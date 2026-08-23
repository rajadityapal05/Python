-- ============================================================
-- SOUNDIQ - BUSINESS INSIGHTS
-- ============================================================


-- ============================================================
-- 1. MONTHLY REVENUE TRENDS
-- ============================================================

SELECT
    DATE_TRUNC('month', i.invoice_date)::date AS month,
    COUNT(DISTINCT i.invoice_id) AS orders,
    COUNT(DISTINCT i.customer_id) AS customers,
    ROUND(SUM(i.total)::numeric, 2) AS revenue,
    ROUND(
        (SUM(i.total) / NULLIF(COUNT(DISTINCT i.invoice_id), 0))::numeric,
        2
    ) AS average_order_value
FROM invoice i
GROUP BY DATE_TRUNC('month', i.invoice_date)
ORDER BY month;


-- ============================================================
-- 2. CUSTOMER REVENUE BY COUNTRY
-- ============================================================

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT i.invoice_id) AS orders,
    ROUND(SUM(i.total)::numeric, 2) AS revenue,
    ROUND(
        (SUM(i.total) / NULLIF(COUNT(DISTINCT c.customer_id), 0))::numeric,
        2
    ) AS revenue_per_customer
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue DESC;


-- ============================================================
-- 3. CUSTOMER SEGMENT DISTRIBUTION
-- ============================================================

WITH customer_metrics AS (
    SELECT
        c.customer_id,
        MAX(i.invoice_date)::date AS last_purchase_date,
        CURRENT_DATE - MAX(i.invoice_date)::date AS recency_days,
        COUNT(DISTINCT i.invoice_id) AS orders,
        SUM(i.total) AS lifetime_value
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
scored AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS recency_score,
        NTILE(5) OVER (
            ORDER BY orders
        ) AS frequency_score,
        NTILE(5) OVER (
            ORDER BY lifetime_value
        ) AS monetary_score
    FROM customer_metrics
),
segmented AS (
    SELECT
        *,
        recency_score
        + frequency_score
        + monetary_score AS rfm_score,
        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'Champions'

            WHEN recency_score >= 4
                 AND frequency_score <= 3
                THEN 'Potential Loyalists'

            WHEN recency_score <= 2
                 AND frequency_score >= 4
                THEN 'At Risk'

            WHEN recency_score <= 2
                 AND frequency_score <= 2
                 AND monetary_score <= 2
                THEN 'Dormant'

            ELSE 'Regular Customers'
        END AS customer_segment
    FROM scored
)
SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(
        (100.0 * COUNT(*) / SUM(COUNT(*)) OVER ())::numeric,
        2
    ) AS customer_share_pct,
    ROUND(
        SUM(lifetime_value)::numeric,
        2
    ) AS segment_revenue,
    ROUND(
        AVG(lifetime_value)::numeric,
        2
    ) AS average_customer_value
FROM segmented
GROUP BY customer_segment
ORDER BY segment_revenue DESC;


-- ============================================================
-- 4. HIGH-VALUE CUSTOMERS AT RISK
-- ============================================================

WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.country,
        MAX(i.invoice_date)::date AS last_purchase_date,
        CURRENT_DATE - MAX(i.invoice_date)::date AS recency_days,
        COUNT(DISTINCT i.invoice_id) AS orders,
        ROUND(SUM(i.total)::numeric, 2) AS lifetime_value
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country
),
ranked AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS recency_score,
        NTILE(5) OVER (
            ORDER BY orders
        ) AS frequency_score,
        NTILE(5) OVER (
            ORDER BY lifetime_value
        ) AS monetary_score
    FROM customer_metrics
)
SELECT
    customer_id,
    customer_name,
    country,
    last_purchase_date,
    recency_days,
    orders,
    lifetime_value,
    recency_score,
    frequency_score,
    monetary_score,
    'HIGH-VALUE AT-RISK' AS retention_priority
FROM ranked
WHERE monetary_score >= 4
  AND recency_score <= 2
ORDER BY lifetime_value DESC;


-- ============================================================
-- 5. GENRE OPPORTUNITY ANALYSIS
-- ============================================================

WITH genre_metrics AS (
    SELECT
        g.genre_id,
        g.name AS genre,
        COUNT(DISTINCT t.track_id) AS catalog_tracks,
        COUNT(DISTINCT il.invoice_line_id) AS units_sold,
        COUNT(DISTINCT i.customer_id) AS unique_customers,
        ROUND(
            SUM(il.unit_price * il.quantity)::numeric,
            2
        ) AS revenue
    FROM genre g
    JOIN track t
        ON g.genre_id = t.genre_id
    LEFT JOIN invoice_line il
        ON t.track_id = il.track_id
    LEFT JOIN invoice i
        ON il.invoice_id = i.invoice_id
    GROUP BY
        g.genre_id,
        g.name
)
SELECT
    genre,
    catalog_tracks,
    units_sold,
    unique_customers,
    revenue,
    ROUND(
        (
            revenue / NULLIF(catalog_tracks, 0)
        )::numeric,
        2
    ) AS revenue_per_catalog_track,
    CASE
        WHEN revenue >= 50
             AND unique_customers >= 10
            THEN 'CORE PERFORMER'

        WHEN catalog_tracks >= 50
             AND revenue < 50
            THEN 'UNDERPERFORMING CATALOG'

        WHEN catalog_tracks < 50
             AND revenue >= 50
            THEN 'HIGH-POTENTIAL NICHE'

        ELSE 'STANDARD'
    END AS opportunity_type
FROM genre_metrics
ORDER BY revenue DESC;


-- ============================================================
-- 6. REVENUE CONCENTRATION
-- ============================================================

WITH track_revenue AS (
    SELECT
        t.track_id,
        t.name AS track_name,
        SUM(il.unit_price * il.quantity) AS revenue
    FROM track t
    JOIN invoice_line il
        ON t.track_id = il.track_id
    GROUP BY
        t.track_id,
        t.name
),
ranked_tracks AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY revenue DESC
        ) AS track_rank,
        COUNT(*) OVER () AS total_tracks,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM track_revenue
)
SELECT
    track_rank,
    track_id,
    track_name,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (100.0 * track_rank / total_tracks)::numeric,
        2
    ) AS catalog_percentile,
    ROUND(
        (100.0 * revenue / total_revenue)::numeric,
        2
    ) AS revenue_share_pct,
    ROUND(
        (100.0 * cumulative_revenue / total_revenue)::numeric,
        2
    ) AS cumulative_revenue_pct
FROM ranked_tracks
WHERE track_rank <= 100
ORDER BY track_rank;


-- ============================================================
-- 7. TOP 10% TRACK REVENUE CONTRIBUTION
-- ============================================================

WITH track_revenue AS (
    SELECT
        t.track_id,
        SUM(il.unit_price * il.quantity) AS revenue
    FROM track t
    JOIN invoice_line il
        ON t.track_id = il.track_id
    GROUP BY t.track_id
),
ranked AS (
    SELECT
        *,
        NTILE(10) OVER (
            ORDER BY revenue DESC
        ) AS revenue_decile
    FROM track_revenue
)
SELECT
    revenue_decile,
    COUNT(*) AS tracks,
    ROUND(SUM(revenue)::numeric, 2) AS revenue,
    ROUND(
        (
            100.0 * SUM(revenue)
            / SUM(SUM(revenue)) OVER ()
        )::numeric,
        2
    ) AS revenue_share_pct
FROM ranked
GROUP BY revenue_decile
ORDER BY revenue_decile;


-- ============================================================
-- 8. BUSINESS KPI SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT i.invoice_id) AS total_orders,

    COUNT(DISTINCT i.customer_id) AS total_customers,

    ROUND(
        SUM(i.total)::numeric,
        2
    ) AS total_revenue,

    ROUND(
        (
            SUM(i.total)
            / NULLIF(COUNT(DISTINCT i.invoice_id), 0)
        )::numeric,
        2
    ) AS average_order_value,

    COUNT(DISTINCT il.track_id) AS unique_tracks_sold,

    SUM(il.quantity) AS total_tracks_sold,

    ROUND(
        (
            100.0 * COUNT(DISTINCT CASE
                WHEN i.invoice_date >= CURRENT_DATE - INTERVAL '90 days'
                THEN i.customer_id
            END)
            / NULLIF(COUNT(DISTINCT i.customer_id), 0)
        )::numeric,
        2
    ) AS active_customer_rate_pct

FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id;


-- ============================================================
-- 9. CUSTOMER VALUE TIERS
-- ============================================================

WITH customer_value AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        COUNT(DISTINCT i.invoice_id) AS orders,
        ROUND(SUM(i.total)::numeric, 2) AS lifetime_value
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    CASE
        WHEN lifetime_value >= 45 THEN 'High Value'
        WHEN lifetime_value >= 40 THEN 'Medium Value'
        ELSE 'Standard Value'
    END AS value_tier,
    COUNT(*) AS customers,
    ROUND(SUM(lifetime_value)::numeric, 2) AS revenue,
    ROUND(AVG(lifetime_value)::numeric, 2) AS average_customer_value
FROM customer_value
GROUP BY
    CASE
        WHEN lifetime_value >= 45 THEN 'High Value'
        WHEN lifetime_value >= 40 THEN 'Medium Value'
        ELSE 'Standard Value'
    END
ORDER BY revenue DESC;


-- ============================================================
-- 10. TOP COUNTRIES BY CUSTOMER VALUE
-- ============================================================

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(i.total)::numeric, 2) AS revenue,
    ROUND(
        (
            SUM(i.total)
            / NULLIF(COUNT(DISTINCT c.customer_id), 0)
        )::numeric,
        2
    ) AS revenue_per_customer,
    ROUND(
        (
            SUM(i.total)
            / NULLIF(COUNT(DISTINCT i.invoice_id), 0)
        )::numeric,
        2
    ) AS average_order_value
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.country
HAVING COUNT(DISTINCT c.customer_id) >= 2
ORDER BY revenue_per_customer DESC;


-- ============================================================
-- END OF SOUNDIQ BUSINESS INTELLIGENCE
-- ============================================================
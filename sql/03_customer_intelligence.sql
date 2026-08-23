-- ============================================================
-- SoundIQ - Customer Intelligence & RFM Segmentation
-- ============================================================

WITH customer_metrics AS (

    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.country,

        COUNT(i.invoice_id) AS orders,

        SUM(i.total) AS lifetime_value,

        AVG(i.total) AS average_order_value,

        MAX(i.invoice_date)::date AS last_purchase_date

    FROM customer c

    JOIN invoice i
        ON c.customer_id = i.customer_id

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country
),

customer_tracks AS (

    SELECT
        i.customer_id,
        COUNT(il.invoice_line_id) AS tracks_purchased,
        COUNT(DISTINCT t.genre_id) AS genres_purchased

    FROM invoice i

    JOIN invoice_line il
        ON i.invoice_id = il.invoice_id

    JOIN track t
        ON il.track_id = t.track_id

    GROUP BY i.customer_id
),

rfm_base AS (

    SELECT
        cm.*,

        COALESCE(ct.tracks_purchased, 0) AS tracks_purchased,

        COALESCE(ct.genres_purchased, 0) AS genres_purchased,

        (
            MAX(cm.last_purchase_date) OVER ()
            - cm.last_purchase_date
        ) AS recency_days

    FROM customer_metrics cm

    LEFT JOIN customer_tracks ct
        ON cm.customer_id = ct.customer_id
),

rfm_scores AS (

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

    FROM rfm_base
)

SELECT
    customer_id,
    customer_name,
    country,

    recency_days,
    orders,
    tracks_purchased,
    genres_purchased,

    ROUND(lifetime_value::numeric, 2) AS lifetime_value,

    ROUND(average_order_value::numeric, 2) AS average_order_value,

    recency_score,
    frequency_score,
    monetary_score,

    recency_score
        + frequency_score
        + monetary_score AS rfm_score,

    CASE

        WHEN recency_score >= 4
             AND monetary_score >= 4
        THEN 'Champions'

        WHEN recency_score >= 4
             AND frequency_score >= 4
        THEN 'Loyal Customers'

        WHEN recency_score >= 4
             AND monetary_score >= 3
        THEN 'Potential Loyalists'

        WHEN recency_score <= 2
             AND monetary_score >= 4
        THEN 'At Risk'

        WHEN recency_score <= 2
             AND monetary_score <= 2
        THEN 'Dormant'

        ELSE 'Regular Customers'

    END AS customer_segment

FROM rfm_scores

ORDER BY
    rfm_score DESC,
    lifetime_value DESC;
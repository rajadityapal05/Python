/*
============================================================
 SoundIQ — Revenue Intelligence
 Module: 02_revenue_intelligence.sql

 Business Questions:
 1. What is total revenue?
 2. What is the average invoice value?
 3. Which countries generate the most revenue?
 4. How does revenue change over time?
 5. Which customers generate the most revenue?
 6. How concentrated is revenue?
 7. Which genres generate the most revenue?
============================================================
*/


/*
============================================================
 1. OVERALL REVENUE PERFORMANCE
============================================================
*/

SELECT
    COUNT(DISTINCT invoice_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS paying_customers,
    ROUND(SUM(total)::numeric, 2) AS total_revenue,
    ROUND(AVG(total)::numeric, 2) AS average_order_value,
    ROUND(MIN(total)::numeric, 2) AS smallest_order,
    ROUND(MAX(total)::numeric, 2) AS largest_order
FROM invoice;


/*
============================================================
 2. REVENUE BY COUNTRY
============================================================
*/

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT i.invoice_id) AS orders,
    ROUND(SUM(i.total)::numeric, 2) AS revenue,
    ROUND(
        100.0 * SUM(i.total)
        / SUM(SUM(i.total)) OVER (),
        2
    ) AS revenue_share_pct
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue DESC;


/*
============================================================
 3. MONTHLY REVENUE TREND
============================================================
*/

SELECT
    DATE_TRUNC('month', invoice_date)::date AS month,
    COUNT(*) AS orders,
    ROUND(SUM(total)::numeric, 2) AS revenue
FROM invoice
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY month;


/*
============================================================
 4. MONTH-OVER-MONTH REVENUE GROWTH
============================================================
*/

WITH monthly_revenue AS (

    SELECT
        DATE_TRUNC('month', invoice_date)::date AS month,
        SUM(total) AS revenue
    FROM invoice
    GROUP BY DATE_TRUNC('month', invoice_date)

),

revenue_with_previous AS (

    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_revenue

)

SELECT
    month,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(previous_month_revenue::numeric, 2)
        AS previous_month_revenue,
    ROUND(
        (
            (revenue - previous_month_revenue)
            / NULLIF(previous_month_revenue, 0)
        )::numeric * 100,
        2
    ) AS mom_growth_pct
FROM revenue_with_previous
ORDER BY month;


/*
============================================================
 5. TOP CUSTOMERS BY LIFETIME VALUE
============================================================
*/

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.country,
    COUNT(i.invoice_id) AS orders,
    ROUND(SUM(i.total)::numeric, 2) AS lifetime_value,
    ROUND(AVG(i.total)::numeric, 2) AS average_order_value
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.country
ORDER BY lifetime_value DESC
LIMIT 20;


/*
============================================================
 6. CUSTOMER REVENUE CONTRIBUTION
============================================================
*/

WITH customer_revenue AS (

    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(i.total) AS revenue
    FROM customer c
    JOIN invoice i
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name

)

SELECT
    customer_name,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        100.0 * revenue
        / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct,
    ROUND(
        100.0 * SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
        )
        / SUM(revenue) OVER (),
        2
    ) AS cumulative_revenue_pct
FROM customer_revenue
ORDER BY revenue DESC;


/*
============================================================
 7. REVENUE BY GENRE
============================================================
*/

SELECT
    g.name AS genre,
    COUNT(DISTINCT il.invoice_line_id) AS tracks_sold,
    ROUND(
        SUM(il.unit_price * il.quantity)::numeric,
        2
    ) AS revenue,
    ROUND(
        100.0 * SUM(il.unit_price * il.quantity)
        / SUM(SUM(il.unit_price * il.quantity)) OVER (),
        2
    ) AS revenue_share_pct
FROM genre g
JOIN track t
    ON g.genre_id = t.genre_id
JOIN invoice_line il
    ON t.track_id = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY revenue DESC;


/*
============================================================
 8. REVENUE BY MEDIA TYPE
============================================================
*/

SELECT
    mt.name AS media_type,
    COUNT(il.invoice_line_id) AS tracks_sold,
    ROUND(
        SUM(il.unit_price * il.quantity)::numeric,
        2
    ) AS revenue
FROM media_type mt
JOIN track t
    ON mt.media_type_id = t.media_type_id
JOIN invoice_line il
    ON t.track_id = il.track_id
GROUP BY mt.media_type_id, mt.name
ORDER BY revenue DESC;


/*
============================================================
 END OF REVENUE INTELLIGENCE
============================================================
*/
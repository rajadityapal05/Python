-- ============================================================
-- SOUNDIQ - ARTIST INTELLIGENCE
-- ============================================================


-- 1. Top artists by revenue
SELECT
    ar.artist_id,
    ar.name AS artist,
    COUNT(DISTINCT t.track_id) AS catalog_tracks,
    COUNT(il.invoice_line_id) AS units_sold,
    ROUND(
        SUM(il.unit_price * il.quantity)::numeric,
        2
    ) AS revenue
FROM artist ar
JOIN album al
    ON ar.artist_id = al.artist_id
JOIN track t
    ON al.album_id = t.album_id
JOIN invoice_line il
    ON t.track_id = il.track_id
GROUP BY
    ar.artist_id,
    ar.name
ORDER BY revenue DESC
LIMIT 20;


-- 2. Artist revenue share
WITH artist_revenue AS (
    SELECT
        ar.artist_id,
        ar.name AS artist,
        SUM(il.unit_price * il.quantity) AS revenue
    FROM artist ar
    JOIN album al
        ON ar.artist_id = al.artist_id
    JOIN track t
        ON al.album_id = t.album_id
    JOIN invoice_line il
        ON t.track_id = il.track_id
    GROUP BY
        ar.artist_id,
        ar.name
)
SELECT
    artist,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (100 * revenue / SUM(revenue) OVER ())::numeric,
        2
    ) AS revenue_share_pct,
    ROUND(
        (
            100 *
            SUM(revenue) OVER (
                ORDER BY revenue DESC
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
            )
            / SUM(revenue) OVER ()
        )::numeric,
        2
    ) AS cumulative_revenue_pct
FROM artist_revenue
ORDER BY revenue DESC;


-- 3. Artist catalog efficiency
WITH artist_metrics AS (
    SELECT
        ar.artist_id,
        ar.name AS artist,
        COUNT(DISTINCT t.track_id) AS catalog_tracks,
        COUNT(il.invoice_line_id) AS units_sold,
        COALESCE(
            SUM(il.unit_price * il.quantity),
            0
        ) AS revenue
    FROM artist ar
    JOIN album al
        ON ar.artist_id = al.artist_id
    JOIN track t
        ON al.album_id = t.album_id
    LEFT JOIN invoice_line il
        ON t.track_id = il.track_id
    GROUP BY
        ar.artist_id,
        ar.name
)
SELECT
    artist,
    catalog_tracks,
    units_sold,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (revenue / NULLIF(catalog_tracks, 0))::numeric,
        2
    ) AS revenue_per_track
FROM artist_metrics
WHERE revenue > 0
ORDER BY revenue_per_track DESC
LIMIT 20;


-- 4. Artists with large catalogs but weak sales
WITH artist_metrics AS (
    SELECT
        ar.artist_id,
        ar.name AS artist,
        COUNT(DISTINCT t.track_id) AS catalog_tracks,
        COUNT(il.invoice_line_id) AS units_sold,
        COALESCE(
            SUM(il.unit_price * il.quantity),
            0
        ) AS revenue
    FROM artist ar
    JOIN album al
        ON ar.artist_id = al.artist_id
    JOIN track t
        ON al.album_id = t.album_id
    LEFT JOIN invoice_line il
        ON t.track_id = il.track_id
    GROUP BY
        ar.artist_id,
        ar.name
)
SELECT
    artist,
    catalog_tracks,
    units_sold,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (revenue / NULLIF(catalog_tracks, 0))::numeric,
        2
    ) AS revenue_per_track
FROM artist_metrics
WHERE catalog_tracks >= 10
ORDER BY revenue_per_track ASC
LIMIT 20;


-- 5. Artist catalog penetration
WITH artist_metrics AS (
    SELECT
        ar.artist_id,
        ar.name AS artist,
        COUNT(DISTINCT t.track_id) AS catalog_tracks,
        COUNT(DISTINCT CASE
            WHEN il.invoice_line_id IS NOT NULL
            THEN t.track_id
        END) AS tracks_sold
    FROM artist ar
    JOIN album al
        ON ar.artist_id = al.artist_id
    JOIN track t
        ON al.album_id = t.album_id
    LEFT JOIN invoice_line il
        ON t.track_id = il.track_id
    GROUP BY
        ar.artist_id,
        ar.name
)
SELECT
    artist,
    catalog_tracks,
    tracks_sold,
    ROUND(
        (
            100.0 * tracks_sold
            / NULLIF(catalog_tracks, 0)
        )::numeric,
        2
    ) AS catalog_penetration_pct
FROM artist_metrics
ORDER BY catalog_penetration_pct DESC, catalog_tracks DESC;


-- 6. Artist diversity by genre
SELECT
    ar.name AS artist,
    COUNT(DISTINCT g.genre_id) AS genres,
    STRING_AGG(
        DISTINCT g.name,
        ', '
        ORDER BY g.name
    ) AS genre_mix
FROM artist ar
JOIN album al
    ON ar.artist_id = al.artist_id
JOIN track t
    ON al.album_id = t.album_id
JOIN genre g
    ON t.genre_id = g.genre_id
GROUP BY
    ar.artist_id,
    ar.name
HAVING COUNT(DISTINCT g.genre_id) > 1
ORDER BY genres DESC, artist;


-- 7. Top artists by customer reach
SELECT
    ar.name AS artist,
    COUNT(DISTINCT c.customer_id) AS unique_customers,
    COUNT(il.invoice_line_id) AS units_sold,
    ROUND(
        SUM(il.unit_price * il.quantity)::numeric,
        2
    ) AS revenue
FROM artist ar
JOIN album al
    ON ar.artist_id = al.artist_id
JOIN track t
    ON al.album_id = t.album_id
JOIN invoice_line il
    ON t.track_id = il.track_id
JOIN invoice i
    ON il.invoice_id = i.invoice_id
JOIN customer c
    ON i.customer_id = c.customer_id
GROUP BY
    ar.artist_id,
    ar.name
ORDER BY unique_customers DESC, revenue DESC
LIMIT 20;
-- ============================================================
-- SOUNDIQ - PRODUCT INTELLIGENCE
-- ============================================================

-- 1. Top-selling tracks
SELECT
    t.track_id,
    t.name AS track_name,
    ar.name AS artist,
    g.name AS genre,
    COUNT(il.invoice_line_id) AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity)::numeric, 2) AS revenue
FROM track t
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
JOIN genre g
    ON t.genre_id = g.genre_id
JOIN invoice_line il
    ON t.track_id = il.track_id
GROUP BY
    t.track_id,
    t.name,
    ar.name,
    g.name
ORDER BY revenue DESC
LIMIT 20;


-- 2. Tracks that have never been purchased
SELECT
    t.track_id,
    t.name AS track_name,
    ar.name AS artist,
    g.name AS genre
FROM track t
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
JOIN genre g
    ON t.genre_id = g.genre_id
LEFT JOIN invoice_line il
    ON t.track_id = il.track_id
WHERE il.invoice_line_id IS NULL
ORDER BY artist, track_name;


-- 3. Artist performance
SELECT
    ar.artist_id,
    ar.name AS artist,
    COUNT(DISTINCT t.track_id) AS catalog_tracks,
    COUNT(il.invoice_line_id) AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity)::numeric, 2) AS revenue
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
HAVING COUNT(il.invoice_line_id) > 0
ORDER BY revenue DESC
LIMIT 20;


-- 4. Artist catalog efficiency
SELECT
    ar.name AS artist,
    COUNT(DISTINCT t.track_id) AS catalog_tracks,
    COUNT(il.invoice_line_id) AS units_sold,
    ROUND(
        SUM(il.unit_price * il.quantity)::numeric,
        2
    ) AS revenue,
    ROUND(
        (
            SUM(il.unit_price * il.quantity)
            / NULLIF(COUNT(DISTINCT t.track_id), 0)
        )::numeric,
        2
    ) AS revenue_per_catalog_track
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
HAVING COUNT(il.invoice_line_id) > 0
ORDER BY revenue_per_catalog_track DESC
LIMIT 20;


-- 5. Album performance
SELECT
    al.album_id,
    al.title AS album,
    ar.name AS artist,
    COUNT(DISTINCT t.track_id) AS tracks_in_album,
    COUNT(il.invoice_line_id) AS units_sold,
    ROUND(SUM(il.unit_price * il.quantity)::numeric, 2) AS revenue
FROM album al
JOIN artist ar
    ON al.artist_id = ar.artist_id
JOIN track t
    ON al.album_id = t.album_id
JOIN invoice_line il
    ON t.track_id = il.track_id
GROUP BY
    al.album_id,
    al.title,
    ar.name
ORDER BY revenue DESC
LIMIT 20;


-- 6. Genre performance with average revenue per sold track
SELECT
    g.name AS genre,
    COUNT(il.invoice_line_id) AS units_sold,
    ROUND(
        SUM(il.unit_price * il.quantity)::numeric,
        2
    ) AS revenue,
    ROUND(
        AVG(il.unit_price * il.quantity)::numeric,
        2
    ) AS average_line_value
FROM genre g
JOIN track t
    ON g.genre_id = t.genre_id
JOIN invoice_line il
    ON t.track_id = il.track_id
GROUP BY
    g.genre_id,
    g.name
ORDER BY revenue DESC;


-- 7. Revenue concentration by track
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
        track_id,
        track_name,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (
            ORDER BY revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_revenue
    FROM track_revenue
)
SELECT
    track_id,
    track_name,
    ROUND(revenue::numeric, 2) AS revenue,
    ROUND(
        (100 * revenue / total_revenue)::numeric,
        2
    ) AS revenue_share_pct,
    ROUND(
        (100 * cumulative_revenue / total_revenue)::numeric,
        2
    ) AS cumulative_revenue_pct
FROM ranked_tracks
ORDER BY revenue DESC;
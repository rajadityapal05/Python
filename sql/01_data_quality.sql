/*
============================================================
 SoundIQ — Data Quality & Validation
 Module: 01_data_quality.sql

 Purpose:
 Validate the Chinook source database before analytics.

 Checks:
 1. Table row counts
 2. Referential integrity
 3. NULL values
 4. Duplicate records
 5. Business-rule validation
============================================================
*/


/*
============================================================
 1. TABLE ROW COUNTS
============================================================
*/

SELECT 'artist' AS table_name, COUNT(*) AS row_count
FROM artist

UNION ALL

SELECT 'album', COUNT(*)
FROM album

UNION ALL

SELECT 'track', COUNT(*)
FROM track

UNION ALL

SELECT 'customer', COUNT(*)
FROM customer

UNION ALL

SELECT 'invoice', COUNT(*)
FROM invoice

UNION ALL

SELECT 'invoice_line', COUNT(*)
FROM invoice_line

UNION ALL

SELECT 'genre', COUNT(*)
FROM genre

UNION ALL

SELECT 'employee', COUNT(*)
FROM employee

UNION ALL

SELECT 'playlist', COUNT(*)
FROM playlist

UNION ALL

SELECT 'playlist_track', COUNT(*)
FROM playlist_track

UNION ALL

SELECT 'media_type', COUNT(*)
FROM media_type

ORDER BY table_name;


/*
============================================================
 2. REFERENTIAL INTEGRITY
============================================================
*/


-- Tracks without a valid album

SELECT COUNT(*) AS orphan_tracks
FROM track t
LEFT JOIN album a
    ON t.album_id = a.album_id
WHERE a.album_id IS NULL;


-- Invoice lines without a valid invoice

SELECT COUNT(*) AS orphan_invoice_lines
FROM invoice_line il
LEFT JOIN invoice i
    ON il.invoice_id = i.invoice_id
WHERE i.invoice_id IS NULL;


-- Invoice lines without a valid track

SELECT COUNT(*) AS orphan_invoice_tracks
FROM invoice_line il
LEFT JOIN track t
    ON il.track_id = t.track_id
WHERE t.track_id IS NULL;


-- Albums without a valid artist

SELECT COUNT(*) AS orphan_albums
FROM album a
LEFT JOIN artist ar
    ON a.artist_id = ar.artist_id
WHERE ar.artist_id IS NULL;


/*
============================================================
 3. NULL VALUE CHECKS
============================================================
*/


-- Tracks

SELECT
    COUNT(*) AS total_tracks,
    COUNT(*) FILTER (WHERE name IS NULL) AS null_track_names,
    COUNT(*) FILTER (WHERE album_id IS NULL) AS null_album_ids,
    COUNT(*) FILTER (WHERE genre_id IS NULL) AS null_genre_ids,
    COUNT(*) FILTER (WHERE media_type_id IS NULL) AS null_media_type_ids
FROM track;


-- Customers

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE first_name IS NULL) AS null_first_names,
    COUNT(*) FILTER (WHERE last_name IS NULL) AS null_last_names,
    COUNT(*) FILTER (WHERE email IS NULL) AS null_emails,
    COUNT(*) FILTER (WHERE country IS NULL) AS null_countries
FROM customer;


-- Invoices

SELECT
    COUNT(*) AS total_invoices,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_ids,
    COUNT(*) FILTER (WHERE invoice_date IS NULL) AS null_invoice_dates,
    COUNT(*) FILTER (WHERE total IS NULL) AS null_totals
FROM invoice;


/*
============================================================
 4. DUPLICATE CHECKS
============================================================
*/


-- Duplicate artist names

SELECT
    name,
    COUNT(*) AS duplicate_count
FROM artist
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- Duplicate customer email addresses

SELECT
    email,
    COUNT(*) AS duplicate_count
FROM customer
GROUP BY email
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


/*
============================================================
 5. BUSINESS-RULE VALIDATION
============================================================
*/


-- Invoice totals should never be negative

SELECT COUNT(*) AS negative_invoices
FROM invoice
WHERE total < 0;


-- Invoice line quantities should be positive

SELECT COUNT(*) AS invalid_quantities
FROM invoice_line
WHERE quantity <= 0;


-- Invoice line unit prices should not be negative

SELECT COUNT(*) AS negative_unit_prices
FROM invoice_line
WHERE unit_price < 0;


/*
============================================================
 6. REVENUE CONSISTENCY CHECK
============================================================

Compare invoice totals with the sum of their invoice lines.

This helps detect financial inconsistencies in the source data.
============================================================
*/


SELECT
    i.invoice_id,
    ROUND(i.total::numeric, 2) AS invoice_total,
    ROUND(SUM(il.unit_price * il.quantity)::numeric, 2) AS calculated_total,
    ROUND(
        (i.total - SUM(il.unit_price * il.quantity))::numeric,
        2
    ) AS difference
FROM invoice i
JOIN invoice_line il
    ON i.invoice_id = il.invoice_id
GROUP BY
    i.invoice_id,
    i.total
HAVING ABS(
    i.total - SUM(il.unit_price * il.quantity)
) > 0.01
ORDER BY ABS(
    i.total - SUM(il.unit_price * il.quantity)
) DESC;


/*
============================================================
 END OF DATA QUALITY VALIDATION
============================================================
*/
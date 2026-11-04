-- ============================================================================
-- PORTFOLIO 2: QUERY PROCESSING AND OPTIMISATION
-- Case Study: Grand Horizon Hotel Management System
-- Database: PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- OPERATIONAL QUERY 1: Room Availability Lookup for Date Ranges
-- Description: Finds available physical rooms for a given room type ('Deluxe Suite')
--              between target dates, avoiding double-booking overlaps.
-- ----------------------------------------------------------------------------

-- Execution Plan Baseline (Before Indexing)
EXPLAIN ANALYZE
SELECT 
    r.room_id,
    r.room_number,
    rt.type_name,
    rt.base_price_per_night
FROM Rooms r
JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
WHERE r.status != 'Maintenance'
  AND rt.type_name = 'Deluxe Suite'
  AND r.room_id NOT IN (
      SELECT b.room_id
      FROM Bookings b
      WHERE b.booking_status IN ('Confirmed', 'Checked_In')
        AND b.check_in_date < '2026-12-28'
        AND b.check_out_date > '2026-12-20'
  );


-- ----------------------------------------------------------------------------
-- OPERATIONAL QUERY 2: Financial Revenue & Transaction Analytics
-- Description: Aggregates total payments, average transaction values, and booking
--              counts grouped by room type and payment method for completed payments.
-- ----------------------------------------------------------------------------

-- Execution Plan Baseline (Before Indexing)
EXPLAIN ANALYZE
SELECT 
    rt.type_name,
    p.payment_method,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(p.amount) AS total_revenue,
    ROUND(AVG(p.amount), 2) AS avg_transaction_value
FROM Payments p
JOIN Bookings b ON p.booking_id = b.booking_id
JOIN Rooms r ON b.room_id = r.room_id
JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
WHERE p.payment_status = 'Completed'
  AND p.payment_date >= '2026-01-01'
GROUP BY rt.type_name, p.payment_method
ORDER BY total_revenue DESC;


-- ----------------------------------------------------------------------------
-- OPERATIONAL QUERY 3: High-Value VIP Guest Identification
-- Description: Retrieves guest profiles whose cumulative spend on active/completed
--              reservations exceeds the hotel-wide average reservation spending.
-- ----------------------------------------------------------------------------

-- Execution Plan Baseline (Before Indexing)
EXPLAIN ANALYZE
SELECT 
    g.guest_id,
    g.first_name || ' ' || g.last_name AS full_name,
    g.email,
    COUNT(b.booking_id) AS total_reservations,
    SUM(b.total_amount) AS lifetime_spend
FROM Guests g
JOIN Bookings b ON g.guest_id = b.guest_id
WHERE b.booking_status != 'Cancelled'
GROUP BY g.guest_id, g.first_name, g.last_name, g.email
HAVING SUM(b.total_amount) > (
    SELECT AVG(total_amount) 
    FROM Bookings 
    WHERE booking_status != 'Cancelled'
)
ORDER BY lifetime_spend DESC;


-- ============================================================================
-- PERFORMANCE INDEX CREATION
-- ============================================================================

-- Index 1: Partial Composite Index on Bookings for active reservation dates
-- Optimization Target: Speeds up date-range overlap subqueries in Query 1.
CREATE INDEX idx_bookings_active_dates 
ON Bookings (room_id, check_in_date, check_out_date)
WHERE booking_status IN ('Confirmed', 'Checked_In');

-- Index 2: Composite Index on Payments with Included Columns
-- Optimization Target: Eliminates table scans on Payments during revenue aggregation in Query 2.
CREATE INDEX idx_payments_status_date 
ON Payments (payment_status, payment_date) 
INCLUDE (booking_id, amount);

-- Index 3: Composite Index on Bookings for Guest Foreign Keys & Status
-- Optimization Target: Accelerates joining and grouping operations in Query 3.
CREATE INDEX idx_bookings_guest_status 
ON Bookings (guest_id, booking_status) 
INCLUDE (total_amount);


-- ============================================================================
-- VERIFICATION: EXPLAIN ANALYZE (Post-Indexing Execution Plans)
-- Run these statements to verify index usage and scan cost reductions.
-- ============================================================================

-- Re-test Query 1 with Index
EXPLAIN ANALYZE
SELECT 
    r.room_id,
    r.room_number,
    rt.type_name,
    rt.base_price_per_night
FROM Rooms r
JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
WHERE r.status != 'Maintenance'
  AND rt.type_name = 'Deluxe Suite'
  AND r.room_id NOT IN (
      SELECT b.room_id
      FROM Bookings b
      WHERE b.booking_status IN ('Confirmed', 'Checked_In')
        AND b.check_in_date < '2026-12-28'
        AND b.check_out_date > '2026-12-20'
  );

-- Re-test Query 2 with Index
EXPLAIN ANALYZE
SELECT 
    rt.type_name,
    p.payment_method,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(p.amount) AS total_revenue,
    ROUND(AVG(p.amount), 2) AS avg_transaction_value
FROM Payments p
JOIN Bookings b ON p.booking_id = b.booking_id
JOIN Rooms r ON b.room_id = r.room_id
JOIN Room_Types rt ON r.room_type_id = rt.room_type_id
WHERE p.payment_status = 'Completed'
  AND p.payment_date >= '2026-01-01'
GROUP BY rt.type_name, p.payment_method
ORDER BY total_revenue DESC;

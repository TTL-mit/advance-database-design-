-- ============================================================================
-- PORTFOLIO 3: TRANSACTIONS & CONCURRENCY CONTROL
-- Case Study: Grand Horizon Hotel Management System
-- Database Engine: PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SCENARIO 1: ATOMIC ROOM RESERVATION & PAYMENT TRANSACTION
-- Demonstrates Atomicity and Consistency (ACID).
-- Either both the reservation and payment succeed, or the whole transaction rolls back.
-- ----------------------------------------------------------------------------

BEGIN;

-- 1. Check room availability and lock the row to prevent concurrent modifications
SELECT room_id, room_number, status 
FROM Rooms 
WHERE room_id = 9 AND status = 'Available' 
FOR UPDATE;

-- 2. Insert new reservation
INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, total_amount, booking_status)
VALUES (1, 9, '2026-12-24', '2026-12-30', 2100.00, 'Confirmed');

-- 3. Update physical room status to 'Reserved'
UPDATE Rooms 
SET status = 'Reserved' 
WHERE room_id = 9;

-- 4. Process associated payment
INSERT INTO Payments (booking_id, amount, payment_method, payment_status)
VALUES (currval('bookings_booking_id_seq'), 2100.00, 'Credit Card', 'Completed');

-- Commit transaction atomically
COMMIT;

-- Note: If payment fails or input data is invalid, execute ROLLBACK;


-- ----------------------------------------------------------------------------
-- SCENARIO 2: PREVENTING DOUBLE-BOOKING (CONCURRENCY CONTROL VIA ROW LOCKING)
-- Simulates two concurrent user sessions attempting to book Room 5 simultaneously.
-- ----------------------------------------------------------------------------

-- SESSION A (Terminal / Window 1)
BEGIN;

SELECT room_id, status 
FROM Rooms 
WHERE room_id = 5 
FOR UPDATE; -- Session A acquires an exclusive row lock on Room 5

-- SESSION B (Terminal / Window 2)
-- If Session B attempts to read or reserve Room 5 with FOR UPDATE:
-- SELECT room_id, status FROM Rooms WHERE room_id = 5 FOR UPDATE;
-- RESULT: Session B is blocked and waits until Session A finishes.

-- SESSION A completes reservation:
INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, total_amount, booking_status)
VALUES (3, 5, '2026-12-24', '2026-12-28', 720.00, 'Confirmed');

UPDATE Rooms SET status = 'Reserved' WHERE room_id = 5;

COMMIT; -- Releases lock. Session B unblocks, re-evaluates, and sees status is no longer 'Available'.


-- ----------------------------------------------------------------------------
-- SCENARIO 3: TRANSACTION ISOLATION LEVEL COMPARISON (SERIALIZABLE)
-- Prevents lost updates and phantom reads during concurrent reporting.
-- ----------------------------------------------------------------------------

-- Set transaction isolation level to SERIALIZABLE for high-integrity financial operations
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT SUM(amount) AS total_daily_revenue 
FROM Payments 
WHERE payment_date::date = '2026-11-02' 
  AND payment_status = 'Completed';

-- Ensures no new concurrent payments committed during this session will alter the result set
COMMIT;

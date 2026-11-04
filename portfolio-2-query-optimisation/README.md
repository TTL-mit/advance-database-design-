# Portfolio 2: Query Processing & Optimisation

## 1. Overview & Database Setup
This portfolio component demonstrates query design, execution plan analysis using PostgreSQL's `EXPLAIN ANALYZE`, and performance tuning using targeted indexing strategies [2, 3].

* **Database Engine:** PostgreSQL
* **Case Study:** Grand Horizon Hotel Management System
* **Prerequisite Scripts:**
  1. `portfolio-1-database-design/schema.sql` (Schema DDL)
  2. `portfolio-2-query-optimisation/seed.sql` (Test Dataset Population)
  3. `portfolio-2-query-optimisation/queries.sql` (Operational Queries & Index Statements)

---

## 2. Core Operational Queries

### Query 1: Room Availability Lookup for Specific Date Range
* **Business Requirement:** Front desk staff need to check for available physical rooms of a target type (e.g., `'Deluxe Suite'`) between check-in and check-out dates without double-booking.
* **SQL Implementation:**
```sql
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

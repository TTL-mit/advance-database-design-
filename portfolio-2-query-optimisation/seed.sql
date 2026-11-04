-- Seed Data for Hotel Reservation System
BEGIN;

-- 1. Insert Room Types
INSERT INTO Room_Types (type_name, base_price_per_night, max_capacity, description) VALUES
('Standard Room', 100.00, 2, 'Cozy single/double room with standard amenities'),
('Executive Room', 180.00, 2, 'Spacious room with king bed and city view workspace'),
('Deluxe Suite', 350.00, 4, 'Luxury multi-room suite with private lounge access'),
('Presidential Suite', 800.00, 6, 'Top-floor penthouse suite with full hotel services');

-- 2. Insert Physical Rooms
INSERT INTO Rooms (room_number, room_type_id, floor_number, status) VALUES
('101', 1, 1, 'Available'),
('102', 1, 1, 'Occupied'),
('103', 1, 1, 'Available'),
('104', 1, 1, 'Maintenance'),
('201', 2, 2, 'Available'),
('202', 2, 2, 'Occupied'),
('203', 2, 2, 'Reserved'),
('204', 2, 2, 'Available'),
('301', 3, 3, 'Available'),
('302', 3, 3, 'Reserved'),
('303', 3, 3, 'Available'),
('401', 4, 4, 'Available');

-- 3. Insert Guests
INSERT INTO Guests (first_name, last_name, email, phone) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '+1-555-0101'),
('Bob', 'Smith', 'bob.smith@example.com', '+1-555-0102'),
('Charlie', 'Brown', 'charlie.brown@example.com', '+1-555-0103'),
('Diana', 'Prince', 'diana.prince@example.com', '+1-555-0104'),
('Evan', 'Wright', 'evan.wright@example.com', '+1-555-0105'),
('Fiona', 'Gallagher', 'fiona.g@example.com', '+1-555-0106'),
('George', 'Clark', 'george.clark@example.com', '+1-555-0107'),
('Hannah', 'Abbott', 'hannah.a@example.com', '+1-555-0108');

-- 4. Insert Bookings (Historical, Current, and Future Dates)
INSERT INTO Bookings (guest_id, room_id, check_in_date, check_out_date, total_amount, booking_status) VALUES
(1, 1, '2026-01-10', '2026-01-15', 500.00, 'Checked_Out'),
(2, 5, '2026-02-01', '2026-02-05', 720.00, 'Checked_Out'),
(3, 9, '2026-03-12', '2026-03-16', 1400.00, 'Checked_Out'),
(4, 12, '2026-04-20', '2026-04-25', 4000.00, 'Checked_Out'),
(5, 2, '2026-11-01', '2026-11-05', 400.00, 'Checked_In'),
(6, 6, '2026-11-02', '2026-11-07', 900.00, 'Checked_In'),
(7, 7, '2026-12-20', '2026-12-26', 1080.00, 'Confirmed'),
(8, 10, '2026-12-22', '2026-12-27', 1750.00, 'Confirmed'),
(1, 9, '2026-12-24', '2026-12-30', 2100.00, 'Confirmed'),
(2, 11, '2026-12-25', '2026-12-29', 1400.00, 'Cancelled');

-- 5. Insert Payment Records
INSERT INTO Payments (booking_id, payment_date, amount, payment_method, payment_status) VALUES
(1, '2026-01-10 09:15:00', 500.00, 'Credit Card', 'Completed'),
(2, '2026-02-01 14:30:00', 720.00, 'Debit Card', 'Completed'),
(3, '2026-03-12 11:00:00', 1400.00, 'Bank Transfer', 'Completed'),
(4, '2026-04-20 16:45:00', 4000.00, 'Credit Card', 'Completed'),
(5, '2026-11-01 10:20:00', 400.00, 'Cash', 'Completed'),
(6, '2026-11-02 15:10:00', 900.00, 'Credit Card', 'Completed'),
(7, '2026-11-15 12:00:00', 1080.00, 'Credit Card', 'Completed'),
(8, '2026-11-20 08:30:00', 1750.00, 'Debit Card', 'Completed'),
(9, '2026-11-22 19:00:00', 2100.00, 'Credit Card', 'Completed'),
(10, '2026-11-23 10:00:00', 1400.00, 'Credit Card', 'Refunded');

-- 6. Insert Check-In/Out Audit Records
INSERT INTO Check_In_Out_Records (booking_id, actual_check_in, actual_check_out, handled_by_staff) VALUES
(1, '2026-01-10 14:05:00', '2026-01-15 10:30:00', 'Staff_John'),
(2, '2026-02-01 15:20:00', '2026-02-05 11:00:00', 'Staff_Mary'),
(3, '2026-03-12 13:45:00', '2026-03-16 09:50:00', 'Staff_John'),
(4, '2026-04-20 14:00:00', '2026-04-25 11:15:00', 'Staff_Sarah'),
(5, '2026-11-01 14:10:00', NULL, 'Staff_Mary'),
(6, '2026-11-02 15:00:00', NULL, 'Staff_John');

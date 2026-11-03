-- PostgreSQL Schema for Hotel Reservation System

CREATE TABLE Room_Types (
    room_type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    base_price_per_night DECIMAL(10,2) NOT NULL CHECK (base_price_per_night > 0),
    max_capacity INT NOT NULL CHECK (max_capacity >= 1),
    description TEXT
);

CREATE TABLE Rooms (
    room_id SERIAL PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type_id INT NOT NULL REFERENCES Room_Types(room_type_id) ON DELETE RESTRICT,
    floor_number INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Available' 
        CHECK (status IN ('Available', 'Occupied', 'Maintenance', 'Reserved'))
);

CREATE TABLE Guests (
    guest_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,
    guest_id INT NOT NULL REFERENCES Guests(guest_id) ON DELETE RESTRICT,
    room_id INT NOT NULL REFERENCES Rooms(room_id) ON DELETE RESTRICT,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    booking_status VARCHAR(20) NOT NULL DEFAULT 'Confirmed' 
        CHECK (booking_status IN ('Confirmed', 'Checked_In', 'Checked_Out', 'Cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_dates CHECK (check_out_date > check_in_date)
);

CREATE TABLE Payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(30) NOT NULL 
        CHECK (payment_method IN ('Credit Card', 'Debit Card', 'Bank Transfer', 'Cash')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Completed' 
        CHECK (payment_status IN ('Completed', 'Pending', 'Failed', 'Refunded'))
);

CREATE TABLE Check_In_Out_Records (
    record_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    actual_check_in TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actual_check_out TIMESTAMP,
    handled_by_staff VARCHAR(50) NOT NULL,
    CONSTRAINT chk_check_out_time CHECK (actual_check_out IS NULL OR actual_check_out >= actual_check_in)
);


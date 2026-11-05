# Portfolio 1: Database Design & Modelling

## 1. Case Study Specification
* **Organisation Name:** Grand Horizon Hotel Management System
* **Nature of Business:** Hospitality and lodging management system handling guest reservations, room allocation, and financial tracking.
* **Target Users:** Guests, Front Desk Staff, Hotel Managers, and System Administrators.
* **Major Data Stored:** Guest profiles, physical room inventory, room categorisation, reservation periods, transaction billing, and physical check-in/out logs.
* **Key Operations Supported:** Room availability updates, multi-date reservation bookings, payment processing, and arrival/departure logging.

---

## 2. Relational Schema & Integrity Constraints

The relational model consists of 6 normalized entities designed in PostgreSQL:

1. **`Room_Types`**
   * **Attributes:** `room_type_id` (PK, SERIAL), `type_name` (VARCHAR(50)), `base_price_per_night` (DECIMAL(10,2)), `max_capacity` (INT), `description` (TEXT)
   * **Constraints:** `type_name` UNIQUE & NOT NULL, `base_price_per_night > 0`, `max_capacity >= 1`.

2. **`Rooms`**
   * **Attributes:** `room_id` (PK, SERIAL), `room_number` (VARCHAR(10)), `room_type_id` (FK → `Room_Types`), `floor_number` (INT), `status` (VARCHAR(20))
   * **Constraints:** `room_number` UNIQUE & NOT NULL, `status` IN (`'Available'`, `'Occupied'`, `'Maintenance'`, `'Reserved'`).

3. **`Guests`**
   * **Attributes:** `guest_id` (PK, SERIAL), `first_name` (VARCHAR(50)), `last_name` (VARCHAR(50)), `email` (VARCHAR(100)), `phone` (VARCHAR(20)), `created_at` (TIMESTAMP)
   * **Constraints:** `email` UNIQUE & NOT NULL, `first_name` and `last_name` NOT NULL.

4. **`Bookings`**
   * **Attributes:** `booking_id` (PK, SERIAL), `guest_id` (FK → `Guests`), `room_id` (FK → `Rooms`), `check_in_date` (DATE), `check_out_date` (DATE), `total_amount` (DECIMAL(10,2)), `booking_status` (VARCHAR(20)), `created_at` (TIMESTAMP)
   * **Constraints:** `check_out_date > check_in_date`, `total_amount >= 0`, `booking_status` IN (`'Confirmed'`, `'Checked_In'`, `'Checked_Out'`, `'Cancelled'`).

5. **`Payments`**
   * **Attributes:** `payment_id` (PK, SERIAL), `booking_id` (FK → `Bookings`), `payment_date` (TIMESTAMP), `amount` (DECIMAL(10,2)), `payment_method` (VARCHAR(30)), `payment_status` (VARCHAR(20))
   * **Constraints:** `amount > 0`, `payment_method` IN (`'Credit Card'`, `'Debit Card'`, `'Bank Transfer'`, `'Cash'`), `payment_status` IN (`'Completed'`, `'Pending'`, `'Failed'`, `'Refunded'`).

6. **`Check_In_Out_Records`**
   * **Attributes:** `record_id` (PK, SERIAL), `booking_id` (FK → `Bookings`), `actual_check_in` (TIMESTAMP), `actual_check_out` (TIMESTAMP), `handled_by_staff` (VARCHAR(50))
   * **Constraints:** `booking_id` UNIQUE, `actual_check_out >= actual_check_in`.

---

## 3. Entity-Relationship (ER) Diagram

```mermaid
erDiagram
    Room_Types ||--o{ Rooms : categorises
    Guests ||--o{ Bookings : places
    Rooms ||--o{ Bookings : reserved_in
    Bookings ||--o{ Payments : generates
    Bookings ||--|| Check_In_Out_Records : logs

    Room_Types {
        int room_type_id PK
        string type_name
        decimal base_price_per_night
        int max_capacity
        string description
    }

    Rooms {
        int room_id PK
        string room_number
        int room_type_id FK
        int floor_number
        string status
    }

    Guests {
        int guest_id PK
        string first_name
        string last_name
        string email
        string phone
        timestamp created_at
    }

    Bookings {
        int booking_id PK
        int guest_id FK
        int room_id FK
        date check_in_date
        date check_out_date
        decimal total_amount
        string booking_status
        timestamp created_at
    }

    Payments {
        int payment_id PK
        int booking_id FK
        timestamp payment_date
        decimal amount
        string payment_method
        string payment_status
    }

    Check_In_Out_Records {
        int record_id PK
        int booking_id FK
        timestamp actual_check_in
        timestamp actual_check_out
        string handled_by_staff
    }

````

## 4. Normalisation Rationale (up to 3NF)

* **First Normal Form (1NF):** All table fields contain atomic (indivisible) scalar values. Repeating groups (e.g., guest payments or physical room instances) are isolated into dedicated tables (`Payments`, `Rooms`).
* **Second Normal Form (2NF):** The schema meets 1NF criteria and ensures all non-key attributes are fully functionally dependent on the entity's primary key. Shared attributes like `base_price_per_night` depend exclusively on `room_type_id`, preventing redundancy across individual room instances.
* **Third Normal Form (3NF):** Meets 2NF standards with no transitive functional dependencies (i.e., non-key attributes depend *only* on the candidate key). Guest metadata is not duplicated within `Bookings`, and room details are separated from payment logs—eliminating insertion, update, and deletion anomalies.

---

## 5. Script Verification & Execution Instructions

To execute and verify the DDL script:
1. I connected to my PostgreSQL server instance.
2. Run the DDL script:
   ```bash
   psql -U postgres -d hotel_db -f schema.sql
   ```

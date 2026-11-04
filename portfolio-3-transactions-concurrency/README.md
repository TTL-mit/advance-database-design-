# Portfolio 3: Transactions & Concurrency Control

## 1. Executive Summary & ACID Mapping
In a multi-user Hotel Reservation System, database transaction processing must strictly enforce **ACID properties** to guarantee financial accuracy and prevent overbooking rooms.

| ACID Property | Hotel System Application | Implementation Mechanism |
| :--- | :--- | :--- |
| **Atomicity** | Room booking creation, payment collection, and room status updates must all complete together or fail completely. | Explicit `BEGIN`, `COMMIT`, and `ROLLBACK` blocks. |
| **Consistency** | Total booking amount cannot be negative (`CHECK (total_amount >= 0)`) and room check-out date must succeed check-in date. | Database integrity constraints & foreign key rules. |
| **Isolation** | Simultaneous guest checkout/booking transactions do not interfere with each other's uncommitted updates. | Row-level locking (`FOR UPDATE`) & `SERIALIZABLE` transaction isolation levels. |
| **Durability** | Once a guest payment is confirmed and committed, the transaction persists even during system power loss. | Write-Ahead Logging (WAL) in PostgreSQL. |

---

## 2. Concurrency Conflict Analysis & Resolution

### The Double-Booking Anomaly
When two guests attempt to reserve the same physical room for overlapping dates at the exact same second:
1. **Uncontrolled Execution:** Both sessions read `status = 'Available'`. Both proceed to insert booking records and mark the room as reserved—causing a critical double-booking error.
2. **Resolution Strategy:** Pessimistic Row-Level Locking (`SELECT ... FOR UPDATE`).
   * When **Session A** searches for available rooms, `FOR UPDATE` locks the specific row in the `Rooms` table.
   * **Session B** attempting to lock or alter the same row is forced into a wait state until Session A executes `COMMIT` or `ROLLBACK`.
   * Upon Session A's commit, the room status changes to `'Reserved'`, causing Session B's query to fail safely.

---

## 3. Transaction Isolation Levels in PostgreSQL

| Isolation Level | Dirty Read | Non-Repeatable Read | Phantom Read | Serialization Anomaly | Used For |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Read Committed** (Default) | Prevented | Possible | Possible | Possible | General guest room queries & search browsing. |
| **Repeatable Read** | Prevented | Prevented | Prevented | Possible | Guest booking summary view during checkout checkout. |
| **Serializable** | Prevented | Prevented | Prevented | Prevented | Nightly audit reporting & daily financial reconciliation. |

---

## 4. Execution & Testing Instructions

To test concurrent transactions using two PostgreSQL client windows (`psql` or pgAdmin Query Tool):

1. **Open Session 1:**
   ```sql
   BEGIN;
   SELECT room_id, status FROM Rooms WHERE room_id = 5 FOR UPDATE;


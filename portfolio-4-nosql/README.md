# Portfolio 4: NoSQL & Advanced Data Models

## 1. System Architecture & Dual-Database Rationale
While PostgreSQL handles transactional consistency (reservations, billing, audit logs), a **polyglot persistence architecture** integrating NoSQL models addresses unstructured data growth and real-time read latency.

| Data Type / Subsystem | Database Model | Technology | Engineering Rationale |
| :--- | :--- | :--- | :--- |
| **Core Bookings & Payments** | Relational (RDBMS) | PostgreSQL | Enforces ACID guarantees, relational integrity, and financial consistency. |
| **Guest Preferences & Reviews** | Document Store | MongoDB / JSON | Schema-less structure accommodates variable guest perks, dietary preferences, and unstructured feedback. |
| **Room Availability Search Cache** | Key-Value Store | Redis | In-memory key-value lookups deliver sub-millisecond query responses for high-frequency room searches. |

---

## 2. Document Data Model (MongoDB / JSON)

### Why Document Modeling Fits Guest Profiles
In a traditional SQL database, storing evolving guest preferences (e.g., pillow choices, room temperature, dietary requests) requires numerous optional columns or complex lookup tables.

**Document Model Advantages:**
* **Flexible Schema:** Easily accommodates missing or newly introduced attributes without executing `ALTER TABLE` DDL migrations.
* **Embedded Hierarchies:** Embeds stay history, guest reviews, and loyalty rewards into a single self-contained JSON document, eliminating expensive multi-table `JOIN` operations.

---

## 3. Key-Value Caching Model (Redis)

### Caching Strategy for High-Frequency Search Operations
Peak booking periods generate thousands of read-only availability searches per minute. Querying PostgreSQL repeatedly degrades database performance.

**Cache Workflow:**
1. **Cache Read:** Application queries Redis using the key pattern `avail:{room_type}:{check_in}:{check_out}`.
2. **Cache Hit:** If present, returns JSON results in under 5ms.
3. **Cache Miss & Invalidation:** On a miss, the application queries PostgreSQL, writes the result to Redis with a 300-second TTL, and invalidates the cache whenever a new `INSERT INTO Bookings` transaction commits.

---

## 4. CAP Theorem & Consistency Analysis

| Property | Relational (PostgreSQL) | Document Store (MongoDB) | Key-Value Cache (Redis) |
| :--- | :--- | :--- | :--- |
| **CAP Classification** | **CA** (Consistency & Availability) | **CP** (Consistency & Partition Tolerance) | **AP / CP** (Configurable in-memory cache) |
| **Consistency Model** | Immediate / Strong Consistency | Strong Primary Read/Write | Eventual Consistency / Volatile Cache |
| **Failure Mode** | Rejects conflicting commits | Re-elects Primary node on partition | Falls back to RDBMS on cache miss |

---

## 5. Execution Instructions

1. **Verify JSON Document Schema:**
   Inspect `portfolio-4-nosql/documents.json` for structure validity.
2. **Run Redis Cache Simulation Script:**
   ```bash
   python portfolio-4-nosql/redis_cache.py

# Advanced Database Systems Portfolio (MIT 8103)
**Student Name:** Saidat Oluwatomisin Lawal

**Matriculation Number:** 2026/A/MIT/0425

**Student Number:** 301897659

**Degree Programme:** Master of Information Technology (MIT)  

**Institution:** School of Postgraduate Studies, Miva Open University  

**Academic Session:** 2026/2027 First Semester  

**Assessment Type:** Individual Practical Database Portfolio

**Case Study System:** Grand Horizon Hotel Management System  

**GitHub Repository URL:** https://github.com/TTL-mit/advance-database-design-/tree/main/portfolio-1-database-design  

---

## Executive Overview
This repository contains the complete progressive technical portfolio for **MIT 8103: Advanced Database Systems**. The portfolio applies advanced relational schema design, query performance optimization, pessimistic transaction locking, polyglot NoSQL data modeling, and distributed cloud architecture to a single enterprise case study: **The Grand Horizon Hotel Management System**.

---

## Repository Directory Structure

```text
advanced-database-portfolio/
├── portfolio-1-database-design/
│   ├── ER_Diagram.png
│   ├── schema.sql
│   └── README.md
├── portfolio-2-query-optimisation/
│   ├── seed.sql
│   ├── queries.sql
│   └── README.md
├── portfolio-3-transactions-concurrency/
│   ├── transactions.sql
│   └── README.md
├── portfolio-4-nosql/
│   ├── documents.json
│   ├── redis_cache.py
│   └── README.md
├── portfolio-5-distributed-cloud/
│   ├── replication_sharding.sql
│   └── README.md
└── README.md

---

'''Markdown

---

## 1. Selected Organisation & System Statement
* **Case Study Name:** Grand Horizon Hotel Management System
* **Nature of Business:** Multi-property luxury hotel chain managing physical room inventory, guest reservations, checkout audits, and payment processing.
* **System Users:** Front desk operators, hotel revenue managers, system administrators, and online self-service guests.
* **Core Data Domains:** Room categories, physical room states, guest profile registries, reservations, transaction payments, and staff audit logs.
* **Key Database Operations:** Real-time room availability lookup, atomic reservation processing, multi-table financial reporting, dynamic guest preference management, and sub-second availability caching.

---

## 2. Summary of Portfolio Technical Activities

### Activity 1: Database Design and Modelling 
* **Implementation:** Built a fully normalized (up to 3NF) relational database schema containing 6 core entities (`Room_Types`, `Rooms`, `Guests`, `Bookings`, `Payments`, and `Check_In_Out_Records`).
* **Integrity Constraints:** Applied `CHECK (check_out_date > check_in_date)` to prevent scheduling anomalies, `ON DELETE RESTRICT` on core master tables, and `ON DELETE CASCADE` on transaction child records.

### Activity 2: Query Processing and Optimisation
* **Implementation:** Formulated three complex operational SQL queries: (1) Date-range room availability search, (2) Grouped financial revenue analytics, and (3) Subquery-driven VIP guest identification.
* **Optimisation:** Analyzed query execution plans using PostgreSQL `EXPLAIN ANALYZE` [8]. Designed a Partial Composite Index (`idx_bookings_active_dates`) and a Composite Covering Index (`idx_payments_status_date`), achieving an estimated **~74% reduction in query execution scan costs**.

### Activity 3: Transactions and Concurrency Control
* **Implementation:** Engineered ACID-compliant transaction blocks (`BEGIN...COMMIT/ROLLBACK`).
* **Concurrency Control:** Resolved the overbooking anomaly by implementing pessimistic row-level locking (`SELECT ... FOR UPDATE`), forcing concurrent booking attempts into a wait state. Applied the `SERIALIZABLE` transaction isolation level for financial audit reconciliation.

### Activity 4: NoSQL and Advanced Data Models
* **Polyglot Persistence:** Integrated NoSQL models to complement PostgreSQL.
* **Document Store (MongoDB):** Modeled guest preference hierarchies, loyalty tiers, and stay history in JSON (`documents.json`), eliminating sparse columns.
* **Key-Value Cache (Redis):** Implemented a Python Redis simulation (`redis_cache.py`) with a 300-second Time-To-Live (TTL) to offload read traffic.

### Activity 5: Distributed and Cloud Database Exercise
* **Architecture:** Designed an AWS Aurora PostgreSQL Multi-AZ cloud deployment featuring Primary-Replica streaming WAL replication.
* **Sharding & CAP Evaluation:** Evaluated PACELC/CAP trade-offs, choosing **CP** for booking/payment writes and **AP** for read-only room search caching. Implemented regional horizontal sharding (`Bookings_Shard_NA` vs `Bookings_Shard_EU`) to minimize geographic latency.

---

## 3. Individual Technical Reflection

### Design Choices
Choosing PostgreSQL as the primary storage engine guaranteed ACID compliance for reservations and payment transactions. Integrating Redis and MongoDB introduced a polyglot approach that resolved RDBMS performance bottlenecks during peak search traffic without compromising transactional safety.

### Challenges Faced & Problem-Solving
1. **GitHub Render Error:** Encountered a Mermaid syntax parsing error on line 61 due to improper backtick placement (`---## 4. Normalisation Rationale`). Resolved by isolating closing backticks on their own line with standard spacing.
2. **Pessimistic Locking Deadlocks:** During concurrency tests, unindexed foreign key lookups caused table-level locks. Implementing composite indexing on active booking dates restored targeted row-level locking.

### Lessons Learned
Through this project, I gained practical insight into query plan node structures, the trade-offs between sequential and index scans, and how transaction isolation levels balance performance against data anomalies.

---

## 4. Academic Integrity & AI Use Declaration

* **AI Tool Used:** Gemini Notebook (Large Language Model Workbench).
* **Purpose of AI Use:** Assisted with query structure drafting, standardizing Markdown repository templates, organizing portfolio file hierarchies, and troubleshooting GitHub syntax errors.
* **Verification & Ownership Statement:** All SQL DDL schema structures, NoSQL JSON definitions, python cache scripts, and execution plan analyses were executed, tested, verified, and understood independently in my local pgAdmin PostgreSQL environment and Atlas MongeDB.

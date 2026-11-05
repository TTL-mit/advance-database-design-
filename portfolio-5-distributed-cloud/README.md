# Portfolio 5: Distributed & Cloud Database Systems

## 1. Executive Summary & Distributed Architecture Overview
As **Grand Horizon Hotel Group** expands globally, a single centralized database instance creates geographical read latency for international guests and presents a single point of failure (SPOF). This portfolio documents a **distributed, cloud-native database topology** built on **AWS Aurora PostgreSQL Multi-AZ**.

---

## 2. Primary-Replica Replication Architecture

                   ┌─────────────────────────┐
                   │   Application Load      │
                   │        Balancer         │
                   └────────────┬────────────┘
                                │
           ┌────────────────────┴────────────────────┐
           │ Writes (INSERT/UPDATE)                  │ Reads (SELECT)
           ▼                                         ▼
┌─────────────────────────────┐           ┌─────────────────────────────┐ │  Primary Node (Write-Only)  │           │ Read Replica 1 (Analytics)  │ │  Region: us-east-1          │           │ Region: us-east-1           │ └──────────────┬──────────────┘           └─────────────────────────────┘ │ Async WAL Streaming ▼ ┌─────────────────────────────┐ │ Read Replica 2 (EU Region)  │ │ Region: eu-west-1           │ └─────────────────────────────┘

### Architectural Responsibilities:
1. **Primary Node (Master):** Handles all write operations (`INSERT INTO Bookings`, `UPDATE Rooms SET status = 'Reserved'`, `INSERT INTO Payments`).
2. **Read Replicas (Standby Nodes):** Offload high-volume read queries (`SELECT` room search lookups and financial reporting queries from Portfolio 2).
3. **Failover Mechanism:** Automated multi-AZ failover converts a Read Replica into the Primary Node within 30 seconds if the main instance fails.

---

## 3. Horizontal Sharding Strategy

To prevent single-table bottlenecking as historical booking records grow into tens of millions of rows, data is **horizontally sharded by Property Region**:

* **Shard Key:** `property_region_id` (derived from `room_id` range).
* **Routing Logic:**
  * `Shard 1 (Americas):` `room_id` ranges `1000–1999`.
  * `Shard 2 (EMEA):` `room_id` ranges `2000–2999`.
* **Benefits:** Localizes regional queries to nearby data centers, cutting latency for guest check-ins while isolating regional hardware failures.

---

## 4. PACELC & CAP Theorem Analysis

| Parameter | Application Strategy | Operational Trade-off |
| :--- | :--- | :--- |
| **CAP Theorem** | **CP (Consistency / Partition Tolerance)** for Bookings & Payments | During a network partition, payment and booking writes are rejected rather than risking inconsistent double-bookings. |
| **CAP Theorem** | **AP (Availability / Partition Tolerance)** for Search & Cache | Room search browsing uses asynchronous read replicas (eventually consistent data) to guarantee 99.999% uptime. |
| **PACELC Theorem** | **If Partitioned (P):** Choose Consistency (**C**) over Availability (**A**).<br>**Else (E):** Choose Latency (**L**) over Consistency (**C**) for read operations. | Balance absolute financial correctness with sub-second browsing speeds. |

---

## 5. Cloud Deployment & Disaster Recovery

* **Database Engine:** AWS Aurora PostgreSQL Serverless v2.
* **Backup & Recovery:** Continuous automated point-in-time recovery (PITR) with 5-minute RPO (Recovery Point Objective) and sub-15-minute RTO (Recovery Time Objective).
* **Security & Compliance:** Encryption at rest using AWS KMS (AES-256) and SSL/TLS transport layer security for PCI-DSS payment compliance.

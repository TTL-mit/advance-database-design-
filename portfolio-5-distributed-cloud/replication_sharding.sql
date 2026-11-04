
-- ============================================================================
-- PORTFOLIO 5: DISTRIBUTED & CLOUD DATABASE EXERCISE
-- Case Study: Grand Horizon Hotel Management System
-- Engine: PostgreSQL (Distributed Architecture / AWS Aurora Multi-AZ)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. PRIMARY-REPLICA STREAMING REPLICATION CONFIGURATION (CONCEPTUAL DDL)
-- Separation of Write Traffic (Primary Node) and Read Analytics (Replica Nodes)
-- ----------------------------------------------------------------------------

-- Enable Write-Ahead Logging (WAL) level for physical/logical replication
-- (Set in postgresql.conf on Primary Node)
-- wal_level = replica
-- max_wal_senders = 5
-- hot_standby = on

-- Create a dedicated replication user with minimal permissions
CREATE USER rep_user WITH REPLICATION ENCRYPTED PASSWORD 'SecureReplicaPass2026!';

-- Create a physical replication slot for Node 2 (Read Replica 1)
SELECT pg_create_physical_replication_slot('standby_node_1_slot');


-- ----------------------------------------------------------------------------
-- 2. HORIZONTAL DATABASE SHARDING (BY GEOGRAPHIC REGION / HOTEL LOCATION)
-- Sharding strategy: Distribute guest bookings across distinct regional nodes
-- Node A (Shard 1): North America Region (region_id = 1)
-- Node B (Shard 2): Europe & Middle East Region (region_id = 2)
-- ----------------------------------------------------------------------------

-- Create Regional Shard Table for North American Property Bookings
CREATE TABLE Bookings_Shard_NA (
    CONSTRAINT chk_region_na CHECK (room_id BETWEEN 1000 AND 1999)
) INHERITS (Bookings);

-- Create Regional Shard Table for Europe/Middle East Property Bookings
CREATE TABLE Bookings_Shard_EU (
    CONSTRAINT chk_region_eu CHECK (room_id BETWEEN 2000 AND 2999)
) INHERITS (Bookings);


-- ----------------------------------------------------------------------------
-- 3. DISTRIBUTED HEALTH & REPLICATION LAG MONITORING QUERY
-- Query run on Replica nodes to verify latency behind Primary
-- ----------------------------------------------------------------------------
SELECT 
    client_addr AS replica_ip,
    application_name,
    state,
    sync_state,
    pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn) AS replication_lag_bytes,
    ROUND(EXTRACT(EPOCH FROM (now() - reply_time))::numeric, 2) AS lag_seconds
FROM pg_stat_replication;

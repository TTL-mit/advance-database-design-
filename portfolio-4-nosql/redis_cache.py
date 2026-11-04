"""
Portfolio 4: NoSQL Key-Value Cache Implementation (Redis)
Case Study: Grand Horizon Hotel Management System
"""

import json
import time

# Simulated Redis In-Memory Key-Value Store
redis_store = {}

def set_room_availability_cache(room_type: str, check_in: str, check_out: str, available_rooms: list, ttl_seconds: int = 300):
    """Caches room search query results with Time-To-Live (TTL)."""
    cache_key = f"avail:{room_type}:{check_in}:{check_out}"
    payload = {
        "cached_at": time.time(),
        "ttl": ttl_seconds,
        "data": available_rooms
    }
    redis_store[cache_key] = json.dumps(payload)
    print(f"[CACHE SET] Key: {cache_key} | TTL: {ttl_seconds}s")

def get_room_availability_cache(room_type: str, check_in: str, check_out: str):
    """Retrieves cached availability results to bypass RDBMS query overhead."""
    cache_key = f"avail:{room_type}:{check_in}:{check_out}"
    if cache_key in redis_store:
        payload = json.loads(redis_store[cache_key])
        print(f"[CACHE HIT] Serving from Redis Cache for key: {cache_key}")
        return payload["data"]
    print(f"[CACHE MISS] Executing PostgreSQL database query...")
    return None

# --- Demonstration Execution ---
if __name__ == "__main__":
    # Simulate first user request (Cache Miss -> Queries PostgreSQL -> Populates Cache)
    search_results = [
        {"room_id": 9, "room_number": "301", "price": 350.00},
        {"room_id": 11, "room_number": "303", "price": 350.00}
    ]
    
    print("--- User Search Request 1 ---")
    result = get_room_availability_cache("Deluxe Suite", "2026-12-20", "2026-12-28")
    if not result:
        set_room_availability_cache("Deluxe Suite", "2026-12-20", "2026-12-28", search_results)
    
    print("\n--- User Search Request 2 (Identical Search) ---")
    cached_data = get_room_availability_cache("Deluxe Suite", "2026-12-20", "2026-12-28")
    print(f"Returned Data: {cached_data}")

import sqlite3

drone_db_file = "database.sqlite"

print(f"Creating Drone database: {drone_db_file}")

try:
    sqlite3.connect(f"{drone_db_file}")
    
except e as exc:
    print(f"Exception: {e}")

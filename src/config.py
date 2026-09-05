import os
from dotenv import load_dotenv

load_dotenv()

REQUIRED = ["PGHOST", "PGPORT", "PGDATABASE", "PGUSER", "PGPASSWORD"]

def get_conn_params():
    missing = []

    for name in REQUIRED:
        value = os.getenv(name)
        if not value:
            missing.append(name)      # collect

    if missing:                        # then check, once
        raise RuntimeError(f"Missing required environment variables: {', '.join(missing)}")

    return {
        "host": os.getenv("PGHOST"),
        "port": os.getenv("PGPORT"),
        "dbname": os.getenv("PGDATABASE"),
        "user": os.getenv("PGUSER"),
        "password": os.getenv("PGPASSWORD")
    }
import psycopg
from config import get_conn_params

params = get_conn_params()

with psycopg.connect(**params) as conn:
    with conn.cursor() as cur:
        cur.execute("SELECT version(), current_database(), current_user;")
        print(cur.fetchone())
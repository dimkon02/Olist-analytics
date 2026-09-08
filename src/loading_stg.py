import psycopg
from config import get_conn_params
from pathlib import Path

DATA_DIR = Path(__file__).resolve().parent.parent / "data"

TABLES = {
    "stg_orders":               "olist_orders_dataset.csv",
    "stg_customers":            "olist_customers_dataset.csv",
    "stg_order_items":          "olist_order_items_dataset.csv",
    "stg_order_payments":       "olist_order_payments_dataset.csv",
    "stg_order_reviews":        "olist_order_reviews_dataset.csv",
    "stg_products":             "olist_products_dataset.csv",
    "stg_sellers":              "olist_sellers_dataset.csv",
    "stg_geolocation":          "olist_geolocation_dataset.csv",
    "stg_category_translation": "product_category_name_translation.csv",
}

params = get_conn_params()


with psycopg.connect(**params) as conn:
    with conn.cursor() as cur:
        for table, filename in TABLES.items():
            cur.execute(f"TRUNCATE {table};")

            with cur.copy(f"COPY {table} FROM STDIN WITH (FORMAT csv, HEADER true)") as copy:
                with open(DATA_DIR / filename, "rb") as f:
                    while chunk := f.read(8192):
                        copy.write(chunk)

            cur.execute(f"SELECT COUNT(*) FROM {table};")
            print(f"{table}: {cur.fetchone()[0]:,}")
# Olist Analytics

An end-to-end SQL analytics project on the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce): 9 raw CSVs are profiled in pandas, loaded into PostgreSQL as text-only staging tables, transformed into constrained relational tables, and then queried for a variety of purposes such as revenue, geography, categories, payments, customer cohorts, and delivery time vs review score.

This project isn't simply SQL queries. Every modelling decision (what the primary key should be, whether a table should be dropped or not) is documented in [`notes.md`](notes.md), and all the analysis of the SQL queries can be found in [`analysing_queries.md`](analysing_queries.md). Finally, in the folder named [`graphs`](graphs) there is a variety of visual representations of the query results.

## Stack

- **PostgreSQL 18** 
- **Python 3.14** — the pipeline scripts
  - **pandas 3.0.5** — profiling the raw CSVs in the exploration phase
  - **psycopg 3.3.5** — database driver, used for the `COPY` load and the upserts
  - **python-dotenv 1.2.3** — keeps credentials in `.env` and out of the code
- Plain `.sql` files for the schema and the analysis.

## Repository layout

```
src/
  config.py                  Reads Postgres credentials from .env, fails loudly if any are missing
  check_connection.py        Smoke test: prints server version, database, user
  explore_orders.py          Phase 1 — profiling of the orders CSV
  explore_relationships.py   Phase 2 — row counts, distinct counts, nulls, PK/FK discovery across all 9 CSVs
  loading_stg.py             Truncates and COPYs every CSV into its stg_table
  transform.py               Staging -> modelled tables, idempotent (ON CONFLICT upserts)

sql/
  01_staging.sql             stg_tables, every column TEXT (staging mirrors the source, warts included)
  02_schema.sql              Modelled tables with PKs, FKs and CHECK constraints
  schema_exploration.sql     Per-column type investigation that justifies each type in 02_schema.sql
  transform.sql              The SQL from transform.py, kept readable as standalone statements
  test_for_pipeline.sql      Post-load row-count checks

queries/                     The 10 analysis queries, numbered in the order they were written
graphs/                      Charts exported from the query results
notes.md                     Data profiling findings, the ER diagram, and every modelling decision
analysing_queries.md         Findings per query, plus the EXPLAIN before/after for the index work
```
## Setup

**1. Database and credentials**

```bash
createdb olist_data
cp .env.example .env     # then fill in PGPASSWORD
```

`.env` holds `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`. It is gitignored.

**2. Python environment**

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

**3. Data**

Download the dataset from Kaggle and unzip the nine CSVs into `data/` at the repo root (gitignored — the CSVs are not committed):

```
data/
  olist_customers_dataset.csv
  olist_orders_dataset.csv
  olist_order_items_dataset.csv
  olist_order_payments_dataset.csv
  olist_order_reviews_dataset.csv
  olist_products_dataset.csv
  olist_sellers_dataset.csv
  olist_geolocation_dataset.csv
  product_category_name_translation.csv
```

## Running the pipeline

```bash
cd src
python check_connection.py          # verify the connection first

psql -d olist_data -f ../sql/01_staging.sql    # create stg_ tables
python loading_stg.py                          # COPY the CSVs in, prints row counts

psql -d olist_data -f ../sql/02_schema.sql     # create the modelled tables
python transform.py                            # staging -> model, prints rows affected
```
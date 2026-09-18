SELECT * FROM customers;
-- customer_id, customer_unique_id

SELECT * FROM orders;
-- customer_id, purchase_timestamp, order_id


WITH first_order AS (
    SELECT c.customer_unique_id,
           date_trunc('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY c.customer_unique_id
),
orders_by_month AS (
    SELECT c.customer_unique_id,
           date_trunc('month', o.order_purchase_timestamp) AS order_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
),
cohort_orders AS (
    SELECT f.cohort_month,
           o.order_month,
           o.customer_unique_id,
           EXTRACT(YEAR FROM age(o.order_month, f.cohort_month)) * 12
  + EXTRACT(MONTH FROM age(o.order_month, f.cohort_month))
    AS months_since_first
    FROM first_order f
    JOIN orders_by_month o ON f.customer_unique_id = o.customer_unique_id
),
cohort_counts AS (
    SELECT cohort_month,
           months_since_first,
           COUNT(DISTINCT customer_unique_id) AS customers
    FROM cohort_orders
    GROUP BY cohort_month, months_since_first
)
SELECT cohort_month,
       months_since_first,
       customers,
       MAX(customers) OVER (PARTITION BY cohort_month) AS cohort_size,
       ROUND(100.0 * customers / MAX(customers) OVER (PARTITION BY cohort_month), 2) AS pct_retained
FROM cohort_counts
ORDER BY cohort_month, months_since_first;
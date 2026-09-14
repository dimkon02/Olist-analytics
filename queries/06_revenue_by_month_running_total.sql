WITH monthly AS (
    SELECT date_trunc('month', o.order_purchase_timestamp) AS month,
           SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
  	AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY month
)
SELECT to_char(month, 'YYYY-MM') AS month,
       revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;
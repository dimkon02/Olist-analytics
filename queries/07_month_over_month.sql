WITH monthly AS (
    SELECT date_trunc('month', o.order_purchase_timestamp) AS month,
           SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_purchase_timestamp >= '2017-01-01'
  	AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY month
),
with_prev AS (
	SELECT month,
	       revenue,
	       LAG(revenue) OVER (ORDER BY month) AS prev_revenue
	FROM monthly
)
SELECT to_char(month, 'YYYY-MM') AS month,
       revenue,
       prev_revenue,
       revenue - prev_revenue AS absolute_change,
       ROUND(100.0 * (revenue - prev_revenue) / prev_revenue, 1) AS percentage_change
FROM with_prev
ORDER BY month;
SELECT c.customer_state AS state,
       SUM(oi.price) AS revenue,
       COUNT(DISTINCT o.order_id) AS number_of_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY c.customer_state
ORDER BY revenue DESC;
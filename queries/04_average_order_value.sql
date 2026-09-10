SELECT * FROM order_items;

SELECT * FROM orders;

WITH order_totals AS (
	SELECT o.order_id, SUM(oi.price) AS order_total, o.order_status
	FROM orders o
	JOIN order_items oi ON o.order_id = oi.order_id
	WHERE o.order_purchase_timestamp >= '2017-01-01'
  	AND o.order_purchase_timestamp < '2018-09-01'
	GROUP BY o.order_id
)
SELECT AVG(order_total),
	   order_status,
	   COUNT(*)
FROM order_totals
GROUP BY order_status
ORDER BY AVG(order_total) DESC;

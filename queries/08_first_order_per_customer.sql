SELECT * FROM customers;
-- We need : customer_unique_id
-- customer_id for JOIN

SELECT * FROM orders;
-- We need : prder_purchase_timestamp
-- customer_id for JOIN
-- order_id for JOIN

SELECT * FROM order_items;
-- We need : price 
-- order_id for JOIN

with order_totals AS (
	SELECT c.customer_unique_id,
		   o.order_purchase_timestamp,
		   o.order_id,
		   SUM(oi.price) AS order_total
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_items oi ON o.order_id = oi.order_id
	WHERE o.order_purchase_timestamp >= '2017-01-01'
  	AND o.order_purchase_timestamp < '2018-09-01'
	GROUP BY o.order_id, o.order_purchase_timestamp,c.customer_unique_id  
),
with_ranked_orders AS (
	SELECT customer_unique_id,
		   order_purchase_timestamp,
		   order_id,
		   order_total,
		   ROW_NUMBER() OVER (
				PARTITION BY customer_unique_id
				ORDER BY order_purchase_timestamp
		   ) AS rn
	FROM order_totals
) 
SELECT customer_unique_id,
       order_purchase_timestamp,
       order_id,
       order_total
FROM with_ranked_orders
WHERE rn = 1
ORDER BY order_purchase_timestamp;
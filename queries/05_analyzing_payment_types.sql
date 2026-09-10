SELECT * FROM order_payments;

SELECT * FROM orders;

SELECT COUNT(*) FROM order_payments;

SELECT payment_type,
	   COUNT(*) AS payments,
	   AVG(payment_value) AS avg_value,
	   SUM(payment_value) AS total_value,
	   AVG(payment_installments) AS avg_installments
FROM order_payments op
JOIN orders o ON o.order_id = op.order_id
WHERE o.order_purchase_timestamp >= '2017-01-01'
AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY payment_type
ORDER BY total_value DESC;
SELECT * FROM orders;


SELECT * FROM order_reviews;


-- we will use order_id to JOINN the tables
-- we will calculate the difference between order_estimated_delivery_date and order_delivered_customer_date
-- we will group by delay

with delivery AS(
	SELECT o.order_id,
		   r.review_score,
		   o.order_delivered_customer_date::DATE - o.order_estimated_delivery_date AS delay_days
	FROM orders o 
	JOIN order_reviews r ON o.order_id = r.order_id
	WHERE o.order_delivered_customer_date IS NOT NULL AND
		  o.order_purchase_timestamp >= '2017-01-01'
      	  AND o.order_purchase_timestamp < '2018-09-01'
)
SELECT CASE WHEN delay_days < 0 THEN 'Early'
            WHEN delay_days = 0 THEN 'On time'
            WHEN delay_days <= 5 THEN 'Late(1-5 days)'
            ELSE 'Very Late (5+ days)'
       END AS delivery_status,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_score,
       COUNT(*) FILTER (WHERE review_score <= 2) AS bad_reviews
FROM delivery
GROUP BY 1
ORDER BY MIN(delay_days);
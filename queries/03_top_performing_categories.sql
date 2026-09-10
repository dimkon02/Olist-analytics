SELECT * FROM products;
-- product_id and product_gategory name

SELECT * FROM categories_translations;
-- product_category_name_english

SELECT * FROM order_items;
-- product_id   and price

SELECT COALESCE(ct.product_category_name_english, 'unknown') AS category,
       SUM(oi.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
LEFT JOIN categories_translations ct ON p.product_category_name = ct.product_category_name
WHERE o.order_purchase_timestamp >= '2017-01-01'
AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY COALESCE(ct.product_category_name_english, 'unknown')
ORDER BY revenue DESC;
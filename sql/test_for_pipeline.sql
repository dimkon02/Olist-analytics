SELECT COUNT (*) FROM customers;


SELECT * FROM stg_category_translation;

SELECT review_creation_date FROM order_reviews
WHERE order_id = '0035246a40f520710769010f752e7507';

SELECT 'customers' AS t, COUNT(*) FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'categories', COUNT(*) FROM categories_translations
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews;
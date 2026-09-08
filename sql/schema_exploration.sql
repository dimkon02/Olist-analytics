						-- FOR CUSTOMERS TABLE
SELECT MIN(LENGTH(customer_id)), MAX(LENGTH(customer_id)) FROM stg_customers;
SELECT customer_id FROM stg_customers LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so customer_id cant be int
-- customer_id wil be CHAR(32)

SELECT MIN(LENGTH(customer_unique_id)), MAX(LENGTH(customer_unique_id)) FROM stg_customers; 
SELECT customer_unique_id FROM stg_customers LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so customer_unique_id cant be int
-- customer_unique_id wil be CHAR(32)

SELECT MIN(LENGTH(customer_zip_code_prefix)), MAX(LENGTH(customer_zip_code_prefix)) FROM stg_customers;
SELECT customer_zip_code_prefix FROM stg_customers LIMIT 10;
-- RETURNS MIN, MAX 5, some values start with 0, so customer_zip_code_prefix cant be int
-- customer_zip_code_prefix wil be CHAR(5)

SELECT COUNT(DISTINCT customer_city) FROM stg_customers;
SELECT customer_city FROM stg_customers LIMIT 10;
-- RETURNS 4119 all cities are text
-- customer_city will be text

SELECT DISTINCT(customer_state) FROM stg_customers;
-- RETURNS 27, 2 CHAR EACH
-- customer_state will be CHAR(2)



						-- FOR ORDERS
SELECT MIN(LENGTH(order_id)), MAX(LENGTH(order_id)) FROM stg_orders;
SELECT order_id FROM stg_orders LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so order_id cant be int
-- order_id wil be CHAR(32)

SELECT MIN(LENGTH(customer_id)), MAX(LENGTH(customer_id)) FROM stg_orders;
SELECT customer_id FROM stg_orders LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so customer_id cant be int
-- customer_id wil be CHAR(32)

SELECT MIN(LENGTH(order_status)), MAX(LENGTH(order_status)) FROM stg_orders;
-- RETURNS MIN 7, MAX 12
-- order_status will be TEXT

SELECT order_purchase_timestamp FROM stg_orders;
-- order_purchase_timestamp will be TIMESTAMP

SELECT
  COUNT(*) FILTER (WHERE order_approved_at = '')            AS approved_empty,
  COUNT(*) FILTER (WHERE order_approved_at IS NULL)         AS approved_null,
  COUNT(*) FILTER (WHERE order_delivered_carrier_date = '') AS carrier_empty,
  COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS carrier_null,
  COUNT(*) FILTER (WHERE order_delivered_customer_date = '')   AS customer_empty,
  COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS customer_null
FROM stg_orders;

SELECT order_approved_at FROM stg_orders;
SELECT order_delivered_carrier_date FROM stg_orders;
SELECT order_delivered_customer_date FROM stg_orders;
-- all variables came back as null not empty.
-- all of them will be timestamp, and will permit null

SELECT
  COUNT(*) FILTER (WHERE order_purchase_timestamp !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') AS bad_purchase,
  COUNT(*) FILTER (WHERE order_approved_at !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') AS bad_approved,
  COUNT(*) FILTER (WHERE order_delivered_carrier_date !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') AS bad_carrier,
  COUNT(*) FILTER (WHERE order_delivered_customer_date !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') AS bad_customer
FROM stg_orders;
-- check that all date columns are the appropriate format to be timestamp

SELECT order_estimated_delivery_date FROM stg_orders;
SELECT COUNT(*) FROM stg_orders
WHERE order_estimated_delivery_date NOT LIKE '% 00:00:00';
-- order_estimated_delivery_date will be DATE, all delivery date show midnight



						-- FOR ITEMS 
SELECT MIN(LENGTH(order_id)), MAX(LENGTH(order_id)) FROM stg_order_items;
SELECT order_id FROM stg_order_items LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so order_id cant be int
-- order_id wil be CHAR(32)

SELECT MIN(LENGTH(order_item_id)), MAX(LENGTH(order_item_id)) FROM stg_order_items;
SELECT DISTINCT(order_item_id) FROM stg_order_items LIMIT 10;
-- RETURNS MIN 1 ,MAX 2, some 
-- order_id wil be INTEGER

SELECT MIN(LENGTH(product_id)), MAX(LENGTH(product_id)) FROM stg_order_items;
SELECT DISTINCT(product_id) FROM stg_order_items LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so product_id cant be int
-- product_id wil be CHAR(32)

SELECT MIN(LENGTH(seller_id)), MAX(LENGTH(seller_id)) FROM stg_order_items;
SELECT DISTINCT(seller_id) FROM stg_order_items LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so seller_id cant be int
-- seller_id wil be CHAR(32)

SELECT
  COUNT(*) FILTER (WHERE shipping_limit_date !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') AS bad_shipping
FROM stg_order_items;
-- shipping_limit_date will be TIMESTAMP

SELECT MIN(price::NUMERIC), MAX(price::NUMERIC),
       MIN(freight_value::NUMERIC), MAX(freight_value::NUMERIC)
FROM stg_order_items;

SELECT MIN(LENGTH(price)), MAX(LENGTH(price)) FROM stg_order_items;
SELECT DISTINCT(price) FROM stg_order_items LIMIT 10;
-- price will be numeric MIN : 0.85 MAX : 6735.00

SELECT MIN(LENGTH(freight_value)), MAX(LENGTH(freight_value)) FROM stg_order_items;
SELECT DISTINCT(freight_value) FROM stg_order_items LIMIT 10;
-- freight_value will be numeric MIN : 0.00 MAX : 409.68




						-- FOR PAYMENTS
SELECT MIN(LENGTH(order_id)), MAX(LENGTH(order_id)) FROM stg_order_payments;
SELECT order_id FROM stg_order_payments LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so order_id cant be int
-- order_id wil be CHAR(32)

SELECT MIN(payment_sequential::NUMERIC), MAX(payment_sequential::NUMERIC) FROM stg_order_payments;
-- payment_sequential will be INTEGER
-- MIN 1 MAX 29

SELECT DISTINCT(payment_type) FROM stg_order_payments;
--payment_type will be text
-- 5 values (boleto, debit_card, voucher, credit_card and not_defined) the last we eill convert to null

SELECT MIN(payment_installments::NUMERIC), MAX(payment_installments::NUMERIC) FROM stg_order_payments;
-- MIN 0, MAX 24 
-- INTEGER

SELECT payment_installments, COUNT(*), SUM(payment_value::NUMERIC)
FROM stg_order_payments
GROUP BY payment_installments
ORDER BY SUM(payment_value::NUMERIC) DESC;
-- there are two payments with 0 payment_instalments with a total value of 188.63

SELECT MIN(payment_value::NUMERIC), MAX(payment_value::NUMERIC)
FROM stg_order_payments;
-- MIN 0, MAX 13664.08
-- payment_value will be numeric

SELECT DISTINCT payment_type FROM stg_order_payments;
-- payment_type will be text

SELECT payment_type, COUNT(*), SUM(payment_value::NUMERIC)
FROM stg_order_payments
GROUP BY payment_type
ORDER BY SUM(payment_value::NUMERIC) DESC;
-- there are 3 payment types with `not_defined` payment_type and total payment_value of 0

SELECT payment_type, payment_installments::INTEGER AS installments, COUNT(*)
FROM stg_order_payments
GROUP BY payment_type, installments
ORDER BY payment_type, installments;
-- the two payments with 0 payment_installments were done with credit card



				-- FOR REVIEWS
SELECT MIN(LENGTH(review_id)), MAX((LENGTH(review_id))) FROM stg_order_reviews;
SELECT review_id FROM stg_order_reviews LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so review_id cant be int
-- order_id wil be CHAR(32)


SELECT MIN(LENGTH(order_id)), MAX((LENGTH(order_id))) FROM stg_order_reviews;
SELECT order_id FROM stg_order_reviews LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so order_id cant be int
-- order_id wil be CHAR(32)


SELECT DISTINCT(review_score) FROM stg_order_reviews;
-- 1 through 5, will use INTEGER


SELECT review_creation_date FROM stg_order_reviews
-- a lot seem to have only midnight time, need to investigate

SELECT review_creation_date FROM stg_order_reviews;
SELECT COUNT(*) FROM stg_order_reviews
WHERE review_creation_date NOT LIKE '% 00:00:00';
-- 85 dont have midnight time, need to investigate 

SELECT review_creation_date FROM stg_order_reviews
WHERE review_creation_date NOT LIKE '% 00:00:00' LIMIT 10;

SELECT review_creation_date FROM stg_order_reviews;
SELECT COUNT(*) FROM stg_order_reviews
WHERE review_creation_date  LIKE '% 01:00:00';
-- the 85 that dont have 00:00:00 have 01:00:00
-- we will use DATE

SELECT review_answer_timestamp FROM stg_order_reviews;

SELECT
  COUNT(*) FILTER (WHERE review_creation_date !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') AS bad_review_creation,
  COUNT(*) FILTER (WHERE review_answer_timestamp !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$') AS bad_answer_timestamp
FROM stg_order_reviews;
-- All follow corect format
-- review_creation_date will use DATE
-- review_answer_timestamp will use TIMESTAMP

SELECT review_comment_title FROM stg_order_reviews;
-- text but 87656 null

SELECT review_comment_message FROM stg_order_reviews;
-- text but has 58247 null the max length of message is 208

SELECT COUNT(*) FILTER (WHERE review_comment_title IS NULL) AS title_null,
       COUNT(*) FILTER (WHERE review_comment_message IS NULL) AS msg_null,
       MAX(LENGTH(review_comment_message)) AS max_msg_len
FROM stg_order_reviews;

			-- FOR PRODUCTS
SELECT MIN(LENGTH(product_id)), MAX((LENGTH(product_id))) FROM stg_products;
SELECT product_id FROM stg_products LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so order_id cant be int
-- product_id wil be CHAR(32)



			-- FOR SELLERS
SELECT MIN(LENGTH(seller_id)), MAX((LENGTH(seller_id))) FROM stg_sellers;
SELECT seller_id FROM stg_sellers LIMIT 10;
-- RETURNS MIN,MAX 32, some values start with 0 and contain letters, so order_id cant be int
-- product_id wil be CHAR(32)

SELECT MIN(LENGTH(seller_zip_code_prefix)), MAX((LENGTH(seller_zip_code_prefix))) FROM stg_sellers;
-- CHAR(5)

SELECT MIN(LENGTH(seller_city)), MAX((LENGTH(seller_city))) FROM stg_sellers;
-- MIN: 2, MAX: 40
-- text

SELECT MIN(LENGTH(seller_state)), MAX((LENGTH(seller_state))) FROM stg_sellers;
-- MIN: 2, MAX: 2
-- CHAR
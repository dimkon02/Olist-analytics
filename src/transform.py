import psycopg
from config import get_conn_params

INSERT_CUSTOMERS = """
    INSERT INTO customers (customer_id, customer_unique_id, customer_zip_code_prefix, 
                        customer_city, customer_state)

    SELECT customer_id, customer_unique_id, customer_zip_code_prefix,
        customer_city, customer_state
    FROM stg_customers
    ON CONFLICT (customer_id) DO UPDATE
    SET customer_unique_id = EXCLUDED.customer_unique_id,
        customer_zip_code_prefix = EXCLUDED.customer_zip_code_prefix,
        customer_city = EXCLUDED.customer_city,
        customer_state = EXCLUDED.customer_state;
"""

INSERT_SELLERS = """
    INSERT INTO sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)

    SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state
    FROM stg_sellers
    ON CONFLICT (seller_id) DO UPDATE
    SET seller_zip_code_prefix = EXCLUDED.seller_zip_code_prefix,
        seller_city = EXCLUDED.seller_city,
        seller_state = EXCLUDED.seller_state;
"""

INSERT_CATEGORIES = """
    INSERT INTO categories_translations (product_category_name, product_category_name_english)
    SELECT product_category_name, product_category_name_english
    FROM stg_category_translation
    UNION ALL
    SELECT 'pc_gamer', 'pc_gamer'
    UNION ALL
    SELECT 'portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_portables_and_food_preparers'
    ON CONFLICT (product_category_name) DO UPDATE
    SET product_category_name_english = EXCLUDED.product_category_name_english;
"""

INSERT_PRODUCTS = """
    INSERT INTO products (product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
    SELECT product_id,
        product_category_name,
        product_name_lenght::INTEGER,
        product_description_lenght::INTEGER,
        product_photos_qty::INTEGER,
        product_weight_g::INTEGER,
        product_length_cm::INTEGER,
        product_height_cm::INTEGER,
        product_width_cm::INTEGER
    FROM stg_products
    ON CONFLICT (product_id) DO UPDATE
    SET product_category_name = EXCLUDED.product_category_name,
        product_name_lenght = EXCLUDED.product_name_lenght,
        product_description_lenght = EXCLUDED.product_description_lenght,
        product_photos_qty = EXCLUDED.product_photos_qty,
        product_weight_g = EXCLUDED.product_weight_g,
        product_length_cm = EXCLUDED.product_length_cm,
        product_height_cm = EXCLUDED.product_height_cm,
        product_width_cm = EXCLUDED.product_width_cm;
"""

INSERT_ORDERS = """
    INSERT INTO orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
    SELECT order_id,
        customer_id,
        order_status,
        order_purchase_timestamp::TIMESTAMP,
        order_approved_at::TIMESTAMP,
        order_delivered_carrier_date::TIMESTAMP,
        order_delivered_customer_date::TIMESTAMP,
        order_estimated_delivery_date::DATE
    FROM stg_orders
    ON CONFLICT (order_id) DO UPDATE
    SET customer_id = EXCLUDED.customer_id,
        order_status = EXCLUDED.order_status,
        order_purchase_timestamp = EXCLUDED.order_purchase_timestamp,
        order_approved_at = EXCLUDED.order_approved_at,
        order_delivered_carrier_date = EXCLUDED.order_delivered_carrier_date,
        order_delivered_customer_date = EXCLUDED.order_delivered_customer_date,
        order_estimated_delivery_date = EXCLUDED.order_estimated_delivery_date;
"""

INSERT_ORDER_ITEMS = """
    INSERT INTO order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
    SELECT order_id,
        order_item_id::INTEGER,
        product_id,
        seller_id,
        shipping_limit_date::TIMESTAMP,
        price::NUMERIC(10,2),
        freight_value::NUMERIC(10,2)
    FROM stg_order_items
    ON CONFLICT (order_id, order_item_id) DO UPDATE
    SET product_id = EXCLUDED.product_id,
        seller_id = EXCLUDED.seller_id,
        shipping_limit_date = EXCLUDED.shipping_limit_date,
        price = EXCLUDED.price,
        freight_value = EXCLUDED.freight_value;
"""

INSERT_ORDER_PAYMENTS = """
    INSERT INTO order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
    SELECT order_id,
        payment_sequential::INTEGER,
        NULLIF(payment_type, 'not_defined'),
        payment_installments::INTEGER,
        payment_value::NUMERIC(10,2)
    FROM stg_order_payments
    ON CONFLICT (order_id, payment_sequential) DO UPDATE
    SET  payment_type = EXCLUDED.payment_type,
        payment_installments = EXCLUDED.payment_installments,
        payment_value = EXCLUDED.payment_value;
"""

INSERT_ORDER_REVIEWS = """
    WITH ranked AS (
        SELECT order_id,
            review_id,
            review_score::INTEGER AS review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date::TIMESTAMP AS review_creation_date,
            review_answer_timestamp::TIMESTAMP AS review_answer_timestamp,
            ROW_NUMBER() OVER (
                PARTITION BY order_id
                ORDER BY review_creation_date DESC, review_answer_timestamp DESC
            ) AS rn
        FROM stg_order_reviews
    )
    INSERT INTO order_reviews (order_id, review_id, review_score, review_comment_title,
                            review_comment_message, review_creation_date, review_answer_timestamp)
    SELECT order_id, review_id, review_score, review_comment_title,
        review_comment_message, review_creation_date, review_answer_timestamp
    FROM ranked
    WHERE rn = 1
    ON CONFLICT (order_id) DO UPDATE
    SET review_id= EXCLUDED.review_id,
        review_score= EXCLUDED.review_score,
        review_comment_title= EXCLUDED.review_comment_title,
        review_comment_message= EXCLUDED.review_comment_message,
        review_creation_date= EXCLUDED.review_creation_date,
        review_answer_timestamp= EXCLUDED.review_answer_timestamp;
"""


STATEMENTS = [
    ("customers", INSERT_CUSTOMERS),
    ("sellers", INSERT_SELLERS),
    ("categories_translations", INSERT_CATEGORIES),
    ("products", INSERT_PRODUCTS),
    ("orders", INSERT_ORDERS),
    ("order_items", INSERT_ORDER_ITEMS),
    ("order_payments", INSERT_ORDER_PAYMENTS),
    ("order_reviews", INSERT_ORDER_REVIEWS),
]

with psycopg.connect(**get_conn_params()) as conn:
    with conn.cursor() as cur:
        for name, sql in STATEMENTS:
            cur.execute(sql)
            print(f"{name}: {cur.rowcount:,}")
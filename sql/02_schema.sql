DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id CHAR(32) PRIMARY KEY,
    customer_unique_id CHAR(32) NOT NULL,
    customer_zip_code_prefix CHAR(5) NOT NULL,
    customer_city TEXT NOT NULL,
    customer_state CHAR(2) NOT NULL
);

DROP TABLE IF EXISTS orders CASCADE;

CREATE TABLE orders (
    order_id CHAR(32) PRIMARY KEY ,
    customer_id CHAR(32) NOT NULL UNIQUE REFERENCES customers(customer_id),
    order_status TEXT NOT NULL CHECK (order_status IN (
        'shipped', 'unavailable', 'invoiced', 'created', 'approved', 
        'processing', 'delivered', 'canceled'
    )),
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date DATE NOT NULL
);

DROP TABLE IF EXISTS sellers CASCADE;

CREATE TABLE sellers (
    seller_id CHAR(32) PRIMARY KEY,
    seller_zip_code_prefix CHAR(5) NOT NULL,
    seller_city TEXT NOT NULL,
    seller_state CHAR(2) NOT NULL
);

DROP TABLE IF EXISTS categories_translations CASCADE;

CREATE TABLE categories_translations (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT NOT NULL UNIQUE
);


DROP TABLE IF EXISTS products CASCADE;

CREATE TABLE products (
    product_id CHAR(32) PRIMARY KEY,
    product_category_name TEXT REFERENCES categories_translations(product_category_name),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

DROP TABLE IF EXISTS order_items CASCADE;

CREATE TABLE order_items (
    order_id CHAR(32) REFERENCES orders(order_id),
    order_item_id INTEGER NOT NULL,
    product_id CHAR(32) NOT NULL REFERENCES products(product_id),
    seller_id CHAR(32) NOT NULL REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    freight_value NUMERIC(10,2) NOT NULL CHECK (freight_value >= 0),
    PRIMARY KEY(order_id, order_item_id)
);

DROP TABLE IF EXISTS order_payments CASCADE;

CREATE TABLE order_payments(
    order_id CHAR(32) NOT NULL REFERENCES orders(order_id),
    payment_sequential INTEGER NOT NULL,
    payment_type TEXT CHECK (payment_type IN ('credit_card', 'boleto', 'voucher', 'debit_card')),
    payment_installments INTEGER NOT NULL CHECK (payment_installments >= 0),
    payment_value NUMERIC(10,2) NOT NULL CHECK (payment_value >= 0),
    PRIMARY KEY (order_id, payment_sequential) 
);

DROP TABLE IF EXISTS order_reviews CASCADE;

CREATE TABLE order_reviews(
    order_id CHAR(32) PRIMARY KEY REFERENCES orders(order_id),
    review_id CHAR(32) NOT NULL,
    review_score INTEGER NOT NULL CHECK (review_score BETWEEN 1 AND 5),
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP NOT NULL,
    review_answer_timestamp TIMESTAMP NOT NULL
);
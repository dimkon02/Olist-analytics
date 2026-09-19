DROP INDEX IF EXISTS idx_orders_purchase_timestamp;
CREATE INDEX idx_orders_purchase_timestamp ON orders (order_purchase_timestamp);
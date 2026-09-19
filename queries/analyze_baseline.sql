-- 1. Baseline: drop the index if present
DROP INDEX IF EXISTS idx_orders_purchase_timestamp;

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM orders
WHERE order_purchase_timestamp >= '2018-01-01'
  AND order_purchase_timestamp < '2018-02-01';
-- Seq Scan, Rows Removed by Filter: 92172, Buffers: 5424, Execution Time: 12.355 ms

-- 2. Add the index
CREATE INDEX idx_orders_purchase_timestamp ON orders (order_purchase_timestamp);

EXPLAIN ANALYZE
SELECT COUNT(*)
FROM orders
WHERE order_purchase_timestamp >= '2018-01-01'
  AND order_purchase_timestamp < '2018-02-01';
-- Index Only Scan, Heap Fetches: 0, Buffers: 22, Execution Time: 0.523 ms
-- 24x faster
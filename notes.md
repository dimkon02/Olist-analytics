# Fidings from Phase 2: Exploring Relationships between tables

## Tables:

- `Customers` : has 99,441 rows.
    - **PK**: `customer_id` has 99,441 distinct values.  
    - `customer_unique_id` has 96,096 distinct values, it is used to identify the customer.
    - `customer_id` is used to identify the a per order image created for every purchase.
    - The 3,345 gap is extra records belonging to people who ordered more than once (~3.4%).

- `Orders` : has 99,441 rows.
    - **PK**: `order_id` has 99,441 distinct values.
    - `customer_id` has 99,441 distinct values, it is FK to  `Customers` 1:1.
    - Null counts : `order_approved_at` is 160, `order_delivered_carrier_date` is 1,783, `order_delivered_customer_date` is 2,965.
    - `order_approved_at` : 141 are orders that were canceled that is why they were not apporved, 14 are orders that were delivered but have no approved value, these are ERRORS, 5 were created but no approved value yet (Error Rate = 14/160 = 8.75%) 
    - `order_delivered_carrier_date` : all of them are orders theat were not delivered ('unavailable', 'invoiced', 'processing', 'created', 'approved'), some are orders that will never be delivered ('canceled'), 2 show delivered but have no `order_delivered_carrier_date` theese are errors. (Error Rate = 2 / 1783 = 0.1%)
    - `order_delivered_customer_date` : all of them are orders that have not been deliveres yet (ex 'Shipped', 'processing', 'unavailable', 'invoiced', 'processing', 'created', 'approved'), or they will never be delivered (ex 'cancelled'), only 8 of them show delivered status but not date. (Error Rate = 8/2965 = 0.3%)

- `Items` : has 112,650 rows.
    - **PK**: `order_id`, `order_item_id` has  112,650 distinct values.
    - `product_id` has 32,951 distinct values, it is FK to `Products` 1:many.
    - `seller_id` has 3,095 disticnt values, it is FK to `Sellers` 1:many.
    - `order_id` has 98,666 distinct values, it is FK to `Orders` 1:many.
    - `item[order_id]` 775 less than `orders[order_id]`, unavailable(603), canceled(164), created(5), invoiced(2), shipped(1)
        767 (unavailable and canceled) make sense nothing got picked up
        3 (invoiced/shipped) errors
        5 (created) nothing has happened yet.
    - For `SQL` : JOIN drops the 775, LEFT JOIN keeps them with NULL
                    SUM will be same either way
                    Average will not 
    - OPEN: does an order containing nothing count as an order worth 0?

- `Payments` : has 103,886 rows.
    - **PK**: `order_id`, `payment_sequential` has 103,886 distinct values.
    - `order_id` has 99,440 distinct values, it is FK to `Orders` 1:many.
    - There are 99440 values in Payments[order_id] but Orders[order_id] has 99441
    - The missing orders is {'bfbd0f9bdef84302105ad712db648a6c'}
    - It was delivered late 36 days.
    - Payments has 103.886 values but 99,440 disitnct orders, this is because one order could have multiple payment ways.           (credit and coupon)

- `Reviews` : has 99,224 rows.
    - **PK**: `review_id`, `order_id` has 99,224 distinct values.
    - `order_id` has 98,673 distinct values, it is FK to `Orders` 1:many.

- `Products` : has 32,951 rows.
    - **PK**: `product_id` has 32,951 distinct values.

- `SELLERS` : has 3,095 rows
    - **PK**: `seller_id` has 3,095 distinct values.

- `Geo` : has 1,000,163 rows.
    - Geolovation has 1.000.163 rows but only 19.015 geolocation_zip_code_prefix this means 1.000.163/19.015 = 53 per prefix
    - This table doesnt have a PK so it cant be used as entity table
    - **Decision : Do not use**

- `Categories` : has 71 rows.
    
- `Other` : The first purchase date is in Sept 2016 but in 2016 (Sept has 4 rows, Oct has 324, Nov has 0, Dec has 1), From 2017 the    numbers are steady except the last 2 months in 2018 (Sept has 16, Oct has 4) so we will filter "order_purchase_timestamp" from "January 2017" and "September 2018"

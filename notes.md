# Fidings from Phase 2: Exploring Relationships between tables

## Tables:

- `Customers` : has 99,441 rows.
    - **PK**: `customer_id` has 99,441 distinct values.  
    - `customer_unique_id` has 96,096 distinct values, it is used to identify the customer.
    - `customer_id` is used to identify the a per order image created for every purchase.
    - The 3,345 gap is extra records belonging to people who ordered more than once (~3.4%).
    - if we need to look for repear purchase we need to group by `customer_unique_id`

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
    - `price` and `freigh_values` are money so we will use **`Numeric` not `floating point`**

- `Payments` : has 103,886 rows.
    - **PK**: `order_id`, `payment_sequential` has 103,886 distinct values.
    - `order_id` has 99,440 distinct values, it is FK to `Orders` 1:many.
    - There are 99440 values in Payments[order_id] but Orders[order_id] has 99441
    - The missing orders is {'bfbd0f9bdef84302105ad712db648a6c'} (has no payment)
    - It was delivered late 36 days.
    - Payments has 103.886 values but 99,440 disitnct orders, this is because one order could have multiple payment ways.           (credit and coupon)

- `Reviews` : has 99,224 rows.
    - `order_id` has 98,673 distinct values, it is FK to `Orders` 1:many.
    - `Review_id` appears on multiple rows for th different `order_id`.
    - We have 814 excess duplicates, 764 appear twice while 25 three times (764 + 25*2 = 814) (Id failing to identify)
    - 547 orders have more than one review (543 twice, 4 three times) 99224 - 98673 = 551 excess rows. (543 + 4*2)  (Nuisness Rule "one review per order" is violated)
    - (review_id, order_id) IS unique across 99,224 rows, but is NOT a usable PK:
        1. Not addressable - you must already know the review_id to look anything up.
        2. Unique by coincidence, not construction - two defects happened not to collide.
        Contrast (order_id, order_item_id): "line 2 of order X" is nameable in advance,
        and unique in ANY extract by definition.
    - => this table has NO working primary key in the source.


- `Products` : has 32,951 rows.
    - **PK**: `product_id` has 32,951 distinct values.
    - `Products` has 610 null values in `product_category_name`, `product_name_lenght`, `product_description_lenght`, `product_photos_qty`
    - They are all in the same row
    - There are two untranslated categories that exist in products nut not in the translattion table
    - {'pc_gamer', 'portateis_cozinha_e_preparadores_de_alimentos'}

- `SELLERS` : has 3,095 rows
    - **PK**: `seller_id` has 3,095 distinct values.

- `Geo` : has 1,000,163 rows.
    - Geolovation has 1.000.163 rows but only 19.015 geolocation_zip_code_prefix this means 1.000.163/19.015 = 53 per prefix
    - This table doesnt have a PK so it cant be used as entity table
    - **Decision : Do not use**

- `Categories` : has 71 rows.
    - **PK**: `product_category_name` 

    
- `Other` : The first purchase date is in Sept 2016 but in 2016 (Sept has 4 rows, Oct has 324, Nov has 0, Dec has 1), From 2017 the    numbers are steady except the last 2 months in 2018 (Sept has 16, Oct has 4) so we will filter "order_purchase_timestamp" from "January 2017" and "September 2018"


## ER ##

erDiagram
    CUSTOMERS ||--|| ORDERS : places
    ORDERS ||--o{ ORDER_ITEMS : contains
    ORDERS ||--o{ ORDER_PAYMENTS : "paid by"
    ORDERS ||--o{ ORDER_REVIEWS : "reviewed in"
    PRODUCTS ||--o{ ORDER_ITEMS : "appears in"
    SELLERS ||--o{ ORDER_ITEMS : fulfils
    CATEGORY_TRANSLATION ||--o{ PRODUCTS : translates

    CUSTOMERS {
        string customer_id PK
        string customer_unique_id "the actual person"
        string customer_city "dirty - do not group by"
        string customer_state
    }
    ORDERS {
        string order_id PK
        string customer_id FK
        string order_status
        timestamp order_purchase_timestamp
        timestamp order_approved_at "nullable"
        timestamp order_delivered_carrier_date "nullable"
        timestamp order_delivered_customer_date "nullable"
        date order_estimated_delivery_date
    }
    ORDER_ITEMS {
        string order_id PK_FK
        int order_item_id PK "line number, not an id"
        string product_id FK
        string seller_id FK
        numeric price
        numeric freight_value
    }
    ORDER_PAYMENTS {
        string order_id PK_FK
        int payment_sequential PK "line number"
        string payment_type
        int payment_installments
        numeric payment_value "must be SUMmed per order"
    }
    ORDER_REVIEWS {
        string order_id PK "after dedup"
        string review_id "not unique in source"
        int review_score
    }
    PRODUCTS {
        string product_id PK
        string product_category_name FK "610 nulls"
    }
    SELLERS {
        string seller_id PK
        string seller_state
    }
    CATEGORY_TRANSLATION {
        string product_category_name PK
        string product_category_name_english
    }
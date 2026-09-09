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
        string customer_zip_code_prefix 
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
        date shipping_limit_date
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
        string review_comment_title             
        string review_comment_message          
        string review_creation_date                
        string review_answer_timestamp
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

## DECISIONS ##

- Keep `Customers` as one table with `customer_id` the PK.
Consdiered splitting in two tables, the first being the person, second a per order record, but it would create a table with a single column (id) also since `customer_city` `customer_zip_code_prefix` and `customer_state` would be on the per oreder table, records could differ 
Cost : `customer_unmique_id` remains as non unique value, in queries have to use `GROUP BY`

- `Reviews` dedup : keep the LATEST review per order
    - ORDER BY `review_creation_date` DESC, tie-broken on `review_answer_timestamp` DESC
    - Reason : if a customer revised their opinion, the revision is their settled view
    - Alternative considered : earliest, which measures the unprompted first reaction
      before any customer service resolution. Also defensible.
    - COST : 551 rows dropped. Of 547 affected orders, 345 AGREED on score (lossless),
      202 DISAGREED (real loss)
    - Nothing destroyed, `stg_order_reviews` still holds all 99,224 rows
    - README must note the rule shifts average review scores slightly

- `order_reviews` PK is `order_id`, NOT `review_id`
    - Only valid because the dedup rule creates it. The source has no working key.
    - `review_id` kept as a plain column for traceability, cannot constrain anything
      (789 reused across different orders)
    - Also practical : ON CONFLICT (order_id) needs a unique constraint. No PK means
      no upsert means no idempotent load.

- `payment_type` = 'not_defined' will be converted to NULL
    - 3 rows, all with payment_value 0.00
    - It is missing data written as a category. Keeping it means a phantom 5th
      payment method appears in every GROUP BY payment_type

- Date window for all time series : >= 2017-01-01 AND < 2018-09-01 (20 complete months)
    - 2016 is incomplete (Nov has 0 rows, Dec has 1)
    - 2018-09 has 16 rows and 2018-10 has 4, extract was cut mid-stream

- Money columns use NUMERIC(10,2), never floating point
    - `price`, `freight_value`, `payment_value`

- Rename `lenght` -> `length` in the modelled `products` table
    - Source typo stays in staging (staging mirrors the source), fixed deliberately
      in the modelled layer

- Add the 2 missing translations to `categories_translations` in Phase 5
    - 'pc_gamer' and 'portateis_cozinha_e_preparadores_de_alimentos'
    - Must happen BEFORE loading products, or the FK rejects those rows

- `Geo` excluded entirely
    - No PK, ~53 rows per zip prefix, joining fans out ~53x (99,441 customers -> ~5M rows)
    - No error is raised, aggregates are silently inflated
    - State and city already live on customers and sellers

## CONSTRAINTS WANTED BUT BLOCKED ##

True business rules that a few bad rows prevent enforcing:

| Rule                                    | Blocked by                        |
|-----------------------------------------|-----------------------------------|
| delivered => has delivery timestamp     | 8 rows                            |
| every order has >= 1 payment            | 1 row, status DELIVERED           |
| payment_installments >= 1               | 2 credit card rows with 0         |
| payment_type is one of the 4 real types | 3 'not_defined' rows              |
| product_weight_g > 0                    | 4 rows                            |

For each : fix in Phase 5, drop the rows, or weaken the constraint.
Current choice : weaken (>= 0 rather than > 0) and document, except payment_type
which becomes NULL.
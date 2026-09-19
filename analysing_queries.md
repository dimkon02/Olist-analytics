## Analyzing Key findings on querries made ##


SCOPE : Applied to all queries:

- By revenue only price is calculated not freight value (shipping)
- Date Window : is frrom `2017-01` to `2018-09`.

# 1. Revenue by Month

- The overall trend of total revenue is upward trajectory. 

- The top selling month is `November 2017` with totla revenue of R$1,010,271.37. 
    Possible explanation is `Black Friday`

- Revenue grew from R$120,313 in January 2017 to R$854,686 in August 2018 — a 7.1x
  increase over 20 months.

- Early 2018 months performed significantly higher revenue than late 2017, but since 
  data spans a 20 month period we canc make any concrete conclusions.

- Total revenue is R$13,541,712.78

# 2. Orders by State   

- Total revenue is R$13,541,712.78.

- `SP` Sao Paolo has R$5,188,099.23 which account for `38.31%` of total revenue.

- Nearly 22% of Brazil's population lives in São Paulo (IBGE), but account for `38 
  31%` of total revenue which is 1.7x increase.

- `RJ` has R$1,812,846.22 and `MG` R$1,580,496.82, `13.38%` and `11.67%`.

- The three highest in revenue states make up `63.36%` of total revenue.

- In comparisson the last 10 states have a combined revenue of R$463,171.40 which 
  makes up for `3.42%`

- `SP` R$5,188,099.23 in 41264 : R$125.72 per order.
- `RR` R$7716.84 in 44 : R$175.38 per order.

# 3. Top performing Categories

- No single category dominates like Orders by State.

- The top selling category `health and beauty` has a total of R$1,253,993.86 which 
  accounts for `9.2%` of total revenue.

- In comparisson `Computer accessories` the 5th best selling category has a total of 
  R$910,555.00 this account for `6.72%`.

- Top 5 categories account for R$5,387,419.32 which is `39.78%`.

- While the 30 lowest selling categories account for R$249,856.50 of total revenue 
  which is only `1.84%`. 

- `unknown` ranks 21st with R$179,469 (1.3%) — products with no category assigned.
  Kept visible via LEFT JOIN + COALESCE. An inner join would have silently
  deleted this revenue from the analysis.

- Finaly, it should be mentioned that Olist's categories are too broad :
    1. There are 5 construction categories (construction_tools_construction, construction_tools_lights, construction_tools_safety, costruction_tools_garden, costruction_tools_tools) all of them could be aggregate to one.

    2. Same with categories for home applicances (home_appliances_2, home_construction, home_appliances, small_appliances_home_oven_and_coffee, kitchen_portables_and_food_preparers).

# 4. Average Order Value ny Status

- AOV is R$137.00 

- `Cancelled` had the highest order value with R$205.76, in comparisson with `Shipped` where the values was 50% lower.

- 448 cancelled orders at R$205.77 = ~R$92K lost.

- Cannot point to cause from this data, coild be : fraud detection, stock 
  availability, customer remorse or payment failure.

# 5. Analyzing payment types

# 5. Analyzing payment types

- Total payments in window : 103,520

- Credit Card : 76,537, 73.9%, Average Value : R$163.24, Average Instalments : 3.50

- Boleto : 19,721, 19.1%, Average Value : R$145.01, Average Instalments : 1.00

- Voucher : 5,733, 5.5%, Average Value : R$65.15, Average Instalments : 1.00

- Debit Card : 1,527, 1.5%, Average Value : R$142.60, Average Instalments : 1.00

- Nulls : 2, we previously discovered 3 not_defined payment types, the 3rd falls outside the date window.

- Credit card is 73.9% of transactions but 79% of total value, it over-indexes because its average ticket is larger.

- Instalments are exclusively a credit card feature. Boleto, voucher and debit card are all exactly 1.00, which is structurally correct for Brazil and validates the data. If boleto had shown 1.4 something would be wrong.

- Credit card orders average 12% more than boleto (R$163.24 vs R$145.01). Financing is the plausible driver. This sets up the Phase 10 question on instalments vs order value.

- Voucher averages R$65.15, less than half of every other method, because vouchers are partial payments or store credit rather than whole orders. Another reminder that payment_value is per tender, not per order.


# 6. Revenue by Month Running Total

- The `running total` variable along with the graph, confirm that the trajectory of 
  the revenue is upwards.

- Total revenue fot the time windows we set is R$13,541,712.78

- More than half of the revenue R$7,385,905,80 was earned after December 2017 
  meaning the majority of revenue was earned in the last 8 months of the 20 month 
  window.

# 7. Month over Month changes (Absolute and pecentage)

- `Black Friday` revenue spike is evident, there was a 52.1% increase in revenue 
  from October 2017 to November 2017.

- From April 2018 to Augoust 2018, there is an evident plateau in revenue change.

  1. April : 1.4%
  2. May : 0.0% (R$130.07 difference between the two months, when revenue for each was around R$1,000,000.00)
  3. June : -13.2% 
  4. July : 3.5%
  5. Augoust : -4.6%

- Compared to 2017, where pecentage change varied substancially

  1. February : 105.5%
  2. March : 51.4%
  3. May : 40.6%
  4. November : 52.1% 
  5. December : -26.4% 

- Black Friday revenue spike is obvious : 52.1% increase from October 2017.

- After Black Friday a sudden drop in revenu was noticed down 26.4%.

# 8. First order Per Customer 

- Inside our time window, 95.121 customers places their first order, there was a 
  total of 96,096 customers (but 975 placed it outside out time window)

- Average first order is R$138.15, the AOV is R$137.00 (querry 4). A 0.8% increase,  
  practically identical.

- Range for first order is : R$0.85 and R$13440.00

 
# 9. Customer Cohorts

- Retention is clost to zero. Every cohort, every month offset, sits between
  0.06% and 0.78%.

- The shape matters more than the size. Retention normally decays — month 1 is
  highest and falls away, because customers who come back tend to come back soon.
  Here there is no decay. The 2017-01 cohort sits at 0.39% one month in and 0.78%
  twelve months in.

- With no decay curve, these are not returning customers. They are one-off repeat
  purchases landing at random across two years.

- `NOTE`: Olist is a marketplace, not a store. Customers buy from sellers/retailers 
  by accesing Olist, this explains the low returtning customers.

# 10. Late Delivery and Low Reviews

- Review score falls consistently as delivery gets later:
    Early              4.29   (87,902 orders)
    On time            4.03   (1,280)
    Late 1-5 days      2.99   (2,721)
    Very late 5+ days  1.74   (3,658)

- A 2.55 point spread on a 5 point scale.

- Early delivery is the norm: 87,902 of 95,561 (92%).

- On time (4.03) scores below early (4.29). Meeting the promise is
  not as good as beating it.

# 11. Analyze

"QUERY PLAN"
"Aggregate  (cost=6933.69..6933.70 rows=1 width=8) (actual time=12.330..12.331 rows=1.00 loops=1)"
"  Buffers: shared hit=3065 read=2359"
"  ->  Seq Scan on orders  (cost=0.00..6915.61 rows=7230 width=0) (actual time=0.020..12.103 rows=7269.00 loops=1)"
"        Filter: ((order_purchase_timestamp >= '2018-01-01 00:00:00'::timestamp without time zone) AND (order_purchase_timestamp < '2018-02-01 00:00:00'::timestamp without time zone))"
"        Rows Removed by Filter: 92172"
"        Buffers: shared hit=3065 read=2359"
"Planning Time: 0.089 ms"
"Execution Time: 12.355 ms"

after index

"Aggregate  (cost=242.97..242.98 rows=1 width=8) (actual time=0.506..0.506 rows=1.00 loops=1)"
"  Buffers: shared hit=22"
"  ->  Index Only Scan using idx_orders_purchase_timestamp on orders  (cost=0.29..224.89 rows=7230 width=0) (actual time=0.021..0.304 rows=7269.00 loops=1)"
"        Index Cond: ((order_purchase_timestamp >= '2018-01-01 00:00:00'::timestamp without time zone) AND (order_purchase_timestamp < '2018-02-01 00:00:00'::timestamp without time zone))"
"        Heap Fetches: 0"
"        Index Searches: 1"
"        Buffers: shared hit=22"
"Planning Time: 0.078 ms"
"Execution Time: 0.523 ms"
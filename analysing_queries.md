## Analyzing Key findings on querries made ##


SCOPE : Applie to all queries 01-05:

- By revenue only price is calculated not freight value (shipping)
- Date Window : is frrom `2017-01` to `2018-09`.

# 1. Revenue by Month

- The overall trend of total revenue is upward trajectory. 

- The top selling month is `November 2017` with totla revenue of R$1,010,271.37. Possible explanation is `Black Friday`

- Revenue grew from R$120,313 in January 2017 to R$854,686 in August 2018 — a 7.1x
increase over 20 months.

- Early 2018 months performed significantly higher revenue than late 2017, but since data spans a 20 month period we canc make any concrete conclusions.

- Total revenue is R$13,541,712.78

# 2. Orders by State   

- Total revenue is R$13,541,712.78.

- `SP` Sao Paolo has R$5,188,099.23 which account for `38.31%` of total revenue.

- Nearly 22% of Brazil's population lives in São Paulo (IBGE), but account for `38.31%` of total revenue which is 1.7x increase.

- `RJ` has R$1,812,846.22 and `MG` R$1,580,496.82, `13.38%` and `11.67%`.

- The three highest in revenue states make up `63.36%` of total revenue.

- In comparisson the last 10 states have a combined revenue of R$463,171.40 which makes up for `3.42%`

- `SP` R$5,188,099.23 in 41264 : R$125.72 per order.
- `RR` R$7716.84 in 44 : R$175.38 per order.

# 3. Top performing Categories

- No single category dominates like Orders by State.

- The top selling category `health and beauty` has a total of R$1,253,993.86 which accounts for `9.2%` of total revenue.

- In comparisson `Computer accessories` the 5th best selling category has a total of R$910,555.00 this account for `6.72%`.

- Top 5 categories account for R$5,387,419.32 which is `39.78%`.

- While the 30 lowest selling categories account for R$249,856.50 of total revenue which is only `1.84%`. 

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

- Cannot point to cause from this data, coild be : fraud detection, stock availability, customer remorse or payment failure.

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

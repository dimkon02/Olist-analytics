import pandas as pd


df = pd.read_csv("data/olist_orders_dataset.csv")

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

print(df.head())

print(df.shape)  # (99441, 8)

df.info() #order_id, #customer_id. order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date,
            #order_delivered_customer_date, order_estimated_delivery_date

print(df.isna().sum())#order_aproved at 160 nulls, #order_delivered_carier_date: 1783 nulls, order_delivered_customer_date: 2965 nulls

print(df.notna().sum())

print(df["order_status"].value_counts())

#We see that there are 96478 with delivered status in (order_status), BUT
#there are 96476 with delivered_customer_date

print(pd.crosstab(df["order_status"], df["order_delivered_customer_date"].isna())) #True: value missing, False: not missing

#8 delivered that dont have delivery timestamp
#6 canceled that have delivery timestamp
# Net difference was only 2 — crosstab showed the real picture.
# Decision: trust the timestamp over the status. An event that was
# recorded happened; a status field is mutable and can go stale.
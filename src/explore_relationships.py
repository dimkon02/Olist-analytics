import pandas as pd

pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)

#All files
FILES = {
    "customers":  "olist_customers_dataset.csv",
    "orders":     "olist_orders_dataset.csv",
    "items":      "olist_order_items_dataset.csv",
    "payments":   "olist_order_payments_dataset.csv",
    "reviews":    "olist_order_reviews_dataset.csv",
    "products":   "olist_products_dataset.csv",
    "sellers":    "olist_sellers_dataset.csv",
    "geo":        "olist_geolocation_dataset.csv",
    "categories": "product_category_name_translation.csv",
}


#Function tha is used to iterate through every File, to calculate the number of rows, distinct values in each column,
#nulls for each column, and a distinct flag if a value is distinct
def profile_columns(df, name):
    print(f"\n {name}: {len(df):,} rows ")
    for col in df.columns:
        distinct = df[col].nunique()
        nulls = df[col].isna().sum()
        flag = "  <- unique" if distinct == len(df) else ""
        print(f"  {col:<32} distinct={distinct:<8,} nulls={nulls:<6,}{flag}")


frames = {name: pd.read_csv(f"data/{f}") for name, f in FILES.items()}

for name, df in frames.items():
    profile_columns(df, name)


#The function can find PK if they  are only for one value, but if the PK is a combination of columns we need to search manually
items = pd.read_csv("data/olist_order_items_dataset.csv")
print("FOR ITEMS")
print(len(items[["order_id", "order_item_id"]].drop_duplicates()))

payments = pd.read_csv("data/olist_order_payments_dataset.csv")
print("FOR PAYMENTS")
print(len(payments[["order_id", "payment_sequential"]].drop_duplicates()))

reviews = pd.read_csv("data/olist_order_reviews_dataset.csv")
print("FOR REVIEWS")
print(len(reviews[["review_id","order_id"]].drop_duplicates()))


r = frames["reviews"]
dupes = r[r.duplicated("order_id", keep=False)].sort_values("order_id")
print(dupes.head(10))

dupes = r[r.duplicated("order_id", keep=False)]
print(dupes.groupby("order_id")["review_score"].nunique().value_counts())

#Used to find how many null are in products
print(frames["products"].isna().sum())
#The nulls are in the same rows
p = frames["products"]
print(p[p["product_category_name"].isna()]["product_photos_qty"].isna().sum())
#Used to find how many product_category are in products but not categories
print(set(frames["products"]["product_category_name"].dropna())
      - set(frames["categories"]["product_category_name"]))



#Trying to find and understand why Orders[order_id] has 99,441 values, and Payments[order_id] has 99,440 values.
orders = pd.read_csv("data/olist_orders_dataset.csv")
orders_set = set(orders["order_id"])
pay_set = set(payments["order_id"])
missing = orders_set - pay_set
print(missing) #id we look for
#{'bfbd0f9bdef84302105ad712db648a6c'}
print(orders[orders["order_id"].isin(missing)]) #prints the row with the missing id
# 2016-09-15 12:16:38 : purchase date
# 2016-11-09 07:47:38 : delivered date
# 2016-10-04 00:00:00 : estimated delivery
#delivered 36 days LATE (estimated 2016-10-04, actual 2016-11-09)
#Order was delivered 

#print status : delivered and purchase date
print(orders.loc[orders["order_id"].isin(missing), ["order_status", "order_purchase_timestamp"]])

#Print orders for all motnhs
print(orders["order_purchase_timestamp"].str[:7].value_counts().sort_index())


# Trying to understand the 2965 null values at `order_delivered_customer_date`.
missing = orders[orders["order_delivered_customer_date"].isna()]
print(missing["order_status"].value_counts())


# Trying to understand the 160 null values at `order_approved_at`.
missing = orders[orders["order_approved_at"].isna()]
print(missing["order_status"].value_counts())


# Trying to understand the 1,783 null values at `order_delivered_carrier_date`.
missing = orders[orders["order_delivered_carrier_date"].isna()]
print(missing["order_status"].value_counts())

#Trying to understand the difference between orders[order_id] : 99,441 values AND items[order_id]: 98,666 values
orders_no_items = set(orders["order_id"]) - set(items["order_id"])
print(len(orders_no_items))
print(orders[orders["order_id"].isin(orders_no_items)]["order_status"].value_counts())

#Trying to understand the duplicate review_id
dupes = reviews["review_id"].value_counts()
dupes = dupes[dupes > 1]  #keeps only the review_id that appear more than once
print(len(dupes)) 

print(reviews[reviews["review_id"].isin(dupes.index)]
      [["review_id", "order_id"]]
      .sort_values("review_id")
      .head(10))

#shows the duplicate review_id how many times each was shown
print(dupes.value_counts()) 

dupes_orders = reviews["order_id"].value_counts()
dupes_orders = dupes_orders[dupes_orders  > 1 ]
print(len(dupes_orders))
print(dupes_orders.value_counts())
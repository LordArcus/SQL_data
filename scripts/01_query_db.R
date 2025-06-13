# Importing necessary libraries
library(here)
library(DBI)
library(RSQLite)


# Path to the SQLite database 
db_path <- here("data", "raw", "olist.sqlite")

# Query to extract customer metrics from the Olist dataset
query <-  "
SELECT 
  c.customer_id, 
  c.customer_unique_id, 
  o.order_purchase_timestamp, 
  rv.review_score, 
  oi.price 
  FROM 
    customers as c 
    JOIN 
      orders as o ON c.customer_id = o.customer_id 
    LEFT JOIN 
      order_reviews as rv ON o.order_id = rv.order_id 
    JOIN 
      order_items as oi ON o.order_id = oi.order_id
"

# Connect and query
con <- dbConnect(RSQLite::SQLite(), dbname = db_path)
data <- dbGetQuery(con, query)  # Query for data
dbDisconnect(con)  # Disconnect from the database


# Save a processed
saveRDS(data, here("data", "processed", "olist_data.rds"))


## Source of sql data: https://www.kaggle.com/datasets/terencicp/e-commerce-dataset-by-olist-as-an-sqlite-database
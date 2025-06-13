# Importing necessary libraries
library(here)
library(tidyverse)

# reading data
data <- readRDS(here::here("data", "processed", "olist_data.rds"))

# Data exploration
df <- data.frame(data)

# Displaying str of data
str(df)

# converting timestamp to date formate
customer_data <- df %>%
  mutate(order_date = as.Date(order_purchase_timestamp))

# first and last order dates
first_date <- min(customer_data$order_date, na.rm = TRUE)
last_date <- max(customer_data$order_date, na.rm = TRUE)


# Aggregate by customer_unique_id
customer_agg <- customer_data %>%
  group_by(customer_unique_id) %>%
  summarise(
    total_orders = n(),
    total_spend = sum(price),
    avg_review_score = mean(review_score, na.rm = TRUE),
    first_order_date = min(order_date),
    last_order_date = max(order_date),
    order_frequency = as.numeric(difftime(max(order_date), min(order_date), units = "days")) / n()
  ) %>%
  mutate(
    customer_tenure = as.numeric(difftime(last_date, first_order_date, units = "days")),
    customer_recency = as.numeric(difftime(last_date, last_order_date, units = "days")),
    avg_order_value = total_spend / total_orders
  )

## Insights: We have 2 years data; 2016-09-04 to 2018-09-03

customer <- data.frame(customer_agg)


-- This script explores the database to understand its structure and content.

-- Count the number of distinct customer in the database as their unique id
SELECT COUNT (DISTINCT c.customer_unique_id) FROM orders AS o JOIN customers as C ON o.customer_id = c.customer_id;

-- Count the number of distinct customers in the orders table
SELECT COUNT(DISTINCT customer_id) FROM orders;

-- Count the number customers that ordered more than once
SELECT  COUNT (*) customers_with_multiple FROM ( SELECT customer_unique_id FROM customers GROUP BY customer_unique_id HAVING COUNT(*) > 1);


-- This compares between customers that placed one order and those that placed multiple orders interms of their order status.

WITH customer_segments AS (
    SELECT 
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count,
        CASE WHEN COUNT(o.order_id) > 2 THEN 'repeat' ELSE 'one-time' END AS segment
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT 
    o.order_status,
    cs.segment,
    COUNT(*) AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY cs.segment), 1) AS segment_percentage
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN customer_segments cs ON c.customer_unique_id = cs.customer_unique_id
GROUP BY o.order_status, cs.segment
ORDER BY cs.segment, orders DESC;


-- This query is to find the repeat rate of customers by product category.

SELECT 
    p.product_category_name,
    COUNT(DISTINCT CASE WHEN cust.segment = 'one-time' THEN c.customer_unique_id END) AS one_time_buyers,
    COUNT(DISTINCT CASE WHEN cust.segment = 'repeat' THEN c.customer_unique_id END) AS repeat_buyers,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN cust.segment = 'repeat' THEN c.customer_unique_id END) / 
        COUNT(DISTINCT c.customer_unique_id), 1) AS repeat_rate_per_category
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
JOIN (
    SELECT 
        customer_unique_id,
        CASE WHEN COUNT(*) > 1 THEN 'repeat' ELSE 'one-time' END AS segment
    FROM customers
    GROUP BY customer_unique_id
) cust ON c.customer_unique_id = cust.customer_unique_id
GROUP BY p.product_category_name
ORDER BY repeat_rate_per_category;

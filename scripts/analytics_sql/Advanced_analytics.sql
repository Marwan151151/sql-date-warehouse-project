/*
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.
*/

-- Running totals and moving average of yearly sales
SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM 
(
    SELECT
        YEAR(order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM
        gold.fact_sales
    WHERE
        order_date IS NOT NULL
    GROUP BY
        YEAR(order_date)
) t;


/*
Performance Analysis
===============================================================================
Purpose:
    - Compare yearly product sales to their average performance.
    - Track year-over-year changes for each product.
*/

WITH yearly_product_sales AS (
    SELECT
        YEAR(s.order_date) AS order_date,
        p.product_name,
        SUM(s.sales_amount) AS total_sales
    FROM
        gold.fact_sales s
    LEFT JOIN
        gold.dim_products p
        ON s.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY
        p.product_name,
        YEAR(s.order_date)
)
SELECT 
    *,
    AVG(total_sales) OVER (PARTITION BY product_name) AS avg_sales,
    total_sales - AVG(total_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE
        WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN total_sales - AVG(total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    LAG(total_sales, 1, 0) OVER(PARTITION BY product_name ORDER BY order_date) AS last_year_sales,
    total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_date) AS year_diff,
    CASE
        WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_date) > 0 THEN 'Increase'
        WHEN total_sales - LAG(total_sales) OVER(PARTITION BY product_name ORDER BY order_date) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_date;


/*
Product Segmentation by Cost
===============================================================================
Purpose:
    - Categorize products into cost ranges.
    - Determine how many products fall into each segment.
*/

SELECT
    cost_range,
    COUNT(product_name) AS product_count
FROM
(
    SELECT
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM
        gold.dim_products
) t
GROUP BY cost_range
ORDER BY product_count DESC;


/*
Customer Segmentation by Spending Behavior
===============================================================================
Purpose:
    - Group customers into segments (VIP, Regular, New) based on:
        * Customer lifespan.
        * Total spending amount.
    - Count how many customers fall into each segment.
*/

WITH customer_spending AS (
    SELECT
        CONCAT(c.first_name,' ', c.last_name) AS customer_name,
        SUM(f.sales_amount) AS total_sales,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM
        gold.fact_sales f
    LEFT JOIN
        gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY CONCAT(c.first_name,' ', c.last_name)
)
SELECT 
    customer_segment,
    COUNT(customer_name) AS total_customers
FROM (
    SELECT
        customer_name,
        lifespan,
        total_sales,
        CASE
            WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;

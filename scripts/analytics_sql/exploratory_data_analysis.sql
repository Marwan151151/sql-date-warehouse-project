USE DataWarehouse;

-- ========================
-- RAW DATA CHECK
-- ========================
SELECT * FROM gold.dim_customers;
SELECT * FROM gold.dim_products;
SELECT * FROM gold.fact_sales;

-- ========================
-- DIMENSIONS EXPLORATION
-- ========================
SELECT DISTINCT
	category,
	subcategory,
	product_name   -- 295 product, 37 subcategory, 5 category
FROM
	gold.dim_products;

SELECT DISTINCT
	product_line
FROM
	gold.dim_products;

-- ========================
-- DATE RANGE EXPLORATION
-- ========================
SELECT
	MIN(birthdate) AS oldest_customer_bd,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_customer_age,
	MAX(birthdate) AS youngest_customer_bd,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_customer_age
FROM
	gold.dim_customers;

SELECT
	MIN(order_date),
	MAX(order_date)
FROM
	gold.fact_sales;

-- ========================
-- SHIPPING PERFORMANCE
-- ========================
-- How long does it take to ship an order?
SELECT
	AVG(DATEDIFF(DAY, order_date, shipping_date)) AS avg_shipping_days
FROM
	gold.fact_sales;

-- Is there a difference between the shipping date and the expected due date?
SELECT
	AVG(DATEDIFF(DAY, shipping_date, due_date)) AS avg_shipping_vs_due 
	-- Positive = early shipping
FROM
	gold.fact_sales;

-- ========================
-- MEASURES EXPLORATION
-- ========================
-- Total Sales
SELECT
	SUM(sales_amount) AS total_sales
FROM
	gold.fact_sales;

-- Number of items sold
SELECT
	COUNT(quantity) AS total_quantity
FROM
	gold.fact_sales;

-- Average selling price
SELECT
	AVG(price) AS avg_price
FROM
	gold.fact_sales;

-- Total number of Orders
SELECT
	COUNT(DISTINCT order_number) AS total_orders
FROM
	gold.fact_sales;

-- Total number of customers
SELECT
	COUNT(customer_key) AS total_customer
FROM
	gold.dim_customers;

-- Total number of customers that have placed an order
SELECT
	COUNT(DISTINCT customer_key) AS customers_with_orders
FROM
	gold.fact_sales;

-- ========================
-- EXECUTIVE SUMMARY (KEY METRICS REPORT)
-- ========================
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, COUNT(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Customer' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales;

-- ========================
-- MAGNITUDE ANALYSIS
-- ========================
-- Total revenue by each customer
SELECT
	c.customer_key,
	c.first_name + ' ' + c.last_name AS full_name,
	SUM(s.sales_amount) AS total_revenue
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_customers c
	ON s.customer_key = c.customer_key
GROUP BY
	c.customer_key,
	c.first_name + ' ' + c.last_name
ORDER BY
	total_revenue DESC;

-- Total revenue by category
SELECT
	p.category,
	SUM(s.sales_amount) AS total_revenue
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_products p
	ON s.product_key = p.product_key
GROUP BY
	p.category
ORDER BY total_revenue DESC;

-- Sales by subcategory
SELECT
	p.subcategory,
	SUM(s.sales_amount) AS total_sales
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_products p
	ON s.product_key = p.product_key
GROUP BY
	p.subcategory
ORDER BY total_sales DESC;

-- Sales in each subcategory by category
SELECT
	P.category,
	p.subcategory,
	SUM(s.sales_amount) AS total_sales
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_products p
	ON s.product_key = p.product_key
GROUP BY
	P.category,
	p.subcategory
ORDER BY 
	p.category,
	total_sales DESC;

-- ========================
-- CUSTOMER & PRODUCT DISTRIBUTION
-- ========================
-- Distribution of sold items across countries
SELECT
	c.country,
	COUNT(s.quantity) AS total_sold_items
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_customers c
	ON s.customer_key = c.customer_key
GROUP BY
	c.country
ORDER BY
	total_sold_items DESC;

-- Total customers by gender
SELECT
	gender,
	COUNT(customer_key) AS total_customer
FROM
 	gold.dim_customers
GROUP BY
	gender
ORDER BY total_customer DESC;

-- Sales by gender
SELECT
	c.gender,
	SUM(s.sales_amount) AS total_sales
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_customers c
	ON s.customer_key = c.customer_key
GROUP BY
	c.gender
ORDER BY total_sales DESC;

-- What is the average cost in each category?
SELECT
    category,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Total customers by country
SELECT
	country,
	COUNT(customer_key) AS total_customer
FROM
	gold.dim_customers
GROUP BY
	country
 ORDER BY total_customer DESC;

-- ========================
-- PRODUCT PERFORMANCE RANKING
-- ========================
-- Top 5 products by Revenue 
SELECT TOP 5
	p.product_name,
	SUM(s.sales_amount) AS total_sales
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_products p
	ON s.product_key = p.product_key
GROUP BY
	p.product_name
ORDER BY SUM(s.sales_amount) DESC;

-- 5 worst-performing products in terms of sales
SELECT TOP 5
	p.product_name,
	SUM(s.sales_amount) AS total_sales
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_products p
	ON s.product_key = p.product_key
GROUP BY
	p.product_name
ORDER BY SUM(s.sales_amount);

-- ========================
-- CUSTOMER PERFORMANCE RANKING
-- ========================
-- Top 10 customers by revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
	SUM(s.sales_amount) AS total_revenue
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_customers c
	ON s.customer_key = c.customer_key
GROUP BY
	c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;

-- 10 customers with the fewest orders placed
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
	COUNT(DISTINCT s.order_number) as total_orders
FROM
	gold.fact_sales s
LEFT JOIN
	gold.dim_customers c
	ON s.customer_key = c.customer_key
GROUP BY
	c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders;

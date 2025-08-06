/*
Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	cc.cst_id             AS customer_id,
	cc.cst_key            AS customer_number,
	cc.cst_firstname      AS first_name,
	cc.cst_lastname       AS last_name,
	cc.cst_marital_status AS marital_status,
	CASE
		WHEN cc.cst_gndr = 'n/a' THEN COALESCE(ec.GEN, 'n/a')
		ELSE cc.cst_gndr
	END					  AS gender,
	cc.cst_create_date    AS create_date,
	ec.BDATE			  AS birthdate
FROM
	silver.crm_cus_info cc
LEFT JOIN silver.erp_cust_az12 ec
	ON cc.cst_key = ec.CID


IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cp.prd_start_dt, cp.prd_key) AS prouct_key,
	cp.prd_id       AS product_id,
	cp.prd_key      AS product_number,
	cp.prd_nm	    AS product_name,
	cp.prd_cost     AS cost,
	cp.cat_id       AS category_id,
	ep.CAT          AS category,
	ep.SUBCAT       AS subcategory,
	ep.MAINTENANCE  AS maintenance,
	cp.prd_line     AS product_line,
	cp.prd_start_dt AS start_date
FROM
	silver.crm_prd_info cp
LEFT JOIN
	silver.erp_px_cat_g1v2 ep
	ON cp.cat_id = ep.ID
WHERE 
	prd_end_dt IS NULL -- Fillter only for the current date prodcuts


IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
	cs.sls_ord_num  AS order_number,
	dc.customer_id	AS customer_key,
	dp.product_id   AS product_key,
	cs.sls_order_dt AS order_date,
	cs.sls_ship_dt  AS ship_date,
	cs.sls_due_dt   AS due_date,
	cs.sls_sales    AS sales_amount,
	cs.sls_quantity AS quantity,
	cs.sls_price    AS price
FROM
	silver.crm_sales_details cs
LEFT JOIN
	gold.dim_customers dc
ON cs.sls_cust_id = dc.customer_id
LEFT JOIN
	gold.dim_products dp
ON cs.sls_prd_key = dp.product_number

/*
=======================================================
Quality Checks Summary
=======================================================
Purpose:
    Validate data in the Silver Layer by checking:
    - Nulls/duplicates in primary keys
    - Extra spaces in strings
    - Data consistency and standardization
    - Invalid or illogical dates
    - Cross-field consistency

Usage:
    - Run post Silver Layer load
    - Investigate and fix any issues found
=======================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	cst_id,
	COUNT(cst_id)
FROM
	silver.crm_cus_info 
GROUP BY
	cst_id
HAVING COUNT(cst_id) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
	cst_firstname
FROM
	silver.crm_cus_info
WHERE cst_firstname <> TRIM(cst_firstname);

SELECT 
	cst_lastname
FROM
	silver.crm_cus_info
WHERE cst_lastname <> TRIM(cst_lastname);

-- Data Standardization & Consistency
SELECT DISTINCT
	cst_marital_status
FROM
	silver.crm_cus_info;


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
	prd_id,
	COUNT(prd_id)
FROM
	silver.crm_prd_info
GROUP BY
	prd_id
HAVING COUNT(prd_id) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
	prd_nm
FROM
	silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT
	prd_cost
FROM
	silver.crm_prd_info
WHERE prd_cost <= 0;

-- Data Standardization & Consistency
SELECT DISTINCT
	prd_line
FROM
	silver.crm_prd_info

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT
	*
FROM
	silver.crm_prd_info
WHERE
	prd_start_dt IS NULL OR 
	prd_start_dt > prd_end_dt 


-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE 
    sls_sales IS NULL 
    OR sls_quantity IS NULL 
    OR sls_price IS NULL 
    OR sls_sales <= 0 
    OR sls_quantity <= 0 
    OR sls_price <= 0
    OR sls_sales != sls_quantity * sls_price
ORDER BY sls_sales;


-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: No Result
SELECT
	BDATE
FROM
	silver.erp_CUST_AZ12
WHERE BDATE > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;


-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

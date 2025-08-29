/*
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_date DATETIME, @end_date DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	
	BEGIN TRY
		SET @batch_start_time = GETDATE();

		-- Load bronze.crm_cus_info
		SET @start_date = GETDATE();
		PRINT '>> Truncate Table: bronze.crm_cus_info'
		TRUNCATE TABLE bronze.crm_cus_info;

		PRINT '>> Inserting Data into: bronze.crm_cus_info'
		BULK INSERT bronze.crm_cus_info
		FROM 'F:\Date analysis\Projects\Data Warehoue\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_date = GETDATE();
		PRINT '>> Load Duration (bronze.crm_cus_info): ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS VARCHAR) + ' seconds';

		-- Load bronze.crm_prd_info
		SET @start_date = GETDATE();
		PRINT '>> Truncate Table: bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Data into: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'F:\Date analysis\Projects\Data Warehoue\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_date = GETDATE();
		PRINT '>> Load Duration (bronze.crm_prd_info): ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS VARCHAR) + ' seconds';

		-- Load bronze.crm_sales_details
		SET @start_date = GETDATE();
		PRINT '>> Truncate Table: bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting Data into: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'F:\Date analysis\Projects\Data Warehoue\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_date = GETDATE();
		PRINT '>> Load Duration (bronze.crm_sales_details): ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS VARCHAR) + ' seconds';

		-- Load bronze.erp_CUST_AZ12
		SET @start_date = GETDATE();
		PRINT '>> Truncate Table: bronze.erp_CUST_AZ12'
		TRUNCATE TABLE bronze.erp_CUST_AZ12;

		PRINT '>> Inserting Data into: bronze.erp_CUST_AZ12'
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'F:\Date analysis\Projects\Data Warehoue\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_date = GETDATE();
		PRINT '>> Load Duration (bronze.erp_CUST_AZ12): ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS VARCHAR) + ' seconds';

		-- Load bronze.erp_LOC_A101
		SET @start_date = GETDATE();
		PRINT '>> Truncate Table: bronze.erp_LOC_A101'
		TRUNCATE TABLE bronze.erp_LOC_A101;

		PRINT '>> Inserting Data into: bronze.erp_LOC_A101'
		BULK INSERT bronze.erp_LOC_A101
		FROM 'F:\Date analysis\Projects\Data Warehoue\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_date = GETDATE();
		PRINT '>> Load Duration (bronze.erp_LOC_A101): ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS VARCHAR) + ' seconds';

		-- Load bronze.erp_PX_CAT_G1V2
		SET @start_date = GETDATE();
		PRINT '>> Truncate Table: bronze.erp_PX_CAT_G1V2'
		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

		PRINT '>> Inserting Data into: bronze.erp_PX_CAT_G1V2'
		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'F:\Date analysis\Projects\Data Warehoue\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_date = GETDATE();
		PRINT '>> Load Duration (bronze.erp_PX_CAT_G1V2): ' + CAST(DATEDIFF(SECOND, @start_date, @end_date) AS VARCHAR) + ' seconds';

		-- Summary
		PRINT '>> Loading Bronze Layer is Completed';
		SET @batch_end_time = GETDATE();
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';

	END TRY
	BEGIN CATCH
		PRINT 'ERROR OCCURRED DURING LOAD BRONZE LAYER';
		PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
		PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS VARCHAR);
	END CATCH
END

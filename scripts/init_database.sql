/*
Create Database and Schemas
=============================================================

Script Purpose:
    This script creates a new database named 'DataWarehouse'.
    If the database exists, it will be dropped and recreated.
    It also creates three schemas: 'bronze', 'silver', and 'gold'.

WARNING:
    Running this script will delete all existing data in 'DataWarehouse'.
    Make sure to back up your data before proceeding.
*/

USE master;
	
DROP DATABASE IF EXISTS DataWarehouse;

CREATE DATABASE DataWarehouse;

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

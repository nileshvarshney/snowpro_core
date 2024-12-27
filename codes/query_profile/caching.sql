/*-------------------------------------------
1) Metadata Cache
2) Results Cache
3) Virtual Warehouse Local Storage
----------------------------------------------*/

-- Set context
USE ROLE SYSADMIN;

USE SCHEMA SNOWFLAKE_SAMPLE_DATA.TPCH_SF1000;

ALTER WAREHOUSE COMPUTE_WH SUSPEND;
ALTER WAREHOUSE SET AUTO_RESUME=FALSE;

-- Count all records
SELECT COUNT(*) FROM CUSTOMER;

-- Context Functions
SELECT CURRENT_USER();

-- Object descriptions
DESCRIBE TABLE CUSTOMER;

-- List objects
SHOW TABLES;

-- System functions 
SELECT SYSTEM$CLUSTERING_INFORMATION('LINEITEM', ('L_ORDERKEY'));
SELECT SYSTEM$CLUSTERING_INFORMATION('LINEITEM');

SELECT * FROM CUSTOMER;

-- Results Cache
USE ROLE ACCOUNTADMIN;
ALTER WAREHOUSE COMPUTE_WH RESUME IF SUSPENDED;
ALTER WAREHOUSE SET AUTO_RESUME=TRUE;

USE ROLE SYSADMIN;
SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE FROM CUSTOMER LIMIT 1000000;

SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE FROM CUSTOMER LIMIT 1000000;

-- Syntactically different
SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_ACCTBAL FROM CUSTOMER LIMIT 1000000;

-- Includes functions evaluated at execution time
SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE, CURRENT_TIMESTAMP() FROM CUSTOMER LIMIT 1000000;

USE ROLE ACCOUNTADMIN;
ALTER ACCOUNT SET USE_CACHED_RESULT = FALSE;

SELECT C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE FROM CUSTOMER LIMIT 1000000;

-- Local storage
SELECT O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE
FROM ORDERS
WHERE O_ORDERDATE > DATE('1997-09-19')
ORDER BY O_ORDERDATE
LIMIT 1000;

SELECT O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE
FROM ORDERS
WHERE O_ORDERDATE > DATE('1997-09-19')
ORDER BY O_ORDERDATE
LIMIT 1000;


-- Additional column
SELECT O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE, O_CLERK, O_ORDERPRIORITY
FROM ORDERS
WHERE O_ORDERDATE > DATE('1997-09-19')
ORDER BY O_ORDERDATE
LIMIT 1000;

ALTER WAREHOUSE COMPUTE_WH SUSPEND;
ALTER WAREHOUSE COMPUTE_WH RESUME;

SELECT O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE
FROM ORDERS
WHERE O_ORDERDATE > DATE('1997-09-19')
ORDER BY O_ORDERDATE
LIMIT 1000;

ALTER ACCOUNT SET USE_CACHED_RESULT = TRUE;
-- create new database
create database clone_test;

-- create new table
create table customer as select * from  SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER;

-- clone the table
create or replace table CUSTOMER_CLONE CLONE CUSTOMER;

show TABLES;

select count(1) from CUSTOMER_CLONE;

select count(1) from CUSTOMER;


-- update of one table will not impact other
UPDATE TABLE CUSTOMER_CLONE SET C_MKTSEGMENT = 'STRUCTURE' WHERE C_MKTSEGMENT = 'BUILDING';

SELECT C_MKTSEGMENT, COUNT(1) FROM CUSTOMER_CLONE GROUP BY 1;

SELECT C_MKTSEGMENT, COUNT(1) FROM CUSTOMER GROUP BY 1;


-- Cloning database
---------------------
USE DATABASE clone_test;

CREATE TABLE clone_test.public.nation     
	AS SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.NATION;

CREATE SCHEMA sub_schema;

CREATE TABLE clone_test.sub_schema.region        
AS SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.REGION;


CREATE DATABASE cloned_database clone clone_test;


-- Cloning table with Time Travel
----------------------------
/*
CREATE { DATABASE | SCHEMA | TABLE  } <object_name>
  CLONE <source:object_name>
[ { AT | BEFORE } ( { TIMESTAMP => <timestamp> | OFFSET => <time_difference> | STATEMENT => <id> } ) ]
*/

CREATE OR REPLACE DATABASE test_timetravel_cloning;

USE DATABASE test_timetravel_cloning;

CREATE TABLE test_timetravel_cloning.public.supplier 
	AS SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.SUPPLIER;

UPDATE test_timetravel_cloning.public.supplier SET S_NAME = NULL;

SELECT COUNT(*) FROM test_timetravel_cloning.public.supplier WHERE S_NAME IS NOT NULL;

-- query_id = '01b90f18-0004-539d-0003-4b630002076a'
CREATE OR REPLACE TABLE supplier_copy clone supplier BEFORE (STATEMENT => '01b90f18-0004-539d-0003-4b630002076a');


-- cleaning

DROP DATABASE clone_test; 
DROP DATABASE cloned_database; 
DROP DATABASE test_timetravel_cloning; 

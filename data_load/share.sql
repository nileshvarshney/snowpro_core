CREATE OR REPLACE DATABASE test_sharing;

USE DATABASE test_sharing;
 
CREATE TABLE test_sharing.public.customer 
AS SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF10.CUSTOMER;


USE ROLE ACCOUNTADMIN;

CREATE SHARE shr_customer;

GRANT SELECT ON TABLE test_sharing.public.customer TO SHARE shr_customer;

GRANT USAGE ON DATABASE test_sharing TO SHARE shr_customer;
GRANT USAGE ON SCHEMA test_sharing.public TO SHARE shr_customer;

GRANT SELECT ON TABLE test_sharing.public.customer TO SHARE shr_customer;

ALTER SHARE shr_customer ADD ACCOUNT = <consumer_account_name>;

USE ROLE ACCOUNTADMIN;
CREATE DATABASE customer_data FROM SHARE <provider_account_name>.shr_customer;

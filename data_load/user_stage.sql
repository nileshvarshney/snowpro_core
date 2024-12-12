USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

create or replace TABLE LA_DB.LA_SCHEMA.CUSTOMERS_USER (
	CUSTOMER NUMBER(38,0) NOT NULL,
	FIRST_NAME VARCHAR(255) NOT NULL,
	LAST_NAME VARCHAR(255) NOT NULL,
	REGION VARCHAR(255) NOT NULL,
	EMAIL VARCHAR(255) NOT NULL,
	GENDER VARCHAR(255) NOT NULL,
	"order" NUMBER(38,0) NOT NULL
);

put file:///Users/xxx/Downloads/MOCK.csv @~/CUSTOMERS_USER/staged AUTO_COMPRESS = FALSE;
put file:///Users/xxx/Downloads/MOCK1.csv @~/CUSTOMERS_USER/staged AUTO_COMPRESS = FALSE;

list @~;

COPY INTO CUSTOMERS_USER FROM @~/CUSTOMERS_USER/staged FILE_FORMAT=(TYPE = 'CSV' SKIP_HEADER=1) PURGE=TRUE;

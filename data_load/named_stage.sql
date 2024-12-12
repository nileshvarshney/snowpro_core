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

CREATE OR REPLACE STAGE internal_stage FILE_FORMAT = (type= 'CSV' FIELD_DELIMITER = ',' SKIP_HEADER = 1);

put file:///Users/xxx/Downloads/MOCK.csv @INTERNAL_STAGE/staged AUTO_COMPRESS = FALSE;
put file:///Users/xxx/Downloads/MOCK1.csv @INTERNAL_STAGE/staged AUTO_COMPRESS = FALSE;

list @INTERNAL_STAGE

copy into LA_DB.LA_SCHEMA.CUSTOMERS_USER FROM @INTERNAL_STAGE/staged file_format = (type = 'CSV' SKIP_HEADER = 1) PURGE=TRUE;

USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

list @INTERNAL_STAGE;

remove @INTERNAL_STAGE;

-- unload the data into named stage
copy into @INTERNAL_STAGE FROM CUSTOMERS_USER FILE_FORMAT =(type = 'CSV' COMPRESSION = 'NONE') OVERWRITE = TRUE HEADER=TRUE;


list @INTERNAL_STAGE;

--Download the file
get @INTERNAL_STAGE file:///Users/xxx/Downloads/;

remove @INTERNAL_STAGE;

-- unload the data by region partition
copy into @INTERNAL_STAGE FROM CUSTOMERS_USER PARTITION BY REGION FILE_FORMAT =(type = 'CSV' COMPRESSION = 'NONE')  HEADER=TRUE;

--Download the files
get @INTERNAL_STAGE file:///Users/xxx/Downloads/;

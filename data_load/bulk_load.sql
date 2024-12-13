-- create internal named stage
CREATE OR REPLACE STAGE internal_named_stage FILE_FORMAT = (type= 'CSV' FIELD_DELIMITER = ',' SKIP_HEADER = 1);

-- load stage from table data
COPY INTO @internal_named_stage FROM CUSTOMERS_USER FILE_FORMAT = (type= 'CSV' COMPRESSION = 'NONE') HEADER=TRUE SINGLE=TRUE;

SELECT t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7 from @internal_named_stage t LIMIT 5;

CREATE OR REPLACE TABLE customer_full_name AS 
SELECT 	t.$1 as Id, 
		concat(t.$2, ' ', t.$3) full_name, 
		t.$4 as region, 
		t.$5 email, 
		t.$6 gender, 
		cast(t.$7 as float) salary 
FROM @internal_named_stage t;

SELECT * FROM customer_full_name LIMIT 5;


TRUNCATE TABLE customer_full_name;

COPY INTO customer_full_name (id, full_name, region, email, gender, salary) FROM (
SELECT 	t.$1 as Id, 
	concat(t.$2, ' ', t.$3) full_name, 
	t.$4 as region, 
	t.$5 email, 
	t.$6 gender, 
	cast(t.$7 as float) salary 
FROM @internal_named_stage/data t
)
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 )
FORCE = TRUE; 


CREATE OR REPLACE TABLE customer_with_binary_region AS 
SELECT
    t.$1 as Id, 
    concat(t.$2, ' ', t.$3) full_name, 
    t.$4 as region, 
    t.$5 email, 
    t.$6 gender, 
    cast(t.$7 as float) salary,
    to_binary(t.$4,'utf-8') as region_binary
FROM @internal_named_stage/data t
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 )
FORCE = TRUE; 

SELECT * FROM customer_with_binary_region LIMIT 10;

---load only for auto increment
CREATE TABLE customer_auto_increment (
	index NUMBER autoincrement start 1 increment 1,
	full_name VARCHAR,
	region VARCHAR,
	email VARCHAR,
	gender VARCHAR,
	salary DECIMAL (15,3),
	extra_col binary
);

DESCRIBE table CUSTOMER_AUTO_INCREMENT;


COPY INTO customer_auto_increment (full_name, region, email, gender, salary, extra_col) FROM (
SELECT 	
	concat(t.$2, ' ', t.$3) full_name, 
	t.$4 as region, 
	t.$5 email, 
	t.$6 gender, 
	cast(t.$7 as float) salary,
	to_binary(t.$4,'utf-8') as region_binary 
FROM @internal_named_stage/data t
)
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 )
FORCE = TRUE; 



USE ROLE SYSADMIN;

CREATE OR REPLACE DATABASE test_tasks;

CREATE TABLE test_tasks.public.customer_report
(
  customer_name STRING,
  total_price   NUMBER
);

CREATE TASK generate_customer_report
WAREHOUSE=COMPUTE_WH
SCHEDULE = '5 MINUTE'
AS
INSERT INTO test_tasks.public.customer_report
SELECT c.c_name as customer_name,SUM(o.o_totalprice) AS total_price 
FROM snowflake_sample_data.tpch_sf1.orders o
INNER JOIN snowflake_sample_data.tpch_sf1.customer c
ON o.o_custkey = c.c_custkey
GROUP BY c.c_name;

SHOW TASKS LIKE 'generate_customer_report';

ALTER TASK generate_customer_report RESUME;

--------------------------------------------
--in case error in resume task
--------------------------------------------
USE ROLE ACCOUNTADMIN;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE SYSADMIN;

USE ROLE SYSADMIN;
ALTER TASK generate_customer_report RESUME;

----------------------------------------------
-- check task execution/error info
----------------------------------------------
USE ROLE ACCOUNTADMIN;
SELECT name, state,
    completed_time, scheduled_time, 
    error_code, error_message
FROM TABLE(information_schema.task_history())
WHERE name = 'GENERATE_CUSTOMER_REPORT';

-- Result
SELECT COUNT(*) FROM test_tasks.public.customer_report; 

-- suspend the task to avoid unwanted compute 
ALTER TASK generate_customer_report SUSPEND; 

----------------------------------------------
-- connect multiple tasks
----------------------------------------------
USE DATABASE test_tasks;
USE ROLE SYSADMIN;

CREATE TASK delete_customer_report
WAREHOUSE=COMPUTE_WH
SCHEDULE = '5 MINUTE'
AS
DELETE FROM test_tasks.public.customer_report;

ALTER TASK generate_customer_report UNSET SCHEDULE;

ALTER TASK generate_customer_report ADD AFTER delete_customer_report;

ALTER TASK generate_customer_report RESUME;
ALTER TASK delete_customer_report RESUME;

SELECT name, state,
    completed_time, scheduled_time, 
    error_code, error_message
FROM TABLE(information_schema.task_history())
WHERE name IN ('DELETE_CUSTOMER_REPORT','GENERATE_CUSTOMER_REPORT');

ALTER TASK delete_customer_report SUSPEND;
ALTER TASK generate_customer_report SUSPEND; 



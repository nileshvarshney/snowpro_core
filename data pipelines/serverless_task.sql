USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE test_tasks;

CREATE TABLE test_tasks.public.order_count
(
  Snapshot_time TIMESTAMP,
  total_orders   NUMBER
);


CREATE TASK generate_order_count
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
SCHEDULE = '2 MINUTE'
AS
INSERT INTO test_tasks.public.order_count
SELECT CURRENT_TIMESTAMP as snapshot_time, COUNT(*) AS total_orders 
FROM snowflake_sample_data.tpch_sf1.orders o
GROUP BY 1;

USE ROLE  ACCOUNTADMIN;
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE SYSADMIN;

USE ROLE SYSADMIN;
ALTER TASK generate_order_count RESUME;


SELECT * FROM  TABLE(information_schema.serverless_task_history())

SELECT name, state,
    completed_time, scheduled_time, 
    error_code, error_message
FROM TABLE(information_schema.task_history())
WHERE name IN ('GENERATE_ORDER_COUNT');


SELECT * FROM test_tasks.public.order_count;

ALTER TASK generate_order_count SUSPEND;

DROP DATABASE test_tasks;

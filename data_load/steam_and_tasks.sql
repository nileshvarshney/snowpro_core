USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- Create a sample table
CREATE OR REPLACE TABLE orders (
    order_id INT,
    customer_name STRING,
    order_amount DECIMAL(10, 2),
    order_date TIMESTAMP
);

-- Create TASK with User Managed Warehouse
CREATE OR REPLACE TASK TASK_ORDER_U
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = '1 MINUTE'
AS
INSERT INTO orders (order_id, customer_name, order_amount, order_date)
VALUES (1, 'Alice', 100.50, CURRENT_TIMESTAMP);

-- Create TASK for Serverless
CREATE OR REPLACE TASK TASK_ORDER_S
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'   --By Default Medium
  SCHEDULE = '1 MINUTE'
AS
INSERT INTO orders (order_id, customer_name, order_amount, order_date)
VALUES (2, 'BoB', 100.50, CURRENT_TIMESTAMP);

-- Check the default values
SHOW PARAMETERS IN DATABASE;
  
-- Show all Tasks
SHOW TASKS;

-- Need to Resume the tasks
ALTER TASK TASK_ORDER_U RESUME;
ALTER TASK TASK_ORDER_S RESUME;

--Check history of all tasks
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY());

-- Check data update
SELECT * FROM orders;

-- You can alter the initial warehouse after susoending the task
ALTER TASK TASK_ORDER_S SUSPEND;
ALTER TASK TASK_ORDER_S SET USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'SMALL';

DESC TASK TASK_ORDER_S;

-- execute suspended task without resuming manually
EXECUTE TASK TASK_ORDER_S;

DROP TASK IF EXISTS TASK_ORDER_S;

-- Depndednt Tasks
ALTER TASK TASK_ORDER_U SUSPEND;

CREATE OR REPLACE TASK TASK_ORDER_S
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
  --SCHEDULE = '1 MINUTE'
  AFTER TASK_ORDER_U
  AS
  	INSERT INTO orders (order_id, customer_name, order_amount, order_date)
	VALUES (3, 'John', 250.50, CURRENT_TIMESTAMP);

ALTER TASK TASK_ORDER_S RESUME;
ALTER TASK TASK_ORDER_u RESUME;

SHOW TASKS;
--------------------------------
-- Combining Stream and Tasks
-------------------------------
-- Inserting new record in source tablle
CREATE OR REPLACE TABLE raw_orders (
    order_id INT,
    customer_name STRING,
    order_amount DECIMAL(10, 2),
    order_date TIMESTAMP
);

CREATE OR REPLACE STREAM raw_orders_stream ON TABLE raw_orders;

INSERT INTO raw_orders (order_id, customer_name, order_amount, order_date)
	VALUES (4, 'Jane', 170.50, CURRENT_TIMESTAMP);

SELECT * FROM raw_data_stream;

CREATE OR REPLACE TASK TASK_STREAM
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
  SCHEDULE = '1 MINUTE'
WHEN  SYSTEM$STREAM_HAS_DATA('raw_orders_stream')
AS INSERT INTO orders(order_id, customer_name, order_amount, order_date) SELECT order_id, customer_name, order_amount, order_date FROM raw_orders_stream;

ALTER TASK TASK_STREAM RESUME;

--Check history of all tasks

SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY());

SHOW TASKS;

SELECT *  FROM orders;

ALTER TASK TASK_STREAM SUSPEND;

ALTER TASK TASK_ORDER_U SUSPEND;
ALTER TASK TASK_ORDER_S SUSPEND;
--Drop All Tasks
drop table orders;
drop table raw_orders;

DROP TASK TASK_ORDER_S;
DROP TASK TASK_ORDER_U;
DROP TASK TASK_STREAM;

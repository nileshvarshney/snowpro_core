USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE TABLE orders (
    order_id INT,
    customer_name STRING,
    order_amount DECIMAL(10, 2),
    order_date TIMESTAMP
);

CREATE OR REPLACE TABLE processed_orders (
                         order_id INT,
                         customer_name STRING,
                         order_amount DECIMAL(10, 2),
                         order_date TIMESTAMP
 );

CREATE OR REPLACE TABLE notifications (
    notification_id INT AUTOINCREMENT,
    order_id INT,
    customer_name STRING,
    message STRING,
    notification_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Insert initial data
INSERT INTO orders (order_id, customer_name, order_amount, order_date)
VALUES
    (1, 'Alice', 100.50, CURRENT_TIMESTAMP),
    (2, 'Bob', 200.00, CURRENT_TIMESTAMP);


-- initial load the orders
INSERT INTO processed_orders  SELECT * FROM orders;

-- Create a stream to capture changes
CREATE OR REPLACE STREAM orders_stream ON TABLE orders;

CREATE OR REPLACE STREAM orders_notificaation_stream ON TABLE orders;



-- Insert new data
INSERT INTO orders (order_id, customer_name, order_amount, order_date)
VALUES
    (3, 'Charlie', 150.75, CURRENT_TIMESTAMP);

-- Update existing data
UPDATE orders
SET order_amount = 250.00
WHERE order_id = 2;

-- Delete a row
DELETE FROM orders
WHERE order_id = 1;


-- Query the stream to see captured changes
SELECT * FROM orders_stream;


-- Process orders
MERGE INTO processed_orders as t 
USING orders_stream as s on s.order_id = t.order_id
WHEN MATCHED AND s.METADATA$ACTION = 'DELETE' AND s.METADATA$ISUPDATE = 'FALSE' THEN DELETE
WHEN MATCHED AND s.METADATA$ACTION = 'INSERT' AND s.METADATA$ISUPDATE = 'TRUE' THEN 
    UPDATE SET CUSTOMER_NAME = s.CUSTOMER_NAME, ORDER_AMOUNT = s.ORDER_AMOUNT, ORDER_DATE = s.ORDER_DATE
WHEN NOT MATCHED AND  s.METADATA$ACTION = 'INSERT' AND s.METADATA$ISUPDATE = 'FALSE' THEN 
    INSERT (ORDER_ID,CUSTOMER_NAME,ORDER_AMOUNT,ORDER_DATE ) VALUES (s.ORDER_ID,s.CUSTOMER_NAME,s.ORDER_AMOUNT,s.ORDER_DATE);

INSERT INTO notifications (order_id, customer_name, message)
SELECT
    order_id,
    customer_name,
    CASE 
        WHEN Metadata$action = 'INSERT' AND METADATA$ISUPDATE = 'FALSE' THEN 'New order placed.'
        WHEN Metadata$action = 'INSERT' AND METADATA$ISUPDATE = 'TRUE' THEN 'Order details updated.'
        WHEN Metadata$action = 'DELETE' AND METADATA$ISUPDATE = 'FALSE' THEN 'Order cancelled.'
    END AS message
FROM orders_notificaation_stream;



drop STREAM if exists orders_stream;
drop STREAM if exists orders_stream_notification;
drop table if exists orders; 
drop table if exists processed_orders;
drop table notifications;



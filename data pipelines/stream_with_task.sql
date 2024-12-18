CREATE OR REPLACE DATABASE test_streams;
 
CREATE TABLE test_streams.public.customer
(
  Customer_Name  STRING,
  Customer_Email STRING,
  Discount_Promo BOOLEAN
);

CREATE TABLE test_streams.public.discount_voucher_list
(
  Customer_Email STRING  
);

CREATE STREAM customer_changes ON TABLE customer;

INSERT INTO test_streams.public.customer
VALUES
(
  'John Smith', 'john.smith@personal.unknown','Y'
);

SELECT * FROM test_streams.public.customer_changes;

INSERT INTO test_streams.public.discount_voucher_list 
SELECT Customer_Email FROM customer_changes WHERE Discount_Promo = 'Y' 
AND METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = FALSE;

SELECT * FROM test_streams.public.discount_voucher_list;

UPDATE test_streams.public.customer SET Customer_Email = 'john.smith@official.known' WHERE Customer_Name = 'John Smith';
 
INSERT INTO test_streams.public.customer
VALUES
(
  'Narendra Modi', 'narendra.modi@new.organisation','Y'
);
 
INSERT INTO test_streams.public.customer
VALUES
(
  'Amit Shah', 'amit.shah@jane.industries','N'
);

SELECT * FROM test_streams.public.customer_changes;

CREATE TASK process_new_customers
USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
SCHEDULE = '2 MINUTE'
WHEN SYSTEM$STREAM_HAS_DATA('customer_changes')
AS
INSERT INTO test_streams.public.discount_voucher_list 
SELECT Customer_Email FROM customer_changes WHERE Discount_Promo = 'Y' 
AND METADATA$ACTION = 'INSERT' AND METADATA$ISUPDATE = FALSE;

ALTER TASK process_new_customers RESUME;

SELECT name, state,
    completed_time, scheduled_time, 
    error_code, error_message
FROM TABLE(information_schema.task_history())
WHERE name IN ('PROCESS_NEW_CUSTOMERS');

SELECT * FROM test_streams.public.discount_voucher_list; 

ALTER TASK process_new_customers SUSPEND;

DROP DATABASE test_streams;

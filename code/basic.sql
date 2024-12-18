CREATE DATABASE LA_DB;
CREATE SCHEMA LA_SCHEMA;

SHOW DATABASES;
SHOW SCHEMAS;

DESCRIBE DATABASE LA_DB;
DESCRIBE SCHEMA LA_SCHEMA;
DESCRIBE TABLE MY_TABLE;

-------------
-- warehouse
-------------
CREATE WAREHOUSE IF NOT EXISTS xs_warehouse
WAREHOUSE_SIZE= XSMALL
AUTO_SUSPEND=60
AUTO_RESUME=TRUE
INITIALLY_SUSPENDED=TRUE;

SHOW WAREHOUSES;
SHOW WAREHOUSES LIKE '%WARE%';

DESCRIBE WAREHOUSE XS_WAREHOUSE;

DROP WAREHOUSE IF EXISTS xs_warehouse;

DROP WAREHOUSE IF EXISTS SMALL_WH;

USE WAREHOUSE COMPUTE_WH;

-------------
-- tables
-------------
USE DATABASE LA_DB;
USE SCHEMA LA_SCHEMA;


CREATE TABLE PERMANENT_TABLE (
  ID NUMBER,
  NAME VARCHAR,
  DOB DATE
);

CREATE TRANSIENT TABLE TRANSIENT_TABLE (
  ID NUMBER,
  NAME VARCHAR,
  DOB DATE
);

CREATE TEMPORARY TABLE TEMPORARY_TABLE (
  ID NUMBER,
  NAME VARCHAR,
  DOB DATE
);

SHOW TABLES;

INSERT INTO PERMANENT_TABLE VALUES (1, 'John', '2022-01-01');
INSERT INTO TRANSIENT_TABLE VALUES (2, 'Jane', '2022-01-02');
INSERT INTO TEMPORARY_TABLE VALUES (4, 'Jill', '2022-01-04');


SELECT * FROM PERMANENT_TABLE;
SELECT * FROM TRANSIENT_TABLE;
SELECT * FROM TEMPORARY_TABLE;

CREATE TEMPORARY TABLE TEMPORARY_TABLE2 CLONE PERMANENT_TABLE;
SELECT * FROM TEMPORARY_TABLE2;

CREATE TRANSIENT TABLE TRANSIENT_TABLE2 CLONE PERMANENT_TABLE;
SELECT * FROM TRANSIENT_TABLE2;

CREATE TEMPORARY TABLE TEMPORARY_TABLE3 CLONE TRANSIENT_TABLE;


-- alter retention time
ALTER TABLE PERMANENT_TABLE SET DATA_RETENTION_TIME_IN_DAYS = 31;
ALTER TABLE TEMPORARY_TABLE2 SET DATA_RETENTION_TIME_IN_DAYS = 32; -- execution will fail
ALTER TABLE TRANSIENT_TABLE SET DATA_RETENTION_TIME_IN_DAYS = 0;

SHOW TABLES like '%TRANSIENT_TABLE%';

DESCRIBE TABLE TRANSIENT_TABLE;

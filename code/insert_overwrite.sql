-- Create a sample table 
CREATE OR REPLACE TABLE employees (
  id INT,
  name VARCHAR(255),
  department VARCHAR(255)
);

-- Insert rows
INSERT INTO employees (id, name, department) VALUES
(1, 'John Doe', 'Engineering'),
(2, 'Jane Doe', 'Sales');


-- This will overwrite the existing data in the employees table with the new data from the select statement.
INSERT  OVERWRITE INTO employees  SELECT id, name, department FROM employees WHERE department = 'Engineering';

SELECT * FROM employees;

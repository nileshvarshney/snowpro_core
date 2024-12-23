CREATE OR REPLACE TABLE car_sales
( 
  src variant
)
AS
SELECT PARSE_JSON(column1) AS src
FROM VALUES
('{ 
    "date" : "2017-04-28", 
    "dealership" : "Valley View Auto Sales",
    "salesperson" : {
      "id": "55",
      "name": "Frank Beasley"
    },
    "customer" : [
      {"name": "Joyce Ridgely", "phone": "16504378889", "address": "San Francisco, CA"}
    ],
    "vehicle" : [
      {"make": "Honda", "model": "Civic", "year": "2017", "price": "20275", "extras":["ext warranty", "paint protection"]}
    ]
}'),
('{ 
    "date" : "2017-04-28", 
    "dealership" : "Tindel Toyota",
    "salesperson" : {
      "id": "274",
      "name": "Greg Northrup"
    },
    "customer" : [
      {"name": "Bradley Greenbloom", "phone": "12127593751", "address": "New York, NY"}
    ],
    "vehicle" : [
      {"make": "Toyota", "model": "Camry", "year": "2017", "price": "23500", "extras":["ext warranty", "rust proofing", "fabric protection"]}  
    ]
}') v;

select 
    cust.value:name::varchar customer_name,
    cust.value:address::varchar customer_address,
    cust.value:phone::varchar customer_phone_num,
    src:dealership::string dealership,
    src:date::date purchase_date,
    src:salesperson.id::integer salesman_id,
    src:salesperson.name::varchar salesman_name,
    v.value:make::varchar make,
    v.value:model::varchar model, 
    v.value:price::float price,
    v.value:year::integer year,
    ex.value::varchar extras
from car_sales cs, LATERAL FLATTEN(INPUT => src:customer) cust,
LATERAL FLATTEN(INPUT => src:vehicle) v,
LATERAL FLATTEN(INPUT => v.value:extras) ex

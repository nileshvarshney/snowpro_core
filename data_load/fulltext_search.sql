WITH cars as(
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
)
SELECT 
    *
FROM cars WHERE SEARCH(customer_address, 'ny')

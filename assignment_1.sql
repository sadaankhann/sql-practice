-- 1.1. Write a query that selects product_name, list_price, and a calculated column price_in_thousands (list_price divided by 1000) from production.products.

select 
	p.product_name, p.list_price / 1000.0 "Price in thousands" 
from production.products p;

-- 1.2. Write a query that returns the distinct list of state values from sales.customers.

select distinct 
    state 
from sales.customers;

-- 1.3. Write a query that returns the 5 cheapest products, showing product_name and list_price, sorted appropriately.

select top 5 
    p.product_name, 
    p.list_price 
from production.products p
order by p.list_price asc;

-- 1.4. Write a query that returns products priced between 200 and 600, where the category is either 1 or 6. Use BETWEEN and IN together.

select 
	p.product_name, 
	p.list_price 
from production.products p 
where p.list_price between 200 and 600 and p.category_id in(1,6);

-- 1.5. The following query is meant to find affordable mountain or road bikes (categories 1 and 6) under $1000, but it has a bug. Identify it and rewrite it correctly:

SELECT product_name, category_id, list_price
FROM production.products
WHERE (category_id = 1 OR category_id = 6) AND list_price < 1000;

-- 1.6. Write a query that finds all customers whose email ends in .com and whose last_name starts with the letter "M".

select 
	c.first_name + ' ' + c.last_name, c.email 
from sales.customers c 
where c.last_name like 'M%' 
and 
c.email like '%.com';

-- 1.7. Write a query that returns the 11th through 20th most expensive products using OFFSET...FETCH.

select 
	p.product_name,
	p.list_price 
from production.products p
order by p.list_price desc
offset 10 rows fetch next 10 rows only;

-- 1.8. Think About It: A junior engineer writes WHERE discount <> NULL to find order items with a defined discount, and the query returns zero rows even though the table clearly has non-null discount values. Explain why, using three-valued logic, and write the correct version.

/* SQL uses three valued logic, Every conditional statement evaluates to either true, false or 
unknown. If we talk about null it can seen as a value whose value is missing or undefined, 
when we write where discount <> NULL, sql compares every field value with this null so
for example for a field discount is 5, so the condition would be 5 <> NULL, so sql can not
classify it as false because the actual value of the null is not known so it can be 5 and cannot 
be, So it will classify it as UNKNOWN and same for every field and will get zero rows in the 
answer even if rows exist, So for such queries we should use 'IS NOT NULL', This will work 
perfectly and give the suitable rows based on the condition. */
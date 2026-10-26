-- 2.1. Write a query that lists every product with its brand name, using production.products and production.brands.

select p.product_name, b.brand_name 
from production.products p
left join production.brands b
on p.brand_id = b.brand_id;

-- 2.2. Using a LEFT JOIN, write a query that finds every store with zero staff currently assigned to it.

select sto.store_name
from sales.stores sto
left join sales.staffs sta
on sto.store_id = sta.store_id
where sta.store_id is null;

-- 2.3. Explain, in your own words, why the following query returns every product regardless of stock level, and rewrite it so that it only returns products with fewer than 5 units in stock at store 1:


SELECT p.product_name, s.quantity
FROM production.products AS p
INNER JOIN production.stocks AS s
   ON p.product_id = s.product_id AND s.quantity < 5 AND s.store_id = 1;


/* The reason this query was not working okay was that because we were using left join, and we
know that the left join will give us the output for each and every row for the first table
if even the values doesnot exist, So to get only the values that are present on both sides we will \
use inner join
*/

/* 2.4. Write a self join on sales.staffs that lists every manager along with a count placeholder
column showing 1 for each employee they manage (you will replace this with a real COUNT in 
Chapter 3); for now, just produce one row per employee-manager pair. */

select 
	mgr.first_name as "Manager Name", 
	sta.first_name as "Staff Name" ,
	1 as "Count Placeholder"
from sales.staffs sta
inner join sales.staffs mgr
on sta.manager_id = mgr.staff_id;

/* 2.5. Write a three-table join across sales.orders, sales.order_items, and production.products 
that lists every item in order #1, including product name and quantity. */

select
	ord.order_id ,
	ord_ite.quantity,
	pro.product_name
from sales.orders ord
left join sales.order_items ord_ite 
	on ord.order_id = ord_ite.order_id  
inner join production.products pro
	on pro.product_id = ord_ite.product_id
where ord.order_id = 1;

/* 2.6. A colleague joins orders to order_items and reports "we received 4,658 orders last year.
" Explain what actually went wrong with that number and how you would find the true order count 
instead.
 */


/* We dont have to join the orders with the order_items cause if we do that it will count the items that we have ordered in each order and that will obviously make the output count 
large, We just have to count the order_id from orders table only */

select count(order_id) AS total_orders
from sales.orders
where year(order_date) = 2017;

--  Think About It: CROSS JOIN is often considered dangerous because it can accidentally produce millions of rows from two innocent-looking tables. Under what real circumstances would you deliberately want a CROSS JOIN, and how would you guard against using one by accident, for example, by forgetting an ON clause that was meant to be there?

/* If I dont know how many rows will I get if I run cross join, Even if I run it by mistake when I 
want to use some other join and by mistake I forgot to use the on clause, So before running any cross join
query we should select the query first and press ctrl + l and get the execution plan, From there we can 
see how many rows will be expected to get if I run that. */
select
    first_name as "First Name",
    last_name as "Last Name",
    email as "Email",
    city as "City"
from sales.customers
where state = 'ny'
  and phone is null
order by last_name, first_name
offset 0 rows fetch next 10 rows only;

-- q2

select
    product_id,
    product_name,
    model_year,
    list_price
from production.products
where model_year in (2017, 2018)
  and list_price between 500 and 1500
  and product_name like '%trek%'
  and product_name not like '%kids%'
order by list_price desc;

-- q3 (a)

select distinct
    order_status
from sales.orders;

-- q3 (b)

select
    order_id,
    customer_id,
    store_id,
    order_date,
    required_date
from sales.orders
where shipped_date is null
  and store_id in (1, 3)
  and order_date >= '2018-01-01'
  and order_date < '2019-01-01'
order by order_date;

-- q4 

select
    o.order_id,
    o.order_date,
    concat(c.first_name, ' ', c.last_name) as customer_full_name,
    p.product_name,
    b.brand_name,
    cat.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) as line_revenue
from sales.orders o
inner join sales.customers c
    on o.customer_id = c.customer_id
inner join sales.order_items oi
    on o.order_id = oi.order_id
inner join production.products p
    on oi.product_id = p.product_id
inner join production.brands b
    on p.brand_id = b.brand_id
inner join production.categories cat
    on p.category_id = cat.category_id
where o.order_id = 1;

-- q5

select
    s.staff_id,
    s.first_name,
    s.last_name,
    st.store_name,
    coalesce(
        concat(m.first_name, ' ', m.last_name),
        'No Manager'
    ) as manager_name
from sales.staffs s
inner join sales.stores st
    on s.store_id = st.store_id
left join sales.staffs m
    on s.manager_id = m.staff_id;

-- q6


select
    s.staff_id,
    s.first_name,
    s.last_name,
    st.store_name,
    coalesce(
        concat(m.first_name, ' ', m.last_name),
        'No Manager'
    ) as manager_name
from sales.staffs s
inner join sales.stores st
    on s.store_id = st.store_id
left join sales.staffs m
    on s.manager_id = m.staff_id;


-- q7 (a)


create view sales.vw_order_line_details
as
select
    o.order_id,
    o.order_date,
    concat(c.first_name, ' ', c.last_name) as customer_full_name,
    p.product_name,
    b.brand_name,
    cat.category_name,
    oi.quantity,
    oi.list_price,
    oi.discount,
    oi.quantity * oi.list_price * (1 - oi.discount) as line_revenue,
    st.store_name,
    o.order_status
from sales.orders o
inner join sales.customers c
    on o.customer_id = c.customer_id
inner join sales.order_items oi
    on o.order_id = oi.order_id
inner join production.products p
    on oi.product_id = p.product_id
inner join production.brands b
    on p.brand_id = b.brand_id
inner join production.categories cat
    on p.category_id = cat.category_id
inner join sales.stores st
    on o.store_id = st.store_id;


-- q7 (b)

select *
from sales.vw_order_line_details
where order_date >= '2018-01-01'
  and order_date < '2018-02-01'
order by order_date, order_id;

-- q8 (a)

create view production.vw_product_catalog
as
select
    p.product_id,
    p.product_name,
    b.brand_name,
    c.category_name,
    p.model_year,
    p.list_price
from production.products p
inner join production.brands b
    on p.brand_id = b.brand_id
inner join production.categories c
    on p.category_id = c.category_id;


-- q8 (b)

select *
from production.vw_product_catalog
where category_name = 'electric bikes'
  and list_price > 3000
order by list_price desc;

-- q9

select
    store_name,
    year(order_date) as order_year,
    count(distinct order_id) as total_orders,
    sum(line_revenue) as total_revenue
from sales.vw_order_line_details
group by
    store_name,
    year(order_date)
order by
    store_name,
    order_year;


-- q10

select
    b.brand_name,
    count(p.product_id) as total_products,
    min(p.list_price) as minimum_price,
    avg(p.list_price) as average_price,
    max(p.list_price) as maximum_price
from production.brands b
inner join production.products p
    on b.brand_id = p.brand_id
group by b.brand_name
having count(p.product_id) > 10
order by average_price desc;

-- q11

select
    p.product_name,
    c.category_name,
    p.list_price,
    (
        select avg(p2.list_price)
        from production.products p2
        where p2.category_id = p.category_id
    ) as category_average_price
from production.products p
inner join production.categories c
    on p.category_id = c.category_id
where p.list_price > (
    select avg(p2.list_price)
    from production.products p2
    where p2.category_id = p.category_id
);

-- q 12

select
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) as full_name,
    c.email,
    c.state
from sales.customers c
where exists (
    select 1
    from sales.orders o
    where o.customer_id = c.customer_id
      and o.order_date >= '2016-01-01'
      and o.order_date < '2017-01-01'
)
and not exists (
    select 1
    from sales.orders o
    where o.customer_id = c.customer_id
      and o.order_date >= '2018-01-01'
      and o.order_date < '2019-01-01'
);

-- q13

with store_revenue as (
    select
        store_name,
        sum(line_revenue) as total_revenue
    from sales.vw_order_line_details
    group by store_name
),
average_revenue as (
    select
        avg(total_revenue) as average
    from store_revenue
)
select
    sr.store_name,
    sr.total_revenue,
    ar.average,
    sr.total_revenue - ar.average as difference
from store_revenue sr
cross join average_revenue ar
where sr.total_revenue > ar.average;

-- q14


with staff_hierarchy as (
    -- anchor member
    select
        staff_id,
        first_name,
        last_name,
        manager_id,
        1 as level,
        cast(
            concat(first_name, ' ', last_name)
            as varchar(max)
        ) as reporting_path
    from sales.staffs
    where manager_id is null

    union all

    -- recursive member
    select
        s.staff_id,
        s.first_name,
        s.last_name,
        s.manager_id,
        sh.level + 1,
        cast(
            concat(
                sh.reporting_path,
                ' > ',
                s.first_name,
                ' ',
                s.last_name
            )
            as varchar(max)
        )
    from sales.staffs s
    inner join staff_hierarchy sh
        on s.manager_id = sh.staff_id
)
select
    staff_id,
    concat(first_name, ' ', last_name) as staff_full_name,
    manager_id,
    level,
    reporting_path
from staff_hierarchy
order by level, staff_id
option (maxrecursion 100);


-- q15(a)

with product_revenue as (
    select
        cat.category_name,
        p.product_name,
        sum(oi.quantity) as total_quantity,
        sum(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) as total_revenue
    from sales.orders o
    inner join sales.order_items oi
        on o.order_id = oi.order_id
    inner join production.products p
        on oi.product_id = p.product_id
    inner join production.categories cat
        on p.category_id = cat.category_id
    where o.order_date >= '2017-01-01'
      and o.order_date < '2018-01-01'
    group by
        cat.category_name,
        p.product_id,
        p.product_name
),
ranked_products as (
    select
        category_name,
        product_name,
        total_quantity,
        total_revenue,
        row_number() over (
            partition by category_name
            order by total_revenue desc
        ) as product_rank
    from product_revenue
)
select
    category_name,
    product_name,
    total_quantity,
    total_revenue,
    product_rank
from ranked_products
where product_rank <= 3
order by category_name, product_rank;

-- q15(b)

with months as (
    -- anchor member
    select 1 as month_number

    union all

    -- recursive member
    select month_number + 1
    from months
    where month_number < 12
),
monthly_sales as (
    select
        month(o.order_date) as month_number,
        count(distinct o.order_id) as total_orders,
        sum(
            oi.quantity * oi.list_price * (1 - oi.discount)
        ) as total_revenue
    from sales.orders o
    left join sales.order_items oi
        on o.order_id = oi.order_id
    where o.order_date >= '2017-01-01'
      and o.order_date < '2018-01-01'
    group by month(o.order_date)
)
select
    m.month_number,
    datename(
        month,
        datefromparts(2017, m.month_number, 1)
    ) as month_name,
    coalesce(ms.total_orders, 0) as total_orders,
    coalesce(ms.total_revenue, 0) as total_revenue
from months m
left join monthly_sales ms
    on m.month_number = ms.month_number
order by m.month_number
option (maxrecursion 12);

















































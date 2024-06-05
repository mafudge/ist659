use fudgemart_v3
GO
with source as  (
    select v.*, product_department, product_id
        from fm_vendors v join fm_products p on v.vendor_id = p.product_vendor_id
        where product_department != 'Housewares'
)
select * from source pivot ( 
    count(product_id) for product_department in 
        ([Clothing],[Electronics], [Hardware],[Sporting Goods])
) as pvt


drop index if exists ix_product_department on fm_products
create index ix_product_department on fm_products(product_department)
    include (product_vendor_id)
go

drop index if exists ix_product_department on fm_products
drop index if exists ix_product_vendor_id on fm_products
create index ix_product_vendor_id on fm_products(product_vendor_id)
    include (product_department) 

select distinct product_department from fm_products

use payroll
go
-- # 1 

select employee_id, employee_firstname, employee_lastname, employee_jobtitle
    from employees 
    where employee_jobtitle = 'Store Manager'
        or employee_jobtitle = 'Owner'

GO
drop index if exists ix_employee_jobtitle on employees
go
create index ix_employee_jobtitle on employees(employee_jobtitle)
    include (employee_firstname, employee_lastname)
GO

-- # 2
select employee_jobtitle, count(*)
    from employees
    group by employee_jobtitle


go
use vbay
go



-- #3 convert the following query to a schemabound view:
select item_id, item_name, 
    dense_rank() over 
        ( partition by item_name order by bid_datetime) as bid_order,
    bid_amount, 
    lag(user_firstname + ' ' + user_lastname) over 
        (partition by item_name order by bid_datetime) as prev_bidder,
    user_firstname + ' ' + user_lastname as bidder,
    lead(user_firstname + ' ' + user_lastname) over 
        (partition by item_name order by bid_datetime) as next_bidder
    from vb_items 
        join vb_bids on item_id=bid_item_id
        join vb_users on bid_user_id = user_id
    where bid_status='ok'

-- #4 improve performance

drop index if exists  ix_bids_bid_status on vb_bids
go
create index ix_bids_bid_status on vb_bids(bid_status)
    include (bid_item_id, bid_user_id, bid_amount, bid_datetime)



-- # 5
use fudgemart_v3
GO

drop view if exists v_orders 
go
create view v_orders 
    with SCHEMABINDING AS
    select  c.customer_state, c.customer_firstname + ' ' + c.customer_lastname as customer_name,
    datepart(year,order_date) as order_year, o.order_id, o.ship_via,
    od.order_qty as order_detail_qty, od.order_qty * p.product_retail_price as order_detail_extd_price,
    p.product_id, p.product_name, p.product_department  
        from dbo.fm_orders o
        join dbo.fm_customers c on o.customer_id = c.customer_id
        join dbo.fm_order_details od on o.order_id = od.order_id
        join dbo.fm_products p on p.product_id = od.product_id
GO


-- # 6 
drop index if exists cix_v_orders on v_orders
go
create unique clustered index cix_v_orders on v_orders(order_id,product_id) 
go
select * from v_orders with (noexpand)


-- # 7 
create COLUMNSTORE 
    index ix_v_orders 
        on v_orders(customer_state, customer_name, order_year, order_id, ship_via, order_detail_qty, order_detail_extd_price, product_id, product_name, product_department)
GO


select product_name, sum(order_detail_qty)
    from v_orders  with (noexpand)
    group by product_name

select distinct customer_name, product_department
    from v_orders with (noexpand)

go

with source as (
    select customer_name, order_year, order_detail_extd_price
        from v_orders with (noexpand)
)
select * from source 
    pivot (sum(order_detail_extd_price) for order_year in ([2009],[2010],[2011],[2012])) as pvt


--- Table
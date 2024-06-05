--Find the name and emails of customers in New York
select 
    customer_email, customer_firstname, customer_lastname, customer_state
from fm_customers
    where customer_state = 'NY'


--Show me the last 10 orders and include the customer’s name and email address with the order. 
select top 10 ...

---


-- for product id #1 display the person who made the review the number of stars in the review,
-- and the name of the product that got reviewed.
select c.customer_id, c.customer_firstname, c.customer_lastname, cpr.*, p.product_name
    from fm_customer_product_reviews cpr
        join fm_customers c on cpr.customer_id = c.customer_id
        join fm_products p on cpr.product_id = p.product_id
    where cpr.product_id = 1 
 
-- who are the people (names please of those who didn't review the Straight Claw hammer?)
select customer_id, customer_firstname, customer_lastname from fm_customers
except 
select c.customer_id, c.customer_firstname, c.customer_lastname
    from fm_customer_product_reviews cpr
        join fm_customers c on cpr.customer_id = c.customer_id
        join fm_products p on cpr.product_id = p.product_id
    where cpr.product_id = 1 
 

-- show me the names and websites of vendors who do not supply any products.
-- will need an outer join 

select *
   from fm_vendors
   join fm_vendors on fm_products on vendor_id = product_vendor_id

-- show me the names and websites of vendors who do not supply any products.
-- will need an outer join 
select fm_vendors.*, product_id
    from fm_products 
        right join fm_vendors on vendor_id = product_vendor_id
    where product_id is null 
 
select fm_vendors.*, product_id
    from  fm_vendors
        left join fm_products on vendor_id = product_vendor_id
    where product_id is null 


-- Product recall on crock pots product id = 39 I need a list of everyone who bought it.
-- names and emails. 


select customer_firstname, customer_lastname, customer_email, product_id
   from fm_customers as c
   join fm_orders as o on c.customer_id = o.customer_id
   join fm_order_details as od on o.order_id = od.order_id
   where product_id='39'

-- Product recall on crock pots product id = 39 I need a list of everyone who bought it.
-- names and emails. 
 
select customer_firstname, customer_lastname, customer_email, product_id,
     c.customer_id as cust_id, o.customer_id as order_cust_id, o.order_id, od.order_id
   from fm_customers as c
    join fm_orders as o on c.customer_id = o.customer_id
    join fm_order_details as od on o.order_id = od.order_id
   where product_id='39'
-- customers or products without reviews
-- since there are no matches, I manually add a product,
-- could do the same with a customer, I'm just lazy.
 
delete from fm_products where product_name ='Mike Socks'
insert into fm_products 
    (product_department, product_name, product_retail_price, 
    product_wholesale_price, product_is_active, product_add_date,
    product_vendor_id)
values ('Clothing','Mike Socks', 5,3, 1, '2020-09-14', 1)
 
 
select r.customer_id, r.product_id, p.*, c.* 
    from fm_customer_product_reviews r
        full join fm_customers c on c.customer_id = r.customer_id
        full join fm_products p on p.product_id = r.product_id
    where r.product_id is null or r.customer_id is null 


select student_firstname, student_lastname, student_major_id, student_year_name
    from students
    where student_year_name = 'Freshman'


drop index if exists ix_something on students 
create index ix_something on students(student_year_name) 
    include (student_firstname, student_lastname,student_major_id)


use fudgemart_v3
go


select employee_department, 
    count(*) employee_count, 
    avg(employee_hourlywage) as avg_hourly_wage
    from fm_employees
    group by employee_department
go
with a as (
    select employee_department, 
    count(*) employee_count
    from fm_employees
    group by employee_department
)
select a.employee_department, a.employee_count, avg(e.employee_hourlywage)
    from a 
    join fm_employees e on a.employee_department = e.employee_department
    group by a.employee_department , a.employee_count

drop index if exists ix_example on fm_employees
create index ix_example on fm_employees(employee_department) include(employee_hourlywage)

GO
select customer_email, ship_via, sum(d.order_qty) total_order_qty
from fm_customers c
    join fm_orders o 
        on c.customer_id= o.customer_id
    join fm_order_details d on d.order_id = o.order_id
group by customer_email, ship_via 

create index ix_orderdetails1 on fm_order_details(order_id)
include (order_qty)

create index ix_order1 on fm_orders(customer_id) 
include (ship_via)

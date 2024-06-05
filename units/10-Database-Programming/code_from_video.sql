use fudgemart_v3
go

with source as  (
    select order_id, customer_id, datename(WEEKDAY, order_date) as order_dow
    from fm_orders
)
select * from source pivot (
    count(order_id) for order_dow in ([Sunday], [Monday],[Tuesday],[Wednesday])
) as pvt



use fudgemart_v3
GO
select *, isnull(vendor_website, 'NO WEBSITE') as vendor_website2
from fm_vendors

select customer_state, 
    count(*) as customer_count, 
    string_agg(customer_email, '   ') as emails
from fm_customers
group by customer_state

declare @text varchar(100)
set @text = 'tom,dick,harry'
select value as names
    from string_split(@text,',')

select product_id, product_name, value
    from fm_products cross apply string_split(product_name,' ')
    where value = 'Hammer'


use payroll
go
GO
drop procedure if exists p_transfer_employee
go 
create procedure p_transfer_employee (
    @empid int,
    @dept varchar(20)
) as BEGIN
    declare @supid int 
    select @supid = employee_id
        from employees
        where employee_jobtitle = 'Department Manager'
        and employee_department = @dept

    update employees 
        set employee_department = @dept,
        employee_supervisor_employee_id = @supid
        where employee_id=@empid
END
go

select * from employees where employee_id= 65
EXEC p_transfer_employee @empid = 65, @dept = 'Clothing'
select * from employees where employee_id= 65


use payroll

drop trigger if exists t_employees_demo
go
create trigger t_employees_demo
on employees
after insert, update, delete
as BEGIN
    select 'INSERTED:', * from inserted 
    select 'DELETED:', * from deleted 
END

update employees set employee_lastname = 'Fudgeeeeeeee' where employee_id=1

GO
use payroll
go
drop trigger if exists t_employees_update_department
go
create trigger t_employees_update_department
on employees
after insert, update
as BEGIN
    update employees
        set employee_department = inserted.employee_department,
        employee_supervisor_employee_id= (select employee_id 
            from employees 
            where employee_jobtitle = 'Department Manager'
            and employee_department = inserted.employee_department)
    from inserted 
    where employees.employee_id = inserted.employee_id 
END

select * from employees where employee_id > 65
update employees set employee_department = 'Clothing' where employee_id > 65
select * from employees where employee_id > 65


GO
use payroll
go
drop function if exists f_get_manager 
go
create function f_get_manager ( 
        @department varchar(100)
) returns int AS
BEGIN
    declare @sup_id INT
    set @sup_id = (
    select employee_id 
        from employees
        where employee_jobtitle = 'Department Manager'
        and employee_department = @department
    )
    RETURN @sup_id
END
GO

select dbo.f_get_manager('Customer Service')

GO
drop function if exists f_my_paychecks
go
create function f_my_paychecks(
    @empid int
) returns table as
return  
    select * from v_payroll where employee_id = @empid
GO

-- NO
select * from employees cross apply dbo.f_my_paychecks(employee_id)

-- YES
select * from dbo.f_my_paychecks(56)
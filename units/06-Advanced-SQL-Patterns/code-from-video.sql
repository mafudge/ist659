use demo
GO

select 'bacon' as food
union ALL
select 'cheese' as something
union ALL
select 'eggs' as other
order by food

select 'mike' as name, 48 as age, 1
union ALL
select 'bob' as age, 23 as age, null
union all
select 'mike' as name, 48 as age, 1
union ALL
select 'bob' as age, 23 as age, null

select 'mikeazon' as products, count(*) as count from mikeazon_products  
union all
select 'fudgemart', count(*) as fudgmart_count from fudgemart_products
union all 
select 'combined', count(*) as combined_count from (
    select product_name from mikeazon_products 
    intersect
    select product_name from fudgemart_products 
) as combined 

select 'mikeazon' as source, product_name  from (
    select product_name from mikeazon_products
    EXCEPT
    select product_name from fudgemart_products
) as mike_not_fudge
union 
select 'fudgemart', product_name from  (
    select product_name from fudgemart_products
    EXCEPT
    select product_name from mikeazon_products
) as fudge_not_mike

use payroll
go
with pivot_source as (
    select employee_department, 
        left( cast(paycheck_payperiod_id as varchar),4) as year, 
        paycheck_gross_pay
        from paychecks
            join employees on employee_id = paycheck_employee_id
)
select employee_department, [2018], [2019], [2020]  
    from pivot_source pivot (
    sum(paycheck_gross_pay) for year in ([2018], [2019], [2020], [2021], [2022])
) as pivot_table

with pivot_source as  (
    select employee_id, employee_firstname + ' ' + employee_lastname as employee_name,
        paycheck_total_hours_worked, 
        substring(cast(paycheck_payperiod_id as varchar),5,2) as month
        from employees
            join paychecks on paycheck_employee_id = employee_id 
        where left(cast(paycheck_payperiod_id as varchar),4) = '2019'
        and paycheck_employee_payroll_type = 'Hourly'
)
select * from pivot_source pivot (
    sum(paycheck_total_hours_worked) for month in 
        ([01],[02],[03],[04],[05],[06],[07],[08],[09],[10],[11],[12])
) as pivot_table 

use demo
GO
select * 
    from contacts
        where home_phone like '415-%'
        or mobile_phone like '415-%'
        -- Dont Repeat Yourself = DRY!


with new_contacts as (
    select * from contacts unpivot (
        phone_number for phone_type in (home_phone, mobile_phone, work_phone, other_phone)
    ) as unpivot_table
)
select * from new_contacts where phone_number like '415-%'


GO

drop view if exists v_contacts
go 
create view v_contacts as 
    select * from contacts unpivot (
        phone_number for phone_type in (home_phone, mobile_phone, work_phone, other_phone)
    ) as unpivot_table


GO

select * from v_contacts
    where phone_number like '%9'

go

select * from contacts

update contacts set mobile_phone='316-555-3305', work_phone='415-555-5567', other_phone = NULL
    where contact_id = 1

select * from v_contacts where phone_number like '316-%'

select * from books 

ALTER TABLE books ADD   
    valid_from datetime2 (2)  GENERATED ALWAYS AS ROW START     
        constraint df_books_valid_from DEFAULT DATEADD(second, -1, SYSUTCDATETIME()),  
    valid_to datetime2 (2)  GENERATED ALWAYS AS ROW END 
        constraint df_books_valid_to DEFAULT '9999.12.31 23:59:59.99',  
    PERIOD FOR SYSTEM_TIME (valid_from, valid_to)   
go
 ALTER TABLE books SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.books_history)); 
GO


select * from books
select * from books_history

update books set book_retail_price = 19.95 where book_id =1

delete from books_history

select * from stocks
select * from stocks for system_time as of '2020-04-05'
select * from stocks for system_time all
    where ticker = 'AAPL'
    order by valid_from 

select * from stocks for system_time BETWEEN 
    '2020-04-02 12:00' and '2020-04-03 12:00'
    where ticker = 'AAPL'

select * 
    from stocks for system_time contained  in ('2020-04-02 12:00','2020-04-04 12:00')
    where ticker = 'AAPL'

    select * from books 
select * from books_history
GO
alter table books set (system_versioning=off)
go

update books_history set book_author_first_name = 'Sunny' where book_id =1 
GO
alter table books set (system_versioning=on (history_table = dbo.books_history))
GO

alter table books set (system_versioning=off)
go
alter table books set (system_versioning=on (history_table = dbo.books_history_2020))
GO
select * from books_history_2020
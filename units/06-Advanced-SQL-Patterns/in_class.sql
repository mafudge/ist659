with table1 as (
    select 5 as col1, 'Y' as available
    union ALL
    select 2, 'Y'
    union all 
    select 3, 'N'
),
table2 as (
    select 3 as col1, 'N/A' as available
    union all
    select 3, 'N/A' as available
    union ALL
    select 4, 'N/A' as available
)
select * from table1
union 
select * from table2
order by col1 desc 

use northwind
go

with source as (
select ShipCountry, 
    cast(month(OrderDate) as varchar) + '-' + datename(mm,OrderDate) as month_name,
    OrderID
from orders 
where year(OrderDate) = 1996 
)
select * 
from source pivot ( count(OrderID) for month_name in ("7-July","8-August","9-September") ) as pivot_table


with source as (
    select LastName as [Last], cast(FirstName as nvarchar(20)) as [First]
    from Employees    
)
select *
from source UNPIVOT ( [Name] for [Type] in ([Last], "First")) as unpivot_table
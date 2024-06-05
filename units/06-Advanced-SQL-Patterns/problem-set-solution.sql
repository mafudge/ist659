use vbay

-- let's get a list of users who are not buyers or sellers.
select * from vb_users
    except 
select * from (
    select vb_users.* from vb_items join vb_users on item_seller_user_id = user_id 
        union 
    select vb_users.* from vb_items join vb_users on item_buyer_user_id = user_id 
)as buyers_sellers

-- SETS:
/* 1. the GIS department would like to get a list of latitudes and longitudes of those users who
make valid bids on items and also review users. These are considered active participants in the platform.
*/
go
use vbay
GO
with dataset as (
    select u.* from vb_users u join vb_bids b on u.user_id=b.bid_user_id
        where b.bid_status='ok'
    intersect 
    SELECT u.* from vb_users u join vb_user_ratings r on r.rating_by_user_id = u.user_id
)
select * from dataset join vb_zip_codes on user_zip_code=zip_code

/* 2. Northwind Traders would like to send out holiday cards to employees, customers and suppliers. 
Create a single mailing list from these sources. The mailing address should have 4 lines: 
1) customer name and title, 2) company, 3) address, City, Region, Country, postal code a line0 
column should be added to keep track of which individuals are custoemrs, employees or suppliers */
use northwind
go
select 
    'suppliers' as line0,
    ContactName + ' ' + ContactTitle as line1, 
    CompanyName as line2, 
    Address as line3,
    case when Region is null 
        then  City + ' '  + Country + ' ' + PostalCode 
    else  City + ' ' + Region + ' '  + Country + ' ' + PostalCode end as line4 
    from Suppliers
union 
select 
    'customers' as line0,
    ContactName + ' ' + ContactTitle as line1, 
    CompanyName as line2, 
    Address as line3,
    City + ' ' + isnull(Region,'') + ' '  + Country + ' ' + PostalCode as line4 
    from Customers
union 
select 'employees' as line0,
    FirstName + ' ' + LastName + ' ' +Title as line1,
    'Northwind Traders' as line2,
    Address as line3,
    City + ' ' + isnull(Region,'') + ' '  + Country + ' ' + PostalCode as line4 
    from Employees

-- PIVOT
/* 3. vbay would like a list of items with id name and type along with a count of bids with bid
type (ok, low_bid, item_seller).
*/
use vbay
GO
with source as (
    select item_id, item_name, item_type,
    --  case 
    --     when  bid_status = 'ok' then 'Ok'
    --     when bid_status = 'low_bid' then 'Bid Was Low'
    --     when bid_status = 'item_seller' then 'Seller Bid On Own Item'
    --     end as bid_status
        bid_status 
        from vb_items join vb_bids on item_id = bid_item_id
)
select item_name, item_type, ok as "Ok", low_bid as "Low A Dabadia" from source pivot (
    count(item_id) for bid_status in (ok,low_bid)    
) as pivot_table

/* 4. Northwind traders has 3 different shippers. For each customer ID and CompanyName list the total amount of shipping Frieght 
paid for each of the three different shippers. There should be a column for each shipper.
*/
use northwind
GO
with source as  (
    select c.CustomerID, c.CompanyName, o.Freight, s.CompanyName as Shipper
        from Customers c
            join Orders o on c.CustomerID = o.CustomerID
            join Shippers s on s.ShipperID = o.ShipVia
)
select * from source pivot (
    sum(Freight) for Shipper in ([Federal Shipping],[Speedy Express],[United Package])
) as pivot_table

-- UNPIVOT
/* 5. Unpivot all the dates in the Northwind order table, creating a table-valued expression with three columns:
order id, type of date (ship date, require date, order date) and the date itself  
*/
use northwind
go

select OrderID, DateType, DateValue from Orders unpivot (
    DateValue for DateType in (OrderDate,RequiredDate,ShippedDate)
) as unpivot_table

/* 6. Unpivot the fudgeflix titles which are just Movies  so that is it easier to query titles which are available in different
 formats such as instant, dvd, and blu-ray. Flatten these three columns into a single column with types, but only
 include a row when the value is 1 in the column. Include the title id and name
*/

use fudgeflix_v3
go
with source as (
    select * 
    from ff_titles UNPIVOT (
        format_value for format_name in (title_bluray_available, title_dvd_available, title_instant_available)
    
    ) 
    as foo
)
select title_id, title_name, format_name,  format_value 
    from source 
        where format_value=1 and title_type = 'Movie'


-- TEMPORAL
use payroll
go
/* 7. Get a list of the employees from the payroll database as they were on May 31, 2018' */
select * 
    from employees for system_time as of '2018-05-31'
    order by employee_hire_date desc

/* 8. Produce a report of Gus Toffwind's pay increases in the payroll database. Include the
id, name ssn of of the employee along with pay rate, previous pay rate and pay increase */
use payroll
go
select employee_id, employee_ssn, employee_department, employee_firstname, employee_lastname, employee_pay_rate,
    lag(employee_pay_rate) over ( order by valid_from) as previous_pay_rate,
    employee_pay_rate - lag(employee_pay_rate) over ( order by valid_from) as pay_increase
    from employees for system_time all
    where employee_id=27
    order by employee_hire_date desc



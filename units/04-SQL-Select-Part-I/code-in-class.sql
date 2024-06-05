use demo
go
drop table gamble
go
create table gamble
(
    choice varchar(5),
    value int 
)

insert into gamble (choice,value)
    select 'hi', 5
    union ALL
    select 'low', 7
    union ALL
    select 'med', 3


use vbay
go


select * 
from vb_items 
where item_sold = 0 
    and item_reserve >= 250


-- original
select item_id, item_name, item_type,item_reserve,item_type,
case 
    when item_reserve >= 250 then 'High Priced Items'
    when item_reserve <= 50 then 'Low Priced Items'
    else 'Average Priced Items'
end as Category
from vb_items
where item_type <> 'All Other' and item_reserve > 50 and item_reserve < 250
go 
with item_pricing as  (
select item_id, item_name, item_type,item_reserve,
case 
    when item_reserve >= 250 then 'High Priced Items'
    when item_reserve <= 50 then 'Low Priced Items'
    else 'Average Priced Items'
end as Category
from vb_items
)
select * from item_pricing where item_type <> 'All Other' and Category = 'Average Priced Items'
GO
select * from vb_items 
    where item_name = 'Smurf TV Tray'
    or item_name = 'Alf Alarm Clock'

select * from vb_items 
    where item_name in ('Smurf TV Tray',  'Alf Alarm Clock')

select * from vb_items 
    where item_soldamount > 15
    or item_soldamount is null 


select i.item_id, i.item_name,i.item_type,i.item_soldamount,i.item_sold,
(u.user_firstname+' '+u.user_lastname) as seller_name , zc.zip_city as seller_city, zc.zip_state as seller_state,
(u2.user_firstname+' '+u2.user_lastname) as buyer_name, zc2.zip_city as buyer_city, zc2.zip_state as buyer_state
from vb_items i 
    join vb_users u on i.item_seller_user_id = u.user_id --seller
    join vb_users u2 on i.item_buyer_user_id = u2.user_id -- buyer
    join vb_zip_codes zc on zc.zip_code = u.user_zip_code --seller
    join vb_zip_codes zc2 on zc2.zip_code = u2.user_zip_code -- buyer
where i.item_sold = 1
go
with sellers as  (
    select user_id, user_firstname+' '+user_lastname as seller_name , zip_city as seller_city, zip_state as seller_state
    from vb_users join vb_zip_codes on  user_zip_code = zip_code
),
buyers as (
    select user_id, user_firstname+' '+user_lastname as buyer_name , zip_city as buyer_city, zip_state as buyer_state
    from vb_users join vb_zip_codes on  user_zip_code = zip_code
)
select *
    from vb_items 
        join sellers on item_seller_user_id = sellers.user_id
        join buyers on item_buyer_user_id = buyers.user_id



--- 10
with ids_placed_bid as (
    select distinct bid_user_id from vb_bids
), ids_of_buyers as (
    select distinct item_buyer_user_id from vb_items where item_buyer_user_id is not null
), ids_of_sellers as (
    select distinct item_seller_user_id from vb_items 
)
select * from  vb_users
    where not ( user_id in (select bid_user_id  from ids_placed_bid)
    or user_id in (select item_buyer_user_id from ids_of_buyers)
    or user_id in (select item_seller_user_id from ids_of_sellers))


-- views
go
create view ids_placed_bid as 
    select distinct bid_user_id from vb_bids

go
use tinyu
go

select student_year_name, student_major_id, count(*)
from students
group by student_year_name,student_major_id

select * from students 
    where student_gpa = (select min(student_gpa) from students)


--diff between min and first
select * from students
select min(student_gpa) from students

-- before window functions
select student_firstname, student_gpa, student_year_name, student_gpa, 
(select avg(student_gpa) from students ) as overall_avg_gpa
from students

-- after window functions
select student_firstname, student_gpa, student_year_name, student_gpa, 
avg(student_gpa) over () as overall_avg_gpa,
avg(student_gpa) over (partition by student_year_name) as avg_gpa_by_year
from students

-- ranking of students
select student_firstname, student_gpa, student_year_name, student_gpa,
rank() over (order by student_gpa desc) as overall_rank,
rank() over (partition by student_year_name order by student_gpa desc) as rank_by_year
from students

--provide names and major name and gpa and rank of student gpa by major
select student_firstname, student_lastname, major_name, student_gpa,
dense_rank() over (partition by major_name order by student_gpa desc) as rank_by_major
    from students 
    join majors  on student_major_id=major_id

-- this is ugly
select student_year_name, count(*) as student_count,
    dense_rank() over ( order by count(*) desc ) as student_count_rank
    from students 
    group by student_year_name 

go
with source as (
    select student_year_name, count(*) as student_count
    from students
    group by student_year_name
)
select *, 
    DENSE_RANK() over ( order by student_count desc ) as student_count_rank
from source 


-- counting things
select * from students 

select count(student_major_id), count(*), count(distinct student_major_id)
from students 

select student_major_id from students group by student_major_id
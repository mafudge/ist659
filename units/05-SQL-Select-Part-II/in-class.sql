-- undergrad students and gpa with avg gpa by major
use tinyu
go
-- using window functions
select student_firstname + ' ' + student_lastname as student_name,
    major_name,
    student_gpa,
    avg(student_gpa) over (partition by major_name) as gpa_avg_by_major
from students join majors 
    on student_major_id = major_id
where student_year_name != 'Graduate'
GO
-- without window functions
with by_major as (
    select avg(student_gpa) as avg_gpa_by_major, major_name
    from students join majors 
        on student_major_id = major_id
    group by major_name
)
select student_firstname + ' ' + student_lastname as student_name,
    b.major_name,
    student_gpa,
    b.avg_gpa_by_major
from students 
    join majors m on student_major_id = m.major_id 
    join by_major b on m.major_name = b.major_name
where student_year_name != 'Graduate'
GO
--without with
select student_firstname + ' ' + student_lastname as student_name,
    b.major_name,
    student_gpa,
    b.avg_gpa_by_major
from students 
join majors m on student_major_id = m.major_id 
join (select avg(student_gpa) as avg_gpa_by_major, major_name
    from students join majors 
        on student_major_id = major_id
    group by major_name)  as b
    on m.major_name = b.major_name
where student_year_name != 'Graduate'



-- example
with someting as  (
    select student_firstname, student_gpa
    from students
    where student_major_id = 3
)
select * from someting
GO
drop view if exists someting
go
create view someting as 
    select student_firstname, student_gpa
    from students
    where student_major_id = 3
go
select * from someting
go
select * from students
    order by student_gpa


go
-- ranking of students summary by year eg. not grad students
--freshman 4.0 1
--sohp    3.8 2 
with source as (
select student_year_name, avg(student_gpa) as avg_student_gpa
    from students
    where student_year_name != 'Graduate'
    group by student_year_name
)
select *, dense_rank() over(order by avg_student_gpa desc )  as rank
from source
GO
select student_year_name, avg(student_gpa) as avg_student_gpa,
    dense_rank() over (order by avg(student_gpa)) as rank 
    from students
    where student_year_name != 'Graduate'
    group by student_year_name


GO
use demo
go
select * from bbplayers
select * from bbteams
-- cartesian product
select * from bbplayers, bbteams
    where team_id = player_team_id

--full outer join
select * from bbplayers full outer join bbteams 
        on player_team_id = team_id

-- left join players with no team
select * from bbplayers left outer join bbteams 
        on player_team_id = team_id

-- same with set operator this is a left join
with joined as (
    select player_id,player_name, player_team_id, team_id, team_name 
        from bbplayers p join bbteams on p.player_team_id = team_id
),
everyone as (
select player_id,player_name, player_team_id, null as team_id, null as team_name 
    from bbplayers
)
select * from joined
UNION
select * from everyone
where player_team_id is null


use vbay
go

select user_email, count(*)  as rating_count, 
avg(cast(rating_value as float)) as avg_rating
    from vb_user_ratings
        join vb_users on user_id =  rating_for_user_id
    where rating_astype = 'Seller'
    group by user_email

-- question 5
select item_id, item_name,
    DENSE_RANK() over(PARTITION by item_id order by bid_datetime) as bid_rank,
    bid_amount, 
    user_firstname + ' ' + user_lastname as bidder
    from vb_items 
        join vb_bids on item_id=bid_item_id
        join vb_users on bid_user_id = user_id
    where bid_status='ok' and item_id = 11


/*7.	Find the names and emails of the users who give out the worst ratings
 (lower than the overall average rating) to either buyers or sellers (no need 
 to differentiate whether the user rated a buyer or seller), and only include 
 those users who have submitted more than 1 rating.
*/
with over_avg as (
    select avg(cast(rating_value as decimal))  as overall_avg
        from vb_user_ratings join vb_users on user_id = rating_by_user_id
),
source as (
select user_firstname, user_lastname, user_email
    from vb_user_ratings join vb_users on user_id = rating_by_user_id
    where rating_value < ( select overall_avg from over_avg)
)
select user_firstname, user_lastname, user_email, count(*) as row_count
 from source
 group by user_firstname, user_lastname, user_email -- other solution
 select user_email, user_firstname, user_lastname,
    count(*) as rating_count,
    avg(cast(rating_value as decimal)) as avg_rating
    from vb_user_ratings
        join vb_users on rating_by_user_id = user_id
    group by user_email, user_firstname, user_lastname
    having avg(cast(rating_value as decimal)) < 
        (select avg(cast(rating_value as decimal)) from vb_user_ratings) 
        and count(*)>1
    order by avg_ratingl
 having count(*) > 1



-- another interpretation
 with ratings as (
    select cast(rating_value as decimal(4,3)) as rating_values, * from vb_user_ratings
), src as (
    select 
        u.user_id,
        (u.user_firstname+' '+u.user_lastname) as username,
        u.user_email,
        arv.rating_values,
        count(*) over (partition by arv.rating_by_user_id) as rating_count_per_user,
        avg(arv.rating_values) over () as avg_rating_values_per_userid 
    from vb_users u 
    join ratings arv on u.user_id = arv.rating_by_user_id 
)
select distinct * from src
    where src.rating_values< src.avg_rating_values_per_userid and src.rating_count_per_user >1

/*
    8.	Produce a report of the KPI (key performance indicator) user bids per item. 
Show the user’s name and email total number of valid bids, total count of items 
bid upon and then the ratio of bids to items. As a check, Anne Dewey’s bids per 
item ratio is 1.666666
*/

select user_email, 
    count(bid_id) as total_valid_bids, 
    count(distinct bid_item_id) as total_items_bid_upon,
    count(bid_id) / cast(count(distinct bid_item_id) as decimal) as ratio
    from vb_users 
    join vb_bids on user_id =bid_user_id
    where bid_status = 'ok'
    group by user_email


/*9.	Among items not sold, show highest bidder name and the highest bid for each item. 
Make sure to include only valid bids.*/

select distinct item_id, item_name,
    max(bid_amount) over (partition by item_id) as high_bid,
    first_value(user_firstname) over (partition by item_id order by bid_amount desc) as high_first_name,
    first_value(user_lastname) over (partition by item_id order by bid_amount desc) as high_last_name
    from vb_users 
    join vb_bids on user_id =bid_user_id
    join vb_items on item_id = bid_item_id
    where item_sold=0
    and bid_status='ok'
    --and item_id = 6

    -- another solution
WITH items_highest_bid as (
select  i.item_id as item_id,i.item_name, max(b.bid_amount) as max_bid_amount
    from vb_bids b
    join vb_items i on i.item_id = b.bid_item_id
    where b.bid_status = 'ok' and i.item_sold = 0
    group by i.item_name, i.item_id
)
 
select i.item_name
    , u.user_firstname + ' ' + u.user_lastname as [Bidder Name]
    , h.max_bid_amount
    from vb_items i 
    join items_highest_bid h on i.item_id = h.item_id
    join vb_bids b on b.bid_item_id = i.item_id and h.max_bid_amount = b.bid_amount
    join vb_users u on u.user_id = b.bid_user_id


    /*10.	Write a query with output like the previous query but also includes the overall average 
seller rating, and the difference between each user’s average rating and the overall average. 
For reference, the overall average seller rating should be 3.2.
*/
go 
with temp as (
    select user_id, user_firstname, user_lastname, rating_value,
        avg(cast(rating_value as decimal)) over () as overall_avg_rating
    from vb_user_ratings
        join vb_users on user_id = rating_for_user_id
    where rating_astype='seller'
)
select user_id, user_firstname, user_lastname, 
        avg(cast(rating_value as decimal)) as avg_rating,
        overall_avg_rating,
        avg(cast(rating_value as decimal)) - overall_avg_rating as delta
    from temp
    group by user_id, user_firstname, user_lastname, overall_avg_rating


GO
use demo
GO
select * from stocks
select * 
from stocks for system_time as of '2020-04-06 00:00:00'

--all googley changes
select * from stocks for system_time all 
    where ticker ='GOOGL'
    ORDER BY valid_from



use vbay
go
select * from vb_user_ratings order by rating_by_user_id
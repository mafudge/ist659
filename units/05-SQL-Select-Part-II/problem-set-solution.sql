use vbay
go
-- # Query 1
select item_name, item_reserve, min(bid_amount) as min_bid, 
    max(bid_amount) as max_bid, item_soldamount
    from vb_items
        join vb_bids on item_id=bid_item_id
    where bid_status = 'ok'
    group by item_name, item_reserve, item_soldamount
    order by item_reserve desc 

-- # Query 2 
with user_bids as (
    select s.user_email, s.user_firstname, s.user_lastname, count(*) as bid_counts,
        case when count(*) between 0 and 1 then 'Low'
            when count(*) between 2 and 4 then 'Moderate'
            else 'High' end as user_bid_activity
        from vb_users s 
            left join vb_bids b 
                on b.bid_user_id = s.user_id
        where b.bid_status = 'ok'
        group by s.user_email, s.user_firstname, s.user_lastname
)
select user_bid_activity, count(*) as user_count 
    from user_bids
    group by user_bid_activity
    order by user_count
    

/*
1.	How many item types are there? Perform an analysis of each item type. 
For each item type, provide the count of items in that type, the minimum, 
average, and maximum item reserve prices for that type. Sort the output by item type. 
*/

select item_type, 
        count(*) as item_count, 
        min(item_reserve) as min_reserve,
        avg(item_reserve) as avg_reserve,
        max(item_reserve) as max_reserve
    from vb_items
    group by item_type
    order by item_type

/*
2.	Perform an analysis of each item in the “Antiques” and “Collectables” item types.
For each item display the name, item type and item reserve. Include the min, max and 
average item reserve over each item type so that the current item reserve can be compared to these values.
*/

select item_name, item_type, item_reserve,
    min(item_reserve) over (partition by item_type) as min_reserve_by_type,
    avg(item_reserve) over (partition by item_type) as avg_reserve_by_type,
    max(item_reserve) over (partition by item_type) as max_reserve_by_type
    from vb_items
    where item_type in ('Antiques', 'Collectables')

/*
3.	Write a query to include the names, counts (number of ratings) and average seller ratings 
(as a decimal) of users. 
For reference, User Carrie Dababbbi has 4 seller ratings and an average rating of 4.75. 
*/



select user_id, user_firstname, user_lastname, 
        count(*) as ratings,
        avg(cast(rating_value as decimal)) as avg_rating
    from vb_user_ratings
        join vb_users on user_id = rating_for_user_id
    where rating_astype='seller'
    group by user_id, user_firstname, user_lastname

/*
4.	Create a list of “Collectable” item types with more than 1 bid. Include the name 
of the item and the number of bids making sure the item with the most bids appears first.
*/
select item_name, count(*) as bid_count
    from vb_items 
        join vb_bids on item_id = bid_item_id
    where item_type = 'Collectables'   
    group by item_name 
    having count(*) > 1
    order by bid_count desc 


/*
5.	Generate a valid bidding history for any given item of your choice. Display the 
item id, item name a number representing the order the bid was placed, the bid 
amount and the bidder’s name. Here’s an example showing the first 3 bids on item 11. 
*/
select item_id, item_name, 
    dense_rank() over( partition by item_name order by bid_datetime) as bid_order,
    bid_amount, 
    user_firstname + ' ' + user_lastname as bidder
    from vb_items 
        join vb_bids on item_id=bid_item_id
        join vb_users on bid_user_id = user_id
    where bid_status='ok' and item_id = 11

/*
6.	Re-Write your query in the previous question to include the names of the next and
previous bidders, like this example again showing the first 3 bids for item 11.
*/
select item_id, item_name, 
    dense_rank() over( partition by item_name order by bid_datetime) as bid_order,
    bid_amount, 
    lag(user_firstname + ' ' + user_lastname) over (partition by item_name order by bid_datetime) as prev_bidder,
    user_firstname + ' ' + user_lastname as bidder,
    lead(user_firstname + ' ' + user_lastname) over (partition by item_name order by bid_datetime) as next_bidder
    from vb_items 
        join vb_bids on item_id=bid_item_id
        join vb_users on bid_user_id = user_id
    where bid_status='ok' and item_id = 11

/*7.	Find the names and emails of the users who give out the worst ratings
 (lower than the overall average rating) to either buyers or sellers (no need 
 to differentiate whether the user rated a buyer or seller), and only include 
 those users who have submitted more than 1 rating.
*/
select user_email, user_firstname, user_lastname,
    count(*) as rating_count,
    avg(cast(rating_value as decimal)) as avg_rating
    from vb_user_ratings
        join vb_users on rating_by_user_id = user_id
    group by user_email, user_firstname, user_lastname
    having avg(cast(rating_value as decimal)) < 
        (select avg(cast(rating_value as decimal)) from vb_user_ratings) 
        and count(*)>1
    order by avg_rating

/*
8.	Produce a report of the KPI (key performance indicator) user bids per item. 
Show the user’s name and email total number of valid bids, total count of items 
bid upon and then the ratio of bids to items. As a check, Anne Dewey’s bids per 
item ratio is 1.666666
*/
select user_email, user_firstname, user_lastname, 
    count(*) as total_bids, 
    count(distinct bid_item_id) as count_items,
    cast(count(*) as decimal) / count(distinct bid_item_id) as bids_per_item
    from vb_users
        join vb_bids on user_id = bid_user_id
        join vb_items on item_id = bid_item_id
    where bid_status = 'ok'
   group by user_email, user_firstname, user_lastname
   order by bids_per_item desc

/*9.	Among items not sold, show highest bidder name and the highest bid for each item. 
Make sure to include only valid bids.
*/
with temp as (
select 
   item_name, item_reserve, 
    rank() over (partition by item_id order by bid_datetime desc) as bid_rank,
    first_value(bid_amount) over (partition by item_id order by bid_datetime desc) as highest_bid,
    first_value(user_firstname + ' ' + user_lastname) over (partition by item_id order by bid_datetime desc) as highest_bidder
    from vb_items
        join vb_bids on item_id = bid_item_id
        join vb_users on user_id = bid_user_id
    where bid_status = 'ok' and item_sold = 0 
)
select item_name, item_reserve, highest_bid, highest_bidder
    from temp where bid_rank =1 

/*10.	Write a query with output like the previous query but also includes the overall average 
seller rating, and the difference between each user’s average rating and the overall average. 
For reference, the overall average seller rating should be 3.2.
*/

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

select * from vb_user_ratings
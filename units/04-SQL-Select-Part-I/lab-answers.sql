/* 1. 	Sales would like to send mailings to users who live in a zip code that starts with “13”
      for example 13244 so that can be notified of their new contact in that region.
*/
select *  
    from vb_users 
    where user_zip_code like '13%'



/* 2.   Find all the users from the state of new york. print their names and emails along with their city, state and zip code.
*/
select * from vb_users 
    join vb_zip_codes on user_zip_code=zip_code
    where zip_state = 'NY'
    order by zip_city, user_lastname, user_firstname

/* 3.	High Priced Items. Return the id, name, type and reserve of items which have not 
        been sold and have a reserve of 250 or higher. Sort the output so that the largest 
        reserve items are first. 
*/ 
select item_id, item_name, item_type, item_reserve 
    from vb_items 
    where item_sold=0 and item_reserve >=250
    order by item_reserve desc

/* 4.	Reserve item categories. Include the id, name, type and reserve price of the item. 
        Do not include items of type “All Other”. Create a category column based on item 
        reserve price.
        When the item is 250 or more it is a high priced item. 
        When the item is 50 or less it is a low priced item.
        Everything else is an average priced item.

        GPA
        Academic Warning
*/
select item_name, item_type, item_reserve, 
    case 
        when item_reserve <=50 then 'low' 
        when item_reserve >=230 then 'high'
        else 'average'
    end as item_category,
    case 
        when ntile(3) over( order by item_reserve) = 1 then 'LOW'
        when ntile(3) over( order by item_reserve) = 2 then 'MED'
        else 'HIGH' end as rank
    from vb_items 
    where item_type != 'All Other'
    order by item_name 



select item_id, item_name, item_type, item_reserve, case 
    when item_reserve >=250 then 'high '
    when item_reserve <=50 then 'low'
    else 'average' end as item_category
    from vb_items 
    where item_type != 'All Other'

/* 5.	Bidder list. Write a query which displays the valid user bids (bid status of ‘ok’) for a given item_id.  
        This would commonly be displayed on the website. You select the item id to display and show the bid id, 
        bid user’s name, bid user email, bid date, and bid amount.
*/
select bid_id,  user_firstname, user_lastname, user_email, bid_item_id, bid_datetime, bid_amount
    from vb_bids
        join vb_users on user_id = bid_user_id 
    where bid_status='ok' and bid_item_id = 11
    order by bid_datetime desc

/* 6.	The bad bidder list. Write query to help the security audit team find fraudulent activity. For any bid
        that does not have a status of ‘ok’, include the date of the bid, name, email and id of the bidder and
        the name and id of the item bid upon of item. Also include the bid amount and sort the output by user's 
        last name, first name and the bid date.
*/

select bid_datetime, user_lastname + ',' + user_firstname as user_name, user_email, item_id, item_name, bid_amount, bid_status
    from vb_bids 
        join vb_items on bid_item_id = item_id
        join vb_users on bid_user_id = user_id 
    where bid_status != 'ok'
    order by user_name, bid_datetime

/* 7.   items with no bids. Produce a report of items which do not contain a bid. Include the item id,
        item name, item type, sellers name item reserve.
*/

select item_id, item_name, item_type, item_reserve, s.user_firstname + ' ' + s.user_lastname as seller_name,
	bid_id, b.user_firstname + ' ' + b.user_lastname as bidder_name
	from vb_items  
		left join vb_bids on item_id=bid_item_id
		join vb_users as s on item_seller_user_id=s.user_id
        left join vb_users as b on b.user_id = bid_user_id
	where bid_id is null
    order by bid_id 

/* 8.	Produce a list of seller ratings. Include the name of the user who gave the rating, the name
        of the user the rating was for, the rating value, and rating comment. Include only ratings of sellers.
*/

select b.user_firstname + ' ' + b.user_lastname as rating_by, f.user_firstname + ' ' + f.user_lastname as rating_for,
	rating_astype, rating_value , rating_comment
	from vb_user_ratings 
		join vb_users as b on rating_by_user_id= b.user_id
		join vb_users as f on rating_for_user_id= f.user_id
	where rating_astype='Seller'

/* 9.	For items that were sold, generate a report which includes the locations (City and state) of the
        buyer and seller. Include item id, item name, item type item sold amount name of seller, seller’s 
        city/state, name of buyer, and the buyer’s city /state
*/

select item_id, item_name, item_type, item_reserve, sz.zip_city + ',' + sz.zip_state as seller_location,
	bz.zip_city + ',' + bz.zip_state as buyer_location,
	item_soldamount
	from vb_items
		join vb_users as s on item_seller_user_id=s.[user_id]
		join vb_users as b on item_buyer_user_id=b.[user_id]
		join vb_zip_codes bz on b.user_zip_code = bz.zip_code
		join vb_zip_codes sz on s.user_zip_code = sz.zip_code
	 where item_sold=1


/* 10.	Users with no activity. Find the names and emails of all users who have never posted an item 
        for bid or have never bid on an item.
*/
select * 
    from vb_users
         left join vb_bids on bid_user_id = user_id
         left join vb_items s on user_id = s.item_seller_user_id
         left join vb_items b on user_id = b.item_buyer_user_id
    where s.item_id is NULL and b.item_id is null and bid_id is null 


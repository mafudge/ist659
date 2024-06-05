
drop view if exists v_buyers_sellers_for_map
GO
create view v_buyers_sellers_for_map
as 
with source as (
    select i.item_id, i.item_name, i.item_soldamount, 
    s.user_firstname + ' '+ s.user_lastname as seller_name,
    sz.zip_lat as seller_lat, sz.zip_lng as seller_lng,
    b.user_firstname + ' '+ b.user_lastname as buyer_name,
    bz.zip_lat as buyer_lat, bz.zip_lng as buyer_lng
    from vb_items i
        join vb_users s on i.item_seller_user_id = s.user_id 
        join vb_zip_codes sz on s.user_zip_code = sz.zip_code
        join vb_users b on i.item_buyer_user_id = b.user_id 
        join vb_zip_codes bz on b.user_zip_code = bz.zip_code
    where item_buyer_user_id is not null 
)
select 'seller' as source, item_id, item_name, seller_name as name, seller_lat as lat, seller_lng as lng from source 
union all
select 'buyer' as source,item_id, item_name,  buyer_name, buyer_lat, buyer_lng from source 
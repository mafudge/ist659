use fudgemart_v3
GO
-- A
drop view if exists v_products_with_vendors
go
create view v_products_with_vendors
    AS
    select * from fm_products
        join fm_vendors on product_vendor_id = vendor_id
GO
-- use it
select * from v_products_with_vendors
go 

-- B (No order details, please)
drop function if exists f_order_history
go
create function f_order_history( @customer_id int)
    returns table 
    AS
    return SELECT * from fm_orders 
        where customer_id = @customer_id

GO
select * from dbo.f_order_history(15)


-- joining a TVF - example
select * from fm_customers cross apply dbo.f_order_history(customer_id)

go
use vbay
go
-- C
drop procedure if exists p_make_bid
go
create procedure p_make_bid( 
    @user_id int, 
    @item_id int,
    @amount money
) AS
BEGIN
    --- insert ? update ? delete?
    insert into vb_bids (bid_user_id, bid_item_id, bid_amount)
    values (@user_id, @item_id, @amount)
END

EXECUTE p_make_bid @user_id=2, @item_id =1, @amount=23.00
-- SQL Injection is why we use TVE and stored procs
--select * from foo where a = "b"&09";drop table foo;
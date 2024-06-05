-- #1

use tinyu
GO
drop procedure if exists dbo.p_upsert_major
GO
create procedure dbo.p_upsert_major (
    @major_code char(3),
    @major_name varchar(50)
) as begin
    begin try
        begin transaction 
        -- data logic
        if exists(select * from majors where major_code = @major_code) begin 
            update majors set major_name = @major_name  
                where major_code = @major_code
            if @@ROWCOUNT <> 1 throw 50001, 'p_upsert_major: Update Error',1
        end
        else begin
            declare @id int = (select max(major_id) from majors) + 1
            insert into majors (major_id, major_code, major_name) 
                values (@id, @major_code, @major_name)
            if @@ROWCOUNT <> 1 throw 50002, 'p_upsert_major: Insert Error',1
        end
        commit
    end try
    begin catch
        rollback
        ;
        throw
    end catch 
end 
GO
-- #2 
-- works, okay data
select * from majors
exec p_upsert_major 'UBW', 'Underwater Basket Weaving'
select * from majors
exec p_upsert_major 'UBW', 'Underwater Basket Weaving'
select * from majors

-- #3
use vbay
GO
drop procedure if exists dbo.p_place_bid
GO
create procedure [dbo].[p_place_bid]
(
	@bid_item_id int,
	@bid_user_id int,
	@bid_amount money
)
as
begin
    begin try
    begin TRANSACTION

	declare @max_bid_amount money
	declare @item_seller_user_id int
	declare @bid_status varchar(20)
	
	-- be optimistic :-)
	set @bid_status = 'ok'
	
	-- TODO: 5.5.1 set @max_bid_amount to the higest bid amount for that item id 
	set @max_bid_amount = (select max(bid_amount) from vb_bids where bid_item_id=@bid_item_id and bid_status='ok') 
	
	-- TODO: 5.5.2 set @item_seller_user_id to the seller_user_id for the item id
	set @item_seller_user_id = (select item_seller_user_id from vb_items where item_id=@bid_item_id) 

	-- TODO: 5.5.3 if no bids then set the @max_bid_amount to the item_reserve amount for the item_id
	if (@max_bid_amount is null) 
		set @max_bid_amount = (select item_reserve from vb_items where item_id=@bid_item_id) 
	
	-- if you're the item seller, set bid status
	if ( @item_seller_user_id = @bid_user_id)
		set @bid_status = 'item_seller'
	
	-- if the current bid lower or equal to the last bid, set bid status
	if ( @bid_amount <= @max_bid_amount)
		set @bid_status = 'low_bid'
		
	-- TODO: 5.5.4 insert the bid at this point and return the bid_id 		
	insert into vb_bids (bid_user_id, bid_item_id, bid_amount, bid_status)
		values (@bid_user_id, @bid_item_id, @bid_amount, @bid_status)
    if @@ROWCOUNT <> 1 throw 50001,'Cannot place bid',1

    commit 
	return  @@identity 

    end TRY
    begin CATCH
        rollback
        ;
        throw
    end catch 
	-- 
end
GO
-- # 4
select * from vb_bids where bid_item_id = 36
exec p_place_bid @bid_item_id=36, @bid_user_id = 2, @bid_amount = 105 
select * from vb_bids where bid_item_id = 36

-- # 5
drop procedure if exists dbo.p_rate_user
GO
create procedure [dbo].[p_rate_user]
(
	@rating_by_user_id int,
	@rating_for_user_id int,
	@rating_astype varchar(20),
	@rating_value int,
	@rating_comment text 
)
as
begin
	-- TODO: 5.3
    begin TRY
    begin TRAN

	insert into vb_user_ratings (rating_by_user_id, rating_for_user_id, rating_astype, rating_value,rating_comment)
	values (@rating_by_user_id, @rating_for_user_id, @rating_astype, @rating_value, @rating_comment)
	if @@ROWCOUNT <> 1 throw 50001, 'Cannot insert rating',1

	commit
    return @@identity 
    end TRY
    begin CATCH
        print 'ROLLBACK'
        rollback
        ;
        THROW
    end CATCH
end
GO

-- # 6
select * from vb_user_ratings where rating_by_user_id=1
execute dbo.p_rate_user @rating_by_user_id=1, @rating_for_user_id=1,
    @rating_astype='Seller',@rating_value=5, @rating_comment = 'test'
execute dbo.p_rate_user @rating_by_user_id=1, @rating_for_user_id=2,
    @rating_astype='Seller',@rating_value=15, @rating_comment = 'test'
select * from vb_user_ratings where rating_by_user_id=1


-- # 7
use tinyu
GO
drop trigger if exists t_max_majors_allowed
go
create trigger t_max_majors_allowed
	on students 
	after update as
begin
    declare @max int = 15
	if exists(select count(*), s.student_major_id 
        from (
            select student_id, student_major_id from students
                UNION
            select student_id, student_major_id from inserted
        ) s     group by s.student_major_id having count(*) > @max ) 
	begin
		rollback
		; --huh? This is required because you cannot say begin... throw
		THROW 50005, 'Too many students in a major.',1
	end 
end
-- # 8
select student_major_id, count(*) from students group by student_major_id
update students set student_major_id = 2 where student_id =3
select student_major_id, count(*) from students group by student_major_id





go 
use vbay 
go 
-- SQL Injection 
insert into vb_user_ratings (rating_by_user_id, rating_for_user_id, rating_astype, rating_value,rating_comment)
	values ('1','2', 'seller', 4, '\x24\x26 go drop table vb_user_ratings;'
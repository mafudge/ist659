use demo
go

begin TRANSACTION
select @@TRANCOUNT
create table test ( test_id int not null)
go 
insert into test values (1),(2),(3)
select * from test
rollback 
select @@trancount 
begin TRANSACTION
drop table flag_colors
-- try to view the dropped table- you can't because its not durable mid-transaction!
ROLLBACK
begin transaction 
delete from fudgemart_products
select * from fudgemart_products
rollback

---

use demo

begin TRANSACTION

select @@TRANCOUNT

drop table accounts
go
delete from  mikeazon_products
select * from mikeazon_products
GO
if exists(select * from sys.objects where name='accounts')
    print 'accounts table exists'

select * from INFORMATION_SCHEMA.TABLES
--rollback 

select * from mikeazon_products


begin TRANSACTION
insert into flag_colors (color,country) values ('white', 'ITA')
insert into flag_colors (color,country) values ('green', 'ITA')
insert into flag_colors (color,country) values ('red', 'ITA')
insert into flag_colors (color,country) values ('red', 'ITA')
commit 

select * from flag_colors

---- 

use demo
go
drop procedure if exists p_transfer_funds
GO
create procedure p_transfer_funds (
    @amount money,
    @from_acct varchar(50),
    @to_acct varchar(50)
) as BEGIN
    update accounts set balance = balance - @amount
        where account = @from_acct
    update accounts set balance = balance + @amount
        where account = @to_acct
END

go

select * from accounts
--exec p_transfer_funds @amount=100, @from_acct='Savings', @to_acct = 'Checking'
-- check constraint fires
exec p_transfer_funds 
    @amount=100, 
    @from_acct='Savings', 
    @to_acct = 'Checking'

-- no rows affected


exec p_transfer_funds_v1 @amount=100, @from_acct='Savingz', @to_acct = 'Checking'
go
select * from accounts 


go
drop procedure if exists p_transfer_funds
GO
create procedure p_transfer_funds (
    @amount money,
    @from_acct varchar(50),
    @to_acct varchar(50)
) as BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        update accounts set balance = balance - @amount
            where account = @from_acct
        update accounts set balance = balance + @amount
            where account = @to_acct
        COMMIT 
    END TRY
    BEGIN CATCH
        ROLLBACK ; 
        THROW 
    END CATCH
END

select * from accounts
--exec p_transfer_funds @amount=100, @from_acct='Savings', @to_acct = 'Checking'
-- check constraint fires
exec p_transfer_funds_v2 @amount=10000, @from_acct='Savings', @to_acct = 'Checking'
-- no rows affected
exec p_transfer_funds_v2 @amount=100, @from_acct='Savingz', @to_acct = 'Checking'
go
select * from accounts 


go
drop procedure if exists p_transfer_funds_v3
GO
create procedure p_transfer_funds_v3 (
    @amount money,
    @from_acct varchar(50),
    @to_acct varchar(50)
) as BEGIN
    declare @from_rc int 
    declare @to_rc int 
    begin TRY
        begin TRANSACTION
        update accounts set balance = balance - @amount
            where account = @from_acct
        if @@ROWCOUNT <> 1 throw 50001, 'Could not transfer from account', 1
        update accounts set balance = balance + @amount
            where account = @to_acct
        if @@rowcount <> 1 throw 50002, 'Could not transfer to account',1
        print 'committing'
        commit 
    end try
    begin CATCH
        throw
        select error_number() as error, ERROR_MESSAGE() as message
        print 'Rolling back'
        rollback 
    end CATCH
END

select * from accounts
exec p_transfer_funds_v3 @amount=100, @from_acct='Savingz', @to_acct = 'Checking'
go
select * from accounts

GO
drop trigger if exists t_accounts_block_locked
go
create trigger t_accounts_block_locked
	on accounts
	instead of update as
begin
	if exists(select * from inserted where locked=1) 
	begin
		; --huh? This is required because you cannot say begin... throw
		THROW 50005, 'No changes permitted, to account is locked',1
		rollback
	end 
	else if exists(select * from deleted where locked=1) 
	begin
		; --huh? This is required because you cannot say begin... throw
		THROW 50005, 'No changes permitted, from account is locked',1
		rollback
	end 
	else -- perform the update as usual.
	begin
		update accounts set accounts.balance= inserted.balance
		from inserted
		where accounts.account = inserted.account
	end
end

GO
update accounts set locked=1 where account = 'Money-Market'
select * from accounts
exec p_transfer_funds_v3 @amount=100, @from_acct='Money-Market', @to_acct = 'Money-Market'
go
select * from accounts

-------------------------


-- setup 
use demo

BEGIN TRAN -- open a transaction

UPDATE accounts set balance = 9999 where account='savings'

PRINT @@TRANCOUNT 

--ROLLBACK


-----------------------------------------------------
--- this only worked for me in SQL Server Management Studio. 
--- Did not work in azure data studio
-------------------------------------------------------
use demo

set transaction isolation level read committed 
go

-- we can read checking... that write is not locked
select * from accounts where account ='checking'

print @@lock_timeout 

-- this query will be blocked as we have a lock in place from the update.
select * from accounts 


-----------------------------------------

use demo

set transaction isolation level read uncommitted 
go

-- this will read dirty data 9999 - the uncommitted tranaction.

select * from accounts 


-------------------------------
-- Deadlocks 
use tinyu 
go 

-- window 1
 BEGIN TRANSACTION 
 UPDATE students
    set student_firstname = 'Robyn'
    where student_id = 1
 WAITFOR DELAY '00:00:05'
UPDATE majors 
    set major_name = 'Accounting'
    where major_id=3
 
ROLLBACK 


-- window 2
 BEGIN TRANSACTION 
UPDATE majors 
    set major_name = 'Accounting'
    where major_id=3

 WAITFOR DELAY '00:00:05'
 UPDATE students
    set student_firstname = 'Robyn'
    where student_id = 1


ROLLBACK 

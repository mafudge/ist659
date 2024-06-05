use demo
GO
begin transaction -- Start a unit of work

create table testing (
    test_name varchar(100)
)
GO
insert into testing (test_name)
     values ('one'),('two'),('three'),('four')
go
select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
    where TABLE_NAME='testing'  -- its there
go
select * from testing -- Data is there

rollback  -- UNDO!

select TABLE_NAME from INFORMATION_SCHEMA.TABLES 
    where TABLE_NAME='testing' -- its not there!

go

BEGIN TRANSACTION
BEGIN TRY
    -- Unit of work starts here

    COMMIT -- Save work!
END TRY
BEGIN CATCH 
    ROLLBACK -- ERROR... Undo
    print 'rollback'
    ; -- weird SQL Server Syntax
    THROW 
END CATCH 


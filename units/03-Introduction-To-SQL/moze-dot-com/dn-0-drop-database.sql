use master
go
if exists(select name from sys.databases where name='moze')
ALTER DATABASE moze SET SINGLE_USER WITH ROLLBACK IMMEDIATE
go
drop database if exists moze;
GO
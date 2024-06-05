use master
go
if not exists(select name from sys.databases where name='moze')
    create database moze
GO
use moze
GO
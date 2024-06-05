use demo
GO
alter 
    database demo add filegroup ORDERS
GO
select * from sys.filegroups
GO
drop table if exists orders
go
create table orders (
    order_id int identity not null,
    order_amount money,
    constraint pk_order_id primary key (order_id)
) on ORDERS
GO
select * from orders
GO
insert into orders (order_amount) values (99.99), (50.99)
-- ERROR
alter database demo add file (
    NAME = 'orders',
    FILENAME = '/var/opt/mssql/data/orders.ndf'
) to filegroup ORDERS
go
insert into orders (order_amount) values (99.99), (50.99)
GO
select * from orders 
GO
select * from sys.database_files
GO



SELECT o.[name] as object_name,  i.[name] as index_name,  
    f.[name] as filegroup_name, d.physical_name as file_name 
    FROM sys.indexes i 
        JOIN sys.filegroups f ON i.data_space_id = f.data_space_id
        JOIN sys.all_objects o ON i.[object_id] = o.[object_id] 
        JOIN sys.database_files d on d.data_space_id = f.data_space_id
    WHERE i.data_space_id = f.data_space_id AND o.type = 'U' -- User Created Tables


GO
use tinyu
go

select student_firstname, student_lastname, student_gpa 
    from students 
    where student_year_name = 'Freshman'

select student_year_name, avg(student_gpa) as student_avg
    from students
    group by student_year_name 
    
GO
drop index if exists ix_students_by_student_year_name on students
go
create index ix_students_by_student_year_name on students(student_year_name)
    include (student_firstname, student_lastname, student_gpa )
go


drop index if exists ix_students_by_student_year_name on students
drop index if exists cix_students on students
GO
create columnstore index cix_students 
    on students(student_id, student_gpa, student_year_name, student_major_id)


select student_major_id, count(student_id)
    from students
    group by student_major_id

select student_year_name, avg(student_gpa)
    from students
    group by student_year_name
    Having student_year_name in ('Junior','Senior')


select student_id, 
    avg(student_gpa) over (partition by student_year_name)
    from students

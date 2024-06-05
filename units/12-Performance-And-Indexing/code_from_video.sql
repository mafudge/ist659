use demo
go
-- create a file group
ALTER DATABASE demo ADD FILEGROUP products  
go
select * from sys.filegroups

-- add some files to the file group
alter database demo
    add file (
        NAME = products_data,
        FILENAME = '/var/opt/mssql/data/products_data.mdf'
        )
    to FILEGROUP products 
GO
select * from sys.filegroups 
select * from sys.tables
select * from sys.database_files
select * from sys.data_spaces

-- which tables are in which filegroup
select sys.objects.name as object_name, 
    sys.filegroups.name as file_group,
    sys.indexes.name as clustered_index_name
    from  sys.filegroups 
    join sys.indexes on sys.filegroups.data_space_id = sys.indexes.data_space_id
    join sys.objects on sys.indexes.object_id = sys.objects.object_id
    where sys.objects.type = 'U'

-- move table fudgemart_products to the products file group:
CREATE UNIQUE CLUSTERED INDEX PK_fudgemart_products_product_id ON fudgemart_products (product_id)  
    WITH (DROP_EXISTING = ON)  
    ON products -- filegroup 

SELECT o.[name] as object_name,  i.[name] as index_name, i.type_desc,  f.[name] as filegroup_name
    FROM sys.indexes i 
        JOIN sys.filegroups f ON i.data_space_id = f.data_space_id
        JOIN sys.all_objects o ON i.[object_id] = o.[object_id] 
    WHERE i.data_space_id = f.data_space_id AND o.type = 'U' -- User Created Tables

---
drop table if exists other_products
go
create table other_products (
    product_id int IDENTITY not null, 
    product_name varchar(20) not null,
    product_price money,
    constraint pk_other_products primary key nonclustered (product_name)
) ON PRODUCTS
GO
create clustered index ixc_other_products on other_products(product_id)
-- error
GO
create clustered index ixc_other_products2 on other_products(product_id,product_name)
GO

---


    select student_firstname, student_lastname, student_gpa
    from students
    where student_year_name = 'Freshman'


select student_year_name, avg(student_gpa)
    from students
    group by student_year_name 

drop index if exists  ix_students_by_year_name on students 
go  
create NONCLUSTERED index ix_students_by_year_name 
    on students (student_year_name)
    include (student_firstname, student_lastname, student_gpa)

---
use tinyu
go
-- basic query
select student_firstname, student_lastname, major_name, student_gpa
    from students s 
        join majors m on s.student_major_id = m.major_id

-- original query with window function
select student_firstname, student_lastname, major_name, student_gpa
    ,avg(student_gpa) over (partition by major_name) as avg_gpa_by_major
    from students s 
        join majors m on s.student_major_id = m.major_id

-- better as it uses a seek, keep the window function in the same table.
select student_firstname, student_lastname, major_name, student_gpa
    ,avg(student_gpa) over (partition by student_major_id) as avg_gpa_by_major
    from students s 
        join majors m on s.student_major_id = m.major_id


---sort is the most costly operation, so let's use an index
GO
drop index if exists ix_students_by_student_major_id on students
GO
create NONCLUSTERED index ix_students_by_student_major_id 
    on students( student_major_id)
        include (student_firstname, student_lastname, student_gpa, student_year_name)
GO
select student_firstname, student_lastname, major_name, student_gpa
    ,avg(student_gpa) over (partition by student_major_id) as avg_gpa_by_major
    from students s 
        join majors m on s.student_major_id = m.major_id

select student_firstname, student_lastname, major_name, student_gpa
    from students s 
        join majors m on s.student_major_id = m.major_id

-- final look at simple query
select student_firstname, student_lastname, major_name, student_gpa
    from students s 
        join majors m on s.student_major_id = m.major_id

---
use demo
GO


-- with size 5 and 2 this will not be fragemented as all the data fits on a single page!
-- with sizes 5 and 2000 
--  the table will be fragmented (clustered index not insereted ascending order)
--  the index will not be fragmented still fits in one page
-- with sizes 500 and 2000 
--  both are fragemented! index out of order, and clustered index out of order

go
drop table if exists items
go
create table items (
    item_name varchar(100) not null,
    item_qty char(500) not null, --5
    item_space_waster char(2000) not null, -- 5
    constraint pk_item_name primary key clustered (item_name)
)
GO
create NONCLUSTERED index ix_items on items(item_qty)
GO

insert into items values ('alarm clock', '50',' ') 
insert into items values ('blanket', '44',' ') 
insert into items values ('cheese', '50',' ') 
insert into items values ('soap', '87',' ') 
insert into items values ('bedding', '88',' ') 
insert into items values ('phone', '30',' ') 
insert into items values ('glass', '88',' ') 
insert into items values ('jewel', '58',' ') 
insert into items values ('zebra', '12',' ') 
insert into items values ('bouy', '99',' ') 
insert into items values ('broom', '20',' ') 
insert into items values ('backpack', '44',' ') 
insert into items values ('fan', '10',' ') 
insert into items values ('file', '1',' ') 
insert into items values ('fund', '7',' ') 
insert into items values ('game', '14',' ') 
insert into items values ('yam,', '14',' ') 
insert into items values ('apple', '44',' ') 
insert into items values ('knife', '88',' ') 
insert into items values ('jam', '44',' ') 
insert into items values ('bucket', '21',' ') 
insert into items values ('armoire', '50',' ') 
insert into items values ('egg', '14',' ') 
insert into items values ('worm', '76',' ') 
insert into items values ('rice', '50',' ') 
insert into items values ('dough', '14',' ') 
insert into items values ('knot', '50',' ') 
insert into items values ('banana', '12',' ') 
insert into items values ('hammer', '90',' ') 
insert into items values ('tape', '1',' ') 
insert into items values ('wire', '25',' ') 
insert into items values ('owl', '40',' ') 
insert into items values ('heater', '92',' ') 
insert into items values ('ash', '99',' ') 
insert into items values ('figurine', '71',' ') 
insert into items values ('saw', '99',' ') 
insert into items values ('slate', '50',' ') 


-- check fragmentation 
SELECT s.[name] +'.'+t.[name]  AS table_name
 ,i.NAME AS index_name
 ,index_type_desc
 ,ROUND(avg_fragmentation_in_percent,2) AS avg_fragmentation_in_percent
 ,record_count AS table_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
INNER JOIN sys.tables t on t.[object_id] = ips.[object_id]
INNER JOIN sys.schemas s on t.[schema_id] = s.[schema_id]
INNER JOIN sys.indexes i ON (ips.object_id = i.object_id) AND (ips.index_id = i.index_id)
ORDER BY avg_fragmentation_in_percent DESC

alter index pk_item_name on items rebuild 
alter index pk_item_name on items REORGANIZE
alter index ix_items on items  rebuild 
alter index ix_items on items  REORGANIZE

--------

use fudgemart_v3
go


-- clustered index scan
SELECT count(order_id),[ship_via]
  FROM [fm_orders]
  GROUP BY [ship_via]

create nonclustered index ix_fudgemart_orders on [fm_orders] (ship_via) ;


  -- yay non clustered index scan - using our new index.
SELECT count(order_id),[ship_via]
  FROM [fm_orders]
  GROUP BY [ship_via]


  -- but this does not  :-(
SELECT count(order_id),customer_id
  FROM [fm_orders]
  GROUP BY customer_id


  -- neither does this  :-(
SELECT count(order_id),creditcard_id
  FROM [fm_orders]
  GROUP BY creditcard_id

 -- and it would require two additional indexs, too. Blah!

  -- let's try a columnstore
GO
drop index if exists ix_fudgmart_orders_col on fm_orders
go
create nonclustered columnstore index ix_fudgmart_orders_col 
    on fm_orders (ship_via, customer_id, creditcard_id)


-- uses our columnstore index
SELECT count(order_id),[ship_via]
  FROM [fm_orders]
  GROUP BY [ship_via]

-- this works too!
SELECT count(order_id),[customer_id]
  FROM [fm_orders]
  GROUP BY [customer_id]

-- this works too!
SELECT count(order_id),[creditcard_id]
  FROM [fm_orders]
  GROUP BY [creditcard_id]

-- and even this!!!
SELECT count(order_id),[creditcard_id]
  FROM [fm_orders]
  WHERE [customer_id] between  10 and 20 
  GROUP BY [creditcard_id]

--------

use tinyu
GO

drop view if exists v_students
go
create view v_students 
    as
        select student_id, student_firstname, student_lastname, 
            student_gpa, student_year_name, major_name
            from students join majors on student_major_id=major_id
GO
select * from v_students 

-- let's index that

drop view if exists v_students
go
create view v_students 
    with SCHEMABINDING
    as
        select student_id, student_firstname, student_lastname, 
            student_gpa, student_year_name, major_name
            from dbo.students join dbo.majors on student_major_id=major_id
GO

drop index if exists ix_v_students on v_students
go
create unique clustered index ix_v_students on v_students(student_id)

select * from v_students 
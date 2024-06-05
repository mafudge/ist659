use tinyu
go -- mssql specific
-- DOWN SCRIPTS

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    where CONSTRAINT_NAME='fk_majors_major_department_id')

    alter table majors drop constraint fk_majors_major_department_id

if exists(select * from INFORMATION_SCHEMA.COLUMNS
    where table_name = 'majors' AND column_name = 'major_department_id')

    alter table majors drop column major_department_id 

drop table if exists departments

go

-- UP SCRIPTS
create table departments (
   department_id int identity not null, --surrogate key
   department_name varchar(20) not null,
   department_school varchar(50) not null,
   department_address varchar(50) not null,
   constraint pk_departments_department_id primary key (department_id),
   constraint u_departments_department_name unique (department_name)
)

alter table majors add major_department_id int null

alter table majors add constraint fk_majors_major_department_id
    foreign key (major_department_id)
    references departments(department_id)

GO

INSERT into departments
(department_name, department_school, department_address)
VALUES
    ('Information', 'iSchool', '123 West Hall'),
    ('Business', 'Bacon School of Management', '999 Kevin Hall')

update majors set major_department_id = 1 where major_id = 1 or major_id= 2
update majors set major_department_id = 2 where major_id in (3,4,5)

-- VERIFY
select * from departments
select * from majors
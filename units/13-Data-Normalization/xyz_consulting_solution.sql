--create database xyz
go 
use xyz
go
drop table if exists xyz_consulting
go
create table xyz_consulting
(
    project_id int not null,
    project_name varchar(50) not null,
    employee_id int not null,
    employee_name varchar(50) not null,
    rate_category char(1) not null,
    rate_amount money not null,
    billable_hours int not null,
    total_billed money not null,
    constraint pk_xyz_consulting primary key(project_id, employee_id)
)
insert into xyz_consulting values 
(1023,	'Madagascar travel site',	11,	'Carol Ling',	'A',	 60.00, 	5,	 300.00 ),
(1023,	'Madagascar travel site',	12,	'Chip Atooth',	'B',	 50.00, 	10,	 500.00 ),
(1023,	'Madagascar travel site',	16,	'Charlie Horse',	'C',	 40.00, 	2,	 80.00), 
(1056,	'Online estate agency',	11,	'Carol Ling',	'D',	 90.00, 	5,	 450.00 ),
(1056,	'Online estate agency',	17,	'Avi Maria',	'B',	 50.00, 	2,	 100.00 ),
(1099,	'Open travel network',	11,	'Carol Ling',	'A',	 60.00, 	6,	 360.00 ),
(1099,	'Open travel network',	12,	'Chip Atooth',	'C',	 40.00, 	8,	 320.00 ),
(1099,	'Open travel network',	14,	'Arnie Hurtz',	'D',	 90.00, 	3,	 270.00 )
GO
select * from xyz_consulting order by employee_id

--- Composite Key - Partial???

--- Columns which are not key dependent
-- No action 0NF => 1NF

--- Columns which are partial key dependent
-- Partial to Project_id ==> project name
-- Partial to employee_id ==> employee_name
-- 1) original table with dependencies removed 
-- 2) projects table
-- 3) employees table

if exists(select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
    where CONSTRAINT_NAME='fk_xyz_billing_project_id')
    alter table xyz_billing drop fk_xyz_billing_project_id
GO
if exists(select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
    where CONSTRAINT_NAME='fk_xyz_billing_employee_id')
    alter table xyz_billing drop fk_xyz_billing_employee_id
GO
if exists(select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
    where CONSTRAINT_NAME='fk_xyz_billing_rate_category')
    alter table xyz_billing drop fk_xyz_billing_rate_category
GO

go
drop table if exists  xyz_consulting_2nf 
go
select project_id, employee_id, rate_category, rate_amount, billable_hours, total_billed
    into  xyz_consulting_2nf
    from  xyz_consulting 
GO
alter table xyz_consulting_2nf add 
    constraint pk_xyz_consulting_2nf primary key (project_id, employee_id)
go
select * from xyz_consulting_2nf
GO
drop table if exists xyz_projects
go
select distinct project_id, project_name 
into xyz_projects
from xyz_consulting
GO
alter table xyz_projects add 
    constraint pk_xyz_projects primary key (project_id)
go
select * from xyz_projects

GO
drop table if exists xyz_employees
go
select distinct  employee_id, employee_name 
into xyz_employees
from xyz_consulting
go
alter table xyz_employees ADD
    constraint pk_xyz_employees primary key (employee_id)
go
select * from xyz_employees
go
--- Columns which are transitive dependent
-- 1) original table with dependencies removed xyz_billing
-- 2) rates table
drop table if exists xyz_billing
go
select project_id, employee_id, rate_category,billable_hours, total_billed
    into xyz_billing
    from xyz_consulting_2nf 
GO
alter table xyz_billing add 
    constraint pk_xyz_billing primary key (project_id, employee_id)
GO
select * from xyz_billing
GO
drop table if exists xyz_rates
go
select distinct rate_category, rate_amount 
into xyz_rates
from xyz_consulting_2nf
go 
alter table xyz_rates add constraint pk_xyz_rates primary key(rate_category)
GO
select * from  xyz_rates
/*
   Projects <=== billing ==> Employees
                    ||
                    \/
                  rates  
*/
alter table xyz_billing ADD
    constraint fk_xyz_billing_project_id 
        foreign key (project_id) references xyz_projects(project_id),
    constraint fk_xyz_billing_employee_id
        foreign key (employee_id) references xyz_employees(employee_id),
    constraint fk_xyz_billing_rate_category 
        foreign key (rate_category) references xyz_rates(rate_category)
go
drop table if exists xyz_consulting_2nf
go

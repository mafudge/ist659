if not exists(select * from sys.databases where name='moze2')
    create database moze2
GO

use moze2
GO

-- DOWN 

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    where CONSTRAINT_NAME='fk_jobs_job_submitted_by')
    alter table jobs drop constraint fk_jobs_job_submitted_by

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    where CONSTRAINT_NAME='fk_jobs_job_contracted_by')
    alter table jobs drop constraint fk_jobs_job_contracted_by

drop table if exists jobs

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    where CONSTRAINT_NAME='fk_contractors_contractor_state')
    alter table contractors drop constraint fk_contractors_contractor_state

drop table if exists contractors

if exists(select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    where CONSTRAINT_NAME='fk_customers_customer_state')
    alter table customers drop constraint fk_customers_customer_state
drop table if exists customers 
drop table if exists state_lookup

GO
-- UP Metadata
create table state_lookup (
    state_code char(2) not null,
    constraint pk_state_lookup_state_code primary key(state_code)
)
create table customers (
    customer_id int identity not null,
    customer_email varchar(50) not null,
    customer_min_price money not null,
    customer_max_price money not null,
    customer_city varchar(50) not null,
    customer_state char(2) not NULL, 
    constraint pk_customers_customer_id primary key (customer_id),
    constraint u_customer_email unique (customer_email),
    constraint ck_min_max_price check (customer_min_price<=customer_max_price)
)
alter table customers 
    add constraint fk_customers_customer_state foreign key (customer_state)
        references state_lookup(state_code)


create table contractors (
    contractor_id int identity not null,
    contractor_email varchar(50) not null,
    contractor_rate money not null,
    contractor_city varchar(50) not null,
    contractor_state char(2) not NULL, 
    constraint pk_contractors_contractor_id primary key (contractor_id),
    constraint u_contractor_email unique (contractor_email)
)

alter table contractors
    add constraint fk_contractors_contractor_state foreign key (contractor_state)
        references state_lookup(state_code)

create table jobs (
    job_id int identity not null,
    job_submitted_by int not null,
    job_requested_date date not null,
    job_contracted_by int null,
    job_service_rate money null,
    job_estimated_date date null,
    job_completed_date date null,
    constraint pk_jobs_job_id primary key (job_id),
    constraint ck_valid_job_dates
        check (job_requested_date<=job_estimated_date and job_estimated_date<=job_completed_date)
)

alter table jobs
    add constraint fk_jobs_job_submitted_by foreign key (job_submitted_by)
        references customers(customer_id)

alter table jobs 
    add constraint  fk_jobs_job_contracted_by foreign key (job_contracted_by)
        references contractors(contractor_id)


GO
-- UP Data
insert into state_lookup (state_code) values
    ('NY'),('NJ'),('CT')
insert into customers
    (customer_email, customer_min_price, customer_max_price, customer_city, customer_state)  
    values
    ('lkarforless@superrito.com', 50, 100, 'Syracuse', 'NY'),
    ('bdehatchett@dayrep.com', 25, 50, 'Syracuse', 'NY'),
    ('pmeaup@dayrep.com', 100, 150, 'Syracuse', 'NY'),
    ('tanott@gustr.com', 25, 75, 'Rochester', 'NY'),
    ('sboate@gustr.com',50,100, 'New Haven', 'CT')

insert into contractors 
    (contractor_email, contractor_rate, contractor_city, contractor_state)  
    values
    ('otyme@dayrep.com', 50, 'Syracuse', 'NY'),
    ('meyezing@dayrep.com', 75, 'Syracuse', 'NY'),
    ('bitall@dayrep.com', 35, 'Rochester', 'NY'),
    ('sbeeches@dayrep.com', 85, 'Hartford', 'CT')

insert into jobs 
    (job_submitted_by, job_requested_date, job_contracted_by,job_service_rate, job_estimated_date, job_completed_date)
values
    (1,'2020-05-01', NULL, NULL,NULL, NULL),
    (2,'2020-05-01', 1, 50,'2020-05-02', NULL),
    (5,'2020-05-01', 4, 85,'2020-05-03','2020-05-03')

GO
-- Verify
select * from state_lookup 
select * from customers 
select * from contractors
select * from jobs
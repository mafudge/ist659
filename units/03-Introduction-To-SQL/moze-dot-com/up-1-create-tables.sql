use moze
go

--create tables and table-based constraints

create table state_lookup (
    state_code char(2) primary key not null
)
GO
create table customers (
    customer_id int identity not null,
    customer_email varchar(50) not null,
    customer_min_price money not null,
    customer_max_price money not null,
    customer_city varchar(50) not null,
    customer_state char(2) not NULL, 
    constraint pk_customers_customer_id primary key (customer_id)
)
go
alter table customers
    add constraint u_customer_email unique (customer_email)

alter table customers 
    add constraint ck_min_max_price check(customer_min_price<=customer_max_price)
GO

create table contractors (
    contractor_id int identity not null,
    contractor_email varchar(50) not null,
    contractor_rate money not null,
    contractor_city varchar(50) not null,
    contractor_state char(2) not NULL, 
    constraint pk_contractors_contractor_id primary key (contractor_id)
)
go
alter table contractors
    add constraint u_contractor_email unique (contractor_email)

GO
create table jobs (
    job_id int identity not null,
    job_submitted_by int not null,
    job_requested_date date not null,
    job_contracted_by int null,
    job_service_rate money null,
    job_estimated_date date null,
    job_completed_date date null,
    constraint pk_jobs_job_id primary key (job_id)
)
GO
alter table jobs 
    add constraint ck_valid_job_dates
        check (job_requested_date<=job_estimated_date and job_estimated_date<=job_completed_date)




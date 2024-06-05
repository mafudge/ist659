if not exists(select * from sys.databases where name='moze2')
    create database moze2
GO

use moze2
GO

-- DOWN 
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
GO
-- Verify
select * from state_lookup 
select * from customers 

drop view if exists v_cars
go 

if exists(SELECT * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    where CONSTRAINT_NAME= 'fk_dealers_dealer_car_id' )
    alter table dealers drop fk_dealers_dealer_car_id
go

drop table if exists cars
drop table if exists dealers
go

create table cars (
    car_id int identity not NULL,
    car_licplate varchar(20) not null,
    CONSTRAINT pk_car_id PRIMARY key (car_id),
    CONSTRAINT u_car_licplate unique (car_licplate)
)

create table dealers (
    dealer_id int IDENTITY not NULL,
    dealer_name varchar(100) not null,
    dealer_car_id int null,
    constraint pk_dealer_id PRIMARY key (dealer_id),
    constraint u_dealer_car_id unique (dealer_car_id)
)
GO
alter table dealers add constraint fk_dealers_dealer_car_id 
    FOREIGN key (dealer_car_id) REFERENCES cars(car_id)


-- data inserts
insert into cars (car_licplate) values
    ('123abc'),
    ('zxy345'),
    ('12ad56')

--two ways to insert with SELECT 
insert into dealers (dealer_name, dealer_car_id)
    select 'Fudgeauto Brokers' as dealer_name , car_id 
        from cars where car_licplate in ('123abc','zxy345')

insert into dealers (dealer_name, dealer_car_id)
    values ('Cheap o''Auto', (select car_id from cars where car_licplate =  '12ad56') )

-- external model
go
create view v_cars as
    select * from dealers join cars on dealer_car_id=car_id 

-- verify
go
select * from v_cars 

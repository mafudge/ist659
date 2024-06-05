/* 
drop database if exists cuserides
go
create database cuserides
go
use cuserides
go 
*/
drop table if exists cr_fleet_2nf 
drop table if exists cr_driver_regions
drop table if exists cr_vehicle_features
drop table if exists cr_vehicles_3nf 
go
drop table if exists cr_fleet
go
create table cr_fleet (
    driver_id int not null,
    driver_name varchar(50) not null,
    driver_fee money not null,
    region1 varchar(20) null,
    region2 varchar(20) null,
    region3 varchar(20) null,
    licplate varchar(10) not null,
    make varchar(20) not null,
    model varchar(20) not null,
    car_size char(1) not null,
    car_fee money not null,
    car_features varchar(50) null,
    test_date date not null,
    test_score int not null,
    constraint pk_fleet primary key (driver_id, licplate)
)
insert into cr_fleet (driver_id, driver_name,driver_fee,region1,region2,region3,
    licplate,make,model,car_size,car_fee,car_features,
    test_date,test_score)
    VALUES
    (101,'Bill Melator', 7.5, 'West','North','Downtown', 'PPF673', 'Cadillac', 'Escalade','M',10,'USB Port,Navigation,XM Radio,Bluetooth','2020-04-05',88 ),
    (101,'Bill Melator', 7.5, 'West','North','Downtown', 'PXK3D7T', 'Chevy', 'Tahoe','L',12.5,'USB Port,Navigation','2020-04-06',92 ),
    (101,'Bill Melator', 7.5, 'West','North','Downtown', '445GH2', 'Nissan', 'Leaf','S',7.5,'USB Port,XM Radio','2020-04-03',90 ),
    (101,'Bill Melator', 7.5, 'West','North','Downtown', '59DLLK', 'Chevy', 'Trax','S',7.5,'USB Port,Bluetooth','2020-04-01',78 ),
    (102,'Willie Dryve', 12.5, 'South','Downtown',NULL, 'PXK3D7T', 'Chevy', 'Tahoe','L',12.5,'USB Port,Navigation','2020-04-05',80 ),
    (102,'Willie Dryve', 12.5, 'South','Downtown',NULL, '663ETMP', 'Chevy', 'Surburban','L',12.5,'XM Radio','2020-04-03',90 ),
    (103,'Sal Debote', 10.0, 'North','Downtown','East', '445GH2', 'Nissan', 'Leaf','S',7.5,'USB Port,XM Radio','2020-04-12',90 ),
    (103,'Sal Debote', 10.0, 'North','Downtown','East', '59DLLK','Chevy', 'Trax','S',7.5,'USB Port,Bluetooth','2020-04-02',85 ),
    (103,'Sal Debote', 10.0, 'North','Downtown','East', '667GM8', 'Nissan', 'Altima','M',10, 'USB Port,Bluetooth,Navigation','2020-04-11',97 ),
    (104,'Carol Ling', 12.5, 'South',NULL,'West', '667GM8', 'Nissan', 'Altima','M',10, 'USB Port,Bluetooth,Navigation','2020-04-09',94 ),
    (104,'Carol Ling', 12.5, 'South',NULL,'West', 'PPF673', 'Cadillac', 'Escalade','M',10,'USB Port,Navigation,XM Radio,Bluetooth','2020-04-04',83 ),
    (104,'Carol Ling', 12.5, 'South',NULL,'West', '663ETMP', 'Chevy', 'Surburban','L',12.5,'XM Radio','2020-04-12',92 ),
    (105,'Ida Knowe', 5, NULL,NULL,'Downtown', '445GH2', 'Nissan', 'Leaf','S',7.5,'USB Port,XM Radio','2020-04-17',99 )


/* 
    NORMALIZATION PROCESS 
*/

-- before, FYI  
select * from cr_fleet

/* Resolve No Key for Regions and features to 1NF*/

-- original cr_fleet to 1NF
-- drop if exists
drop table if exists cr_fleet_1nf  
go
-- make table query
select driver_id, driver_name, driver_fee, licplate, make, model, car_size, car_fee, test_date, test_score 
    into cr_fleet_1nf 
    from cr_fleet
GO
-- set the pk for entity integrity - if this does not work we did something wrong!
alter table cr_fleet_1nf add constraint pk_cr_fleet_1nf primary key (driver_id, licplate)
GO
-- verify its correct
select * from cr_fleet_1nf 
GO

-- region lookup create
drop table if exists cr_regions 
go
with regions as (
select region1 as region from cr_fleet where region1 is not null
    union 
select region2 from cr_fleet where region2 is not null
    union 
select region3 from cr_fleet where region3 is not null
)
select region into cr_regions from regions 
GO
alter table cr_regions alter column region varchar(20) not null
go
alter table cr_regions add constraint pk_cr_regions primary key (region)
GO
select * from cr_regions 

-- bridge table for drivers 
drop table if exists cr_fleet_regions
go
select licplate, driver_id, region into cr_fleet_regions
    from cr_fleet UNPIVOT ( region for region_col in (region1,region2, region3) ) as upvt
    order by driver_id,region 
GO
alter table cr_fleet_regions alter column region varchar(20) not null
go
alter table cr_fleet_regions add constraint pk_cr_fleet_regions primary key (licplate, driver_id, region)
GO
select * from cr_fleet_regions

-- car feature lookup - create
drop table if exists cr_features
go
select distinct value as car_feature into cr_features 
    from cr_fleet cross APPLY string_split(car_features,',')
GO
alter table cr_features alter column car_feature varchar(20) not null
go
alter table cr_features add constraint pk_cr_features primary key (car_feature)
GO
select * from cr_features

-- bridge table for features
drop table if exists cr_fleet_features
go
select driver_id, licplate, value as car_feature into cr_fleet_features
    from cr_fleet cross apply  string_split(car_features,',')
    order by licplate
GO
alter table cr_fleet_features alter column car_feature varchar(20) not NULL
GO
alter table cr_fleet_features add constraint  pk_cr_fleet_features primary KEY (driver_id, licplate, car_feature)
GO
select * from cr_fleet_features


-- 1NF  before, FYI 
select * from cr_fleet_1nf
        

 /* Resolve partial dependencies  to 2NF */

-- original fleet_1nf to 2NF 
drop table if exists cr_fleet_2nf
go
select driver_id, licplate, test_date, test_score into cr_fleet_2nf
    from cr_fleet_1nf
GO
alter table cr_fleet_2nf add constraint pk_cf_fleet_2nf primary key (driver_id, licplate)   
GO
select * from cr_fleet_2nf

-- partial table for driver
drop table if exists cr_drivers
go
select distinct driver_id, driver_name, driver_fee into cr_drivers
    from cr_fleet_1nf
GO
alter table cr_drivers alter column driver_id int not NULL
GO
alter table cr_drivers add constraint pk_cr_drivers primary key (driver_id)
go
select * from cr_drivers 


-- partial table for car
drop table if exists cr_vehicles
go
select distinct licplate, make, model, car_size, car_fee into cr_vehicles
    from cr_fleet_1nf
GO
alter table cr_vehicles alter column licplate varchar(10) not NULL
GO
alter table cr_vehicles add constraint pk_cr_vehicles PRIMARY KEY (licplate)
GO
select * from cr_vehicles

-- cr_fleet_regions becomes cr_driver_regions
drop table if exists cr_driver_regions
go
select distinct driver_id, region into cr_driver_regions
    from cr_fleet_regions
GO
alter table cr_driver_regions add constraint pk_cr_driver_regions primary key (driver_id, region)
GO
select * from cr_driver_regions

--- cr_fleet_features becomes  cr_vehicle_features
drop table if exists cr_vehicle_features
go
select distinct licplate, car_feature into cr_vehicle_features
    from cr_fleet_features
GO
alter table cr_vehicle_features add constraint pk_cr_vehicle_features primary key (licplate, car_feature)
GO
select * from cr_vehicle_features


-- 2NF  before, FYI 
select * from cr_vehicles
        
 /* Resolve transitive dependencies  to 3NF */

-- original table
drop table if exists cr_vehicles_3nf
go
select licplate, make, model, car_size into cr_vehicles_3nf
    from cr_vehicles
GO
alter table cr_vehicles_3nf add constraint pk_cr_vehicles_3nf primary key (licplate)
GO
select * from cr_vehicles_3nf

-- removed transitive dependency cr_vehicle_sizes
drop table if exists cr_vehicle_sizes
go
select distinct car_size, car_fee into cr_vehicle_sizes from cr_vehicles
GO
alter table cr_vehicle_sizes alter column car_size char(1) not null 
GO
alter table cr_vehicle_sizes add constraint pk_cr_vehicle_sizes primary key (car_size)
GO
select * from cr_vehicle_sizes

/* WHAT DO I DO NOW? */

select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME like 'cr_%'

-- which tables do I select?
-- highest NF or name if no NF, so
/*
cr_fleet_2nf, 
cr_drivers,  cr_driver_regions,  cr_regions, 
cr_vehicles_3nf, cr_vehicle_sizes, cr_vehicle_features, cr_features
*/
/* foreign keys */
alter table cr_fleet_2nf add 
    constraint fk_cr_fleet_2nf_driver_id foreign key (driver_id) references cr_drivers(driver_id),
    constraint fk_cr_fleet_2nf_licplate foreign key (licplate) references cr_vehicles(licplate)
go
alter table cr_driver_regions ADD
    CONSTRAINT fk_cr_driver_regions_driver_id foreign key (driver_id) references cr_drivers(driver_id),
    CONSTRAINT fk_cr_driver_regions_region foreign key (region) references cr_regions(region)
go
alter table cr_vehicle_features ADD
    CONSTRAINT fk_cr_vehicle_features_licplate foreign key (licplate) references cr_vehicles(licplate),
    CONSTRAINT fk_cr_vehicle_features_car_feature foreign key (car_feature) references cr_features(car_feature)
GO
alter table cr_vehicles_3nf ADD 
    constraint fk_cr_vehicles_3nf_car_size foreign key (car_size) references cr_vehicle_sizes(car_size)



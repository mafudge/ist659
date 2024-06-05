-- UP: V. 1.0 to V 1.1
-- atomic in your operations
-- one change at a time 
use moze2
GO
if not exists(select * from INFORMATION_SCHEMA.COLUMNS
    WHERE table_name = 'customers' and column_name='customer_phone')
begin 
    alter table customers
        add customer_phone varchar(10) NULL
end

---
if not exists (????)
    alter table customers add customer_fav_prod


-- DOWN: v1.1 to 1.O
if  exists(select * from INFORMATION_SCHEMA.COLUMNS
    WHERE table_name = 'customers' and column_name='customer_phone')
begin
    alter table customers drop column customer_phone
end
select * from customers

-- UPSERT pattern 
if exists(select * from customers where customer_email = 'mafudge@syr.edu')
    update customers set customer_city = 'Utica'
ELSE    
    insert into 

-- merge 

-- INSERT IF NOT EXIST 
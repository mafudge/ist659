select * from 
(
select 'tony' as name, 45 as age
union ALL
select 'jim-bob' as name, 34 as age
union ALL
select 'sally' as name, 28 as age
) as mytable
where mytable.name ='tony'



go
with mytable as 
(
    select 'tony' as name, 45 as age
    union ALL
    select 'jim-bob' as name, 34 as age
    union ALL
    select 'sally' as name, 28 as age
) 
select * from mytable
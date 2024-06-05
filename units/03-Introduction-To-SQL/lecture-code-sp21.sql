/*
    inner equijoin
    left / right outer join
    full outer join
    cartsian product
*/
-- equijoin

use demo
go
select * 
    from bbplayers
        join contacts on player_id = contact_id 


-- 
select * from bbplayers
select * from bbteams 

-- typical join is on pk-fk (intersection of player_team_id = team_id )
select * 
from bbplayers 
    join bbteams on player_team_id = team_id


--cartisan product
select * from bbplayers, bbteams 
    where player_team_id = team_id


-- all players even those with teams
select * 
from bbplayers left join bbteams 
    on player_team_id=team_id

-- this is the same query
select *
from bbteams right join bbplayers 
    on player_team_id = team_id
go

-- full includes participants from both sides
select team_name, player_name
from bbteams full outer join bbplayers 
    on player_team_id = team_id
go

use vbay
go
select vb_users.user_firstname, vb_users.user_lastname, b.*
from vb_bids as b
    join vb_users on user_id=bid_user_id
    join vb_items on item_id = bid_item_id
where b.bid_status='ok'

-- names of people who have never bid!
select user_email, user_firstname, user_lastname
from vb_users left join vb_bids on user_id = bid_user_id
where bid_id is null 


use payroll
go

select * from paychecks
where (paycheck_total_hours_worked between 30 and 40) 
and paycheck_payperiod_id >= 20200101
and paycheck_employee_payroll_type='Hourly'
order by paycheck_payperiod_id desc , paycheck_total_hours_worked desc



SELECT *
   FROM paychecks
   JOIN employees ON paycheck_employee_id = employee_id
   WHERE paycheck_total_hours_worked BETWEEN 30 and 40
   and paycheck_payperiod_id >= 20200101
   and paycheck_employee_payroll_type = 'Hourly'
ORDER BY paycheck_payperiod_id DESC,
       paycheck_total_hours_worked DESC


select 
    e.employee_id,p.paycheck_employee_id, e.employee_firstname, e.employee_lastname, p.* 
from employees e 
    join paychecks p on p.paycheck_employee_id = e.employee_id
where paycheck_total_hours_worked BETWEEN 30 AND 40 
    AND paycheck_payperiod_id >= 20200101 
    AND paycheck_employee_payroll_type = 'Hourly'
order by paycheck_payperiod_id desc, 
    paycheck_total_hours_worked desc



select * 
from paychecks 
    join pay_periods on payperiod_id = paycheck_payperiod_id
    join employees on employee_id = paycheck_employee_id
where payperiod_date = '2018-02-23' and employee_department = 'Hardware'


USE vbay
go


-- #1 list of items for bid name of item, and who is the seller
select u.user_firstname, u.user_lastname, i.item_name
from vb_items as i 
    join vb_users as u on user_id = item_seller_user_id


-- #2 start with #1 and show  the buyer if there is one!!

select s.user_firstname, s.user_lastname, i.item_name, b.user_firstname, b.user_lastname
from vb_items as i 
    join vb_users as s on s.user_id = item_seller_user_id
    left join vb_users as b on b.user_id = item_buyer_user_id


use payroll

select 
    e.employee_id, e.employee_firstname, e.employee_lastname, e.employee_supervisor_employee_id,
    s.employee_firstname, s.employee_lastname
from employees e
    left join employees s on e.employee_supervisor_employee_id  = s.employee_id 

select e.employee_firstname, e.employee_lastname, e.employee_ssn,
    pp.payperiod_date,
    pc.* 
    from paychecks pc
        join employees e on e.employee_id = pc.paycheck_employee_id
        join pay_periods pp on pp.payperiod_id = pc.paycheck_payperiod_id
    where pc.paycheck_employee_payroll_type != 'Salary'
    order by pc.paycheck_employee_id



use demo 

select * from bbplayers
select * from bbteams

select * 
    from bbplayers 
        left join bbteams on team_id = player_team_id

select * 
    from bbplayers 
        right join bbteams on team_id = player_team_id


select * 
    from bbplayers 
        full join bbteams on team_id = player_team_id


select p.* 
    from bbplayers  p
        left join bbteams t on t.team_id = p.player_team_id
    where t.team_id is null 
-- I can do this
select * 
    from bbteams
        join bbplayers on team_id  = player_id




select * 
    from bbplayers
        join bbteams on player_team_id = team_id 

--same
select * 
    from bbplayers
        join bbteams on team_id  = player_team_id

-- same
select  player_name, team_name
    from bbteams
        join bbplayers on team_id  = player_team_id
    where team_name = 'Bulls'


use payroll 


select top 3  * from employees  
    where employee_jobtitle = 'Sales Associate' 
    order by employee_pay_rate desc


select distinct employee_department, employee_jobtitle
    from employees 

select distinct  employee_jobtitle
    from employees

select distinct employee_department 
    from employees
    order by employee_department desc


select employee_firstname, employee_lastname, employee_pay_rate,
    case 
        when employee_pay_rate<=18.50 then 'low'
        when employee_pay_rate>=20 then 'high'
        else 'middle'
    end as pay_band
    from employees 
    where employee_jobtitle = 'Sales Associate'
    and employee_pay_rate > 18.50 and employee_pay_rate <20
    order by employee_pay_rate

select 
    cast(employee_id as varchar) + 'A' as id,
    employee_firstname + ' ' + employee_lastname as employee_name,
    employee_ssn 

    from employees

select * from employees
    where employee_department like 'C%'
    and employee_ssn like '__1%'
    
select * from employees
    where (employee_department = 'Toys' 
    or employee_department ='Clothing')
    and employee_jobtitle = 'Sales Associate'
select * from employees
    where employee_jobtitle ='Department Manager'
    or employee_supervisor_employee_id=3
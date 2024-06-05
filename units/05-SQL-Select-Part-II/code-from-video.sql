select employee_department,  
        row_number() over(order by employee_id) as row_number,
        rank() over (partition by employee_department order by employee_id) as rank,
        ntile(2) over(partition by employee_department order by employee_id) as ntile,  
        percent_rank() over(partition by employee_department order by employee_id) as pct_rank, 
        cume_dist() over(partition by employee_department order by employee_id) as cume_dist 
    from employees 
    order by employee_department

select paycheck_payperiod_id, paycheck_employee_id, paycheck_gross_pay, 
    first_value(paycheck_gross_pay) over 
        (partition by paycheck_employee_id order by paycheck_payperiod_id ) as first_paycheck,
    lag(paycheck_gross_pay) over
        (partition by paycheck_employee_id order by paycheck_payperiod_id ) as previous_paycheck,
    lag(paycheck_gross_pay,2) over
        (partition by paycheck_employee_id order by paycheck_payperiod_id ) as previous_paycheck_2_ago
    from paychecks
    where paycheck_payperiod_id between 20200101 and 20200331
        and paycheck_employee_payroll_type = 'Hourly'

with pay_analysis as (
    select employee_firstname, employee_lastname , employee_department, employee_pay_rate,
        avg(employee_pay_rate) over (partition by employee_department ) as avg_pay_rate_by_dept,
        avg(employee_pay_rate) over () as avg_pay_rate_overall
        from employees
        where employee_jobtitle = 'Sales Associate'
)
select *,
    employee_pay_rate - avg_pay_rate_by_dept as dept_delta,
    employee_pay_rate - avg_pay_rate_overall as overall_delta
    from pay_analysis


with dept_counts as (
    select employee_department, count(*) employee_count 
        from employees
        group by employee_department
)
select * from dept_counts where employee_count >
    (select avg(employee_count) from dept_counts)
    

with payroll_with_years as (
    select left(cast(paycheck_payperiod_id as varchar),4) as payroll_year,
        paycheck_total_hours_worked,  
        paycheck_gross_pay
        from paychecks
)
select 
    payroll_year, sum(paycheck_total_hours_worked), sum(paycheck_gross_pay)
    from  payroll_with_years
    group by payroll_year
    order by payroll_year 


select p.payroll_year, sum(paycheck_total_hours_worked), sum(paycheck_gross_pay)
    from  (
            select left(cast(paycheck_payperiod_id as varchar),4) as payroll_year,
                paycheck_total_hours_worked,  
                paycheck_gross_pay
                from paychecks
    ) as p
    group by payroll_year
    order by payroll_year

select left(cast(paycheck_payperiod_id as varchar),4) as payroll_year,
    sum(paycheck_total_hours_worked) as total_hours_worked,
    sum(paycheck_gross_pay) as total_gross_pay
    from paychecks
    group by left(cast(paycheck_payperiod_id as varchar),4)
    order by payroll_year

select left(cast(paycheck_payperiod_id as varchar),6) as payroll_year,
    sum(paycheck_total_hours_worked) as total_hours_worked,
    sum(paycheck_gross_pay) as total_gross_pay
    from paychecks
    group by left(cast(paycheck_payperiod_id as varchar),6)
    order by payroll_year 


select 
    employee_department,
    paycheck_employee_payroll_type,
    count(*) as paycheck_count,
    sum(paycheck_total_hours_worked) as total_hours_worked,
    sum(paycheck_gross_pay) as total_gross_pay
    from paychecks
        join employees on paycheck_employee_id = employee_id 
    where paycheck_payperiod_id between 20200101 and 20200331
    group by employee_department, paycheck_employee_payroll_type
    having sum(paycheck_gross_pay) > 20000
    order by employee_department, paycheck_employee_payroll_type



select 
    paycheck_employee_payroll_type,
    count(*) as paycheck_count,
    sum(paycheck_total_hours_worked) as total_hours_worked,
    sum(paycheck_gross_pay) as total_gross_pay
    from paychecks
    where paycheck_payperiod_id between 20200101 and 20200331
    group by paycheck_employee_payroll_type


select sum(paycheck_gross_pay) as total_pay_2018,
    sum(paycheck_total_hours_worked) as total_hours_2018
    from paychecks
    where paycheck_payperiod_id between 20180101 and 20181231


select min(paycheck_payperiod_id) as earliest_paycheck,
    max(paycheck_payperiod_id) as latest_paycheck,
    min(paycheck_gross_pay) as smallest_paycheck,
    max(paycheck_gross_pay) as largest_paycheck
    from paychecks


select count(distinct paycheck_employee_payroll_type) 
    from paychecks 

select 
    count(*) as paycheck_count
    from paychecks

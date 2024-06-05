use moze
GO

-- now that tables exist, add foreign key constraints
alter table customers 
    add constraint fk_customers_customer_state foreign key (customer_state)
        references state_lookup(state_code)

alter table contractors
    add constraint fk_contractors_contractor_state foreign key (contractor_state)
        references state_lookup(state_code)

alter table jobs
    add constraint fk_jobs_job_submitted_by foreign key (job_submitted_by)
        references customers(customer_id)

alter table jobs 
    add constraint  fk_jobs_job_contracted_by foreign key (job_contracted_by)
        references contractors(contractor_id)

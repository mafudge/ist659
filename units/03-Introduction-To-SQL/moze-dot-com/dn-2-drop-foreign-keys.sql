use moze
go

-- Drop all foreign key constraints
alter table customers drop fk_customers_customer_state
alter table contractors drop fk_contractors_contractor_state
alter table jobs drop constraint fk_jobs_job_submitted_by
alter table jobs drop constraint fk_jobs_job_contracted_by

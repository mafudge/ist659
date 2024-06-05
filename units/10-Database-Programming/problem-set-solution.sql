
-- #1 p_upsert_major 
use tinyu
GO
drop procedure if exists p_upsert_major
GO
create procedure p_upsert_major (
    @major_code char(3),
    @major_name varchar(50)
) as begin
    if exists(select * from majors where major_code = @major_code) begin 
        update majors set major_name = @major_name  
            where major_code = @major_code
    end
    else begin
        declare @id int = (select max(major_id) from majors) + 1
        insert into majors (major_id, major_code, major_name) 
            values (@id, @major_code, @major_name)
    end
end 
GO
select * from majors 
exec dbo.p_upsert_major 'CSC', 'Computer Science'
exec dbo.p_upsert_major 'FIN', 'Finance'
select * from majors 


-- #2 f_concat 
use tinyu
GO
drop function if exists f_contact 
go 
create function f_concat(@a varchar(50), @b varchar(50), @sep char(1))
returns varchar(max) as BEGIN
    return @a + @sep + @b
END
go
select dbo.f_concat('half','baked','-') -- 'half-baked'
select dbo.f_concat('mike', 'fudge', ' ') -- 'mike fudge'
go
drop view if exists v_students
go
create view v_students AS
    select student_id, dbo.f_concat(student_firstname, student_lastname, ' ') as student_name,
        dbo.f_concat(student_lastname, student_firstname, ',') as student_name_last_first,
        student_gpa, major_name
        from students join majors on major_id = student_major_id
GO
select top 10 * from v_students


-- #3 TVF
go
select major_id, major_code, major_name, value as keyword
    from majors cross apply string_split(major_name,' ')
go
drop function if exists f_search_majors
GO
create function f_search_majors ( @search varchar(50) )
returns table AS 
    return select major_id, major_code, major_name, value as keyword
        from majors cross apply string_split(major_name,' ')
        where value = @search
go
select * from f_search_majors('Science')


-- #4 Trigger
GO
alter table students add 
    student_active char(1) default('Y') not NULL,
    student_inactive_date date null
go
drop trigger if exists t_students_inactivate
GO
create trigger t_students_inactivate
    on students after insert, update
    as begin
        update students SET
            students.student_inactive_date = inserted.student_inactive_date, 
            students.student_active = case when inserted.student_inactive_date is null then 'Y' else 'N' end
        from inserted
        where students.student_id = inserted.student_id
    end 
GO
select * from students where student_year_name = 'Graduate'
update students set student_inactive_date = '2020-08-01'
select * from students where student_year_name = 'Graduate'
GO
select * from students where student_year_name = 'Graduate'
update students set student_inactive_date = NULL
select * from students where student_year_name = 'Graduate'

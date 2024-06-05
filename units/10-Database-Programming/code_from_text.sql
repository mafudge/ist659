use tinyu
go

DECLARE @name varchar(10)
SET @name = 'Quittin'
select student_id, student_firstname, student_lastname , student_gpa
    from students where student_lastname = @name
go

DECLARE @avg_gpa decimal(4,3)
SET @avg_gpa = (SELECT avg(student_gpa) 
        from students 
        where student_year_name='Freshman')

select student_id, student_firstname, student_lastname, 
    student_gpa, @avg_gpa as frosh_avg
    from students 
    where student_year_name='Freshman'

GO

DECLARE @year varchar(50)
DECLARE @gpa decimal(4,3)

select top 1 @year = student_year_name, @gpa = avg(student_gpa) 
    from students
    group by student_year_name 
    order by avg(student_gpa) desc 

print 'Congrats to our ' + @year + ' students'
print 'for having the best overall average GPA of ' + cast(@gpa as varchar) 

GO

DECLARE @student_id int   = 1 -- Robin Banks Student
DECLARE @new_major_id int = 2 -- ADS Major
IF exists(select count(*) from students where student_major_id=@new_major_id
        having count(*) <15) BEGIN
    print 'changing major of student' + cast(@student_id as varchar) 
    print ' to major id '  + cast(@new_major_id as varchar)
    update students 
        set student_major_id=@new_major_id
        where student_id = @student_id
END
ELSE BEGIN
    print 'Sorry this major is full!'
END

GO

DROP PROCEDURE IF EXISTS p_switch_major
GO
CREATE PROCEDURE p_switch_major (
    @student_id int, 
    @new_major_id int
) AS BEGIN 
    IF exists(select count(*) from students where student_major_id=@new_major_id
            having count(*) <15) BEGIN
        print 'changing major of student' + cast(@student_id as varchar) 
        print ' to major id '  + cast(@new_major_id as varchar)
        update students 
            set student_major_id=@new_major_id
            where student_id = @student_id
        RETURN @student_id
    END
    ELSE BEGIN
        print 'Sorry this major is full!'
        RETURN NULL
    END
END
GO

SELECT NULL as result

select * from students where student_id = 1
-- Switch major to 4
exec p_switch_major @student_id=1, @new_major_id=2
select * from students where student_id = 1

GO
declare @result int null 
exec @result = p_switch_major 
    @student_id=1, 
    @new_major_id=2

go

DROP FUNCTION  if exists f_get_list
GO
CREATE FUNCTION f_get_list (
    @gpa decimal(4,3)
) returns varchar(50) AS BEGIN
    return case 
        when @gpa <= 2.0 then 'Academic Warning'
        when @gpa >= 3.8 then 'President''s List'
        when @gpa >= 3.2 then 'Dean''s List'
        else NULL
    end
END
GO




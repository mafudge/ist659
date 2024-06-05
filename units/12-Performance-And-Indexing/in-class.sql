select * from flag_colors where country = 'ITA'

go
create procedure p_add_flag( 
    @country char(3),
    @color1 varchar(20),
    @color2 varchar(20),
    @color3 varchar(20)
) as 
BEGIN
    begin TRAN
    begin try
        insert into flag_colors VALUES(@color1,@country)
        insert into flag_colors VALUES(@color2,@country)
        insert into flag_colors VALUES(@color3,@country)
        commit tran 
        print 'No errors, committing'
    end TRY
    begin catch 
        print 'Error, rolling back'
        ROLLBACK
        ;
        throw 
    end catch 
END
go 


delete from flag_colors where country = 'ITA'

select @@IDENTITY



-- example of using a function and computed column over a trigger.
use tinyu 
go
drop function if exists f_student_active
go 
create function f_student_active(@inactivedate date )
returns char(1)
as begin
    return case when @inactivedate is null then 'Y' else 'N' end
end
go 
select *, dbo.f_student_active(student_inactive_date) from students
GO

alter table students
add 
    student_active as dbo.f_student_active(student_inactive_date)


select * from students

--
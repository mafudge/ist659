use demo
GO
drop table if exists fudgenbooks
GO
create table fudgenbooks
(
    isbn varchar(20) not null,
    title varchar(50) not null,
    price money,
    author1 varchar(20) not null,
    author2 varchar(20) null,
    author3 varchar(20) null, 
    subjects varchar(100) not null,
    pages int not null,
    pub_no int not null,
    pub_name varchar(50) not null,
    pub_website varchar(50) not null,
    constraint pk_fudgenbooks_isbn primary key (isbn)
)
GO
insert into fudgenbooks VALUES
('372317842','Introduction to Money Laundering', 29.95,'Mandafort', 'Made-Off', NULL, 'scams,money laundering',367,101,'Rypoff','http://www.rypoffpublishing.com'),
('472325845','Imbezzle Like a Pro',34.95,'Made-Off','Moneesgon', NULL,'imbezzle,scams',670,101,'Rypoff','http://www.rypoffpublishing.com'),
('535621977','The Internet Scammer''s Bible',44.95, 'Screwm', 'Sucka', NULL, 'phising,id theft,scams',944,102, 'BS Press','http://www.bspress.com/books'),
('635619239','Art of the Ponzi Scheme', 39.95, 'Dewey','Screwm','Howe','scams,ponzi',450,102,'BS Press','http://www.bspress.com/books')


-- foreign keys
if exists(select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE 
    where CONSTRAINT_NAME= 'fk_books_pub_no')
    alter table fb_books drop fk_books_pub_no

if exists(select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE 
    where CONSTRAINT_NAME= 'fk_book_subjects_subject')
    alter table fb_book_subjects drop fk_book_subjects_subject

if exists(select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE 
    where CONSTRAINT_NAME= 'fk_book_subjects_isbn')
    alter table fb_book_subjects drop fk_book_subjects_isbn

if exists(select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE 
    where CONSTRAINT_NAME= 'fk_book_authors_isbn')
    alter table fb_book_authors drop fk_book_authors_isbn

if exists(select * from INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE 
    where CONSTRAINT_NAME= 'fk_book_authors_author_name')
    alter table fb_book_authors drop fk_book_authors_author_name



-- 1NF 
drop table if exists fudgenbooks_1nf
go
select isbn, title, price, pages, pub_no, pub_name, pub_website 
    into fudgenbooks_1nf
    from fudgenbooks
GO
alter table fudgenbooks_1nf add constraint pk_fudgenbooks_1nf primary key (isbn)
GO
select * from fudgenbooks_1nf
GO

drop table if exists fb_authors
GO
select a.author_name
    into fb_authors
from  (
    select author1 as author_name from fudgenbooks where author1 is not null
        union
    select author2 from fudgenbooks where author2 is not null
        union 
    select author3 from fudgenbooks where author3 is not null
) as a
GO
alter table fb_authors alter column author_name varchar(20) not NULL
GO
alter table fb_authors add constraint pk_fb_authors primary key (author_name)
GO
select * from fb_authors
GO

drop table if exists fb_book_authors
go
select isbn, author_name 
    into fb_book_authors
    from fudgenbooks unpivot ( 
        author_name for author_column in (author1,author2,author3)
    ) as upvt
GO
alter table fb_book_authors alter column author_name varchar(20) not NULL
GO
alter table fb_book_authors add constraint pk_fb_book_authors primary key (isbn,author_name)
GO
select * from fb_book_authors
GO

drop table if exists fb_subjects
go
select distinct value as subject 
    into fb_subjects
    from fudgenbooks cross apply string_split(subjects, ',')
GO
alter table fb_subjects alter column subject varchar(20) not NULL
GO
alter table fb_subjects add constraint pk_fb_subjects primary key (subject)
GO
select * from fb_subjects
GO

drop table if exists fb_book_subjects
go
select isbn, value as subject 
    into fb_book_subjects
    from fudgenbooks cross apply string_split(subjects, ',')
go
alter table fb_book_subjects alter column subject varchar(20) not NULL
GO
alter table fb_book_subjects add constraint pk_fb_book_subjects primary key (isbn,subject)
GO
select * from fb_book_subjects
GO

drop table if exists fb_books
go
select isbn, title, price, pages, pub_no  
    into fb_books
    from fudgenbooks_1nf
GO
alter table fb_books add constraint pk_fb_books primary key (isbn)
GO
select * from fb_books
GO

drop table if exists fb_publishers
go
select distinct pub_no, pub_name, pub_website 
    into fb_publishers
    from fudgenbooks_1nf
GO
alter table fb_publishers alter column pub_no int not NULL
GO
alter table fb_publishers add constraint pk_fb_publishers primary key (pub_no)
GO
select * from fb_publishers
GO

alter table fb_book_authors ADD 
    constraint fk_book_authors_isbn foreign key (isbn) references fb_books(isbn),
    constraint fk_book_authors_author_name foreign key (author_name) references fb_authors(author_name)

alter table fb_book_subjects ADD 
    constraint fk_book_subjects_isbn foreign key (isbn) references fb_books(isbn),
    constraint fk_book_subjects_subject foreign key (subject) references fb_subjects(subject)

alter table fb_books ADD
    constraint fk_books_pub_no foreign key (pub_no) references fb_publishers(pub_no)



select * from INFORMATION_SCHEMA.TABLES 
    where TABLE_NAME like 'fb_%'

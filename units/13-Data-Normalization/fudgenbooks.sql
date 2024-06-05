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

GO
select * from fudgenbooks
drop table if exists books
drop table if exists book_editions_lookup
go
create table book_editions_lookup (
    edition varchar(10) not null,
    constraint pk_book_editions_lookup_edition primary key (edition)
)
GO
create table books (
    book_id int identity not null,
    book_title varchar(50) not null,
    book_author_first_name varchar(20) not null,
    book_author_last_name varchar(20) not null,
    book_retail_price decimal(5,2) null, 
    book_number_pages int not null,
    book_edition varchar(10) null,
    constraint pk_books_book_id primary key (book_id)
)
go
insert into book_editions_lookup (edition)
    values ('1st'), ('2nd'),('3rd')

GO
alter table books add 
    book_isbn varchar(10) null
GO
alter table books add constraint u_books_book_isbn unique (book_isbn)
GO
alter table books add 
    constraint df_books_book_edition default ('1st') for book_edition
GO
alter table books ADD
    CONSTRAINT ck_books_book_retail_price_non_neg check (book_retail_price >=0)
GO
alter table books add constraint 
    ck_books_book_valid_number_of_pages check (book_number_pages > 0)
GO
alter table books add constraint 
    fk_books_book_edition FOREIGN KEY (book_edition)
        REFERENCES book_editions_lookup (edition)
GO
insert into books 
  (book_isbn, book_title, book_author_first_name, book_author_last_name, book_retail_price, book_number_pages )
values
  ('12345','The Art of War','Sun','Tzu', 9.95, 260),
  ('23456','Frankenstien','Mary','Shelley', 14.95, 280),
  ('34567','A Christman Carol', 'Charles', 'Dickens', NULL, 110),
  ('45678','The Time Machine', 'H.G.', 'Wells', 9.95, 84)

go



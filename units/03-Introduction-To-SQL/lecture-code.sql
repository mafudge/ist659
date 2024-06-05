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

insert into books 
  (book_title, book_author_first_name, book_author_last_name, book_retail_price, book_number_pages )
values
  ('The Art of War','Sun','Tzu', 9.95, 260),
  ('Frankenstien','Mary','Shelley', 14.95, 280),
  ('A Christman Carol', 'Charles', 'Dickens', NULL, 110),
  ('The Time Machine', 'H.G.', 'Wells', 9.95, 84)
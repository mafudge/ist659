select book_id, book_title, book_isbn, book_number_pages
    from books 
    where book_number_pages >=150

update books
    set book_isbn = '99999'
    where book_id = 1

select book_id, book_title, book_isbn, book_number_pages, book_edition from books

update books
    set book_number_pages = 151,
        book_title = 'A Christmas Carol'
    where book_id = 3

update books    
    set book_edition = '1st'

select book_id, book_title, book_isbn, book_number_pages, book_edition from books

update books
    set book_number_pages = book_number_pages - 200

delete from books where book_id = 4

delete from books where book_number_pages > 200

delete from books
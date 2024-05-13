-- Active: 1715244819451@@localhost@5432@postgres@public

-- Library Catalog Schema
-- ICA1 WAAD

-- Creating table for authors
CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL
);

-- Creating table for genres
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Creating table for books
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    publication_year INTEGER NOT NULL,
    isbn VARCHAR(255) NOT NULL UNIQUE,
    author_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    FOREIGN KEY (author_id) REFERENCES authors(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);

-- Creating table for power users
CREATE TABLE power_users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);


-- Stored procedures

-- Adding a new book
-- Stored Procedure to Add a New Book along with its Author and Genre
CREATE OR REPLACE PROCEDURE add_book(
    book_title VARCHAR(255),
    book_publication_year INTEGER,
    book_isbn VARCHAR(255),
    author_full_name VARCHAR(255),
    genre_name VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variables to hold author and genre IDs
    v_author_id INTEGER;
    v_genre_id INTEGER;
BEGIN
    -- Check if the author exists, if not, insert the author
    SELECT id INTO v_author_id FROM authors WHERE full_name = author_full_name;
    IF v_author_id IS NULL THEN
        INSERT INTO authors (full_name) VALUES (author_full_name) RETURNING id INTO v_author_id;
    END IF;

    -- Check if the genre exists, if not, insert the genre
    SELECT id INTO v_genre_id FROM genres WHERE name = genre_name;
    IF v_genre_id IS NULL THEN
        INSERT INTO genres (name) VALUES (genre_name) RETURNING id INTO v_genre_id;
    END IF;

    -- Insert the new book with references to the author and genre
    INSERT INTO books (title, publication_year, isbn, author_id, genre_id)
    VALUES (book_title, book_publication_year, book_isbn, v_author_id, v_genre_id);

    -- Commit the transaction
    COMMIT;
END;
$$
;


CALL add_book('The Great Gatsby', 1925, '9780743273565', 'F. Scott Fitzgerald', 'Novel');


-- Stored Procedure to Modify an Existing Book, Author, and Genre with NULL Checks
CREATE OR REPLACE PROCEDURE modify_book(
    book_id INTEGER,
    new_book_title VARCHAR(255),
    new_book_publication_year INTEGER,
    new_book_isbn VARCHAR(255),
    new_author_full_name VARCHAR(255),
    new_genre_name VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Variables to hold author and genre IDs
    v_author_id INTEGER;
    v_genre_id INTEGER;
BEGIN
    -- Check if the new author exists, if not, insert the new author
    IF new_author_full_name IS NOT NULL THEN
        SELECT id INTO v_author_id FROM authors WHERE full_name = new_author_full_name;
        IF v_author_id IS NULL THEN
            INSERT INTO authors (full_name) VALUES (new_author_full_name) RETURNING id INTO v_author_id;
        END IF;
        -- Update the book's author_id
        UPDATE books SET author_id = v_author_id WHERE id = book_id;
    END IF;

    -- Check if the new genre exists, if not, insert the new genre
    IF new_genre_name IS NOT NULL THEN
        SELECT id INTO v_genre_id FROM genres WHERE name = new_genre_name;
        IF v_genre_id IS NULL THEN
            INSERT INTO genres (name) VALUES (new_genre_name) RETURNING id INTO v_genre_id;
        END IF;
        -- Update the book's genre_id
        UPDATE books SET genre_id = v_genre_id WHERE id = book_id;
    END IF;

    -- Update the book with the new details, if provided
    IF new_book_title IS NOT NULL THEN
        UPDATE books SET title = new_book_title WHERE id = book_id;
    END IF;

    IF new_book_publication_year IS NOT NULL THEN
        UPDATE books SET publication_year = new_book_publication_year WHERE id = book_id;
    END IF;

    IF new_book_isbn IS NOT NULL THEN
        UPDATE books SET isbn = new_book_isbn WHERE id = book_id;
    END IF;

    -- Commit the transaction
    COMMIT;
END;
$$
;


CALL modify_book(1, 'The Great Gatsby Revised', 1926, '9780743273566', 'Francis Scott Fitzgerald', 'Classic Novel');

-- Stored Procedure to Delete a Book by ID
CREATE OR REPLACE PROCEDURE delete_book(
    book_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Delete the book from the books table
    DELETE FROM books WHERE id = book_id;

    -- Commit the transaction
    COMMIT;
END;
$$
;

CALL delete_book(1);


SELECT * FROM books;
SELECT * FROM authors;
SELECT * FROM genres;
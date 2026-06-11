-- ============================================================
--  Digital Library Management System — Database Setup
--  BIS402 Module 4 & 5 Project
--  30 books across 6 genres, 3-5 copies each
-- ============================================================

CREATE DATABASE IF NOT EXISTS digital_library;
USE digital_library;

-- ────────────────────────────────────────────────────────────
--  Table 1: Books
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS Books (
    book_id          INT PRIMARY KEY AUTO_INCREMENT,
    title            VARCHAR(100) NOT NULL,
    author           VARCHAR(100) NOT NULL,
    genre            VARCHAR(50)  NOT NULL,
    available_copies INT          NOT NULL DEFAULT 3
);

-- ────────────────────────────────────────────────────────────
--  Table 2: IssuedBooks
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS IssuedBooks (
    issue_id     INT PRIMARY KEY AUTO_INCREMENT,
    book_id      INT          NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    issue_date   DATE         NOT NULL,
    return_date  DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- ────────────────────────────────────────────────────────────
--  Clear old data and reload fresh (safe to run multiple times)
-- ────────────────────────────────────────────────────────────
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE IssuedBooks;
TRUNCATE TABLE Books;
SET FOREIGN_KEY_CHECKS = 1;

-- ────────────────────────────────────────────────────────────
--  Sample Books (30 books, 3-5 copies each, 6 genres)
-- ────────────────────────────────────────────────────────────
INSERT INTO Books (title, author, genre, available_copies) VALUES

-- FICTION (6 books)
('The Great Gatsby',               'F. Scott Fitzgerald',  'Fiction',    4),
('To Kill a Mockingbird',          'Harper Lee',           'Fiction',    5),
('1984',                           'George Orwell',        'Fiction',    4),
('Harry Potter & The Sorcerer''s Stone', 'J.K. Rowling',  'Fiction',    5),
('The Alchemist',                  'Paulo Coelho',         'Fiction',    3),
('Pride and Prejudice',            'Jane Austen',          'Fiction',    4),

-- SCIENCE (6 books)
('A Brief History of Time',        'Stephen Hawking',      'Science',    3),
('Sapiens',                        'Yuval Noah Harari',    'Science',    5),
('Cosmos',                         'Carl Sagan',           'Science',    4),
('Dune',                           'Frank Herbert',        'Science',    3),
('The Selfish Gene',               'Richard Dawkins',      'Science',    4),
('Astrophysics for People in a Hurry', 'Neil deGrasse Tyson', 'Science', 5),

-- HISTORY (5 books)
('Guns, Germs, and Steel',         'Jared Diamond',        'History',    4),
('The Art of War',                 'Sun Tzu',              'History',    5),
('A People''s History of the United States', 'Howard Zinn','History',   3),
('The Silk Roads',                 'Peter Frankopan',      'History',    4),
('Yukon Ho!',                      'Bill Watterson',       'History',    3),

-- TECHNOLOGY (5 books)
('Clean Code',                     'Robert C. Martin',     'Technology', 5),
('The Pragmatic Programmer',       'David Thomas',         'Technology', 4),
('Introduction to Algorithms',     'Thomas H. Cormen',     'Technology', 3),
('Design Patterns',                'Gang of Four',         'Technology', 4),
('The Mythical Man-Month',         'Frederick P. Brooks',  'Technology', 3),

-- BUSINESS (4 books)
('The Lean Startup',               'Eric Ries',            'Business',   4),
('Zero to One',                    'Peter Thiel',          'Business',   3),
('Good to Great',                  'Jim Collins',          'Business',   5),
('Rich Dad Poor Dad',              'Robert T. Kiyosaki',   'Business',   4),

-- SELF-HELP (4 books)
('Atomic Habits',                  'James Clear',          'Self-Help',  5),
('Deep Work',                      'Cal Newport',          'Self-Help',  4),
('The 7 Habits of Highly Effective People', 'Stephen Covey','Self-Help', 5),
('Think and Grow Rich',            'Napoleon Hill',        'Self-Help',  3);

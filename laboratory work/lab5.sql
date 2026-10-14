-- Task 1.1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name  TEXT,
    last_name   TEXT,
    age         INTEGER CHECK (age BETWEEN 18 AND 65),
    salary      NUMERIC CHECK (salary > 0)
);
 
-- Task 1.2
CREATE TABLE products_catalog (
    product_id     INTEGER,
    product_name   TEXT,
    regular_price  NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);
 
-- Task 1.3
CREATE TABLE bookings (
    booking_id     INTEGER,
    check_in_date  DATE,
    check_out_date DATE,
    num_guests     INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);
 
-- Task 1.4
INSERT INTO employees VALUES
    (1, 'Aigerim', 'Bekova',   25, 350000),
    (2, 'Ruslan',  'Akhmetov', 40, 600000);
 
INSERT INTO products_catalog VALUES
    (1, 'Laptop',     500000, 450000),
    (2, 'Headphones',  30000,  25000);
 
INSERT INTO bookings VALUES
    (1, '2026-11-01', '2026-11-05', 2),
    (2, '2026-12-20', '2026-12-27', 4);
 
-- INSERT INTO employees VALUES (3, 'Timur', 'Ospanov', 17, 200000);
-- ERROR: violates check constraint "employees_age_check" (age 17 < 18)
 
-- INSERT INTO employees VALUES (4, 'Dana', 'Omarova', 70, 300000);
-- ERROR: violates check constraint "employees_age_check" (age 70 > 65)
 
-- INSERT INTO employees VALUES (5, 'Arman', 'Seitkali', 30, 0);
-- ERROR: violates check constraint "employees_salary_check" (salary must be > 0)
 
-- INSERT INTO products_catalog VALUES (3, 'Mouse', 0, 5000);
-- ERROR: violates check constraint "valid_discount" (regular_price must be > 0)
 
-- INSERT INTO products_catalog VALUES (4, 'Keyboard', 20000, -100);
-- ERROR: violates check constraint "valid_discount" (discount_price must be > 0)
 
-- INSERT INTO products_catalog VALUES (5, 'Monitor', 100000, 120000);
-- ERROR: violates check constraint "valid_discount" (discount_price must be < regular_price)
 
-- INSERT INTO bookings VALUES (3, '2026-11-10', '2026-11-12', 0);
-- ERROR: violates check constraint "bookings_num_guests_check" (num_guests 0 < 1)
 
-- INSERT INTO bookings VALUES (4, '2026-11-10', '2026-11-12', 11);
-- ERROR: violates check constraint "bookings_num_guests_check" (num_guests 11 > 10)
 
-- INSERT INTO bookings VALUES (5, '2026-11-10', '2026-11-08', 2);
-- ERROR: violates check constraint "bookings_check" (check_out_date is before check_in_date)
 
 
-- Task 2.1
CREATE TABLE customers (
    customer_id       INTEGER NOT NULL,
    email             TEXT    NOT NULL,
    phone             TEXT,
    registration_date DATE    NOT NULL
);
 
-- Task 2.2
CREATE TABLE inventory (
    item_id      INTEGER   NOT NULL,
    item_name    TEXT      NOT NULL,
    quantity     INTEGER   NOT NULL CHECK (quantity >= 0),
    unit_price   NUMERIC   NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);
 
-- Task 2.3
INSERT INTO customers VALUES
    (1, 'aigerim@mail.kz', '+77011112233', '2026-01-15'),
    (2, 'ruslan@gmail.com', '+77774445566', '2026-02-20');
 
INSERT INTO inventory VALUES
    (1, 'USB-C Cable', 150,  3500, '2026-10-01 10:00'),
    (2, 'Power Bank',   35, 15000, '2026-10-02 14:30');
 
-- INSERT INTO customers VALUES (3, NULL, '+77050001122', '2026-03-01');
-- ERROR: null value in column "email" violates not-null constraint
 
-- INSERT INTO customers VALUES (4, 'timur@mail.kz', NULL, NULL);
-- ERROR: null value in column "registration_date" violates not-null constraint
 
-- INSERT INTO inventory VALUES (3, NULL, 10, 5000, '2026-10-03 09:00');
-- ERROR: null value in column "item_name" violates not-null constraint
 
-- INSERT INTO inventory VALUES (4, 'Phone Case', NULL, 5000, '2026-10-03 09:00');
-- ERROR: null value in column "quantity" violates not-null constraint
 
INSERT INTO customers VALUES
    (5, 'madina@mail.kz', NULL, '2026-04-10');
 
 
-- Task 3.1
CREATE TABLE users (
    user_id    INTEGER,
    username   TEXT UNIQUE,
    email      TEXT UNIQUE,
    created_at TIMESTAMP
);
 
-- Task 3.2
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id    INTEGER,
    course_code   TEXT,
    semester      TEXT,
    UNIQUE (student_id, course_code, semester)
);
 
INSERT INTO course_enrollments VALUES
    (1, 101, 'CSE1301', 'Fall 2026'),
    (2, 101, 'CSE1301', 'Spring 2027'),
    (3, 102, 'CSE1301', 'Fall 2026');
 
-- INSERT INTO course_enrollments VALUES (4, 101, 'CSE1301', 'Fall 2026');
-- ERROR: duplicate key value violates unique constraint
--        "course_enrollments_student_id_course_code_semester_key"
 
-- Task 3.3
ALTER TABLE users DROP CONSTRAINT users_username_key;
ALTER TABLE users DROP CONSTRAINT users_email_key;
 
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email    UNIQUE (email);
 
INSERT INTO users VALUES
    (1, 'aigerim', 'aigerim@mail.kz', '2026-10-01 09:00'),
    (2, 'ruslan',  'ruslan@gmail.com', '2026-10-02 12:00');
 
-- INSERT INTO users VALUES (3, 'aigerim', 'another@mail.kz', '2026-10-03 10:00');
-- ERROR: duplicate key value violates unique constraint "unique_username"
 
-- INSERT INTO users VALUES (4, 'timur', 'ruslan@gmail.com', '2026-10-03 11:00');
-- ERROR: duplicate key value violates unique constraint "unique_email"
 
 
-- Task 4.1
CREATE TABLE departments (
    dept_id   INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location  TEXT
);
 
INSERT INTO departments VALUES
    (1, 'IT',    'Almaty'),
    (2, 'Sales', 'Astana'),
    (3, 'HR',    'Almaty');
 
-- INSERT INTO departments VALUES (1, 'Marketing', 'Shymkent');
-- ERROR: duplicate key value violates unique constraint "departments_pkey"
 
-- INSERT INTO departments VALUES (NULL, 'Finance', 'Almaty');
-- ERROR: null value in column "dept_id" violates not-null constraint
 
-- Task 4.2
CREATE TABLE student_courses (
    student_id      INTEGER,
    course_id       INTEGER,
    enrollment_date DATE,
    grade           TEXT,
    PRIMARY KEY (student_id, course_id)
);
 
INSERT INTO student_courses VALUES
    (101, 1, '2026-09-01', 'A'),
    (101, 2, '2026-09-01', 'B+'),
    (102, 1, '2026-09-02', 'A-');
 
-- INSERT INTO student_courses VALUES (101, 1, '2026-09-05', 'C');
-- ERROR: duplicate key value violates unique constraint "student_courses_pkey"
 
-- Task 4.3
-- 1. UNIQUE vs PRIMARY KEY:
--    Both forbid duplicate values. PRIMARY KEY is also NOT NULL and is
--    the main identifier of a row that other tables reference.
--    UNIQUE allows NULL (several NULLs are allowed, because NULL is not
--    equal to NULL).
-- 2. Single-column vs composite PRIMARY KEY:
--    Single-column when one attribute identifies a row by itself
--    (dept_id, a surrogate id). Composite when a row is identified only by
--    a combination of values, e.g. a link table for an M:N relationship
--    like student_courses (student_id, course_id).
-- 3. Only one PRIMARY KEY, many UNIQUE:
--    A table has one main way to identify its rows, so there is one
--    PRIMARY KEY. Other candidate keys (email, username, isbn) are still
--    unique, so they are protected with UNIQUE constraints.
 
 
-- Task 5.1
CREATE TABLE employees_dept (
    emp_id    INTEGER PRIMARY KEY,
    emp_name  TEXT NOT NULL,
    dept_id   INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);
 
INSERT INTO employees_dept VALUES
    (1, 'Aigerim Bekova',   1, '2024-03-15'),
    (2, 'Ruslan Akhmetov',  2, '2023-06-01'),
    (3, 'Madina Karimova',  1, '2025-01-10');
 
-- INSERT INTO employees_dept VALUES (4, 'Timur Ospanov', 99, '2026-02-01');
-- ERROR: insert or update on table "employees_dept" violates foreign key
--        constraint "employees_dept_dept_id_fkey" (department 99 does not exist)
 
-- Task 5.2
CREATE TABLE authors (
    author_id   INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country     TEXT
);
 
CREATE TABLE publishers (
    publisher_id   INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city           TEXT
);
 
CREATE TABLE books (
    book_id          INTEGER PRIMARY KEY,
    title            TEXT NOT NULL,
    author_id        INTEGER REFERENCES authors(author_id),
    publisher_id     INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn             TEXT UNIQUE
);
 
INSERT INTO authors VALUES
    (1, 'Abai Kunanbayev',   'Kazakhstan'),
    (2, 'Mukhtar Auezov',    'Kazakhstan'),
    (3, 'George Orwell',     'United Kingdom');
 
INSERT INTO publishers VALUES
    (1, 'Foliant',         'Astana'),
    (2, 'Penguin Books',   'London'),
    (3, 'Mektep',          'Almaty');
 
INSERT INTO books VALUES
    (1, 'Book of Words',       1, 3, 1918, '978-601-00-0001-1'),
    (2, 'The Path of Abai',    2, 1, 1942, '978-601-00-0002-8'),
    (3, '1984',                3, 2, 1949, '978-0-452-28423-4'),
    (4, 'Animal Farm',         3, 2, 1945, '978-0-452-28424-1');
 
-- Task 5.3
CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);
 
CREATE TABLE products_fk (
    product_id   INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id  INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);
 
CREATE TABLE orders (
    order_id   INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
 
CREATE TABLE order_items (
    item_id    INTEGER PRIMARY KEY,
    order_id   INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity   INTEGER CHECK (quantity > 0)
);
 
INSERT INTO categories VALUES
    (1, 'Phones'),
    (2, 'Laptops');
 
INSERT INTO products_fk VALUES
    (1, 'iPhone 15',    1),
    (2, 'Galaxy S24',   1),
    (3, 'MacBook Air',  2);
 
INSERT INTO orders VALUES
    (1, '2026-10-01'),
    (2, '2026-10-05');
 
INSERT INTO order_items VALUES
    (1, 1, 1, 1),
    (2, 1, 3, 1),
    (3, 2, 2, 2);
 
-- DELETE FROM categories WHERE category_id = 1;
-- ERROR: update or delete on table "categories" violates foreign key
--        constraint "products_fk_category_id_fkey" on table "products_fk"
-- Result: RESTRICT blocks the delete because products 1 and 2 still
--         belong to category 1. Nothing is deleted.
 
SELECT * FROM order_items WHERE order_id = 1;
-- Result before delete: 2 rows (item_id 1 and 2)
 
DELETE FROM orders WHERE order_id = 1;
 
SELECT * FROM order_items WHERE order_id = 1;
-- Result after delete: 0 rows. CASCADE removed the order's items
-- automatically; item 3 of order 2 is still there.
 
 
-- Task 6.1
CREATE SCHEMA ecommerce;
 
CREATE TABLE ecommerce.customers (
    customer_id       INTEGER PRIMARY KEY,
    name              TEXT NOT NULL,
    email             TEXT NOT NULL UNIQUE,
    phone             TEXT,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE
);
 
CREATE TABLE ecommerce.products (
    product_id     INTEGER PRIMARY KEY,
    name           TEXT NOT NULL,
    description    TEXT,
    price          NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);
 
CREATE TABLE ecommerce.orders (
    order_id     INTEGER PRIMARY KEY,
    customer_id  INTEGER NOT NULL
                 REFERENCES ecommerce.customers(customer_id) ON DELETE RESTRICT,
    order_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    status       TEXT NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);
 
CREATE TABLE ecommerce.order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id        INTEGER NOT NULL
                    REFERENCES ecommerce.orders(order_id) ON DELETE CASCADE,
    product_id      INTEGER NOT NULL
                    REFERENCES ecommerce.products(product_id) ON DELETE RESTRICT,
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0)
);
 
INSERT INTO ecommerce.customers VALUES
    (1, 'Aigerim Bekova',   'aigerim@mail.kz',  '+77011112233', '2026-01-15'),
    (2, 'Ruslan Akhmetov',  'ruslan@gmail.com', '+77774445566', '2026-02-20'),
    (3, 'Madina Karimova',  'madina@mail.kz',   NULL,           '2026-03-02'),
    (4, 'Yerlan Sadykov',   'yerlan@gmail.com', '+77052223344', '2026-04-11'),
    (5, 'Asel Nurlanova',   'asel@mail.kz',     '+77019998877', '2026-05-28');
 
INSERT INTO ecommerce.products VALUES
    (1, 'iPhone 15',        'Smartphone, 128 GB',   450000, 12),
    (2, 'MacBook Air M3',   'Laptop, 13 inch',      620000,  5),
    (3, 'AirPods Pro 2',    'Wireless earbuds',     120000, 30),
    (4, 'USB-C Cable 1m',   'Charging cable',         3500, 150),
    (5, 'Power Bank 20000', '20000 mAh power bank',  15000, 35);
 
INSERT INTO ecommerce.orders VALUES
    (1, 1, '2026-09-01', 453500, 'delivered'),
    (2, 2, '2026-09-10', 620000, 'shipped'),
    (3, 3, '2026-09-15', 135000, 'processing'),
    (4, 4, '2026-10-01',   7000, 'pending'),
    (5, 1, '2026-10-05', 120000, 'cancelled');
 
INSERT INTO ecommerce.order_details VALUES
    (1, 1, 1, 1, 450000),
    (2, 1, 4, 1,   3500),
    (3, 2, 2, 1, 620000),
    (4, 3, 3, 1, 120000),
    (5, 3, 5, 1,  15000),
    (6, 4, 4, 2,   3500),
    (7, 5, 3, 1, 120000);
 
-- INSERT INTO ecommerce.products VALUES (6, 'Phone Case', 'Silicone case', -100, 10);
-- ERROR: violates check constraint "products_price_check"
 
-- INSERT INTO ecommerce.products VALUES (7, 'Mouse', 'Wireless mouse', 9000, -5);
-- ERROR: violates check constraint "products_stock_quantity_check"
 
-- INSERT INTO ecommerce.orders VALUES (6, 2, '2026-10-10', 5000, 'lost');
-- ERROR: violates check constraint "orders_status_check"
 
-- INSERT INTO ecommerce.order_details VALUES (8, 4, 5, 0, 15000);
-- ERROR: violates check constraint "order_details_quantity_check"
 
-- INSERT INTO ecommerce.customers VALUES (6, 'Timur Ospanov', 'aigerim@mail.kz', NULL, '2026-10-01');
-- ERROR: duplicate key value violates unique constraint "customers_email_key"
 
-- INSERT INTO ecommerce.customers VALUES (7, NULL, 'timur@mail.kz', NULL, '2026-10-01');
-- ERROR: null value in column "name" violates not-null constraint
 
-- INSERT INTO ecommerce.orders VALUES (7, 99, '2026-10-10', 5000, 'pending');
-- ERROR: violates foreign key constraint "orders_customer_id_fkey" (customer 99 does not exist)
 
-- DELETE FROM ecommerce.customers WHERE customer_id = 1;
-- ERROR: violates foreign key constraint "orders_customer_id_fkey"
-- Result: RESTRICT keeps the customer because orders 1 and 5 belong to them.
 
-- DELETE FROM ecommerce.products WHERE product_id = 4;
-- ERROR: violates foreign key constraint "order_details_product_id_fkey"
-- Result: RESTRICT keeps the product because it appears in order details.
 
DELETE FROM ecommerce.orders WHERE order_id = 5;
 
SELECT * FROM ecommerce.order_details WHERE order_id = 5;
-- Result: 0 rows.

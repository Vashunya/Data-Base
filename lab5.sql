--PART 1
--TASK 1.1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age >= 18 and age <= 65),
    salary NUMERIC CHECK (salary > 0)
);
--TASK 1.2
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price Numeric,
    CONSTRAINT valid_discount CHECK(
        regular_price > 0
        discount_price > 0
        discount_price < regular_price
    )
);
--TASK 1.3
CREATE TABLE bookings(
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK(num_guests >= 1 and num_guests <= 10),
    CHECK (check_out_date > check_in_date)
);
--TASK 1.4
INSERT INTO employees VALUES(1, 'Cristiano', 'Ronaldo', 40, 1000000);
INSERT INTO employees VALUES(2, 'Lionel', 'Messi', 37, 1000000);
INSERT INTO employees VALUES(3, 'Lamine', 'Yamal', 17, 100);
INSERT INTO employees VALUES(3, 'Mason', 'Mount', 26, -30000);
INSERT INTO products_catalog VALUES(1, 'Ball', 1000, 900);
INSERT INTO products_catalog VALUES(1, 'Boots', 10000, 9800);
INSERT INTO products_catalog VALUES(2, 'short', -1, 200);
INSERT INTO products_catalog VALUES(2, 'socks', 100, 200);
INSERT INTO booking VALUES(1, '2024-01-01', '2025-01-01', 5);
INSERT INTO booking VALUES(1, '2025-10-01', '2025-10-15', 5);
INSERT INTO booking VALUES(1, '2024-01-01', '2023-01-01', 5);
INSERT INTO booking VALUES(1, '2024-01-01', '2025-01-01', -1);
--PART 2
--TASK 2.1
CREATE TABLE customers(
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);
--TASK 2.2
CREATE TABLE inventory(
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);
--TASK 2.3
INSERT INTO customers VALUES(1, '111@gmail.com', '+777777777', '2025-01-01');
INSERT INTO customers VALUES(2, '777@gmail.com', NULL, '2025-01-01');
INSERT INTO inventory VALUES(1, 'ball', 100, 100, NOW());
INSERT INTO inventory VALUES(2, 'socks', 5, 5, NOW());
INSERT INTO customers VALUES(NULL, '112@gmail.com', '+787777777', '2025-01-01');
INSERT INTO customers VALUES(3, NULL, '+777776777', '2025-01-01');
INSERT INTO inventory VALUES(1, 'ball', -1, 100, NOW());
INSERT INTO inventory VALUES(2, 'socks', 5, 0, NOW());
--PART 3
--TASK 3.1
CREATE TABLE users(
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);
--TASK 3.2
CREATE TABLE course_enrollments(
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT UNIQUE (student_id, course_code, semester)
);
--TASK 3.3
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE(email);
INSERT INTO course_enrollments VALUES(1, 1, '7', '3');
INSERT INTO course_enrollments VALUES(1, 2, '7', '3');
INSERT INTO course_enrollments VALUES(1, 1, '7', '3');
INSERT INTO users VALUES(1, 'Ronaldo', 'cr7@gmail.com', NOW());
INSERT INTO users VALUES(2, 'Messi', 'lm10@gmail.com', NOW());
INSERT INTO users VALUES(3, 'Messi', 'leomessi@gmail.com', NOW());
--PART 4
--TASK 4.1
CREATE TABLE departments(
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);
INSERT INTO departments VALUES(1, 'IT', 'Almaty');
INSERT INTO departments VALUES(2, 'Manager', 'Astana');
INSERT INTO departments VALUES(3, 'Finance', 'Taraz');
INSERT INTO departments VALUES(1, 'Manager', 'Taraz');
INSERT INTO departments VALUES(NULL, 'IT', 'Almaty');
--TASK 4.2
CREATE TABLE student_courses(
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);
INSERT INTO student_courses VALUES(1, 1, '2025-05-15', 'A');
INSERT INTO student_courses VALUES(2, 1, '2025-05-15', 'B');
INSERT INTO student_courses VALUES(1, 2, '2025-05-15', 'A');
INSERT INTO student_courses VALUES(1, 1, '2025-05-15', 'B');
--TASK 4.3
--Primary key is not repeat and always only one on the table and can not be NULL. Unique can not be repeated in the table but can be NULL.
--We use single-column when one column uniquely identifies a record. And composite we use when uniqueness is defined by a combination of 2+ columns.
--Table can have only one primary key because it serves as the main identifier of rows, but can have unique instructions to make sure that coloms or combinations are different.
--PART 5
--TASK 5.1
CREATE TABLE employees_dept(
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments,
    hire_date DATE
);
INSERT INTO employees_dept VALUES(1, 'Lingard', 1, '2025-10-10');
INSERT INTO employees_dept VALUES(2, 'Maguier', 2, '2025-01-01');
INSERT INTO employees_dept VALUES(3, 'Onana', 29, '2025-09-10');
--TASK 5.2
CREATE TABLE authors(
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);
CREATE TABLE publishers(
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);
CREATE TABLE books(
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors,
    publisher_id INTEGER REFERENCES publishers,
    publication_year INTEGER,
    isbn TEXT UNIQUE
)ж
INSERT INTO authors VALUES(1, 'Bruno', 'England'),
(2, 'S.A.F', 'Scootland');
INSERT INTO publishers VALUES(1, 'Books', 'Manchester'),
(2, 'Paper', 'London');
INSERT INTO books VALUES(1, 'Portugal magnifico', 1, 1, 2020, '000-000-001'),
(2, 'Glory days', 2, 2, 2013, '777-777-777');
--TASK 5.3
CREATE TABLE categories(
    category_id integer PRIMARY KEY,
    category_name text NOT NULL
);
CREATE TABLE products_fk(
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories ON DELETE RESTRICT
);
CREATE TABLE orders(
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);
CREATE TABLE order_items(
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk,
    quantity INTEGER CHECK (quantity > 0)
);
INSERT INTO categories VALUES(1, 'Coach'),
(2, 'Player');
INSERT INTO products_fk VALUES(1, 'Ruben Amorim', 1),
(2, 'Benjamin Sesko', 2);
INSERT INTO orders VALUES(1, '2024-11-19'),
(2, '2025-08-09');
INSERT INTO order_items VALUES(1,1,1,2),
(2,1,2,1),
(3,2,1,1);
DELETE FROM catefories WHERE category_id = 1;
DELETE FROM orders WHERE order_id = 1;
--PART 6
--TASK 6.1
CREATE TABLE customers(
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0),
    stock_quantity INTEGER CHECK (stock_quantity >= 0)
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES customers ON DELETE CASCADE,
    order_date DAte NOt NULL,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT CHECK (status IN('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);
CREATE TABLE order_details(
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders ON DELETE CASCADE,
    product_id INTEGER REFERENCES products,
    quantity INTEGER CHECK (quantity > 0),
    unit_price NUMERIC CHECK (unit_price >=0 )
);
INSERT INTO customers VALUES
(1, 'Mbeumo', 'mbeumo@gmail.com', '+77777777777', '2025-01-01'),
(2, 'Cunha', 'cunha@gmail.com', '+77777777777', '2025-01-01'),
(3, 'Lammens', 'lammens@gmail.com', '+77777777777', '2025-01-01');
INSERT INTO customers VALUES
(4, 'Mbappe', 'mbappe@gmai.com', '+77777777777', NULL),
(5, 'Onana', 'lammens@gmail.com', '+77777777777', '2025-01-01');
INSERT INTO products VALUES
(1, 'Ball', 'ManUnt ball', 50, 70),
(2, 'Boots', 'Red', 70, 100),
(3, 'Short', 'ManUnt short', 100, 120);
INSERT INTO products VALUES
(4, 'Ticket', 'Match ticket', -20, 100),
(5, 'Food', 'Food on stadium', 30, -20);
INSERT INTO orders VALUES
(1, 1, '2025-01-01', 140, 'pending'),
(2, 2, '2025-01-01', 120, 'processing'),
(3, 3, '2025-01-01', 500, 'shipped');
INSERT INTO orders VALUES
(4, 4, '2025-01-01', -200, 'delivered'),
(5, 5, NULL, 100, 'cancelled');
INSERT INTO order_details VALUES
(1, 1, 1, 2, 70),
(2, 2, 3, 1, 120),
(3, 3, 2, 5, 100);
INSERT INTO order_details VALUES
(4, 4, 1, -2, 70),
(5, 5, 3, 5, -5);
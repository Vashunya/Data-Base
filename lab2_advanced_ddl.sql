-- 1
-- 1.1
CREATE DATABASE university_main 
    OWNER postgres 
    TEMPLATE template0 
    ENCODING 'UTF8';

CREATE DATABASE university_archive 
    CONNECTION LIMIT 50 
    TEMPLATE template0; 

CREATE DATABASE university_test 
    IS_TEMPLATE true 
    CONNECTION LIMIT 10;


-- 2
-- 2.1
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa DECIMAL(3,2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(10,2),
    is_tenured BOOLEAN,
    years_experience INTEGER
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8) NOT NULL,
    course_title VARCHAR(100) NOT NULL,
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee DECIMAL(8,2),
    is_online BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
);

-- 2.2
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER NOT NULL,
    professor_id INTEGER NOT NULL,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    duration INTERVAL
);

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    semester VARCHAR(20),
    year INTEGER,
    grade CHAR(2),
    attendance_percentage DECIMAL(4,1),
    submission_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE
);

-- 3
-- 3.1
-- студенты
ALTER TABLE students 
ADD COLUMN middle_name VARCHAR(30);

ALTER TABLE students 
ADD COLUMN student_status VARCHAR(20);

ALTER TABLE students 
ALTER COLUMN phone TYPE VARCHAR(20);

ALTER TABLE students 
ALTER COLUMN student_status SET DEFAULT 'ACTIVE';

ALTER TABLE students 
ALTER COLUMN gpa SET DEFAULT 0.00;


--профессоры 
ALTER TABLE professors 
ADD COLUMN department_code CHAR(5);

ALTER TABLE professors 
ADD COLUMN research_area TEXT;

ALTER TABLE professors 
ALTER COLUMN years_experience TYPE SMALLINT;

ALTER TABLE professors 
ALTER COLUMN is_tenured SET DEFAULT false;

ALTER TABLE professors 
ADD COLUMN last_promotion_date DATE;


-- курсы
ALTER TABLE courses 
ADD COLUMN prerequisite_course_id INTEGER;

ALTER TABLE courses 
ADD COLUMN difficulty_level SMALLINT;

ALTER TABLE courses 
ALTER COLUMN course_code TYPE VARCHAR(10);

ALTER TABLE courses 
ALTER COLUMN credits SET DEFAULT 3;

ALTER TABLE courses 
ADD COLUMN lab_required BOOLEAN DEFAULT false;

-- 3.2
-- расписание 
ALTER TABLE class_schedule 
ADD COLUMN room_capacity INTEGER;

ALTER TABLE class_schedule 
DROP COLUMN duration;

ALTER TABLE class_schedule 
ADD COLUMN session_type VARCHAR(15);

ALTER TABLE class_schedule 
ALTER COLUMN classroom TYPE VARCHAR(30);

ALTER TABLE class_schedule 
ADD COLUMN equipment_needed TEXT;


-- рекорды
ALTER TABLE student_records 
ADD COLUMN extra_credit_points DECIMAL(3,1);

ALTER TABLE student_records 
ALTER COLUMN grade TYPE VARCHAR(5);

ALTER TABLE student_records 
ALTER COLUMN extra_credit_points SET DEFAULT 0.0;

ALTER TABLE student_records 
ADD COLUMN final_exam_date DATE;

ALTER TABLE student_records 
DROP COLUMN last_updated;

-- 4
-- 4.1
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_code CHAR(5) NOT NULL,
    building VARCHAR(50),
    phone VARCHAR(15),
    budget DECIMAL(12,2),
    established_year INTEGER
);

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13) NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price DECIMAL(8,2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount DECIMAL(6,2),
    loan_status VARCHAR(20)
);

-- 4.2
-- 1
ALTER TABLE professors 
ADD COLUMN department_id INTEGER;

ALTER TABLE students 
ADD COLUMN advisor_id INTEGER;

ALTER TABLE courses 
ADD COLUMN department_id INTEGER;

-- 2
CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) NOT NULL,
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(3,2)
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20) NOT NULL,
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

-- 5
-- 5.1
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2) NOT NULL,
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(3,2),
    description TEXT  -- Добавленная колонка
);

DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20) NOT NULL,
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

--5.2 
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed; 
-- Part 1: Database Setup
-- 1.1: Create Sample Tables
CREATE TABLE departments (
dept_id INT PRIMARY KEY ,
dept_name VARCHAR(50),
location VARCHAR(50)
);
CREATE TABLE employees (
emp_id INT PRIMARY KEY ,
emp_name VARCHAR(100),
dept_id INT,
salary DECIMAL(10,2),
FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
proj_id INT PRIMARY KEY ,
proj_name VARCHAR(100),
budget DECIMAL(12,2),
dept_id INT,
FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),

-- Part 2: Creating Basic Views
-- 2.1: Create a Simple B-tree Index
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
-- 2 indexes exist - primary key index and emp_salary_idx
-- 2.2: Create an Index on a Foreign Key
CREATE INDEX emp_dept_idx ON employees(dept_id);
EXPLAIN SELECT * FROM employees WHERE dept_id = 101;
-- indexing foreign keys improves join performance and speeds up queries filtering by foreign key columns
-- 2.3: View Index Information
SELECT
tablename,
indexname,
indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- automatic indexes: departments_key, employees_key, projects_key

-- Part 3: Multicolumn Indexes
-- 3.1: Create a Multicolumn Index
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
-- no this idx would not help queries filtering only salary because column order matters

-- 3.2: Understanding Column Order
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
-- yes column order matters significantly, index a,b helps queries with where a = & or a = & and b = &< but not where b = & alone

-- Part 4: Unique Indexes
-- 4.1: Create a Unique Index
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
-- VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
-- Error: "duplicate key value violates unique constraint 'emp_email_unique_idx'"

-- 4.2: Unique Index vs UNIQUE Constraint
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
-- yes, b-tree was created fro unique constraint

-- Part 5: Indexes and Sorting
-- 5.1: Create an Index for Sorting
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;
-- desc idx eliminate sorting operations fro order by desc queries making then faster
-- 5.2: Index with NULL Handling
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

-- Part 6: Indexes on Expressions
-- 6.1: Create a Function-Based Index
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
-- without idx it 'd perform a full table scan and apply lower() to every row
-- 6.2: Index on Calculated Values
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));
SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- Part 7: Managing Indexes
-- 7.1: Rename an Index
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';
-- 7.2: Drop Unused Indexes
DROP INDEX emp_salary_dept_idx;
-- drop idx to reduce storage overhead and improve write performance
-- 7.3: Reindex
REINDEX INDEX employees_salary_index;

-- Part 8: Practical Scenarios
-- 8.1: Optimize a Slow Query
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
-- 8.2: Partial Index
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;
SELECT proj_name, budget
FROM projects
WHERE budget > 80000;
-- partial idx are smaller, faster to maintain and optimized for specific query patterns
-- 8.3: Analyze Index Usage
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
-- index scan means using idx, seq scan mans full table scan, idx scan indicates better performance

-- Part 9: Index Types Comparison
-- 9.1: Create a Hash Index
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
SELECT * FROM departments WHERE dept_name = 'IT';
-- use hash idx for equality-only operations, use b-tree for ranges, sorting and inequality operations
-- 9.2: Compare Index Types
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
SELECT * FROM projects WHERE proj_name > 'Database';

-- Part 10: Cleanup and Best Practices
-- 10.1: Review All Indexes
SELECT
schemaname,
tablename,
indexname,
pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- largest idx is typically on the largest table or column with unique values
-- 10.2: Drop Unnecessary Indexes
DROP INDEX IF EXISTS proj_name_hash_idx;
-- 10.3: Document Your Indexes
CREATE VIEW index_documentation AS
SELECT
tablename,
indexname,
indexdef,
'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;
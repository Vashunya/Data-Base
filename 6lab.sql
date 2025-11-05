-- Part 1: Database Setup
-- 1.1: Create Sample Tables
CREATE TABLE employees (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(50),
dept_id INT,
salary DECIMAL(10, 2)
);
CREATE TABLE departments (
dept_id INT PRIMARY KEY,
dept_name VARCHAR(50),
location VARCHAR(50)
);
CREATE TABLE projects (
project_id INT PRIMARY KEY,
project_name VARCHAR(50),
dept_id INT,
budget DECIMAL(10, 2)
);
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- Part 2: CROSS JOIN Exercises
-- 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
-- 5 employees * 4 department = 20 results
-- 2.2: Alternative CROSS JOIN Syntax
select e.emp_name, d.dept_name from employees e, departments d;
select e.emp_name, d.dept_name from employees e inner join departments d on true;
-- 2.3: Practical CROSS JOIN
select  e.emp_name,  p.project_name from employees e cross join projects p;
-- Part 3: INNER JOIN Exercises
-- 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- result will be 4 rows because  tom brown dept_id = null
-- 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- with on we 'd have 2 columns with same name e.dept_id and d.dept_id but with using columns with same name combine in 1
-- 3.3: NATURAL INNER JOIN
select emp_name, dept_name, location from employees natural inner join departments;
-- 3.4: Multi-table INNER JOIN
select e.emp_name, d.dept_name, p.project_name from employees e inner join departments d on e.dept_id = d.dept_id inner join projects p on d.dept_id = p.dept_id;
-- Part 4: LEFT JOIN Exercises
-- 4.1: Basic LEFT JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- tom brown will represent as null for all select columns expect name
-- 4.2: LEFT JOIN with USING
select e.emp_name, e.dept_id, d.dept_id, d.dept_name from employees e left join departments d using (dept_id);
-- 4.3: Find Unmatched Records
select e.emp_name, e.dept_id from employees e left join departments d on e.dept_id = d.dept_id where d.dept_id is null;
-- 4.4: LEFT JOIN with Aggregation
select d.dept_name, count(e.emp_id) as employee_count from departments d left join  employees e on d.dept_id = e.dept_id group by d.dept_id, d.dept_name order by employee_count desc;
-- Part 5: RIGHT JOIN Exercises
-- 5.1: Basic RIGHT JOIN
select e.emp_name, d.dept_name from employees e right join departments d on e.dept_id = d.dept_id;
-- 5.2: Convert to LEFT JOIN
select e.emp_name, d.dept_name from departments d left join employees e on d.dept_id = e.dept_id;
-- 5.3: Find Departments Without Employees
select d.dept_name, d.location from employees e right join departments d on e.dept_id = d.dept_id where e.emp_id is null;
-- Part 6: FULL JOIN Exercises
-- 6.1: Basic FULL JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
--
-- 6.2: FULL JOIN with Projects
select  d.dept_name, p.project_name, p.budget from departments d full join projects p on d.dept_id = p.dept_id;
-- 6.3: Find Orphaned Records
select
    case
        when e.emp_id is null then 'Department without
employees'
        when d.dept_id is null then 'Employee without
department'
        else 'Matched'
    end as record_status, e.emp_name, d.dept_name
from employees e full join  departments d  on e.dept_id = d.dept_id where e.emp_id is null or d.dept_id is null;
-- Part 7: ON vs WHERE Clause
-- 7.1: Filtering in ON Clause (Outer Join)
select e.emp_name, d.dept_name, e.salary from employees e left join departments d on e.dept_id = d.dept_id and d.location = 'Building A';
-- 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- with on clause filter is applied before join so all rows save and with where filter is applied after join so in table stays only rows with right condition
-- 7.3: ON vs WHERE with INNER JOIN
select e.emp_name, d.dept_name, e.salary from employees e inner join departments d on e.dept_id = d.dept_id and d.location = 'Building A';
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
inner join departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Part 8: Complex JOIN Scenarios
-- 8.1: Multiple Joins with Different Types
select d.dept_name, e.emp_name, e.salary, p.project_name, p.budget from departments d left join employees e on d.dept_id = e.dept_id left join projects p on d.dept_id = p.dept_id order by d.dept_name, e.emp_name;
-- 8.2: Self Join
alter table employees add column  manager_id int;
update  employees set  manager_id = 3 where emp_id = 1;
update  employees set  manager_id = 3 where emp_id = 2;
update  employees set  manager_id = null where emp_id = 3;
update  employees set  manager_id = 3 where emp_id = 4;
update  employees set  manager_id = 3 where emp_id = 5;
select e.emp_name as employee, m.emp_name as manager from employees e left join  employees m on e.manager_id = m.emp_id;
-- 8.3: Join with Subquery
select d.dept_name, avg(e.salary) as avg_salary from departments d inner join  employees e on d.dept_id = e.dept_id group by  d.dept_id, d.dept_name having  avg(e.salary) > 50000;
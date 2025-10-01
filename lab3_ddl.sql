--Part A
create database advanced_lab;

create table employees(
    emp_id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    department TEXT,
    salary INTEGER DEFAULT 0,
    hire_date DATE,
    status VARCHAR(15) DEFAULT 'Active'
)

create table departments(
    dept_id SERIAL PRIMARY KEY,
    dept_name TEXT,
    budget INTEGER,
    manager_id INTEGER
)

create table projects(
    project_id SERIAL PRIMARY KEY,
    project_name TEXT,
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
)
--Part B
--2
insert into employees (first_name, last_name, department) values('Vadim', 'Shumayev', 'IT');
--3
insert into employees (first_name, last_name, department, hire_date) values('Zlanat', 'Ibrahimovic', 'HR', '2025-09-15');
--4
insert into departments (dept_name, budget)
values
('IT', 100000),
('HR', 90000),
('Sales', 50000);
--5
insert into employees (first_name, last_name, department, salary, hire_date)
values ('Cristiano', 'Ronaldo', 'IT', 50000*1.1, CURRENT_DATE);
--6
create temporary table temp_employees as
select * from employees where department = 'IT';


--Part C
--7
UPDATE employees set salary = salary * 1.1;
--8
UPDATE employees set status = 'Senior' where salary > 60000 and hire_date < '2020-01-01';
--9
UPDATE employees set department = CASE 
    WHEN salary > 80000 THEN 'Management'
    when salary BETWEEN 50000 and 80000 then 'Senior'
    ELSE 'Junior'
END;
--10
UPDATE employees set department = Default WHERE status = 'Inactive';
--11
UPDATE departments set budget = (
    SELECT avg(salary) * 1.2
    from employees
    where employees.department = departments.dept_name
);
--12
UPDATE employees set salary = salary * 1.15, status = 'Promoted'
where department = 'Sales';

--Part D
--13
DELETE from employees
where status = 'Terminated';
--14
DELETE from employees
WHERE salary < 40000 and hire_date > '2023-01-01' and department is NULL;
--15
DELETE FROM departments 
where dept_id NOT IN (
    SELECT DISTINCT department
    FROM employees 
    WHERE department_id IS NOT NULL
);
--16
DELETE from projects where end_date < '2023-01-01' RETURNING *;

--Part E
--17
INSERT into employees (first_name, last_name, salary, department) VALUES('Andre', 'Onana', NULL, NULL);
--18
UPDATE employees set department = 'Unassigned' where department IS NULL;
--19
DELETE FROM employees WHERE salary IS NULL OR department IS NULL;

--Part F
--20
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Marcus', 'Rashford', 'IT', 75000)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;
--21
UPDATE employees SET salary = salary + 5000 WHERE department = 'IT' RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;
--22
DELETE FROM employees WHERE hire_date < '2020-01-01' RETURNING *;

--Part g
--23
INSERT INTO employees (first_name, last_name, department) SELECT 'Harry', 'Maguire', 'Management'
WHERE NOT EXISTS (
    SELECT 1 FROM employees 
    WHERE first_name = 'Harry' AND last_name = 'Maguire'
);
--24
UPDATE employees 
SET salary = CASE 
    WHEN department IN (
        SELECT dept_name FROM departments WHERE budget > 100000
    ) THEN salary * 1.10
    ELSE salary * 1.05
END;
--25
INSERT INTO employees (first_name, last_name, department, salary) VALUES
('Bruno', 'Fernandes', 'IT', 80000),
('Lisandro', 'Martinez', 'IT', 70000),
('Matheous', 'Cunha', 'Sales', 60000),
('Bryan', 'Mbeumo', 'IT', 75000),
('Kobbie', 'Mainoo', 'HR', 50000);
UPDATE employees SET salary = salary * 1.10 WHERE first_name IN ('Bruno', 'Lisandro', 'Matheous', 'Bryan', 'Kobbie');
--26
CREATE TABLE employee_archive AS SELECT * FROM employees WHERE 1 = 0;
INSERT INTO employee_archive SELECT * FROM employees WHERE status = 'Inactive';
DELETE FROM employees WHERE status = 'Inactive';
--27
UPDATE projects SET end_date = end_date + INTERVAL '30 days' WHERE budget > 50000 AND dept_id IN (
    SELECT dept_id 
    FROM departments 
    WHERE dept_name IN (
        SELECT department 
        FROM employees 
        GROUP BY department 
        HAVING COUNT(*) > 3
    )
);
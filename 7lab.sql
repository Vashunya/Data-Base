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

-- Part 2: Creating Basic Views
-- 2.1: Simple View Creation
create or replace view employee_details as
    select e.emp_name, e.salary, d.dept_name, d.location
from employees e join departments d on e.dept_id = d.dept_id;
-- because his dept_id is null => there no department in join
-- 2.2: View with Aggregation
create or replace view dept_statistics as
    select d.dept_name, count(e.emp_id) as employee_count,
           coalesce(avg(e.salary), 0) as avg_salary,
           coalesce(max(e.salary), 0) as max_salary,
           coalesce(min(e.salary), 0) as min_salary
from departments d left join employees e on d.dept_id = e.dept_id
group by d.dept_name;
-- 2.3: View with Multiple Joins
create or replace view project_overview as
    select  p.project_name,
            p.budget,
            d.dept_name,
            d.location,
            count(e.emp_id) as team_size
from projects p
left join departments d on p.dept_id = d.dept_id
left join employees e on p.dept_id = e.dept_id
group by p.project_name, p.budget, d.dept_name, d.location;
-- 2.4: View with Filtering
create or replace view high_earners as
select e.emp_name, e.salary, d.dept_name
from employees e
join departments d on e.dept_id = d.dept_id
where e.salary > 55000;
-- yes but not those who have no department

-- Part 3: Modifying and Managing Views
-- 3.1: Replace a View
create or replace view employee_details as
    select e.emp_name, e.salary, d.dept_name, d.location,
           case
               when e.salary > 60000 then 'high'
                when e.salary > 50000 then 'medium'
                else 'standard'
            end as salary_grade
from employees e join departments d on e.dept_id = d.dept_id;
-- 3.2: Rename a View
alter view high_earners rename to top_performers;
-- 3.3: Drop a View
create or replace view temp_view as
    select emp_name, salary
from employees where salary < 50000;
drop view temp_view;

-- Part 4: Updatable Views
-- 4.1: Create an Updatable View
create or replace view employee_salaries as
    select emp_id, emp_name, dept_id, salary
from employees;
-- 4.2: Update Through a View
update employee_salaries
set salary = 52000
where emp_name = 'John Smith';
-- 4.3 Insert Through a View
insert  into employee_salaries(emp_id, emp_name, dept_id, salary) VALUES (6, 'Alice Johnson', 102, 58000);
-- 4.4: View with CHECK OPTION
create or replace view it_employees as
    select emp_id, emp_name, dept_id, salary
from employees where dept_id = 101
with local check option;
-- INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
-- VALUES (7, 'Bob Wilson', 103, 60000);
-- dept_id is not 101 sp it will fail our check option

-- Part 5: Materialized Views
-- 5.1: Create a Materialized View
create materialized view dept_summary_mv as
    select
        d.dept_id,
        d.dept_name,
        count(distinct e.emp_id) as total_employees,
        coalesce(sum(e.salary), 0) as toral_salaries,
        count(distinct p.project_id) as total_projects,
        coalesce(sum(p.budget), 0) as total_budget
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
group by  d.dept_id, d.dept_name with data;
-- 5.2: Refresh Materialized View
insert into employees (emp_id, emp_name, dept_id, salary) values (9, 'Charlie Brown', 101, 54000);
refresh materialized view dept_summary_mv;
-- before data was old and after it includes new employee
-- 5.3: Concurrent Refresh
create unique index idx_dept_summary_mv_dept_id
on dept_summary_mv(dept_id);
refresh materialized view concurrently dept_summary_mv;
-- it allows refreshing without blocking read queries
-- 5.4: Materialized View with NO DATA
create materialized view project_stats_mv as
    select
        p.project_name,
        p.budget,
        d.dept_name,
        count(e.emp_id) as assigned_employees
from projects p
left join departments d on p.dept_id = d.dept_id
left join employees e on d.dept_id = e.dept_id
group by p.project_name, p.budget, d.dept_name with no data;
-- materialized view "project_stats_mv" has not been populated we need refresh materialized view project_stats_mv

-- Part 6: Database Roles
-- 6.1: Create Basic Roles
create role analyst;
create role data_viewer login password 'viewer123';
create user report_user password 'report456';
-- 6.2: Role with Specific Attributes
create role db_creator login createdb password 'creator789';
create role user_manager login createrole password 'manager101';
create role admin_user login superuser password 'admin999';
-- 6.3: Grant Privileges
grant select on employees, departments, projects to analyst;
grant all privileges on employee_details to data_viewer;
grant select, insert on employees to report_user;
-- 6.4: Create Group Roles
create role hr_team;
create role finance_team;
create role it_team;
create user hr_user1 password 'hr001';
create user hr_user2 password 'hr002';
create user finance_user1 password 'fin001';
grant hr_team to hr_user1, hr_user2;
grant finance_team to finance_user1;
grant select, update on employees to hr_team;
grant select on dept_statistics to finance_team;
-- 6.5: Revoke Privileges
revoke update on employees from hr_team;
revoke hr_team from hr_user2;
revoke all privileges on employee_details from data_viewer;
-- 6.6: Modify Role Attributes
alter role analyst login password 'analyst123';
alter role user_manager superuser;
alter role analyst password null;
alter role data_viewer connection limit 5;

-- Part 7: Advanced Role Management
-- 7.1: Role Hierarchies
create role read_only;
create role junior_analyst login password 'junior123';
create role senior_analyst login password 'senior123';
grant read_only to junior_analyst, senior_analyst;
grant insert, update on employees to senior_analyst;
-- 7.2: Object Ownership
create role project_manager login password 'pm123';
alter view dept_statistics owner to project_manager;
alter table projects owner to project_manager;
-- 7.3: Reassign and Drop Roles
create role temp_owner login ;
create table temp_table (id INT);
alter table temp_table owner to temp_owner;
reassign owned by temp_owner to postgres;
drop owned by temp_owner;
drop role temp_owner;
-- 7.4: Row-Level Security with Views
create or replace view hr_employee_view as
    select * from  employees where dept_id = 102;
grant select on hr_employee_view to hr_team;

create or replace view finance_employee_view as
    select emp_id, emp_name, salary from employees;
grant select on finance_employee_view to finance_team;

-- Part 8: Practical Scenarios
-- 8.1: Department Dashboard View
create or replace view dept_dashboard as
    select
        d.dept_name,
        d.location,
        count(distinct e.emp_id) as employee_count,
        round(coalesce(avg(e.salary), 0), 2) as avg_salary,
        count(distinct p.project_id) as active_projects,
        coalesce(sum(p.budget), 0) as total_budget,
        round(coalesce(sum(p.budget), 0) / nullif(count(distinct e.emp_id), 0), 2) as budget_per_employee
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
group by d.dept_name, d.location;
-- 8.2: Audit View
alter table projects
add column if not exists created_table timestamp default current_timestamp;
create or replace view high_budget_projects as
    select
        p.project_name,
        p.budget,
        d.dept_name,
        p.created_table,
        case
            when p.budget > 150000 then 'Critical Review Required'
            when p.budget > 100000 then 'Management Approval Needed'
            else 'Standard Process'
        end as approval_status
from projects p
left join departments d on p.dept_id = d.dept_id
where p.budget > 75000;
-- 8.3: Access Control System
create role viewer_role;
grant select on all tables in schema public to viewer_role;
grant select on all views in schema public to viewer_role;

create role entry_role;
grant viewer_role to entry_role;
grant insert on employees, projects to entry_role;

create role analyst_role;
grant entry_role to analyst_role;
grant update on employees, projects to analyst_role;

create role manager_role;
grant analyst_role to manager_role;
grant delete on employees, projects to manager_role;

create user alice password 'alice123';
create user bob password 'bob123';
create user charlie password 'charlie123';

grant viewer_role to alice;
grant analyst_role to bob;
grant manager_role to charlie;
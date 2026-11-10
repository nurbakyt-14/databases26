-- part 1: setup (run only when the lab 6 tables do not exist)
create table if not exists employees (
    emp_id int primary key,
    emp_name varchar(50),
    dept_id int,
    salary decimal(10, 2)
);
create table if not exists departments (
    dept_id int primary key,
    dept_name varchar(50),
    location varchar(50)
);
create table if not exists projects (
    project_id int primary key,
    project_name varchar(50),
    dept_id int,
    budget decimal(10, 2)
);
insert into employees values
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', null, 45000)
on conflict (emp_id) do nothing;
insert into departments values
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D')
on conflict (dept_id) do nothing;
insert into projects values
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', null, 200000)
on conflict (project_id) do nothing;

-- 2.1
create or replace view employee_details as
select e.emp_name, e.salary, d.dept_name, d.location
from employees e
join departments d on e.dept_id = d.dept_id;
select * from employee_details;

-- 2.2
create or replace view dept_statistics as
select d.dept_name, count(e.emp_id) as employee_count,
       round(avg(e.salary), 2) as avg_salary,
       max(e.salary) as max_salary, min(e.salary) as min_salary
from departments d
left join employees e on e.dept_id = d.dept_id
group by d.dept_id, d.dept_name;
select * from dept_statistics order by employee_count desc;

-- 2.3
create or replace view project_overview as
select p.project_name, p.budget, d.dept_name, d.location,
       (select count(*) from employees e where e.dept_id = p.dept_id) as team_size
from projects p
left join departments d on d.dept_id = p.dept_id;
select * from project_overview;

-- 2.4
create or replace view high_earners as
select e.emp_name, e.salary, d.dept_name
from employees e
left join departments d on d.dept_id = e.dept_id
where e.salary > 55000;
select * from high_earners;

-- 3.1: existing columns stay in the same order, new column goes last
create or replace view employee_details as
select e.emp_name, e.salary, d.dept_name, d.location,
       case
           when e.salary > 60000 then 'High'
           when e.salary > 50000 then 'Medium'
           else 'Standard'
       end as salary_grade
from employees e
join departments d on e.dept_id = d.dept_id;
select * from employee_details;

-- 3.2
alter view high_earners rename to top_performers;
select * from top_performers;

-- 3.3
create view temp_view as
select * from employees where salary < 50000;
drop view temp_view;

-- 4.1
create or replace view employee_salaries as
select emp_id, emp_name, dept_id, salary from employees;

-- 4.2
update employee_salaries set salary = 52000 where emp_name = 'John Smith';
select * from employees where emp_name = 'John Smith';

-- 4.3
insert into employee_salaries (emp_id, emp_name, dept_id, salary)
values (6, 'Alice Johnson', 102, 58000)
on conflict (emp_id) do nothing;
select * from employees where emp_id = 6;

-- 4.4
create or replace view it_employees as
select emp_id, emp_name, dept_id, salary
from employees where dept_id = 101
with local check option;
-- intentionally fails, run separately to see the error:
-- insert into it_employees (emp_id, emp_name, dept_id, salary)
-- values (7, 'Bob Wilson', 103, 60000);

-- 5.1: separately aggregate employees and projects to avoid multiplied totals
create materialized view dept_summary_mv as
select d.dept_id, d.dept_name,
       coalesce(e.total_employees, 0) as total_employees,
       coalesce(e.total_salaries, 0) as total_salaries,
       coalesce(p.total_projects, 0) as total_projects,
       coalesce(p.total_budget, 0) as total_budget
from departments d
left join (
    select dept_id, count(*) as total_employees, sum(salary) as total_salaries
    from employees group by dept_id
) e on e.dept_id = d.dept_id
left join (
    select dept_id, count(*) as total_projects, sum(budget) as total_budget
    from projects group by dept_id
) p on p.dept_id = d.dept_id
with data;
select * from dept_summary_mv order by total_employees desc;

-- 5.2
insert into employees (emp_id, emp_name, dept_id, salary)
values (8, 'Charlie Brown', 101, 54000)
on conflict (emp_id) do nothing;
select * from dept_summary_mv order by dept_id;
refresh materialized view dept_summary_mv;
select * from dept_summary_mv order by dept_id;

-- 5.3
create unique index dept_summary_mv_dept_id_idx on dept_summary_mv (dept_id);
refresh materialized view concurrently dept_summary_mv;

-- 5.4: lab 6 has no direct employee-to-project assignment.
-- this example counts employees of the project's department, not true assignees.
create materialized view project_stats_mv as
select p.project_name, p.budget, d.dept_name,
       (select count(*) from employees e where e.dept_id = p.dept_id) as department_employee_count
from projects p
left join departments d on d.dept_id = p.dept_id
with no data;
-- intentionally fails until refreshed:
-- select * from project_stats_mv;
refresh materialized view project_stats_mv;
select * from project_stats_mv;

-- 6.1
create role analyst nologin;
create role data_viewer login password 'viewer123';
create user report_user password 'report456';
select rolname from pg_roles where rolname not like 'pg_%';

-- 6.2: for an isolated lab database only; these attributes are powerful
create role db_creator createdb login password 'creator789';
create role user_manager createrole login password 'manager101';
create role admin_user superuser login password 'admin999';

-- 6.3
-- allow these roles to access public schema if public usage was revoked
 grant usage on schema public to analyst, data_viewer, report_user;
grant select on employees, departments, projects to analyst;
grant all privileges on employee_details to data_viewer;
grant select, insert on employees to report_user;

-- 6.4: the pdf text appears to mean password 'fin001' for finance_user1
create role hr_team nologin;
create role finance_team nologin;
create role it_team nologin;
create user hr_user1 password 'hr001';
create user hr_user2 password 'hr002';
create user finance_user1 password 'fin001';
grant hr_team to hr_user1, hr_user2;
grant finance_team to finance_user1;
grant usage on schema public to hr_team, finance_team;
grant select, update on employees to hr_team;
grant select on dept_statistics to finance_team;

-- 6.5
revoke update on employees from hr_team;
revoke hr_team from hr_user2;
revoke all privileges on employee_details from data_viewer;

-- 6.6
alter role analyst login password 'analyst123';
alter role user_manager superuser;
alter role analyst password null;
alter role data_viewer connection limit 5;

-- 7.1
create role read_only nologin;
grant usage on schema public to read_only;
grant select on all tables in schema public to read_only;
create role junior_analyst login password 'junior123';
create role senior_analyst login password 'senior123';
grant read_only to junior_analyst, senior_analyst;
grant insert, update on employees to senior_analyst;

-- 7.2: owner change requires suitable privileges and create permission on schema
create role project_manager login password 'pm123';
grant create on schema public to project_manager;
alter view dept_statistics owner to project_manager;
alter table projects owner to project_manager;
select tablename, tableowner from pg_tables where schemaname = 'public';

-- 7.3: expects role postgres to exist; substitute the actual admin owner if needed
create role temp_owner login;
create table temp_table (id int);
alter table temp_table owner to temp_owner;
reassign owned by temp_owner to postgres;
drop owned by temp_owner;
drop role temp_owner;
-- drop owned revokes any remaining privileges of this role in the current database.
-- because ownership was reassigned, temp_table remains.

-- 7.4: these are filtered views, not postgresql's native row-level security policies
create or replace view hr_employee_view as
select * from employees where dept_id = 102;
grant select on hr_employee_view to hr_team;
create or replace view finance_employee_view as
select emp_id, emp_name, salary from employees;
grant select on finance_employee_view to finance_team;

-- 8.1: lab 6 has no 'active' status; counts all assigned projects.
create or replace view dept_dashboard as
select d.dept_name, d.location,
       coalesce(e.employee_count, 0) as employee_count,
       coalesce(e.avg_salary, 0) as avg_salary,
       coalesce(p.project_count, 0) as active_projects,
       coalesce(p.total_budget, 0) as total_project_budget,
       round(coalesce(p.total_budget, 0) / nullif(coalesce(e.employee_count, 0), 0), 2) as budget_per_employee
from departments d
left join (
    select dept_id, count(*) as employee_count,
           round(avg(salary), 2) as avg_salary
    from employees group by dept_id
) e on e.dept_id = d.dept_id
left join (
    select dept_id, count(*) as project_count, sum(budget) as total_budget
    from projects group by dept_id
) p on p.dept_id = d.dept_id;
select * from dept_dashboard;

-- 8.2
alter table projects add column if not exists created_date timestamp default current_timestamp;
create or replace view high_budget_projects as
select p.project_name, p.budget, d.dept_name, p.created_date,
       case
           when p.budget > 150000 then 'Critical Review Required'
           when p.budget > 100000 then 'Management Approval Needed'
           else 'Standard Process'
       end as approval_status
from projects p
left join departments d on d.dept_id = p.dept_id
where p.budget > 75000;
select * from high_budget_projects;

-- 8.3
create role viewer_role nologin;
grant usage on schema public to viewer_role;
grant select on all tables in schema public to viewer_role;
create role entry_role nologin;
grant viewer_role to entry_role;
grant insert on employees, projects to entry_role;
create role analyst_role nologin;
grant entry_role to analyst_role;
grant update on employees, projects to analyst_role;
create role manager_role nologin;
grant analyst_role to manager_role;
grant delete on employees, projects to manager_role;
create user alice password 'alice123';
create user bob password 'bob123';
create user charlie password 'charlie123';
grant viewer_role to alice;
grant analyst_role to bob;
grant manager_role to charlie;

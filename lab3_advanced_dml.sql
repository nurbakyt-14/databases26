-- Part A
-- 1
create database advanced_lab;

\c advanced_lab;


create table employees(
    emp_id serial primary key,
    first_name varchar(80),
    last_name varchar(80),
    department varchar(80),
    salary integer,
    hire_date date,
    status varchar(80) default 'Active'
);


create table departments(
    dept_id serial primary key,
    dept_name varchar(80),
    budget integer,
    manager_id integer
);


create table projects(
    project_id serial primary key,
    project_name varchar(80),
    dept_id integer,
    start_date date,
    end_date date,
    budget integer
);

-- Part B
-- 2
insert into employees (emp_id, first_name, last_name, department)
values (1, 'Nurbakyt', 'Tolepbergen', 'IT');

-- 3
insert into employees (first_name, last_name, department, salary, status)
values ('Miras', 'Nurbolatuly', 'HR', default, default);

-- 4
insert into departments (dept_name, budget, manager_id)
values
    ('IT', 200000, 1),
    ('HR', 150000, 2),
    ('Finance', 120000, 3);

-- 5
insert into employees (first_name, last_name, department, salary, hire_date)
values ('Ernar', 'Aidar', 'Finance', 50000*1.1, now());


-- 6
create temp table temp_employees as
select *
from employees
where department = 'IT';


-- Part C
-- 7
update employees set salary = salary * 1.10;

-- 8
update employees set status = 'Senior' where salary > 60000 and hire_date < '2020-01-01';

-- 9
update employees set department = case
    when salary > 80000 then 'Management'
    when salary between 50000 and 80000 then 'Senior'
    else 'Junior'
end;


-- 10
update employees set department = default where status = 'Inactive';

-- 11
update departments d set budget = (
    select avg(salary) * 1.20
    from employees e
    where e.department = d.dept_name
)
where exists (
    select 1 from employees e where e.department = d.dept_name
);


-- 12
update employees set salary = salary * 1.15, status = 'Promoted'
where department = 'Sales';


-- Part D
-- 13
delete from employees where status = 'Terminated';

-- 14
delete from employees
where salary < 40000 and hire_date > '2023-01-01' and department is null;

-- 15
delete from departments where dept_id not in(
    select distinct dept_id
    from projects
    where dept_id is not null
);

-- 16
delete from projects where end_date < '2023-01-01'
returning *;

-- Part E
-- 17
insert into employees (first_name, last_name, salary, department)
values ('Kairat', 'Nurtas', null, null);

-- 18
update employees set department = 'Unassigned'
where department is null;

-- 19
delete from employees
where salary is null or department is null;

-- Part F
-- 20
insert into employees (first_name, last_name, department, salary)
values ('Nurbek', 'Armanov', 'IT', 75000)
returning emp_id, (first_name || ' ' || last_name) as full_name;

-- 21
update employees set salary = salary + 5000
where department = 'IT'
returning emp_id, salary - 5000 as old_salary, salary as new_salary;

-- 22
delete from employees where hire_date < '2020-01-01'
returning *;

-- Part G
-- 23
insert into employees (first_name, last_name, department, salary)
select 'Serik', 'Omarov', 'IT', 60000
where not exists (
    select 1 from employees
    where first_name = 'Serik' and last_name = 'Omarov'
);

-- 24
update employees e set salary = case
    when (select budget from departments d where d.dept_name = e.department) > 100000
        then salary * 1.10
    else salary * 1.05
end
where department is not null;

-- 25
insert into employees (first_name, last_name, department, salary) values
    ('Marat', 'Aliev', 'IT', 50000),
    ('Erasyl', 'Maksat', 'IT', 52000),
    ('Gulnaz', 'Galieva', 'IT', 54000),
    ('Daniyal', 'Bayurzhan', 'IT', 56000),
    ('Erkebulan', 'Esen', 'IT', 58000);

update employees
set salary = salary * 1.10
where department = 'IT';

-- 26
create table if not exists employee_archive (like employees including all);

with moved_rows as (
    delete from employees
    where status = 'Inactive'
    returning *
)
insert into employee_archive
select * from moved_rows;

-- 27
update projects
set end_date = end_date + interval '30 days'
where budget > 50000
  and dept_id in (
      select dept_id
      from employees
      group by dept_id
      having count(*) > 3
  );

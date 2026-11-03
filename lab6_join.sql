--tak 1.1
drop table if exists employees cascade ;
drop table if exists departments cascade ;
drop table if exists projects cascade ;

CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);

-- task 1.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

select * from employees;
select * from departments;
select * from projects;

--task 2.1
select e.emp_name, d.dept_name
from employees e
cross join departments d;

--task 2.2
-- a)
select e.emp_name, d.dept_name
from employees e, departments d;
--b)
select e.emp_name, d.dept_name
from employees e
inner join departments d on true;

--task 2.3
select e.emp_name, p.project_name
from employees e
cross join projects p;

--task 3.1
select e.emp_name, d.dept_name, d.location
from employees e
inner join departments d
on e.dept_id = d.dept_id;


-- task 3.2

select emp_name, dept_name, location
from employees
inner join departments using (dept_id);


-- task 3.3

select emp_name, dept_name, location
from employees
natural inner join departments;


-- task 3.4
-- join three tables to show employees, departments, and projects
select e.emp_name, d.dept_name, p.project_name
from employees e
inner join departments d
on e.dept_id = d.dept_id
inner join projects p
on d.dept_id = p.dept_id;


-- task 4.1

select
    e.emp_name,
    e.dept_id as emp_dept,
    d.dept_id as dept_dept,
    d.dept_name
from employees e
left join departments d
on e.dept_id = d.dept_id;


-- task 4.2

select emp_name, dept_id, dept_name
from employees
left join departments using (dept_id);


-- task 4.3
-- find employees without a matching department
select e.emp_name, e.dept_id
from employees e
left join departments d
on e.dept_id = d.dept_id
where d.dept_id is null;


-- task 4.4
-- count employees in each department
-- left join includes departments without employees
-- group by groups results by department
select d.dept_name, count(e.emp_id) as employee_count
from departments d
left join employees e
on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name
order by employee_count desc;


-- task 5.1

select e.emp_name, d.dept_name
from employees e
right join departments d
on e.dept_id = d.dept_id;


-- task 5.2

select e.emp_name, d.dept_name
from departments d
left join employees e
on e.dept_id = d.dept_id;


-- task 5.3

select d.dept_name, d.location
from employees e
right join departments d
on e.dept_id = d.dept_id
where e.emp_id is null;


-- task 6.1

select
    e.emp_name,
    e.dept_id as emp_dept,
    d.dept_id as dept_dept,
    d.dept_name
from employees e
full join departments d
on e.dept_id = d.dept_id;


-- task 6.2

select d.dept_name, p.project_name, p.budget
from departments d
full join projects p
on d.dept_id = p.dept_id;


-- task 6.3
-- find employees without departments and departments without employees
-- case identifies the type of unmatched record
-- full join includes unmatched rows from both tables
select
    case
        when e.emp_id is null then 'department without employees'
        when d.dept_id is null then 'employee without department'
        else 'matched'
    end as record_status,
    e.emp_name,
    d.dept_name
from employees e
full join departments d
on e.dept_id = d.dept_id
where e.emp_id is null or d.dept_id is null;


-- task 7.1
-- filter departments in the on clause
-- all employees remain in the result
select e.emp_name, d.dept_name, e.salary
from employees e
left join departments d
on e.dept_id = d.dept_id
and d.location = 'Building A';


-- task 7.2
-- filter departments in the where clause
-- only employees from building a remain
select e.emp_name, d.dept_name, e.salary
from employees e
left join departments d
on e.dept_id = d.dept_id
where d.location = 'Building A';


-- task 7.3 a

select e.emp_name, d.dept_name, e.salary
from employees e
inner join departments d
on e.dept_id = d.dept_id
and d.location = 'Building A';


-- task 7.3 b

select e.emp_name, d.dept_name, e.salary
from employees e
inner join departments d
on e.dept_id = d.dept_id
where d.location = 'Building A';


-- task 8.1
-- combine departments, employees, and projects
-- left joins keep departments without employees or projects
select
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
from departments d
left join employees e
on d.dept_id = e.dept_id
left join projects p
on d.dept_id = p.dept_id
order by d.dept_name, e.emp_name;


-- task 8.2
-- add a manager column to the employees table
alter table employees
add column manager_id int;
-- assign manager ids to employees
update employees set manager_id = 3 where emp_id = 1;
update employees set manager_id = 3 where emp_id = 2;
update employees set manager_id = null where emp_id = 3;
update employees set manager_id = 3 where emp_id = 4;
update employees set manager_id = 3 where emp_id = 5;
-- self join matches employees with their managers
-- left join includes employees without a manager
select
    e.emp_name as employee,
    m.emp_name as manager
from employees e
left join employees m
on e.manager_id = m.emp_id;


-- task 8.3
-- calculate average salary for each department
-- having filters departments with average salary above 50000
select d.dept_name, avg(e.salary) as avg_salary
from departments d
inner join employees e
on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name
having avg(e.salary) > 50000;


-- additional challenge 1

select e.emp_id, e.emp_name, d.dept_id, d.dept_name
from employees e
left join departments d
on e.dept_id = d.dept_id

union

select e.emp_id, e.emp_name, d.dept_id, d.dept_name
from employees e
right join departments d
on e.dept_id = d.dept_id;


-- additional challenge 2

select e.emp_name, d.dept_name
from employees e
inner join departments d
on e.dept_id = d.dept_id
where d.dept_id in (
    select dept_id
    from projects
    group by dept_id
    having count(*) > 1
);


-- additional challenge 3

select
    e.emp_name as employee,
    m.emp_name as manager,
    mm.emp_name as managers_manager
from employees e
left join employees m
on e.manager_id = m.emp_id
left join employees mm
on m.manager_id = mm.emp_id;


-- additional challenge 4

select
    e1.emp_name as employee1,
    e2.emp_name as employee2,
    e1.dept_id
from employees e1
inner join employees e2
on e1.dept_id = e2.dept_id
and e1.emp_id < e2.emp_id;
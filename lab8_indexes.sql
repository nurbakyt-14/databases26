CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

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
(203, 'HR System Upgrade', 50000, 102);

select * from departments;
select * from employees;
select * from projects;

--part 2
-- task 2.1
create index emp_salary_idx on employees(salary);

select indexname, indexdef
from pg_indexes
where tablename = 'employees';

-- question: How many indexes exist on the employees table?
-- answer : 2 index
-- employees_pkey - index which created by primary key
-- emp_salary_idx - index which I created

-- task 2.2
create index emp_dept_idx on employees(dept_id);

select * from employees where dept_id = 101;

-- question: Why is it beneficial to index foreign key columns?
-- answer : creating index to foreign key can make faster join operations and searches

-- task 2.3
select
    tablename,
    indexname,
    indexdef
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;

-- question: List all the indexes you see. Which ones were created automatically?
/*
 authors_pkey
books_isbn_key
books_pkey
categories_pkey
unique_enrollment
courses_code_key
courses_pkey
departments_pkey
dept_summary_mv_dept_id_idx
emp_dept_idx
emp_salary_idx
employees_pkey
employees_dept_pkey
enrollments_pkey
unique_seat
locations_pkey
order_items_pkey
orders_pkey
products_fk_pkey
projects_pkey
publishers_pkey
shipments_pkey
student_courses_pkey
unique_email
unique_username
users_email_key
users_username_key
warehouses_pkey
*/
-- indexes with _pkey created automatically by primary key

-- part 3
-- task 3.1
create index emp_dept_salary_idx on employees(dept_id, salary);

select emp_name, salary
from employees
where dept_id = 101 and salary > 52000;

-- question: Would this index be useful for a query that only filters by salary (without
-- dept_id)? Why or why not?
-- answer: searching based solely on `salary` is generally not very efficient, as the first column is `dept_id`. However, in some versions of PostgreSQL, an optimization such as "skip scan" might be used.

-- task 3.2
create index emp_salary_dept_idx on employees(salary, dept_id);

select * from employees where dept_id = 102 and salary > 50000;
select * from employees where salary > 50000 and dept_id = 102;

-- question: Does the order of columns in a multicolumn index matter? Explain.
-- answer :
/*
 Yes, but the order of the columns in the index matters.
 (dept_id, salary) - suitable for searching by department and filtering by salary.
 (salary, dept_id) - more oriented toward searching by salary.
 However, changing the order of the conditions within the `where` clause does not alter the logical result of these two queries.
 */

-- part 4
-- task 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

create unique index emp_email_unique_idx on employees(email);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (9, 'New Employee', 101, 55000, 'john.smith@company.com');

-- question: What error message did you receive?
-- answer: ERROR: duplicate key value violates unique constraint "emp_email_unique_idx"
-- because we already have this email

-- task 4.2
alter table employees add column phone varchar(20) unique;

select indexname, indexdef
from pg_indexes
where tablename = 'employees' and indexname like '%phone%';

-- question: Did PostgreSQL automatically create an index? What type of index?
-- answer: yes, postgresql create employees_phone_pkey index(unique btree index)

-- part 5
-- task 5.1
create index emp_salary_desc_idx on employees(salary desc);

select emp_name, salary from employees order by salary desc;

-- question : How does this index help with ORDER BY queries?
-- answer: index can allow data to be read in a sorted order, potentially reducing the need for a separate sort operation

-- task 5.2
create index proj_budget_nulls_first_idx on projects(budget nulls first);

select project_name, budget
from projects
order by budget nulls first;


-- part 6

-- task 6.1
create index emp_name_lower_idx
on employees(lower(emp_name));

select *
from employees
where lower(emp_name) = 'john smith';

-- question: Without this index, how would PostgreSQL search for names case-insensitively?
-- answer: it would usually use a sequential scan.


-- task 6.2
alter table employees
add column if not exists hire_date date;

update employees set hire_date = '2020-01-15' where emp_id = 1;
update employees set hire_date = '2019-06-20' where emp_id = 2;
update employees set hire_date = '2021-03-10' where emp_id = 3;
update employees set hire_date = '2020-11-05' where emp_id = 4;
update employees set hire_date = '2018-08-25' where emp_id = 5;

create index emp_hire_year_idx
on employees(extract(year from hire_date));

select emp_name, hire_date
from employees
where extract(year from hire_date) = 2020;


-- part 7

-- task 7.1
alter index emp_salary_idx
rename to employees_salary_index;

select indexname
from pg_indexes
where tablename = 'employees';


-- task 7.2
drop index if exists emp_salary_dept_idx;

-- question: Why might you want to drop an index?
-- answer: to save space and reduce write overhead.


-- task 7.3
reindex index employees_salary_index;

-- question: When is reindex useful?
-- answer: when an index is bloated or needs rebuilding.


-- part 8

-- task 8.1
select e.emp_name, e.salary, d.dept_name
from employees e
join departments d on e.dept_id = d.dept_id
where e.salary > 50000
order by e.salary desc;

create index emp_salary_filter_idx
on employees(salary)
where salary > 50000;


-- task 8.2
create index proj_high_budget_idx
on projects(budget)
where budget > 80000;

select project_name, budget
from projects
where budget > 80000;

-- question: What's the advantage of a partial index compared to a regular index?
-- answer: it is smaller and indexes only selected rows.


-- task 8.3
explain
select *
from employees
where salary > 52000;

-- question: Does the output show an "Index Scan" or a "Seq Scan" (Sequential Scan)? What does
-- this tell you?
-- answer: index scan uses an index; seq scan reads the table.
-- the actual result depends on the query plan.


-- part 9

-- task 9.1
create index dept_name_hash_idx
on departments using hash (dept_name);

select *
from departments
where dept_name = 'IT';

-- question: When should you use hash instead of b-tree?
-- answer: for equality searches when testing shows a benefit.


-- task 9.2
create index proj_name_btree_idx
on projects(project_name);

create index proj_name_hash_idx
on projects using hash (project_name);

-- equality search: both index types support it
select *
from projects
where project_name = 'Website Redesign';

-- range search: only b-tree supports it
select *
from projects
where project_name > 'Database';


-- part 10

-- task 10.1
select
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;

-- question: Which index is the largest? Why?
-- answer: dept_name_hash_idx is 32 kb
-- proj_name_hash_idx is 32 kb
-- hash indexes can use more space due to their structure.


-- task 10.2
drop index if exists proj_name_hash_idx;


-- task 10.3
create or replace view index_documentation as
select
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' as purpose
from pg_indexes
where schemaname = 'public'
and indexname like '%salary%';

select *
from index_documentation;


-- summary questions

-- question 1: what is the default index type?
-- answer: b-tree.

-- question 2: name three scenarios to create an index.
-- answer: frequent where, join and order by queries.

-- question 3: when should you not create an index?
-- answer: on tiny tables or rarely queried columns.

-- question 4: what happens during insert, update or delete?
-- answer: postgresql maintains the affected indexes.

-- question 5: how can you check index usage?
-- answer: using explain or explain analyze.


-- additional challenges

-- challenge 1: index for employees hired in a specific month
create index emp_hire_date_idx
on employees(hire_date);

select emp_name, hire_date
from employees
where hire_date >= '2020-01-01'
and hire_date < '2020-02-01';


-- challenge 2: composite unique index
create unique index emp_dept_email_unique_idx
on employees(dept_id, email);


-- challenge 3: compare query performance

-- with index scans discouraged
set enable_indexscan = off;
set enable_bitmapscan = off;

explain analyze
select *
from employees
where salary > 52000;

-- with normal planner settings
reset enable_indexscan;
reset enable_bitmapscan;

explain analyze
select *
from employees
where salary > 52000;


-- challenge 4: covering index
create index emp_covering_idx
on employees(dept_id)
include (emp_name, salary);

select emp_name, salary
from employees
where dept_id = 101;


-- reflection
-- indexes improve search performance.
-- they are useful for frequent queries on large tables.
-- too many indexes increase storage and write overhead.
-- explain helps check whether an index is used.

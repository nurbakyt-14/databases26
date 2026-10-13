--task 1.1

create table employees (
    employee_id integer,
    first_name text,
    last_name text,
    age integer check (age between 18 and 65),
    salary numeric check (salary > 0)
);

--task 1.2
create table products_catalog (
    product_id integer,
    product_name text,
    regular_price numeric,
    discount_price numeric,
    constraint valid_discount
        check (
            regular_price > 0
            and discount_price > 0
            and discount_price < regular_price
        )
);

-- task 1.3
create table bookings (
    booking_id integer,
    check_in_date date,
    check_out_date date,
    num_guests integer,
    check (num_guests between 1 and 100),
    check (check_out_date > check_in_date)
);

--task 1.4
insert into employees values
(1, 'Arman', 'Aliev', 25, 250000),
(2, 'Aliya', 'Nurbekova', 32, 320000);

insert into products_catalog values
(1, 'laptop', 400000, 350000),
(2, 'mouse', 10000, 8000);

insert into bookings values
(1, '2026-10-10', '2026-10-15', 2),
(2, '2026-10-20', '2026-10-22', 4);

select * from employees;
select * from products_catalog;
select * from bookings;

--test
-- age < 18
--insert into employees values (3, 'test', 'user', 16, 100000);
-- salary = 0
--insert into employees values (4, 'test', 'user', 25, 0);
--discount_price > regular_price
--insert into products_catalog values (3, 'tablet', 200000, 220000);
--num_guests > 10
--insert into bookings values (3, '2026-10-10', '2026-10-12', 12);
-- check_out_date < check_in_date
--insert into bookings values (4, '2026-10-15', '2026-10-14', 2);

-- task 2.1
create table customers (
    customer_id integer not null,
    email text not null,
    phone text,
    registration_date date not null
);

--task 2.2
create table inventory (
    item_id integer not null,
    item_name text not null,
    quantity integer not null check (quantity >= 0),
    unit_price numeric not null check (unit_price > 0),
    last_updated timestamp not null
);

--task 2.3
insert into customers values
(1, 'arman@example.com', '87071234567', '2026-10-01'),
(2, 'aliya@example.com', null, '2026-10-02');

insert into inventory values
(1, 'laptop', 10, 350000, current_timestamp),
(2, 'mouse', 25, 5000, current_timestamp);

select * from customers;
select * from inventory;

-- test
-- email cannot be null
-- insert into customers values (3, null, '87005554433', '2026-10-03');
-- quantity must be >= 0
-- insert into inventory values (3, 'keyboard', -1, 15000, current_timestamp);
-- unit_price must be >0
-- insert into inventory values (4, 'monitor', 5, 0, current_timestamp);

-- phone can be null
insert into customers values
(4, 'miras@example.com', null, '2026-10-04');

--task 3.1
create table users (
    user_id integer,
    username text unique,
    email text unique,
    created_at timestamp
);

-- task 3.2
create table course_enrollments (
    enrollment_id integer,
    student_id integer,
    course_code text,
    semester text,
    constraint unique_enrollment
        unique(student_id, course_code, semester)
);

--task 3.3
alter table users
add constraint unique_username unique(username);

alter table users
add constraint unique_email unique(email);

-- test
insert into users values
(1, 'arman', 'arman@gmail.com', current_timestamp);

insert into users values
(2, 'aliya', 'aliya@gmail.com', current_timestamp);

--insert into users values (3, 'arman', 'new@gmail.com', current_timestamp);

--task 4.1
create table departments (
    dept_id integer primary key,
    dept_name text not null,
    location text
);

create table departments (
    dept_id integer primary key,
    dept_name text not null,
    location text
);

insert into departments values
(1, 'Sales', 'Almaty'),
(2, 'Finance', 'Shymkent'),
(3, 'IT', 'Astana');

select * from departments;
--test
-- dept_id duplicate
-- insert into departments values (1, 'Physics', 'Astana');
-- primary key cannot be null
-- insert into departments values (null, 'Chemistry', 'Almaty');

-- task 4.2
create table student_courses (
    student_id integer,
    course_id integer,
    enrollment_id date,
    grade text,
    primary key(student_id, course_id)
);

-- task 4.3
-- 1. primary key: unique, not null; unique: prevents duplicates.
-- 2. single-column uses one column; composite uses multiple columns.
-- 3. primary key identifies each row; unique constraints ensure uniqueness of other columns.

-- task 5.1
create table employees_dept (
    emp_id integer primary key,
    emp_name text not null,
    dept_id integer references departments(dept_id),
    hire_date date
);

--test
insert into employees_dept values
(1, 'Arman', 1, '2025-06-01'),
(2, 'Aliya', 2, '2026-01-15');
-- insert into employees_dept values (3, 'dias', 99, '2026-02-01');

--task 5.2
create table authors (
    author_id integer primary key,
    author_name text not null,
    country text
);

create table publishers (
    publisher_id integer primary key,
    publisher_name text not null,
    city text
);

create table books (
    book_id integer primary key,
    title text not null,
    author_id integer references authors(author_id),
    publisher_id integer references publishers(publisher_id),
    publication_year integer,
    isbn text unique
);

insert into authors values
(1, 'Abish Kekilbayev', 'Kazakhstan'),
(2, 'Mukhtar Auezov', 'Kazakhstan'),
(3, 'Jules Verne', 'France');

insert into publishers values
(1, 'Bilim', 'Astana'),
(2, 'Atamura', 'Almaty'),
(3, 'Penguin Books', 'London');

insert into books values
(1, 'The end of the legend', 1, 1, 1999, '9780000000001'),
(2, 'The path of Abai', 2, 2, 1942, '9780000000002'),
(3, 'Journey to the center of the earth', 3, 3, 1864, '9780000000003');

select * from books;

--task 5.3
create table categories (
    category_id integer primary key,
    category_name text not null
);

create table products_fk (
    product_id integer primary key,
    product_name text not null,
    category_id integer references categories(category_id)
        on delete restrict
);

create table orders (
    order_id integer primary key,
    order_date date not null
);

create table order_items (
    item_id integer primary key,
    order_id integer references orders(order_id)
        on delete cascade,
    product_id integer references products_fk(product_id),
    quantity integer check (quantity > 0)
);

insert into categories values
(1, 'Electronics'),
(2, 'Accessories');

insert into products_fk values
(1, 'laptop', 1),
(2, 'mouse', 2);

insert into orders values
(1, '2026-10-10'),
(2, '2026-10-11');

insert into order_items values
(1, 1, 1, 1),
(2, 1, 2, 2),
(3, 2, 2, 1);

-- delete from categories where category_id = 1;

-- cascade: for order_id = 1
delete from orders where order_id = 1;

select * from orders;
select * from order_items;

-- task 6.1
create schema ecommerce;

create table ecommerce.customers (
    customer_id integer primary key,
    name text not null,
    email text not null unique,
    phone text,
    registration_date date not null
);

create table ecommerce.products (
    product_id integer primary key,
    name text not null,
    description text,
    price numeric(10, 2) not null check (price >= 0),
    stock_quantity integer not null check (stock_quantity >= 0)
);

create table ecommerce.orders (
    order_id integer primary key,
    customer_id integer not null
        references ecommerce.customers(customer_id)
        on delete restrict,
    order_date date not null,
    total_amount numeric(10, 2) not null check (total_amount >= 0),
    status text not null check (
        status in (
            'pending',
            'processing',
            'shipped',
            'delivered',
            'cancelled'
        )
    )
);

create table ecommerce.order_details (
    order_detail_id integer primary key,
    order_id integer not null
        references ecommerce.orders(order_id)
        on delete cascade,
    product_id integer not null
        references ecommerce.products(product_id)
        on delete restrict,
    quantity integer not null check (quantity > 0),
    unit_price numeric(10, 2) not null check (unit_price >= 0)
);

insert into ecommerce.customers values
(1, 'arman', 'arman@example.com', '87011234567', '2026-09-01'),
(2, 'aliya', 'aliya@example.com', '87015556677', '2026-09-02'),
(3, 'dias', 'dias@example.com', null, '2026-09-03'),
(4, 'madina', 'madina@example.com', '87017778899', '2026-09-04'),
(5, 'askar', 'askar@example.com', null, '2026-09-05');

insert into ecommerce.products values
(1, 'laptop', 'student laptop', 350000, 10),
(2, 'mouse', 'wireless mouse', 8000, 50),
(3, 'keyboard', 'mechanical keyboard', 25000, 20),
(4, 'monitor', '24 inch monitor', 90000, 15),
(5, 'headphones', 'wireless headphones', 18000, 30);

insert into ecommerce.orders values
(1, 1, '2026-10-01', 358000, 'delivered'),
(2, 2, '2026-10-02', 25000, 'shipped'),
(3, 3, '2026-10-03', 90000, 'processing'),
(4, 4, '2026-10-04', 18000, 'pending'),
(5, 5, '2026-10-05', 350000, 'cancelled');

insert into ecommerce.order_details values
(1, 1, 1, 1, 350000),
(2, 1, 2, 1, 8000),
(3, 2, 3, 1, 25000),
(4, 3, 4, 1, 90000),
(5, 4, 5, 1, 18000);

select * from ecommerce.customers;
select * from ecommerce.products;
select * from ecommerce.orders;
select * from ecommerce.order_details;

-- test the relationships
select
    o.order_id,
    c.name as customer_name,
    o.total_amount,
    o.status
from ecommerce.orders o
join ecommerce.customers c
    on o.customer_id = c.customer_id;

select
    od.order_id,
    p.name as product_name,
    od.quantity,
    od.unit_price
from ecommerce.order_details od
join ecommerce.products p
    on od.product_id = p.product_id;

-- test: duplicate email is not allowed
-- insert into ecommerce.customers values
-- (6, 'test', 'arman@example.com', null, '2026-10-06');

-- test: negative product price is not allowed
-- insert into ecommerce.products values
-- (6, 'test product', 'test', -100, 5);

-- test: negative stock is not allowed
-- insert into ecommerce.products values
-- (7, 'test product', 'test', 100, -5);

-- test: invalid status is not allowed
-- insert into ecommerce.orders values
-- (6, 1, '2026-10-06', 1000, 'waiting');

-- test: quantity must be positive
-- insert into ecommerce.order_details values
-- (6, 1, 2, 0, 8000);

-- test: nonexistent customer is not allowed
-- insert into ecommerce.orders values
-- (7, 99, '2026-10-07', 1000, 'pending');

-- test: nonexistent product is not allowed
-- insert into ecommerce.order_details values
-- (7, 1, 99, 1, 1000);
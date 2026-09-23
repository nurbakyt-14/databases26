create database fitness_template
with
    is_template = true
    limit connection = 5;


create database fitness_db with template = fitness_template

\connect fitness_db

create table members(
    member_id serial primary key,
    full_name varchar(80),
    card_number char(12),
    birth_date date,
    weight_kg numeric(10, 1),
    membership_fee decimal,
    is_premium boolean,
    joined_at timestamptz
);

create table session(
    session_id smallserial primary key,
    member_id integer,
    trainer_id smallint,
    session_date date,
    start_time time,
    duration interval,
    calories_burned numeric(10, 2)

);

alter table members
alter column card_number type varchar(16);

alter table members
add column phone varchar(20);

alter table members
alter column membership_fee set default(15000.00);

alter table session
alter column trainer_id type integer,
    drop column calories_burned;








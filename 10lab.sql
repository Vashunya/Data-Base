CREATE TABLE accounts (
id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL,
balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
id SERIAL PRIMARY KEY,
shop VARCHAR(100) NOT NULL,
product VARCHAR(100) NOT NULL,
price DECIMAL(10, 2) NOT NULL
);
INSERT INTO accounts (name, balance) VALUES
('Alice', 1000.00),
('Bob', 500.00),
('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
('Joe''s Shop', 'Coke', 2.50),
('Joe''s Shop', 'Pepsi', 3.00);

-- 3.2
begin;
update accounts
set balance = balance - 100.00
where name = 'Alice';
update accounts
set balance = balance + 100.00
where name = 'Bob';
commit;
-- a) select * from accounts; -> alice 900, bob 600
-- b) it is important because we need to take money from alice and send it to bob in same moment
-- c) Alice would lose her money and bob wouldn't get them

-- 3.3
begin;
update accounts
set balance = balance - 500
where name = 'Alice';
select * from accounts where name = 'Alice';
rollback;
select  * from accounts where name = 'Alice';
-- a) alice balance before rollback was 400
-- b) alice balance after rollback 900
-- c)

-- 3.4
begin;
update accounts
set balance = balance - 100.00
where name = 'Alice';
savepoint my_savepoint;
update accounts
set balance = balance + 100.00
where name = 'Bob';
rollback to my_savepoint;
update accounts
set balance = balance + 100.00
where name = 'Wally';
commit;
-- a) alice 800 bob 600 wally 850
-- b) no, because we did not commit new bob's balance
-- c) the advantage of using savepoint is we don't need to start all code from the start

-- 3.5
begin transaction isolation level read committed;
select * from products where shop='joe''s shop';
select * from products where shop='joe''s shop';
commit;

-- terminal 2
begin;
delete from products where shop='joe''s shop';
insert into products(shop, product, price) values ('joe''s shop','fanta',3.50);
commit;

-- a) sees old rows, then sees fanta
-- b) terminal1 sees snapshot without fanta
-- c) read committed allows changes, serializable blocks anomalies
begin transaction isolation level serializable;
select * from products where shop='joe''s shop';
select * from products where shop='joe''s shop';
commit;

-- 3.6 task 5 phantom
begin transaction isolation level repeatable read;
select max(price), min(price) from products where shop='joe''s shop';
select max(price), min(price) from products where shop='joe''s shop';
commit;

-- terminal 2
begin;
insert into products(shop, product, price) values ('joe''s shop','sprite',4.00);
commit;
-- a) no, repeatable read keeps snapshot
-- b) phantom = new rows appear
-- c) serializable prevents

-- 3.7 task 6 dirty read
begin transaction isolation level read uncommitted;
select * from products where shop='joe''s shop';
select * from products where shop='joe''s shop';
select * from products where shop='joe''s shop';
commit;

-- terminal 2
begin;
update products set price=99.99 where product='fanta';
rollback;
-- a) yes, dirty reads unsafe
-- b) reading uncommitted data
-- c) avoid read uncommitted

-- exercise 1
-- transfer 200 from bob to wally if enough
begin;
do $$ declare bal numeric; begin
select balance into bal from accounts where name='bob';
if bal>=200 then
update accounts set balance=balance-200 where name='bob';
update accounts set balance=balance+200 where name='wally';
else raise exception 'insufficient funds'; end if; end $$;
commit;

-- exercise 2
-- final state: product exists with updated price
begin;
insert into products(shop, product, price) values ('test shop','milk',1.00);
savepoint a;
update products set price=2.00 where shop='test shop' and product='milk';
savepoint b;
delete from products where shop='test shop' and product='milk';
rollback to a;
commit;

-- exercise 3
-- two withdrawals demonstrating isolation behavior
begin transaction isolation level read committed;
update accounts set balance = balance - 300 where name='alice';
commit;

-- exercise 4
-- broken max < min without transaction
select max(price) from sells where shop='joe''s shop';
select min(price) from sells where shop='joe''s shop';

-- fixed
begin;
select max(price) from sells where shop='joe''s shop';
select min(price) from sells where shop='joe''s shop';
commit;

-- self-assessment answers
-- 1 atomic: all or nothing; consistent: valid state; isolated: no interference; durable: survives crash
-- 2 commit saves, rollback undoes
-- 3 savepoint for partial undo
-- 4 isolation levels compare safety vs performance
-- 5 dirty read = uncommitted; allowed only in read uncommitted
-- 6 non-repeatable read = row changes between reads
-- 7 phantom = new rows; prevented by serializable
-- 8 read committed faster for high traffic
-- 9 transactions maintain consistency
-- 10 uncommitted data is lost
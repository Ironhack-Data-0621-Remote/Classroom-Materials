-- the where clause
select * from bank.order
where amount > 1000
order by amount asc;

select * from bank.order
where k_symbol = 'SIPO';

select order_id, account_id, bank_to, amount from bank.order
where k_symbol = 'SIPO';

select order_id as "OrderID", account_id as `AccountID`, bank_to as 'DestinationBank', amount  as 'Amount'
from bank.order
where k_symbol = 'SIPO';

-- where clause - multiple conditions
select * from bank.loan
where (status = 'B' or status = 'C') and amount > 100000; 
-- where status in ('B', 'C') and amount > 100000; 

select *
from bank.loan
where status = 'B' or status = 'D';
-- where status in ('B', 'D');

select *
from bank.loan
where (status = 'B' or status ='D') and not amount > 200000
order by amount desc;

-- basic arithmetic operations
select loan_id, account_id, date, duration, status, amount-payments as balance
from bank.loan;

select loan_id, account_id, date, duration, status, (amount-payments)/1000 as 'balance in Thousands'
from bank.loan;

-- this is the modulus operator that gives the remainder
select duration%2
from bank.loan;
-- where duration%2 = 1;


-- rounding
select order_id, round(amount/1000,2)
from bank.order;

select floor(avg(amount)) from bank.order;

select ceiling(avg(amount)) from bank.order;

-- checking the number of rows in the table, both methods give the same result
-- given that there are no nulls in the column in the second case:
select count(*) from bank.order;
select count(order_id) from bank.order;

-- max/min
select max(amount) from bank.order;
select min(amount) from bank.order;

-- 'string' operations
select *, length(k_symbol) as 'Symbol_length' from bank.order;
select *, concat('$', order_id, '-', account_id) as 'concat' from bank.order;

-- formats the number to a form with commas,
-- 2 is the number of decimal places, converts numeric to string as well
select *, format(amount, 2) from bank.loan;

select *, lower(A2), upper(A3) from bank.district;
-- It is interesting to note that select lower(A2), upper(A3), * from bank.district; doesn't work

select A2, left(A2,5), A3, ltrim(A3) from bank.district;
-- Similar to ltrim() there is rtrim() and trim() (to remove spaces). And similar to left() there is right() (to crop the value)

select *, substr(A2,3,6) from bank.district;

-- position
select A3, left(A3, position(' ' in A3)) as bla from district;
select position('-' in 'a-b');
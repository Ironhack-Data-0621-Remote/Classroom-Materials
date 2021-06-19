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
-- step1:
select round(avg(amount),2) as "Avg Amount", round(avg(payments),2) as "Avg Payment", status
from bank.loan
group by status
order by status;

-- step 2:
select round(avg(amount),2) - round(avg(payments),2) as "Avg Balance", status
from bank.loan
group by status
order by status;

select round(avg(amount-payments),2) as "Avg Balance", status
from bank.loan
group by status
order by status;

-- Find the average amount of transactions for each different kind of k_symbol
select round(avg(amount),2) as Average, k_symbol
from bank.order
group by k_symbol
order by Average asc;


select round(avg(amount),2) as Average, k_symbol 
from bank.order
where k_symbol <> ' '
group by k_symbol
order by Average asc;

select round(avg(amount),2) as Average, k_symbol 
from bank.order
where k_symbol != ' '
group by k_symbol
order by Average asc;


-- the same query with NOT operator

select round(avg(amount),2) as Average, k_symbol from bank.order
where not k_symbol = ' '
group by k_symbol
order by Average asc;

-- 65
-- city1(100) -> 70, city2(10)-> 90
-- city_name, school_name, student_name, score
-- select city_name, avg(score) as avg_score
-- from table
-- where city_name != 'Paris'
-- group by city_name
-- having avg_score > (select avg(score) from table)

-- multi column
select round(avg(amount),2) - round(avg(payments),2) as "Avg Balance", status, duration
from bank.loan
group by status, duration
order by status, duration;

select round(avg(amount),2) - round(avg(payments),2) as "Avg Balance", status, duration
from bank.loan
group by status, duration;
-- order by duration, status;

-- Query without the "order by" clause
select type, operation, k_symbol, round(avg(balance),2)
from bank.trans
group by type, operation, k_symbol;


-- Query with the "order by" clause
select type, operation, k_symbol, round(avg(balance),2) as avg_balance
from bank.trans
where k_symbol != ' '
group by type, operation, k_symbol
having avg_balance > 10000
order by type, operation, k_symbol;

-- having clause
select type, operation, k_symbol, round(avg(balance),2) as Average
from bank.trans
where k_symbol <> '' and k_symbol <> ' ' and  operation <> ''
group by type, operation, k_symbol
having Average > 30000
order by type, operation, k_symbol;

-- Not the most efficient way of using the HAVING clause

select type, operation, k_symbol, round(avg(balance),2) as Average
from bank.trans
where k_symbol <> '' and k_symbol != ' '
group by type, operation, k_symbol
having operation <> ''
order by type, operation, k_symbol;

-- Using the same query as before

select round(avg(amount),2) - round(avg(payments),2) as Avg_Balance, status, duration
from bank.loan
group by status, duration
having Avg_Balance > 100000
order by duration, status;


-- partitions
select loan_id, account_id, amount, payments, duration, amount-payments as "Balance",
avg(amount-payments) over (partition by duration) as Avg_Balance,
first_value(amount-payments) over (partition by duration) as Avg_Balance1,
last_value(amount-payments) over (partition by duration) as Avg_Balance2,
lag(amount-payments,2) over (partition by duration) as Avg_Balance3,
lead(amount-payments,2) over (partition by duration) as Avg_Balance4,
nth_value(amount-payments,2) over (partition by duration) as Avg_Balance5,
rank() over(order by duration)
from bank.loan
where amount > 100000
-- order by duration, balance desc; 
-- Some more Window Functions for your delight

-- Rank the customers based on the amount of loan borrowed
select *, rank() over (order by amount desc) as 'Rank'
from bank.loan
order by amount; 

select *, row_number() over (order by amount desc) as 'Row Number'
from bank.loan;
-- order by amount;

-- Rank the customers based on the amount of loan, in each of the "k_symbol" categories
select * , rank() over (partition by k_symbol order by amount desc) as "Ranks"
from bank.order
where k_symbol <> " ";
-- setting a partition will restart the rank for each group/window

-- Difference between rank and dense_rank
select amount, rank() over(order by amount asc) as 'RANK', dense_rank() over(order by amount asc) as 'DENSE_RANK', row_number() over(order by amount asc) as 'ROW_NUMBER'
from bank.order
where k_symbol <> ' ';

select *, dense_rank() over(order by amount asc) as 'RANK'
from bank.order
where k_symbol <> ' ';

-- they work very similar, the important difference is that:
-- if you have repeated values (ties), when transitioning to the next group/window:
  -- rank() skip the ranks according to the rows jumped and starts back from the row number.
  -- dense_rank() doesn't skip the ranks, starting back from the rank it left off from.
  
-- if you don't want the ranking repetition for ties, you can use row_number() instead.

-- More stuff you can do
select duration, sum(amount) , rank() over (order by sum(amount)) as 'Rank'
from bank.loan
group by duration;
-- order by duration; 

select * from bank.loan;


-- JOINS

select * from bank.account a
join bank.loan l on a.account_id = l.account_id -- inner join -- using (account_id)
where l.duration = 12
order by l.payments;
limit 10;

select a.account_id, a.frequency, d.A1, d.A2, l.loan_id, l.amount, l.duration
from bank.account a
join bank.loan l on a.account_id = l.account_id
join bank.district d on a.district_id = d.A1
limit 10;

-- Left/Right Joins
-- checking rows in tables
select count(distinct account_id) from bank.account;
select count(distinct account_id) from bank.loan;
-- not all the account_ids have information available from the order table,
-- so, not all the customers have taken a loan from the bank

-- Left Join
select a.account_id, a.frequency, l.loan_id, l.amount, l.duration, l.payments, l.status
from bank.account a
left join bank.loan l on l.account_id = a.account_id
order by a.account_id;
-- LEFT JOIN keeps everything from the left table (table in FROM statement)

-- Right Join
select a.account_id, a.frequency, l.loan_id, l.amount, l.duration, l.payments, l.status
from bank.account a
left join bank.loan l on a.account_id = l.account_id
order by a.account_id;
-- RIGHT JOIN keeps everything from the left table (table in JOIN statement)

-- Full outer join
SELECT * FROM account a
LEFT JOIN district d ON a.district_id = d.A1
UNION
SELECT * FROM account a
RIGHT JOIN district d ON a.district_id = d.A1;

/*
*/

-- Activity 01:
-- 01 Rank districts by different variables.
select A2, A12, dense_rank() over(order by A12) as Unemployment_Rate
from bank.district;
-- 02 Do the same but group by region.
select A2, A3, dense_rank() over(partition by A3 order by A2) as region
from bank.district;

-- Activity 02:
-- Use the transactions table in the bank database to find the Top 20 account_ids based on the amount.
select account_id, amount, DENSE_RANK() over(order by amount desc) as Top20
from bank.trans
Limit 20;
-- Illustrate the difference between rank() and dense_rank().
select account_id, amount, DENSE_RANK() over(order by amount desc) as Top20, RANK() over(order by amount desc) as Ranked20
from bank.trans
Limit 20;

-- Activity 3
-- 1
select count(client_id) as 'Client', rank () over (order by count(client_id)) from client
group by district_id;
-- 2
select count(client_id) as NofClients, A3, rank() over (order by count(client_id)) as 'Rank' from client a
join district l on a.district_id = l.A1
group by A3
order by NofCLients;
-- 3
select sum(amount) as TotalAmount, avg(amount) as AvgLoan, district_id from disp a
join loan l on a.account_id = l.account_id
join client d on a.client_id = d.client_id
group by district_id
order by district_id;
-- 4
select district_id, substr(date,1,2) as 'Year', count(a.account_id) as NumberofAccounts from disp a
join client d on a.client_id = d.client_id
join trans l on a.account_id = l.account_id
group by district_id, 'Year'
order by district_id;
select district_id, count(account_id), substr(date,1,2) as 'year' from bank.account
group by district_id, 'year';
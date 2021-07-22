-- Common Table Expressions (CTE):
-- stores temporarily results of a query, exists only within the query;
-- improves readability and performance of the query.

-- Syntax:
with cte_loan as (
  select * from bank.loan
)
select * from cte_loan
where status = 'B';

-- same as:
select * from bank.loan
where status = 'B';

-- return all the account information, and also the total amount and total balance of each account
with cte_transactions as (
  select account_id, sum(amount), sum(balance)
  from bank.trans
  group by account_id
)
select * from cte_transactions ct
join account a
on ct.account_id = a.account_id;


/*
*/

-- Views:
-- virtual tables in the database that can be used for querying, like a regular table
-- but they do not store any information permanently in them, not occupying memory in the DB.

-- Good for:
-- *Security*: Different users can be given access to different sets of views and not the complete database
-- *Query simplicity*: It can help write neater and simplified query by not using many levels of nesting.

create view loan_status_B as
select * from bank.loan
where status = 'B';

select * from loan_status_B;

-- removing views:
drop view if exists loan_status_B;
-- overwritting views:
create or replace view loan_status_B as
select * from bank.loan
where status = 'B';

-- return the customers in status C that have total balance more than the average balance for that status: 
select * from loan;

create view running_contract_ok_balances as
with cte_running_contract_OK_balances  as (
  select *, amount-payments as Balance
  from bank.loan
  where status = 'C'
  order by Balance
)
select * from cte_running_contract_OK_balances
where Balance > (
  select avg(Balance)
  from cte_running_contract_OK_balances
)
order by Balance desc
limit 20;

select * from running_contract_ok_balances;

-- How:
-- step 1: start with what you know:
select *, amount-payments as Balance
from bank.loan
where status = 'C'
order by Balance;

-- we realize some operations can be applied on the previous query to compare the balance with the avg balance
-- step 2: start the main query
select * from (step 1)
where Balance > ?;

-- we know the query on step 1 will go on the FROM statement of query on step 2,
-- now we need the query that goes in the WHERE statement
-- step 3: calculate the average balance
select avg(Balance) from (step 1);

-- we realize step 2 and 3 will use the query on step 1, so having a CTE will definitely improve performance (will run the query on step 1 just once)
-- step 4: use step 1 query, that would be used as subquery for step 2 and 3 queries, as CTE
with cte_running_contract_OK_balances as (
  select *, amount-payments as Balance
  from bank.loan
  where status = 'C'
  order by Balance
)
-- step 5: use the CTE
select * from cte_running_contract_OK_balances
where Balance > (
  select avg(Balance)
  from cte_running_contract_OK_balances
)
order by Balance desc
limit 20;
-- OBS.1: step 4 and 5 are in the same query.
-- OBS.2: the order of the reasoning is still the same from last classes, with some more complexity to the steps.


-- Views with check option:
-- WITH CHECK OPTION prevents a view from updating or inserting rows
create view customer_status_D as
select * from bank.loan
where status = 'D'
with check option;

insert into customer_status_D values (0000, 00000, 987398, 00000, 60, 00000, 'C');

/*
*/

-- Recap Plus:

-- Nested Subqueries in FROM statement
-- for each (group), find the (secondary group) with the (condition with aggregated value)
-- for each duration, find the status with the highest total amount:

-- if i have a group and a subgroup/secondary group, and i need to pick for each group one row from the secondary group,
-- a window function is likely to solve my problem
select duration, status, total, ranking
from (
	select *, row_number() over (partition by duration order by total desc) ranking
	from (
		select duration, status, sum(amount) total from bank.loan
		group by duration, status
		order by duration, status
	) as sub1
) as sub2
where ranking = 1;

-- doing it with ctes:
with cte1 as (
	 select duration, status, sum(amount) total from bank.loan
	 group by duration, status
	 order by duration, status
	),
	 cte2 as (
	 select *, row_number() over (partition by duration order by total desc) ranking
	 from cte1
	)
select duration, status, total 
from cte2
where ranking = 1;


-- Correlated Subqueries:
-- processes once for every row, instead of just once as in self-contained subqueries.

-- return the loans where the amount is greater than the average amount per status:
select status, avg(amount) as average
from bank.loan
group by status
order by status;

select * from bank.loan l1
where amount > (
  select avg(amount) as average
  from bank.loan
  where status = l1.status
);


-- 3.06 Activity 1
with cte_min_date_per_district as (
	select district_id, min(date) date
	from bank.account
	group by district_id)
select * from cte_min_date_per_district cte
join account a on cte.district_id = a.district_id and cte.date = a.date
order by a.district_id;


-- 3.06 Activity 2
-- create a view last_week_withdrawals with total withdrawals by client in the last week:
-- step 1: get every table we'll need (disp for client_id and trans for the withdrawals)
select *
from bank.disp
left join trans
using (account_id);

-- step 2: try to get what you want
select client_id, sum(amount) total_withdrawal
from bank.disp
left join trans
using (account_id)
where date > ?
group by client_id;

-- step 3: find the last day and think of how to get a week from that
select max(date)-7 max_date from trans order by week(date) desc; -- ?
-- let's use date_sub to avoid common date problems when simply subtracting
select date_sub(max(date), interval 7 day) max_date from trans;

-- step 4: put it together
select client_id, sum(amount) total_withdrawal
from bank.disp
left join trans
using (account_id)
where date(date) > (select date_sub(max(date), interval 7 day) max_date from trans)
group by client_id;

-- step 5: create the view and prettify
create or replace view last_week_withdrawals as
select client_id, round(sum(amount)) total_withdrawal
from bank.disp
left join trans
using (account_id)
where date(date) > (select date_sub(max(date), interval 7 day) max_date from trans)
group by client_id
order by client_id;

select * from last_week_withdrawals;

-- 3.06 Activity 3
-- The table client has a field birth_number that encapsulates client birthday and sex.
-- The number is in the form YYMMDD for men, and in the form YYMM+50DD for women, where YYMMDD is the date of birth.
-- Create a view client_demographics with client_id, birth_date and sex fields. Use that view and a CTE to find the number of loans by status and sex.
select * from client;

-- step 1: create the demographics view
create or replace view client_demographics as
select
  client_id,
  case when substr(birth_number, 3, 2) > 12 then birth_number-5000 else birth_number end birth_date, -- YY MM+50 DD
  case when substr(birth_number, 3, 2) > 12 then 'F' else 'M' end gender
from bank.client;

select * from client_demographics;

-- step 2: get all the tables you'll need
select a.account_id, c.client_id, c.gender, l.status
from account a
join disp d using (account_id)
join client_demographics c using (client_id)
join loan l using (account_id);

-- step 3: i could group by (aggregate) to find the number of loans per gender and status - M and F on the same column
select status, gender, count(loan_id)
from account a
join disp d using (account_id)
join client_demographics c using (client_id)
join loan l  using (account_id)
group by gender, status
order by gender, status;

-- using ctes instead - M and F on the same row
with loan_info as
(
  select
    status,
    case when gender = 'M' then 1 else 0 end M, -- if(gender = 'M', 1, 0)
    case when gender = 'F' then 1 else 0 end F
  from account a
  join disp d using (account_id)
  join client_demographics c using (client_id)
  join loan l using (account_id)
)
select status, sum(M) as M, sum(F) as F
from loan_info
group by status;


-- 3.06 Activity 4
-- the query to help me understand the problem
select district_id, avg(amount) from account a
join district d on d.A1 = a.district_id
join loan l using(account_id)
group by district_id
order by district_id;

-- the query to solve the problem
SELECT account_id, district_id, amount FROM account a
JOIN district d on d.A1 = a.district_id
JOIN loan l using(account_id)
where amount > (
	SELECT avg(amount) FROM account
	JOIN district d on d.A1 = a.district_id
	JOIN loan l using(account_id)
	WHERE district_id = a.district_id
); 

-- to check if the query is alright
select district_id, avg(amount) from account a
join district d on d.A1 = a.district_id
join loan l using(account_id)
where district_id = 45;

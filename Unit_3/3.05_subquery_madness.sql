-- Subqueries Platinum Plus Deluxe

-- Subqueries in WHERE statement:
-- identify the customers who borrowed an amount which is higher than the average:
 
 -- step 1 --> start your main query
select * from bank.loan
where amount > ? ; -- avg(amount) won't work, WHERE clause doesn't take agg functions

-- step 2 --> create a query that returns the average (this will be the subquery)
select avg(amount) from bank.loan;

-- step 3 --> place the subquery in the main query
select * from bank.loan
where amount > (
  select avg(amount)
  from bank.loan
);

-- step 4 --> prettify the result
select * from bank.loan
where amount > (select avg(amount) from bank.loan)
order by amount
limit 10;


-- Subqueries with IN statement:
-- return the rows in the 'order' table, for the banks in which the average amount transfered is higher than 5500:
select * from bank.trans;

-- step 1: find the banks where the avg amount is higher than 5500
select bank, avg(amount) as Average
from bank.trans
where bank <> ''
group by bank
having Average > 5500;

-- if we hard coded, this is what it would look like:
select * from bank.order
where bank_to in ('ST', 'UV', 'GH');

-- step 2: use the previous query as a 'list' to filter our result
select * from bank.order
where bank_to in (
  select bank from (
    select bank, avg(amount) as Average
    from bank.trans
    where bank <> ''
    group by bank
    having Average > 5500
    ) sub1
)
and k_symbol <> ' ';

-- return the rows in 'order' table with the k_symbols whose average amount is bigger than 3000:
-- step 1: return the k_symbols with the average amount bigger than 3000
select k_symbol
from bank.order
where k_symbol <> ' '
group by k_symbol
having avg(amount) > 3000;

-- if i hardcoded:
select * from bank.trans
where k_symbol in ('SIPO', 'UVER');

-- if i apply the subquery straight ahead, it'll take forever:
select * from bank.trans
where k_symbol in (
	select k_symbol
	from bank.order
	where k_symbol <> ' '
	group by k_symbol
	having avg(amount) > 3000
);

-- step 2: making an apparently unecessary subquery because of performance issues
select k_symbol as symbol from (
    select k_symbol
    from bank.order
    where k_symbol <> ' '
    group by k_symbol
    having avg(amount) > 3000
) sub1;
    
-- step 3: putting the 'list' returned from the previous query in the IN statement, resulting in a nested subquery
select * from bank.trans
where k_symbol in (
    select k_symbol as symbol from (
		select k_symbol
		from bank.order
		where k_symbol <> ' '
		group by k_symbol
		having avg(amount) > 3000
	  ) sub1
);

-- syntax wise we could have skipped the subquery from step 2, but process wise, the nested subquery is making the whole thing faster...
-- this has to do with how the subqueries behave in the IN vs the FROM statements:
-- a subquery in the IN statement will operate for every row
-- if we skip step 2 we will be doing the whole operation on the subquery for every row...
-- if we keep the subquery on step 2, it will be comparing with only ('SIPO', 'UVER'), because the inner query in the FROM statement will run only once;


-- Simple Subqueries in FROM statement:
-- return the rows where the total order amount per account_id is higher then 10000:

-- step 1: start the query
select account_id, sum(amount) as Total
from bank.order
group by account_id;
-- having total > 10000;

-- notice you need some operations over the table resulted in the previous query

-- step 2: start main query / use subquerie as table
select * from (
  select account_id, sum(amount) as Total
  from bank.order
  group by account_id
) sub1
where total > 10000;

-- use 'having', it's more efficient


-- Nested subqueries in FROM statement: 
-- for each duration, find the status with the highest total amount:
select * from bank.loan;

-- step 1: start the query
select duration, status, sum(amount) total from bank.loan
group by duration, status
order by duration, status;

-- you notice that you'll have to use the previous query as a table in a new query

-- step 2: start the main query / use the previous query as the table (subquery)
select *, row_number() over (partition by duration order by total desc) 
from (
	select duration, status, sum(amount) total from bank.loan
	group by duration, status
	order by duration, status
    ) as sub;

-- almost there...

select * from ?
where ranking = 1;

-- step 3: nested subqueries to get the result we want
select duration, status, total
from (
	select *, row_number() over (partition by duration order by total desc) ranking
	from (
		select duration, status, sum(amount) total from bank.loan
		group by duration, status
		order by duration, status
	) as sub1
) as sub2
where ranking = 1;


-- Correlated Subqueries
-- return the loans whose amounts are greater than the average, within the same status group:
-- (we want to find those averages by each status group and simultaneously compare the loan amount with its status group's average)

-- step 0:
select status, avg(amount) from bank.loan
group by status;

-- step 1: customers whose loan amount was greater than the average
select * from bank.loan
where amount > ?;

-- step 2: get the average
select avg(amount)
from bank.loan;

-- step 3: put them together
select * from bank.loan
where amount > (
	select avg(amount)
	from bank.loan
);

-- but we are comparing with the total avg, instead of avg per status

-- step 4: add the correlated condition
select * from bank.loan l1
where amount > (
  select avg(amount) as average
  from bank.loan
  where status = l1.status
);

-- if status is A, picks the avg from A to compare on the main queries WHERE statement
-- if status is B, picks the avg from B and so on...


-- 3.05 Activity 1
select avg(number_trans) from (
	select account_id, count(account_id) as number_trans
    from trans
	group by account_id
) sub;

select account_id, count(account_id) as number_trans
from trans
group by account_id
having number_trans > (select avg(number_trans) from (
	select account_id, count(account_id) as number_trans
    from trans
	group by account_id
) sub)
order by number_trans desc;


-- 3.05 Activity 2
select A1 from bank.district
where A3 = 'central Bohemia';
-- with subquery
select * from bank.account
where district_id in (select A1 from bank.district
where A3 = 'central Bohemia');
-- with join
select a.account_id, d.a3 from account a
join district d on a.district_id = d.a1
where a3 = 'Central Bohemia'; 


-- 3.05 Activity 3
select district_id, account_id, activity from (
	select *, rank() over (partition by district_id order by activity desc) as ranking from (
		select a.district_id, a.account_id, count(t.trans_id) as activity
		from account a
		join district d on a.district_id = d.a1
		join trans t on a.account_id = t.account_id
		where d.a3 = 'Central Bohemia'
		group by a.account_id
		order by district_id
	) sub1
) sub2
where ranking = 1;

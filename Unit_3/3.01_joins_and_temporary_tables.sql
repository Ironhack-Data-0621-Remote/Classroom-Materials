-- The Degrees of Relationships between two entities (columns/tables) is the number of entities involved in that relationship:
-- Examples from sakila:
-- One to One - if every store is located in only one city and there is only one store per city.
				-- so, every unique store_id is directly associated to just one city_id and vice-versa.
-- One to Many - if every customer is associated with one city, but many customers can live in the ssame city.
				-- so, every unique customer_id is associated with a city_id, but, the same city_id can be associated to different customers.
-- Many to Many - if a movie could have more than one category, you'd have more than one category per movie and more than a movie per category.
				-- so, more than one movie_id is associated with more than one category and vice-versa.


# Simple joins

select * from bank.loan l
join bank.account a
on l.account_id = a.account_id; -- using(account_id)

select * from bank.loan l
left join bank.account a
on l.account_id = a.account_id;

select * from bank.account a
right join bank.loan l
on a.account_id = l.account_id;

select * from bank.account a
left join bank.loan l
on a.account_id = l.account_id;

select * from bank.loan l
right join bank.account a
on l.account_id = a.account_id;


-- 1) return account_id, operation, frequency, sum of amount, sum of balance, 
-- 2) where the balance is over 1000 and operation type is VKLAD and
-- 3) group by (sum of amount, sum of balance) -- aggregation
-- 4) having an aggregated amount over 500,000.

-- step 1
select a.account_id, operation, frequency, sum(amount) as TotalAmount, sum(balance) as TotalBalance -- step 3: sum(amount) as TotalAmount, sum(balance) as TotalBalance
from bank.trans t 
left join bank.account a
on t.account_id = a.account_id
-- step 2
where t.operation = 'VKLAD' and balance > 1000
-- step 3
group by t.account_id, t.operation, a.frequency
-- step 4
having TotalAmount > 500000
order by TotalAmount desc
limit 10;


-- Multiple Joins

select * from bank.disp d
join bank.client c
on d.client_id = c.client_id
join bank.card ca
on d.disp_id = ca.disp_id;

-- Logical order of joins:
-- 1st join:
-- from bank.disp -- this is our left table
-- join bank.client c -- this is our right table
-- 2nd join:
-- from bank.disp d join bank.client c -- this is our left table
-- join bank.card ca -- this is our right table

-- Compound Conditions
select * from bank.loan_and_account la
join bank.disp_and_account da
on la.account_id = da.account_id
and la.district_id = da.district_id;


-- Temporary Tables
create temporary table if not exists bank.loan_and_account
select l.loan_id, l.account_id, a.district_id, l.amount, l.payments, a.frequency
from bank.loan l
join bank.account a
on l.account_id = a.account_id;

select * from bank.loan_and_account;

create temporary table if not exists bank.disp_and_account
select d.disp_id, d.client_id, d.account_id, a.district_id, d.type
from disp d
join account a
on d.account_id = a.account_id;

select * from bank.disp_and_account;


-- Act 1
-- Get the number of clients by district, returning district name.
SELECT A2 as district_name, count(client_id)
FROM bank.client as client_table
JOIN bank.district as district_table on client_table.district_id = district_table.A1
GROUP BY A2;
-- Are there districts with no clients? Move all clients from Strakonice to a new district with district_id = 100. Check again. Hint: In case you have some doubts, you can check here how to use the update statement.
UPDATE bank.district
SET A1 = 100
WHERE A1 = 20;
-- How would you spot clients with wrong or missing district_id?
SELECT client_id, A1 as district_id
FROM bank.client as client_table
JOIN bank.district as district_table on client_table.district_id = district_table.A1
WHERE A1 is null
GROUP BY A1, client_id;
-- Return clients to Strakonice.
UPDATE bank.district
SET A1 = 20
WHERE A1 = 100;
-- Activity 4
-- Make a list of all the clients together with region and district, ordered by region and district.
SELECT  client_id, A2 as district_name, A3 as region
FROM bank.client as client_table
JOIN bank.district as district_table on client_table.district_id = district_table.A1
-- GROUP BY client_id,A2,A3
ORDER BY region,district_name;
-- Count how many clients do we have per region and district.
-- per region
SELECT A3 as region,count(client_id)
FROM bank.client as client_table
JOIN bank.district as district_table on client_table.district_id = district_table.A1
GROUP BY region;
-- per district
SELECT  A2 as district_name, count(client_id)
FROM bank.client as client_table
JOIN bank.district as district_table on client_table.district_id = district_table.A1
GROUP BY district_name;
-- How many clients do we have per 10000 inhabitants per district?
SELECT count(client_id), (count(client_id)*10000/A4), A2
FROM bank.client as client_table
JOIN bank.district as district_table on client_table.district_id = district_table.A1
GROUP BY A4, A2;
-- How many clients do we have in total per 10000 inhabitants?
select 10000*count(c.client_id)/sum(distinct A4)
from district d join client c on d.A1 = c.district_id;
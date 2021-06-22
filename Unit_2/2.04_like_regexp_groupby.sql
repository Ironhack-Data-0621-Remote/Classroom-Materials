-- Intro to GroupBy
select a3, avg(length(a3)) from bank.district
group by a3;

select * from bank.district
where length(a3) = (select max(length(a3)) from bank.district);


-- distinct
select A3 from bank.district;
select distinct A3 from bank.district;

-- in
select * from bank.order
where k_symbol in ('leasing', 'pojistne');

select * from bank.account
where district_id in (1,2,3,4,5);

-- between
select *,
case
when k_symbol = 'SIPO' then 'a'
when k_symbol = 'LEASING' then 'b'
else 'c'
end as 'abc'
from bank.order
where 
case
when k_symbol = 'SIPO' then 'a'
when k_symbol = 'LEASING' then 'b'
else 'c'
end
between 'a' and 'b';

select * from bank.loan
where amount - payments between 1000 and 10000;

-- like
select * from bank.district
where A3 like 'north%';

select * from bank.district
where A3 like '%boh%';

select * from bank.district
where a3 like 'north_M%';
-- This would return all the results for 'north  Moravia', 'northMoravia', northMiami'

-- regex
select * from bank.district
where a3 regexp 'north';

select * from bank.order
where k_symbol regexp 's';

select * from bank.order
where k_symbol regexp '^s'; -- starts with

select * from bank.order
where k_symbol regexp 'o$'; -- ends with

select distinct k_symbol from bank.order
where k_symbol regexp 'ip|is'; -- one or another (ip or is)

select * from bank.district
where a2 regexp 'cesk[ey]';

select * from bank.district
where a2 regexp '^ch';




-- day 2 activity 1

-- Keep working on the bank database and its card table.

SELECT *
FROM card;


-- Get different card types.
SELECT DISTINCT(type)
FROM card;

-- Get transactions in the first 15 days of 1993.

SELECT * from trans
where date between '930101' and '930115';




-- Get all running loans.
SELECT *
FROM loan
WHERE status LIKE 'C' OR status like 'D';



-- Find the different values from the field A2 that start with the letter 'K'.
SELECT *
FROM district
WHERE a2 REGEXP '^K';


-- Find the different values from the field A2 that end with the letter 'K'.
SELECT *
FROM district
WHERE a2 REGEXP 'k$';

-- Can you use the following query:
select * from bank.district
where a3 like 'north%';

-- instead of:
	
select * from bank.district
where a3 like 'north_M%';


-- Can you modify the query to print the rows only for those values in the A2 column that starts with 'CH'?

select * from bank.district
where a2 regexp '^CH';


-- Use the table trans for this query. Use the column type to test: "By default, in an ascending sort, special characters appear first, followed by numbers, and then letters."

SELECT *
FROM trans
ORDER BY type ASC;


-- Again use the table trans for this query. Use the column k_symbol to test: "Null values appear first if the order is ascending."

SELECT *
FROM trans
ORDER BY k_symbol ASC;


-- Pick any table and any column to test: "You can use any column from the table to sort the values even if that column is not used in the select statement." Check the difference by writing the query with and without that column (column used to sort the results) in the select statement.

SELECT k_symbol,account_id
FROM trans
ORDER BY k_symbol;

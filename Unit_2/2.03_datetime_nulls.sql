-- converting to date type
select account_id, district_id, frequency, date, convert(date,date) from bank.account; -- cast(date as date)
select account_id, district_id, frequency, convert(date,datetime) from bank.account;
-- the first argument is the column name and the second is the type you want to convert

select issued, convert(substring_index(issued, ' ', 1), date) from bank.card;   -- left(issued, position(' ' in issued))  instead of substring_index

-- converting the original format to the date format that we need:
select date_format(convert(date,date), '%Y-%M-%D') from bank.loan;

-- if we just want to extract some specific part of the date
select date_format(convert(date,date), '%y') from bank.loan; 

-- extract
SELECT EXTRACT(DAY from CAST(date as date)) AS day from loan;

/* Order of Processing
FROM
ON
JOIN
WHERE
GROUP BY
WITH CUBE/ROLLUP
HAVING
SELECT
DISTINCT
ORDER BY
TOP/LIMIT
OFFSET/FETCH
*/


-- Nulls
select isnull(card_id) from bank.card; -- 0 means not null, 1 means null

-- this is used to check all the elements of a column.
select sum(isnull(card_id)) from bank.card;

select * from bank.order
where k_symbol is null;

select * from bank.order
where k_symbol is not null and k_symbol = ' '; -- 

-- to check, replace nulls
select *, coalesce(amount, 0) from bank.order
where amount = 1000;


-- case/when
select loan_id, account_id,
case
when status = 'A' then 'Good - Contract Finished'
when status = 'B' then 'Defaulter - Contract Finished'
when status = 'C' then 'Good - Contract Running'
else 'In Debt - Contract Running'
end as 'Status_Description'
from bank.loan;
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
-- Find out how many cards of each type have been issued.
select type, count(card_id) 
from bank.card
group by type;

-- Find out how many customers there are by the district.
select count(client_id), district_id
from bank.client
group by district_id;

-- Find out average transaction value by type.
select type, round(avg(amount)) as avg_amount
from bank.trans
group by type
order by avg_amount;


-- For each `k_symbol` and `operation`, calculate the average of `balance` in the `trans` table. 
-- But there a few places where the column `k_symbol` is an empty string. Your task it to use a filter to remove those rows of data.
--  After the filter gets applied, you would see that the number of rows have reduced.
select k_symbol, operation, round(avg(balance))
from bank.trans
where k_symbol != ' '
group by k_symbol, operation;

-- Find the districts with more than 100 clients.
select district_id, count(district_id) as c
from bank.client
group by district_id
having c > 100
order by district_id;


-- Find the transactions (type, operation) with a mean amount greater than 10000.
select type, operation, avg(amount) as t
from bank.trans
group by type, operation
having t > 10000;
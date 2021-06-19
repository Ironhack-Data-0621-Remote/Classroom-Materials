-- insert data
INSERT into card(card_id, disp_id, type, issued)
VALUES (100, 10, 'new_classic', '940119 00:00:00');

select * from card
where type='new_classic';

-- disable safe mode in workbench
SET SQL_SAFE_UPDATES = 0;

-- update query
UPDATE card
SET type='ironhack'
where type='new_classic'
and disp_id = 10;

-- delete data
DELETE from card 
where type='ironhack';

-- sorting data
select * 
from loan
order by status asc, amount desc
limit 20;

-- distinct values
select distinct type, card_id
from card
order by card_id
limit 50;

-- printing data
select 'hello world';
select 2*5 as new_col;
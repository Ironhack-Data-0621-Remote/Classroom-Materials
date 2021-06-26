use bank_demo;

delete from accountDemo where account_id = 1;

select * from district_demo;

-- before importing data from file
-- run this code
show variables like 'local_infile';
set global local_infile = 1;


delete from district_demo;
load data local infile './district.csv' -- this file is at files_for_lesson_and_activities folder
into table district_demo
fields terminated by ',';


delete from account_demo;
load data local infile './account.csv' -- this file is at files_for_lesson_and_activities folders
into table account_demo
fields terminated BY ',';


update district_demo
set A4 = 0, A5 = 0, A6 = 0
where A2 = 'Kladno';


-- what is the total amount loaned by the bank so far
select sum(amount) from bank.loan;

-- what is the total amount that the bank has recovered/received from the customers
select sum(payments) from bank.loan;

-- what is the average loan amount taken by customers in Status A
select avg(amount) from bank.loan
where Status = 'A';


select Status, avg(amount), min(amount) from bank.loan
group by Status;


select avg(amount) as Average, status from bank.loan
group by Status
order by Average asc;


-- table1, table2
insert into table2
select adressid from table1
where col1 = ''
and col2 = '';

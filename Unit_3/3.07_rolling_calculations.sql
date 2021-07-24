-- Rolling Calculations

-- rolling sum of the amount transfered in transactions per account:
select account_id, date, amount,
sum(amount) over (partition by account_id order by date) -- order by account_id, date -- partition by account_id
from bank.trans;

-- we could achieve the same result with this:
select *, (select sum(amount)
from bank.trans) from bank.trans;

-- Rolling Calculations with LAG()

-- get the difference of the amount of monthly active users between each month and the previous month:
-- monthly active users - previous month active users

-- step 1: first i'll create a view with all the data i'm going to need:
create or replace view bank.user_activity as
select account_id, convert(date, date) as Activity_date,
date_format(convert(date,date), '%m') as Activity_Month,
date_format(convert(date,date), '%Y') as Activity_year
from bank.trans;

select * from bank.user_activity;

-- step 2: getting the total number of active user per month and year
create or replace view bank.monthly_active_users as
select Activity_year, Activity_Month, count(account_id) as Active_users
from bank.user_activity
group by Activity_year, Activity_Month
order by Activity_year asc, Activity_Month asc;

select * from monthly_active_users;

-- step 3: using LAG() to get the users from previous month
select 
   Activity_year, 
   Activity_month,
   Active_users, 
   lag(Active_users) over () as Last_month -- order by Activity_year, Activity_Month -- lag(Active_users, 2) -- partition by Activity_year
from monthly_active_users;

-- step 4: getting the difference
create or replace view bank.diff_monthly_active_users as
with cte_view as 
(
	select 
	Activity_year, 
	Activity_month,
	Active_users, 
	lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month
	from monthly_active_users
)
select 
   Activity_year, 
   Activity_month, 
   Active_users, 
   Last_month, 
   (Active_users - Last_month) as Difference 
from cte_view;

select * from diff_monthly_active_users;

/*
*/

-- Rolling Calculations with Self Joins

-- from the above we got the info from the total number off transactions,
-- now we want by unique account_id

select * from bank.user_activity;

-- step 1: get the unique active users per month
create or replace view bank.distinct_users as
select
	distinct 
	account_id as Active_id, 
	Activity_year, 
	Activity_month
from bank.user_activity
order by Activity_year, Activity_month, account_id;

select * from bank.distinct_users;

-- step 2: getting monthly unique users
create or replace view bank.monthly_distinct_users as
select Activity_year, Activity_month, count(Activity_month) as Active_users
from bank.distinct_users
group by Activity_year, Activity_month;

select * from bank.monthly_distinct_users;

-- step 3: self joinning the table
select m1.Activity_year, m1.Activity_month, m1.Active_users, m2.Activity_year, m2.Activity_month, m2.Active_users Previous_month_users
from monthly_distinct_users m1
left join monthly_distinct_users m2
on m1.Activity_year = m2.Activity_year -- case when m1.Activity_month = 1 then m1.Activity_year + 1 else m1.Activity_year end
and m1.Activity_month =  m2.Activity_month+1; -- case when m2.Activity_month+1 = 13 then 12 else m2.Activity_month+1 end;
-- OBS.: the case when are not ready... make them work as a challenge

-- almost same result (but with january) with lag():
select *,
lag(Active_users) over () as Previous_month_users
from bank.monthly_distinct_users;

-- Rolling Calculations with LAG() and Self Join
-- step 4: calculate the difference in retained customers from month to month for each year:
select * from retained_customers;

select
    Activity_year,
    Activity_month, 
    Retained_customers,
    (Retained_customers-lag(Retained_customers) over(partition by Activity_year)) as Diff
from retained_customers;

-- or
with cte as
(
	select *,
    lag(Active_users) over () as Previous_month_users
    from bank.monthly_distinct_users
)
select *, Active_users - Previous_month_users
from cte;

/*
*/

-- 3.07 Activity 1:
-- Obtain the percentage of variation in the number of users compared with previous month.
with cte_activity as
(
-- in the cte we get last months active users with lag()
  select
    Activity_year, Activity_month, Active_users,
    lag(Active_users,1) over (partition by Activity_year) as last_month
  from monthly_active_users
)
select
  activity_year, activity_month,
-- then we subtract this months users with last months and calculate the percentage
  (Active_users-last_month)/Active_users*100 as percentage_change
from cte_activity
where last_month is not null;


-- 3.08 Activity 2:
-- List the customers lost in the last month available on the DB.

-- step 1: find last month and year of activity
select month(max(date)) month, year(max(date)) year from trans;

-- step 2: find the distinct users (we don't want to count more than one transaction per account)
select distinct account_id, date from trans;
  
-- step 3: use step 1 to filter out step 2 
select distinct account_id, month(date) month, year(date) year
from trans
where (
       month(date) = (select month(max(date)) from trans)
       or
	   month(date) = (select month(max(date)) from trans)-1 -- (remember you'll also need the previous month)
	  )
       and
       year(date) = (select year(max(date)) from trans);
       
-- if we do a self join we'd get something like
with cte_distinct_users as
(
  select distinct account_id, month(date) month
  from trans
  where (month(date) = 12 or month(date) = 11) and year(date) = 1998
)
select *
from cte_distinct_users cte1 
join cte_distinct_users cte2
on cte1.account_id = cte2.account_id;

-- step 4: put it together with a self join
  -- replaced the subqueries by their values for easier understanding
with cte_distinct_users as
(
  select distinct account_id, month(date) month
  from trans
  where (month(date) = 12 or month(date) = 11) and year(date) = 1998
)
select * -- cte1.account_id
from cte_distinct_users cte1 
left join cte_distinct_users cte2
on cte1.account_id = cte2.account_id
and cte1.month = cte2.month - 1
where cte2.account_id is null;


-- Activity 3
-- Get total monthly transaction per account and the difference with the previous month

-- step 1: separate last months amount and the previous months amount
  select
	account_id,
    case when month(date) = 11 then amount else 0 end amount_previous_month,
    case when month(date) = 12 then amount else 0 end amount_last_month
  from trans
  where (month(date) = 12 or month(date) = 11) and year(date) = 1998;
  
-- step 2: using the query above, aggregate and calculate
with cte_distinct_users as
(
  select
	account_id,
    case when month(date) = 12 then amount else 0 end amount_last_month,
    case when month(date) = 11 then amount else 0 end amount_previous_month
  from trans
  where (month(date) = 12 or month(date) = 11) and year(date) = 1998
)
select account_id, round(sum(amount_last_month) - sum(amount_previous_month)) as difference
from cte_distinct_users
group by account_id;


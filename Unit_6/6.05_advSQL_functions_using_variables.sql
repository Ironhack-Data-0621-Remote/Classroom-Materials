use bank;

drop procedure average_loss_proc;

delimiter //
create procedure average_loss_proc ()
begin
select status, round((sum(amount) - sum(payments))/count(*), 2)
from bank.loan
-- where status = 'B';
group by status;
end
//
delimiter ;

call average_loss_proc();
select round(@x,2) as average_loss_per_customer;

-- end of query

drop procedure average_loss_proc;

delimiter //
create procedure average_loss_proc (out param1 float)
begin
  select round((sum(amount) - sum(payments))/count(*), 2) into param1
  from bank.loan
  where status = "B";
end;
//
delimiter ;

call average_loss_proc(@x);
select round(@x,2) as Average_loss_per_customer;

-- end of query

drop procedure if exists average_loss_proc;

delimiter //
create procedure average_loss_proc ()
begin
declare avg_loss float;-- default 0.0;
select round((sum(amount) - sum(payments))/count(*), 2) into avg_loss
 from bank.loan
  where status = "B";
select avg_loss;
end
//
delimiter ;

call average_loss_proc();

--  end of query

drop procedure if exists average_loss_proc;

delimiter //
create procedure average_loss_proc (in param varchar(10))
begin
declare avg_loss float default 0.0;
select round((sum(amount) - sum(payments))/count(*), 2) into avg_loss
 from bank.loan
  where status COLLATE utf8mb4_general_ci = param;
  select avg_loss;
end
// 
delimiter ;

call average_loss_proc('B');


--  end of query

drop procedure if exists average_loss_proc;

delimiter //
create procedure average_loss_proc (in param varchar(10), out param1 float)
begin
select round((sum(amount) - sum(payments))/count(*), 2) into param1
 from bank.loan
where status COLLATE utf8mb4_general_ci = param;
end
// 
delimiter ;

call average_loss_proc('B', @x);

select @x;

-- end of query

drop procedure if exists average_loss_status_regiom_proc;

delimiter //
create procedure average_loss_status_regiom_proc (in param1 varchar(20), in param2 varchar(50), out avg_loss_region float)
begin
select round((sum(amount) - sum(payments))/count(*), 2) into avg_loss_region
  from (
    select a.account_id, d.A2 as district, d.A3 as region, l.amount, l.payments, l.status
    from bank.account a
    join bank.district d
    on a.district_id = d.A1
    join bank.loan l
    on l.account_id = a.account_id
    where l.status COLLATE utf8mb4_general_ci = param1
    and d.A3 COLLATE utf8mb4_general_ci = param2
) sub1;
end
// 
delimiter ;

call average_loss_status_regiom_proc("A", "Prague", @x);
select @x;


-- Similar to the procedure we created last class, we will be calculating the average loss of the unpaid loans
-- by status and region, returning also the 'group' in which it belong according to the average resulted (green, yellow, red)

drop procedure if exists average_loss_status_regiom_proc;

DELIMITER //
create procedure average_loss_status_region_proc (in param1 varchar(10), in param2 varchar(100),
 out param3 varchar(20), out param4 int)
begin
  -- declare avg_loss_region float default 0.0; 
  declare zone varchar(20) default "";

  select round((sum(amount) - sum(payments))/count(*), 2) into param4 -- into avg_loss_region
  from (
    select a.account_id, d.A2 as district, d.A3 as region, l.amount, l.payments, l.status
    from bank.account a
    join bank.district d
    on a.district_id = d.A1
    join bank.loan l
    on l.account_id = a.account_id
    where l.status COLLATE utf8mb4_general_ci = param1 
    and d.A3 COLLATE utf8mb4_general_ci = param2
  ) sub1;

  if param4 > 70000 then
    set zone = 'Red Zone';
  elseif param4 <= 70000 and param4 > 40000 then
    set zone = 'Yellow Zone';
  else
    set zone = 'Green Zone';
  end if;

  select zone into param3;
end //
DELIMITER ;

call average_loss_status_region_proc("A", "Prague", @zone, @average);
select @zone, @average;


-- end of query



drop procedure if exists average_loss_status_region_proc;

DELIMITER //
create procedure average_loss_status_region_proc (in param1 varchar(10), in param2 varchar(100),
 out param3 varchar(20), out param4 int)
begin
  declare zone varchar(20) default "";

  select round((sum(amount) - sum(payments))/count(*), 2) into param4 -- into avg_loss_region
  from (
    select a.account_id, d.A2 as district, d.A3 as region, l.amount, l.payments, l.status
    from bank.account a
    join bank.district d
    on a.district_id = d.A1
    join bank.loan l
    on l.account_id = a.account_id
    where l.status COLLATE utf8mb4_general_ci = param1 
    and d.A3 COLLATE utf8mb4_general_ci = param2
  ) sub1;

  case
	when param4 > 50000 then
		set zone = 'red zone';
	when param4 <= 50000 and param4 > 20000 then
		set zone = 'yellow zone';
	else
		set zone = 'green zone';
  end case;

  select zone into param3;
end //
DELIMITER ;

call average_loss_status_region_proc("A", "Prague", @zone, @average);
select @zone, @average;


call average_loss_status_region_proc("A", "Prague");
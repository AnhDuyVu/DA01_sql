--ex01

with rank_order as (Select *,
(case when order_date = customer_pref_delivery_date then 'immediate'
     else 'sceduled' end) as delivery_type,
rank() over(partition by customer_id order by order_date) as rank_order
from Delivery)
Select 
round((sum(case when rank_order = 1 and delivery_type = 'immediate' then 1 else 0 end)/ sum(case when rank_order = 1 then 1 else 0 end))*100,2) as immediate_percentage
from rank_order;

--ex02

with log_in_table as (Select *,
coalesce(lead(event_date) over(partition by player_id order by event_date),0) as next_log_in,
min(event_date) over (partition by player_id order by event_date)as first_date_log_in
from Activity),
two_consecutive_day_log_in as (
Select *, datediff(next_log_in,first_date_log_in) as date_diff
from log_in_table
where datediff(next_log_in,first_date_log_in) =1)
Select round(count(player_id)/ (select count(distinct player_id) from Activity),2) as fraction
from two_consecutive_day_log_in;

--ex03

with two_consecutive_table as (Select *,
lead(id) over(order by id) as next_id,
lead(student) over(order by id) as next_student,
lag(student) over(order by id) as previous_student,
coalesce(lead(id) over(order by id) - id,0) as two_consecutive_id
from Seat)
Select id,
       (case when two_consecutive_id = 1 and mod(id,2) <> 0 and id not in (select max(id) from two_consecutive_table) then next_student 
       when (two_consecutive_id = 1 or two_consecutive_id =0)and mod(id,2) = 0 and (id not in (select max(id) from two_consecutive_table) or id in (select max(id) from two_consecutive_table)) then previous_student 
       else  student end) as student
from two_consecutive_table;

--ex04




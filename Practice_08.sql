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

with total_amount as (Select visited_on,
amount,
sum(amount) as total_amount
from Customer
group by visited_on
order by visited_on)
Select visited_on,
running_total_7d as amount,
round(avg_amount_7d,2) as average_amount
from (Select *,
sum(total_amount) over(order by visited_on desc rows between CURRENT ROW AND 6 FOLLOWING) as running_total_7d,
avg(total_amount) over(order by visited_on desc rows between CURRENT ROW AND 6 FOLLOWING) as avg_amount_7d,
rank() over(order by visited_on) as stt
from total_amount) as running_7d
where stt >=7
order by visited_on;

--ex05

SELECT ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM Insurance
WHERE tiv_2015 IN (
    SELECT tiv_2015
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
)
AND (lat, lon) IN (
    SELECT lat, lon
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(*) = 1
)

-ex06

with rank_salary_table as (Select e.id, e.name, e.salary,e.departmentId,d.name as depart_name,
dense_rank() over(partition by departmentId order by departmentId asc, salary desc) as rank_salary
from Employee as e
join Department as d
on e.departmentID = d.id)
Select depart_name as Department,
name as Employee,
salary
from rank_salary_table
where rank_salary <=3;

-ex07

with total_weight as (Select *,
sum(weight) over(order by turn,Weight) as total_weight
from Queue)
Select person_name
from (Select *
from total_weight
where total_weight <=1000) as limit_weight
order by total_weight desc
limit 1;

--ex08

select distinct product_id,
coalesce((select new_price from 
(select * from products as p3 where change_date <= '2019-08-16' and p3.product_id = p2.product_id) as p1
order by change_date DESC limit 1),10) as price
from products p2;









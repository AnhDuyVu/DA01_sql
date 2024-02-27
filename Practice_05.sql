--ex01
Select b.continent,
floor(avg(a.population)) as average_city_populations
from city as a
inner join country as b
on a.countrycode = b.code
group by b.continent;

--ex02
SELECT 
round(cast(count(t.signup_action) as decimal)/count(e.email_id),2) as confirm_rate
from emails as e
left join texts as t
on e.email_id = t.email_id and t.signup_action = 'Confirmed';

--ex03
SELECT age_bucket,
      round((sum(case when activity_type ='send' then time_spent else 0 end)/ sum(time_spent))*100.0,2) as send_perc,
      round((sum(case when activity_type ='open' then time_spent else 0 end)/ sum(time_spent))*100.0,2) as open_perc
from activities as a 
left join age_breakdown as b 
on a.user_id = b.user_id and a.activity_type in  ('open','send')
where age_bucket is not null
group by age_bucket;

--ex04
SELECT customer_id
from customer_contracts as c 
left join products as p  
on c.product_id = p.product_id and left(product_name,5) = 'Azure'
where p.product_id is not null
group by customer_id
having count(distinct c.product_id) >2;

--ex05
Select e.employee_id,
       e.name,
       count(m.employee_id) as reports_count,
       round(avg(m.age)) as average_age
from Employees as e
left join Employees as m
on e.employee_id = m.reports_to
group by e.employee_id, e.name
having count(m.employee_id) <>0
order by e.employee_id;

--ex06
Select product_name,
       sum(unit) as unit
from Products as p
left join Orders as o
on p.product_id = o.product_id
where order_date between '2020-02-01' and '2020-02-29'
group by product_name
having sum(unit) >= 100;

--ex07
SELECT p.page_id
from pages as p  
left join page_likes as pl 
on p.page_id = pl.page_id
where liked_date is null
order by p.page_id asc;

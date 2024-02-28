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

mid-test
---Question 01
Select distinct replacement_cost 
from film
order by replacement_cost asc;
---Question 02
Select 
case 
    when replacement_cost between 9.99 and 19.99 then 'low'
	when replacement_cost between 20.00 and 24.99 then 'medium'
	when replacement_cost between 25.00 and 29.99 then 'high'
	else 'no category'
	end as replacement_cost_category,
sum(case 
    when replacement_cost between 9.99 and 19.99 then 1 else 0 end) as count_low
from film
group by replacement_cost_category
order by count_low desc;
--Question 03
Select f.title,f.length,ca.name
from film as f
left join film_category as fc
on f.film_id = fc.film_id
left join category as ca
on fc.category_id=ca.category_id
where name in ('Drama','Sports')
order by ca.name desc, length desc;
--Question 04
Select ca.name,
count(f.title) as total_titles
from film as f
left join film_category as fc
on f.film_id = fc.film_id
left join category as ca
on fc.category_id=ca.category_id
group by name
order by total_titles desc;
--Question 05
Select ac.last_name,ac.first_name,
count(film_id) as total_film
from actor as ac
left join film_actor as fac
on ac.actor_id = fac.actor_id
group by last_name,first_name
order by total_film desc;
--Question 06
Select count(ad.address_id) as count_address_id_no_belong_to_customer
from address as ad
left join customer as cus
on ad.address_id = cus.address_id
where cus.address_id is null;
--Question 07
Select ci.city,
sum(pay.amount) as total_revenue
from payment as pay
left join customer as cus
on pay.customer_id = cus.customer_id
left join address as ad
on cus.address_id = ad.address_id
left join city as ci
on ad.city_id = ci.city_id
group by ci.city
order by total_revenue desc;

--Question 08
Select * from country;
Select * from city;
Select ci.city || ',' || ' ' || co.country  as country_city,
sum(pay.amount) as total_revenue
from payment as pay
left join customer as cus
on pay.customer_id = cus.customer_id
left join address as ad
on cus.address_id = ad.address_id
left join city as ci
on ad.city_id = ci.city_id
left join country as co
on ci.country_id = co.country_id
group by ci.city || ',' || ' ' || co.country
order by total_revenue asc;

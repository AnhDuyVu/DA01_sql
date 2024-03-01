--ex01

Select count(distinct company_id) as duplicate_companies
from job_listings
where company_id in (Select company_id
from job_listings
group by company_id
having count(title) > 1 and count(description) >1);

--ex02
with top_two_appliance as (Select category,
       product,
       sum(spend) as total_spend
from product_spend
where extract(year from transaction_date) = 2022 and category ='appliance'
group by category, product
order by category asc,total_spend desc
limit 2),
top_two_electronics as (Select category,
       product,
       sum(spend) as total_spend
from product_spend
where extract(year from transaction_date) = 2022 and category ='electronics'
group by category, product
order by category asc,total_spend desc
limit 2)
Select *
from top_two_appliance
UNION ALL
Select * 
from top_two_electronics;

--ex03

Select count(policy_holder_id) as member_count
from (SELECT policy_holder_id,
      COUNT(case_id) AS count_calls
from callers
group by policy_holder_id
having count(case_id) >=3) as count_record;

--ex04
Select page_id
from pages
where page_id not in (select page_id from page_likes where liked_date is not null);

--ex05
SELECT 
  EXTRACT(MONTH FROM curr_month.event_date) AS month, 
  COUNT(DISTINCT curr_month.user_id) AS monthly_active_users 
FROM user_actions AS curr_month
WHERE curr_month.user_id in (
  SELECT last_month.user_id 
  FROM user_actions AS last_month
  WHERE last_month.user_id = curr_month.user_id
    AND EXTRACT(MONTH FROM last_month.event_date) =
    EXTRACT(MONTH FROM curr_month.event_date - interval '1 month')
)
  AND EXTRACT(MONTH FROM curr_month.event_date) = 7
  AND EXTRACT(YEAR FROM curr_month.event_date) = 2022
GROUP BY EXTRACT(MONTH FROM curr_month.event_date);

--ex06

Select month, country, 
count(trans_date) as trans_count,
sum(case when state = 'approved' then 1 else 0 end) as approved_count,
sum(amount) as trans_total_amount,
sum(case when state = 'approved' then amount else 0 end) as approved_total_amount
from (Select DATE_FORMAT(trans_date, '%Y-%m') as month,
country,
state,trans_date, amount
from Transactions) as state_table
group by month, country;

--ex07

Select product_id,
year as first_year,
quantity, price
from Sales
where (product_id,year) in (Select product_id, min(year) as first_year from sales group by product_id);

--ex08

select customer_id
from Customer
group by customer_id
having count(distinct product_key) = 
    (select count(distinct product_key) from Product);

--ex09

Select employee_id
from Employees
where salary < 30000 and manager_id not in (select employee_id from Employees)
order by employee_id asc;

--ex11

(Select name as results
from (Select u.name,
count(rating) as count_rating
from MovieRating as m
inner join Users as u
on m.user_id = u.user_id
group by u.name
order by count_rating desc, u.name asc) as username_highest_number_of_rating
limit 1)
union all
(Select title as results
from (Select mo.title,
avg(rating) as avg_rating
from MovieRating as m
inner join Movies as mo
on m.movie_id = mo.movie_id
where DATE_FORMAT(created_at, '%Y-%m') = '2020-02'
group by mo.title
order by avg(rating) desc, title asc) as movie_name_highest_avg_rating
limit 1);

--ex12
select id, count(*) as num  
from (select requester_id as id from RequestAccepted
union all
select accepter_id as id from RequestAccepted) as friend_table 
group by id 
order by count(*) desc 
limit 1;







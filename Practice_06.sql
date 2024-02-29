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





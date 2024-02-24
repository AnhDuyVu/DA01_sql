--ex01
Select name
from students 
where marks > 75
order by right(name,3), ID asc;

--ex02
Select user_id,
       concat(upper(left(name,1)),lower(substring(name from 2 for length(name)-1))) as name
from Users;

--ex03
Select manufacturer,
'$' || round(sum(total_sales)/1000000) || ' ' || 'million' as sales_mil
from pharmacy_sales
group by manufacturer
order by sum(total_sales) desc, manufacturer asc;

--ex04
SELECT 
       extract(month from submit_date) as mth,
       product_id as product,
       round(avg(stars),2) as avg_stars
from reviews
group by extract(month from submit_date), product_id
order by extract(month from submit_date) asc, product_id asc;

--ex05
SELECT sender_id,
       count(content) as message_count
from  messages
where extract(month from sent_date) = 8 and extract(year from sent_date) = 2022
group by sender_id
order by message_count DESC
limit 2;

--ex06
Select tweet_id
from Tweets
where length(content) > 15;

--ex07
Select activity_date as day,
count(distinct user_id) as active_users
from Activity
where activity_date between '2019-06-29' and '2019-07-28'
group by activity_date
having count(activity_type) > 1; 

--ex08
select count(id) as number_of_employee_hired
from employees
where extract(month from joining_date) between 01 and 08 and extract(year from joining_date) = 2022;

--ex09
select position('a' in first_name) 
from worker
where first_name = 'Amitah';

--ex10
select title,
       substring(title from position('2' in title) for 4) as the_vintage_years
from winemag_p2
where country = 'Macedonia';


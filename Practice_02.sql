---ex1
Select distinct city from station
where id % 02 = 0;

---ex2
Select count(city) - count(distinct city) as difference
from station;

---ex3
SELECT ceiling(AVG(SALARY) - AVG(REPLACE(SALARY,'0',''))) as amount_of_error
FROM Employees;

---ex4
SELECT 
round(cast((sum(order_occurrences*item_count)/sum(order_occurrences)) as decimal),1) as mean
FROM items_per_order;

--ex5
SELECT distinct candidate_id 
FROM candidates
where skill in('Python','Tableau','PostgreSQL')
group by candidate_id
having count(skill) = 3
order by candidate_id asc;

---ex6
SELECT user_id, 
date(max(post_date)) - date(min (post_date)) as days_between
FROM posts
where post_date > '2021-01-01' and post_date < '2022-01-01'
group by user_id
having count(post_id) >=2;

---ex07
SELECT card_name,
max(issued_amount) - min(issued_amount) as difference
from monthly_cards_issued
group by card_name
order by (max(issued_amount) - min(issued_amount)) desc;

---ex08
Select manufacturer,
       count(drug) as drug_count,
       abs(sum(total_sales - cogs)) as total_loss
from pharmacy_sales
where (total_sales - cogs) <0
group by manufacturer
having count(drug) > 0
order by total_loss desc;

---ex09
Select *
from Cinema
where id%2 = 1 and description <>'boring'
order by rating desc;

---ex10
Select teacher_id,
count(distinct subject_id) as cnt
from Teacher
group by teacher_id;

---ex11
Select user_id,
count(follower_id) as followers_count
from Followers
group by user_id
order by user_id asc;

---ex12
Select class
from Courses
group by class
having count(student) >=5;

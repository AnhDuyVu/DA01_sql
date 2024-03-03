--ex01

Select extract(year from transaction_date) as year,
       product_id,
       spend as curr_year_spend,
       lag(spend) over (partition by product_id order by product_id,extract(year from transaction_date)) as prev_year_spend,
       round((spend - lag(spend) over (partition by product_id order by product_id,extract(year from transaction_date)))/(lag(spend) over (partition by product_id order by product_id,extract(year from transaction_date)))*100,2) as yoy_rate
from user_transactions;

--ex02
Select distinct card_name,
      first_issued_amount
from (Select card_name,
       issue_year,
       issue_month,
       issued_amount,
       first_value(issued_amount) over(PARTITION BY card_name order by issue_year asc, issue_month asc) as first_issued_amount
from monthly_cards_issued) as a
order by first_issued_amount desc;

--ex03
Select user_id,
       spend,
       transaction_date
from (SELECT user_id,
spend,
transaction_date,
dense_rank() over(PARTITION BY user_id order by user_id,transaction_date) as rank_transaction
from transactions) as rank_transaction_table
where rank_transaction =3;

--ex04
Select transaction_date,
       user_id,
       count(product_id) as purchase_count
from (SELECT *,
       rank() over(PARTITION BY user_id order by transaction_date desc) as rank_transaction_date
from user_transactions) as rank_transaction_date_table
where rank_transaction_date = 1
group by transaction_date, user_id
order by transaction_date asc;

--ex05

SELECT    
  user_id,    
  tweet_date,   
  ROUND(AVG(tweet_count) OVER (
    PARTITION BY user_id     
    ORDER BY tweet_date     
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
  ,2) AS rolling_avg_3d
FROM tweets;

--ex06

with diff_transaction_minute as (SELECT *,
extract(minutes from transaction_timestamp) as minute_transaction,
extract(minutes from first_value(transaction_timestamp) over(partition by merchant_id, credit_card_id, amount order by transaction_timestamp)) as first_transaction_timestamp,
extract(minutes from transaction_timestamp) - extract(minutes from first_value(transaction_timestamp) over(partition by merchant_id, credit_card_id, amount order by transaction_timestamp)) as diff
FROM transactions),
repeat_payment_count as (Select merchant_id, credit_card_id, amount,	
count(transaction_id) over(PARTITION BY merchant_id, credit_card_id, amount order by transaction_timestamp) as payment_count
from diff_transaction_minute
where diff <=10
order by payment_count desc)
Select count(payment_count) as payment_count
from repeat_payment_count
where payment_count >1;

--ex07
with ranking_spending as (SELECT 
  category, 
  product, 
  SUM(spend) AS total_spend,
  RANK() OVER (
    PARTITION BY category 
    ORDER BY SUM(spend) DESC) AS ranking 
FROM product_spend
WHERE EXTRACT(YEAR FROM transaction_date) = 2022
GROUP BY category, product)
SELECT 
  category, 
  product, 
  total_spend 
FROM ranking_spending 
WHERE ranking <= 2 
ORDER BY category, ranking;

--ex08

WITH top_10 AS (
  SELECT 
    a.artist_name,
    DENSE_RANK() OVER (
      ORDER BY COUNT(s.song_id) DESC) AS artist_rank
  FROM artists as a
  INNER JOIN songs as s
    ON a.artist_id = s.artist_id
  INNER JOIN global_song_rank AS ranking
    ON s.song_id = ranking.song_id
  WHERE ranking.rank <= 10
  GROUP BY a.artist_name
)

SELECT artist_name, artist_rank
FROM top_10
WHERE artist_rank <= 5;

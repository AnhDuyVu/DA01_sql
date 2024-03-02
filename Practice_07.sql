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


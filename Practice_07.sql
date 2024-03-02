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

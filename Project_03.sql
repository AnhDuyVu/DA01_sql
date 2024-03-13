/* Dataset ở project 01*/
alter table sales_dataset_rfm_prj
alter column ordernumber type numeric using (trim(ordernumber)::numeric);
alter table sales_dataset_rfm_prj
alter column quantityordered type numeric using (trim(quantityordered)::numeric);
alter table sales_dataset_rfm_prj
alter column priceeach type numeric using (trim(priceeach)::numeric);
alter table sales_dataset_rfm_prj
alter column orderlinenumber type numeric using (trim(orderlinenumber)::numeric);
alter table sales_dataset_rfm_prj
alter column sales type numeric using (trim(sales)::numeric);
UPDATE sales_dataset_rfm_prj
SET orderdate = TO_DATE(orderdate, 'MM/DD/YYYY HH24:MI');
alter table sales_dataset_rfm_prj
alter column orderdate type date using (trim(orderdate)::date);
alter table sales_dataset_rfm_prj
alter column msrp type numeric using (trim(msrp)::numeric);

select *
from sales_dataset_rfm_prj
where ORDERNUMBER is null  or
      QUANTITYORDERED is null or
	  PRICEEACH is null  or
	  ORDERLINENUMBER is null or
	  SALES is null or
	  ORDERDATE is null;
	  
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN CONTACTLASTNAME text,
ADD COLUMN CONTACTFIRSTNAME text;
UPDATE sales_dataset_rfm_prj
SET 
    CONTACTLASTNAME = upper(left(substring(contactfullname from position('-' in contactfullname) + 1 for 1),1)) ||
	                       substring(contactfullname from position('-' in contactfullname) + 2 for length(contactfullname)),
    CONTACTFIRSTNAME = upper(left(contactfullname,1)) || substring(contactfullname from 2 for position('-' in contactfullname) - 2);

ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QTR_ID numeric,
ADD COLUMN MONTH_ID numeric,
ADD COLUMN YEAR_ID numeric;
UPDATE sales_dataset_rfm_prj
SET
   QTR_ID = extract(quarter from ORDERDATE),
   MONTH_ID = extract(month from ORDERDATE),
   YEAR_ID = extract(year from ORDERDATE);
   
with avg_sttdev_table as (Select *,
(Select avg(quantityordered) from sales_dataset_rfm_prj) as avg,
(Select stddev(quantityordered) from sales_dataset_rfm_prj) as sttdev
from sales_dataset_rfm_prj),
z_score_outlier_table as (Select *,
(quantityordered-avg)/sttdev as z_score
from avg_sttdev_table
where abs((quantityordered-avg)/sttdev) >3)
delete from sales_dataset_rfm_prj
where quantityordered in (Select quantityordered from z_score_outlier_table);

CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
(SELECT *
FROM sales_dataset_rfm_prj);

Select * from public.sales_dataset_rfm_prj_clean;

/* Project 03*/
/* 1. Doanh thu theo từng productline,year,dealsize */
Select 
year_id,
productline,
dealsize,
sum(sales) as revenue
from public.sales_dataset_rfm_prj_clean
group by productline, year_id, dealsize
order by year_id, productline, dealsize;

/* 2. Đâu là tháng có bán tốt nhất mỗi năm? */

with revenue_count_table as (Select month_id,
year_id,
sum(sales) as revenue,
count(ordernumber) as order_number
from public.sales_dataset_rfm_prj_clean
group by year_id, month_id),
rank_table as (Select *,
rank() over(partition by year_id order by revenue desc) as rank_revenue
from revenue_count_table)
Select month_id,
year_id,
revenue,
order_number
from rank_table
where rank_revenue = 1
  
/* 3. Product line nào được bán nhiều ở tháng 11*/
  
Select * from public.sales_dataset_rfm_prj_clean;
with revenue_count_table_2 as (Select month_id,
productline,
sum(sales) as revenue,
count(ordernumber) as order_number
from public.sales_dataset_rfm_prj_clean
where month_id = 11
group by month_id, productline ),
rank_table_2 as (Select *,
rank() over(partition by month_id order by revenue desc, productline asc) as rank_revenue
from revenue_count_table)
Select month_id,
productline,
revenue,
order_number
from rank_table_2
where rank_revenue between 1 and 3;

/* 4. Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm */

with revenue_table as (Select year_id,
productline,
sum(sales) as revenue
from public.sales_dataset_rfm_prj_clean
where country = 'UK'
group by year_id, productline
order by year_id),
rank_revenue_table as (Select *,
rank() over(partition by year_id order by revenue desc) as rank_revenue
from revenue_table)
Select *
from rank_revenue_table
where rank_revenue = 1;

/* 5. Ai là khách hàng tốt nhất, phân tích dựa vào RFM*/

with customer_RFM as (Select customername,
current_date - max(orderdate) as R,
count(distinct ordernumber) as F,
sum(sales) as M
from sales_dataset_rfm_prj_clean
group by customername),
rfm_score as (Select customername,
ntile(5) over (order by R desc) as R_score,
ntile(5) over (order by F) as F_score,
ntile(5) over (order by M) as M_score
from customer_RFM),
rfm_final as (Select customername,
cast(r_score  as varchar) || cast(F_score as varchar) || cast(M_score as varchar) as rfm_score
from rfm_score),
segment_table as (Select segment,a.customername,count (*) from (Select r.customername,
seg_sc.segment
from rfm_final as r
join segment_score as seg_sc
on r.rfm_score = seg_sc.scores) as a
group by segment, a.customername
order by segment, count(*) desc)
Select *,
sum(count) over(partition by segment) as total_count_each_segment
from segment_table

/* Nhận xét: Champion, Hibernating, Potential Loyalist và Lost Customer

--1
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

--2
select *
from sales_dataset_rfm_prj
where ORDERNUMBER is null  or
      QUANTITYORDERED is null or
	  PRICEEACH is null  or
	  ORDERLINENUMBER is null or
	  SALES is null or
	  ORDERDATE is null;
--3
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN CONTACTLASTNAME text,
ADD COLUMN CONTACTFIRSTNAME text;
UPDATE sales_dataset_rfm_prj
SET 
    CONTACTLASTNAME = upper(left(substring(contactfullname from position('-' in contactfullname) + 1 for 1),1)) ||
	                       substring(contactfullname from position('-' in contactfullname) + 2 for length(contactfullname)),
    CONTACTFIRSTNAME = upper(left(contactfullname,1)) || substring(contactfullname from 2 for position('-' in contactfullname) - 2);

--4
ALTER TABLE sales_dataset_rfm_prj
ADD COLUMN QTR_ID numeric,
ADD COLUMN MONTH_ID numeric,
ADD COLUMN YEAR_ID numeric;
UPDATE sales_dataset_rfm_prj
SET
   QTR_ID = extract(quarter from ORDERDATE),
   MONTH_ID = extract(month from ORDERDATE),
   YEAR_ID = extract(year from ORDERDATE);

--5
--5.1 Su dung IQR/ BOXPlOT tim outlier

with box_plot_table as (Select 
percentile_cont(0.25) within group(order by quantityordered) as pct_25,
percentile_cont(0.75) within group(order by quantityordered) as pct_75,
percentile_cont(0.75) within group(order by quantityordered)-percentile_cont(0.25) within group(order by quantityordered) as IQR,
percentile_cont(0.25) within group(order by quantityordered) -1.5* (percentile_cont(0.75) within group(order by quantityordered)-percentile_cont(0.25) within group(order by quantityordered)) as min_boxplot,
percentile_cont(0.75) within group(order by quantityordered) + 1.5*(percentile_cont(0.75) within group(order by quantityordered)-percentile_cont(0.25) within group(order by quantityordered)) as max_boxplot
from sales_dataset_rfm_prj),
boxplot_outlier_table as (Select *
from sales_dataset_rfm_prj
where quantityordered < (select min_boxplot from box_plot_table) or quantityordered >(select max_boxplot from box_plot_table))
  
--5.2 Su dung z-score tim outlier
  
with avg_sttdev_table as (Select *,
(Select avg(quantityordered) from sales_dataset_rfm_prj) as avg,
(Select stddev(quantityordered) from sales_dataset_rfm_prj) as sttdev
from sales_dataset_rfm_prj),
z_score_outlier_table as (Select *,
(quantityordered-avg)/sttdev as z_score
from avg_sttdev_table
where abs((quantityordered-avg)/sttdev) >3)
  
--5.3 Xử lý outlier
--delete outlier với boxplox
  
delete from sales_dataset_rfm_prj
where quantityordered in (Select quantityordered from boxplot_outlier_table);

--delete outlier với z-score

delete from sales_dataset_rfm_prj
where quantityordered in (Select quantityordered from z_score_outlier_table);

--6. Update bảng ghi mới
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
(SELECT *
FROM sales_dataset_rfm_prj);

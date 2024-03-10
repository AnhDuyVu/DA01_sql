/*1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng */
II. Ad-hoc tasks
Select month_year,
total_user,
total_order
from (Select extract(year from created_at) || '-' || lpad(cast(extract(month from created_at) as string),2,'0') as month_year,
count(distinct user_id) as total_user,
count(distinct order_id) as total_order
from bigquery-public-data.thelook_ecommerce.order_items
where status = 'Complete'
group by 1
order by 1) as month_year_table
where month_year between '2019-01' and '2022-04';
--- insight: Nhìn chung, đơn hàng tăng hàng năm. Chỉ trong năm đầu tiên, 2019, đơn hàng tăng từ tháng thứ 2 cho đến cuối năm. Trái lại, trong năm 2020 và 2021, số lượng đơn hàng tăng mạnh tháng 02 so tháng 1, và tháng 11 đơn hàng giảm mạnh so với tháng 10.

/*2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng */

Select month_year,
count(distinct user_id) as distinct_user,
sum(sale_price)/count(distinct order_id) as average_order_value
from (Select 
extract(year from created_at) || '-' || lpad(cast(extract(month from created_at) as string),2,'0') as month_year,
user_id,
order_id,
sale_price,
status
from bigquery-public-data.thelook_ecommerce.order_items
order by 1) as month_year_price_table
where month_year between '2019-01' and '2022-04' and status = 'Complete'
group by 1
order by 1;
-- insight: Nhìn chung, vào năm 2019, giá trị đơn hàng trung bình tăng mạnh từ 16.47 lên 78. Tuy nhiên, trong các năm 2020 và 2021, có xu hướng giảm từ 88 xuống 89 vào năm 2020 và từ 98 xuống 86 vào năm 2021. Điển hình là so sánh giữa tháng 2 và tháng 1 năm 2021, giá trị đơn hàng trung bình không tăng tỉ lệ thuận với tổng lượng người dùng theo từng tháng. Mặc dù tổng số người dùng tăng từ 213 lên 257, nhưng giá trị đơn hàng trung bình giảm từ 98.57 xuống 87.61.

/*3. Nhóm khách hàng theo độ tuổi*/
with youngest_oldest_table as (Select b.first_name,b.last_name,b.gender,b.age,
case when b.age = a.youngest then 'youngest' else null end as tag
from (Select gender,
min(age) as youngest
from bigquery-public-data.thelook_ecommerce.users group by gender) as a
join bigquery-public-data.thelook_ecommerce.users as b
on a.gender = b.gender and a.youngest = b.age 
where created_at between '2019-01-01' and '2022-05-01'
union distinct 
Select d.first_name,d.last_name,d.gender,d.age,
case when d.age = c.oldest then 'oldest' else null end as tag
from (Select gender,
max(age) as oldest
from bigquery-public-data.thelook_ecommerce.users group by gender) as c
join bigquery-public-data.thelook_ecommerce.users as d
on c.gender = d.gender and c.oldest = d.age
where created_at between '2019-01-01' and '2022-05-01')
Select gender, age,
sum(case when tag = 'youngest' then 1 else 0 end) as total_youngest,
sum(case when tag = 'oldest' then 1 else 0 end) as total_oldest
from youngest_oldest_table
group by gender,age
order by gender,age;

--insight: trẻ nhất ở nam và nữ là 12 tuổi, trong đó sô lượng nữ 12 tuổi là 542, số lượng nam 12 tuổi là 529, già nhất ở nam và nữ là 70 tuổi, trong đó số luọng nữ 70 tuổi là 529, số lượng nam 70 tuổi là 540

/*4 top 5 sản phẩm mỗi tháng*/

with new_table as (Select extract(year from created_at) || '-' || lpad(cast(extract(month from created_at) as string),2,'0') as month_year,
       product_id,
       p.name as product_name,
       sale_price as sales,
       p.cost as cost,
       (sale_price - p.cost) as profit
from bigquery-public-data.thelook_ecommerce.order_items as o
left join bigquery-public-data.thelook_ecommerce.products as p
on o.product_id = p.id),
rank_per_month_table as (Select *,
dense_rank() over(partition by month_year order by profit desc,product_name asc) as rank_per_month
from new_table
order by month_year)
Select *
from rank_per_month_table
where rank_per_month <=5;

/*5 Doanh thu tính đến thời điểm hiện tại của mỗi danh mục*/

--5.1 Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua

with new_table as (Select extract(date from created_at) as dates,
       p.category as product_category,
       sum(o.sale_price) as revenue
from bigquery-public-data.thelook_ecommerce.order_items as o
left join bigquery-public-data.thelook_ecommerce.products as p
on o.product_id = p.id 
group by extract(date from created_at),p.category
order by 1,2)
Select *
from new_table
where dates between '2022-01-15' and '2022-04-15'
order by product_category, dates;

--5.2 Doanh thu tính đến thời điểm hiện tại của mỗi danh mục trong vòng 3 tháng qua

with new_table as (Select extract(date from created_at) as dates,
       p.category as product_category,
       sum(o.sale_price) as revenue
from bigquery-public-data.thelook_ecommerce.order_items as o
left join bigquery-public-data.thelook_ecommerce.products as p
on o.product_id = p.id 
group by extract(date from created_at),p.category
order by 1,2),
day_revenue_table as (Select *
from new_table
where dates between '2022-01-15' and '2022-04-15'
order by product_category, dates),
rank_revenue_table as (Select *,
dense_rank() over(partition by product_category order by cumulative_revenue desc) as rank_revenue
from (Select *,
sum(revenue) over(partition by product_category order by dates) as cumulative_revenue
from day_revenue_table) as cumulative_revenue_table)
Select '2022-01-15' as begin_date,
'2022-04-15' as to_date,
product_category,
cumulative_revenue as revenue
from rank_revenue_table
where rank_revenue = 1;

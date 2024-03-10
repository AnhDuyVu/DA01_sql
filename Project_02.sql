/*1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng */

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

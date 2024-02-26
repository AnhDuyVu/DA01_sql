--ex01
select  
      sum(case 
      when device_type = 'laptop' and view_time is not null then 1 else 0 end) as laptop_views,
      sum (CASE
      when (device_type = 'tablet' or device_type = 'phone') and view_time is not null then 1 else 0 end) as mobile_views
from viewership;

--ex02
Select x,y,z,
     case 
         when ((x+y)>z and (x+z) > y and (y+z) > x) then 'Yes' else 'No' 
     End as triangle
 from Triangle;

--ex03
SELECT
      round(sum(case when (call_category = 'n/a' or call_category is null) then 1 else 0 end)/ count(*),1) as call_percentage
from callers;

--ex 04
Select name
from Customer
where coalesce(referee_id,0) <>2;

--ex 05
select survived,
       sum(case when pclass = 1 then 1 else 0 end) as first_class,
       sum(case when pclass = 2 then 1 else 0 end) as second_class,
       sum(case when pclass = 3 then 1 else 0 end) as third_class
from titanic
group by survived;

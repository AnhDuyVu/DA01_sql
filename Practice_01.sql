---EX1
Select name from city
where countrycode = 'USA' and population > 120000;

---EX2
Select * from city
where countrycode = 'JPN';

---EX3
Select city, state from station;

---EX4
Select distinct city from station
where city like 'a%' or city like 'e%' or city like 'i%' or city like 'o%' or city like 'u%';

---EX5
Select distinct city from station
where city like '%a' or city like '%e' or city like '%i' or city like '%o' or city like '%u';

---EX6
Select distinct city from station
where city not like 'a%' and city not like 'e%' and city not like 'i%' and city not like 'o%' and city not like 'u%'; 

---EX7
Select name from employee
order by name;

---EX8
Select name from employee
where salary > 2000 and months <10
order by employee_id asc;

---EX9
Select product_id from products
where low_fats = 'Y' and recyclable = 'Y';

---EX10
Select name from Customer
where referee_id <> 2 or referee_id is null;

---EX11
Select name, population, area from world
where area >= 3000000 or population >= 25000000;

---EX12
Select distinct author_id as id from Views
where author_id = viewer_id
order by author_id asc;

---EX13
SELECT part, assembly_step from parts_assembly
where finish_date is null;

---EX14
select * from lyft_drivers
where yearly_salary <= 30000 or yearly_salary >= 70000;

---EX15
select advertising_channel from uber_advertising
where money_spent > 100000 and year = 2019;



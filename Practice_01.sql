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



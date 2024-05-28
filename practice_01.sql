--1. https://www.hackerrank.com/challenges/revising-the-select-query-2/problem?isFullScreen=true
SELECT NAME
FROM CITY 
WHERE COUNTRYCODE = 'USA' AND POPULATION > 120000;

--2. https://www.hackerrank.com/challenges/japanese-cities-attributes/problem?isFullScreen=true
SELECT *
FROM CITY
WHERE COUNTRYCODE = 'JPN';

--3. https://www.hackerrank.com/challenges/weather-observation-station-1/problem?isFullScreen=true
SELECT CITY, STATE
FROM STATION;

--4. https://www.hackerrank.com/challenges/weather-observation-station-6/problem?isFullScreen=true

SELECT DISTINCT CITY
FROM STATION
WHERE CITY LIKE 'e%' OR CITY LIKE 'a%' OR CITY LIKE 'i%' OR CITY LIKE 'o%' OR CITY LIKE 'u%' ;


--5. https://www.hackerrank.com/challenges/weather-observation-station-7/problem?isFullScreen=true
SELECT DISTINCT CITY
FROM STATION
WHERE CITY LIKE '%a' OR CITY LIKE '%e' OR CITY LIKE '%i' OR CITY LIKE '%o' OR CITY LIKE '%u';

--6. https://www.hackerrank.com/challenges/weather-observation-station-9/problem?isFullScreen=true

SELECT DISTINCT CITY
FROM STATION
WHERE CITY NOT LIKE 'a%' OR CITY NOT LIKE 'e%' OR CITY NOT LIKE 'i%' OR CITY NOT LIKE 'o%' OR CITY NOT LIKE 'u%';


--7. https://www.hackerrank.com/challenges/name-of-employees/problem?isFullScreen=true
SELECT name
FROM Employee 
ORDER BY name;

--8. https://www.hackerrank.com/challenges/salary-of-employees/problem?isFullScreen=true
SELECT name
FROM Employee
WHERE salary > 2000 AND months < 10 
ORDER BY employee_id 

--9. https://leetcode.com/problems/recyclable-and-low-fat-products/?envType=study-plan-v2&envId=top-sql-50
SELECT product_id
FROM Products 
WHERE low_fats = 'Y' AND recyclable = 'Y';

--10. https://leetcode.com/problems/find-customer-referee/?envType=study-plan-v2&envId=top-sql-50
SELECT name
FROM Customer
WHERE referee_id != 2 OR referee_id is null;

--11. https://leetcode.com/problems/big-countries/?envType=study-plan-v2&envId=top-sql-50
SELECT name, population, area
FROM World 
WHERE area >= 3000000 or population >= 25000000

--12. https://leetcode.com/problems/article-views-i/?envType=study-plan-v2&envId=top-sql-50
SELECT DISTINCT author_id AS id 
FROM Views
WHERE author_id = viewer_id 
ORDER BY author_id

--13. https://datalemur.com/questions/tesla-unfinished-parts
SELECT part, assembly_step
FROM parts_assembly 
WHERE finish_date is null;

--14. https://platform.stratascratch.com/coding/10003-lyft-driver-wages?code_type=1
select * 
from lyft_drivers 
where yearly_salary <= 30000 or yearly_salary >= 70000;

--15. https://platform.stratascratch.com/coding/10002-find-the-advertising-channel-where-uber-spent-more-than-100k-usd-in-2019?code_type=1
select advertising_channel
from uber_advertising
where money_spent > 100000 and year = 2019;


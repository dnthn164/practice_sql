--1. https://datalemur.com/questions/laptop-mobile-viewership
SELECT 
SUM(CASE 
  WHEN device_type = 'laptop' THEN 1
  ELSE 0
END) as laptop_reviews,
SUM(CASE 
  WHEN device_type IN ('phone', 'tablet') THEN 1
  ELSE 0
END) as mobile_reviews
FROM viewership;

--2. https://leetcode.com/problems/triangle-judgement/?envType=study-plan-v2&envId=top-sql-50
SELECT x, y, z, 
CASE 
    WHEN x+y > z AND x+z > y AND y+z > x THEN 'Yes'
    ELSE 'No'
END as triangle
FROM Triangle 

--3. https://datalemur.com/questions/uncategorized-calls-percentage
SELECT 
ROUND((SUM(CASE
  WHEN call_category = 'n/a' OR call_category is null THEN 1
  ELSE 0 
END)/COUNT(*))*100,1) as call_percentage
FROM callers;

--4. https://leetcode.com/problems/find-customer-referee/?envType=study-plan-v2&envId=top-sql-50
SELECT name
FROM Customer
WHERE COALESCE(referee_id, "") !=2 


--5. https://platform.stratascratch.com/coding/9881-make-a-report-showing-the-number-of-survivors-and-non-survivors-by-passenger-class?code_type=1
select survived,
SUM(CASE 
    WHEN pclass = 1 THEN 1
    ELSE 0 
END) as first_class,
SUM(CASE 
    WHEN pclass = 2 THEN 1
    ELSE 0 
END) as second_class,
SUM(CASE 
    WHEN pclass = 3 THEN 1
    ELSE 0 
END) as third_class
from titanic
group by survived






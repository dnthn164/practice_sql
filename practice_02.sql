---1. https://www.hackerrank.com/challenges/weather-observation-station-3/problem?isFullScreen=true
SELECT DISTINCT CITY
FROM STATION
WHERE ID%2=0

 --2. https://www.hackerrank.com/challenges/weather-observation-station-4/problem?isFullScreen=true
SELECT COUNT(CITY) - COUNT(DISTINCT CITY)
FROM STATION

--3. https://www.hackerrank.com/challenges/the-blunder/problem?isFullScreen=true
SELECT CEILING(AVG(salary) - AVG(REPLACE(salary, '0', '')))
FROM EMPLOYEES

--4. https://datalemur.com/questions/alibaba-compressed-mean

SELECT ROUND(CAST(SUM(item_count	* order_occurrences) / SUM(order_occurrences) as decimal ),1) as mean 
FROM items_per_order

--5. https://datalemur.com/questions/matching-skills
SELECT candidate_id
FROM candidates
WHERE skill in ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(skill) = 3
ORDER BY candidate_id;

--6. https://datalemur.com/questions/sql-average-post-hiatus-1
SELECT user_id, 
DATE(MAX(post_date)) - DATE(MIN(post_date)) as days_between
FROM posts
WHERE post_date >= '2021-01-01' and post_date <  '2022-01-01'
GROUP BY user_id
HAVING COUNT(post_id) >= 2;

--7. https://datalemur.com/questions/cards-issued-difference
SELECT card_name, 
MAX(issued_amount) - MIN(issued_amount) as difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference desc

--8. https://datalemur.com/questions/non-profitable-drugs
SELECT manufacturer,
COUNT(drug) as drug_count,
ABS(SUM(cogs - total_sales)) as total_loss
FROM pharmacy_sales
WHERE total_sales < cogs
GROUP BY manufacturer
ORDER BY total_loss DESC

--9. https://leetcode.com/problems/not-boring-movies/?envType=study-plan-v2&envId=top-sql-50
SELECT *
FROM Cinema
WHERE id%2=1 and description != 'boring'
ORDER BY rating desc

--10. https://leetcode.com/problems/number-of-unique-subjects-taught-by-each-teacher/?envType=study-plan-v2&envId=top-sql-50
SELECT teacher_id, COUNT(DISTINCT subject_id) as cnt
FROM Teacher
GROUP BY teacher_id

--11. https://leetcode.com/problems/find-followers-count/?envType=study-plan-v2&envId=top-sql-50
SELECT user_id, COUNT(follower_id) as followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id 

--12. https://leetcode.com/problems/classes-more-than-5-students/?envType=study-plan-v2&envId=top-sql-50
SELECT class
FROM Courses
GROUP BY class
HAVING COUNT(student) >= 5















--1. https://www.hackerrank.com/challenges/more-than-75-marks/problem?isFullScreen=true
SELECT Name
FROM STUDENTS
WHERE marks > 75
ORDER BY  RIGHT(Name, 3), ID

--2. https://leetcode.com/problems/fix-names-in-a-table/?envType=study-plan-v2&envId=top-sql-50
SELECT user_id,
CONCAT(UPPER(LEFT(name,1)), Lower(right(name,LENGTH(name) - 1))) as name
FROM Users
ORDER BY user_id

--3. https://datalemur.com/questions/total-drugs-sales
SELECT manufacturer, 
'$' || ROUND(SUM(total_sales)/1000000,0) ||' ' || 'milion' as sale
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) desc, manufacturer 

--4. https://datalemur.com/questions/sql-avg-review-ratings
SELECT 
EXTRACT('month' from submit_date	) as mth,
product_id as product,
ROUND(avg(stars),2) as avg_stars
FROM reviews
GROUP BY mth, product
ORDER BY mth, product

--5. https://datalemur.com/questions/teams-power-users
SELECT sender_id,
COUNT(receiver_id) as message_count
FROM messages
WHERE EXTRACT('month' from sent_date) = 8 and EXTRACT('year' from sent_date) = 2022
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2

--6. https://leetcode.com/problems/invalid-tweets/?envType=study-plan-v2&envId=top-sql-50
SELECT tweet_id 
FROM Tweets
WHERE LENGTH(content) > 15

--7. https://leetcode.com/problems/user-activity-for-the-past-30-days-i/?envType=study-plan-v2&envId=top-sql-50
SELECT activity_date as day, count(distinct user_id ) as active_users 
FROM Activity
WHERE activity_date between '2019-06-28' and '2019-07-27'
GROUP BY activity_date

--8. https://platform.stratascratch.com/coding/2151-number-of-hires-during-specific-time-period?code_type=1
select count(id) as number_employee
from employees
where extract('month' from joining_date) between 1 and 7 
and extract('year' from joining_date) = 2022


--9. https://platform.stratascratch.com/coding/9829-positions-of-letter-a?code_type=1
select position('a' in first_name) as position
from worker
where first_name = 'Amitah'


--10. https://platform.stratascratch.com/coding/10039-macedonian-vintages?code_type=1
select substring(title, length(winery)+2, 4)
from winemag_p2
where country = 'Macedonia'





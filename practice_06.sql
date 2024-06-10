--1. https://datalemur.com/questions/duplicate-job-listings
With company_information as (
SELECT company_id, title, description, count(*)
FROM job_listings
GROUP BY company_id, title, description
HAVING count(*) > 1
)
SELECT count(*)
FROM company_information 

--2. https://datalemur.com/questions/sql-highest-grossing
SELECT 
  category, 
  product, 
  total_spend 
FROM (
  SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER (
      PARTITION BY category 
      ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
) AS ranked_spending
WHERE ranking <= 2 
ORDER BY category, ranking;

  
--3. https://datalemur.com/questions/frequent-callers
WITH CTE as (
SELECT policy_holder_id, count(call_duration_secs)
FROM callers 
GROUP BY policy_holder_id
HAVING count(call_duration_secs) >=3 
)
SELECT COUNT(*) as member_count
FROM CTE 

--4. https://datalemur.com/questions/sql-page-with-no-likes
WITH CTE as (
SELECT a.page_id
FROM pages as a
LEFT JOIN page_likes as b 
ON a.page_id = b.page_id
WHERE b.page_id is null 
ORDER BY a.page_id 
)
SELECT page_id 
FROM CTE 
  
--5. https://datalemur.com/questions/user-retention
WITH cte_user AS (
  SELECT user_id, EXTRACT(MONTH FROM event_date) AS mth
  FROM user_actions
  WHERE event_type IN ('sign-in','like','comment')  AND 
  EXTRACT (MONTH FROM event_date) IN (6,7) AND
  EXTRACT(YEAR FROM event_date)= 2022
  GROUP BY user_id, mth
  HAVING COUNT(EXTRACT(MONTH FROM event_date))  = 2
)
SELECT mth, COUNT(user_id) AS monthly_active_users
FROM cte_user
WHERE mth = 7
GROUP BY mth;

--6. https://leetcode.com/problems/monthly-transactions-i/?envType=study-plan-v2&envId=top-sql-50
SELECT LEFT(trans_date,7) as month, country, COUNT(amount) as trans_count,
SUM(
    CASE 
    WHEN state = 'approved' THEN 1 ELSE 0 END) as approved_count, 
    SUM(amount) as trans_total_amount, 
    SUM(
      CASE WHEN state = 'approved' THEN amount
      ELSE 0
    END ) as approved_total_amount
FROM Transactions
GROUP BY EXTRACT(YEAR FROM trans_date), EXTRACT(MONTH FROM trans_date), country
  
--7. https://leetcode.com/problems/product-sales-analysis-iii/?envType=study-plan-v2&envId=top-sql-50
WITH cte_year as (
  SELECT product_id, MIN(year) as first_year
  FROM Sales 
  GROUP BY product_id 
) 
SELECT a.product_id, a.first_year, b.quantity, b.price
FROM cte_year as a
JOIN Sales as b 
ON a.product_id = b.product_id AND first_year = b.year
  
--8. https://leetcode.com/problems/customers-who-bought-all-products/?envType=study-plan-v2&envId=top-sql-50
SELECT customer_id
FROM Customer 
GROUP BY customer_id 
HAVING COUNT(DISTINCT product_key) = (
  SELECT COUNT(product_key)
  FROM Product
)
  
--9. https://leetcode.com/problems/employees-whose-manager-left-the-company/?envType=study-plan-v2&envId=top-sql-50
SELECT employee_id 
FROM Employees 
WHERE manager_id not in
(
  SELECT employee_id 
  FROM Employees 
)
AND salary < 30000
ORDER BY employee_id 
  
--10. https://leetcode.com/problems/primary-department-for-each-employee/
WITH CTE AS (
SELECT Employee_id, count(department_id) as a
FROM Employee
GROUP BY employee_id
)
SELECT employee_id, department_id
FROM Employee
WHERE employee_id IN (SELECT Employee_id FROM CTE WHERE a = 1)
UNION
SELECT employee_id, department_id
FROM Employee
WHERE primary_flag = "Y"

  
--11. https://leetcode.com/problems/movie-rating/?envType=study-plan-v2&envId=top-sql-50
WITH cte AS (
    SELECT a.name AS results
    FROM Users AS a
    JOIN MovieRating AS b ON a.user_id = b.user_id
    GROUP BY a.name
    ORDER BY COUNT(*) DESC, a.name
    LIMIT 1
),
cte2 AS (
    SELECT c.title AS results
    FROM Movies AS c
    JOIN MovieRating AS d ON c.movie_id = d.movie_id
    WHERE EXTRACT(MONTH FROM d.created_at) = 2
      AND EXTRACT(YEAR FROM d.created_at) = 2020
    GROUP BY c.title
    ORDER BY AVG(d.rating) DESC, c.title
    LIMIT 1
)
SELECT * FROM cte
UNION ALL
SELECT * FROM cte2;

  
--12. https://leetcode.com/problems/friend-requests-ii-who-has-the-most-friends/?envType=study-plan-v2&envId=top-sql-50
With cte_friends AS
(
SELECT requester_id, accepter_id
FROM RequestAccepted
UNION ALL
SELECT accepter_id, requester_id
FROM RequestAccepted
)
SELECT requester_id as id, count(accepter_id) as num
FROM cte_friends
group by 1
ORDER BY 2 DESC
LIMIT 1

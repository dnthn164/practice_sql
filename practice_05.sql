--1. https://www.hackerrank.com/challenges/average-population-of-each-continent/problem?isFullScreen=true
SELECT B.CONTINENT, FLOOR(AVG(A.POPULATION))
FROM CITY AS A
INNER JOIN COUNTRY AS B
ON A.COUNTRYCODE = B.CODE
GROUP BY B.CONTINENT

--2. https://datalemur.com/questions/signup-confirmation-rate
SELECT ROUND(AVG(
CASE
  WHEN signup_action = 'Confirmed' THEN 1
  ELSE 0
END),2)
FROM emails as a
JOIN texts as b 
ON a.email_id = b.email_id

--3. https://datalemur.com/questions/time-spent-snaps
SELECT b.age_bucket, 
ROUND(SUM(CASE WHEN a.activity_type = 'send' THEN time_spent ELSE 0 END)*100.0/
(SUM(CASE WHEN a.activity_type = 'send' THEN time_spent ELSE 0 END)+
SUM(CASE WHEN a.activity_type = 'open' THEN time_spent ELSE 0 END)),2) as send_perc,

ROUND(SUM(CASE WHEN a.activity_type = 'open' THEN time_spent ELSE 0 END)*100.0/
(SUM(CASE WHEN a.activity_type = 'send' THEN time_spent ELSE 0 END)+
SUM(CASE WHEN a.activity_type = 'open' THEN time_spent ELSE 0 END)),2) as send_perc
FROM activities as a
JOIN age_breakdown as b 
ON a.user_id = b.user_id
GROUP BY b.age_bucket

--4. https://datalemur.com/questions/supercloud-customer
SELECT a.customer_id 
FROM customer_contracts as a
JOIN products as b 
ON a.product_id = b.product_id
GROUP BY a.customer_id 
HAVING COUNT(DISTINCT b.product_category) = 3

--5. https://leetcode.com/problems/the-number-of-employees-which-report-to-each-employee/?envType=study-plan-v2&envId=top-sql-50
SELECT t1.employee_id, t1.name, COUNT(t2.reports_to ) as reports_count, 
ROUND(AVG(t2.age)) as average_age
FROM Employees as t1
JOIN Employees as t2 
ON t1.employee_id = t2.reports_to 
GROUP BY t1.Employee_id, t1.name
ORDER BY t1.Employee_id asc

--6. https://leetcode.com/problems/list-the-products-ordered-in-a-period/?envType=study-plan-v2&envId=top-sql-50
select p.product_name, 
sum(unit) as unit    
from Products as p
join Orders as o
on p.product_id = o.product_id 
where EXTRACT(MONTH from o.order_date) = 2 and EXTRACT(YEAR FROM o.order_date) = 2020
group by p.product_name
HAVING sum(unit) >=100

--7. https://datalemur.com/questions/sql-page-with-no-likes
SELECT a.page_id
FROM pages as a
LEFT JOIN page_likes as b 
ON a.page_id = b.page_id
WHERE b.page_id is null 
ORDER BY a.page_id 

/*
Question 1:

Level: Basic

Topic: DISTINCT

Task: Tạo danh sách tất cả chi phí thay thế (replacement costs )  khác nhau của các film.

Question: Chi phí thay thế thấp nhất là bao nhiêu?
Answer: 9.99
*/
SELECT DISTINCT(replacement_cost), MIN(replacement_cost)
FROM film
GROUP BY replacement_cost

/*
Question 2:
Level: Intermediate
Topic: CASE + GROUP BY
Task: Viết một truy vấn cung cấp cái nhìn tổng quan về số lượng phim có chi phí thay thế trong các phạm vi chi phí sau
1.	low: 9.99 - 19.99
2.	medium: 20.00 - 24.99
3.	high: 25.00 - 29.99
Question: Có bao nhiêu phim có chi phí thay thế thuộc nhóm “low”?
Answer: 514
*/
SELECT 
CASE 
	WHEN replacement_cost between 9.99 and 19.99 THEN 'low'
	WHEN replacement_cost between 20.00 and 24.99 THEN 'medium'
	ELSE 'high'
END as category,
COUNT(
CASE
	WHEN replacement_cost between 9.99 and 19.99 THEN 1 ELSE 0
END)
FROM film
GROUP BY category


/*
Question 3:
Level: c
Topic: JOIN
Task: Tạo danh sách các film_title  bao gồm tiêu đề (title), độ dài (length) và 
tên danh mục (category_name) được sắp xếp theo độ dài giảm dần. 
Lọc kết quả để chỉ các phim trong danh mục 'Drama' hoặc 'Sports'.
Question: Phim dài nhất thuộc thể loại nào và dài bao nhiêu?
Answer: Sports : 184
*/
SELECT a.title as ten_phim, a.length as do_dai, c.name as danh_muc
FROM film as a
JOIN film_category  as b 
ON a.film_id = b.film_id
JOIN category as c
ON b.category_id = c.category_id
WHERE c.name IN ('Drama', 'Sports')
ORDER BY a.length desc 
LIMIT 1

/*
Question 4:
Level: Intermediate
Topic: JOIN & GROUP BY
Task: Đưa ra cái nhìn tổng quan về số lượng phim (tilte) trong mỗi danh mục (category).
Question:Thể loại danh mục nào là phổ biến nhất trong số các bộ phim?
Answer: Sports :74 titles
*/
SELECT c.name as danh_muc,
COUNT(a.title) as so_luong_phim
FROM film as a
JOIN film_category  as b 
ON a.film_id = b.film_id
JOIN category as c
ON b.category_id = c.category_id
GROUP BY danh_muc
ORDER BY so_luong_phim desc
LIMIT 1


/*
Question 5:
Level: Intermediate
Topic: JOIN & GROUP BY
Task:Đưa ra cái nhìn tổng quan về họ và tên của các diễn viên 
cũng như số lượng phim họ tham gia.
Question: Diễn viên nào đóng nhiều phim nhất?
Answer: Susan Davis : 54 movies
*/
SELECT c.first_name || ' ' || c.last_name as full_name,
COUNT(b.film_id) as so_luong
FROM film as a
JOIN film_actor as b
ON a.film_id = b.film_id 
JOIN actor as c 
ON c.actor_id = b.actor_id
GROUP BY full_name 
ORDER BY so_luong desc 
LIMIT 1


/*
Question 6:
Level: Intermediate
Topic: LEFT JOIN & FILTERING
Task: Tìm các địa chỉ không liên quan đến bất kỳ khách hàng nào.
Question: Có bao nhiêu địa chỉ như vậy?
Answer: 4
*/
SELECT 
COUNT(1) FILTER 
(WHERE  b.address_id is null) AS so_luong
FROM address as a
LEFT JOIN customer as b 
ON a.address_id = b.address_id 


/*
Question 7:
Level: Intermediate
Topic: JOIN & GROUP BY
Task: Danh sách các thành phố và doanh thu tương ừng trên từng thành phố 
Question:Thành phố nào đạt doanh thu cao nhất?
Answer: Cape Coral : 221.55
*/
SELECT a.city, SUM(amount) as doanh_thu
FROM city as a
JOIN address as b
ON a.city_id = b.city_id
JOIN customer as c
ON c.address_id = b.address_id 
JOIN payment as d
ON d.customer_id = c.customer_id
GROUP BY a.city
ORDER BY SUM(amount) desc
LIMIT 1

/*
Question 8:
Level: Intermediate 
Topic: JOIN & GROUP BY
Task: Tạo danh sách trả ra 2 cột dữ liệu: 
-	cột 1: thông tin thành phố và đất nước ( format: “city, country")
-	cột 2: doanh thu tương ứng với cột 1
Question: thành phố của đất nước nào đat doanh thu cao nhất
Answer: United States, Tallahassee : 50.85.
*/

SELECT a.city || ', ' || e.country as city_country, 
SUM(amount) as doanh_thu
FROM city as a
JOIN address as b
ON a.city_id = b.city_id
JOIN country as e 
ON a.country_id = e.country_id
JOIN customer as c
ON c.address_id = b.address_id 
JOIN payment as d
ON d.customer_id = c.customer_id
GROUP BY a.city, e.country
ORDER BY SUM(amount) 
LIMIT 1










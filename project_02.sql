SELECT *
FROM bigquery-public-data.thelook_ecommerce.orders;
SELECT * 
FROM bigquery-public-data.thelook_ecommerce.order_items;
------------------------------------------------------------------------------------------------------
/* Thống kê tổng số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng ( Từ 1/2019 - 4/2022)
Output: month_year ( yyyy-mm) , total_user, total_order
*/
SELECT 
    COUNT(DISTINCT a.user_id) AS total_user, 
    COUNT(a.num_of_item) AS total_order,
    FORMAT_TIMESTAMP('%Y-%m', b.created_at) AS month_year
FROM 
    bigquery-public-data.thelook_ecommerce.orders AS a
JOIN 
    bigquery-public-data.thelook_ecommerce.order_items AS b 
ON 
    a.user_id = b.user_id
WHERE 
    b.created_at BETWEEN '2019-01-01' AND '2022-04-30' 
    AND b.status = "Complete"
GROUP BY 
    month_year
ORDER BY 
    month_year;

--Insight: mỗi tháng số lượng order đều tăng đáng kể.
-------------------------------------------------------------------------------------------------

/*
Thống kê giá trị đơn hàng trung bình và tổng số người dùng khác nhau mỗi tháng 
( Từ 1/2019-4/2022)
Output: month_year ( yyyy-mm), distinct_users, average_order_value
*/

SELECT *
FROM bigquery-public-data.thelook_ecommerce.orders;
SELECT * 
FROM bigquery-public-data.thelook_ecommerce.order_items;
-------
SELECT 
    FORMAT_TIMESTAMP('%Y-%m', a.created_at) AS month_year,
    COUNT(DISTINCT a.user_id) AS total_user, 
    SUM(sale_price)/COUNT(a.order_id)  AS average_order_value
   
FROM 
    bigquery-public-data.thelook_ecommerce.orders AS a
JOIN 
    bigquery-public-data.thelook_ecommerce.order_items AS b 
ON 
    a.order_id = b.order_id
WHERE 
    a.created_at BETWEEN '2019-01-01' AND '2022-04-30'
GROUP BY 
    month_year
ORDER BY 
    month_year;

--------------------------------------------------------------------------------------------------------------
/*
Tìm các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính ( Từ 1/2019-4/2022)
Output: first_name, last_name, gender, age, tag (hiển thị youngest nếu trẻ tuổi nhất, oldest nếu lớn tuổi nhất)
*/

SELECT *
FROM bigquery-public-data.thelook_ecommerce.orders;
SELECT * 
FROM bigquery-public-data.thelook_ecommerce.order_items;
--
CREATE TEMP TABLE customer_age AS
WITH filtered_users AS (
    SELECT 
        first_name, 
        last_name, 
        gender, 
        age,
        created_at
    FROM 
        bigquery-public-data.thelook_ecommerce.users
    WHERE 
        created_at BETWEEN '2019-01-01' AND '2022-04-30'
),
youngest_ages AS (
    SELECT 
        gender, 
        MIN(age) AS age
    FROM 
        filtered_users
    GROUP BY 
        gender
),
oldest_ages AS (
    SELECT 
        gender, 
        MAX(age) AS age
    FROM 
        filtered_users
    GROUP BY 
        gender
)
SELECT 
    u.first_name, 
    u.last_name, 
    u.gender, 
    u.age, 
    'youngest' AS tag
FROM 
    filtered_users u
JOIN 
    youngest_ages y
ON 
    u.gender = y.gender AND u.age = y.age
UNION ALL
SELECT 
    u.first_name, 
    u.last_name, 
    u.gender, 
    u.age, 
    'oldest' AS tag
FROM 
    filtered_users u
JOIN 
    oldest_ages o
ON 
    u.gender = o.gender AND u.age = o.age;

SELECT 
    gender, 
    tag, 
    age, 
    COUNT(*) AS count
FROM 
    customer_age
GROUP BY 
    gender, tag, age
ORDER BY 
    gender, tag, age;


/* Insight
Trẻ tuổi nhất ở cả nam và nữ là 12 tuổi
Số lượng như sau: 
Nữ: 453 
Nam: 508
Tổng: 961
Lớn tuổi nhất ở cả nam và nữ là 70 tuổi
Số lượng như sau:
Nữ: 541
Nam: 504
Tổng: 1045
*/


-----------------------------------------------------------------------------------
/*
Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm). 
Output: month_year ( yyyy-mm), product_id, product_name, sales, cost, profit, rank_per_month
*/

SELECT *
FROM bigquery-public-data.thelook_ecommerce.orders;
SELECT * 
FROM bigquery-public-data.thelook_ecommerce.order_items;
----------------
WITH product_sales AS (
    SELECT 
        FORMAT_TIMESTAMP('%Y-%m', i.created_at) AS month_year,
        p.id AS product_id,
        p.name AS product_name,
        SUM(i.sale_price) AS sales,
        SUM(p.cost) AS cost,
        SUM(i.sale_price - p.cost) AS profit
    FROM 
        bigquery-public-data.thelook_ecommerce.order_items AS i
    JOIN 
        bigquery-public-data.thelook_ecommerce.products AS p 
    ON 
        i.product_id = p.id
    GROUP BY 
        month_year, product_id, product_name
),
ranked_products AS (
    SELECT 
        month_year,
        product_id,
        product_name,
        sales,
        cost,
        profit,
        RANK() OVER (PARTITION BY month_year ORDER BY profit DESC) AS rank_per_month
    FROM 
        product_sales
)

SELECT 
    month_year,
    product_id,
    product_name,
    sales,
    cost,
    profit,
    rank_per_month
FROM 
    ranked_products
WHERE 
    rank_per_month <= 5
ORDER BY 
    month_year, rank_per_month;

----------------------------------------------------------------------------------------------------------------------------
/*
Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022)
Output: dates (yyyy-mm-dd), product_categories, revenue
*/

SELECT *
FROM bigquery-public-data.thelook_ecommerce.orders;
SELECT * 
FROM bigquery-public-data.thelook_ecommerce.order_items;
---------
WITH filtered_orders AS (
    SELECT 
        i.created_at,
        p.category AS product_category,
        i.sale_price AS revenue
    FROM 
        bigquery-public-data.thelook_ecommerce.order_items AS i
    JOIN 
        bigquery-public-data.thelook_ecommerce.products AS p 
    ON 
        i.product_id = p.id
    WHERE 
        i.created_at BETWEEN TIMESTAMP('2022-01-15') AND TIMESTAMP('2022-04-14')
)
SELECT 
    FORMAT_TIMESTAMP('%Y-%m-%d', created_at) AS dates,
    product_category,
    SUM(revenue) AS revenue
FROM 
    filtered_orders
GROUP BY 
    dates, product_category
ORDER BY 
    dates, product_category;
--------------------------------------------------------------------------------------------------------------
/* Tạo metric trước khi dựng dashboard
Xây dựng view gồm các cột: 
    Month (bảng orders)
    Year (bảng orders)
    Product_category (bảng product)
    TPV (bảng order_items)
    TPO (bảng order_items)
    Revenue_growth (doanh thu tháng sau - doanh thu tháng trước)/doanh thu tháng trước (hiển thị %)
    Order_growth: (số đơn hàng tháng sau - số đơn hàng tháng trước/ số đơn tháng trước (hiển thị %)
    Total_cost: bảng product
    Total_profit: tổng doanh thu - tổng chi phí
    Profit_to_cost_ratio: tổng lợi nhuận / tổng chi phí
*/

CREATE OR REPLACE VIEW project02-427007.project02.vw_ecommerce_analyst AS
WITH orders_data AS (
    SELECT 
        FORMAT_TIMESTAMP('%Y-%m', o.created_at) AS month,
        EXTRACT(YEAR FROM o.created_at) AS year,
        i.product_id,
        COUNT(o.order_id) AS order_count,
        SUM(i.sale_price) AS total_sales
    FROM 
        bigquery-public-data.thelook_ecommerce.orders AS o
    JOIN 
        bigquery-public-data.thelook_ecommerce.order_items AS i 
    ON 
        o.order_id = i.order_id
    WHERE 
        o.created_at BETWEEN TIMESTAMP('2019-01-01') AND TIMESTAMP('2022-04-30')
    GROUP BY 
        month, year, i.product_id
),
product_data AS (
    SELECT 
        p.id AS product_id,
        p.category AS product_category,
        p.cost
    FROM 
        bigquery-public-data.thelook_ecommerce.products AS p
),
monthly_metrics AS (
    SELECT 
        o.month,
        o.year,
        p.product_category,
        SUM(o.total_sales) AS tpv, 
        SUM(o.order_count) AS tpo, 
        SUM(p.cost * o.order_count) AS total_cost, 
        SUM(o.total_sales - (p.cost * o.order_count)) AS total_profit 
    FROM 
        orders_data AS o
    JOIN 
        product_data AS p
    ON 
        o.product_id = p.product_id
    GROUP BY 
        o.month, o.year, p.product_category
),
growth_metrics AS (
    SELECT 
        month,
        year,
        product_category,
        tpv,
        tpo,
        total_cost,
        total_profit,
        total_profit / total_cost AS profit_to_cost_ratio,
        (tpv - LAG(tpv) OVER (PARTITION BY product_category ORDER BY year, month)) / LAG(tpv) OVER (PARTITION BY product_category ORDER BY year, month) * 100 AS revenue_growth,
        (tpo - LAG(tpo) OVER (PARTITION BY product_category ORDER BY year, month)) / LAG(tpo) OVER (PARTITION BY product_category ORDER BY year, month) * 100 AS order_growth
    FROM 
        monthly_metrics
)

SELECT 
    month,
    year,
    product_category,
    tpv,
    tpo,
    revenue_growth,
    order_growth,
    total_cost,
    total_profit,
    profit_to_cost_ratio
FROM 
    growth_metrics
ORDER BY 
    year, month, product_category;
----------------------------------------------------------
/*
Insight
1. Phân tích tăng trưởng doanh thu (Revenue Growth)
Tháng 2/2019: Một số sản phẩm có mức tăng trưởng doanh thu cao
Fashion Hoodies & Sweatsh: tăng trưởng doanh thu đạt 544.44%.
Jeans: tăng trưởng doanh thu đạt 815.23%.
Tops & Tees: tăng trưởng doanh thu đạt 1206.32%.

Tháng 3/2019: Có một số sản phẩm có mức tăng trưởng doanh thu rất cao, chẳng hạn như:
Dresses: tăng trưởng doanh thu đạt 4062% 
Sweaters: tăng trưởng doanh thu đạt 3620%
Maternity: tăng trưởng doanh thu đạt 653%

2. Phân tích tăng trưởng đơn hàng (Order Growth)
Một số sản phẩm có sự tăng trưởng đơn hàng ấn tượng, chẳng hạn như:
Tháng 2/2019: 
+ Jeans: 500%
+ Tops & Tees: 500%
Tháng 3/2019
+ Sweaters: 800%

3. Phân tích lợi nhuận (Total Profit)
Tháng 1/2019: Một số sản phẩm có lợi nhuận cao nhất bao gồm:
Sweaters: đạt lợi nhuận là 205.91.
Shorts: đạt lợi nhuận là 83.88.
Dresses: đạt lợi nhuận là 68.09.

Tháng 2/2019: Một số sản phẩm có lợi nhuận cao nhất bao gồm:
Plus: đạt lợi nhuận là 489.40.
Jeans: đạt lợi nhuận là 389.46.
Tops & Tees: đạt lợi nhuận là 127.60.

Tháng 3/2019: Một số sản phẩm có lợi nhuận cao nhất bao gồm:
Swim: 500.74
Sweaters: 466
Dresses: 466

4. Tỷ lệ lợi nhuận trên chi phí (Profit to Cost Ratio)
Tháng 1/2019: Một số sản phẩm có tỷ lệ lợi nhuận trên chi phí cao nhất bao gồm:
Socks & Hosiery: 1.5
Blazers & Jackets: 1.44
Tháng 2/2019: 
Suits & Sport Coats: 1.59
Blazers & Jackets: 1.64
Tháng 3/2019
Suits & Sport Coats: 1.67
Blazers & Jackets: 1.64

5. Chi phí tổng (Total Cost)
Tháng 1/2019: Một số sản phẩm có chi phí cao nhất bao gồm:
Sweaters: chi phí là 212.17.
Shorts: chi phí là 83.23.

Tháng 2/2019: Một số sản phẩm có chi phí cao nhất bao gồm:
Plus: chi phí là 429.59.
Jeans: chi phí là 415.94.

Tháng 3/2019: Một số sản phẩm có chi phí cao nhất bao gồm:
Sweaters: 463.41
Swim: 425.92

6. Phân tích theo thời gian
Tăng trưởng theo tháng: Sự tăng trưởng doanh thu và số lượng đơn hàng giữa tháng 1, tháng 2 có sự biến động mạnh. Đặc biệt, một số sản phẩm như Jeans và Tops & Tees có sự gia tăng đáng kể.
Từ tháng 2 đến tháng 2: các sản phẩm Swims có sự gia tăng mạnh mẽ
*/

WITH sales_convert AS (
    SELECT 
        CAST(month AS text) AS month,
        CAST(year AS text) AS year, 
        product_category,
        CAST(REPLACE(tpv, ',', '') AS numeric) AS tpv,  
        CAST(tpo AS int) AS tpo, 
        CAST(REPLACE(total_cost, ',', '') AS numeric) AS total_cost,  
        CAST(order_growth AS numeric) AS order_growth, 
        CAST(REPLACE(total_profit, ',', '') AS numeric) AS total_profit,  
        CAST(profit_to_cost_ratio AS numeric) AS profit_to_cost_ratio,
        TO_DATE(year || '-' || LPAD(month, 2, '0') || '-01', 'YYYY-MM-DD') AS sales_date
    FROM sales_dataset
    WHERE revenue_growth IS NOT NULL 
        AND order_growth IS NOT NULL 
        AND tpv <> ''     
        AND CAST(tpo AS int) > 0
        AND total_cost <> ''
        AND total_profit <> ''
        AND profit_to_cost_ratio <> ''
),
sales_main AS (
    SELECT 
        month,
        year,
        product_category,
        tpv,
        tpo,
        total_cost,
        order_growth,
        total_profit,
        profit_to_cost_ratio,
        sales_date,
        ROW_NUMBER() OVER(PARTITION BY month, year, product_category ORDER BY month, year) AS rn
    FROM sales_convert
),
first_purchase AS (
    SELECT 
        product_category,
        tpo,
        tpv,
        total_profit,
        sales_date,
        (EXTRACT(YEAR FROM sales_date) * 12 + EXTRACT(MONTH FROM sales_date)) -
        (EXTRACT(YEAR FROM cohort_date) * 12 + EXTRACT(MONTH FROM cohort_date)) + 1 AS index,
        cohort_date
    FROM (
        SELECT 
            product_category,
            tpo,
            tpv,
            total_profit,
            sales_date,
            MIN(sales_date) OVER (PARTITION BY product_category) AS cohort_date
        FROM sales_main
    ) subquery
),
xxx AS (
    SELECT 
        cohort_date, 
        index, 
        COUNT(DISTINCT product_category) AS cnt, 
        SUM(tpv) AS revenue
    FROM first_purchase
    GROUP BY cohort_date, index
),
customer_cohort AS (
    SELECT 
        cohort_date,
        SUM(CASE WHEN index = 1 THEN cnt ELSE 0 END) AS m1,
        SUM(CASE WHEN index = 2 THEN cnt ELSE 0 END) AS m2,
        SUM(CASE WHEN index = 3 THEN cnt ELSE 0 END) AS m3,
        SUM(CASE WHEN index = 4 THEN cnt ELSE 0 END) AS m4,
        SUM(CASE WHEN index = 5 THEN cnt ELSE 0 END) AS m5,
        SUM(CASE WHEN index = 6 THEN cnt ELSE 0 END) AS m6,
        SUM(CASE WHEN index = 7 THEN cnt ELSE 0 END) AS m7,
        SUM(CASE WHEN index = 8 THEN cnt ELSE 0 END) AS m8,
        SUM(CASE WHEN index = 9 THEN cnt ELSE 0 END) AS m9,
        SUM(CASE WHEN index = 10 THEN cnt ELSE 0 END) AS m10,
        SUM(CASE WHEN index = 11 THEN cnt ELSE 0 END) AS m11,
        SUM(CASE WHEN index = 12 THEN cnt ELSE 0 END) AS m12,
        SUM(CASE WHEN index = 13 THEN cnt ELSE 0 END) AS m13
    FROM xxx
    GROUP BY cohort_date
    ORDER BY cohort_date
)
-- Retention cohort analysis
SELECT
    cohort_date,
    (100 - ROUND(100.00 * m1 / m1, 2)) || '%' AS m1,
    (100 - ROUND(100.00 * m2 / m1, 2)) || '%' AS m2,
    (100 - ROUND(100.00 * m3 / m1, 2)) || '%' AS m3,
    ROUND(100.00 * m4 / m1, 2) || '%' AS m4,
    ROUND(100.00 * m5 / m1, 2) || '%' AS m5,
    ROUND(100.00 * m6 / m1, 2) || '%' AS m6,
    ROUND(100.00 * m7 / m1, 2) || '%' AS m7,
    ROUND(100.00 * m8 / m1, 2) || '%' AS m8,
    ROUND(100.00 * m9 / m1, 2) || '%' AS m9,
    ROUND(100.00 * m10 / m1, 2) || '%' AS m10,
    ROUND(100.00 * m11 / m1, 2) || '%' AS m11,
    ROUND(100.00 * m12 / m1, 2) || '%' AS m12,
    ROUND(100.00 * m13 / m1, 2) || '%' AS m13
FROM customer_cohort;




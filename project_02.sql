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
/*
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

CREATE OR REPLACE VIEW bigquery-public-data.thelook_ecommerce.project02.vw_ecommerce_analyst AS
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


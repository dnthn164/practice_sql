SELECT *
FROM sales_dataset_rfm_prj
/*
1) Doanh thu theo từng ProductLine, Year  và DealSize?
Output: PRODUCTLINE, YEAR_ID, DEALSIZE, REVENUE
*/
SELECT
    productline,
    EXTRACT(YEAR FROM orderdate) AS year_id,
    dealsize,
    SUM(priceeach * quantityordered) AS revenue
FROM
    sales_dataset_rfm_prj
GROUP BY
    productline,
    EXTRACT(YEAR FROM orderdate),
    dealsize;
/*
2) Đâu là tháng có bán tốt nhất mỗi năm?
Output: MONTH_ID, REVENUE, ORDER_NUMBER
*/
WITH monthly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM orderdate) AS year_id,
        EXTRACT(MONTH FROM orderdate) AS month_id,
        SUM(priceeach * quantityordered) AS revenue,
        COUNT(ordernumber) AS order_number
    FROM
        sales_dataset_rfm_prj
    GROUP BY
        EXTRACT(YEAR FROM orderdate),
        EXTRACT(MONTH FROM orderdate)
)
SELECT
    year_id,
    month_id,
    revenue,
    order_number
FROM
    monthly_revenue
WHERE
    (year_id, revenue) IN (
        SELECT
            year_id,
            MAX(revenue)
        FROM
            monthly_revenue
        GROUP BY
            year_id
    );
	
/*
3) Product line nào được bán nhiều ở tháng 11?
Output: MONTH_ID, REVENUE, ORDER_NUMBER
*/
WITH november_sales AS (
    SELECT
        productline,
        EXTRACT(MONTH FROM orderdate) AS month_id,
        SUM(priceeach * quantityordered) AS revenue,
        COUNT(ordernumber) AS order_number
    FROM
        sales_dataset_rfm_prj
    WHERE
        EXTRACT(MONTH FROM orderdate) = 11
    GROUP BY
        productline,
        EXTRACT(MONTH FROM orderdate)
)
SELECT
    month_id,
    productline,
    revenue,
    order_number
FROM
    november_sales
WHERE
    revenue = (
        SELECT MAX(revenue) FROM november_sales
    );

/*
4) Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
Xếp hạng các các doanh thu đó theo từng năm.
Output: YEAR_ID, PRODUCTLINE,REVENUE, RANK
*/

WITH yearly_sales_uk AS (
    SELECT
        EXTRACT(YEAR FROM orderdate) AS year_id,
        productline,
        SUM(priceeach * quantityordered) AS revenue
    FROM
        sales_dataset_rfm_prj
    WHERE
        country = 'UK'
    GROUP BY
        EXTRACT(YEAR FROM orderdate),
        productline
),
ranked_sales AS (
    SELECT
        year_id,
        productline,
        revenue,
        RANK() OVER (PARTITION BY year_id ORDER BY revenue DESC) AS rank
    FROM
        yearly_sales_uk
)
SELECT
    year_id,
    productline,
    revenue,
    rank
FROM
    ranked_sales
WHERE
    rank = 1;

/*
5) Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
*/

WITH customers_rfm AS (
    SELECT
        customername,
        MAX(orderdate) AS last_order_date,
        COUNT(distinct ordernumber) AS F,
        SUM(priceeach * quantityordered) AS M
    FROM
        sales_dataset_rfm_prj
    GROUP BY
        customername
),

rfm_score AS (
    SELECT
        customername,
        ntile(5) OVER (ORDER BY (current_date - last_order_date) DESC) AS R_score,     
        ntile(5) OVER (ORDER BY F) AS F_score,
        ntile(5) OVER (ORDER BY M) AS M_score
    FROM
        customers_rfm
),

rfm_final AS (
    SELECT
        customername, 
        CAST(R_score AS VARCHAR) || CAST(F_score AS VARCHAR) || CAST(M_score AS VARCHAR) AS RFM_score
    FROM
        rfm_score
)
------Hiển thị các khách hàng tốt nhất

SELECT customername
FROM rfm_final
WHERE RFM_score = '555';

---Đếm số lượng khách hàng theo phân khúc
SELECT segment, COUNT(*)
FROM (
    SELECT a.customername, b.segment
    FROM rfm_final AS a
    JOIN segment_score AS b ON a.RFM_score = b.scores
) AS a 
GROUP BY segment;

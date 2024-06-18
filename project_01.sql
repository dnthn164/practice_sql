create table SALES_DATASET_RFM_PRJ
(
  ordernumber VARCHAR,
  quantityordered VARCHAR,
  priceeach        VARCHAR,
  orderlinenumber  VARCHAR,
  sales            VARCHAR,
  orderdate        VARCHAR,
  status           VARCHAR,
  productline      VARCHAR,
  msrp             VARCHAR,
  productcode      VARCHAR,
  customername     VARCHAR,
  phone            VARCHAR,
  addressline1     VARCHAR,
  addressline2     VARCHAR,
  city             VARCHAR,
  state            VARCHAR,
  postalcode       VARCHAR,
  country          VARCHAR,
  territory        VARCHAR,
  contactfullname  VARCHAR,
  dealsize         VARCHAR
) 
SELECT * FROM SALES_DATASET_RFM_PRJ 
------------------------------------
--Import từ excel nên xuất hiện một dòng tên côt
--Xóa hàng đầu tiên 
DELETE FROM SALES_DATASET_RFM_PRJ
WHERE ctid = (
    SELECT ctid
    FROM SALES_DATASET_RFM_PRJ
    LIMIT 1
);

--1/ Chuyển đổi kiểu dữ liệu phù hợp cho các trường ( sử dụng câu lệnh ALTER) 

--column ordernumber, priceeach, quantityordered, orderlinenumber, sales, msrp => numeric 

ALTER TABLE SALES_DATASET_RFM_PRJ 
ALTER COLUMN ordernumber TYPE NUMERIC USING trim(ordernumber)::NUMERIC,
ALTER COLUMN priceeach TYPE NUMERIC USING trim(priceeach)::NUMERIC,
ALTER COLUMN quantityordered TYPE NUMERIC USING trim(quantityordered)::NUMERIC,
ALTER COLUMN orderlinenumber TYPE NUMERIC USING trim(orderlinenumber)::NUMERIC,
ALTER COLUMN sales TYPE NUMERIC USING trim(sales)::NUMERIC,
ALTER COLUMN msrp TYPE NUMERIC USING trim(msrp)::NUMERIC;

--column orderdate => timestamp
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN orderdate TYPE TIMESTAMP USING to_timestamp(orderdate, 'MM/DD/YYYY HH24:MI');


--column phone
-- Cập nhật cột phone 

UPDATE SALES_DATASET_RFM_PRJ
SET phone = regexp_replace(phone, '\D', '', 'g');

--chuyển đổi kiểu dữ liệu
ALTER TABLE SALES_DATASET_RFM_PRJ
ALTER COLUMN phone TYPE VARCHAR(12) USING trim(phone);


--2/Check NULL/BLANK (‘’)  ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.
SELECT *
FROM SALES_DATASET_RFM_PRJ
WHERE (ORDERNUMBER IS NULL OR ORDERNUMBER::text = '')
   OR (QUANTITYORDERED IS NULL OR QUANTITYORDERED::text = '')
   OR (PRICEEACH IS NULL OR PRICEEACH::text = '')
   OR (SALES IS NULL OR SALES::text = '');

/*
3/Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME . 
Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường. 
Gợi ý AddColumn sau đó Update
*/

-- Thêm cột CONTACTLASTNAME và CONTACTFIRSTNAME vào bảng
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN CONTACTLASTNAME VARCHAR(100),
ADD COLUMN CONTACTFIRSTNAME VARCHAR(100);

-- Lấy dữ liệu từ cột contactfullname 
UPDATE SALES_DATASET_RFM_PRJ
SET 
    CONTACTFIRSTNAME = INITCAP(TRIM(SPLIT_PART(contactfullname, '-', 1))),
    CONTACTLASTNAME = INITCAP(TRIM(SPLIT_PART(contactfullname, '-', 2)));

--4/ Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 

-- Thêm cột QTR_ID (quý), MONTH_ID (tháng), YEAR_ID (năm)
ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN QTR_ID INTEGER;

ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN MONTH_ID INTEGER;

ALTER TABLE SALES_DATASET_RFM_PRJ
ADD COLUMN YEAR_ID INTEGER;

-- Thêm dữ liệu
UPDATE SALES_DATASET_RFM_PRJ
SET 
    QTR_ID = EXTRACT(QUARTER FROM ORDERDATE), --Hàm QUARTER trả về quý (một số từ 1 đến 4) 
    MONTH_ID = EXTRACT(MONTH FROM ORDERDATE),
    YEAR_ID = EXTRACT(YEAR FROM ORDERDATE);


--6/ Lưu thành bảng mới SALES_DATASET_RFM_PRJ_CLEAN
CREATE TABLE SALES_DATASET_RFM_PRJ_CLEAN AS
SELECT * FROM SALES_DATASET_RFM_PRJ WHERE 1=0;

---------------------------------------------
SELECT * FROM SALES_DATASET_RFM_PRJ 
---------------------------------------------
--5/Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn cách xử lý cho bản ghi đó (2 cách) 

--Cách 1:

WITH twt_min_max_values as (
SELECT Q1-1.5*IQR as min_value, Q3+1.5*IQR as max_value
FROM (
SELECT
percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) as Q1,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) as Q3,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered)  - percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered)  as IQR
FROM SALES_DATASET_RFM_PRJ ) as a )


SELECT *
FROM SALES_DATASET_RFM_PRJ
where 		quantityordered < (select min_value from twt_min_max_values ) 
		or  quantityordered > (select max_value from twt_min_max_values)
		
--Cách 2: sử dụng z-core = (users - avg)/ stddev (độ lệch chuẩn)

WITH cte AS (
    SELECT 
        orderdate,
        quantityordered,
        (SELECT AVG(quantityordered) FROM SALES_DATASET_RFM_PRJ) AS avg_quantity,
        (SELECT STDDEV(quantityordered) FROM SALES_DATASET_RFM_PRJ) AS stddev_quantity
    FROM SALES_DATASET_RFM_PRJ
),
twt_outlier AS (
    SELECT 
        orderdate,
        quantityordered,
        (quantityordered - avg_quantity) / stddev_quantity AS z_score
    FROM cte
)
SELECT *
FROM twt_outlier;

---DELETE 
DELETE FROM SALES_DATASET_RFM_PRJ
WHERE quantityordered IN (SELECT quantityordered FROM twt_outlier )

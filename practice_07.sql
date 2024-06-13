--1. https://datalemur.com/questions/yoy-growth-rate
WITH cte AS (
SELECT EXTRACT(year from transaction_date) AS year,
  product_id,spend AS curr_year_spend,
  lag(spend) OVER(PARTITION BY product_id ORDER BY transaction_date) AS prev_year_spend
FROM user_transactions)

SELECT *,
ROUND(100.0*(curr_year_spend-prev_year_spend)/prev_year_spend,2) AS yoy_rate
FROM cte;

--2. https://datalemur.com/questions/card-launch-success
SELECT DISTINCT card_name, 
  FIRST_VALUE(issued_amount) OVER (PARTITION BY card_name ORDER BY make_date(issue_year,issue_month,'01')) as amount
FROM monthly_cards_issued
ORDER BY amount DESC;

--3. https://datalemur.com/questions/sql-third-transaction
WITH cte AS (
  SELECT 
  user_id, 
  spend, 
  transaction_date,
  ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date) AS row
FROM transactions)

SELECT user_id,spend, transaction_date
FROM cte
WHERE row = 3;

--4. https://datalemur.com/questions/histogram-users-purchases
WITH cte_rank AS 
  ( SELECT user_id,transaction_date,
    DENSE_RANK() OVER(PARTITION BY user_id ORDER BY transaction_date DESC) as number_rank
    FROM user_transactions)

SELECT 
  MAX(transaction_date) AS transaction_date, 
  user_id, 
  SUM(number_rank) AS purchase_count
FROM cte_rank
WHERE number_rank = 1
GROUP BY user_id
ORDER BY transaction_date

--5. https://datalemur.com/questions/rolling-average-tweets
WITH cte AS 
(
  (SELECT user_id, tweet_date, tweet_count AS base
  FROM tweets)
UNION ALL
  (SELECT user_id, tweet_date, 
    LAG(tweet_count) OVER (PARTITION BY user_id ORDER BY tweet_date) 
  FROM tweets)
UNION ALL
  (SELECT user_id, tweet_date,
    LAG(tweet_count,2) OVER (PARTITION BY user_id ORDER BY tweet_date) 
  FROM tweets)
)
SELECT user_id, tweet_date, ROUND(AVG(base),2) AS rolling_avg_3d
FROM cte
GROUP BY user_id, tweet_date
ORDER BY user_id, tweet_date

--6. https://datalemur.com/questions/repeated-payments
SELECT COUNT(*) AS payment_count
FROM ( 
  SELECT merchant_id, credit_card_id, amount, 
  transaction_timestamp - LAG(transaction_timestamp,1) OVER (PARTITION BY merchant_id,
  credit_card_id, amount ORDER BY transaction_timestamp) as next_trans
  FROM TRANSACTIONS
  ORDER BY merchant_id, credit_card_id, amount
) AS a
WHERE EXTRACT(MINUTE FROM next_trans) < 10

--7. https://datalemur.com/questions/sql-highest-grossing
WITH cte_rank AS (
  SELECT 
    category, 
    product, 
    SUM(spend) as total_spend,
    DENSE_RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) as rank
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
)
SELECT 
  category,
  product,
  total_spend
FROM cte_rank
WHERE rank <=2
ORDER BY category, rank;

--8. https://datalemur.com/questions/top-fans-rank
SELECT rank_number.artist_name, rank_number.ranking as artist_rank
FROM (
  SELECT a.artist_name,
  DENSE_RANK() OVER(ORDER BY COUNT(a.artist_name) DESC) ranking
  FROM artists a
  JOIN songs b on a.artist_id = b.artist_id
  JOIN global_song_rank c on c.song_id = b.song_id and rank <= 10
  GROUP BY a.artist_name
) rank_number
WHERE rank_number.ranking <= 5 

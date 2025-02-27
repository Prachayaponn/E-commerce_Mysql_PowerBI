USE ecommerce;

-- @General Dataset Insights
-- What is the total number of transactions in the dataset?
SELECT count(Transaction_ID) AS total_transaction
FROM synthetic_ecommerce_data
;
-- How many unique customers and unique products exist?
SELECT COUNT(DISTINCT Customer_id)
,COUNT(DISTINCT Product_ID)
FROM synthetic_ecommerce_data
;
-- What is the time range of the dataset? (Earliest & latest order dates)
SELECT MIN(Transaction_Date)
,MAX(Transaction_Date)
FROM synthetic_ecommerce_data
;
-- @Sales & Revenue Analysis
-- What is the total revenue and order count over time (daily, weekly, monthly)?


-- What are the top-selling products based on quantity sold?
SELECT Product_ID
,SUM(Units_Sold) AS total_unit
FROM synthetic_ecommerce_data
GROUP BY Product_ID
ORDER BY 2 DESC
LIMIT 10
;
-- What products generate the most revenue?
SELECT Product_id
,ROUND(SUM(Revenue),2) AS total_revenue
FROM synthetic_ecommerce_data
GROUP BY Product_id
ORDER BY 2 DESC
;
-- What is the revenue contribution of repeat vs. new customers?
with repea AS (
SELECT Customer_ID
,SUM(Revenue) as total
,CASE WHEN count(*) > 1 THEN 'Repeat' else 'new' END as repeatcus
FROM synthetic_ecommerce_data
GROUP BY 1
)
SELECT repeatcus,ROUND(SUM(total),2)
FROM repea
GROUP BY repeatcus
ORDER BY repeatcus DESC
;

-- @Customer Behavior Analysis
-- What is the distribution of order frequency per customer?
SELECT Customer_id
,count(*)
FROM synthetic_ecommerce_data
GROUP BY Customer_ID
ORDER BY 2 DESC
;
-- Who are the top 10% highest-spending customers?
WITH ranked_customers AS (
SELECT customer_id, SUM(revenue) AS total_spent
,NTILE(10) OVER (ORDER BY SUM(revenue) DESC) AS percentile_rank
FROM synthetic_ecommerce_data
GROUP BY customer_id
  
 )
 SELECT customer_id, total_spent FROM ranked_customers WHERE percentile_rank = 1
 ;
-- What percentage of customers only purchase once?
with c AS (
SELECT Customer_ID,CASE WHEN count(*) > 1 THEN 0 ELSE 1 END AS once
FROM synthetic_ecommerce_data
GROUP BY Customer_ID
)
SELECT count(*)/(SELECT COUNT(DISTINCT Customer_ID) FROM synthetic_ecommerce_data)*100 AS percent_once
FROM c
WHERE once = 1
;

-- What is the average time gap between repeat purchases for customers?
with lagdate AS (
SELECT Customer_ID,Transaction_Date,LAG(Transaction_Date) OVER (PARTITION BY Customer_ID ORDER BY Transaction_Date) AS lag_date 
FROM synthetic_ecommerce_data
)
SELECT AVG(datediff(Transaction_Date,lag_date))
FROM lagdate
;

-- @Product & Inventory Analysis
-- What are the top-performing product categories?
with top AS (
SELECT SUM(Revenue) AS totalrev ,Product_ID,Category,row_number() OVER(PARTITION BY Category ORDER BY SUM(Revenue) DESC) as toprow
FROM synthetic_ecommerce_data
GROUP BY Product_id,Category
)
SELECT Product_ID,Category,ROUND(totalrev,2)
FROM top
WHERE toprow = 1
;

-- @Geographical Insights (if location data exists)
-- Which regions generate the highest revenue?
SELECT Region,ROUND(SUM(Revenue),2)
FROM synthetic_ecommerce_data
GROUP BY Region
ORDER BY 2 DESC
;
-- What are the most popular products per region?
with pop AS (
SELECT Region,Product_ID,ROUND(SUM(Revenue),2) as total_rev ,row_number() OVER(partition by Region ORDER BY ROUND(SUM(Revenue),2) DESC) as rank_pop
FROM synthetic_ecommerce_data
GROUP BY Region,Product_ID
ORDER BY 3 DESC
)
SELECT Region,Product_ID,total_rev
FROM pop
WHERE rank_pop = 1
;
-- Advanced SQL Case Study Questions
-- Monthly revenue & transaction count
SELECT EXTRACT(MONTH FROM Transaction_Date) ,ROUND(SUM(Revenue),2),COUNT(Transaction_ID)
FROM synthetic_ecommerce_data
GROUP BY 1
ORDER BY 1
;
--  Identify top 5% customers by revenue
WITH ranked AS (
SELECT customer_id, SUM(revenue) AS total_spent
,NTILE(5) OVER (ORDER BY SUM(revenue) DESC) AS percentile_rank
FROM synthetic_ecommerce_data
GROUP BY customer_id
  
 )
 SELECT customer_id, ROUND(total_spent,2) 
 FROM ranked 
 WHERE percentile_rank = 1
 ORDER BY 2 DESC
 ;

-- Most common order value (mode)
SELECT ROUND(Revenue,2),COUNT(*) as frequncy
FROM synthetic_ecommerce_data
GROUP BY Revenue
HAVING COUNT(*) >1
ORDER BY 2 DESC
LIMIT 1
;
-- Rank customers by lifetime value
SELECT Customer_ID
,SUM(Revenue)
,row_number() OVER(ORDER BY SUM(Revenue) DESC)  AS rank_life
FROM synthetic_ecommerce_data
GROUP BY Customer_ID
;
-- Month-over-month revenue growth
WITH monthcte AS (
SELECT extract(month from Transaction_Date) as mon ,ROUND(SUM(Revenue),2) as totalrev
FROM synthetic_ecommerce_data
GROUP BY 1
)
SELECT mon,totalrev,(totalrev - lag(totalrev) OVER(ORDER BY mon))/lag(totalrev) OVER(ORDER BY mon) as lag_month
FROM monthcte
;
-- Customer segmentation into spend tiers
WITH seg AS(
SELECT Customer_ID,ROUND(SUM(Revenue),2) AS total_rev
FROM synthetic_ecommerce_data
GROUP BY Customer_ID
)
SELECT Customer_ID
,CASE WHEN total_rev >= 1000 THEN 'hight'
WHEN total_rev between 500 and 999 THEN 'Medium'
ELSE 'Low' END AS tier
FROM seg
;






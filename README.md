# Ecommerce Data Analysis - SQL & Power BI

## Project Overview
This project analyzes an **ecommerce dataset** using **SQL & Power BI** to gain **business insights** into customer behavior, sales performance, and discount impact. The goal is to **optimize pricing strategies, improve customer retention, and identify top-selling products**.

## Key Objectives
- Identify top-selling products, seasonal trends, and peak sales months.
- Evaluate average order value (AOV) and monthly revenue trends.
- Understand customer spending behavior and categorize them into segments.
- Analyze repeat customer trends and identify strategies to increase retention.
- Measure how discounts impact revenue, order volume, and profitability.
- Identify the optimal discount percentage that maximizes profit.
- Analyze regional sales performance to optimize marketing strategies.
- Identify the most profitable regions & products per region.

## Dataset Overview
- Columns
  - Transaction_ID	Unique identifier for each transaction
  - Transaction_Date	Date of purchase
  - Customer_ID	Unique customer identifier
  - Product_ID	Unique identifier for each product
  - Category	Product category (e.g., Electronics, Clothing)
  - Units_Sold	Number of units sold
  - Revenue	Total revenue from the transaction
  - Discount_Applied	Discount percentage applied to the order
  - Clicks	Number of ad clicks before purchase
  - Impressions	Number of times the ad was shown
  - Conversion_Rate	Percentage of users who made a purchase after clicking
  - Ad_Spend	Marketing cost associated with the transaction
  - Region	Geographic region where the purchase was made
  
## Key Insights & Findings from Ecommerce Analysis
- Highest Revenue Month: $4.83M (Month X had the highest sales volume).Consistent growth in revenue over the months, indicating a strong sales trend.
- Product 215 had the highest units sold (18.8K), but Product 108 generated the most revenue.Electronics, Books, and Toys are the top-performing product categories.
- Repeat customers drive the majority of revenue (99.35%).The average time between purchases is 55.71 days, meaning customers buy approximately every 2 months.
- The number of repeat customers has been increasing monthly, indicating strong retention.The repeat purchase cycle is ~55 days, meaning retention campaigns should target customers after ~2 months.
- 1% discount maximized revenue, while higher discounts mainly increased sales volume but not overall profit.Customers respond well to small discounts (1-4%) rather than large discounts.
- Sales are evenly distributed across regions, meaning marketing efforts should be balanced globally.Top-Selling Product in Each Region: Product 150.

## Some interesting queries

Average time between purchase
```
WITH purchase_gaps AS (
    SELECT customer_id, transaction_date,
           LAG(transaction_date) OVER(PARTITION BY customer_id ORDER BY transaction_date) AS prev_purchase
    FROM synthetic_ecommerce_data
)
SELECT ROUND(AVG(DATEDIFF(transaction_date, prev_purchase)), 2) AS avg_days_between_purchases
FROM purchase_gaps
WHERE prev_purchase IS NOT NULL;
```
The revenue contribution of repeat vs. new customers
```
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
```
Customer segmentation/total revenue into spend tiers
```
WITH customer_spend AS (
    SELECT customer_id, ROUND(SUM(revenue), 2) AS total_spent
    FROM synthetic_ecommerce_data 
    GROUP BY customer_id
 )
 SELECT customer_id,
       total_spent,
       CASE 
           WHEN total_spent >= 5000 THEN 'High' 
           WHEN total_spent BETWEEN 3000 AND 4999 THEN 'Upper intermedite'
           WHEN total_spent BETWEEN 1000 AND 2999 THEN 'Lowwer intermediate' 
           ELSE 'Low' 
       END AS spend_tier

FROM customer_spend
;
```
Customer Purchase Frequency Distribution
```
SELECT order_count, COUNT(*) AS customer_count 
FROM (
    SELECT customer_id, COUNT(*) AS order_count 
    FROM synthetic_ecommerce_data 
    GROUP BY customer_id
) AS order_frequency
GROUP BY order_count 
ORDER BY order_count;
```

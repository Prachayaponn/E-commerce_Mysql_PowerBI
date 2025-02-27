USE ecommerce;

SELECT *
FROM synthetic_ecommerce_data
LIMIT 10
;

-- TO DO LIST
-- 1.remove duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any column or row

-- 1.remove duplicates
-- NO null data in every column
SELECT *
FROM synthetic_ecommerce_data
WHERE Ad_Spend IS NULL
;

-- check duplicate
-- no duplicate in Transaction_ID
with dup AS (
SELECT *,ROW_NUMBER() OVER(PARTITION BY Transaction_ID ORDER BY Transaction_Date) as row_num
FROM synthetic_ecommerce_data
)
SELECT *
FROM dup
WHERE row_num >1
;
-- check duplicate,  sometimes transactions get recorded twice but have different Transaction_ID
-- no duplicate 
WITH dup1 AS (
    SELECT *, 
           ROW_NUMBER() OVER(PARTITION BY Customer_ID, Product_ID, Transaction_Date ORDER BY Revenue DESC) AS row_num
    FROM synthetic_ecommerce_data
)
SELECT *
FROM dup1
WHERE row_num > 1;


-- 2. Standardize the Data
-- change Transaction_Date data type
ALTER TABLE synthetic_ecommerce_data
MODIFY COLUMN Transaction_Date DATE 
;

-- check outliner data
-- has 0 clik
-- has 0 Conversion_Rate
SELECT MAX(Discount_Applied),MIN(Discount_Applied)
FROM synthetic_ecommerce_data
;
SELECT MAX(Revenue) ,MIN(Revenue)
FROM synthetic_ecommerce_data
;
SELECT MAX(Units_Sold),MIN(Units_Sold)
FROM synthetic_ecommerce_data
;
SELECT MAX(Clicks),MIN(Clicks)
FROM synthetic_ecommerce_data
;
SELECT MAX(Impressions),MIN(Impressions)
FROM synthetic_ecommerce_data
;
SELECT MAX(Conversion_Rate),MIN(Conversion_Rate)
FROM synthetic_ecommerce_data
;
SELECT MAX(Ad_CTR),MIN(Ad_CTR)
FROM synthetic_ecommerce_data
;
SELECT MAX(Ad_CPC),MIN(Ad_CPC)
FROM synthetic_ecommerce_data
;
SELECT MAX(Ad_Spend),MIN(Ad_Spend)
FROM synthetic_ecommerce_data
;
-- has a wrong information, 0  conversion_rate but cliks != 0  
SELECT *
FROM synthetic_ecommerce_data
WHERE Conversion_Rate = 0
;

UPDATE synthetic_ecommerce_data
SET Conversion_Rate = ROUND(Clicks/ NULLIF(Impressions, 0), 4)
WHERE Conversion_Rate IS NULL OR Conversion_Rate = 0
;

-- after checking ther are no null no duplicate no number error alreadychange data type 

-- Project Name : Analyse Promotions and Provide Tangible Insights to Sales Director

-- Project Domain: FMCG , Function: Sales / Promotions

USE retail_events_db;

-- Adding new columns to the fact_events table to avoid repetation of query 
ALTER TABLE fact_events
ADD COLUMN revenue_before_promo INT;

UPDATE fact_events
SET revenue_before_promo=base_price*quantity_sold_before_promo;

ALTER TABLE fact_events
ADD COLUMN revenue_after_promo INT;

UPDATE fact_events
SET revenue_after_promo = 
	   CASE WHEN promo_type="25% OFF" THEN base_price*quantity_sold_after_promo*0.75
            WHEN promo_type="33% OFF" THEN base_price*quantity_sold_after_promo*0.67
            WHEN promo_type="50% OFF" THEN base_price*quantity_sold_after_promo*0.5
            WHEN promo_type="500 Cashback" THEN (base_price-500)*quantity_sold_after_promo
            WHEN promo_type="BOGOF" THEN base_price*quantity_sold_after_promo*2*0.5
	   END;
       
ALTER TABLE fact_events
ADD COLUMN incremental_revenue INT;

UPDATE fact_events
SET incremental_revenue = revenue_after_promo - revenue_before_promo;

ALTER TABLE fact_events
ADD COLUMN incremental_sold_units INT;

UPDATE fact_events
SET incremental_sold_units = quantity_sold_after_promo - quantity_sold_before_promo;

-- --------------------------------------- Ad-Hoc Requests ------------------------------------

-- Q.1)Provide alist of products with a base price greater than 500 and that are featured
-- in promo type of 'BOGOF' (Buy One Get One Free). This information will help us
-- identify high-value products that are currently being heavily discounted, which
-- can be useful for evaluating our pricing and promotion strategies.

SELECT product_name,base_price,SUM(base_price) AS Total_Sales
FROM fact_events 
JOIN dim_products USING(product_code)
WHERE promo_type = "BOGOF" AND base_price>500
GROUP BY product_name,base_price;

-- Q.2)Generate a report that provides an overview of the number of stores in each city.
-- The results will be sorted in descending order of store counts, allowing us to
-- identify the cities with the highest store presence.The report includes two
-- essential fields: city and store count, which will assist in optimizing our retail
-- operations.
SELECT city,
	   COUNT(DISTINCT store_id) number_of_stores
FROM dim_stores
GROUP BY city
ORDER BY number_of_stores DESC;

-- Q.3)Generate a report that displays each campaign along with the total revenue
-- generated before and after the campaign? The report includes three key fields:
-- campaign_name, total_revenue(before_promotion),
-- total_revenue(after_promotion). This report should help in evaluating the financial
-- impact of our promotional campaigns. (Display the values in millions)
SELECT campaign_name , 
	   CONCAT(ROUND(SUM(revenue_before_promo)/1000000,2)," M") total_revenue_before_promo,
       CONCAT(ROUND(SUM(revenue_after_promo)/1000000,2)," M") total_revenue_after_promo
FROM fact_events
JOIN dim_campaigns USING(campaign_id)
GROUP BY campaign_name;

-- Q.4)Produce a report that calculates the Incremental Sold Quantity (ISU%) for each
-- category during the Diwali campaign. Additionally, provide rankings for the
-- categories based on their ISU%. The report will include three key fields:
-- category, isu%, and rank order. This information will assist in assessing the
-- category-wise success and impact of the Diwali campaign on incremental sales.
WITH CTE AS(
SELECT category, 
       ROUND(SUM(incremental_sold_units)*100/SUM(quantity_sold_before_promo),2) AS ISU_pct
FROM fact_events 
JOIN dim_campaigns USING(campaign_id)
JOIN dim_products USING(product_code)
WHERE campaign_name="Diwali"
GROUP BY category)
SELECT *, RANK() OVER(ORDER BY ISU_pct DESC) AS rnk
FROM CTE;

-- Q.5)Create a report featuring the Top 5 products, ranked by Incremental Revenue
-- Percentage (IR%), across all campaigns. The report will provide essential
-- information including product name, category, and ir%. This analysis helps
-- identify the most successful products in terms of incremental revenue across our
-- campaigns, assisting in product optimization
WITH CTE AS(
SELECT product_name,category,
       SUM(incremental_revenue) AS incremental_revenue,
       SUM(revenue_before_promo) AS total_revenue_before_promo
FROM fact_events
JOIN dim_products USING(product_code)
GROUP BY product_name,category),CTE2 AS (
SELECT product_name,category,
	   ROUND(incremental_revenue*100/total_revenue_before_promo,2) AS IR_pct
FROM CTE)
SELECT *
FROM CTE2
ORDER BY IR_pct DESC 
LIMIT 5;

-- Q.6)Which are the top 10 stores in terms of Incremental Revenue (IR) generated from the promotions?
SELECT s.store_id,city,
	   CONCAT(ROUND(SUM(incremental_revenue)/1000000,2)," M") AS incremental_revenue
FROM fact_events
JOIN dim_stores s USING(store_id)
GROUP BY s.store_id,city
ORDER BY incremental_revenue DESC
LIMIT 10;

-- Q.7)Which are the bottom 10 stores when it comes to Incremental Sold Units (ISU) 
-- during the promotional period?
SELECT s.store_id,city,
       SUM(incremental_sold_units) AS incremental_sold_units
FROM fact_events 
JOIN dim_stores s USING(store_id)
GROUP BY s.store_id,city
ORDER BY incremental_sold_units ASC
LIMIT 10;

-- Q.8)How does the performance of stores vary by city? Are there any common
-- characteristics among the top-performing stores that could be leveraged across
-- other stores?
SELECT s.store_id,city,
       SUM(incremental_sold_units) AS incremental_sold_units,
       CONCAT(ROUND(SUM(incremental_revenue)/1000000,2)," M") AS incremental_revenue
FROM fact_events 
JOIN dim_stores s USING(store_id)
GROUP BY s.store_id,city
ORDER BY incremental_sold_units DESC;

-- Top perfoming stores are present in cities like Mysuru, Banglore,Chennai,Hyderabad
-- have sold more units and hence the revenue is maximum whereas other stores in cities like 
-- Mangalore, Visakhapatnam,Trivandrum,Vijayawada,Coimbatore have sold less units which is 
-- affecting the reveneue generated.

-- Q.9)What are the top 2 promotion types that resulted in the highest Incremental Revenue?
SELECT promo_type, 
       CONCAT(ROUND(SUM(incremental_revenue)/1000000,2)," M") AS incremental_revenue
FROM fact_events
GROUP BY promo_type
ORDER BY incremental_revenue DESC
LIMIT 2;

-- Q.10)What are the bottom 2 promotion types in terms of their impact on Incremental Sold Units?
SELECT promo_type, 
       SUM(incremental_sold_units) AS incremental_sold_units
FROM fact_events
GROUP BY promo_type
ORDER BY incremental_sold_units ASC
LIMIT 2;

-- Q.11)Is there a significant difference in the performance of discount-based promotions
-- versus BOGOF (Buy One Get One Free) or cashback promotions?
SELECT promo_type, 
       SUM(incremental_sold_units) AS incremental_sold_units,
       CONCAT(ROUND(SUM(incremental_revenue)/1000000,2)," M") AS incremental_revenue
FROM fact_events
GROUP BY promo_type
ORDER BY incremental_sold_units DESC;

-- BOGOF and Cashback promo types are having more quantities sold and hence generating more revenue 
-- as compared to discount based promo types.

-- Q.12)Which promotions strike the best balance between Incremental Sold Units and
-- maintaining healthy margins?
SELECT promo_type, 
       SUM(incremental_sold_units) AS incremental_sold_units,
       CONCAT(ROUND(SUM(incremental_revenue)/1000000,2)," M") AS incremental_revenue
FROM fact_events
GROUP BY promo_type
ORDER BY incremental_sold_units DESC;

-- BOGOF and Cashback promo types are 2 promotion types have best balance between 
-- incremental sold units and maintaining healthy margins.

-- Q.13)Which product categories saw the most significant lift in sales from the promotions?
WITH CTE AS(
SELECT category,
       ROUND(SUM(revenue_before_promo)/1000000,2) as total_revenue_before_promo, 
       ROUND(SUM(revenue_after_promo)/1000000,2) as total_revenue_after_promo
FROM fact_events
JOIN dim_products USING(product_code)
GROUP BY category) 
SELECT *,
       ROUND((total_revenue_after_promo -total_revenue_before_promo)*100/total_revenue_before_promo,2) AS IR_pct
FROM CTE
ORDER BY IR_pct DESC;

-- Home Appliances , Home Care and Combo1 Categories shown significant lift in sales from the promotions.

-- Q.14)Are there specific products that respond exceptionally well or poorly to promotions?
SELECT product_name,
       SUM(incremental_sold_units) AS incremental_sold_units,
       CONCAT(ROUND(SUM(incremental_revenue)/1000000,2)," M") AS incremental_revenue
FROM fact_events
JOIN dim_products USING(product_code)
GROUP BY product_name
ORDER BY incremental_revenue DESC;

-- Q.15)What is the correlation between product category and promotion type effectiveness?
SELECT category,promo_type,
       CONCAT(ROUND(SUM(incremental_revenue)/1000000,2)," M") AS incremental_revenue
FROM fact_events
JOIN dim_products USING(product_code)
GROUP BY category,promo_type;

-- Product categories with promo type of either 500 Cashback or BOGOF are generating maximum revenue 
-- as compared to product categories with discount based promotions.
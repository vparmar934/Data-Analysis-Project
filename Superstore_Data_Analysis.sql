/* 1) What is the profit margin percentage for each category and subcategory? 
Please provide the results in descending order based on margin percentage. 
Ensure the margin is expressed in percentage form. */

SELECT p.category,p.sub_category, ROUND(SUM(o.sales)::numeric,2) AS sales, 
ROUND(SUM(o.profit)::numeric,2) AS profit, 
CONCAT(ROUND(SUM(o.profit)::numeric*100/SUM(o.sales)::numeric,0),'%') as margin
FROM superstore.products p
JOIN superstore.orders o
ON o.product_id = p.product_id
GROUP BY category,sub_category
ORDER BY ROUND(SUM(o.profit)::numeric*100/SUM(o.sales)::numeric,0) DESC;


-- 2) What is the total sales amount for the Superstore?

SELECT CONCAT('$',ROUND(SUM(sales)::numeric,2)) as total_sales
FROM superstore.orders;


-- 3) Which product category has the highest sales?

WITH rnks AS
(SELECT p.category,ROUND(SUM(o.sales)::numeric,2) as total_sales,
DENSE_RANK() OVER (ORDER BY SUM(o.sales) DESC) AS rnk
FROM superstore.products p
JOIN superstore.orders o
ON p.product_id = o.product_id
GROUP BY category)
SELECT category FROM rnks
WHERE rnk = 1;


-- 4) Can you provide a breakdown of sales by product subcategory?

SELECT p.sub_category, CONCAT('$',ROUND(SUM(o.sales)::numeric,2)) AS total_sales
FROM superstore.products p
JOIN superstore.orders o
ON p.product_id = o.product_id
GROUP BY sub_category
ORDER BY SUM(o.sales) DESC;


-- 5) What is the average sales amount per order in the Superstore?

SELECT CONCAT('$',ROUND(AVG(sales)::numeric,0)) as avg_sales
FROM superstore.orders;


-- 6) Identify the top 5 products with the highest sales.

SELECT p.product_name, CONCAT('$',ROUND(SUM(o.sales)::numeric,2)) as total_sales
FROM superstore.products p
JOIN superstore.orders o
ON p.product_id = o.product_id
GROUP BY product_name
ORDER BY SUM(o.sales) DESC
LIMIT 5;


-- 7) How do the sales numbers vary across different regions?

SELECT c.region, CONCAT('$',ROUND(SUM(o.sales)::numeric,2)) AS total_sales,
CONCAT(ROUND(SUM(o.sales)::numeric*100/SUM(SUM(o.sales)::numeric) OVER(),0),'%') AS sales_per
FROM superstore.customers c
JOIN superstore.orders o
ON c.customer_id = o.customer_id
GROUP BY region
ORDER BY SUM(o.sales) DESC;


-- 8) What is the trend in sales over the past quarter?

SELECT TO_CHAR(DATE_TRUNC('quarter', order_date::DATE),'"Q"Q-YYYY') AS quarter_start,
CONCAT('$',ROUND(SUM(sales)::numeric,2)) AS total_sales
FROM superstore.orders
WHERE order_date >= CURRENT_DATE - INTERVAL '46 months'
GROUP BY DATE_TRUNC('quarter', order_date)
ORDER BY DATE_TRUNC('quarter', order_date);

-- 9) Can you compare sales performance between different customer segments?

SELECT c.segment, CONCAT('$',ROUND(SUM(o.sales)::numeric,2)) as total_sales,
CONCAT(ROUND(SUM(o.sales)::numeric*100/SUM(SUM(o.sales)::numeric) OVER(),0),'%') as sales_per
FROM superstore.customers c
JOIN superstore.orders o
ON c.customer_id = o.customer_id
GROUP BY segment
ORDER BY SUM(o.sales) DESC;

-- 10) What is the total sales in each year?

SELECT EXTRACT(YEAR FROM order_date) AS order_year,
CONCAT('$',ROUND(SUM(sales)::numeric,2)) AS total_sales
FROM superstore.orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY EXTRACT(YEAR FROM order_date);
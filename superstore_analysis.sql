use superstore_db;
show tables;
SELECT ROUND(SUM(sales),2)  AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       COUNT(DISTINCT order_id)    AS total_orders,
       COUNT(DISTINCT customer_id) AS customers
FROM superstore_db.orders;
-- Q2. Sales, profit and margin by category
SELECT category,
       ROUND(SUM(sales),2)  AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin_pct
FROM superstore_db.orders
GROUP BY category
ORDER BY profit DESC;
-- Q3. Sales, profit and margin by region
SELECT region,
       ROUND(SUM(sales),2)  AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin_pct
FROM superstore_db.orders
GROUP BY region
ORDER BY profit DESC;
-- Q4. Sub-categories that lose money
SELECT sub_category,
       ROUND(SUM(sales),2)  AS sales,
       ROUND(SUM(profit),2) AS profit
FROM superstore_db.orders
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY profit;
Q5. Does a bigger discount hurt profit?
SELECT CASE WHEN discount = 0    THEN '1. No discount'
            WHEN discount <= 0.2 THEN '2. Low (up to 20%)'
            WHEN discount <= 0.4 THEN '3. Medium (20-40%)'
            ELSE                      '4. High (above 40%)'
       END AS discount_band,
       COUNT(*) AS rows_count,
       ROUND(AVG(profit),2) AS avg_profit
FROM superstore_db.orders
GROUP BY discount_band
ORDER BY discount_band;
-- Q6. Average discount by sub-category (highest first)
SELECT sub_category,
       ROUND(AVG(discount)*100,1) AS avg_discount_pct,
       ROUND(SUM(profit),2)       AS total_profit
FROM superstore_db.orders
GROUP BY sub_category
ORDER BY avg_discount_pct DESC;
- Q7. Sales, profit and orders for each year
SELECT YEAR(order_date) AS yr,
       ROUND(SUM(sales),2)  AS sales,
       ROUND(SUM(profit),2) AS profit,
       COUNT(DISTINCT order_id) AS orders
FROM superstore_db.orders
GROUP BY YEAR(order_date)
ORDER BY yr;
-- Q8. Year-over-year sales growth
WITH yearly AS (
    SELECT YEAR(order_date) AS yr, SUM(sales) AS sales
    FROM superstore_db.orders
    GROUP BY YEAR(order_date)
)
SELECT yr,
       ROUND(sales,2) AS sales,
       ROUND(LAG(sales) OVER (ORDER BY yr),2) AS last_year_sales,
       ROUND((sales - LAG(sales) OVER (ORDER BY yr))
             / LAG(sales) OVER (ORDER BY yr) * 100, 2) AS growth_pct
FROM yearly
ORDER BY yr;
-- Q9. Which months sell the most? (all years combined)
SELECT MONTH(order_date) AS month_no,
       MONTHNAME(order_date) AS month_name,
       ROUND(SUM(sales),2) AS sales
FROM superstore_db.orders
GROUP BY MONTH(order_date), MONTHNAME(order_date)
ORDER BY month_no;
-- Q10. Top 3 products by profit in each category
WITH product_profit AS (
    SELECT category,
           product_name,
           ROUND(SUM(profit),2) AS profit,
           RANK() OVER (PARTITION BY category
                        ORDER BY SUM(profit) DESC) AS rnk
    FROM superstore_db.orders
    GROUP BY category, product_name
)
SELECT category, rnk, product_name, profit
FROM product_profit
WHERE rnk <= 3
ORDER BY category, rnk;
-- Q11a. Recency, Frequency, Monetary for each customer
SELECT customer_id,
       customer_name,
       DATEDIFF((SELECT MAX(order_date) FROM superstore_db.orders),
                MAX(order_date))       AS recency_days,
       COUNT(DISTINCT order_id)        AS frequency,
       ROUND(SUM(sales),2)             AS monetary
FROM superstore_db.orders
GROUP BY customer_id, customer_name
ORDER BY monetary DESC
LIMIT 10;
-- Q11b. RFM scores and customer segments
WITH rfm AS (
    SELECT customer_id,
           customer_name,
           DATEDIFF((SELECT MAX(order_date) FROM superstore_db.orders),
                    MAX(order_date)) AS recency_days,
           COUNT(DISTINCT order_id)  AS frequency,
           SUM(sales)                AS monetary
    FROM superstore_db.orders
    GROUP BY customer_id, customer_name
),
scored AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
           NTILE(4) OVER (ORDER BY frequency ASC)     AS f_score,
           NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score
    FROM rfm
)
SELECT customer_name, recency_days, frequency,
       ROUND(monetary,2) AS monetary,
       r_score, f_score, m_score,
       CASE WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champion'
            WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
            WHEN f_score >= 3                                   THEN 'Loyal'
            WHEN r_score = 1                                    THEN 'Lost'
            ELSE 'Regular'
       END AS segment
FROM scored
ORDER BY monetary DESC;
-- Q11c. How many customers and how much money in each segment
WITH rfm AS (
    SELECT customer_id,
           DATEDIFF((SELECT MAX(order_date) FROM superstore_db.orders),
                    MAX(order_date)) AS recency_days,
           COUNT(DISTINCT order_id)  AS frequency,
           SUM(sales)                AS monetary
    FROM superstore_db.orders
    GROUP BY customer_id
),
scored AS (
    SELECT *,
           NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
           NTILE(4) OVER (ORDER BY frequency ASC)     AS f_score,
           NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score
    FROM rfm
),
labelled AS (
    SELECT *,
           CASE WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champion'
                WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
                WHEN f_score >= 3                                   THEN 'Loyal'
                WHEN r_score = 1                                    THEN 'Lost'
                ELSE 'Regular'
           END AS segment
    FROM scored
)
SELECT segment,
       COUNT(*)              AS customers,
       ROUND(SUM(monetary),2) AS total_spent
FROM labelled
GROUP BY segment
ORDER BY total_spent DESC;
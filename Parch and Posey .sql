-- 1. Which 5 sales representatives are bringing the highest sales volume?

SELECT s.name AS sales_reps_name, 
	SUM(o.total_amt_usd) AS total_sales 
FROM accounts a
JOIN sales_reps s ON s.id = a.sales_rep_id
JOIN orders o ON a.id = o.account_id
GROUP BY s.name
ORDER BY total_sales DESC
LIMIT 5;

-- 2. What is the average order value by region?

SELECT r.name AS region_name,
	 ROUND(AVG(o.total_amt_usd), 2) AS Average_order_value
FROM accounts a
JOIN orders o 
	ON a.id = o.account_id
JOIN region r 
	ON o.id = r.id
GROUP BY r.name
ORDER BY Average_order_value DESC;

--3. Retrive the number of times each customer used the company's channel

SELECT a.name AS account_name, 
		COUNT(DISTINCT w.channel)
FROM accounts a
JOIN web_events w
	ON a.id = w.account_id
GROUP BY a.name
ORDER BY a.name ASC
LIMIT 5;

--4. What is the Total amount of sales made yearly

SELECT DATE_PART('Year', occurred_at) AS Year,
	SUM(total_amt_usd) AS total_amt_usd
FROM orders 
GROUP BY Year
ORDER BY Year ASC;

--5. Find top 10 accounts that purchased orders greater than 2000 between September 2015 and 2016

SELECT a.name AS account_name, 
		o.occurred_at AS order_date,
		o.total AS total_order
FROM accounts a, orders o
WHERE a.id = o.account_id AND 
	  o.occurred_at BETWEEN '2015-09-01' AND '2016-09-30' 
GROUP BY a.name, o.occurred_at, o.total
HAVING o.total > 2000
ORDER BY o.total DESC
LIMIT 10; 

--6. Find the top 2 customers for each year and their corresponding number of orders

WITH CTE AS (
	SELECT a.name AS account_name, 
			SUM(o.total) AS total_orders, 
			DATE_PART('Year', o.occurred_at) AS Year,  
			RANK() OVER (PARTITION BY  DATE_PART('Year', occurred_at)
			ORDER BY SUM(o.total) DESC) AS rnk_num
	FROM orders o
	INNER JOIN accounts a 
	ON a.id = o.account_id
	GROUP BY o.account_id, DATE_PART('Year', o.occurred_at), a.name
	ORDER BY DATE_PART('Year', o.occurred_at), SUM(o.total) DESC
	)
SELECT account_name, total_orders, Year, rnk_num
FROM CTE
WHERE rnk_num IN (1,2);

-- 7. Give the names of the 5 highest paying customers?

SELECT a.name AS account_name, 
		SUM(o.total_amt_usd) AS total_amt_usd
FROM accounts a
JOIN orders o
	ON a.id = o.account_id
GROUP BY a.name
ORDER BY SUM(o.total_amt_usd) DESC
LIMIT 5;

-- 8. How frequently was each channel used to contact parch and posey?

SELECT w.channel, 
		COUNT(a.name) AS contact_frequency
FROM web_events w
JOIN accounts a
	ON w.account_id = a.id
GROUP BY w.channel
ORDER BY COUNT(a.name) DESC;

-- 9. Identify the highest 10 orders for standard paper in comparison to gloss and poster paper and 
-- the months when these orders were made in a single visit to the parch and posey company.
 
SELECT DATE_TRUNC('Month', occurred_at) AS time_period, 
		standard_qty,gloss_qty, poster_qty
FROM orders 
ORDER BY standard_qty DESC
LIMIT 10;

-- 10.Identify 5 companies that spent the most on poster paper orders in a single order and what was the corresponding 
-- amount spent on other papers. 

SELECT a.name AS company, SUM(o.poster_amt_usd) AS total_poster_amt_usd, 
		SUM(o.standard_amt_usd) AS total_standard_amt_usd,  
		SUM(o.gloss_amt_usd) AS total_gloss_amt_usd 
FROM accounts a
JOIN orders o
	ON a.id = o.account_id
GROUP BY a.name 
ORDER BY SUM(o.poster_amt_usd) DESC
LIMIT 5;

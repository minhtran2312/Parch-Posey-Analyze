/*
Parch & Possey Sales, Account Analysis 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, 

*/

--ACCOUNT 
SELECT *
FROM accounts

-- How many accounts does the company have?
SELECT COUNT(Distinct id)
FROM accounts


--Find the account name, primary_poc, and sales_rep_id for Walmart
SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart')

--What are the  channels used by account id 1001?
SELECT DISTINCT a.name, w.channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE a.id = '1001';

-- Total sales of each account
SELECT a.name, SUM(total_amt_usd) total_sales
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

-- What are the accounts that made the most sales and how many orders did they place?
SELECT TOP(5) a.name as Account_Name, SUM(o.total_amt_usd) AS Total_Sales, COUNT(*) AS Total_Orders
FROM orders o
JOIN accounts a ON a.id = o.account_id
GROUP BY a.name
ORDER BY 2 DESC

--Which account has the most orders?
SELECT top(1)a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC

--Who are the sales representatives associated with each account?
SELECT rep.name AS Sales_Rep_Name, acc.name as Account
FROM accounts acc
INNER JOIN sales_reps rep on rep.id = acc.sales_rep_id
ORDER BY acc.name ASC;

--ORDER
--Find the sales in terms of total dollars for all orders in each year
SELECT DATEPART(year, occurred_at) AS ord_year,  SUM(total_amt_usd) total_spent
FROM orders
GROUP BY ord_year
ORDER BY 2 DESC

--Which accounts have less than 5 orders?
SELECT a.name, COUNT(*) as Total_Orders
FROM accounts a
JOIN orders ord on a.id = ord.account_id
GROUP BY a.name
HAVING COUNT(*) < 5
ORDER BY Total_Orders DESC

--Region perform in terms of total sales
SELECT reg.name AS Region, SUM(ord.total_amt_usd) as Total
FROM orders ord
   JOIN accounts acc ON acc.id = ord.account_id
   JOIN sales_reps rep ON acc.sales_rep_id=rep.id
   JOIN region reg ON rep.region_id=reg.id
GROUP BY reg.name
ORDER BY Total DESC;

--Find all the orders that occurred in 2015
SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;

--Average quantity and usd of each type of paper
SELECT AVG(standard_qty) mean_standard, AVG(gloss_qty) mean_gloss, 
              AVG(poster_qty) mean_poster, AVG(standard_amt_usd) mean_standard_usd, 
              AVG(gloss_amt_usd) mean_gloss_usd, AVG(poster_amt_usd) mean_poster_usd
FROM orders;

--The smallest order placed by each account in terms of total usd
SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;

--Which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--The number of sales reps in each region
SELECT r.name, COUNT(*) num_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_reps;

--How many of the sales reps have more than 5 accounts that they manage
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

--Identify top performing sales reps
SELECT s.name, COUNT(*) num_ords,
        CASE WHEN COUNT(*) > 200 THEN 'top'
        ELSE 'not' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 2 DESC;

--CHANNEL
--Which account used facebook most as a channel
SELECT top(1) a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC

-- Which channel was most frequently used by most accounts?
SELECT TOP(5) a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC

--Name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH t1 AS (
     SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
      FROM sales_reps s
      JOIN accounts a
      ON a.sales_rep_id = s.id
      JOIN orders o
      ON o.account_id = a.id
      JOIN region r
      ON r.id = s.region_id
      GROUP BY 1,2
      ORDER BY 3 DESC), 
t2 AS (
      SELECT region_name, MAX(total_amt) total_amt
      FROM t1
      GROUP BY 1)
SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name


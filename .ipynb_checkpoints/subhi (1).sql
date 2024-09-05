show databases;
use project;
show tables;

-- This query calculates the average order value in USD for each customer by converting the total sales amount to USD using the exchange rate on the order date. --
SELECT s.CustomerKey, AVG(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS average_order_value_usd FROM sales s JOIN products p ON s.ProductKey = p.ProductKey 
JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode GROUP BY s.CustomerKey;


-- This query provides the frequency of purchases by each customer, showing the num of orders, 1st and last order dates, and an estimate of how often they place orders. --
SELECT c.CustomerKey, c.Name, COUNT(DISTINCT s.OrderNumber) AS total_orders, MIN(s.OrderDate) AS first_order_date, MAX(s.OrderDate) AS last_order_date,
    DATEDIFF(MAX(s.OrderDate), MIN(s.OrderDate)) AS days_between_first_and_last_order, 
    COUNT(DISTINCT s.OrderNumber) * 1.0 / (DATEDIFF(MAX(s.OrderDate), MIN(s.OrderDate)) + 1) AS orders_per_day
	FROM Customers c JOIN Sales s ON c.CustomerKey = s.CustomerKey GROUP BY c.CustomerKey, c.Name ORDER BY total_orders DESC;
    
    
-- This query calculates the age of each customer based on the difference between the current date (CURDATE()) and their birthday. --
SELECT CustomerKey, Gender, Name, City, StateCode, State, Country, Continent, Birthday, FLOOR(DATEDIFF(CURDATE(), Birthday) / 365) 
AS Age FROM Customers;

-- These queries provide insights into the distribution of customers across different city locations.
SELECT City, COUNT(*) AS customer_count, ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Customers), 2) 
AS percentage FROM Customers GROUP BY City ORDER BY customer_count DESC;

-- These queries provide insights into the distribution of customers across different country locations.
SELECT State, COUNT(*) AS customer_count, ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Customers), 2) 
AS percentage FROM Customers GROUP BY State ORDER BY customer_count DESC;

-- These queries provide insights into the distribution of customers across different country locations.
SELECT Country, COUNT(*) AS customer_count, ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Customers), 2) 
AS percentage FROM Customers GROUP BY Country ORDER BY customer_count DESC;

-- These queries provide insights into the distribution of customers across different Continent locations. --
SELECT Continent, COUNT(*) AS customer_count, ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Customers), 2) 
AS percentage FROM Customers GROUP BY Continent ORDER BY customer_count DESC;

-- This query counts the number of customers for each gender and calculates the percentage of total customers. --
SELECT Gender,COUNT(*) AS customer_count,ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Customers), 2) AS percentage FROM Customers GROUP BY Gender;


-- This query categorizes customers into predefined age groups and counts the number of customers in each group. --
SELECT CASE 
	WHEN Age < 18 THEN '0-17' WHEN Age BETWEEN 18 AND 25 THEN '18-25' 
    WHEN Age BETWEEN 26 AND 35 THEN '26-35' WHEN Age BETWEEN 36 AND 45 THEN '36-45'
	WHEN Age BETWEEN 46 AND 60 THEN '46-60' ELSE '60+' END AS age_group, COUNT(*) AS customer_count,  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Customers), 2) 
	AS percentage FROM (SELECT FLOOR(DATEDIFF(CURDATE(), Birthday) / 365) AS Age FROM Customers) AS AgeData GROUP BY age_group ORDER BY customer_count DESC;


-- This query will create a base table, CustomerMetrics, which contains demographic information and key purchasing metrics for each customer --
WITH CustomerMetrics AS (SELECT c.CustomerKey,c.Gender,FLOOR(DATEDIFF(CURDATE(), c.Birthday) / 365) AS Age, c.City, c.State, c.Country, c.Continent,
        COUNT(DISTINCT s.OrderNumber) AS total_orders,
        SUM(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS total_spend_usd,
        AVG(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS average_order_value_usd,
        MAX(s.OrderDate) AS last_order_date,
        MIN(s.OrderDate) AS first_order_date,
        DATEDIFF(MAX(s.OrderDate), MIN(s.OrderDate)) AS days_active,
        DATEDIFF(CURDATE(), MAX(s.OrderDate)) AS days_since_last_purchase
    FROM Customers c JOIN Sales s ON c.CustomerKey = s.CustomerKey JOIN Products p ON s.ProductKey = p.ProductKey JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode
    GROUP BY c.CustomerKey) SELECT * FROM CustomerMetrics ;
    
-- This query segments customers into high, mid, and low-value groups based on their total spend. --
SELECT CASE 
	WHEN total_spend_usd >= 10000 THEN 'High-Value Customers' 
	WHEN total_spend_usd BETWEEN 5000 AND 9999 THEN 'Mid-Value Customers' 
	ELSE 'Low-Value Customers'
END AS spend_segment, COUNT(*) AS customer_count, AVG(total_spend_usd) AS avg_spend_usd FROM CustomerMetrics GROUP BY spend_segment ORDER BY spend_segment DESC;


-- This query segments customers based on the frequency of their purchases. --
SELECT CASE 
	WHEN total_orders >= 20 THEN 'Frequent Buyers'
	WHEN total_orders BETWEEN 10 AND 19 THEN 'Moderate Buyers'
	ELSE 'Infrequent Buyers'
END AS frequency_segment, COUNT(*) AS customer_count, AVG(total_orders) AS avg_orders FROM CustomerMetrics GROUP BY frequency_segment ORDER BY frequency_segment DESC;



-- This query identifies the preferred product category for each customer based on their spending.-- 
WITH PreferredCategory AS (SELECT s.CustomerKey, p.Category, SUM(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS total_spend_in_category
    FROM Sales s JOIN Products p ON s.ProductKey = p.ProductKey JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode
    GROUP BY s.CustomerKey, p.Category), CustomerPreferredCategory AS (SELECT CustomerKey, Category, total_spend_in_category,RANK() 
    OVER (PARTITION BY CustomerKey ORDER BY total_spend_in_category DESC) AS 'rank'  FROM PreferredCategory) SELECT cpc.CustomerKey, cpc.Category AS preferred_category FROM CustomerPreferredCategory cpc WHERE cpc.rank = 1;
    
    
-- Finally, combine these segments to create a multi-dimensional customer profile: --
WITH CustomerSegments AS (
    SELECT 
        cm.CustomerKey,cm.Gender,cm.Age,cm.City,cm.State,cm.Country,cm.Continent,cm.total_spend_usd,cm.total_orders,cm.average_order_value_usd,cm.days_since_last_purchase,
        CASE 
            WHEN cm.total_spend_usd >= 10000 THEN 'High-Value'
            WHEN cm.total_spend_usd BETWEEN 5000 AND 9999 THEN 'Mid-Value'
            ELSE 'Low-Value'
        END AS spend_segment,
        CASE 
            WHEN cm.total_orders >= 20 THEN 'Frequent Buyer'
            WHEN cm.total_orders BETWEEN 10 AND 19 THEN 'Moderate Buyer'
            ELSE 'Infrequent Buyer'
        END AS frequency_segment,  
	cpc.preferred_category  FROM CustomerMetrics cm LEFT JOIN CustomerPreferredCategory cpc ON cm.CustomerKey = cpc.CustomerKey)
    SELECT * FROM CustomerSegments ORDER BY spend_segment DESC, frequency_segment DESC, Age ASC;


-- This query aggregates the total sales in USD for each order date. --
SELECT s.OrderDate, SUM(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS total_sales_usd
FROM Sales s JOIN Products p ON s.ProductKey = p.ProductKey
JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode
GROUP BY s.OrderDate ORDER BY s.OrderDate;


-- Analyze Monthly Sales Trends: --
-- This query shows total sales aggregated by month and year, which helps identify long-term trends.-- 
SELECT YEAR(s.OrderDate) AS year,MONTH(s.OrderDate) AS month,SUM(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS total_sales_usd
FROM Sales s JOIN Products p ON s.ProductKey = p.ProductKey JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode
GROUP BY YEAR(s.OrderDate), MONTH(s.OrderDate) ORDER BY year, month;

-- This query aggregates sales data by year to show overall growth or decline. --
SELECT YEAR(s.OrderDate) AS year,SUM(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS total_sales_usd FROM Sales s JOIN Products p ON s.ProductKey = p.ProductKey
JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode GROUP BY YEAR(s.OrderDate) ORDER BY year;

-- This query shows sales totals for each month across all years, helping to identify if certain months consistently see higher or lower sales. --
SELECT MONTH(s.OrderDate) AS month, SUM(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS total_sales_usd
FROM Sales s JOIN Products p ON s.ProductKey = p.ProductKey JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode
GROUP BY MONTH(s.OrderDate) ORDER BY month;

-- This query identifies which days of the week typically see higher sales, which can be useful for operational planning. -- 
SELECT DAYOFWEEK(s.OrderDate) AS day_of_week, SUM(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS total_sales_usd
FROM Sales s JOIN Products p ON s.ProductKey = p.ProductKey JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode
GROUP BY DAYOFWEEK(s.OrderDate) ORDER BY day_of_week;


-- To detect specific trends (e.g., increasing/decreasing sales over time), you can compare data across different periods. For instance, calculate the percentage change from one month to the next: --
SELECT year, month, total_sales_usd, LAG(total_sales_usd, 1) OVER (ORDER BY year, month) AS previous_month_sales,
    (total_sales_usd - LAG(total_sales_usd, 1) OVER (ORDER BY year, month)) / LAG(total_sales_usd, 1) OVER (ORDER BY year, month) * 100 AS month_over_month_growth 
    FROM (  SELECT YEAR(s.OrderDate) AS year,MONTH(s.OrderDate) AS month, SUM(s.Quantity * p.UnitPriceUSD / e.ExchangeRate) AS total_sales_usd
    FROM Sales s JOIN Products p ON s.ProductKey = p.ProductKey JOIN exrates e ON s.OrderDate = e.Date AND s.CurrencyCode = e.CurrencyCode
    GROUP BY YEAR(s.OrderDate), MONTH(s.OrderDate) ) AS MonthlySales ORDER BY year, month;




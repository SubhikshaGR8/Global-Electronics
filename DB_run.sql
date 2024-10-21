SHOW DATABASES;
USE project;
SHOW TABLES;

SELECT * FROM customers LIMIT 5;
SELECT * FROM products LIMIT 5;
SELECT * FROM sales LIMIT 35;
SELECT * FROM exchange_rates LIMIT 5;
SELECT * FROM stores LIMIT 5;

#--------------------------------------------------------------------------------------------------------------
ALTER TABLE products CHANGE `Product Name` Product_Name VARCHAR(200);
ALTER TABLE products CHANGE `Unit Price USD` Unit_Price_USD double;
ALTER TABLE products CHANGE `Unit Cost USD` Unit_Cost_USD double;
DESCRIBE products;
DESCRIBE sales;


SELECT 
    p.Product_Name,
    p.Brand,
    SUM(o.Quantity) AS TotalQuantitySold,
    FORMAT(SUM(o.Quantity * p.Unit_Price_USD), 2)AS TotalSales
FROM 
    Sales o
JOIN 
    Products p ON o.ProductKey = p.ProductKey
GROUP BY 
    p.Product_Name,
    p.Brand
ORDER BY 
    TotalQuantitySold DESC; -- To get the most popular products first
#--------------------------------------------------------------------------------------------------------------------
SELECT 
    p.Product_Name,
    p.Brand,
    p.Unit_Cost_USD,
    p.Unit_Price_USD,
    format((p.Unit_Price_USD - p.Unit_Cost_USD), 2 )AS ProfitPerUnit,
    format((p.Unit_Price_USD - p.Unit_Cost_USD), 2) / p.Unit_Price_USD * 100 AS ProfitMarginPercentage,
    
    SUM(o.Quantity) AS TotalQuantitySold,
    format(SUM(o.Quantity * (p.Unit_Price_USD - p.Unit_Cost_USD)),2 )AS TotalProfit
FROM 
    Sales o
JOIN 
    Products p ON o.ProductKey = p.ProductKey
GROUP BY 
    p.Product_Name,
    p.Brand,
    p.Unit_Cost_USD,
    p.Unit_Price_USD
ORDER BY 
    ProfitMarginPercentage DESC; -- To highlight products with higher profit margins
#----------------------------------------------------------------------------------------------------------------------------------------
SELECT 
    p.Category,
    p.Subcategory,
    SUM(o.Quantity) AS TotalQuantitySold,
    Format(SUM(o.Quantity * p.Unit_Price_USD), 3 ) AS TotalSales,
    FORMAT(SUM(o.Quantity * (p.Unit_Price_USD - p.Unit_Cost_USD)), 3) AS TotalProfit
FROM 
    Sales o
JOIN 
    Products p ON o.ProductKey = p.ProductKey
GROUP BY 
    p.Category,
    p.Subcategory
ORDER BY 
    TotalSales DESC -- To analyze the performance by category and subcategory
#--------------------------------------------------------------------------------------------------------------------
SELECT 
    Gender,
    City,
    State,
    Country,
    Continent,
    COUNT(*) AS TotalCustomers,	
    AVG(TIMESTAMPDIFF(YEAR, Birthday, CURDATE())) AS AverageAge
FROM 
    Customers
GROUP BY 
    Gender, City, State, Country, Continent; --- Demographic Distribution: Analyze the distribution of customers based on continent).
#------------------------------------------------------------------------------------------------------------------    


SELECT 
    c.CustomerKey,
    FORMAT(AVG(p.Unit_Price_USD * s.Quantity), 3 ) AS AverageOrderValue,
    COUNT(s.ProductKey) AS PurchaseFrequency,
    GROUP_CONCAT(DISTINCT p.Product_Name) AS PreferredProducts # group_concat(), DISTINCT() -----> I have used 
FROM 
    Customers c
JOIN 
    Sales s ON c.CustomerKey = s.CustomerKey
JOIN 
    Products p ON s.ProductKey = p.ProductKey
GROUP BY 
    c.CustomerKey
LIMIT 1000;

    
DESCRIBE products;  ----- Purchase Patterns: Identify purchasing patterns such as average order value, frequency of purchases, and preferred products.

#-----------------------------------------------------------------------------------------------------------------------
SELECT 
    c.Gender,
    AVG(TIMESTAMPDIFF(YEAR, c.Birthday, CURDATE())) AS AverageAge,
    COUNT(s.ProductKey) AS TotalPurchases,
    AVG(p.Unit_Price_USD * s.Quantity) AS AverageSpend,
    CASE 
        WHEN AVG(p.Unit_Price_USD * s.Quantity) < 50 THEN 'Low Value'
        WHEN AVG(p.Unit_Price_USD * s.Quantity) BETWEEN 50 AND 150 THEN 'Medium Value'
        ELSE 'High Value'
    END AS CustomerSegment
FROM 
    Customers c
LEFT JOIN 
    Sales s ON c.CustomerKey = s.CustomerKey
LEFT JOIN 
    Products p ON s.ProductKey = p.ProductKey
GROUP BY 
    c.Gender; ----- Segmentation: Segment customers based on demographics and purchasing behavior to identify key customer groups.












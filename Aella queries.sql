USE aella
;

SELECT *
FROM product
;

SELECT *
FROM sales_order_details
;

SELECT *
FROM sales_order_header
;

SELECT *
FROM sales_persons
;

SELECT *
FROM sales_territory
;


# 1. Sales Info
SELECT 
    p.ProductID, 
    p.ProductName, 
    sod.OrderQty, 
    sod.UnitPrice, 
    sod.LineTotal, 
    soh.OrderDate
FROM 
    product p
LEFT JOIN 
    sales_order_details sod ON p.ProductID = sod.ProductID
LEFT JOIN 
    Sales_order_header soh ON sod.SalesOrderID = soh.SalesOrderID
ORDER BY 
    p.ProductID
    ;

#2. Total Sales
SELECT 
    st.TerritoryID, 
    st.Name, 
    SUM(soh.TotalDue) AS TotalSales
FROM 
    sales_territory st
JOIN 
    Sales_order_header soh ON st.TerritoryID = soh.TerritoryID
GROUP BY 
    st.TerritoryID, st.Name
ORDER BY 
    TotalSales DESC
    ;

#3. most sold product
SELECT 
    p.ProductID, 
    p.ProductName, 
    SUM(sod.LineTotal) AS TotalSales
FROM 
    product p
JOIN 
    sales_order_details sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    TotalSales DESC
LIMIT 1
;






#4. totalsales by territory
SELECT 
    s.FirstName, 
    s.LastName, 
    st.Name AS TerritoryName, 
    SUM(soh.TotalDue) AS TotalSales
FROM 
    sales_order_header soh
JOIN 
    sales_territory st ON soh.TerritoryID = st.TerritoryID
JOIN 
    Sales_persons s ON soh.TerritoryID = s.TerritoryID
GROUP BY 
    s.FirstName, s.LastName, st.Name
ORDER BY 
    TotalSales DESC
    ;

#5. product status: sold or not
SELECT 
    p.ProductID, 
    p.ProductName, 
    CASE 
        WHEN sod.ProductID IS NULL THEN 'Not Sold'
        ELSE 'Sold'
    END AS SaleStatus
FROM 
    product p
LEFT JOIN 
    sales_order_details sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.ProductID, p.ProductName, sod.ProductID
ORDER BY 
    p.ProductID
    ;
    
    #6. Top 3 customers
    SELECT 
    soh.CustomerID, 
    SUM(soh.TotalDue) AS TotalPurchases
FROM 
    Sales_order_header soh
GROUP BY 
    soh.CustomerID
ORDER BY 
    TotalPurchases DESC
LIMIT 3
;


#. lets update sales_persons table
#create table

SET SQL_SAFE_UPDATES = 0
;


CREATE TABLE Sales_persona AS
SELECT DISTINCT
    TerritoryID,
    SalesPersonID
FROM
    sales_order_header
    ;

#alter
ALTER TABLE Sales_persons 
ADD COLUMN SalesPersonID INT
;

UPDATE Sales_persons s
JOIN Sales_persona sp ON s.TerritoryID = sp.TerritoryID
SET s.SalesPersonID = sp.SalesPersonID
;

DROP TABLE Sales_persona
;

SET SQL_SAFE_UPDATES = 1
;




#7. salesman commission
SELECT 
    s.FirstName, 
    s.LastName, 
    ROUND(SUM(soh.TotalDue * s.CommissionPct), 2) AS TotalCommission
FROM 
    Sales_persons s
JOIN 
    Sales_order_header soh ON s.SalesPersonID = soh.SalesPersonID
GROUP BY 
    s.FirstName, s.LastName
ORDER BY 
    TotalCommission DESC
    ;

    
    #8. Total Sales by salespersons in each territory
    
    SELECT 
    s.FirstName, 
    s.LastName, 
    st.Name AS TerritoryName, 
    SUM(soh.TotalDue) AS TotalSales
FROM 
    sales_order_header soh
JOIN 
    sales_territory st ON soh.TerritoryID = st.TerritoryID
JOIN 
    Sales_persons s ON soh.SalesPersonID = s.SalesPersonID
GROUP BY 
    s.FirstName, s.LastName, st.Name
ORDER BY 
    TotalSales DESC
    ;
    
    #9. Top 3 customers with most buys
    SELECT 
    soh.CustomerID, 
    SUM(soh.TotalDue) AS TotalPurchases
FROM 
    Sales_order_header soh
GROUP BY 
    soh.CustomerID
ORDER BY 
    TotalPurchases DESC
LIMIT 3
;

 #10. no sales in June
#Sales in July
SELECT 
    soh.SalesOrderID, 
    soh.OrderDate, 
    soh.TotalDue
FROM 
    Sales_order_header soh
WHERE 
    soh.OrderDate BETWEEN '2011-07-01' AND '2011-07-30'
ORDER BY 
    soh.OrderDate
    ;

#11. products with the longest manufacturing date
 SELECT 
    p.ProductID, 
    p.ProductName, 
    p.DaysToManufacture, 
    sod.OrderQty, 
    sod.UnitPrice, 
    sod.LineTotal, 
    soh.OrderDate
FROM 
    product p
LEFT JOIN 
    sales_order_details sod ON p.ProductID = sod.ProductID
LEFT JOIN 
    Sales_order_header soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE 
    p.DaysToManufacture = (SELECT MAX(DaysToManufacture) FROM product)
ORDER BY 
    p.ProductID
    ;
    
    #12. ave unit price of each product
   
    SELECT 
    p.ProductName, 
    ROUND(AVG(sod.UnitPrice), 2) AS AverageUnitPrice
FROM 
    product p
JOIN 
    sales_order_details sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.ProductName
ORDER BY 
    AverageUnitPrice DESC;

#13. months with the most sales
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
    ROUND(SUM(TotalDue), 2) AS TotalSales
FROM 
    Sales_order_header
GROUP BY 
    DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY 
    TotalSales DESC
LIMIT 1;

#sales amount by product
SELECT 
    p.ProductName, 
    ROUND(SUM(sod.LineTotal), 2) AS TotalSalesAmount
FROM 
    product p
JOIN 
    sales_order_details sod ON p.ProductID = sod.ProductID
GROUP BY 
    p.ProductName
ORDER BY 
    TotalSalesAmount DESC
    LIMIT 5
    ;






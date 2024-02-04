select* from Sales.Customers;
select* from Sales.CustomerCategories;
select* from Sales.CustomerTransactions
select* from Application.Cities;
select* from Application.DeliveryMethods


--Joining multiple tables 
SELECT Sales.Customers.CustomerID, Sales.Customers.CustomerName, 
Sales.CustomerCategories.CustomerCategoryName, Application.Cities.CityName, Application.DeliveryMethods.DeliveryMethodName,
SUM(Sales.CustomerTransactions.TransactionAmount) as Total 
FROM Sales.Customers
JOIN Sales.CustomerCategories ON Sales.Customers.CustomerCategoryID = Sales.CustomerCategories.CustomerCategoryID
JOIN Application.Cities ON Sales.Customers.DeliveryCityID = Application.Cities.CityID
JOIN Application.DeliveryMethods ON Sales.Customers.DeliveryMethodID = Application.DeliveryMethods.DeliveryMethodID
JOIN Sales.CustomerTransactions ON Sales.Customers.CustomerID = Sales.CustomerTransactions.CustomerID
GROUP BY Sales.Customers.CustomerID, Sales.Customers.CustomerName, 
Sales.CustomerCategories.CustomerCategoryName, Application.Cities.CityName, Application.DeliveryMethods.DeliveryMethodName
ORDER BY Sales.Customers.CustomerID ASC;


--To exlude $0 amount

SELECT Sales.Customers.CustomerID, Sales.Customers.CustomerName, 
Sales.CustomerCategories.CustomerCategoryName, Application.Cities.CityName, Application.DeliveryMethods.DeliveryMethodName,
SUM(Sales.CustomerTransactions.TransactionAmount) as Total 
FROM Sales.Customers
JOIN Sales.CustomerCategories ON Sales.Customers.CustomerCategoryID = Sales.CustomerCategories.CustomerCategoryID
JOIN Application.Cities ON Sales.Customers.DeliveryCityID = Application.Cities.CityID
JOIN Application.DeliveryMethods ON Sales.Customers.DeliveryMethodID = Application.DeliveryMethods.DeliveryMethodID
JOIN Sales.CustomerTransactions ON Sales.Customers.CustomerID = Sales.CustomerTransactions.CustomerID
GROUP BY Sales.Customers.CustomerID, Sales.Customers.CustomerName, 
Sales.CustomerCategories.CustomerCategoryName, Application.Cities.CityName, Application.DeliveryMethods.DeliveryMethodName
Having SUM(Sales.CustomerTransactions.TransactionAmount) >0
ORDER BY Sales.Customers.CustomerID ASC;


--Creating table ShppingTEST with queries 
SELECT Sales.Customers.CustomerID, Sales.Customers.CustomerName, 
Sales.CustomerCategories.CustomerCategoryName, Application.Cities.CityName, Application.DeliveryMethods.DeliveryMethodName,
SUM(Sales.CustomerTransactions.TransactionAmount) as Total 
INTO ShippingTest
FROM Sales.Customers
JOIN Sales.CustomerCategories ON Sales.Customers.CustomerCategoryID = Sales.CustomerCategories.CustomerCategoryID
JOIN Application.Cities ON Sales.Customers.DeliveryCityID = Application.Cities.CityID
JOIN Application.DeliveryMethods ON Sales.Customers.DeliveryMethodID = Application.DeliveryMethods.DeliveryMethodID
JOIN Sales.CustomerTransactions ON Sales.Customers.CustomerID = Sales.CustomerTransactions.CustomerID
GROUP BY Sales.Customers.CustomerID, Sales.Customers.CustomerName, 
Sales.CustomerCategories.CustomerCategoryName, Application.Cities.CityName, Application.DeliveryMethods.DeliveryMethodName
HAVING SUM(Sales.CustomerTransactions.TransactionAmount) > 0
ORDER BY Sales.Customers.CustomerID ASC;

select* 
from ShippingTest
order by CustomerID ASC;

ALTER TABLE ShippingTest
ADD CONSTRAINT PK_ShippingTest PRIMARY KEY (CustomerID);

SELECT CustomerID, CustomerName, MIN(Total)
FROM ShippingTest
GROUP BY CustomerID, CustomerName;

select  CustomerID, CustomerName, Total
FROM ShippingTest
ORDER BY Total DESC;

--Finding Max sales! 
SELECT CustomerID, CustomerName, MAX(Total) AS MaxTotal
FROM ShippingTest
GROUP BY CustomerID, CustomerName
HAVING MAX(Total) = (SELECT MAX(Total) FROM ShippingTest);

---Finding Min sales! by Select & Having commands 
SELECT CustomerID, CustomerName, MAX(Total) AS MaxTotal
FROM ShippingTest
GROUP BY CustomerID, CustomerName
HAVING MIN(Total) = (SELECT MIN(Total) FROM ShippingTest);

select *
from ShippingTest

select CityName, max(Total) as MaxTotal 
from ShippingTest
Group by CityName



select*
from Sales.Orders

--Finding how many orders per day 
-- Distinct keyword help to find unique value (not duplicate values) 
select DISTINCT OrderDate, count(OrderID) as TotalOrder
from Sales.Orders
GROUP by OrderDate
order by OrderDate
----Finding how many orders per day  per Sales person 
select DISTINCT SalespersonPersonID, OrderDate, count(OrderID) as TotalOrder
from Sales.Orders
GROUP by OrderDate, SalespersonPersonID
order by OrderDate

----Finding how many orders by sales person in Jan 
SELECT SalespersonPersonID, COUNT(OrderID) AS TotalOrder
FROM Sales.Orders
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-01-30'
GROUP BY SalespersonPersonID;


alter table Sales.Orders
add Month Int;

UPDATE Sales.Orders
SET Month = MONTH(OrderDate);


select DISTINCT Month, count(OrderID) as TotalOrder
from Sales.Orders
GROUP by Month
order by TotalOrder DESC;

select Month, count(OrderID) as TotalOrder
from Sales.Orders
GROUP by Month
order by TotalOrder DESC;

--Finding top 5 months in order 
SELECT TOP 5 [Month], COUNT(OrderID) AS TotalOrder
FROM Sales.Orders
GROUP BY Month
ORDER BY TotalOrder DESC;


SELECT*
FROM Sales.Orders

--this query shows the count of SalesPerson 
-- in the total order where there is more than 1
SELECT SalespersonPersonID, COUNT(*) as Total
FROM Sales.Orders
GROUP BY SalespersonPersonID
HAVING COUNT(*) > 1;


SELECT*
FROM Sales.InvoiceLines

--Difference between WHERE and HAVING


select DISTINCT InvoiceID, sum(ExtendedPrice)
from Sales.InvoiceLines
where ExtendedPrice >1000
Group by InvoiceID

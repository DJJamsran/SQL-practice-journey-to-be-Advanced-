
--Component Definition Range
--YYYY Year, including century 1000 to 9999
--MM Month 01 (January) to 12 (December)
--DD Day 01 to 31
--HH Hour 00 to 23
--HHH Hours (elapsed) −838 to 838
--MI Minute 00 to 59
--SS Second 00 to 59--Type Default format Allowable values
--Date YYYY-MM-DD 1000-01-01 to 9999-12-31
--Datetime YYYY-MM-DD HH:MI:SS 1000-01-01 00:00:00 to 9999-12-31 23:59:59
--Timestamp YYYY-MM-DD HH:MI:SS 1970-01-01 00:00:00 to 2037-12-31 23:59:59
--Year YYYY 1901 to 2155
--Time HHH:MI:SS −838:59:59 to 838:59:59

select* from ShippingTest

Create View Shipping_vw as
select CustomerID, Total
from ShippingTest

--Using subqueries 
select CustomerID, CustomerName, CityName
from ShippingTest
where CustomerCategoryName in (select CustomerCategoryName from ShippingTest
where total > 5000);


  select* from Warehouse.StockItemHoldings
  select* from Warehouse.StockItemTransactions
  select* from Warehouse.StockItems

--Joining tables by subqueries 
SELECT wh.StockItemID, wh.QuantityOnHand
FROM Warehouse.StockItemHoldings wh
INNER JOIN (
    SELECT StockItemID, CustomerID, InvoiceID
    FROM Warehouse.StockItemTransactions
    WHERE LastEditedBy = 4
) wt ON wh.StockItemID = wt.StockItemID;



SELECT wh.StockItemID, wh.QuantityOnHand, ws.UnitPrice, ws.StockItemName, ws.LeadTimeDays
FROM Warehouse.StockItemHoldings wh
INNER JOIN (
    SELECT StockItemID, CustomerID, InvoiceID
    FROM Warehouse.StockItemTransactions
    WHERE LastEditedBy = 4
) wt ON wh.StockItemID = wt.StockItemID
INNER JOIN (
	select StockItemID, StockItemName, UnitPrice, LeadTimeDays
	from Warehouse.StockItems
	where LeadTimeDays >10
) ws ON wh.StockItemID = ws.StockItemID;

-- Equi-Joins
-- example wh.StockItemID = wt.StockItemID 

SELECT wh.StockItemID, wh.QuantityOnHand
FROM Warehouse.StockItemHoldings wh
INNER JOIN (
    SELECT StockItemID, CustomerID, InvoiceID
    FROM Warehouse.StockItemTransactions
    WHERE LastEditedBy = 4
) wt ON wh.StockItemID = wt.StockItemID
INNER JOIN (
	select StockItemID, StockItemName, UnitPrice, LeadTimeDays
	from Warehouse.StockItems
	where LeadTimeDays >10
) ws ON wh.StockItemID = ws.StockItemID;



SELECT wh.StockItemID, wh.QuantityOnHand, NULL AS CustomerID, NULL AS InvoiceID
FROM Warehouse.StockItemHoldings wh
WHERE BinLocation LIKE 'L%'
UNION
SELECT NULL AS StockItemID, NULL AS QuantityOnHand, wt.CustomerID, wt.InvoiceID
FROM Warehouse.StockItemTransactions wt;


--The UNION keyword or set operator will allow you to combine the results of two queries. 
--It removes any duplicate results and shows you the combination of both.
SELECT wh.StockItemID
FROM Warehouse.StockItemHoldings wh
UNION
SELECT wt.StockItemID
FROM Warehouse.StockItemTransactions wt;




  select* from Warehouse.StockItemHoldings
  select* from Warehouse.StockItems
  select* from Warehouse.StockItemTransactions



SELECT wh.StockItemID
FROM Warehouse.StockItemHoldings wh
WHERE BinLocation LIKE 'L%'
UNION
SELECT wh.StockItemID
FROM Warehouse.StockItemHoldings wh
INNER JOIN Warehouse.StockItemTransactions w 
	ON  wh.StockItemID = w.StockItemID
	where w.LastEditedBy = 4
UNION ALL
SELECT wh.StockItemID
FROM Warehouse.StockItemHoldings wh
where LastCostPrice >20
ORDER by wh.StockItemID DESC;







SELECT wh.StockItemID
FROM Warehouse.StockItemHoldings wh
INNER JOIN Warehouse.StockItemTransactions w ON wh.StockItemID = w.StockItemID
WHERE wh.LastCostPrice > 20
AND wh.BinLocation LIKE 'L%'
AND w.LastEditedBy = 4


--SELECT p.name product, b.name branch,
-- -> CONCAT(e.fname, ' ', e.lname) name,
-- -> SUM(a.avail_balance) tot_deposits
-- -> FROM account a INNER JOIN employee e
-- -> ON a.open_emp_id = e.emp_id
-- -> INNER JOIN branch b
-- -> ON a.open_branch_id = b.branch_id
-- -> INNER JOIN product p
-- -> ON a.product_cd = p.product_cd
-- -> WHERE p.product_type_cd = 'ACCOUNT'
-- -> GROUP BY p.name, b.name, e.fname, e.lname
-- -> ORDER BY 1,2;


select* from Warehouse.StockItems
-- Count all supplier
select SupplierID, count(*) total_counts
from Warehouse.StockItems w
Group by SupplierID

---- Count all supplier, and find the max 
select SupplierID, count(*) total_counts
from Warehouse.StockItems w
Group by SupplierID
Having count(*) = (
	select MAX(total_counts)
	from (
	Select count(*) total_counts 
	from Warehouse.StockItems
	Group by SupplierID
	) as counts
);

  select* from Warehouse.StockItemHoldings
  select* from Warehouse.StockItems
  select* from Warehouse.StockItemTransactions

  select* from Sales.InvoiceLines
  select* from Warehouse.StockItems


--Task-oriented subqueries
--mysql> SELECT p.name product, b.name branch,
-- -> CONCAT(e.fname, ' ', e.lname) name,
-- -> account_groups.tot_deposits
-- -> FROM
-- -> (SELECT product_cd, open_branch_id branch_id,
-- -> open_emp_id emp_id,
-- -> SUM(avail_balance) tot_deposits
-- -> FROM account
-- -> GROUP BY product_cd, open_branch_id, open_emp_id) account_groups
-- -> INNER JOIN employee e ON e.emp_id = account_groups.emp_id
-- -> INNER JOIN branch b ON b.branch_id = account_groups.branch_id
-- -> INNER JOIN product p ON p.product_cd = account_groups.product_cd
-- -> WHERE p.product_type_cd = 'ACCOUNT';


select* from Warehouse.StockItems
select* from Sales.InvoiceLines

--Complex subquery by using double join 
SELECT w.SupplierID, 
       COUNT(*) AS ts,
       SUM(subquery.total) AS total_sum
FROM Warehouse.StockItems w
LEFT JOIN (
    SELECT s.StockItemID, SUM(s.ExtendedPrice) AS total
    FROM Sales.InvoiceLines s
    INNER JOIN Warehouse.StockItems w ON s.StockItemID = w.StockItemID
    GROUP BY s.StockItemID
) AS subquery ON w.StockItemID = subquery.StockItemID
GROUP BY w.SupplierID;

--Complex subquery by using double join 
select w.UnitPackageID, 
	count(*) as total_package,
	sum(total_order.total) as total_sum
from Warehouse.StockItems w
JOIN (
	select s.StockItemID, 
	SUM(s.ExtendedPrice) AS total
	from Sales.InvoiceLines s
	Inner Join Warehouse.StockItems w ON s.StockItemID = w.StockItemID
	GROUP BY s.StockItemID
) AS total_order ON w.StockItemID = total_order.StockItemID
Group by w.UnitPackageID;







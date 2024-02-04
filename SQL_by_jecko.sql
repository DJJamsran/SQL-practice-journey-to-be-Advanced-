--JOE CELKO'S SQL for SMARTIES

--CHAPTER 1: DATE DESIGN 
--DATA DESIGN FUNCTIONS:
--1 CREATE TABLE

--MANIPULATING FUNCTIONS: DROP, ALTER, UPDATE, CREATE TABLE, REFERENCE CLAUSE 
--COLUMN CONSTRAINTS
--Column constraints are rules attached to a table. All the rows in the table 
--are validated against them. File systems have nothing like this, since 
--validation is done in the application programs. Column constraints are 
--also one of the most underused features of SQL, so you will look like a 
--real wizard if you can master them

--TYPES OF CONSTRAINTS 
--Primary key constraints 
--Unique constraints
--Foreign key constraints
-- Check constraints
--Default constraints
--Not Null constraints
--Unique Index constraints


--CHECK() CONTSRAINS 
--The CHECK() constraint tests the rows of the table against a logical 
--expression, which SQL calls a search condition, and rejects rows whose 
--search condition returns FALSE. However, the constraint accepts rows 
-- when the search condition returns TRUE or UNKNOWN

--NOT NULL CONTSRAINS 

CREATE TABLE Exports(
	movie_title CHAR(25) NOT NULL, 
	country_code CHAR(2) NOT NULL, -- use 2-letter ISO nation codes
	sales_amt DECIMAL(12, 2) NOT NULL, 
	PRIMARY KEY (movie_title, country_code), 
	CONSTRAINT National_Quota 
	CHECK (-- reference to same table 
	10 <= ALL (SELECT COUNT(movie_title)
	FROM Exports AS E1
	GROUP BY E1.country_code))
); 


--UNIQUE CONSTRAIN VERSUS UNIQUE Indexes

--1) UNIQUE constraints are not the same thing as UNIQUE indexes
--2) The column referenced by a FOREIGN KEY has to be either a 
--PRIMARY KEY or a column with a UNIQUE constraint; a unique index 
--on the same set of columns cannot be referenced, since the index is on 
--one table and not a relationship between two tables

--Although there is no order to a constraint, an index is ordered, so the 
--unique index might be an aid for sorting. Some products construct special 
--index structures for the declarative referential integrity (DRI) constraints, 
--which in effect “pre-JOIN” the referenced and referencing tables.

--All the constraints can be defined as equivalent to some CHECK
--constraint. For example:

PRIMARY KEY = CHECK (UNIQUE (SELECT <key columns> FROM <table>)
 AND (<key columns>) IS NOT NULL)

 UNIQUE = CHECK (UNIQUE (SELECT <key columns> FROM <table>))

 NOT NULL = CHECK (<column> IS NOT NULL)


 --NESTED UNIQUE Constraints 

 --PROBLEM: 
-- The rules we want to enforce the table are:
--1. A teacher is in only one room each period.
--2. A teacher teaches only one class each period.
--3. A room has only one class each period.
--4. A room has only one teacher in it each period.



--If a teacher is in only one room each period, then given a period and 
--a teacher I should be able to determine only one room; i.e., room is 
--functionally dependent upon the combination of teacher and period. 
--Likewise, if a teacher teaches only one class each period, then class is 
--functionally dependent upon the combination of teacher and period. 
--The same thinking holds for the last two rules: class is functionally 
--dependent upon the combination of room and period, and teacher is 
--functionally dependent upon the combination of room and period.

CREATE TABLE Schedule_3 -- correct version
(teacher_name VARCHAR(15) NOT NULL, 
 class_name CHAR(15) NOT NULL, 
 room_nbr INTEGER NOT NULL, 
  period INTEGER NOT NULL, 
 UNIQUE (teacher_name, period), -- rules #1 and #2
 UNIQUE (room_nbr, period),
 UNIQUE (class_name, period)); -- rules #3 and #4
 
 --Modeling Class Hierarchies in DDL (Data Definition Language) 
-- The classic scenario in an object-oriented (OO) model calls for a root 
--class with all of the common attributes and then specialized subclasses 
--under it. As an example, let’s take the class of Vehicles and find an 
--industry standard identifier (the Vehicle Identification Number, or VIN), 
--and add two mutually exclusive subclasses, sport utility vehicles and 
--sedans ('SUV', 'SED')


CREATE TABLE Vehicles
(vin CHAR(17) NOT NULL PRIMARY KEY, 
 vehicle_type CHAR(3) NOT NULL
 CHECK(vehicle_type IN ('SUV', 'SED')), 
 UNIQUE (vin, vehicle_type), 
);


CREATE TABLE SUV 
(vin CHAR(17) NOT NULL PRIMARY KEY, 
 vehicle_type CHAR(3) DEFAULT 'SUV' NOT NULL
 CHECK(vehicle_type = 'SUV'), 
 UNIQUE (vin, vehicle_type), -- vin & vehicle_type have to be unique and not repeated 
 FOREIGN KEY (vin, vehicle_type) 
 REFERENCES Vehicles(vin, vehicle_type)
 ON UPDATE CASCADE
 ON DELETE CASCADE, 
);


CREATE TABLE Sedans
(vin CHAR(17) NOT NULL PRIMARY KEY, 
 vehicle_type CHAR(3) DEFAULT 'SED' NOT NULL
 CHECK(vehicle_type = 'SED'), 
 UNIQUE (vin, vehicle_type), 
 FOREIGN KEY (vin, vehicle_type)
 REFERENCES Vehicles(vin, vehicle_type)
 ON UPDATE CASCADE
 ON DELETE CASCADE, 
 );


-- I can continue to build a hierarchy like this. For example, if I had a 
--Sedans table that broke down into two-door and four-door sedans, I 
--could build a schema like this

CREATE TABLE Sedans.V2
(vin char(17) NOT NULL PRIMARY KEY,
 vehicle_type char(3) default 'SED' NOT NULL,
	CHECK(vehicle_type in ('2D', '4D', 'SED')),
 UNIQUE (vin, vehicle_type), 
 FOREIGN KEY (vin, vehicle_type)
 REFERENCES Vehicles(vin, vehicle_type)
 ON UPDATE CASCADE
 ON DELETE CASCADE, 
);


--Generating Unique Sequential Numbers for Keys

CREATE TABLE Footbar(
	a int,
	b int,
	c int
); 

--Approach 1
--Notice the use of the COALESCE() function to handle the empty 
--table and to get the numbering started with one. This approach 
--generalizes from a row insertion to a table insertion:

select*from Footbar

--INSERT INTO Footbar(a,b,c ...)
--VALUES
--(COALESCE((SELECT MAX(a) from Footbar), 0) +1, ...),
--(COALESCE((SELECT MAX(b) from Footbar), 0) +2, ...),
--(COALESCE((SELECT MAX(c) from Footbar), 0) +3, ...);


--Creating user defined fuction
use customer

CREATE TABLE GeneratorValues 
(lock CHAR(1) DEFAULT 'X' NOT NULL PRIMARY KEY -- only one row
 CHECK (lock = 'X'), 
keyval INTEGER DEFAULT 1 NOT NULL -- positive numbers only
 CHECK (keyval > 0));

 SELECT* FROM GeneratorValues

 --Creating user defined function 
CREATE FUNCTION dbo.Generator (@VAR INT)
 RETURNS INT AS 
 BEGIN 
	RETURN @var+1
END
GO

select dbo.Generator(1)
GO

-- Update the keyval column using the Generator function
WITH UpdatedValues AS (
    SELECT keyval, dbo.Generator(keyval) AS new_value
    FROM GeneratorValues
)
UPDATE UpdatedValues
SET keyval = new_value;

SELECT*, dbo.Generator(1) from GeneratorValues
GO

UPDATE GeneratorValues
SET keyval = 1+(select dbo.Generator(1) from GeneratorValues)

INSERT INTO GeneratorValues (lock, keyval)
VALUES ('', dbo.Generator(1));


--Cursors (Transact-SQL)
--CLOSE

--CREATE PROCEDURE

--DEALLOCATE

--DECLARE CURSOR

--DECLARE @local_variable

--DELETE

--FETCH

--OPEN

--UPDATE

--SET

--Normalization: 

--1NF: Primary key, Data type, Indepedent data 
--2NF: Each non-key attributes must depend on primary keys 
--3NF: Prevent from non key attributes depend each other. 
--So, each non -key attribute must depends on the key
--4NF: Multivalued dependencies in a table must be multivalued dependencies on the key
--5NF: Tables can be joined on the logic(by keys)

--Chapter3: Numeric Data in SQL 
--CAST() function 
--In SQL Server, the CAST () function converts an expression of one data type to another.

--For example 
SELECT CAST(25.65 AS varchar);
SELECT CAST('2017-08-25' AS datetime);

-- Converting value to and from null 
--SQL specifies two functions, NULLIF() and the related COALESCE(), 
--that can be used to replace expressions with NULL, and vice versa. They 
--are part of the CASE expression family

NULLIF(V1, V2) := CASE
 WHEN (V1 = V2)
 THEN NULL
 ELSE V1 END;

--Example of coalesce
select coalesce(department_id, 0)--null values converted to '0' 
from employee


--Exponential Functions
--POWER(x, n) = Raises the number x to the nth power.
--SQRT(x) = Returns the square root of x.
--LOG10(x) = Returns the base ten logarithm of x. See remarks about 
--LN(x).
--LN(x) or LOG(x) = Returns the natural logarithm of x. The problem is 
--that logarithms are undefined when (x <= 0). Some SQL 
--implementations return an error message, some return a NULL and DB2/
--400; version 3 release 1 returned *NEGINF (short for “negative infinity”) 
--as its result.
--EXP(x) = Returns e to the x power; the inverse of a natural log.


-- Scaling Functions
--ROUND(x, p) = Round the number x to p decimal places.
--TRUNCATE(x, p) = Truncate the number x to p decimal places.
--FLOOR(x) = The largest integer less than or equal to x.
--CEILING(x) = The smallest integer greater than or equal to x.

--Chapter4:Temporal data types in SQL
--For example, to reduce a TIMESTAMP to just a date with the clock set 
--to 00:00 in SQL Server, you can take advantage of their internal 
--representation and write:
CAST (FLOOR (CAST (mydate AS FLOAT)) AS DATETIME);

select CURRENT_TIMESTAMP as c, 
GETDATE() as g,
CAST(FLOOR(CAST(CURRENT_TIMESTAMP AS FLOAT)) AS DATETIME);

SELECT CURRENT_TIMESTAMP AS FLOAT;
SELECT CAST(CURRENT_TIMESTAMP AS FLOAT);
select FLOOR(CAST(CURRENT_TIMESTAMP AS FLOAT))AS DATETIME; 
SELECT CAST(FLOOR(CAST(CURRENT_TIMESTAMP AS FLOAT))AS DATETIME); 

SELECT CONVERT(DATE, GETDATE()) AS CurrentDate;

CREATE TABLE EXAMS(
	exam_date date,
	markout_date date
); 
select* from EXAMS

INSERT INTO EXAMS (exam_date, markout_date)
VALUES
((SELECT CONVERT(DATE, GETDATE())), DATEADD(DAY, 7, (SELECT CONVERT(DATE, GETDATE()))));



INSERT INTO EXAMS (exam_date, markout_date)
SELECT 
    CONVERT(DATE, GETDATE()) AS exam_date,
    DATEADD(DAY, 7, CONVERT(DATE, GETDATE())) AS markout_date
UNION ALL
SELECT 
    CONVERT(DATE, GETDATE()) AS exam_date,
    DATEADD(DAY, 14, CONVERT(DATE, GETDATE())) AS markout_date
UNION ALL
SELECT 
    CONVERT(DATE, GETDATE()) AS exam_date,
    DATEADD(DAY, 21, CONVERT(DATE, GETDATE())) AS markout_date;

INSERT INTO EXAMS
SELECT*
FROM EXAMS; 

--Copy table

Select*
into EXAMS2
FROM EXAMS;

SELECT* FROM EXAMS2

--CHAPTER 5: Character Data Types in SQL
 CREATE TABLE Foobar (x VARCHAR(5) NOT NULL);
 INSERT INTO Foobar VALUES ('a'), ('a '), ('a '), ('a ');


SELECT x, LEN(x) AS char_length
FROM Foobar
GROUP BY x;


--CHAPTER 8: TABLE OPERATIONS 
--DELETE STATEMENT
--WHERE CLAUSE 

--DELETING BASED ON THE SECOND TABLE 

--EXAMPLE 
--DELETE FROM Deadbeats 
-- WHERE EXISTS (SELECT *
-- FROM Payments AS P1
-- WHERE Deadbeats.cust_nbr = P1.cust_nbr
-- AND P1.amtpaid >= Deadbeats.amtdue);


--DELETING WITHIN THE SAME TABLE
--EXAMPLE

--DELETE FROM Students
-- WHERE grade < (SELECT AVG(grade) FROM Students);

--INSERT TINTO STATEMENT
--UPDATE STATEMENT 

--UPDATE TABLE FROM THE SECOND TABLE 
--EXAMPLE:

--UPDATE Customers
-- SET acct_amt 
-- = acct_amt
-- - (SELECT SUM(amt)
-- FROM Payments AS P1
-- WHERE Customers.cust_nbr = P1.cust_nbr)
-- WHERE EXISTS (SELECT * 
 --FROM Payments AS P2 
 --WHERE Customers.cust_nbr = P2.cust_nbr);


-- The second common programming error that is made with this kind 
--of UPDATE is to use an aggregate function that does not return zero when 
--it is applied to an empty table, such as the AVG(). Suppose we wanted to 
--post the average payment amount made by the Customers; we could not 
--just replace SUM() with AVG() and acct_amt with average balance in the 
--above UPDATE. Instead, we would have to add a WHERE clause to the 
--UPDATE that gives us only those customers who made a payment, thus:


--UPDATE Customers
-- SET payment = (SELECT AVG(P1.amt)
--					FROM Payments AS P1
--					WHERE Customers.cust_nbr = P1.cust_nbr)
-- WHERE EXISTS (SELECT *
-- FROM Payments AS P1
-- WHERE Customers.cust_nbr = P1.cust_nbr);


select* from StudentFees

select*
into StudentFees2
from StudentFees; 

select* from StudentFees2

delete from StudentFees2

--INSERT INTO values from the second table 
INSERT INTO StudentFees2 (FirstName)
SELECT FirstName
from StudentFees; 

--UPDATE TABLE FROM THE SECOND TABLE 
Update StudentFees2
SET LastName = (select LastName
					from StudentFees o
					where StudentFees2.FirstName = o.FirstName); 


Update StudentFees2
SET Fees_Required = (select Fees_Required
					from StudentFees o
					where StudentFees2.FirstName = o.FirstName)
where StudentID <20;


--CHAPTER 11: CASE EXPRESSION 

--Simple case expression example 
 --CASE iso_sex_code
 --WHEN 0 THEN 'Unknown'
 --WHEN 1 THEN 'Male'
 --WHEN 2 THEN 'Female'
 --WHEN 9 THEN 'N/A'
 --ELSE NULL END


 --CASE EXPRESSION with GROUP 

 --SELECT dept_nbr, 
 --SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0) AS males,
 --SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0) AS females
 --FROM Personnel
 --GROUP BY dept_nbr;

 --OR

 --SELECT dept_nbr, 
 --COUNT(CASE WHEN gender = 'M' THEN 1 ELSE NULL) AS males,
 --COUNT(CASE WHEN gender = 'F' THEN 1 ELSE NULL) AS females
 --FROM Personnel
 --GROUP BY dept_nbr


 --CASE, CHECK() Clauses and Logical Implication

 CREATE TABLE Foobar_DDL
(a CHAR(1) CHECK (a IN ('T', 'F')), 
 b CHAR(1) CHECK (b IN ('T', 'F')),
CONSTRAINT implication_example_2
CHECK(CASE WHEN A = 'T'
 THEN CASE WHEN B = 'T'
 THEN 1 ELSE 0 END
 ELSE 1 END = 1));


INSERT INTO Foobar_DDL 
VALUES ('T', 'T'),
 ('T', 'F'), -- fails
 ('T', NULL), 
 ('F', 'T'), 
 ('F', 'F'), 
 ('F', NULL), 
 (NULL, 'T'), 
 (NULL, 'F'), 
 (NULL, NULL);


 --LIKE PREDICT 
 --CASE Experessions and Like expressions 

 select* from StudentFees


 SELECT 
    FirstName,
    LastName,
    CASE WHEN LastName LIKE '%S' THEN 1 ELSE 0 END AS IsSLastName
FROM (
    SELECT 
        FirstName,
        LastName
    FROM StudentFees
) AS SubqueryAlias;



SELECT 
    FirstName,
    LastName,
    CASE WHEN LastName LIKE '%S' THEN 1 ELSE 0 END AS IsSLastName
FROM StudentFees;

--Between and predicate
--Overlaps predicate

--the [NOT] IN predicate 


Select StudentID, FirstName, LastName
from StudentFees
where state in ('New York', 'Texas');


--Example
--SELECT restaurant_name, phone_nbr
-- FROM Restaurants
-- WHERE restaurant_name 
-- IN (SELECT restaurant_name
-- FROM MenuGuide
-- WHERE price <= 10.00);

--OR 

--SELECT restaurant_name, phone_nbr
-- FROM Restaurants, MenuGuide
-- WHERE price <= 10.00
-- AND Restaurants.restaurant_name = MenuGuide.restaurant_name;


--IN() and Referential constraint
--Example 
--CREATE TABLE Addresses
-- (addressee_name CHAR(25) NOT NULL PRIMARY KEY,
-- street_loc CHAR(25) NOT NULL,
-- city_name CHAR(20) NOT NULL,
-- state_code CHAR(2) NOT NULL
-- CONSTRAINT valid_state_code
-- CHECK (state_code IN ('AL', 'AK', ...)),
--);


--Example 

CREATE TABLE NumberTest (
    AgeRef INT,
    FavNum INT,
    CONSTRAINT CHK_AgeRef CHECK (AgeRef < 40),
    CONSTRAINT CHK_FavNum CHECK (FavNum < 9)
);


INSERT INTO NumberTest(AgeRef, FavNum)
VALUES (39, 1)

Select* from NumberTest


-- IN() Predicate and Scalar Queries

--Example
--SELECT P.upc 
-- FROM Picklist AS P
-- WHERE P.upc 
-- IN ((SELECT upc FROM Warehouse AS W WHERE W.upc = 
--Picklist.upc),
-- (SELECT upc FROM TruckCenter AS T WHERE T.upc = 
--Picklist.upc),
-- ...
-- (SELECT upc FROM Garbage AS G WHERE G.upc = 
--Picklist.upc));

--EXISTS PREDICATE

select* from employee
SELECT P1.emp_name, ' was born on a day without a famous New 
Yorker!'
 FROM Personnel AS P1
 WHERE NOT EXISTS
 (SELECT *
 FROM Celebrities AS C1
 WHERE C1.birth_city = 'New York'
 AND C1.birthday = P1.birthday);


 --EXISTS and INNER Joins

 SELECT P1.emp_name, ' has the same birthday as a famous person!'
 FROM Personnel AS P1, Celebrities AS C1
 WHERE P1.birthday = C1.birthday
 and P1.emp_name = C1.emp_name;

 --the above query can be run by the following query 
 SELECT P1.emp_name, ' has the same birthday as ', C1.emp_name
 FROM Personnel AS P1, Celebrities AS C1
 WHERE EXISTS
 (SELECT *
 FROM Celebrities AS C2
 WHERE P1.birthday = C2.birthday
 AND C1.emp_name = C2.emp_name);

 select* from employee
 select* from emp

 select*
 into emp3
 from employee

  select* from emp3

  Update emp3
  SET Birthdate =
  CASE 
	WHEN employee_id = 14 then '1975-09-01'
	WHEN employee_id = 13 then '1986-12-02'
	END; 



SELECT e.full_name as e, e3.full_name as e3
FROM employee e, emp3 e3
WHERE EXISTS
	(SELECT*
	 FROM emp3
	 WHERE e.Birthdate = e3.Birthdate
	 and e.full_name = e3.full_name)



--EXISTS AND REFERENTIAL CONSTRAINTS 

--EXAMPLE
 --CREATE TABLE Addresses
 --(addressee_name CHAR(25) NOT NULL PRIMARY KEY,
 --street_loc CHAR(25) NOT NULL,
 --city_name CHAR(20) NOT NULL,
 --state_code CHAR(2) NOT NULL
 --REFERENCES ZipCodeData(state_code) -- THIS CAN BE WRITTEN AS BELOW

-- CREATE TABLE Addresses
--(addressee_name CHAR(25) NOT NULL PRIMARY KEY,
-- street_loc CHAR(25) NOT NULL,
-- city_name CHAR(20) NOT NULL,
-- state_code CHAR(2) NOT NULL,
-- CONSTRAINT valid_state_code
-- CHECK (EXISTS(SELECT *
-- FROM ZipCodeData AS Z1
-- WHERE Z1.state_code = Addresses.state_code)),
-- ...);


--EXISTS AND THREE VALUED LOGIC 

--SELECT spx.sup_nbr
-- FROM SupplierParts AS spx
-- WHERE spx.part_nbr = 'P1'
-- AND NOT EXISTS
-- (SELECT *
-- FROM SupplierParts AS spy
-- WHERE spy.sup_nbr = spx.sup_nbr
-- AND spy.part_nbr = 'P1'
-- AND spy.qty = 1000);

--CHAPTER 16 QUANTIFIED SUBQUERIES PREDICATES


SELECT* FROM StudentFees

SELECT FirstName, LastName, State
FROM StudentFees
WHERE Fees_Paid > (SELECT AVG(Fees_Paid)
					FROM StudentFees);

--Correlated subqueries in a select statement 
SELECT FirstName, LastName, State
FROM StudentFees S1
WHERE Fees_Paid < (SELECT AVG(Fees_Paid)
					FROM StudentFees S2
					where S1.State = S2.State);


--Joining multiple tables 
CREATE VIEW Shipping AS 
SELECT Sales.Customers.CustomerID, Sales.Customers.CustomerName, 
Sales.CustomerCategories.CustomerCategoryName, Application.Cities.CityName, Application.DeliveryMethods.DeliveryMethodName,
SUM(Sales.CustomerTransactions.TransactionAmount) as Total 
FROM Sales.Customers
JOIN Sales.CustomerCategories ON Sales.Customers.CustomerCategoryID = Sales.CustomerCategories.CustomerCategoryID
JOIN Application.Cities ON Sales.Customers.DeliveryCityID = Application.Cities.CityID
JOIN Application.DeliveryMethods ON Sales.Customers.DeliveryMethodID = Application.DeliveryMethods.DeliveryMethodID
JOIN Sales.CustomerTransactions ON Sales.Customers.CustomerID = Sales.CustomerTransactions.CustomerID
GROUP BY Sales.Customers.CustomerID, Sales.Customers.CustomerName, 
Sales.CustomerCategories.CustomerCategoryName, Application.Cities.CityName, Application.DeliveryMethods.DeliveryMethodName;



--Updatable Views
--1) Views are created only by one table or one view
--2) if query contains 'DISTINCT' clause, then views cannot be update 
--3) if query contains 'GROUP BY' clause, then views cannot be update 
--4) if query contains 'With' clause, then views cannot be update 
--5) if query contains 'WINDOW' functions, then views cannot be update 
--6) if query contains 'HAVING' clause, then views cannot be update 

select* from Shipping

select StudentID::varchar, State
from StudentFees


--Renaming columns in the existing view
EXEC sp_rename '.Shipping.Total', 'Totalshipping', 'column'


Alter view Shipping
drop column DeliveryMethodName;


select*from employee

CREATE VIEW EMPBRIEF AS 
select full_name, salary, emp_level, Birthdate
from employee; 


Select* from EMPBRIEF


Update EMPBRIEF
SET Birthdate = '1973-03-02'
where full_name = 'Natalie Rocca'

CREATE VIEW Dept AS 
select department_id, count(*) as total
FROM employee
WHERE department_id IS NOT NULL
GROUP BY department_id;

select* from Dept

UPDATE Dept
Set total = 5
where department_id = 5


--'With check option' in views 
Select*from StudentFees

CREATE VIEW STUDENTSTATE AS
Select StudentID, FirstName, LastName,State
from StudentFees
where State = 'New York'
with check option; 


select*from STUDENTSTATE

INSERT INTO StudentFees(FirstName, LastName, State)
VALUES('Tim', 'Mathew', 'New York'),
('Tom', 'Bull', 'Texas'); 



--GROPU BY and Having 
use WideWorldImporters;
select* from Sales.Invoices;


select SalespersonPersonID,
count(*)
from Sales.Invoices
GROUP BY SalespersonPersonID
HAVING COUNT(*) > 7000;

select* from Sales.InvoiceLines;

select s.InvoiceID, sum(s.quantity)
from Sales.InvoiceLines s
Group by s.InvoiceID, s.PackageTypeID



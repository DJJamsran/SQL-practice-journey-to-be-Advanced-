--SQL Set Operators
-- set operator in SQL is a keyword that lets you combine the results of two queries into a single query.


--The Different Types of Set Operators
--The different set operators are:

--UNION
--UNION ALL
--MINUS
--INTERSECT
--EXCEPT


Create table Cus(
	 CustomerID int identity(1,1) primary key,
	 Full_name varchar(50),
	 Age int,
);

INSERT INTO Cus (full_name, Age)
VALUES 
('John Smith', 41),
('Wayne Ablett', 51),
('Michelle Carey', 32),
('Chris Matthews', 33),
('Andrew Judd', 43),
('Danielle McLeod', 25),
('Matthew Swan', 29),
('Stephanie Richardson', 62),
('Tony Grant', 33),
('Jenna Lockett', 34),
('Michael Dunstall', 47),
('Jane Voss', 41),
('Anthony Hird', 52),
('Natalie Rocca', 59);

select* from Cus
select* from employee

SELECT Full_name, age
FROM cus
UNION
SELECT full_name, salary
FROM employee;


INSERT INTO cus(Full_name, Age)
Values 
('David John', 75),
('Sarah Bird', 90),
('Debra Tyle', 44);


SELECT 'Customer' AS record_type, Full_name
FROM cus
UNION
SELECT Distinct 'Employee', full_name
FROM employee;


--EXCEPT is the same as MINUS – they both show results from one query that don’t exist in another query.
--The INTERSECT keyword allows you to find results that exist in both queries. 
--Two SELECT statements are needed, and any results that are found in both of them are returned if INTERSECT is used.

select* from MaleCandidate
select* from FemaleCandidate

select location
from MaleCandidate
INTERSECT
select location
from FemaleCandidate 

select location
from MaleCandidate
EXCEPT
select location
from FemaleCandidate 


select FirstName, LastName, Seeking
from MaleCandidate
UNION ALL
select FirstName, LastName,Seeking
from FemaleCandidate 

--Operator	Meaning
--=	Is equal to
--!=	Is not equal to
--<>	Is not equal to
-->	Is greater than
-->=	Is greater than or equal to
--<	Is less than
--<=	Is less than or equal to
--IN	Is in a list of values
--NOT IN	Is not in a list of values
--EXISTS	Is found in a result set
--NOT EXISTS	Is not found in a result set
--LIKE	Is a partial match
--NOT LIKE	Is not a partial match
--BETWEEN	Is between two values
--NOT BETWEEN	Is not between two values
--ANY	Matches at least one of a list of values
--ALL	Matches all of a list of values


-- Using operations
SELECT FirstName, LastName, Seeking
FROM MaleCandidate
WHERE FirstName LIKE 'J%'
UNION ALL
SELECT FirstName, LastName, Seeking
FROM FemaleCandidate
WHERE FirstName LIKE 'S%';


SELECT FirstName, LastName, Seeking
FROM MaleCandidate
WHERE Seeking = 'F'
UNION ALL
SELECT FirstName, LastName, Seeking
FROM FemaleCandidate
WHERE Seeking = 'M'


SELECT FirstName, LastName, Seeking, location
FROM MaleCandidate
WHERE Seeking = 'F'
AND Location IN (SELECT Location FROM FemaleCandidate)
UNION ALL
SELECT FirstName, LastName, Seeking, location
FROM FemaleCandidate
WHERE Seeking = 'M'
AND Location IN (SELECT Location FROM MaleCandidate);

--Summary of ALL and ANY
--= ALL ()	The value must match all of the values in the list.
--<> ALL ()	The value must not match any of the values in the list.
--> ALL ()	The value must be greater than the largest value in the list.
--< ALL ()	The value must be less than than the smallest value in the list.
-->= ALL ()	The value must be greater than or equal to the largest value in the list.
--<= ALL ()	The value must be less than or equal to than the smallest value in the list.
--= ANY ()	The value must match one or more values in the list.
--<> ANY ()	The value must not match one or more values in the list.
--> ANY ()	The value must be greater than the smallest value in the list.
--< ANY ()	The value must be less than than the largest value in the list.
-->= ANY ()	The value must be greater than or equal to the smallest value in the list.
--<= ANY ()	The value must be less than or equal to than the largest value in the list.




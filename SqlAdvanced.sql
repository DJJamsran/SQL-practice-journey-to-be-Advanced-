---Chapter 1 

--Retrieving data

select* from sales.InvoiceLines

select DISTINCT StockItemID, sum(ExtendedPrice) as total
from sales.InvoiceLines
Group by StockItemID
Having sum(ExtendedPrice) = (select Max(total) from (
		 select sum(ExtendedPrice) as total
		 from sales.InvoiceLines
		 Group by StockItemID) as subquery
		 );


SELECT TOP 5 StockItemID, SUM(ExtendedPrice) AS total
FROM sales.InvoiceLines
GROUP BY StockItemID
ORDER BY total DESC;

select* from employee

-- How to convert NULL to 0
select coalesce (department_id, 0)
from employee;

select case 
	when department_id is null then 0
	else department_id
	end
from employee;

--Chapter 2 Sorting 

select full_name, job_role, salary
from employee
where department_id = 4
order by 3 desc; -- '3' means order by command corresponds to the third column 

--Using substring function in the order by clause



SELECT employee_id, full_name, department_id, salary
FROM (
    SELECT employee_id, full_name, department_id, salary,
        CASE
            WHEN department_id IS NULL THEN 0
        END AS is_null
    FROM employee
) x
ORDER BY is_null DESC, department_id;


--Chapter 3 Working with multiple tables
--Can use 'Union' command, which removes duplicate columns

select* from Warehouse.StockItemHoldings
select* from Warehouse.StockItems

-- Using where clause 
SELECT wh.QuantityOnHand, wh.LastCostPrice, ws.UnitPrice, ws.RecommendedRetailPrice,
       SUM(((ws.UnitPrice - wh.LastCostPrice) / ws.UnitPrice)*100) as Gross_margin 
FROM Warehouse.StockItemHoldings wh
JOIN Warehouse.StockItems ws ON wh.StockItemID = ws.StockItemID
WHERE wh.StockItemID = 10
GROUP BY wh.QuantityOnHand, wh.LastCostPrice, ws.UnitPrice, ws.RecommendedRetailPrice;


--Retrieving values from one table that do not exist in another
--Oracle can use commands like minus or except
-- however, sql server can use command 'not in'

select wh.StockItemID
from Warehouse.StockItemHoldings wh
where wh.StockItemID not in (select StockItemID from Warehouse.StockItems);


--Retrieving values from one table that exist in another
select wh.StockItemID
from Warehouse.StockItemHoldings wh
where wh.StockItemID in (select StockItemID from Warehouse.StockItems);


-- adding joins to a query without interfering with other joins

select wh.StockItemID, ws.UnitPrice, ws.StockItemName,
			(select ws.SupplierID from Warehouse.StockItems ws 
			 where ws.SupplierID = 12
			 and LeadTimeDays <10) as x
from Warehouse.StockItemHoldings wh, Warehouse.StockItems ws 
where wh.StockItemID = ws.StockItemID
order by 2 desc


select* from employee


--Performing Joins when using Aggregates 
select SupplierID,
avg(UnitPrice) as ave_price
from (
		select ws.SupplierID, 
		ws.UnitPrice
		from Warehouse.StockItems ws, Warehouse.StockItemHoldings wh
		where ws.StockItemID = wh.StockItemID
		and ws.StockItemID between 1 and 100
		)  x
Group by SupplierID



select* from Sales.Invoices
select* from Sales.InvoiceLines


--Returning Missing Data from Multiple Tab
--Results give that there is no missing data 
select si.InvoiceID, s.InvoiceID
from Sales.Invoices si
left outer join Sales.InvoiceLines s
ON si.InvoiceID = s.InvoiceID;


--Chapter 4: Inserting, Updating, & Deleting 

--Coping rows from one table into Another 

--Insert into dept_east (deptno, dname, loc)
--select deptno, dname, loc
--	from dept
--	where loc in ('New York', 'Boston')

-- Coping a table definition

select *
into employee2
from employee

select* from employee2



select* from department
select* from employee

--Updating with values from another another table by subquery
update employee
set department_id = (select department_id from department where department_name = 'HR')
where full_name = 'John Smith'


select* from employee2
--Deleting column
alter table employee2
drop column salary

alter table employee2
add salary int

--Updating with values from another another table by joining table with where clause 
--Updating with values from another another table
update employee2 
set salary = e.salary
	from employee2 e2, employee e 
	where e2.employee_id = e.employee_id



--Deleting Referential Integrity Violations 
-- When you wish to delete records from a table when those records refer to non existent in some other table by using not exist command 

insert into employee2 (full_name)
Values ('Peter Hunt')

delete from employee2
where not exists (select *from employee
					where employee.employee_id = employee2.employee_id)


--Deleting duplicate records

insert into employee2 (full_name)
Values 
('Peter Hunt'),
('Peter Hunt'),
('Peter Hunt'),
('Peter Hunt');

delete from employee2 
where employee_id not in (select min(employee_id)
							from employee2
							group by full_name)

-- In this query, you will get an error says that emp_id cannot be grouped by full_name due to duplicate name 
select employee_id, full_name
from employee2
Group by full_name

-- Here, this query selects emp_id with distinct name, and not including emp_id with duplicate names 
select min(employee_id), full_name
from employee2
Group by full_name


--Deleting Records Referenced from another
--You want to delete records from one table when those records are referenced from some other table

select* from department
select 

create table depno_accident (
	department_id int,
	accident_name varchar(50)
)
Insert into depno_accident(department_id, accident_name)
VALUES 
(2, 'foot'), 
(3, 'shoulder'),
(5, 'hand'),
(9, 'hand'),
(8, 'foot'),
(10, 'head');

select* from depno_accident

delete from depno_accident
where department_id in (select department.department_id
							from department, depno_accident
							where department.department_id = depno_accident.department_id); 


--Chapter 5: Metadata queries 
--Read more this!!!!
--Listing table's column 

select COLLATION_NAME, DATA_TYPE, ORDINAL_POSITION
from INFORMATION_SCHEMA.COLUMNS
where TABLE_SCHEMA = 'customer'
and TABLE_NAME = 'employee'; 


--Chapter 6 Working with strings
--Read more this!!!!


--Chapter 7 Working with numbers
-- Generating running total (accunmlating)

select* from employee

SELECT
    e.full_name,
    e.salary,
    (
        SELECT SUM(d.salary)
        FROM employee2 d
        WHERE d.employee_id <= e.employee_id
    ) AS running_total
FROM
    employee2 e
ORDER BY 3;

--Running multipication example: running total = sal from emp1* sal from emp 2

SELECT
    e.full_name,
    e.salary,
    (
        SELECT EXP(SUM(log(d.salary)))
        FROM employee2 d
        WHERE d.employee_id <= e.employee_id
    ) AS running_total
FROM
    employee2 e
ORDER BY 3;



--Calculating running difference
select
e.full_name,
e.salary,
	(
	Select 
	Case
	when e.employee_id = min(d.employee_id) then sum (d.salary)
		else sum(-d.salary)
	end
	from employee2 d
	WHERE d.employee_id <= e.employee_id
	) as rnk 
from employee2 e

select* from employee2

select e. employee_id, e.full_name, e.salary,
	(
	select sum(d.salary-e.salary)
	from employee2 d
	WHERE d.employee_id < e.employee_id
	) as rnk
from employee2 e 


select e.*,
lag(salary) over (partition by department_id order by employee_id) as comparison_with_previous_record
from employee2 e


-- Calculating a Mode

-- Ranking salary 
--(A)
Select full_name, salary,
rank() over ( order by salary DESC) as rank_sal
from employee2 

Select full_name, salary,
Dense_rank() over ( order by salary DESC) as rank_sal
from employee2 

--(B)
--Finding how many times each salary range occuring

SELECT salary,
		DENSE_RANK () over (ORDER BY cnt DESC) as rank
FROM (
select salary, count (*) as cnt
from employee2
Group by salary) x 

--calculatin Median 
drop table employee2
select* from employee

--Calculating median 
Select avg(salary)
from ( select salary,
	count (*) over () total,
	cast(count (*) over () as decimal)/2 mid, -- finding a number of salary in the list, and what is mid number 
	ceiling(cast(count (*) over () as decimal)/2) next, -- finding next a whole int 
	row_number() over(order by salary ) rn
	from employee
	) x 
where (total%2 = 0 -- findind whether it is even
		and rn in (mid, mid+1)
		)
or (total%2 = 1 -- findind whether it is odd
	and rn =1)


--Determining percentage of total
--You want to determine the percentage that values in a specific column represent against a total 

select full_name, salary,
	cast(salary as decimal)/total*100 as pct
from (select full_name, salary,
	sum(salary) over () total
	from employee) x


--determine the percentage that values in a specific column represent against a total  in the specific department
select full_name, salary,
	cast(salary as decimal)/total*100 as pct
from (select full_name,salary, 
	sum(salary) over () total
	from employee
	where department_id = 4) x


 --Computing averege withough high and low
 --You want to compute an average, but you wish to exclude the highest and lowest values in order to
 --(hopefully) reduce the effect skew. 

 select avg (salary)
 from (
	select salary,
	min(salary) over () min_sal,
	max(salary) over () max_sal
	from employee
	) x
where salary not in (min_sal, max_sal)

--Chapter 8 Data Arithmetic
--This chapter is about simple arithmetic tasks like adding days to dates, finding a number of days between dates
--finding business days between days 

select* from employee

alter table employee
drop column sal_growth

alter table employee
add Birthdate date 

where employee_id between 1 and 12

UPDATE employee
SET Birthdate = 
Case
	when employee_id = 1 then ('1967-01-06')
	when employee_id = 2 then ('1970-09-04')
	when employee_id = 3 then ('1999-03-05')
	when employee_id = 4 then ('1987-09-02')
	when employee_id = 5 then ('1980-08-13')
	when employee_id = 6 then ('1991-07-07')
	when employee_id = 7 then ('1993-06-06')
	when employee_id = 8 then ('1969-05-05')
	when employee_id = 9 then ('1978-04-12')
	when employee_id = 10 then ('1979-03-03')
	when employee_id = 11 then ('1988-04-30')
	when employee_id = 12 then ('1989-01-01')
	when employee_id = 13 then ('1986-12-01')
	when employee_id = 14 then ('1973-03-01')
	END;

select 
dateadd (day, -5, Birthdate) as hd_minus_5days
From employee
where employee_id = 1 


SELECT full_name, Birthdate,
    DATEADD(DAY, -5, Birthdate) AS hd_minus_5days
FROM employee
WHERE employee_id = 1;


SELECT full_name, Birthdate,
    DATEADD(MONTH, -5, Birthdate) AS hd_minus_5days
FROM employee
WHERE employee_id = 1;

SELECT full_name, Birthdate,
    DATEADD(YEAR, -5, Birthdate) AS hd_minus_5days
FROM employee
WHERE employee_id = 1;


--Determinin numbers between dates
--Finding difference between two dates 

SELECT
    (SELECT Birthdate FROM employee WHERE employee_id = 1) AS x,
    (SELECT Birthdate FROM employee WHERE employee_id = 2) AS x1,
    DATEDIFF(DAY, (SELECT Birthdate FROM employee WHERE employee_id = 1), (SELECT Birthdate FROM employee WHERE employee_id = 2)) AS difference;


SELECT
    DATEDIFF(DAY, (SELECT Birthdate FROM employee WHERE employee_id = 1), (SELECT Birthdate FROM employee WHERE employee_id = 2)) AS difference;

SELECT
    DATEDIFF(MONTH, (SELECT Birthdate FROM employee WHERE employee_id = 1), (SELECT Birthdate FROM employee WHERE employee_id = 2)) AS difference;
SELECT
    (SELECT Birthdate FROM employee WHERE employee_id = 1) AS x,
    (SELECT Birthdate FROM employee WHERE employee_id = 2) AS x1,
    DATEDIFF(MONTH, (SELECT Birthdate FROM employee WHERE employee_id = 1), (SELECT Birthdate FROM employee WHERE employee_id = 2)) AS difference;

SELECT
    (SELECT Birthdate FROM employee WHERE employee_id = 1) AS x,
    (SELECT Birthdate FROM employee WHERE employee_id = 2) AS x1,
    DATEDIFF(YEAR, (SELECT Birthdate FROM employee WHERE employee_id = 1), (SELECT Birthdate FROM employee WHERE employee_id = 2)) AS difference;



Select emp1, emp2, DATEDIFF(day, emp1, emp2) as diff 
from (
	select Birthdate as emp1
	from employee
	where employee_id = 1
	) x,
	(
	select Birthdate as emp2
	from employee
	where employee_id = 2
	) y

--Determining the business days between two days

select Birthdate,
DATENAME(day, Birthdate) as dw
from employee
where employee_id =1 

select Birthdate,
DATEPART(day, Birthdate) as dw
from employee
where employee_id =1 


DECLARE @start_date DATE = (select Birthdate from employee where employee_id = 1);
DECLARE @end_date DATE = (select Birthdate from employee where employee_id = 2);

SELECT 
    @start_date AS start_date,
    @end_date AS end_date,
    COUNT(*) - (2 * (DATEDIFF(WEEK, @start_date, @end_date) + 1)) AS business_days
FROM (
    SELECT TOP (DATEDIFF(DAY, @start_date, @end_date) + 1) 
        DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1, @start_date) AS date
    FROM sys.columns
) dates
WHERE DATEPART(WEEKDAY, date) NOT IN (1, 7);


--Determining the number of months or years between two dates
SELECT
    DATEDIFF(MONTH, (SELECT Birthdate FROM employee WHERE employee_id = 1), (SELECT Birthdate FROM employee WHERE employee_id = 2)) AS difference;


--Determing the number of seconds, munitues, hours and two dates 
Select emp1, emp2, 
DATEDIFF(YEAR, emp1, emp2) as yeardiff, 
DATEDIFF(MONTH, emp1, emp2) as monthdiff, 
DATEDIFF(day, emp1, emp2) as daydiff, 
DATEDIFF(day, emp1, emp2)*24 as Total_hours, 
DATEDIFF(day, emp1, emp2)*24*60 as Total_minutes,
DATEDIFF(day, emp1, emp2)*24*60*60 as Total_Seconds
from (
	select Birthdate as emp1
	from employee
	where employee_id = 1
	) x,
	(
	select Birthdate as emp2
	from employee
	where employee_id = 2
	) y


--Counting the occurrences of weekdays in a year
--1. Generate all possible dates in year
--2. Format the date such that they solve to the name of their respective weekdays
--3. Count the occurence of eachday of weekday name

select* from employee

update employee
set Birthdate = '1968-01-06'
where employee_id = 2

--Generating days from start to end date
DECLARE @start_date DATE = (select Birthdate from employee where employee_id = 1);
DECLARE @end_date DATE = (select Birthdate from employee where employee_id = 2);
SELECT TOP (DATEDIFF(DAY, @start_date, @end_date) + 1) 
        DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1, @start_date) AS date
    FROM sys.columns

-- Generating days with Union All
WITH X (STARTDATE, ENDDATE) AS (
    SELECT 
        (SELECT Birthdate FROM employee WHERE employee_id = 1) AS STARTDATE,
        (SELECT Birthdate FROM employee WHERE employee_id = 2) AS ENDDATE
    UNION ALL
    SELECT DATEADD(day, 1, STARTDATE), ENDDATE
    FROM X
    WHERE DATEADD(day, 1, STARTDATE) <= ENDDATE
)
Select*
from X
OPTION (MAXRECURSION 1000);


-- Counting occurences of each day 
WITH X (STARTDATE, ENDDATE) AS (
    SELECT 
        (SELECT Birthdate FROM employee WHERE employee_id = 1) AS STARTDATE,
        (SELECT Birthdate FROM employee WHERE employee_id = 2) AS ENDDATE
    UNION ALL --generating recursive date from start date till end off date 
    SELECT DATEADD(day, 1, STARTDATE), ENDDATE
    FROM X
    WHERE DATEADD(day, 1, STARTDATE) <= ENDDATE
)
SELECT DATENAME(dw, STARTDATE) AS Weekday, COUNT(*) AS Count
FROM X
GROUP BY DATENAME(dw, STARTDATE)
OPTION (MAXRECURSION 1000);


--Chapter 9: Date Manipulation 
--This chapter introduces recipes for searching and modifying dates. 

WITH x (dy, mth) AS (
    SELECT
        CAST(dy AS DATE),
        MONTH(dy) AS mth
    FROM (
        SELECT DATENAME(day, Birthdate) AS dy
        FROM employee
        WHERE employee_id = 1
    ) AS t
    UNION ALL
    SELECT
        DATEADD(dd, 1, dy) AS dy,
        mth
    FROM x
    WHERE MONTH(DATEADD(dd, 1, dy)) = mth
)
SELECT MAX(dy) AS MaxDay
FROM x;


--Determining the number of days in a year 

WITH X (STARTDATE, ENDDATE) AS (
    SELECT 
        (SELECT Birthdate FROM employee WHERE employee_id = 1) AS STARTDATE,
        (SELECT Birthdate FROM employee WHERE employee_id = 2) AS ENDDATE
    UNION ALL --generating recursive date from start date till end off date 
    SELECT DATEADD(day, 1, STARTDATE), ENDDATE
    FROM X
    WHERE DATEADD(day, 1, STARTDATE) <= ENDDATE
)
SELECT DATENAME(dw, STARTDATE) AS Weekday, COUNT(*) AS D, 
sum(COUNT(*)) over () as total
FROM X
GROUP BY DATENAME(dw, STARTDATE)
OPTION (MAXRECURSION 1000);


--Determining the number of days in a year 
WITH X (STARTDATE, ENDDATE) AS (
    SELECT 
        (SELECT Birthdate FROM employee WHERE employee_id = 1) AS STARTDATE,
        (SELECT Birthdate FROM employee WHERE employee_id = 2) AS ENDDATE
    UNION ALL --generating recursive date from start date till end off date 
    SELECT DATEADD(day, 1, STARTDATE), ENDDATE
    FROM X
    WHERE DATEADD(day, 1, STARTDATE) <= ENDDATE
)
SELECT COUNT(STARTDATE) as total
FROM X
OPTION (MAXRECURSION 1000);

--Exracting Units of time from a date
-- Using DATEPART function 

--Determining the first and last day of a month 
WITH X (sd) AS (
    SELECT Birthdate sd
	FROM employee 
	WHERE employee_id = 10 
) 
Select 
DATEADD(day, -day(sd)+1, sd) firstday,
DATEADD(day, 
		-day(sd)+1,
		 DATEADD(month, 1, sd)) lastday
from X;


WITH X (sd) AS (
    SELECT Birthdate sd
	FROM employee 
	WHERE employee_id = 1 
) 
Select*
from X; 

--Determining all dates for a particular weekday for a year
--for example, you may wish to generate a list of Fridays for the particular year


WITH X (STARTDATE, ENDDATE) AS (
    SELECT 
        (SELECT Birthdate FROM employee WHERE employee_id = 1) AS STARTDATE,
        (SELECT Birthdate FROM employee WHERE employee_id = 2) AS ENDDATE
    UNION ALL --generating recursive date from start date till end of date 
    SELECT DATEADD(day, 1, STARTDATE), ENDDATE
    FROM X
    WHERE DATEADD(day, 1, STARTDATE) <= ENDDATE
)
SELECT STARTDATE,  
       DATENAME(dw, STARTDATE) AS Weekday
FROM X
WHERE DATENAME(dw, STARTDATE) = 'Friday'
OPTION (MAXRECURSION 1000);

---B way
Create table t1 (
	TD date
);
Insert into t1
values ('1960-06-06');



--Not working, needs to be fixed
WITH x (dy, yr) AS (
    SELECT dy, YEAR(dy) AS yr
    FROM (
        SELECT GETDATE() - DATEPART(dy, GETDATE()) + 1 AS dy
        FROM t1
    ) s
    UNION ALL
    SELECT DATEADD(dd, 1, dy) AS dy, NULL AS yr
    FROM x
    WHERE YEAR(DATEADD(dd, 1, dy)) = yr
)
SELECT x.dy
FROM x
WHERE DATENAME(dw, x.dy) = 'Friday'
OPTION (MAXRECURSION 400);


--Listing start and end dates of quarters for a year

with x (dy, cnt) AS(
	SELECT dateadd(d, -(datepart(dy, getdate())-1), getdate()), 
		1
		FROM t1
	UNION ALL
	select dateadd(m, 3, dy), cnt +1
	from x
	where cnt + 1 <= 4
)
SELECT DISTINCT  DATEPART(q, dateadd(d, -1, dy)) QTR,
		dateadd(m, -3, dy) Q_start,
		dateadd(d, -1, dy) Q_end
from x
order by 1


--Generating quarter start dates 
with x (dy, cnt) AS(
	SELECT dateadd(d, -(datepart(dy, getdate())-1), getdate()), 
		1
		FROM t1
	UNION ALL
	select dateadd(m, 3, dy), cnt +1
	from x
	where cnt + 1 <= 4
)
Select*
from x


-- Generating start days 
with x (dy, cnt) AS(
	SELECT dateadd(d, -(datepart(dy, getdate())-1), getdate()), 
		1
		FROM t1
	UNION ALL
	select dateadd(m, 3, dy), cnt +1
	from x
	where cnt + 1 <= 4
)
Select Distinct dy
from x



--Chapter 10 Working with Ranges
--Read more!!

select* from employee

select year(Birthdate) yr, count(*) cnt
from employee
group by year(Birthdate); 


--Generatin consecutive numbers 

with x (id) AS(
	select employee_id id 
	from employee
	where employee_id = 1
	UNION ALL
	select id+1
	from x
	where id +1<=10
)
select* from x


--Chapter 1 Advanced Searching 

-- Show first 5 salary 

Select salary
from (
	select ROW_NUMBER () over (order by salary DESC) as rn,
	salary
	from employee) x
where rn between 1 and 5; 


Select salary
from (
	select salary, ROW_NUMBER () over (order by salary DESC) as rn
	from employee) x
where rn between 1 and 5; 

--Versus the above query 
SELECT e.*,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY employee_id) AS rn
FROM employee e


select salary, ROW_NUMBER () over (order by salary DESC) as rn
from employee


--Skipping rows in a table 
select* from employee

select *
from (select*,
		ROW_NUMBER () over (order by full_name) as rn
		from employee e) x
where rn%2 = 1;


Create table emp (
	empname varchar(50),
	sal int,
	hiredate date
); 

INSERT INTO emp (empname, sal, hiredate)
VALUES
('Smith', 800, '1980-12-17'), 
('Allen', 1600, '1981-02-20'), 
('Ward', 1250, '1981-02-22'), 
('Jones', 2975, '1981-04-02'), 
('Blake', 2850, '1981-05-01'), 
('Clark', 2450, '1981-06-09'), 
('Turner', 1500, '1981-09-08'), 
('Martin', 1250, '1981-09-28'), 
('King', 5000, '1981-11-17'), 
('James', 950, '1981-12-03'), 
('Ford', 3000, '1981-12-03'), 
('Miller', 1300, '1982-01-23'), 
('Scott', 3000, '1982-12-09'), 
('Adams', 1100, '1983-01-23'); 

select* from emp;

--Problem: Find employess who earn less then employess hired immediately after them 

--Solution:
--1) find employees hired immediately with hire salary and name it as next_sal_greater in a subquery
--2) find next hire dates from previous hiredate name as next_hiredate in a subquery
--3) find employess with less sal where next_sal = nexthire 

SELECT empname, sal, hiredate
FROM ( 
    SELECT a.empname, a.sal, a.hiredate,
        (SELECT MIN(hiredate) FROM emp b
         WHERE b.hiredate > a.hiredate
           AND b.sal > a.sal) AS next_sal_grtr,
        (SELECT MIN(hiredate) FROM emp b
         WHERE b.hiredate > a.hiredate) AS next_hire
    FROM emp a		
) x 
WHERE next_sal_grtr = next_hire;



SELECT empname, sal, hiredate, next_sal_grtr
FROM (
    SELECT a.empname, a.sal, a.hiredate,
        (SELECT MIN(hiredate) FROM emp b
         WHERE b.hiredate > a.hiredate
           AND b.sal > a.sal) AS next_sal_grtr
    FROM emp a
) x
WHERE next_sal_grtr IS NOT NULL;



--Shitting values

-- Problem: you want to return each employee's name and sal along with the next highest and lowest 

--Solution: 

select empname, sal,
	coalesce(
	(select min(sal) from emp d where d.sal > e.sal),
				(select min(sal) from emp)
				) as forward_sal,
	coalesce(
	(select max(sal) from emp d where d.sal < e.sal),
				(select max(sal) from emp)
				) as rewind_sal
from emp e 
order by 2 



SELECT
    empname,
    sal,
    COALESCE((
        SELECT MIN(sal)
        FROM emp d
        WHERE d.sal > e.sal
    ), 0) AS forward_sal,
    COALESCE((
        SELECT MAX(sal)
        FROM emp d
        WHERE d.sal < e.sal
    ), 0) AS rewind_sal
FROM
    emp e
ORDER BY
    sal;


alter table emp
add age int; 

select* from emp

UPDATE emp
set age =
CASE
when empname = 'Smith' then 25
when empname = 'Ward' then 34
when empname = 'Jones' then 40
when empname =  'Blake' then 30
when empname = 'Turner'then 39
when empname = 'Martin' then 19
when empname = 'King' then 56
when empname =  'James' then 23 
END; 

--Filling missing value at the age colum by coalesce 
select empname, coalesce(age, 0)
from emp


--Chapter 12 reporting and warehousing 
select* from employee

select department_id, count(*) as total_emp
from employee
GROUP by department_id


select job_role, full_name, 
Row_number () over (partition by job_role order by full_name) rn 
from employee

SELECT 
    MAX(CASE WHEN job_role = 'Back-end Developer' THEN full_name ELSE NULL END) AS Developer,
    MAX(CASE WHEN job_role = 'Salesperson' THEN full_name ELSE NULL END) AS Sales,
    MAX(CASE WHEN job_role = 'Sales Manager' THEN full_name ELSE NULL END) AS SalesADmin
FROM (
    SELECT 
        job_role,
        full_name,
        ROW_NUMBER() OVER (PARTITION BY job_role ORDER BY full_name) rn
    FROM employee
)  x
GROUP BY rn;



select job_role, full_name, 
Row_number () over (partition by job_role order by full_name) rn 
from employee

select* from employee


 --Calculating simple subtotal 

 select department_id, 
 avg(salary) as avg_sal
 from employee
 GROUP BY department_id


 --USING ROLL UP for subtotal 

 select department_id, 
 avg(salary) as avg_sal
 from employee
 GROUP BY ROLLUP (department_id);

 -- another way 

 select coalesce(department_id, 0), department_id,
 avg(salary) avg_sal
 from employee
 group by department_id with rollup


 --Performing Aggeregations over different groups/partitions simutaneously 
  select DISTINCT department_id, 
 count(*) over (partition by department_id) dep_cnt
 from employee;

 select DISTINCT department_id, job_role, 
 count(*) over (partition by department_id) dep_cnt, 
  count(*) over (partition by job_role) jb_cnt
 from employee; 



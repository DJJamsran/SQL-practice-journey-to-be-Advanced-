CREATE TABLE StudentFees (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(25),
    LastName VARCHAR(25),
    Fees_Required DECIMAL(5, 2),
    Fees_Paid DECIMAL(5, 2),
	State varchar(25)
);

select*
from StudentFees

alter table  StudentFees
add State varchar (25);

INSERT INTO [customer].[dbo].[StudentFees] (FirstName, LastName, Fees_Required, Fees_Paid, State)
VALUES
('John', 'Smith', 500.00, 100.00, 'New York'),
('Emily', 'Johnson', 150.00, 150.00, 'Colorado'),
('Michael', 'Brown', 350.00, 320.00, 'Nevada'),
('Sarah', 'Lee', 500.00, 410.00, 'New York'),
('David', 'Wang', 100.00, 80.00, 'New York'),
('Jessica', 'Taylor', 100.00, 0.00, 'Texas'),
('Andrew', 'Miller', 250.00, 0.00, 'Florida'),
('Olivia', 'Martinez', 800.00, 400.00, 'Texas'),
('James', 'Anderson', 110.00, 100.00, 'Colorado'),
('Sophia', 'Harris', 150.00, 150.00, 'Texas');



--Difference between WHERE and HAVING
-- This is because the WHERE clause is run first, which eliminates rows that don’t meet the criteria.
--In this case, all rows where fees_paid <= 500 are removed from the result set. No results show up 
SELECT state, SUM(Fees_Paid)
FROM StudentFees
WHERE fees_paid > 500
GROUP BY state;


SELECT state, SUM(Fees_Paid)
FROM StudentFees
GROUP BY state
Having sum(fees_paid) > 500;


CREATE TABLE sample_group_table (
  student_name VARCHAR(50),
  subject_name VARCHAR(100),
  school_year INT,
  student_grade INT
);

INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Andrew', 'Physics', 2020, 76);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Belle', 'Physics', 2020, 85);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Chris', 'Physics', 2020, 40);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Debbie', 'Physics', 2020, 54);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Andrew', 'English', 2020, 96);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Belle', 'English', 2020, 99);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Chris', 'English', 2020, 41);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Debbie', 'English', 2020, 49);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Andrew', 'Mathematics', 2020, 44);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Belle', 'Mathematics', 2020, 42);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Chris', 'Mathematics', 2020, 94);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Debbie', 'Mathematics', 2020, 57);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Andrew', 'Physics', 2021, 53);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Belle', 'Physics', 2021, 85);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Chris', 'Physics', 2021, 74);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Debbie', 'Physics', 2021, 72);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Andrew', 'English', 2021, 48);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Belle', 'English', 2021, 76);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Chris', 'English', 2021, 86);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Debbie', 'English', 2021, 68);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Andrew', 'Mathematics', 2021, 41);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Belle', 'Mathematics', 2021, 57);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Chris', 'Mathematics', 2021, 92);
INSERT INTO sample_group_table (student_name, subject_name, school_year, student_grade)
VALUES ('Debbie', 'Mathematics', 2021, 65);



SELECT*
FROM sample_group_table


SELECT school_year,
COUNT(*)
FROM sample_group_table
GROUP BY school_year;

--Find max score by each subject 
select subject_name,
MAX(student_grade)
FROM sample_group_table
GROUP BY subject_name


SELECT subject_name, student_name, MAX(student_grade) As HighAchiever
FROM sample_group_table
GROUP BY subject_name, student_name
HAVING MAX(student_grade) = (SELECT MAX(student_grade) FROM sample_group_table);

-- Ranking 
WITH RankedStudents AS (
    SELECT
        student_name,
        subject_name,
        student_grade,
        RANK() OVER (PARTITION BY subject_name ORDER BY student_grade DESC) AS rnk
    FROM
        sample_group_table
)
SELECT
    student_name,
    subject_name,
    student_grade AS HighestScore
FROM
    RankedStudents
WHERE
    rnk = 1;


-- Find ave mark by each student in total subject

select student_name, AVG(student_grade) as AVG_GRADE
from sample_group_table
GROUP by student_name
Order by student_name


select student_name, AVG(student_grade) as AVG_GRADE
from sample_group_table
GROUP by student_name
HAVING AVG(student_grade) >=65
Order by student_name





--The ROLLUP SQL grouping type allows you to group by subtotals and a grand total.
--GROUP BY ROLUP
select student_name, school_year, AVG(student_grade)
from sample_group_table
GROUP BY ROLLUP (student_name, school_year)
order by student_name, school_year

-- VS with the query above 
select student_name, school_year, AVG(student_grade)
from sample_group_table
GROUP BY student_name, school_year
order by student_name, school_year


--Another type of SQL GROUP BY you can do is GROUP BY CUBE.
--It’s similar to ROLLUP in SQL but allows for more subtotals to be shown.
--Each combination of student_name and school_year (same as ROLLUP)
--A subtotal for each student_name (same as ROLLUP)
--A subtotal for each school_year
--An overall total (same as ROLLUP)

-- GROUP BY CUBE
select student_name, school_year, AVG(student_grade)
from sample_group_table
GROUP BY CUBE (student_name, school_year)
order by student_name, school_year


-- GROUP BY CUBE adding subject_name 
select student_name, school_year, subject_name, AVG(student_grade)
from sample_group_table
GROUP BY CUBE (student_name, school_year, subject_name)
order by student_name, school_year, subject_name

--By using Grouping SETS, we can choose to which group can be subtotalled 

SELECT student_name,
subject_name,
school_year,
SUM(student_grade) AS total_grades
FROM sample_group_table
GROUP BY GROUPING SETS (student_name, subject_name, school_year)
ORDER BY student_name, subject_name, school_year
--VS with the query above 
SELECT student_name,
subject_name,
school_year,
SUM(student_grade) AS total_grades
FROM sample_group_table
GROUP BY GROUPING SETS ((student_name, subject_name), school_year)
ORDER BY student_name, subject_name, school_year

--VS with the query above 
SELECT student_name, subject_name, school_year,
SUM(student_grade) AS total_grades
FROM sample_group_table
GROUP BY GROUPING SETS ((school_year, subject_name), student_name)
ORDER BY subject_name, student_name, school_year

--VS with the query above 
SELECT subject_name, school_year,
SUM(student_grade) AS total_grades
FROM sample_group_table
GROUP BY GROUPING SETS ((subject_name, school_year), school_year)
ORDER BY subject_name, school_year;


select*
from sample_group_table

select count(*)
from sample_group_table
where student_grade >50;


CREATE TABLE department (
department_id int identity(1,1) PRIMARY KEY,
department_name varchar(100)
);
 
 select*
 from department 

CREATE TABLE employee (
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100),
    department_id INT,
    job_role VARCHAR(100),
    manager_id INT,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);


INSERT INTO department(department_name) 
VALUES 
('Executive'),
('HR'),
('Sales'),
('Development'),
('Support'),
('Research');


INSERT INTO employee (full_name, department_id, job_role, manager_id)
VALUES 
('John Smith', 1, 'CEO', NULL),
('Wayne Ablett', 1, 'CIO', 1),
('Michelle Carey', 2, 'HR Manager', 1),
('Chris Matthews', 3, 'Sales Manager ', 2),
('Andrew Judd', 4, 'Development Manager', 3),
('Danielle McLeod', 5, 'Support Manager', 3),
('Matthew Swan', 2, 'HR Representative', 4),
('Stephanie Richardson', 2, 'Salesperson', 5),
('Tony Grant', 3, 'Salesperson', 5),
('Jenna Lockett', 4, 'Front-End Developer', 6),
('Michael Dunstall', 4, 'Back-End Developer', 6),
('Jane Voss', 4, 'Back-End Developer', 6),
('Anthony Hird', null, 'Support', 7),
('Natalie Rocca', 5, 'Support', 7);


 select*
 from employee

 SELECT
e.full_name,
e.job_role,
d.department_name
FROM employee e
INNER JOIN department d ON e.department_id = d.department_id;


--Left Outer join 
--Here is the way that the data is loaded:
--For each record in table1
--Show the data from table1
--Look for a match in table2
--Match found?
--Show data from table2
--Match not found?
--Show NULL

SELECT
e.employee_id,
e.full_name,
e.job_role,
d.department_id,
d.department_name
FROM employee e
LEFT OUTER JOIN department d ON e.department_id = d.department_id;

--The LEFT JOIN is the same, as the OUTER keyword is optional.
SELECT
e.employee_id,
e.full_name,
e.job_role,
d.department_id,
d.department_name
FROM employee e
LEFT JOIN department d ON e.department_id = d.department_id;


-- Right Outer Join

select
e.employee_id,
e.full_name,
e.job_role,
e.department_id,
d.department_name
from employee e
RIGHT JOIN department d ON e.department_id=d.department_id

--FULL JOIN
select
e.employee_id,
e.full_name,
e.job_role,
e.department_id,
d.department_name
from employee e
FULL JOIN department d ON e.department_id=d.department_id

--CROSS JOIN
--This is how the data is loaded:

--For each record in table1
--For each record in table2
--Show data from table1 and table2
--There is no filtering of the data here.
SELECT
e.employee_id,
e.full_name,
e.job_role,
d.department_id,
d.department_name
FROM employee e
CROSS JOIN department d;

--Joining tables by using where clause 
--Inner join by where clause 
SELECT
e.full_name,
e.job_role,
d.department_name
FROM employee e, department d
WHERE e.department_id = d.department_id;



--UPDATE commands

--Update with using subquery

select*
from StudentFees

-- Update current required fees of the student ID 5 by max in the table 
UPDATE StudentFees
set Fees_Required = (select max(Fees_Required) from StudentFees)
where StudentID = 5 

-- Update the max by 400 
UPDATE StudentFees
set Fees_Required = 400
where Fees_Required = (
select max(Fees_Required) from StudentFees
);

--Updating Two Columns Using a Subquery

UPDATE StudentFees
SET Fees_Required = (SELECT MAX(Fees_Required) FROM StudentFees),
    Fees_Paid = (SELECT MAX(Fees_Paid) FROM StudentFees)
WHERE StudentID = 6;

--Check the Data Types
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'StudentFees';


--What Are the Types of Constraints in SQL?
--They are:

--Primary Key Constraint: this ensures all rows have a unique value and cannot be NULL, often used as an identifier of a table’s row.
--Foreign Key Constraint: this ensures that values in a column (or several columns) match values in another table’s column/s.
--Unique Constraint: this ensures all rows have a unique value.
--Not Null Constraint: this ensures a value cannot be NULL.
--Check Constraint: this ensures a value meets a specific condition.


ALTER TABLE employee
ADD CONSTRAINT pk_emp_id PRIMARY KEY(employee_id);



--ON DELETE
--The ON DELETE clause is a clause of a foreign key. 
--It lets you determine how you want to treat referenced data when you delete the parent record.

--There are two options:
--ON DELETE SET NULL: When you delete the parent record, then all child records will have the referenced column set to NULL.
--ON DELETE CASCADE: When you delete the parent record, then all child records will be deleted as well.
--By default (if you don’t specify the ON DELETE clause), the database will not let you delete parent records if a child record exists.

--Example
--CREATE TABLE employee (
--  employee_id NUMBER(10),
--  first_name VARCHAR2(200),
--  last_name VARCHAR2(200),
--  salary NUMBER(10),
--  hire_date DATE,
--  department_id NUMBER(10),
--  CONSTRAINT fk_emp_deptid
--  FOREIGN KEY (department_id)
--  REFERENCES department(dept_id)
--  ON DELETE CASCADE
--);

--CREATE TABLE employee (
--  employee_id NUMBER(10),
--  first_name VARCHAR2(200),
--  last_name VARCHAR2(200),
--  salary NUMBER(10),
--  hire_date DATE,
--  department_id NUMBER(10),
--  CONSTRAINT fk_emp_deptid
--  FOREIGN KEY (department_id)
--  REFERENCES department(dept_id)
--  ON DELETE SET NULL
--);



ALTER TABLE employee
ADD CONSTRAINT FK_department_id
FOREIGN KEY (department_id) REFERENCES department(department_id)
ON DELETE SET NULL;


select* from employee
select* from department

--Commenting in the middle of query
delete from department
/*department is the table*/
where department_id = 1


--SQL Alias, it is "AS", and some examples
--Some examples are:

--employee e
--employee emp
--product p
--product pr
--customer c
--customer cust
--bill_usage_line_items bli


select* from employee

alter table employee
add salary int 

DELETE FROM employee
WHERE salary IS NOT NULL;

Select Distinct job_role
from employee


Update employee
SET salary = 150000
where job_role = 'CEO'

UPDATE employee
SET salary = 
    CASE 
        WHEN job_role = 'CIO' THEN 150000
		WHEN job_role = 'CE)' THEN 160000
        WHEN job_role = 'Development manager' THEN 120000
        WHEN job_role = 'Back-End Developer' THEN 110000
		WHEN job_role = 'Front-End Developer' THEN 105000
		WHEN job_role = 'HR Manager' THEN 90000
		WHEN job_role = 'HR Representative' THEN 80000
		WHEN job_role = 'Sales Manager' THEN 130000
		WHEN job_role = 'Salesperson' THEN 110000
		WHEN job_role = 'Support' THEN 80000
		WHEN job_role = 'Support Manager' THEN 90000
    END;



Update employee
SET salary = 150000
where employee_id = 1;

--Finding people who is more then AVG
SELECT employee_id, full_name, salary
FROM employee
WHERE salary > (Select AVG(salary) from employee);

--VS with the query above

SELECT employee_id, full_name, salary
FROM employee
GROUP BY employee_id, full_name, salary
HAVING AVG(salary) > 100000;



SELECT department_id, AVG(salary)
FROM employee
WHERE salary > (Select AVG(salary) from employee)
GROUP by department_id;


--matching several values in a subquery by using an IN operator
SELECT employee_id, full_name, salary
FROM employee
WHERE salary IN (120000, 150000);


-- Using 'IN" operator

SELECT employee_id, full_name, salary
FROM employee
WHERE salary IN (
  SELECT salary
FROM employee
WHERE full_name LIKE 'C%'
);


--Subqueries in a FROM Clause
SELECT department_id, avg_salary
FROM (
  SELECT department_id, ROUND(AVG(salary), 2) AS avg_salary
  FROM employee
  GROUP BY department_id
);

--HOW TOP keyword works 
SELECT TOP 3 full_name, job_role, salary
FROM employee
ORDER BY salary DESC;


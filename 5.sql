CREATE TABLE JOB_PROFILE(
    emp_id NUMBER PRIMARY KEY,
    Emp_Name VARCHAR2(50) NOT NULL,
    Emp_Sal NUMBER CHECK (Emp_Sal > 0) NOT NULL,
    Job_ID VARCHAR2(30) UNIQUE,
    Dept_No NUMBER
    );
    
 CREATE TABLE CUSTOMER (
    Cust_ID NUMBER PRIMARY KEY,
    Cust_Name VARCHAR2(50) NOT NULL,
    Branch VARCHAR2(50) NOT NULL);
 
 
INSERT INTO JOB_PROFILE (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (101, 'Aman', 3000, 'FI_ACC', 20 );
INSERT INTO JOB_PROFILE (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (102, 'Adama', 2500, 'MK_MGR', 10 );
INSERT INTO JOB_PROFILE (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (103, 'Anita', 5000, 'IT_PROG', 30);
INSERT INTO JOB_PROFILE (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (104, 'Anamika', 2975, 'LEC', 15 );
INSERT INTO JOB_PROFILE (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (105, 'Snehal', 1600, 'COMP_OP', 25);

ALTER TABLE CUSTOMER DROP COLUMN BRANCH;

INSERT INTO Customer (Cust_ID, Cust_Name )
VALUES (201, 'Anil', 'Andheri');
INSERT INTO Customer (Cust_ID, Cust_Name )
VALUES (202, 'Sunil', 'Virar');
INSERT INTO Customer (Cust_ID, Cust_Name )
VALUES (203, 'Keyur', 'Dadar');
INSERT INTO Customer (Cust_ID, Cust_Name )
VALUES (204, 'Vijay', 'Borivali');

SELECT * FROM JOB_PROFILE;
SELECT * FROM CUSTOMER;

--1
SELECT AVG(Emp_Sal) AS Average_Salary
FROM JOB_PROFILE;

--1.1
SELECT AVG(DISTINCT Emp_Sal) AS Distinct_Average_Salary
FROM JOB_PROFILE;

--2
SELECT MIN(Emp_Sal) AS Min_Salary
FROM JOB_PROFILE;


--3
SELECT COUNT(*) AS Total_Employees
FROM JOB_PROFILE;
 
 --3.1
SELECT COUNT(DISTINCT Dept_No) AS Distinct_Departments
FROM JOB_PROFILE;

--4
SELECT MAX(Emp_Sal) AS Max_Salary
FROM JOB_PROFILE;

--5
SELECT SUM(Emp_Sal) AS Total_Salary
FROM JOB_PROFILE;

--5.1
SELECT SUM(DISTINCT Emp_Sal) AS Distinct_Salary
FROM JOB_PROFILE;


--6
SELECT emp_id, Emp_Name, Emp_Sal, ABS(Emp_Sal - 1000) AS Abs_Diff_From_1000
FROM JOB_PROFILE;

--7
SELECT emp_id, Emp_Name, Emp_Sal, POWER(Emp_Sal, 2) AS Salary_Squared
FROM JOB_PROFILE;

--8
SELECT emp_id, Emp_Name, Emp_Sal, ROUND(Emp_Sal, 2) AS Rounded_Salary
FROM JOB_PROFILE;

--9
    SELECT emp_id, Emp_Name, Emp_Sal, SQRT(Emp_Sal) AS Salary_Square_Root
    FROM JOB_PROFILE;

--
--10.1
SELECT emp_id, Emp_Name, LOWER(Emp_Name) AS Lowercase_Name
FROM JOB_PROFILE;

--10.2
SELECT emp_id, Emp_Name, UPPER(Emp_Name) AS Uppercase_Name
FROM JOB_PROFILE;

--10.3
SELECT emp_id, Emp_Name, INITCAP(Emp_Name) AS InitialCaps_Name
FROM JOB_PROFILE;

--11
SELECT emp_id, Emp_Name, SUBSTR(Emp_Name, 1, 3) AS First_Three_Chars
FROM JOB_PROFILE;

--12
SELECT emp_id, Emp_Name, LENGTH(Emp_Name) AS Name_Length
FROM JOB_PROFILE;

--13
SELECT emp_id, Emp_Name, 
       REPLACE(REPLACE(Emp_Name, 'A', ''), 'a', '') AS Modified_Name
FROM JOB_PROFILE;

--14
SELECT emp_id, Emp_Name, 
       LPAD(RPAD(Emp_Name, 10, '*'), 10, '*') AS Padded_Name
FROM JOB_PROFILE;
 
 
 --
 --15
SELECT emp_id, Emp_Name, Emp_Sal, TO_NUMBER(Emp_Sal) AS Numeric_Salary
FROM JOB_PROFILE;


--16
SELECT emp_id, Emp_Name, Emp_Sal, TO_CHAR(Emp_Sal, '999,999,999.00') AS Formatted_Salary
FROM JOB_PROFILE;

--
--17
SELECT CURRENT_DATE AS Current_Date, ADD_MONTHS(CURRENT_DATE, 6) AS Date_After_6_Months
FROM dual;

--18
SELECT CURRENT_DATE AS Current_Date, LAST_DAY(CURRENT_DATE) AS Last_Day_Of_Month
FROM dual;

--19
SELECT MONTHS_BETWEEN(DATE '2025-07-01', DATE '2025-01-01') AS Months_Between
FROM dual;

 --20
SELECT CURRENT_DATE AS Current_Date, NEXT_DAY(CURRENT_DATE, 'MONDAY') AS Next_Monday
FROM dual;

--
--21
SELECT Emp_Name AS First_Name
FROM JOB_PROFILE
UNION
SELECT Cust_Name AS First_Name
FROM CUSTOMER;

--22
SELECT Emp_Name AS First_Name
FROM JOB_PROFILE
UNION ALL
SELECT Cust_Name AS First_Name
FROM CUSTOMER;

--23
SELECT Emp_Name AS First_Name
FROM JOB_PROFILE
INTERSECT
SELECT Cust_Name AS First_Name
FROM CUSTOMER;


--24
SELECT Emp_Name AS First_Name
FROM JOB_PROFILE
MINUS
SELECT Cust_Name AS First_Name
FROM CUSTOMER;

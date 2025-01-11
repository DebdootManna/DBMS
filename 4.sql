--1
-- Step 1: Creating Employee and Customer schemas with constraints

DROP TABLE Employee;
CREATE TABLE Employee (
    emp_id NUMBER PRIMARY KEY,
    Emp_Name VARCHAR2(50) NOT NULL,
    Emp_Sal NUMBER CHECK (Emp_Sal > 0) NOT NULL,
    Job_ID VARCHAR2(30) UNIQUE,
    Dept_No NUMBER,
    Phone CHAR(10)
);

DROP TABLE Customer;
CREATE TABLE Customer (
    Cust_ID NUMBER PRIMARY KEY,
    Cust_Name VARCHAR2(50) NOT NULL,
    Branch VARCHAR2(50) NOT NULL
);

-- Inserting sample data into Employee table
INSERT INTO Employee (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (101, 'Aman', 3000, 'FI_ACC', 20, '1234567890');
INSERT INTO Employee (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (102, 'Adama', 2500, 'MK_MGR', 10, '2345678901');
INSERT INTO Employee (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (103, 'Anita', 5000, 'IT_PROG', 30, '3456789012');
INSERT INTO Employee (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (104, 'Anamika', 2975, 'LEC', 15, '4567890123');
INSERT INTO Employee (emp_id, Emp_Name, Emp_Sal, Job_ID, Dept_No)
VALUES (105, 'Snehal', 1600, 'COMP_OP', 25, NULL);

-- Inserting sample data into Customer table
INSERT INTO Customer (Cust_ID, Cust_Name, Branch)
VALUES (201, 'Anil', 'Andheri');
INSERT INTO Customer (Cust_ID, Cust_Name, Branch)
VALUES (202, 'Sunil', 'Virar');
INSERT INTO Customer (Cust_ID, Cust_Name, Branch)
VALUES (203, 'Keyur', 'Dadar');
INSERT INTO Customer (Cust_ID, Cust_Name, Branch)
VALUES (204, 'Vijay', 'Borivali');

-- Task Queries

-- 1. Retrieve employees whose names start with 'A' or have 'a' as the third character
SELECT * FROM Employee
WHERE Emp_Name LIKE 'A%' OR SUBSTR(Emp_Name, 3, 1) = 'a';

-- 2. Retrieve employees whose names are exactly 5 characters long and start with 'Ani'
SELECT Emp_Name, emp_id, Emp_Sal FROM Employee
WHERE LENGTH(Emp_Name) = 5 AND Emp_Name LIKE 'Ani%';

-- 1. Retrieve employees whose second character is 'M' or 'N'
SELECT * FROM Employee
WHERE SUBSTR(Emp_Name, 2, 1) IN ('m', 'n');

-- 2. Retrieve employees whose second character is 'n' and names are exactly 5 characters long
SELECT * FROM Employee
WHERE LENGTH(Emp_Name) = 5 AND SUBSTR(Emp_Name, 2, 1) = 'n';

-- 3. Identify employees with incomplete details and third character as 'a'
SELECT * FROM Employee
WHERE (Emp_Sal IS NULL OR Phone IS NULL) AND SUBSTR(Emp_Name, 3, 1) = 'a';


-- 1. Retrieve names of customers in 'Andheri', 'Dadar', or 'Virar'
SELECT CUST_NAME FROM CUSTOMER
WHERE BRANCH IN('Andheri','Virar','Dadar');

-- 1. Retrieve job titles with Job_IDs starting with 'FI_'
SELECT Job_ID FROM Job
WHERE Job_ID LIKE 'FI_%';

-- 2. Retrieve job titles ending with '_MGR' and max salary > 12000
SELECT job_title FROM Job
WHERE job_title LIKE '%_MGR' AND max_sal > 12000;

-- Final Verification Queries
SELECT * FROM Employee;
SELECT * FROM Customer;


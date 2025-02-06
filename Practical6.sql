-------------------------------------------------------------------------------6


-- Step 1: Drop the Product table if it already exists to avoid duplication
DROP TABLE Product CASCADE CONSTRAINTS;

-- Step 2: Create the Product table with proper constraints
CREATE TABLE Product (
    Detorder_no VARCHAR2(10),                -- Order number for the product
    Product_no VARCHAR2(10) NOT NULL,       -- Product number (must not be NULL)
    Qty_order NUMBER(10) CHECK (Qty_order > 0), -- Quantity ordered (must be positive)
    CONSTRAINT PK_Product PRIMARY KEY (Detorder_no, Product_no) -- Composite Primary Key
);

-- Step 3: Insert the given data into the Product table
-- Insert row 1
INSERT INTO Product (Detorder_no, Product_no, Qty_order) 
VALUES ('O19001', 'P00001', 10);

-- Insert row 2
INSERT INTO Product (Detorder_no, Product_no, Qty_order) 
VALUES ('O19001', 'P00002', 3);

-- Insert row 3
INSERT INTO Product (Detorder_no, Product_no, Qty_order) 
VALUES ('O19002', 'P00001', 4);

-- Insert row 4
INSERT INTO Product (Detorder_no, Product_no, Qty_order) 
VALUES ('O19003', 'P00004', 2);

-- Insert row 5
INSERT INTO Product (Detorder_no, Product_no, Qty_order) 
VALUES ('O19004', 'P00003', 6);

-- Insert row 6
INSERT INTO Product (Detorder_no, Product_no, Qty_order) 
VALUES ('O19005', 'P00005', 2);

-- Insert row 7
INSERT INTO Product (Detorder_no, Product_no, Qty_order) 
VALUES ('O19006', 'P00004', 7);

-- Step 4: Display all rows from the Product table to verify the data
SELECT * FROM Product;


SELECT Product_no, SUM(Qty_order) AS Total_Quantity
FROM Product
GROUP BY Product_no;


SELECT Product_no, SUM(Qty_order) AS Total_Quantity
FROM Product
WHERE Product_no IN ('P00001', 'P00004')
GROUP BY Product_no;



-- Create emp_company table
CREATE TABLE emp_company (
    ENAME VARCHAR(50) NOT NULL UNIQUE,
    CNAME VARCHAR(50) NOT NULL,
    SALARY INT NOT NULL CHECK (SALARY > 0)
);

-- Insert employee data
INSERT INTO emp_company (ENAME, CNAME, SALARY) 
VALUES ('Anil', 'ACC', 1500);

INSERT INTO emp_company (ENAME, CNAME, SALARY) 
VALUES ('Shankar', 'TATA', 2000);

INSERT INTO emp_company (ENAME, CNAME, SALARY) 
VALUES ('Jay', 'WIPRO', 1800);

INSERT INTO emp_company (ENAME, CNAME, SALARY) 
VALUES ('Sunil', 'WIPRO', 1700);

INSERT INTO emp_company (ENAME, CNAME, SALARY) 
VALUES ('Vijay', 'TATA', 5000);

INSERT INTO emp_company (ENAME, CNAME, SALARY) 
VALUES ('Prakash', 'TATA', 3000);

INSERT INTO emp_company (ENAME, CNAME, SALARY) 
VALUES ('Ajay', 'ACC', 8000);

INSERT INTO emp_company (ENAME, CNAME, SALARY) 
VALUES ('Abhay', 'ACC', 1800);


-- Test Case 1: Display all rows from the emp_company table
SELECT * FROM emp_company;

-- Test Case 2: Maximum salary per company
SELECT CNAME, MAX(SALARY) AS Max_Salary
FROM emp_company
GROUP BY CNAME;

-- Test Case 3: Average salary per company
SELECT CNAME, AVG(SALARY) AS Avg_Salary
FROM emp_company
GROUP BY CNAME;

-- Task 4: List names of companies with an average salary greater than ?1,500
SELECT CNAME
FROM emp_company
GROUP BY CNAME
HAVING AVG(SALARY) > 1500;

-- Task 5: Calculate the average salary for each company except 'ACC'
SELECT CNAME, AVG(SALARY) AS Avg_Salary
FROM emp_company
WHERE CNAME != 'ACC'
GROUP BY CNAME
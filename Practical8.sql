-------------------------------------------------------------------------------8
-- 1. Creating the Salespeople Table
CREATE TABLE Salespeople (
    Snum NUMBER PRIMARY KEY,          -- Salesperson ID (Primary Key)
    Sname VARCHAR2(100) NOT NULL,     -- Salesperson Name (Not Null)
    City VARCHAR2(100),               -- City (Nullable)
    Comm NUMBER                       -- Commission Rate (Nullable)
);

-- Test Cases for Salespeople Table
-- Insert valid records
INSERT INTO Salespeople (Snum, Sname, City, Comm) VALUES (1, 'John Doe', 'New York', 0.15);
INSERT INTO Salespeople (Snum, Sname) VALUES (2, 'Jane Smith'); -- Null City and Comm allowed

-- Attempt to insert duplicate Snum (should fail)
-- INSERT INTO Salespeople (Snum, Sname) VALUES (1, 'Alice Brown'); -- This will fail due to primary key constraint

-- Attempt to insert null Sname (should fail)
-- INSERT INTO Salespeople (Snum) VALUES (3); -- This will fail due to NOT NULL constraint on Sname

-- Retrieve all records to verify data integrity
SELECT * FROM Salespeople;

-- 2. Creating the Customer Table
CREATE TABLE Customer (
    Cnum NUMBER PRIMARY KEY,          -- Customer ID (Primary Key)
    Cname VARCHAR2(100) NOT NULL,     -- Customer Name (Not Null)
    City VARCHAR2(100),               -- City (Nullable)
    Rating NUMBER DEFAULT 10,         -- Customer Rating (Default: 10)
    Snum NUMBER,                      -- Salesperson ID (Foreign Key)
    CONSTRAINT fk_salespeople FOREIGN KEY (Snum) REFERENCES Salespeople(Snum)
);

-- Test Cases for Customer Table
-- Insert valid records
INSERT INTO Customer (Cnum, Cname, Snum) VALUES (101, 'Customer A', 1); -- Default Rating applied
INSERT INTO Customer (Cnum, Cname, City, Rating, Snum) VALUES (102, 'Customer B', 'Los Angeles', 8, 2);

-- Insert record with missing Rating (default value should be applied)
INSERT INTO Customer (Cnum, Cname, Snum) VALUES (103, 'Customer C', 1);

-- Attempt to insert null Cname (should fail)
-- INSERT INTO Customer (Cnum) VALUES (104); -- This will fail due to NOT NULL constraint on Cname

-- Attempt to insert record with non-existent Snum (should fail)
-- INSERT INTO Customer (Cnum, Cname, Snum) VALUES (105, 'Customer D', 99); -- This will fail due to foreign key constraint

-- Retrieve all records to verify data integrity
SELECT * FROM Customer;

-- 3. Creating the Order Table
CREATE TABLE Orders (
    Order_no NUMBER PRIMARY KEY,      -- Order Number (Primary Key)
    Amount NUMBER,                    -- Order Amount (Nullable)
    Odate DATE,                       -- Order Date (Nullable)
    Cnum NUMBER,                      -- Customer ID (Foreign Key)
    Snum NUMBER,                      -- Salesperson ID (Foreign Key)
    CONSTRAINT fk_customer FOREIGN KEY (Cnum) REFERENCES Customer(Cnum),
    CONSTRAINT fk_salespeople_order FOREIGN KEY (Snum) REFERENCES Salespeople(Snum)
);

-- Test Cases for Order Table
-- Insert valid records
INSERT INTO Orders (Order_no, Amount, Odate, Cnum, Snum) VALUES (1001, 500, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 101, 1);
INSERT INTO Orders (Order_no, Cnum, Snum) VALUES (1002, 102, 2); -- Null Amount and Odate allowed

-- Attempt to insert records with non-existent Cnum or Snum (should fail)
-- INSERT INTO Orders (Order_no, Cnum, Snum) VALUES (1003, 999, 1); -- This will fail due to foreign key constraint
-- INSERT INTO Orders (Order_no, Cnum, Snum) VALUES (1004, 101, 99); -- This will fail due to foreign key constraint

-- Retrieve all records to verify data integrity
SELECT * FROM Orders;

-- 4. Creating the Sales_order Table
CREATE TABLE Sales_order (
    Order_no VARCHAR2(10) PRIMARY KEY CHECK (Order_no LIKE 'O%'), -- Order Number (Primary Key, must start with 'O')
    Order_date DATE NOT NULL,                                     -- Order Date (Not Null)
    Client_no VARCHAR2(10),                                       -- Client ID (Foreign Key)
    Dely_addr VARCHAR2(200),                                      -- Delivery Address
    Salesman_no VARCHAR2(10),                                     -- Salesperson ID (Foreign Key)
    Dely_type CHAR(1) DEFAULT 'F',                                -- Delivery Type (Default: 'F')
    Order_status VARCHAR2(20) CHECK (Order_status IN ('In Process', 'Fulfilled', 'Backorder', 'Cancelled')) -- Order Status (Allowed Values)
);

-- Test Cases for Sales_order Table
-- Insert valid records
INSERT INTO Sales_order (Order_no, Order_date, Client_no, Dely_addr, Salesman_no, Order_status) 
VALUES ('O1001', TO_DATE('2023-10-01', 'YYYY-MM-DD'), 'C101', '123 Main St', 'S001', 'In Process');

-- Attempt to insert invalid Order_no (should fail)
-- INSERT INTO Sales_order (Order_no, Order_date) VALUES ('X1002', TO_DATE('2023-10-02', 'YYYY-MM-DD')); -- This will fail due to check constraint

-- Attempt to insert invalid Order_status (should fail)
-- INSERT INTO Sales_order (Order_no, Order_date, Order_status) VALUES ('O1002', TO_DATE('2023-10-02', 'YYYY-MM-DD'), 'Invalid Status'); -- This will fail due to check constraint

-- Retrieve all records to verify data integrity
SELECT * FROM Sales_order;

-- 5. Creating the Salesman_master Table
CREATE TABLE Salesman_master (
    Salesman_no VARCHAR2(10) PRIMARY KEY CHECK (Salesman_no LIKE 'S%'), -- Salesman Number (Primary Key, must start with 'S')
    Salesman_name VARCHAR2(100) NOT NULL,                               -- Salesman Name (Not Null)
    Address VARCHAR2(200),                                              -- Address
    City VARCHAR2(100),                                                 -- City
    Pincode VARCHAR2(10),                                               -- Pincode
    State VARCHAR2(50),                                                 -- State
    Sal_amt NUMBER NOT NULL CHECK (Sal_amt > 0),                        -- Salary (Not Null, cannot be 0)
    Ytd_sales NUMBER NOT NULL CHECK (Ytd_sales > 0),                    -- Year-to-date Sales (Not Null, cannot be 0)
    Tgt_sales NUMBER NOT NULL                                           -- Target Sales (Not Null)
);

-- Test Cases for Salesman_master Table
-- Insert valid records
INSERT INTO Salesman_master (Salesman_no, Salesman_name, Sal_amt, Ytd_sales, Tgt_sales) 
VALUES ('S001', 'John Doe', 5000, 100000, 200000);

-- Attempt to insert invalid Sal_amt or Ytd_sales (should fail)
-- INSERT INTO Salesman_master (Salesman_no, Salesman_name, Sal_amt, Ytd_sales, Tgt_sales) 
-- VALUES ('S002', 'Jane Smith', 0, 100000, 200000); -- This will fail due to check constraint on Sal_amt

-- Retrieve all records to verify data integrity
SELECT * FROM Salesman_master;

-- 6. Creating the Client_master Table
CREATE TABLE Client_master (
    Client_no VARCHAR2(10) PRIMARY KEY CHECK (Client_no LIKE 'C%'), -- Client Number (Primary Key, must start with 'C')
    Name VARCHAR2(100) NOT NULL,                                    -- Client Name (Not Null)
    Address VARCHAR2(200),                                          -- Address
    City VARCHAR2(100),                                             -- City
    State VARCHAR2(50),                                             -- State
    Pincode VARCHAR2(10),                                           -- Pincode
    Bal_due NUMBER                                                  -- Balance Due
);

-- Test Cases for Client_master Table
-- Insert valid records
INSERT INTO Client_master (Client_no, Name, Bal_due) VALUES ('C101', 'Client A', 1000);

-- Attempt to insert invalid Client_no (should fail)
-- INSERT INTO Client_master (Client_no, Name) VALUES ('X101', 'Client B'); -- This will fail due to check constraint

-- Retrieve all records to verify data integrity
SELECT * FROM Client_master;
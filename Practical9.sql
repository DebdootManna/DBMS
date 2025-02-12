-- Create Sales_People table
CREATE TABLE Sales_People (
    Snum INT PRIMARY KEY,  -- Salesperson ID (Primary Key)
    Sname VARCHAR(100) NOT NULL,  -- Salesperson Name (Not Null)
    City VARCHAR(100),  -- City (Nullable)
    Comm DECIMAL(5,2)  -- Commission Rate (Nullable)
);

-- Insert data into Sales_People table
INSERT INTO Sales_People (Snum, Sname, City, Comm) VALUES (1001, 'Peel', 'London', 0.12);
INSERT INTO Sales_People (Snum, Sname, City, Comm) VALUES (1002, 'Serres', 'San Jose', 0.13);
INSERT INTO Sales_People (Snum, Sname, City, Comm) VALUES (1003, 'Motika', 'London', 0.11);
INSERT INTO Sales_People (Snum, Sname, City, Comm) VALUES (1004, 'Rifkin', 'Barcelona', 0.15);
INSERT INTO Sales_People (Snum, Sname, City, Comm) VALUES (1005, 'Axelord', 'New York', 0.10);

-- Verify Sales_People table data
SELECT * FROM Sales_People;

-- Drop the Customer1 table if it exists
DROP TABLE Customer1;

-- Create Customer1 table
CREATE TABLE Customer1 (
    Cnum NUMBER PRIMARY KEY,  -- Customer ID (Primary Key)
    Cname VARCHAR2(100) NOT NULL,  -- Customer Name (Not Null)
    City VARCHAR2(100),  -- City (Nullable)
    Rating NUMBER DEFAULT 10,  -- Rating with default value
    Snum NUMBER,  -- Salesperson ID (Foreign Key)
    CONSTRAINT fk_Sales_person FOREIGN KEY (Snum) REFERENCES Sales_People(Snum) -- Foreign Key constraint
);

-- Insert data into Customer1 table
INSERT INTO Customer1 (Cnum, Cname, City, Rating, Snum) VALUES (2001, 'Hoffman', 'London', 100, 1001);
INSERT INTO Customer1 (Cnum, Cname, City, Rating, Snum) VALUES (2002, 'Giovance', 'Rome', 200, 1003);
INSERT INTO Customer1 (Cnum, Cname, City, Rating, Snum) VALUES (2003, 'Liu', 'San Jose', 300, 1002);
INSERT INTO Customer1 (Cnum, Cname, City, Rating, Snum) VALUES (2004, 'Grass', 'Berlin', 100, 1002);
INSERT INTO Customer1 (Cnum, Cname, City, Rating, Snum) VALUES (2006, 'Clemens', 'London', 300, 1005); -- Corrected to reference existing Salesperson (1005)
INSERT INTO Customer1 (Cnum, Cname, City, Rating, Snum) VALUES (2007, 'Pereira', 'Rome', 100, 1004);

-- Verify Customer1 table data
SELECT * FROM Customer1;

-- Drop the Order table if it exists (to ensure we start fresh)
DROP TABLE Order;

-- Create the Order table
CREATE TABLE Order_T (
    Order_no NUMBER PRIMARY KEY, -- Primary key for the table
    Amount NUMBER, -- Amount of the order
    Odate DATE, -- Order date
    Cnum NUMBER, -- Customer number (foreign key)
    Snum NUMBER, -- Salesperson number (foreign key)
    CONSTRAINT fk_Customer1_Order FOREIGN KEY (Cnum) REFERENCES Customer1(Cnum), -- Foreign Key constraint for Customer1
    CONSTRAINT fk_Sales_People_Order FOREIGN KEY (Snum) REFERENCES Sales_People(Snum) -- Foreign Key constraint for Sales_People
);

-- Verify that the Order table is created
SELECT * FROM Order_T;



INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3001, 18.96, TO_DATE('10-03-1994', 'DD-MM-YYYY'), 2002, 1002);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3003, 767.19, TO_DATE('10-03-1994', 'DD-MM-YYYY'), 2001, 1001);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3002, 1900.10, TO_DATE('10-03-1994', 'DD-MM-YYYY'), 2007, 1003);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3005, 5160.45, TO_DATE('10-03-1994', 'DD-MM-YYYY'), 2003, 1002);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3006, 1098.16, TO_DATE('10-03-1994', 'DD-MM-YYYY'), 2008, 1002);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3009, 1713.23, TO_DATE('10-04-1994', 'DD-MM-YYYY'), 2002, 1003);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3007, 75.75, TO_DATE('10-04-1994', 'DD-MM-YYYY'), 2001, 1001);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3008, 4723.95, TO_DATE('10-05-1994', 'DD-MM-YYYY'), 2006, 1002);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3010, 1309.95, TO_DATE('10-06-1994', 'DD-MM-YYYY'), 2004, 1002);
INSERT INTO Order_T (Order_no, Amount, Odate, Cnum, Snum) VALUES (3011, 9891.00, TO_DATE('10-06-1994', 'DD-MM-YYYY'), 2006, 1001);

SELECT * FROM Order_T;
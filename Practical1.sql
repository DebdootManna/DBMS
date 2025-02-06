-----------------------------------------------------------------------------1.1

-- Creating the Job table
CREATE TABLE Job (
    job_id VARCHAR2(15),
    job_title VARCHAR2(30),
    min_sal NUMBER(7,2),
    max_sal NUMBER(7,2)
);

-- Inserting values into the Job table
INSERT INTO Job (job_id, job_title, min_sal, max_sal) 
VALUES('IT_PROG', 'Programmer', 4000, 10000);
INSERT INTO Job (job_id, job_title, min_sal, max_sal) 
values('MK_MGR', 'Marketing Manager', 9000, 15000);
INSERT INTO Job (job_id, job_title, min_sal, max_sal) 
VALUES('FI_MGR', 'Finance Manager', 8200, 12000);
INSERT INTO Job (job_id, job_title, min_sal, max_sal)
VALUES('FI_ACC', 'Account', 4200, 9000);
INSERT INTO Job (job_id, job_title, min_sal, max_sal)
VALUES('LEC', 'Lecturer', 6000, 17000);
INSERT INTO Job (job_id, job_title, min_sal, max_sal)
VALUES('COMP_OP', 'Computer Operator', 1500, 13000);

SELECT * FROM Job;


-----------------------------------------------------------------------------1.2

-- Creating the Employee table
CREATE TABLE Employee (
    emp_no NUMBER(10),
    emp_name VARCHAR2(30),
    emp_sal NUMBER(8,2),
    emp_comm NUMBER(8,2),
    dept_no NUMBER(8,2)
);

-- Inserting values into the Employee table
INSERT INTO Employee (emp_no, emp_name, emp_sal, emp_comm, dept_no)
VALUES(101, 'Smith', 800, 455, 20);
INSERT INTO Employee (emp_no, emp_name, emp_sal, emp_comm, dept_no)
VALUES(102, 'Snehal', 1600, 0, 25);
INSERT INTO Employee (emp_no, emp_name, emp_sal, emp_comm, dept_no)
VALUES(103, 'Adama', 1100, 425, 20);
INSERT INTO Employee (emp_no, emp_name, emp_sal, emp_comm, dept_no)
VALUES(104, 'Aman', 3000, NULL, 15);
INSERT INTO Employee (emp_no, emp_name, emp_sal, emp_comm, dept_no)
VALUES(105, 'Anita', 5000, 50000, 10);
INSERT INTO Employee (emp_no, emp_name, emp_sal, emp_comm, dept_no)
VALUES(106, 'Anamika', 2975, NULL, 30);

SELECT * FROM Employee;

-----------------------------------------------------------------------------1.3

-- Creating the Deposit table
CREATE TABLE Deposit (
    a_no VARCHAR2(15),
    cname VARCHAR2(15),
    bname VARCHAR2(15),
    amount NUMBER(10,2),
    a_date DATE
);

-- Inserting values into the Deposit table
INSERT INTO Deposit (a_no, cname, bname, amount, a_date)
VALUES('101', 'Anil', 'Andheri', 7000, TO_DATE('01-JAN-06', 'DD-MON-YY'));
INSERT INTO Deposit (a_no, cname, bname, amount, a_date)
VALUES('102', 'Sunil', 'Virar', 5000, TO_DATE('15-JUL-06', 'DD-MON-YY'));
INSERT INTO Deposit (a_no, cname, bname, amount, a_date)
VALUES('103', 'Jay', 'Villeparle', 6500, TO_DATE('12-MAR-06', 'DD-MON-YY'));
INSERT INTO Deposit (a_no, cname, bname, amount, a_date)
VALUES('104', 'Vijay', 'Andheri', 8000, TO_DATE('17-SEP-06', 'DD-MON-YY'));
INSERT INTO Deposit (a_no, cname, bname, amount, a_date)
VALUES('105', 'Keyur', 'Dadar', 7500, TO_DATE('19-NOV-06', 'DD-MON-YY'));
INSERT INTO Deposit (a_no, cname, bname, amount, a_date)
VALUES('106', 'Mayur', 'Borivali', 5500, TO_DATE('21-DEC-06', 'DD-MON-YY'));

SELECT * FROM Deposit;

-----------------------------------------------------------------------------1.4

-- Creating the Borrow table
CREATE TABLE Borrow (
    loanno VARCHAR2(15),
    cname VARCHAR2(15),
    bname VARCHAR2(15),
    amount NUMBER(10,2)
);

-- Inserting values into the Borrow table
INSERT INTO Borrow (loanno, cname, bname, amount)
VALUES('201', 'Anil', 'VRCE', 1000.00);
INSERT INTO Borrow (loanno, cname, bname, amount)
VALUES('206', 'Mehul', 'AJNI', 5000.00);
INSERT INTO Borrow (loanno, cname, bname, amount)
VALUES('311', 'Sunil', 'Dharampeth', 3000.00);
INSERT INTO Borrow (loanno, cname, bname, amount)
VALUES('321', 'Madhuri', 'Andheri', 2000.00);
INSERT INTO Borrow (loanno, cname, bname, amount)
VALUES('375', 'Prmod', 'Virar', 8000.00);
INSERT INTO Borrow (loanno, cname, bname, amount)
VALUES('481', 'Kranti', 'Nehru Place', 3000.00);

SELECT * FROM Borrow;

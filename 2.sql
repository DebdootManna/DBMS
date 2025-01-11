CREATE TABLE Job (
    job_id varchar2(15) NOT NULL UNIQUE,
    job_title varchar2(30) NOT NULL,
    min_sal number(7,2) NOT NULL,
    max_sal number(7,2) NOT NULL
);

CREATE TABLE Employee (
    emp_no number(10) CONSTRAINT emp_no_pk PRIMARY KEY,
    emp_name varchar2(30) CONSTRAINT emp_name_nn NOT NULL,
    emp_sal number(8,2) CONSTRAINT emp_sal_chk CHECK (emp_sal > 0),
    emp_comm number(6,1) CONSTRAINT emp_comm_chk CHECK (emp_comm >= 0),
    dept_no number(3) CONSTRAINT dept_no_nn NOT NULL
);

CREATE TABLE Deposit (
    a_no varchar2(5) NOT NULL UNIQUE,
    cname varchar2(15) NOT NULL,
    bname varchar2(10) NOT NULL,
    amount number(7,2) NOT NULL,
    a_date date NOT NULL
);

CREATE TABLE Borrow (
    loanno varchar2(5) NOT NULL UNIQUE,
    cname varchar2(15) NOT NULL,
    bname varchar2(15) NOT NULL,
    amount number(7,2) NOT NULL
);
INSERT INTO Employee(emp_no,emp_name,emp_sal,emp_comm,dept_no)VALUES(101,'Smith',800,455,20);
INSERT INTO Employee(emp_no,emp_name,emp_sal,emp_comm,dept_no)VALUES(102,'Snehal',1600,0,25);
INSERT INTO Employee(emp_no,emp_name,emp_sal,emp_comm,dept_no)VALUES(103,'Adama',1100,425,20);
INSERT INTO Employee(emp_no,emp_name,emp_sal,dept_no)VALUES(104,'Aman',3000,15);
INSERT INTO Employee(emp_no,emp_name,emp_sal,emp_comm,dept_no)VALUES(105,'Anita',5000,50000,10);
INSERT INTO Employee(emp_no,emp_name,emp_sal,dept_no)VALUES(106,'Anamika',2975,30);

SELECT * FROM Employee;

INSERT INTO Job(Job_id,Job_title,min_sal,max_sal)VALUES('IT PROG','Programmer',4000,10000);
INSERT INTO Job(Job_id,Job_title,min_sal,max_sal)VALUES('MK MGR','Marketing Manager',9000,15000);
INSERT INTO Job(Job_id,Job_title,min_sal,max_sal)VALUES('FI MGR','Finance Manager',8200,12000);
INSERT INTO Job(Job_id,Job_title,min_sal,max_sal)VALUES('FI ACC','Account',4200,9000);
INSERT INTO Job(Job_id,Job_title,min_sal,max_sal)VALUES('LEC','Lecturer',6000,17000);
INSERT INTO Job(Job_id,Job_title,min_sal,max_sal)VALUES('COMP OP','Computer Operator',1500,13000);

SELECT * FROM Job;

INSERT INTO Deposit(a_no,cname,bname,amount,a_date)VALUES('101','Anil','andheri',7000,TO_DATE('01-01-2006','DD-MM-YYYY'));
INSERT INTO Deposit(a_no,cname,bname,amount,a_date)VALUES('102','sunil','virar',5000,TO_DATE('15-07-2006','DD-MM-YYYY'));
INSERT INTO Deposit(a_no,cname,bname,amount,a_date)VALUES('103','jay','villeparle',6500,TO_DATE('12-03-2006','DD-MM-YYYY'));
INSERT INTO Deposit(a_no,cname,bname,amount,a_date)VALUES('104','vijay','andheri',8000,TO_DATE('17-09-2006','DD-MM-YYYY'));
INSERT INTO Deposit(a_no,cname,bname,amount,a_date)VALUES('105','keyur','dadar',7500,TO_DATE('19-11-2006','DD-MM-YYYY'));
INSERT INTO Deposit(a_no,cname,bname,amount,a_date)VALUES('106','mayur','borivali',5500,TO_DATE('21-12-2006','DD-MM-YYYY'));

SELECT * FROM Deposit;

INSERT INTO Borrow(loanno,cname,bname,amount)VALUES('201','ANIL','VRCE',1000);
INSERT INTO Borrow(loanno,cname,bname,amount)VALUES('206','MEHUL','AJNI',5000);
INSERT INTO Borrow(loanno,cname,bname,amount)VALUES('311','SUNIL','DHARAMPETH',3000);
INSERT INTO Borrow(loanno,cname,bname,amount)VALUES('321','MADHURI','ANDHERI',2000);
INSERT INTO Borrow(loanno,cname,bname,amount)VALUES('375','PRMOD','VIRAR',8000);
INSERT INTO Borrow(loanno,cname,bname,amount)VALUES('481','KRANTI','NEHRU PLACE',3000);

SELECT * FROM Borrow;

--Q_1
DROP TABLE Employee
CREATE TABLE SUPPLIER AS SELECT * FROM EMPLOYEE;
DESCRIBE SUPPLIER;
SELECT * FROM SUPPLIER

CREATE TABLE SUP1 AS SELECT EMP_NO,EMP_NAME FROM EMPLOYEE;
DESCRIBE SUP1;
SELECT * FROM SUP1

CREATE TABLE SUP2 AS SELECT * FROM EMPLOYEE WHERE 1=0;
DESCRIBE SUP2
SELECT * FROM SUP2

INSERT INTO SUP2  select * FROM EMPLOYEE WHERE EMP_NAME='Anita';

ALTER TABLE SUP2 RENAME TO SUP_2;
SELECT * FROM SUP_2

DROP TABLE SUP1
DESCRIBE SUP1

ALTER TABLE EMPLOYEE ADD PHONE VARCHAR2(10);
SELECT * FROM EMPLOYEE
DESCRIBE EMPLOYEE

ALTER TABLE EMPLOYEE MODIFY PHONE CHAR(10)
DESCRIBE EMPLOYEE


ALTER TABLE SUP_2 DROP COLUMN EMP_NAME;
DESCRIBE SUP_2;

ALTER TABLE SUP_2 RENAME COLUMN EMP_SAL TO NEW_SAL;
DESCRIBE SUP_2;
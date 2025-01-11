CREATE TABLE Job (
    job_id varchar2(15) NOT NULL UNIQUE,
    job_title varchar2(30) NOT NULL,
    min_sal number(7,2) NOT NULL,
    max_sal number(7,2) NOT NULL
);

CREATE TABLE Employee (
    emp_no number(3) NOT NULL UNIQUE,
    emp_name varchar2(30) NOT NULL,
    emp_sal number(8,2) NOT NULL,
    emp_comm number(6,1),
    dept_no number(3) NOT NULL
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

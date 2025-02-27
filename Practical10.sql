
Declare 
num1 number;
num2 number;
total number;

begin
num1:= &num1;
num2:= &num2;
total:= num1*num2;

dbms_output.put_line('Total product of num1 and num2 is:' || total);
end;

-- Creating the procedure
CREATE OR REPLACE PROCEDURE my_procedure(in_num1 NUMBER, in_num2 NUMBER) 
AS 
BEGIN
    -- Procedure logic goes here
    DBMS_OUTPUT.PUT_LINE('The Product of two numbers is: ' || (in_num1 * in_num2));
END;
/

-- Anonymous block to call the procedure
DECLARE
    input_str1 NUMBER := &input_str1;
    input_str2 NUMBER := &input_str2;
BEGIN
    my_procedure(input_str1, input_str2);
END;
/

--Extra (Fetching data from table using PL/SQL block)
DECLARE
    EMP_NAME VARCHAR(30);
    EMP_SAL NUMBER;
BEGIN
    SELECT EMP_NAME, EMP_SAL
    INTO EMP_NAME, EMP_SAL
    FROM employee
    WHERE emp_id = 104;  

    dbms_output.put_line('Employee Name: ' || EMP_NAME);
    dbms_output.put_line('Salary: ' || EMP_SAL);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('No Employee found with the given ID.');
    WHEN OTHERS THEN
        dbms_output.put_line('ERROR: ' || SQLERRM);
END;


--Insert Operaration

DECLARE
    v_emp_id NUMBER := 109;  -- Change ID as per your table
    v_emp_name VARCHAR2(30) := 'John Doe';
    v_emp_salary NUMBER := 50000;
BEGIN
    -- Insert statement
    INSERT INTO EMPLOYEE (EMP_ID, EMP_NAME, EMP_SALARY) 
    VALUES (v_emp_id, v_emp_name, v_emp_salary);
    
    -- Commit the transaction to save changes
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Employee inserted successfully.');
    
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: Employee with this ID already exists.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

--Deleting operation 

DECLARE
    v_emp_id NUMBER := 109;  -- Change ID as per your table
BEGIN
    -- Delete statement
    DELETE FROM EMPLOYEE WHERE EMP_ID = v_emp_id;

    -- Check if any row was deleted
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No Employee found with the given ID.');
    ELSE
        COMMIT;  -- Commit only if a row was deleted
        DBMS_OUTPUT.PUT_LINE('Employee deleted successfully.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
select * from EMPLOYEE

CREATE OR REPLACE PACKAGE pkg_FurnitureShop 
IS
    salary_raise_multiplier NUMBER := 2;
    days_worked_loyalty_raise NUMBER := 3000;

    invalid_id EXCEPTION;
    noone_eligible EXCEPTION;
    
    CURSOR c_products(material_name materials.name%TYPE) IS
        SELECT DISTINCT p1.name AS product_name, m1.name AS material_name 
        FROM products p1
        INNER JOIN productscomposition pc1 ON p1.productId = pc1.productId
        INNER JOIN materials m1 ON pc1.materialId = m1.materialId
        WHERE m1.name = material_name;
        
    CURSOR c_emps IS
        SELECT * 
        FROM Employees;
        
    FUNCTION eligible_for_raise(
        empId_in employees.employeeId%TYPE)
        RETURN NUMBER; 
        
    FUNCTION employees_above_given_salary(
        salary_in employees.salary%TYPE)
        RETURN NUMBER;
        
    FUNCTION salary_time_worked_ratio(
        salary_in employees.salary%TYPE,
        hire_date_in employees.hire_date%TYPE) 
        RETURN FLOAT;
        
    FUNCTION valid_empId(
        empId_in employees.employeeId%TYPE) 
        RETURN BOOLEAN;
        
    PROCEDURE loyalty_raise;
        
    PROCEDURE hire_employee(
        empId_in employees.employeeId%TYPE, 
        first_in employees.first_name%TYPE, 
        last_in employees.last_name%TYPE, 
        pos_in employees.position%TYPE,
        salary_in employees.salary%TYPE,
        hir_date_in employees.hire_date%TYPE,
        phone_in employees.phone_number%TYPE,
        email_in employees.email%TYPE,
        managerId_in employees.managerId%TYPE);
        
    PROCEDURE fire_employee(
        empId_in employees.employeeId%TYPE);
        
    PROCEDURE products_description(
        material_name_in materials.name%TYPE);
        
END pkg_FurnitureShop;

CREATE OR REPLACE PACKAGE BODY pkg_FurnitureShop
IS
    
    FUNCTION eligible_for_raise (empId_in employees.employeeId%TYPE) RETURN NUMBER IS
        days_worked NUMBER;
    BEGIN
        SELECT sysdate - hire_date INTO days_worked FROM Employees WHERE employeeId = empId_in;
        IF days_worked >= days_worked_loyalty_raise THEN
            RETURN 1;
        ELSE 
            RETURN 0;
        END IF;
    END eligible_for_raise;
    
    FUNCTION salary_time_worked_ratio (salary_in employees.salary%TYPE, hire_date_in employees.hire_date%TYPE) RETURN FLOAT IS
        ratio FLOAT;
    BEGIN   
        ratio := salary_in / (sysdate - hire_date_in);
        RETURN ROUND(ratio, 2);
    END salary_time_worked_ratio;
    
    FUNCTION employees_above_given_salary(salary_in employees.salary%TYPE) RETURN NUMBER IS
        num_emps NUMBER;
    BEGIN
        SELECT COUNT(*) INTO num_emps FROM Employees WHERE salary > salary_in;
        RETURN num_emps;
    END employees_above_given_salary;
    
    FUNCTION valid_empId (empId_in employees.employeeId%TYPE) RETURN BOOLEAN IS
    BEGIN
        FOR emp IN c_emps LOOP
            IF empId_in = emp.employeeiD THEN
                RETURN FALSE;
            END IF;
        END LOOP;
        RETURN TRUE;
    END valid_empId;
    
    PROCEDURE loyalty_raise IS 
        row_count NUMBER := 0;
        CURSOR c_eligible_emps IS
            SELECT employeeId
            FROM Employees
            WHERE eligible_for_raise(employeeId) = 1;
    BEGIN
        FOR emp IN c_eligible_emps LOOP
            UPDATE Employees
            SET salary = salary + (salary * (salary_raise_multiplier / 100))
            WHERE employeeId = emp.employeeId;
            row_count := row_count + SQL%ROWCOUNT;
        END LOOP;
        IF row_count = 0 THEN
            RAISE noone_eligible;
        END IF;
    EXCEPTION
        WHEN noone_eligible THEN
            dbms_output.put_line('No employees affected');
    END loyalty_raise;
    
    PROCEDURE hire_employee(empId_in employees.employeeId%TYPE, 
        first_in employees.first_name%TYPE, 
        last_in employees.last_name%TYPE, 
        pos_in employees.position%TYPE,
        salary_in employees.salary%TYPE,
        hir_date_in employees.hire_date%TYPE,
        phone_in employees.phone_number%TYPE,
        email_in employees.email%TYPE,
        managerId_in employees.managerId%TYPE) IS
    BEGIN
        IF(valid_empId(empId_in)) THEN
            INSERT INTO employees
            (employeeId, first_name, last_name, position, salary, hire_date, phone_number, email, managerId)
             VALUES
            (empId_in, first_in, last_in, pos_in, salary_in, TO_DATE(hir_date_in, 'dd/mm/yyyy'), phone_in, email_in, managerId_in);
        ELSE 
            RAISE invalid_id;
        END IF;
    EXCEPTION 
        WHEN invalid_id THEN
            dbms_output.put_line('Id either incorrect or taken');
    END hire_employee;
    
    PROCEDURE fire_employee(empId_in employees.employeeId%TYPE) IS
    BEGIN
        DELETE Employees
        WHERE employeeId = empId_in;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE invalid_id;
        END IF;
        EXCEPTION
            WHEN invalid_id THEN
                dbms_output.put_line('Id is either invalid or no such employee exists');
    END fire_employee;
    
    PROCEDURE products_description(material_name_in materials.name%TYPE) IS 
    BEGIN   
        FOR product IN c_products(material_name_in) LOOP
            dbms_output.put_line('Product ' || product.product_name || ' contains the specified material: ' || product.material_name);
        END LOOP;
    END products_description;
        
END pkg_FurnitureShop;

-- Triggers
CREATE OR REPLACE TRIGGER tr_correct_salary
BEFORE INSERT OR UPDATE
ON employees
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_manager_salary employees.salary%TYPE;
BEGIN
    SELECT man.salary INTO v_manager_salary
    FROM employees e
    LEFT JOIN employees man
    ON e.managerid = man.employeeid
    WHERE e.employeeid = :old.employeeid;
    
    IF (v_manager_salary IS NOT NULL AND :NEW.salary > v_manager_salary)
    THEN
        raise_application_error(-20000
            , 'Employee cannot have higher salary than manager');
    END IF;
    
    COMMIT;
END;

CREATE OR REPLACE TRIGGER tr_positive_product_price_per_unit
BEFORE INSERT OR UPDATE
ON products
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF (:NEW.price_per_unit < 0)
    THEN
        raise_application_error(-20000
            , 'Price per unit of a product cannot be negative');
    END IF;
    
    COMMIT;
END;

CREATE OR REPLACE TRIGGER tr_positive_material_price_per_meter
BEFORE INSERT OR UPDATE
ON materials
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF (:NEW.price_per_m2 < 0)
    THEN
        raise_application_error(-20000
            , 'Price per meter2 of a material cannot be negative');
    END IF;
    
    COMMIT;
END;

--DECLARE
--BEGIN
--    pkg_furnitureshop.hire_employee(17, 'Jakub', 'Wandelt', 'Consultant', 12000, TO_DATE('23/04/2002', 'dd/mm/yyyy'), '333-333-333', 'jwandelt@wp.pl', 3);
--END;
--
--
DECLARE 
BEGIN 
    pkg_FurnitureShop.loyalty_raise;
END;
--
--DELETE employees
--WHERE employeeId = 11;
--
SELECT *
FROM employees;

CREATE OR REPLACE PACKAGE pkg_FurnitureShop 
IS
    salary_raise_multiplier NUMBER := 2;
    days_worked_loyalty_raise NUMBER := 3000;
    
    noone_eligible EXCEPTION;
    invalid_id EXCEPTION;
    
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
        RETURN BOOLEAN; 
        
    FUNCTION employees_above_given_salary(
        salary_in employees.salary%TYPE)
        RETURN NUMBER;
        
    FUNCTION salary_time_worked_ratio(
        salary_in employees.salary%TYPE,
        hire_date_in employees.hire_date%TYPE) 
        RETURN FLOAT;
--        
--    FUNCTION valid_empId(
--        empId_in employees.employeeId%TYPE) 
--        RETURN BOOLEAN;
--        
    PROCEDURE loyalty_raise;
--        
--    PROCEDURE hire_employee(
--        empId_in employees.employeeId%TYPE, 
--        first_in employees.first_name%TYPE, 
--        last_in employees.last_name%TYPE, 
--        pos_in employees.position%TYPE,
--        hir_date_in employees.hire_date%TYPE,
--        phone_in employees.phone_number%TYPE,
--        email_in employees.email%TYPE,
--        managerId_in employees.managerId%TYPE);
        
    PROCEDURE products_description(
        material_name_in materials.name%TYPE);
        
END pkg_FurnitureShop;

CREATE OR REPLACE PACKAGE BODY pkg_FurnitureShop
IS
    
    FUNCTION eligible_for_raise (empId_in employees.employeeId%TYPE) RETURN BOOLEAN IS
        days_worked NUMBER;
    BEGIN
        SELECT sysdate - hire_date INTO days_worked FROM Employees WHERE employeeId = empId_in;
        IF days_worked >= days_worked_loyalty_raise THEN
            RETURN TRUE;
        ELSE 
            RETURN FALSE;
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
    
    PROCEDURE loyalty_raise IS
    BEGIN
        FOR emp IN c_emps LOOP
            IF eligible_for_raise(emp.employeeId) THEN
                UPDATE Employees
                SET salary = salary + (salary * (salary_raise_multiplier / 100))
                WHERE sysdate - hire_date >= days_worked_loyalty_raise;
            END IF;
        END LOOP;
    END loyalty_raise;
    
    PROCEDURE products_description(material_name_in materials.name%TYPE) IS 
    BEGIN   
        FOR product IN c_products(material_name_in) LOOP
            dbms_output.put_line('Product ' || product.product_name || ' contains the specified material: ' || product.material_name);
        END LOOP;
    END products_description;
        
END pkg_FurnitureShop;

SELECT last_name, pkg_furnitureshop.salary_time_worked_ratio(salary, hire_date)
FROM employees;
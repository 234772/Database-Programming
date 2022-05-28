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
    PROCEDURE products_description(material_name_in materials.name%TYPE) IS 
    BEGIN   
        FOR product IN c_products(material_name_in) LOOP
            dbms_output.put_line('Product ' || product.product_name || ' contains the specified material: ' || product.material_name);
        END LOOP;
    END;
    
    FUNCTION eligible_for_raise (empId_in employees.employeeId%TYPE) RETURN BOOLEAN IS
        days_worked NUMBER;
    BEGIN
        SELECT sysdate - hire_date INTO days_worked FROM Employees WHERE employeeId = empId_in;
        IF days_worked >= days_worked_loyalty_raise THEN
            RETURN TRUE;
        ELSE 
            RETURN FALSE;
        END IF;
    END;
    
    PROCEDURE loyalty_raise IS
    BEGIN
        FOR emp IN c_emps LOOP
            IF eligible_for_raise(emp.employeeId) THEN
                UPDATE Employees
                SET salary = salary + (salary * (salary_raise_multiplier / 100))
                WHERE sysdate - hire_date >= days_worked_loyalty_raise;
            END IF;
        END LOOP;

    END;
        
END pkg_FurnitureShop;

DECLARE
BEGIN
    pkg_furnitureshop.loyalty_raise;
END;

SELECT *
FROM employees;
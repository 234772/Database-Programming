CREATE OR REPLACE PACKAGE pkg_FurnitureShop 
IS
    salary_raise_multiplier NUMBER := 2;
    
    noone_eligible EXCEPTION;
    invalid_id EXCEPTION;
    
    CURSOR c_products(material_name materials.name%TYPE) IS
        SELECT DISTINCT p1.name AS product_name, m1.name AS material_name 
        FROM products p1
        INNER JOIN productscomposition pc1 ON p1.productId = pc1.productId
        INNER JOIN materials m1 ON pc1.materialId = m1.materialId
        WHERE m1.name = material_name;
        
--    FUNCTION eligible_for_raise(
--        empId_in employees.employeeId%TYPE) 
--        RETURN BOOLEAN;
--        
--    FUNCTION valid_empId(
--        empId_in employees.employeeId%TYPE) 
--        RETURN BOOLEAN;
--        
--    PROCEDURE loyalty_raise(
--        empId_in employees.employeeId%TYPE);
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
END pkg_FurnitureShop;

DECLARE
BEGIN
    pkg_FurnitureShop.products_description('Oak wood');
END;
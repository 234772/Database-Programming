-- Ten SQL queries for data preview -- 

-- Contents of order with id = 1 --  

SELECT productId, quantity 
FROM orderproductline op1
WHERE orderId = 1;

-- Employees sorted by their salary descending -- 

SELECT * 
FROM employees
ORDER BY salary;

-- All employees who have no manager -- 

SELECT * 
FROM employees
WHERE managerId IS NULL;

-- Cost of each position in order, where id = 1 -- 

SELECT op1.productId, op1.quantity * p1.price_per_unit AS Total_price_per_product
FROM orderproductline op1
INNER JOIN products p1 ON op1.productId = p1.productId
WHERE orderId = 1;

-- Total money spent by client with id = 1 -- 

SELECT o1.clientId, SUM(op1.quantity * p1.price_per_unit) AS Total_price_per_product
FROM orders o1 
INNER JOIN orderproductline op1 ON o1.orderId = op1.orderId
INNER JOIN products p1 ON op1.productId = p1.productId
WHERE o1.clientId = 1
GROUP BY o1.clientId;

-- Amount of orders per client -- 

SELECT clientId, COUNT(clientId) AS Orders
FROM orders
GROUP BY clientId
ORDER BY COUNT(clientId) ASC;

-- The most expensive product -- 

SELECT a.name, a.price_per_unit
FROM (SELECT price_per_unit, name FROM Products ORDER BY price_per_unit DESC) a
WHERE rownum = 1;

-- Every product and its composition -- 

SELECT p1.name, m1.name
FROM Products p1
INNER JOIN productscomposition pc1 ON p1.productId = pc1.productId
INNER JOIN materials m1 ON pc1.materialId = m1.materialId
ORDER BY p1.name DESC;

-- Most commonly used material -- 

SELECT a.materialId, a.times_used
FROM (SELECT materialId, COUNT(materialId) times_used FROM productscomposition GROUP BY materialId ORDER BY COUNT(materialId) DESC) a
WHERE rownum = 1;

-- Employee with the most orders ncompleted --

SELECT a.employeeId, a.orders_realized
FROM
(SELECT o1.employeeId, COUNT(*) AS orders_realized
FROM orders o1
INNER JOIN employees e1 ON o1.employeeId = e1.employeeId
WHERE o1.shipment_date IS NOT NULL
GROUP BY o1.employeeId
ORDER BY COUNT(*) DESC) a
WHERE rownum = 1;

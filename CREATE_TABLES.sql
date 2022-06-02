

-- Materials table -- 
CREATE TABLE Materials(
    materialId NUMBER NOT NULL,
    name VARCHAR(20) NOT NULL,
    price_per_m2 NUMBER(5,2) NOT NULL,
    PRIMARY KEY(materialId)
);

-- Products table --
CREATE TABLE Products(
    productId NUMBER NOT NULL,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(20) NOT NULL,
    price_per_unit FLOAT NOT NULL,
    quantity_in_stock NUMBER NOT NULL,
    PRIMARY KEY(productId)
);

-- Products' composition table -- 
CREATE TABLE ProductsComposition(
    compositionId NUMBER NOT NULL,
    materialId NUMBER NOT NULL,
    productId NUMBER NOT NULL,
    amount_of_m2 FLOAT NOT NULL,
    PRIMARY KEY(compositionId),
    FOREIGN KEY (materialId) REFERENCES Materials(materialId),
    FOREIGN KEY (productId) REFERENCES Products(productId)
);

-- Clients table --
CREATE TABLE Clients(
    clientId NUMBER NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    street VARCHAR(20) NOT NULL,
    city VARCHAR(20) NOT NULL,
    zip_code VARCHAR(6) NOT NULL,
    phone_number VARCHAR(11) NOT NULL,
    email VARCHAR(50) NULL,
    PRIMARY KEY(clientId)
);

-- Employees table --
CREATE TABLE Employees(
    employeeId NUMBER NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    position VARCHAR(20) NULL,
    salary NUMBER(7,2) NOT NULL,
    hire_date DATE NOT NULL,
    phone_number VARCHAR(11) NOT NULL,
    email VARCHAR(50) NULL,
    managerId NUMBER NULL,
    PRIMARY KEY(employeeId)
);

-- Orders table -- 
CREATE TABLE Orders(
    orderId NUMBER NOT NULL,
    clientId NUMBER NOT NULL,
    employeeId NUMBER NOT NULL,
    has_been_realized NUMBER(1,0) NOT NULL,
    shipment_date DATE NULL,
    deliver_date DATE NULL,
    order_date DATE NOT NULL,
    PRIMARY KEY(orderId),
    FOREIGN KEY (clientId) REFERENCES Clients(clientId),
    FOREIGN KEY (employeeId) REFERENCES Employees(employeeId)
);

-- Order product line table --
CREATE TABLE OrderProductLine(
    order_lineId NUMBER NOT NULL,
    productId NUMBER NOT NULL,
    orderId NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    PRIMARY KEY(order_lineId),
    FOREIGN KEY (productId) REFERENCES Products(productId),
    FOREIGN KEY (orderId) REFERENCES Orders(orderId)
);

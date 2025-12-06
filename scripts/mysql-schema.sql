-- Utiliser la base cachesystem
USE cachesystem;

-- Supprimer les tables si elles existent (pour réinitialisation propre)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS employees;

-- Table customers
CREATE TABLE customers (
  customerNumber INT PRIMARY KEY AUTO_INCREMENT,
  customerName VARCHAR(100) NOT NULL,
  contactLastName VARCHAR(50),
  contactFirstName VARCHAR(50),
  phone VARCHAR(50),
  addressLine1 VARCHAR(100),
  addressLine2 VARCHAR(100),
  city VARCHAR(100),
  state VARCHAR(50),
  postalCode VARCHAR(20),
  country VARCHAR(100),
  salesRepEmployeeNumber INT,
  creditLimit DECIMAL(10, 2),
  INDEX idx_customerName (customerName)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table orders
CREATE TABLE orders (
  orderNumber INT PRIMARY KEY AUTO_INCREMENT,
  orderDate DATE NOT NULL,
  requiredDate DATE,
  shippedDate DATE,
  status VARCHAR(50),
  comments TEXT,
  customerNumber INT NOT NULL,
  INDEX idx_customerNumber (customerNumber),
  CONSTRAINT fk_customer FOREIGN KEY (customerNumber) 
    REFERENCES customers(customerNumber) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table products
CREATE TABLE products (
  productCode VARCHAR(20) PRIMARY KEY,
  productName VARCHAR(100) NOT NULL,
  productLine VARCHAR(50),
  productScale VARCHAR(20),
  productVendor VARCHAR(100),
  productDescription TEXT,
  quantityInStock INT,
  buyPrice DECIMAL(10, 2),
  MSRP DECIMAL(10, 2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table employees
CREATE TABLE employees (
  employeeNumber INT PRIMARY KEY AUTO_INCREMENT,
  lastName VARCHAR(50) NOT NULL,
  firstName VARCHAR(50) NOT NULL,
  extension VARCHAR(10),
  email VARCHAR(100),
  officeCode VARCHAR(10),
  reportsTo INT,
  jobTitle VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insérer données de test customers
INSERT INTO customers (customerNumber, customerName, contactLastName, contactFirstName, phone, city, country, creditLimit) VALUES
(103, 'Atelier graphique', 'Schmitt', 'Carine', '40.32.2555', 'Nantes', 'France', 21000.00),
(112, 'Signal Gift Stores', 'King', 'Jean', '4155551380', 'Las Vegas', 'USA', 71800.00),
(114, 'Australian Collectables, Ltd', 'Ferguson', 'Peter', '03 9520 4555', 'Melbourne', 'Australia', 117300.00),
(119, 'La Rochelle Gifts', 'Labrune', 'Janine', '40.67.8555', 'La Rochelle', 'France', 118200.00),
(121, 'Baane Mini Imports', 'Bergulfsen', 'Jonas', '07-98 92 5555', 'Stavern', 'Norway', 81700.00);

-- Insérer données de test orders
INSERT INTO orders (orderNumber, orderDate, requiredDate, status, customerNumber) VALUES
(10123, '2024-01-01', '2024-02-01', 'Shipped', 103),
(10298, '2024-01-15', '2024-02-15', 'Shipped', 112),
(10120, '2024-01-20', '2024-02-20', 'Pending', 114),
(10404, '2024-02-01', '2024-03-01', 'Processing', 119),
(10405, '2024-02-05', '2024-03-05', 'In Transit', 121);

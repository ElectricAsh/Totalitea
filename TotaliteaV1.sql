CREATE TABLE Users (
	Username VARCHAR2(25) NOT NULL UNIQUE,
	Email VARCHAR2(50) CHECK (Email LIKE '%_@_%'),
	Password VARCHAR2(25) NOT NULL,
	IsAdmin INT DEFAULT 0,
	UserID INT GENERATED ALWAYS AS IDENTITY,
	Register DATE NOT NULL,
	Address VARCHAR2(75),
	PRIMARY KEY (UserID),
	CONSTRAINT check_booking CHECK (IsAdmin IN (0,1))
);

CREATE TABLE Products (
	ProductID INT GENERATED ALWAYS AS IDENTITY,
	ProductName VARCHAR2(25) NOT NULL,
	Description VARCHAR2(50),
	Category VARCHAR2(15) NOT NULL,
	Supplier VARCHAR2(35) NOT NULL,
	PricePerGram INT NOT NULL,
	PRIMARY KEY (ProductID)
);
 
CREATE TABLE Orders (
	OrderID INT NOT NULL,
	ProductID INT NOT NULL,
	UserID INT NOT NULL,
	Weight INT NOT NULL,
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE SEQUENCE seq_orderid
START WITH 1 
INCREMENT BY 1;

INSERT INTO Users (Username, Email, Password, Address, IsAdmin, Register)
VALUES ('Steve', 'Steve@hotmail.com', 'horse', '10 downing street London W7 1BW', 1, to_Date('01/11/2021 09:30:00', 'DD/MM/YYYY HH24:MI:SS'));

INSERT INTO Users (Username, Email, Password, Address, IsAdmin, Register)
VALUES ('user1', 'user1@hotmail.com', 'van', '15 compton avenue Derby  DE7 22A', 0, to_Date('01/11/2021 09:30:00', 'DD/MM/YYYY HH24:MI:SS'));

INSERT INTO Products (ProductName, 	Description, Category, Supplier, PricePerGram)
VALUES ('espresso', 'black', 'caffinated', 'Azera', 0.5);

INSERT INTO Products (ProductName, Description, Category, Supplier, PricePerGram)
VALUES ('Earl Grey', 'grey', 'herbal', 'pg tips', 8);

INSERT INTO Orders (OrderID, ProductID, UserID, Weight)
VALUES (seq_orderid.nextval, 1, 1, 1);

INSERT INTO Orders (OrderID, ProductID, UserID, Weight)
VALUES (seq_orderid.currval, 2, 1, 5);

INSERT INTO Orders (OrderID, ProductID, UserID, Weight)
VALUES (seq_orderid.nextval, 2, 2, 10);

SELECT * FROM Users;
SELECT * FROM Products;
SELECT * FROM Orders;
	
DROP TABLE Users CASCADE CONSTRAINTS;
DROP TABLE Products CASCADE CONSTRAINTS;
DROP TABLE Orders CASCADE CONSTRAINTS;
DROP SEQUENCE seq_orderid;


-- TABLES NEED:
-- Products 
-- orders

	
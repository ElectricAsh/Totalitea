SET LINESIZE 700;

DROP TABLE Users CASCADE CONSTRAINTS;
DROP TABLE Products CASCADE CONSTRAINTS;
DROP TABLE Orders CASCADE CONSTRAINTS;
DROP SEQUENCE seq_orderid;

CREATE TABLE Users (
	Username VARCHAR2(25) NOT NULL,
	Email VARCHAR2(50) CHECK (Email LIKE '%_@_%'),
	Password VARCHAR2(25) NOT NULL,
	IsAdmin INT DEFAULT 0,
	UserID INT GENERATED ALWAYS AS IDENTITY,
	Register DATE NOT NULL,
	Address VARCHAR2(75),
	PRIMARY KEY (UserID),
	CONSTRAINT check_booking CHECK (IsAdmin IN (0,1)),
	CONSTRAINT uq_name UNIQUE (Username),
	CONSTRAINT uq_email UNIQUE (Email)
--	DOB
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
	OrderPlaced DATE DEFAULT CURRENT_DATE,
	CONSTRAINTS orderidPK PRIMARY KEY (OrderID, ProductID, UserID),
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE SEQUENCE seq_orderid
START WITH 1 
INCREMENT BY 1;

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE insertUser (
	auser IN Users.Username%TYPE,
	aemail IN Users.Email%TYPE,
	apass IN Users.Password%TYPE,
	aAddress IN Users.Address%TYPE,
	aAdmin IN Users.IsAdmin%TYPE,
	aregister IN Users.Register%TYPE,
	auserid OUT Users.UserID%TYPE
)
IS 
BEGIN
	INSERT INTO Users (Username, Email, Password, Address, IsAdmin, Register)
	VALUES (auser, aemail, apass, aAddress, aAdmin, aregister) RETURNING UserID INTO auserid;
END;
/

CREATE OR REPLACE PROCEDURE insertProducts (
	aprodname IN Products.ProductName%TYPE,
	adesc IN Products.Description%TYPE,
	acategory IN Products.Category%TYPE,
	asupplier IN Products.Supplier%TYPE,
	appg IN Products.PricePerGram%TYPE,
	aprodid OUT Products.ProductID%TYPE
)
IS
BEGIN
	INSERT INTO Products (ProductName, Description, Category, Supplier, PricePerGram)
	VALUES (aprodname, adesc, acategory, asupplier, appg) RETURNING ProductID INTO aprodid;
END;
/

CREATE OR REPLACE PROCEDURE insertOrders(
	aorderID IN Orders.OrderID%TYPE,
	aprodID IN Orders.ProductID%TYPE,
	auserID IN Orders.UserID%TYPE,
	aweight IN Orders.Weight%TYPE,
	placedwhen IN Orders.OrderPlaced%TYPE,
	excmsg OUT VARCHAR2
)
IS
	invalidWeight EXCEPTION;
BEGIN 
	IF(aweight > 0) THEN
		INSERT INTO Orders (OrderID, ProductID, UserID, Weight, OrderPlaced)
		VALUES (aorderID, aprodID, auserID, aweight, placedwhen);
	ELSE 
		RAISE invalidWeight;
	END IF;
EXCEPTION
	WHEN invalidWeight THEN
		excmsg := 'invalidWeight ' || aweight|| '. It must be a value more than 0';
END;
/

DECLARE 
	prodID INT;
	userID INT;
	excmsg VARCHAR2(120);
BEGIN
	insertUser('Stuart', 'Stuart@hotmail.com', 'horse', '10 downing street London W7 1BW', 1, to_Date('01/11/2021 09:30:00', 'DD/MM/YYYY HH24:MI:SS'), userID);
	insertProducts('espresso', 'black', 'caffinated', 'Azera', 0.5, prodID);
	insertOrders(seq_orderid.nextval, prodID, userID, 1, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'), excmsg);
	insertProducts('Earl Grey', 'grey', 'herbal', 'pg tips', 8, prodID);
	insertOrders(seq_orderid.currval, prodID, userID, 5, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'), excmsg);
	
	insertUser('user1', 'user1@hotmail.com', 'van', '15 compton avenue Derby  DE7 22A', 0, to_Date('01/11/2021 09:30:00', 'DD/MM/YYYY HH24:MI:SS'), userID);
	insertOrders(seq_orderid.nextval, prodID, userID, 10, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'), excmsg);
END;
/
COMMIT;

SELECT * FROM Users;
SELECT * FROM Products;
SELECT * FROM Orders;	

-- DO NOT DROP THE SOAP OR THE TABLE!! FOR YOU WILL BE AGONISED
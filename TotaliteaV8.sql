SET LINESIZE 700;

DROP TABLE Users CASCADE CONSTRAINTS;
DROP TABLE Products CASCADE CONSTRAINTS;
DROP TABLE Orders CASCADE CONSTRAINTS;
DROP SEQUENCE seq_orderid;

CREATE TABLE Users (
	Username VARCHAR2(25) NOT NULL,
	DOB VARCHAR2(15) NOT NULL,
	Email VARCHAR2(50) CHECK (Email LIKE '%_@_%'),
	Password VARCHAR2(25) NOT NULL,
	IsAdmin INT DEFAULT 0,
	UserID INT GENERATED ALWAYS AS IDENTITY,
	Register TIMESTAMP NOT NULL,
	Address VARCHAR2(75),
	PRIMARY KEY (UserID),
	CONSTRAINT check_admin CHECK (IsAdmin IN (0,1)),
	CONSTRAINT uq_name UNIQUE (Username),
	CONSTRAINT uq_email UNIQUE (Email)
);

CREATE TABLE Products (
	ProductID INT GENERATED ALWAYS AS IDENTITY,
	ProductType VARCHAR2(35),
	Description VARCHAR2(50),
	MedicanlUse VARCHAR2(50),
	CaffeineAmt INT,
	Category VARCHAR2(15) NOT NULL,
	Supplier VARCHAR2(35) NOT NULL,
	SetPrice DECIMAL(5,2) NOT NULL,
	SetWeight INT NOT NULL,
	HasNuts	INT DEFAULT 0,
	HasDairy INT DEFAULT 0,
	SugarAmt INT,
	SaturatedFat INT,
	PRIMARY KEY (ProductID),
	CONSTRAINT check_nuts CHECK (HasNuts IN (0,1)),
	CONSTRAINT check_dairy CHECK (HasDairy IN (0,1))
);	

CREATE TABLE Orders (
	OrderID INT NOT NULL,
	ProductID INT NOT NULL,
	UserID INT NOT NULL,
	OrderPlaced TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINTS orderidPK PRIMARY KEY (OrderID, ProductID, UserID),
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE SEQUENCE seq_orderid
START WITH 1 
INCREMENT BY 1;

SAVEPOINT savepoint_seq;

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE insertUser (
	auser IN Users.Username%TYPE,
	adob IN Users.DOB%TYPE,
	aemail IN Users.Email%TYPE,
	apass IN Users.Password%TYPE,
	aAddress IN Users.Address%TYPE,
	aAdmin IN Users.IsAdmin%TYPE,
	aregister IN Users.Register%TYPE,
	auserid OUT Users.UserID%TYPE,
	emcmsg OUT VARCHAR2
)
IS 
	invalidEmail EXCEPTION;
BEGIN
	IF (aemail LIKE '%_@_%.com') THEN
		INSERT INTO Users (Username, DOB, Email, Password, Address, IsAdmin, Register)
		VALUES (auser, adob, aemail, apass, aAddress, aAdmin, aregister) RETURNING UserID INTO auserid;
	ELSE
		-- 'throw' the exception
		RAISE invalidEmail;
	END IF;
EXCEPTION
	WHEN invalidEmail THEN
		emcmsg := 'invalidEmail ' || aemail || '. it must end with a .com';
END;
/
SAVEPOINT savepoint_user;

CREATE OR REPLACE PROCEDURE insertProducts (
	aprodtype IN Products.ProductType%TYPE,
	adesc IN Products.Description%TYPE,
	meduse IN Products.MedicanlUse%TYPE,
	acafamt IN Products.CaffeineAmt%TYPE,
	acategory IN Products.Category%TYPE,
	asupplier IN Products.Supplier%TYPE,
	aprice IN Products.SetPrice%TYPE,
	aweight IN Products.SetWeight%TYPE,
	hasnuts IN Products.HasNuts%TYPE,
	hasdairy IN Products.HasDairy%TYPE,
	asugaramt IN Products.SugarAmt%TYPE,
	satfat IN Products.SaturatedFat%TYPE,
	aprod OUT Products.ProductID%TYPE
)
IS
BEGIN
	INSERT INTO Products (ProductType, Description, MedicanlUse, CaffeineAmt, Category, 
	Supplier, SetPrice, SetWeight, HasNuts, HasDairy, SugarAmt, 
	SaturatedFat)
	VALUES (aprodtype, adesc, meduse, acafamt, acategory, asupplier, aprice, aweight,
    hasnuts, hasdairy, asugaramt, satfat) RETURNING ProductID INTO aprod;
END;
/
SAVEPOINT savepoint_products;

CREATE OR REPLACE PROCEDURE insertOrders (
	aorderID IN Orders.OrderID%TYPE,
	prodID IN Orders.ProductID%TYPE,
	auserID IN Orders.UserID%TYPE,
	placedwhen IN Orders.OrderPlaced%TYPE
)
IS
BEGIN 
	INSERT INTO Orders (OrderID, ProductID, UserID, OrderPlaced)
	VALUES (aorderID, prodID, auserID, placedwhen);
END;
/
SAVEPOINT savepoint_orders;

DECLARE 
	aprod INT;
	auser INT;
	emcmsg VARCHAR2(120);
BEGIN
	insertUser('Stuart', '02-JUN-88', 'Stuart@hotmail.com', 'horse', '10 downing street London W7 1BW', 1, to_Date('01/11/2021 09:30:00', 'DD/MM/YYYY HH24:MI:SS'), auser, emcmsg);
	DBMS_OUTPUT.PUT_LINE(emcmsg);
	insertProducts('caffeinated', 'espresso', 'improve concentration', 212, 'Drink', 'azera', 4.20, 100, 0, 0, 0, 0, aprod); 
	insertOrders(seq_orderid.nextval, aprod, auser, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	insertProducts('decaff', 'Earl Grey', 'improve digestion', 95, 'Drink', 'Twinings', 4.00, 250, 0, 0, 0, 0, aprod); 
	insertOrders(seq_orderid.currval, aprod, auser, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	insertProducts('caffeinated', 'Cappuccino', 'source of useful antioxidant', 212, 'Drink', 'azera', 4.20, 100, 0, 0, 0, 0, aprod); 
	insertOrders(seq_orderid.currval, aprod, auser, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	-- insertUser('user1', '02-sep-88', 'user1@hotmail.com', 'van', '15 RollsRoyce Drive  Derby  DE7 22A', 0, to_Date('01/11/2021 09:30:00', 'DD/MM/YYYY HH24:MI:SS'), auser, emcmsg);
	-- DBMS_OUTPUT.PUT_LINE(emcmsg);
	-- insertOrders(seq_orderid.nextval, aprod, auser, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'));
END;
/
COMMIT;
	-- ProductType, Description, MedicanlUse, CaffeineAmt, Category, Supplier, SetPrice, SetWeight, HasNuts, HasDairy, SugarAmt, SaturatedFat
SELECT * FROM Users;
SELECT * FROM Products;
SELECT * FROM Orders;	

-- DO NOT DROP THE SOAP OR THE TABLE!! FOR YOU WILL BE AGONISED
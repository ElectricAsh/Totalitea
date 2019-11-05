SET LINESIZE 700;

DROP TABLE Users CASCADE CONSTRAINTS;
DROP TABLE Drinks CASCADE CONSTRAINTS;
DROP TABLE Orders CASCADE CONSTRAINTS;
DROP TABLE Cakes CASCADE CONSTRAINTS;
DROP SEQUENCE seq_orderid;
DROP SEQUENCE seq_prodid;

CREATE TABLE Users (
	Username VARCHAR2(25) NOT NULL,
	DOB VARCHAR2(15) NOT NULL,
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
);

CREATE TABLE Drinks (
	ProductID INT,
	DrinkType VARCHAR2(15),
	DrinkName VARCHAR2(20),
	Description VARCHAR2(50),
	CaffeineAmt INT,
	Category VARCHAR2(15) NOT NULL,
	Supplier VARCHAR2(35) NOT NULL,
	PricePerGram INT NOT NULL,
	PRIMARY KEY (ProductID)
);

CREATE SEQUENCE seq_prodid
START WITH 1
INCREMENT BY 1;

CREATE TABLE Cakes (
	DrinkID INT,
	ProductID INT,
	CakeType VARCHAR2(25) NOT NULL,
	HasNuts	INT DEFAULT 0,
	HasDairy INT DEFAULT 0,
	SugarAmt INT,
	SaturatedFat INT,
	PRIMARY KEY (ProductID),
	FOREIGN KEY (DrinkID) REFERENCES Drinks(ProductID)
);	

CREATE TABLE Orders (
	OrderID INT NOT NULL,
	ProductID INT NOT NULL,
	UserID INT NOT NULL,
	Weight INT NOT NULL,
	OrderPlaced DATE DEFAULT CURRENT_DATE,
	CONSTRAINTS orderidPK PRIMARY KEY (OrderID, ProductID, UserID),
	FOREIGN KEY (ProductID) REFERENCES Drinks(ProductID),
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

CREATE OR REPLACE PROCEDURE insertDrinks (
	adrinktype IN Drinks.DrinkType%TYPE,
	adrinkname IN Drinks.DrinkName%TYPE,
	adesc IN Drinks.Description%TYPE,
	acafamt IN Drinks.CaffeineAmt%TYPE,
	acategory IN Drinks.Category%TYPE,
	asupplier IN Drinks.Supplier%TYPE,
	appg IN Drinks.PricePerGram%TYPE,
	adrinkid IN Drinks.ProductID%TYPE
)
IS
BEGIN
	INSERT INTO Drinks (ProductID, DrinkType, DrinkName, Description, CaffeineAmt, Category, Supplier, PricePerGram)
	VALUES (adrinkid, adrinktype, adrinkname, adesc, acafamt, acategory, asupplier, appg)
END;
/
SAVEPOINT savepoint_drinks;

CREATE OR REPLACE PROCEDURE insertCakes (
	adrinkID IN Cakes.DrinkID%TYPE,
	acktype IN Cakes.CakeType%TYPE,
	hasnuts IN Cakes.HasNuts%TYPE,
	hasdairy IN Cakes.HasDairy%TYPE,
	sugaramt IN Cakes.SugarAmt%TYPE,
	satfat IN Cakes.SaturatedFat%TYPE,
	aprodID OUT Cakes.ProductID%TYPE
)
IS
BEGIN
	INSERT INTO Cakes (DrinkID, CakeType, HasNuts, HasDairy, SugarAmt, SaturatedFat)
	VALUES (adrinkID, acktype, hasnuts, hasdairy, sugaramt, satfat) RETURNING ProductID INTO aprodID;
END;
/
SAVEPOINT savepoint_cakes;

CREATE OR REPLACE PROCEDURE insertOrders (
	aorderID IN Orders.OrderID%TYPE,
	prodID IN Orders.ProductID%TYPE,
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
		VALUES (aorderID, prodID, auserID, aweight, placedwhen);
	ELSE 
		RAISE invalidWeight;
	END IF;
EXCEPTION
	WHEN invalidWeight THEN
		excmsg := 'invalidWeight ' || aweight|| '. It must be a value more than 0';
END;
/
SAVEPOINT savepoint_orders;

DECLARE 
	prodID INT;
	drinkID INT;
	userID INT;
	excmsg VARCHAR2(120);
	emcmsg VARCHAR2(120);
BEGIN
	insertUser('Stuart', '02-JUN-88', 'Stuart@hotmail.com', 'horse', '10 downing street London W7 1BW', 1, to_Date('01/11/2021 09:30:00', 'DD/MM/YYYY HH24:MI:SS'), userID, emcmsg);
	DBMS_OUTPUT.PUT_LINE(emcmsg);
	insertDrinks(seq_prodid.nextval, 'Coffee', 'espresso', 'black', 50, 'caffinated', 'Azera', 0.5);
	insertCakes(seq_prodid.currval, 'velvet', 0, 0, 15, 2, drinkID); 
	insertOrders(seq_orderid.nextval, drinkID, userID, 1, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'), excmsg);
	DBMS_OUTPUT.PUT_LINE(excmsg);
	insertDrinks(seq_prodid.nextval, 'Tea', 'Earl Grey', 'grey', 3, 'herbal', 'pg tips', 8);
	insertCakes(seq_prodid.currval, 'carrot cake', 1, 1, 25, 5, drinkID);
	insertOrders(seq_orderid.currval, drinkID, userID, 5, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'), excmsg);
	
	insertUser('user1', '02-sep-88', 'user1@hotmail.com', 'van', '15 compton avenue Derby  DE7 22A', 0, to_Date('01/11/2021 09:30:00', 'DD/MM/YYYY HH24:MI:SS'), userID, emcmsg);
	DBMS_OUTPUT.PUT_LINE(emcmsg);
	insertOrders(seq_orderid.nextval, drinkID, userID, 10, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'), excmsg);
	DBMS_OUTPUT.PUT_LINE(excmsg);
END;
/
COMMIT;

SELECT * FROM Users;
SELECT * FROM Cakes;
SELECT * FROM Orders;
SELECT * FROM Drinks;	

-- DO NOT DROP THE SOAP OR THE TABLE!! FOR YOU WILL BE AGONISED
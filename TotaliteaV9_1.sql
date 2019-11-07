SET LINESIZE 200;

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
	ProductName VARCHAR2(50),
	Description VARCHAR2(200),
	MedicinalUse VARCHAR2(50),
	CaffeineAmt INT,
	Category VARCHAR2(15) NOT NULL,
	Recommended VARCHAR2(50),
	Supplier VARCHAR2(35) NOT NULL,
	Price DECIMAL(5,2) NOT NULL,
	Weight INT NOT NULL,
	HasNuts	VARCHAR2(20),
	HasDairy VARCHAR2(20),
	SugarAmt DECIMAL(5,1),
	SaturatedFat DECIMAL(5,1),
	PRIMARY KEY (ProductID)
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
	aprodname IN Products.ProductName%TYPE,
	adesc IN Products.Description%TYPE,
	meduse IN Products.MedicinalUse%TYPE,
	acafamt IN Products.CaffeineAmt%TYPE,
	acategory IN Products.Category%TYPE,
	arecommend IN Products.Recommended%TYPE,
	asupplier IN Products.Supplier%TYPE,
	aprice IN Products.Price%TYPE,
	aweight IN Products.Weight%TYPE,
	hasnuts IN Products.HasNuts%TYPE,
	hasdairy IN Products.HasDairy%TYPE,
	asugaramt IN Products.SugarAmt%TYPE,
	satfat IN Products.SaturatedFat%TYPE,
	aprod OUT Products.ProductID%TYPE
)
IS
BEGIN
	INSERT INTO Products (ProductType, ProductName, Description, MedicinalUse, CaffeineAmt, Category, Recommended,
	Supplier, Price, Weight, HasNuts, HasDairy, SugarAmt, SaturatedFat) 
	VALUES (aprodtype, aprodname, adesc, meduse, acafamt, acategory, arecommend, asupplier, aprice, aweight,
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
	insertProducts('Herbal', 'Green Tea', 'One of the healthiest beverages on the planet.', 'Reduces risk of cardiovascular diseases', 38, 'Drink', '', 'Clipper', 3.00, 160, 'No Nuts', 'No Dairy', 0.0, 0.0, aprod);
	insertProducts('Caffeinated', 'Turkish Black Tea', 'Incredibly strong black tea', 'Reduces risk of diabetes', 0, 'Drink', '', 'Caykur', 6.10, 500, 'No Nuts', 'No Dairy', 0.0, 0.0, aprod);
	insertProducts('Caffeinated', 'Americano', 'Hot water added to a shot of espresso', 'Holds essential nutrients and antioxidants', 83, 'Drink', '', 'Azera', 3.00, 100, 'No Nuts', 'No Dairy', 0.0, 0.0, aprod);
	insertProducts('Caffeinated', 'Latte Macchiato', 'Espresso topped with foamed milk', 'Improves the mood of the consumer', 150, 'Drink', '', 'Tassimo', 3.98, 264, 'No Nuts', 'No Dairy', 7.0, 0.0, aprod);
	insertProducts('Caffeinated', 'Mocha', 'Like a latte, but with added chocolate flavouring', 'None', 165, 'Drink', '', 'Nescafe', 2.65, 233, 'No Nuts', 'No Dairy', 25.0, 0.0, aprod);
	insertProducts('Frosted cake', 'Red Velvet', 'Red velvet cake with a cream cheese frosting', 'None', 0, 'Cake', 'Latte', 'Sainsburys', 2.00, 350, 'No Nuts', 'Has Dairy', 38.5, 10.2, aprod);
	
	insertUser('Stuart', '02-JUN-88', 'thestuart@meantinc.com', 'horse', '62 Boat Lane, Resolven, SA11 6NG', 1, to_Date('01/11/2019 09:30:00', 'DD/MM/YYYY HH24:MI:SS'), auser, emcmsg);
	DBMS_OUTPUT.PUT_LINE(emcmsg);
	insertProducts('Caffeinated', 'Espresso', 'Full-flavoured, concentrated form of coffee.', 'Improves concentration', 212, 'Drink', '', 'Azera', 4.20, 100, 'No Nuts', 'No Dairy', 0.0, 0.0, aprod); 
	insertOrders(seq_orderid.nextval, aprod, auser, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	insertProducts('Herbal', 'Earl Grey', 'One of the most recognised flavoured teas', 'Improves digestion', 95, 'Drink', '', 'Twinings', 4.00, 250, 'No Nuts', 'No Dairy', 0.0, 0.0, aprod); 
	insertOrders(seq_orderid.currval, aprod, auser, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	insertProducts('Caffeinated', 'Cappuccino', 'A coffee drink typically composed of double espresso and hot milk', 'Source of useful antioxidants', 143, 'Drink', '', 'Azera', 14.00, 560, 'No Nuts', 'Has Dairy', 5.9, 1.4, aprod); 
	insertOrders(seq_orderid.currval, aprod, auser, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	insertProducts('Chocolate cake', 'Chocolate Celebration Cake', 'Moist, delicious and packed full of chocolate.', 'None', 0, 'Cake', 'Cappuccino', 'Thorntons', 2.20, 600, 'No Nuts', 'Has Dairy', 102.4, 47.4, aprod);
	insertOrders(seq_orderid.currval, aprod, auser, to_Date('04/11/2019 15:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	
	insertUser('JamieG', '02-sep-88', 'jamiegustav@socialbounty.com', 'van', '96 Stroud Road, Old Craighill, EH22 3ZL', 0, to_Date('03/11/2019 10:30:00', 'DD/MM/YYYY HH24:MI:SS'), auser, emcmsg);
	DBMS_OUTPUT.PUT_LINE(emcmsg);
	insertProducts('Sponge cake', 'Victoria Sponge Cake', 'Two layers of sponge filled with cream and jam.', 'None', 0, 'Cake', 'Mocha', 'The Craft Company', 2.75, 345, 'No Nuts', 'Has Dairy', 81.0, 18.0, aprod); 
	insertOrders(seq_orderid.nextval, aprod, auser, to_Date('07/11/2019 17:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	insertProducts('Chocolate Cake', 'Belgian Chocolate Fudge Cake', 'Chocolate cake topped with belgian chocolate buttercream.', 'None', 0, 'Cake', 'Espresso', 'The Handmade Cake Company', 2.75, 395, 'No Nuts', 'Has Dairy', 115.2, 27.0, aprod);
	insertOrders(seq_orderid.currval, aprod, auser, to_Date('07/11/2019 17:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	insertProducts('Caffeinated', 'Latte', 'Half coffee - Half milk', 'A latte a day keeps the doctor way.', 77, 'Drink', '', 'LavAzza', 13.93, 630, 'No Nuts', 'Has Dairy', 18.8, 14.4, aprod);   
	insertOrders(seq_orderid.currval, aprod, auser, to_Date('07/11/2019 17:10:00', 'DD/MM/YYYY HH24:MI:SS'));
	
END;
/
COMMIT;
	 -- ProductType, ProductName, Description, MedicinalUse, CaffeineAmt, Category, Supplier, Price, Weight, HasNuts, HasDairy, SugarAmt, SaturatedFat
SELECT * FROM Users;
SELECT * FROM Products;
SELECT * FROM Orders;	

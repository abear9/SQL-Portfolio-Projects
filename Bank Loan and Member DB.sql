--DDL and Insert Script Homework

--Drop Tables section in order that parent/child tables need to be deleted
DROP TABLE Member_Address_Link;
DROP TABLE Member_Address;
DROP TABLE Member_Phone;
DROP TABLE Member_Tax_ID;
DROP TABLE Transaction_History;
DROP TABLE Loans;
DROP TABLE Employees;
DROP TABLE Branch;
DROP TABLE Members;

COMMIT;

--Create Tables section
--First create the tables for the member attributes
CREATE TABLE Members (
member_ID       NUMBER          PRIMARY KEY, 
First_Name      VARCHAR(100)    NOT NULL, 
Middle_Name     VARCHAR(100),
Last_Name       VARCHAR(100)    NOT NULL,
Email           VARCHAR(100)    NOT NULL    UNIQUE,
CONSTRAINT email_length_check   CHECK(Length(Email) >= 7)
);

CREATE TABLE Member_Address (
Address_ID      NUMBER          PRIMARY KEY,
Address_1       VARCHAR(100)    NOT NULL, 
Address_2       VARCHAR(100),
City            VARCHAR(100)    NOT NULL, 
Member_State    CHAR(2)         NOT NULL,
Zip_Code        CHAR(5)         NOT NULL
);

--Foreign key defined at column level
CREATE TABLE Member_Phone  (
Phone_ID        NUMBER          PRIMARY KEY, 
Phone_Number    CHAR(12)        NOT NULL, 
Phone_Type      VARCHAR(10)     NOT NULL,
Member_ID       NUMBER          REFERENCES Members(Member_ID)
);

CREATE TABLE Member_Tax_ID (
Member_ID       NUMBER          REFERENCES Members(Member_ID),
Tax_ID          CHAR(9)         NOT NULL    UNIQUE,
CONSTRAINT member_tax_pk        PRIMARY KEY (Member_ID)
);

--Create Linking table for Member ID and Address
CREATE TABLE Member_Address_Link (
Member_ID       NUMBER          REFERENCES Members(Member_ID),
Address_ID      NUMBER          REFERENCES Member_Address(Address_ID),
Address_Status  CHAR(1)         NOT NULL,
CONSTRAINT member_address_pk    PRIMARY KEY (Member_ID, Address_ID)
);

--Now Create Tables on the Loans and Employees side
CREATE TABLE Branch (
Branch_ID       NUMBER          PRIMARY KEY,
Branch_Name     VARCHAR(100)    NOT NULL    UNIQUE,
Address         VARCHAR(100)    NOT NULL,
City            VARCHAR(100)    NOT NULL,
Branch_State    CHAR(2)         NOT NULL,
Zip_Code        CHAR(5)         NOT NULL
);

CREATE TABLE Employees (
Employee_ID     NUMBER          PRIMARY KEY,
Branch_ID       NUMBER          REFERENCES Branch(Branch_ID),
First_Name      VARCHAR(100)    NOT NULL,
Last_Name       VARCHAR(100)    NOT NULL,
Tax_ID_Number   CHAR(9)         NOT NULL    UNIQUE,
Birthday        DATE            NOT NULL,
Mailing_Address VARCHAR(100)    NOT NULL,
Mailing_City    VARCHAR(100)    NOT NULL,
Mailing_State   CHAR(2)         NOT NULL,
Mailing_ZIP     CHAR(5)         NOT NULL,
Phone_Number    CHAR(12)        NOT NULL,
Email           VARCHAR(100)    NOT NULL,
Emp_Level       CHAR(1)         NOT NULL,
CONSTRAINT emp_level_check      CHECK(Emp_Level in ('1', '2', '3', '4', '5')),
CONSTRAINT email_length_check_2   CHECK(Length(Email) >= 7)
);

CREATE TABLE Loans (
Loan_Number     CHAR(12)        PRIMARY KEY,
Member_ID       NUMBER          REFERENCES Members(Member_ID),
Loan_Type       CHAR(2)         NOT NULL,
Original_Amount NUMBER          NOT NULL,
Origination_Date DATE           NOT NULL,
Num_of_Payments NUMBER          NOT NULL,
Interest_Rate   NUMBER(5,3)     NOT NULL    CHECK(Interest_Rate >= 0 AND Interest_Rate <=99.999),
Payment_Amount  NUMBER          NOT NULL,
Maturity_Date   DATE            NOT NULL,
Loan_Notes      VARCHAR(250),
Employee_ID     NUMBER          REFERENCES Employees(Employee_ID),
Loan_Status     CHAR(1)         NOT NULL,
CONSTRAINT  maturity_origination_check  CHECK(Maturity_Date > Origination_Date),
CONSTRAINT  status_check        CHECK(Loan_Status in ('A', 'R', 'P', 'D', 'C'))
);

CREATE TABLE Transaction_History (
Transaction_ID  NUMBER          PRIMARY KEY,
Loan_Number     CHAR(12)        REFERENCES Loans(Loan_Number),
Transaction_Date DATE           DEFAULT SYSDATE,
Amount          NUMBER          NOT NULL,
Transaction_Description VARCHAR(100) NOT NULL,
Updated_Balance NUMBER          CHECK(Updated_Balance >= 0)
);

COMMIT;

--Insert data into the new tables created

--Creating 2 Members
INSERT INTO Members 
VALUES (1, 'Drew', 'R', 'Hebert', 'ah64595@utexas.edu');

INSERT INTO Members 
VALUES (2, 'Keanu', 'S', 'Reeves', 'kr12345@utexas.edu');

--Create Tax IDs for Members 1 and 2
INSERT INTO Member_Tax_ID
VALUES (1, 111222333);

INSERT INTO Member_Tax_ID
VALUES(2, 333444555);

--Create 2 Addresses for both members
INSERT INTO Member_Address
VALUES(1, '33 Main St', '160', 'Austin', 'TX', '78751');

INSERT INTO Member_Address
VALUES(2, '100 Oak Dr', '100', 'Houston', 'TX', '77433');

INSERT INTO Member_Address
VALUES(3, '101 Washington Ave', '232', 'Arlington', 'VA', '45454');

--Make Address 1 the primary address for Member 1 (me)
INSERT INTO Member_Address_Link
VALUES(1, 1, 'P');

--Make Address 2 inactive for Member 1 but active for Member 2
INSERT INTO Member_Address_Link
VALUES(1, 2, 'I');

INSERT INTO Member_Address_Link
VALUES(2, 2, 'P');

--Make Address 3 inactive for Member 2
INSERT INTO Member_Address_Link
VALUES(2, 3, 'I');

COMMIT;

--Create 2 phone numbers for both members
INSERT INTO Member_Phone
VALUES(1, '512-888-9999', 'home', 1);

INSERT INTO Member_Phone
VALUES(2, '512-001-1010', 'cell', 1);

INSERT INTO Member_Phone
VALUES(3, '512-713-8321', 'home', 2);

INSERT INTO Member_Phone
VALUES(4, '832-615-0101', 'cell', 2);

COMMIT;

--Create 2 loans for both members (null for employee ID for now)
INSERT INTO Loans 
VALUES('AH1000012121', 1, 'XX', 10000, '1-SEP-2022', 10, 11.001, 400, '1-SEP-2032', 
'Loan for opening bar with Business Partner Keanu Reeves', NULL, 'P'); 

INSERT INTO Loans 
VALUES('AH2000100000', 1, 'AA', 25000, '1-JAN-2016', 2, 15.000, 12500, '1-JUL-2020', 
'Loan for starting clothing for cats brand', NULL, 'C'); 

INSERT INTO Loans 
VALUES('KR9990123412', 2, 'YY', 100000, '1-NOV-2005', 13, 6.05, 9000, '1-NOV-2018', 
'John Wick Spin-Off Series Loan - Failed', NULL, 'R'); 

INSERT INTO Loans 
VALUES('KR1234567890', 2, 'AA', 20000, '1-SEP-2022', 10, 11.001, 800, '1-SEP-2032', 
'Related Loan for opening bar with business partner Drew Hebert', NULL, 'D'); 

COMMIT;

--Create 2 Payments for the active loan in transaction history
INSERT INTO Transaction_History
VALUES(10001, 'AH1000012121', '1-SEP-2023', 444, 'Yearly payment on loan', 9556);

INSERT INTO Transaction_History
VALUES(10002, 'AH1000012121', '1-SEP-2024', 444, 'Yearly payment on loan', 9112);

--Create 4 Employees and assign each one a members loans (NULL for branch ID)
INSERT INTO Employees
VALUES(101, NULL, 'Jake', 'Smith', 123456789, '1-JAN-1990', '987 Big Rd', 'Tampa', 
'FL', '80909', '231-123-1321', 'jsmith@bank.com', '1');

INSERT INTO Employees
VALUES(102, NULL, 'Amanda', 'Jones', 456789123, '23-AUG-1988', '1001 Medium St', 'Los Angeles', 
'CA', '23123', '701-342-1232', 'ajones@bank.com', '2');

INSERT INTO Employees
VALUES(103, NULL, 'Fabio', 'Gonzalez', 789123456, '10-NOV-1993', '1 Decent Dr', 'Chicago', 
'IL', '75757', '199-143-1008', 'fgonzalez@bank.com', '2');

INSERT INTO Employees
VALUES(104, NULL, 'Anna', 'Banana', 100100100, '11-DEC-1999', '9090 Small Ln', 'Seattle', 
'WA', '67675', '432-010-8293', 'abanana@bank.com', '4');

COMMIT;

--Assign to loans
UPDATE Loans
SET Employee_ID = 101
WHERE Loan_Number = 'AH1000012121';

UPDATE Loans
SET Employee_ID = 102
WHERE Loan_Number = 'AH2000100000';

UPDATE Loans
SET Employee_ID = 103
WHERE Loan_Number = 'KR9990123412';

UPDATE Loans
SET Employee_ID = 104
WHERE Loan_Number = 'KR1234567890';

COMMIT;

--Create Indexes on all foreign keys to speed up queries
CREATE INDEX phone_member_index
ON Member_Phone(Member_ID);

CREATE INDEX loan_member_index
ON Loans(Member_ID);

CREATE INDEX loan_employee_index
ON Loans(Employee_ID);

CREATE INDEX transaction_loan_index
ON Transaction_History(Loan_Number);

CREATE INDEX employees_branch_index
ON Employees(Branch_ID);

COMMIT;

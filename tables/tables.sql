-- Category
---------------------------------------------------------------------

CREATE TABLE Category
(
    CategoryID   int          NOT NULL IDENTITY (1, 1),
    CategoryName varchar(55)  NOT NULL,
    Description  varchar(255) NOT NULL,
    CONSTRAINT CategoryCheck CHECK (CategoryName not like '%[^a-zA-Z ]%'),
    CONSTRAINT CategoryPK PRIMARY KEY (CategoryID)
)

-- Meals --
---------------------------------------------------------------------

CREATE TABLE Meals
(
    MealID       int         NOT NULL IDENTITY (1, 1),
    CategoryID   int         NOT NULL,
    NameMeals    varchar(55) NOT NULL,
    Price        money       NOT NULL,
    Discontinued bit         NOT NULL,
    CONSTRAINT ErrorPrice CHECK (Price > 0),
    CONSTRAINT NameMealsCheck CHECK (NameMeals not like '%[^a-zA-Z ]%'),
    CONSTRAINT MealsPK PRIMARY KEY (MealID)
)

ALTER TABLE Meals
    ADD CONSTRAINT CategoryMenuItems
        FOREIGN KEY (CategoryID)
            REFERENCES Category (CategoryID)

-- Current Menu --
---------------------------------------------------------------------

CREATE TABLE CurrentMenu
(
    IntroduceDate date NOT NULL,
    MealID        int  NOT NULL,
    CONSTRAINT CurrentMenu_pk PRIMARY KEY (MealID)
)

ALTER TABLE CurrentMenu
    ADD CONSTRAINT MenuPosition
        FOREIGN KEY (MealID)
            REFERENCES Meals (MealID)

-- Customers --

CREATE TABLE Customers
(
    CustomerID int          NOT NULL IDENTITY (1, 1),
    Email      varchar(255) NOT NULL,
    Phone      char(12)     NOT NULL,
    City       varchar(255) NOT NULL,
    Street     varchar(255) NOT NULL,
    PostalCode varchar(255) NOT NULL,

    CONSTRAINT ValidPostalCode CHECK (PostalCode LIKE
                                      '[0-9][0-9]-[0-9][0-9][0-9]'),
    CONSTRAINT ValidEmail CHECK (Email LIKE '%@%.%'),
    CONSTRAINT ValidPhone CHECK (Phone LIKE
                                 '+[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT Customers_pk PRIMARY KEY (CustomerID)
)

-- Individual Customers --
---------------------------------------------------------------------

CREATE TABLE IndividualCustomers
(
    CustomerID   int          NOT NULL,
    CustomerName varchar(255) NOT NULL,

    CONSTRAINT CustomersPK PRIMARY KEY (CustomerID),
)

ALTER TABLE IndividualCustomers
    ADD CONSTRAINT Customers__fk
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

-- Company Customer --
---------------------------------------------------------------------

CREATE TABLE CompanyCustomers
(
    CustomerID int          NOT NULL,
    Name       varchar(255) NOT NULL,
    NIP        char(10)     NOT NULL,

    CONSTRAINT CompanyClients_pk PRIMARY KEY (CustomerID),
    CONSTRAINT ValidNIP CHECK ( NIP LIKE
                                '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)

ALTER TABLE CompanyCustomers
    ADD CONSTRAINT Customers_fk
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

-- Employees --
---------------------------------------------------------------------

CREATE TABLE Employees
(
    EmployeeID int NOT NULL,
    CompanyID  int NOT NULL,

    CONSTRAINT Employees_pk PRIMARY KEY (EmployeeID, CompanyID)
)

ALTER TABLE Employees
    ADD CONSTRAINT EmployeeCustomer_fk
        FOREIGN KEY (EmployeeID) REFERENCES IndividualCustomers (CustomerID)

ALTER TABLE Employees
    ADD CONSTRAINT EmployeeCompany_fk
        FOREIGN KEY (CompanyID) REFERENCES CompanyCustomers (CustomerID)


-- Orders --
---------------------------------------------------------------------

CREATE TABLE Orders
(
    OrderID    int         NOT NULL IDENTITY (1, 1),
    CustomerID int         NOT NULL,
    OrderDate  datetime    NOT NULL,
    Discount   float       NOT NULL,
    Status     varchar(20) NOT NULL,

    CONSTRAINT OrdersPK PRIMARY KEY (OrderID),
    CONSTRAINT ValidDiscount CHECK (Discount BETWEEN 0 AND 1),
    CONSTRAINT OrderStatusEnum CHECK (Status IN ('Pending', 'Complete'))
)

ALTER TABLE Orders
    ADD CONSTRAINT OrderCustomers_fk
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

-- Takeaway Orders --
---------------------------------------------------------------------

CREATE TABLE TakeawayOrders
(
    OrderID      int      NOT NULL,
    TakeawayDate datetime NOT NULL,
)

ALTER TABLE TakeawayOrders
    ADD CONSTRAINT OrderNumber
        FOREIGN KEY (OrderID)
            REFERENCES Orders (OrderID)

-- Order Contents --
---------------------------------------------------------------------

CREATE TABLE OrderContents
(
    OrderID  int NOT NULL,
    MealID   int NOT NULL,
    Quantity int NOT NULL,
    CONSTRAINT ValidQuantity CHECK (Quantity > 0),
    CONSTRAINT OrderContentsPK PRIMARY KEY (OrderID, MealID)
)

ALTER TABLE OrderContents
    ADD CONSTRAINT OrdersNumber
        FOREIGN KEY (OrderID)
            REFERENCES Orders (OrderID)

ALTER TABLE OrderContents
    ADD CONSTRAINT OrdersMeals
        FOREIGN KEY (MealID)
            REFERENCES Meals (MealID)

-- Restaurant --
---------------------------------------------------------------------

CREATE TABLE Restaurant
(
    NIP        varchar(10) NOT NULL,
    Country    varchar(25) NOT NULL,
    City       varchar(35) NOT NULL,
    Address    varchar(35) NOT NULL,
    PostalCode int         NOT NULL,
    CONSTRAINT NIPCheck CHECK (NIP like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT PostalCodeCheck CHECK (PostalCode like '[0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT AddressCheck CHECK (Address not like '%[^a-zA-Z0-9. ]%'),
    CONSTRAINT CityCheck CHECK (City not like '%[^a-zA-Z ]%'),
    CONSTRAINT CountryCheck CHECK (Country not like '%[^a-zA-Z ]%'),
    CONSTRAINT RestaurantPK PRIMARY KEY (NIP)

)

-- Invoices --
---------------------------------------------------------------------

CREATE TABLE Invoices
(
    InvoiceID     int         NOT NULL IDENTITY (1, 1),
    OrderID       int         NOT NULL,
    RestaurantNIP varchar(10) NOT NULL,

    CONSTRAINT InvoicesPK PRIMARY KEY (InvoiceID)
)

ALTER TABLE Invoices
    ADD CONSTRAINT RestaurantNIP_fk
        FOREIGN KEY (RestaurantNIP) REFERENCES Restaurant (NIP)

ALTER TABLE Invoices
    ADD CONSTRAINT InvoiceOrder_fk
        FOREIGN KEY (OrderID) REFERENCES Orders (OrderID)


-- Tables --
---------------------------------------------------------------------

CREATE TABLE Tables
(
    TableID  int          NOT NULL IDENTITY (1, 1),
    Seats    int          NOT NULL,
    Location varchar(255) NOT NULL,

    CONSTRAINT Tables_pk PRIMARY KEY (TableID),
    CONSTRAINT PositiveSeats CHECK (Seats > 0)
)

-- Reservations --
---------------------------------------------------------------------

CREATE TABLE Reservations
(
    ReservationID     int      NOT NULL IDENTITY (1, 1),
    OrderID           int      NOT NULL,
    CustomerID        int      NOT NULL,
    TableID           int      NOT NULL,
    PlacementDate     datetime NOT NULL,
    ArrivalDate       datetime NOT NULL,
    Duration          time     NOT NULL,
    NumberOfCustomers int      NOT NULL,
    Status            varchar(20) NOT NULL,

    CONSTRAINT ReservationsPK PRIMARY KEY (ReservationID),
    CONSTRAINT PositiveNumberOfCustomers CHECK (NumberOfCustomers > 0),
    CONSTRAINT ReservationStatusEnum CHECK (Status IN ('Pending', 'Complete'))
)

ALTER TABLE Reservations
    ADD CONSTRAINT ReservationOrder_fk
        FOREIGN KEY (OrderID) REFERENCES Orders (OrderID)

ALTER TABLE Reservations
    ADD CONSTRAINT ReservationCustomer_fk
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

ALTER TABLE Reservations
    ADD CONSTRAINT ReservationTable_fk
        FOREIGN KEY (TableID) REFERENCES Tables (TableID)

-- Individual Reservations --
---------------------------------------------------------------------

CREATE TABLE IndividualReservations
(
    ReservationID int          NOT NULL,
    PaymentMethod varchar(255) NOT NULL,
    Paid          bit          NOT NULL,

    CONSTRAINT IndividualReservationsPK PRIMARY KEY (ReservationID),
)

ALTER TABLE IndividualReservations
    ADD CONSTRAINT IndividualToGeneral_fk
        FOREIGN KEY (ReservationID) REFERENCES Reservations (ReservationID)

-- Company Reservations --
---------------------------------------------------------------------

CREATE TABLE CompanyReservation
(
    ReservationID int NOT NULL,

    CONSTRAINT CompanyReservation_pk PRIMARY KEY (ReservationID),
)

ALTER TABLE CompanyReservation
    ADD CONSTRAINT CompanyToGeneral_fk
        FOREIGN KEY (ReservationID) REFERENCES Reservations (ReservationID)

-- Reservation Employees --
---------------------------------------------------------------------

CREATE TABLE ReservationEmployees
(
    ReservationID int NOT NULL,
    EmployeeID    int NOT NULL,

    CONSTRAINT ReservationEmployees_pk PRIMARY KEY (ReservationID, EmployeeID),
)

ALTER TABLE ReservationEmployees
    ADD CONSTRAINT ReservationEmployee_fk
        FOREIGN KEY (EmployeeID) REFERENCES IndividualCustomers (CustomerID)

ALTER TABLE ReservationEmployees
    ADD CONSTRAINT ReservationID_fk
        FOREIGN KEY (ReservationID) REFERENCES Reservations (ReservationID)

-- Discounts --
---------------------------------------------------------------------

CREATE TABLE Discounts
(
    DiscountID        int         NOT NULL IDENTITY (1, 1),
    CustomerID        int         NOT NULL,
    DiscountType      int         NOT NULL,
    DiscountValue     float       NOT NULL,
    StartDate         date        NOT NULL,
    EndDate           date,
    Status            varchar(20) NOT NULL,
    OrdersAccumulated int         NOT NULL,
    MoneyAccumulated  money       NOT NULL,

    CONSTRAINT DiscountsPK PRIMARY KEY (DiscountID),
    CONSTRAINT ValidDiscountType CHECK (DiscountType BETWEEN 1 AND 2),
    CONSTRAINT ValidDiscountValue CHECK (DiscountValue BETWEEN 0 AND 1),
    CONSTRAINT EndDateForDiscount2 CHECK (DiscountType = 1 OR EndDate IS NOT NULL),
    CONSTRAINT ValidDateRelation CHECK (EndDate > StartDate),
    CONSTRAINT StatusEnum CHECK (Status IN ('Counting', 'Active', 'Deactivated'))
)

ALTER TABLE Discounts
    ADD CONSTRAINT DiscountCustomer_fk
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

-- Config --
---------------------------------------------------------------------

CREATE TABLE Config
(
    IntroduceDate             date  NOT NULL,
    ChangeDate                date,
    MinReservationValue       float NOT NULL,
    MinOrdersForReservation   int   NOT NULL,
    OrdersForDiscount1        int   NOT NULL,
    MinOrderValueForDiscount1 float NOT NULL,
    Discount1Value            float NOT NULL,
    OrdersValueForDiscount2   float NOT NULL,
    Discount2Value            float NOT NULL,
    Discount2DurationDays     int   NOT NULL,

    CONSTRAINT ConfigPK PRIMARY KEY (IntroduceDate, ChangeDate),
    CONSTRAINT MinReservationValuePositive CHECK (MinReservationValue > 0),
    CONSTRAINT MinOrdersForReservationPositive CHECK (MinOrdersForReservation > 0),

    CONSTRAINT OrdersForDiscount1Positive CHECK (OrdersForDiscount1 > 0),
    CONSTRAINT MinOrderValueForDiscount1Positive CHECK (MinOrderValueForDiscount1 > 0),
    CONSTRAINT ValidDiscount1Value CHECK (Discount1Value BETWEEN 0 AND 1),

    CONSTRAINT OrdersValueForDiscount2Positive CHECK (OrdersValueForDiscount2 > 0),
    CONSTRAINT ValidDiscount2Value CHECK (Discount2Value BETWEEN 0 AND 1),
    CONSTRAINT Discount2DurationDaysPositive CHECK (Discount2DurationDays > 0),
)

-- Meals History --
---------------------------------------------------------------------

CREATE TABLE MealsHistory
(
    ChangeDate date         NOT NULL,
    MealID     int          NOT NULL,
    MealName   varchar(255) NOT NULL,
    MealPrice  int          NOT NULL,
    CategoryID int          NOT NULL,

    CONSTRAINT MealsHistoryPK PRIMARY KEY (ChangeDate, MealID)
)

ALTER TABLE MealsHistory
    ADD CONSTRAINT MealRecordToCurrent_fk
        FOREIGN KEY (MealID) REFERENCES Meals (MealID)

-- Menu History --
---------------------------------------------------------------------

CREATE TABLE MenuHistory
(
    MealID        int  NOT NULL,
    IntroduceDate date NOT NULL,
    DurationDays  int  NOT NULL,

    CONSTRAINT MenuHistoryPK PRIMARY KEY (MealID, IntroduceDate),
    CONSTRAINT DurationDaysPositive CHECK (DurationDays > 0)
)

ALTER TABLE MenuHistory
    ADD CONSTRAINT MenuRecordToCurrent_fk
        FOREIGN KEY (MealID) REFERENCES Meals (MealID)

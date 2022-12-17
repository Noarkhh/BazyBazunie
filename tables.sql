-- Category
---------------------------------------------------------------------

CREATE TABLE Category
(
    CategoryID   int          NOT NULL,
    CategoryName varchar(55)  NOT NULL,
    Description  varchar(255) NOT NULL,
    CONSTRAINT CategoryCheck CHECK (CategoryName not like '%[^a-zA-Z ]%')
        CONSTRAINT CategoryPK PRIMARY KEY (CategoryID)
)

-- Meals --
---------------------------------------------------------------------

CREATE TABLE Meals
(
    CategoryID int         NOT NULL,
    MealID     int         NOT NULL,
    NameMeals  varchar(55) NOT NULL,
    Price      money       NOT NULL,
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
)


ALTER TABLE CurrentMenu
    ADD CONSTRAINT MenuPosition
        FOREIGN KEY (MealID)
            REFERENCES Meals (MealID)

-- Orders --
---------------------------------------------------------------------

CREATE TABLE Orders
(
    OrderID    int      NOT NULL,
    CustomerID int      NOT NULL,
    OrderDate  datetime NOT NULL,

    CONSTRAINT OrdersPK PRIMARY KEY (OrderID)
)

ALTER TABLE Orders
    ADD CONSTRAINT OrdersCostumer
        FOREIGN KEY (CustomerID)
            REFERENCES Customers (CustomerID)

-- Takeaway Orders --
---------------------------------------------------------------------

CREATE TABLE TakeawayOrders
(
    OrderID      int      NOT NULL,
    TakeawayDate datetime NOT NULL,
    CONSTRAINT ValidDate CHECK (TakeawayDate > GETDATE())
)

ALTER TABLE OrdersTakeaways
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
    OrderID       INT          NOT NULL,
    InvoiceID     varchar(255) NOT NULL,
    RestaurantNIP varchar(10)  NOT NULL,

    CONSTRAINT InvoicesPK PRIMARY KEY (OrderID)
)

ALTER TABLE Invoice
    ADD CONSTRAINT RestaurantNIP
        FOREIGN KEY (RestaurantNIP)
            REFERENCES Restaurant (NIP)

-- Individual Customers --
---------------------------------------------------------------------

CREATE TABLE IndividualCustomers
(
    CustomerID   int          NOT NULL,
    CustomerName varchar(255) NOT NULL,

    CONSTRAINT CustomersPK PRIMARY KEY (CustomerID),
)

ALTER TABLE IndividualCustomers
    ADD CONSTRAINT
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

-- Orders --
---------------------------------------------------------------------

CREATE TABLE Orders
(
    OrderID    int      NOT NULL,
    CustomerID int      NOT NULL,
    OrderDate  datetime NOT NULL,

    CONSTRAINT OrdersPK PRIMARY KEY (OrderID),
)

ALTER TABLE Orders
    ADD CONSTRAINT
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

-- Reservations --
---------------------------------------------------------------------

CREATE TABLE Reservations
(
    ReservationID     int      NOT NULL,
    OrderID           int      NOT NULL,
    CustomerID        int      NOT NULL,
    TableID           int      NOT NULL,
    PlacementDate     datetime NOT NULL,
    ArrivalDate       datetime NOT NULL,
    Duration          time     NOT NULL,
    NumberOfCustomers int      NOT NULL,

    CONSTRAINT ReservationsPK PRIMARY KEY (ReservationID),
    CONSTRAINT PositiveNumberOfCustomers CHECK (NumberOfCustomers > 0)
)

ALTER TABLE Reservations
    ADD CONSTRAINT
        FOREIGN KEY (OrderID) REFERENCES Orders (OrderID)

ALTER TABLE Reservations
    ADD CONSTRAINT
        FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

ALTER TABLE Reservations
    ADD CONSTRAINT
        FOREIGN KEY (TableID) REFERENCES Tables (TableID)

-- Individual Reservations --
---------------------------------------------------------------------

CREATE TABLE IndividualReservations
(
    ReservationID int          NOT NULL,
    PaymentMethod varchar(255) NOT NULL,
    Paid          int          NOT NULL,

    CONSTRAINT IndividualReservationsPK PRIMARY KEY (ReservationID),
    CONSTRAINT PaidIsBool CHECK (Paid BETWEEN 0 AND 1)
)

ALTER TABLE IndividualReservations
    ADD CONSTRAINT
        FOREIGN KEY (ReservationID) REFERENCES Reservations (ReservationID)

-- Discounts --
---------------------------------------------------------------------

CREATE TABLE Discounts
(
    DiscountID    int   NOT NULL,
    CustomerID    int   NOT NULL,
    DiscountType  int   NOT NULL,
    DiscountValue float NOT NULL,
    StartDate     date  NOT NULL,
    EndDate       date,

    CONSTRAINT DiscountsPK PRIMARY KEY (DiscountID),
    CONSTRAINT ValidDiscountType CHECK (DiscountType BETWEEN 1 AND 2),
    CONSTRAINT ValidDiscountValue CHECK (DiscountValue BETWEEN 0 AND 1),
    CONSTRAINT EndDateForDiscount2 CHECK (DiscountType = 1 OR EndDate IS NOT NULL),
    CONSTRAINT ValidDateRelation CHECK (EndDate > StartDate)
)

ALTER TABLE Discounts
    ADD CONSTRAINT
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



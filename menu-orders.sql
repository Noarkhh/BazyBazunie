CREATE TABLE Category(
    CategoryID   int          NOT NULL,
    CategoryName varchar(55) NOT NULL,
    Description  varchar(255) NOT NULL,
    CONSTRAINT CategoryCheck CHECK (CategoryName not like '%[^a-zA-Z ]%')
    CONSTRAINT CategoryPK PRIMARY KEY (CategoryID)
)

CREATE TABLE Meals(
    CategoryID int          NOT NULL,
    MealID     int          NOT NULL,
    NameMeals  varchar(55) NOT NULL,
    Price      money        NOT NULL,
    CONSTRAINT ErrorPrice CHECK (Price > 0),
    CONSTRAINT NameMealsCheck CHECK (NameMeals not like '%[^a-zA-Z ]%'),
    CONSTRAINT MealsPK PRIMARY KEY (MealID)
)


CREATE TABLE CurrentMenu(
    IntroduceDate date NOT NULL,
    MealID        int  NOT NULL,
)


CREATE TABLE OrdersTakeaways
(
    OrderID      int      NOT NULL,
    TakeawayDate datetime NOT NULL,
    CONSTRAINT ValidDate CHECK (TakeawayDate > GETDATE())
)


CREATE TABLE Orders(
    OrderID    int      NOT NULL,
    CustomerID int      NOT NULL,
    OrderDate  datetime NOT NULL,

    CONSTRAINT OrdersPK PRIMARY KEY (OrderID)
)


create table OrderContents(
    OrderID  INT    NOT NULL,
    MealID   INT    NOT NULL,
    Quantity INT    NOT NULL,
    CONSTRAINT ValidQuantity CHECK (Quantity > 0)
)

CREATE TABLE Restaurant(
    NIP           varchar(10)   NOT NULL,
    Country       varchar(25)   NOT NULL
    City          varchar(35)   NOT NULL,
    Address       varchar(35)   NOT NULL,
    PostalCode    int           NOT NULL,
    CONSTRAINT NIPCheck CHECK (NIP like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT PostalCodeCheck CHECK (PostalCode like '[0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT AddressCheck    CHECK (Address not like '%[^a-zA-Z0-9. ]%'),
    CONSTRAINT CityCheck       CHECK (City not like '%[^a-zA-Z ]%'),
    CONSTRAINT CountryCheck       CHECK (Country not like '%[^a-zA-Z ]%'),
    CONSTRAINT RestaurantPK PRIMARY KEY (NIP)
    
)

CREATE TABLE Invoices(
    OrderID       INT           NOT NULL,
    Invoiceld     varchar(255)  NOT NULL,
    RestaurantNIP varchar(10)    NOT NULL 
)


ALTER TABLE Invoice
    ADD CONSTRAINT RestaurantNIP
        FOREIGN KEY (RestaurantNIP)
            REFERENCES Restaurant(NIP)

ALTER TABLE OrderContents
    ADD CONSTRAINT OrdersNumber
        FOREIGN KEY (OrderID)
            REFERENCES Orders(OrderID)


ALTER TABLE OrderContents
    ADD CONSTRAINT OrdersMeals
        FOREIGN KEY (MealID)
            REFERENCES Meals(MealID)

ALTER TABLE Meals
    ADD CONSTRAINT CategoryMenuItems
        FOREIGN KEY (CategoryID)
            REFERENCES Category (CategoryID)

ALTER TABLE CurrentMenu
    ADD CONSTRAINT MenuPosition
        FOREIGN KEY (MealID)
            REFERENCES Meals(MealID)

ALTER TABLE OrdersTakeaways
    ADD CONSTRAINT OrderNumber
        FOREIGN KEY (OrderID)
            REFERENCES Orders(OrderID)

ALTER TABLE Orders
    ADD CONSTRAINT OrdersCostumer
        FOREIGN KEY (CustomerID)
            REFERENCES Customers(CustomerID)

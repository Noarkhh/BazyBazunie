CREATE TABLE IndividualClients (
    CustomerID   int          NOT NULL,
    CustomerName varchar(255) NOT NULL,

    CONSTRAINT Customers_pk PRIMARY KEY (CustomerID),
    CONSTRAINT FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
)

CREATE TABLE Orders (
    OrderID    int      NOT NULL,
    CustomerID int      NOT NULL,
    OrderDate  datetime NOT NULL,

    CONSTRAINT Orders_pk PRIMARY KEY (OrderID),
    CONSTRAINT FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)

)

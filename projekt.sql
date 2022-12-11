CREATE TABLE Customers
(
    CustomerID  int             NOT NULL,
    Email       varchar(255)    NOT NULL,
    Phone       char(12)        NOT NULL,
    City        varchar(255)    NOT NULL,
    Street      varchar(255)    NOT NULL,
    PostalCode  varchar(255)    NOT NULL,

    CONSTRAINT ValidPostalCode CHECK (PostalCode LIKE
        '[0-9][0-9]-[0-9][0-9][0-9]'),
    CONSTRAINT ValidEmail CHECK (Email LIKE '%@%'),
    CONSTRAINT ValidPhone CHECK (Phone LIKE
        '+[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT Customers_pk PRIMARY KEY (ClientID)
)

CREATE TABLE Employees
(
    EmployeeID  int     NOT NULL,
    CompanyID  int     NOT NULL,

    CONSTRAINT Employees_pk PRIMARY KEY (EmployeeID),
    CONSTRAINT Employees_pk PRIMARY KEY (CompanyID),
    CONSTRAINT FOREIGN KEY (EmployeeID) REFERENCES IndividualClients (EmployeeID),
    CONSTRAINT FOREIGN KEY (EmployeeID) REFERENCES ReservationEmployees (EmployeeID),
    CONSTRAINT FOREIGN KEY (CompanyID) REFERENCES CompanyClients (CompanyID)
)

CREATE TABLE CompanyClients
(
    ClientID int NOT NULL,
    Name    varchar(255) NOT NULL,
    NIP     char(10) NOT NULL,

    CONSTRAINT CompanyClients_pk PRIMARY KEY (ClientID),
    CONSTRAINT ValidNIP CHECK ( NIP LIKE
        '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)

CREATE TABLE ReservationEmployees
(
    ReservationID   int     NOT NULL,
    EmployeeID      int     NOT NULL,

    CONSTRAINT ReservationEmployees_pk PRIMARY KEY (ReservationID),
    CONSTRAINT ReservationEmployees_pk PRIMARY KEY (EmployeeID),
    CONSTRAINT FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID),
    CONSTRAINT FOREIGN KEY (ReservationID) REFERENCES CompanyReservation (ReservationID)
)

CREATE TABLE CompanyReservation
(
    ReservationID int NOT NULL,

    CONSTRAINT CompanyReservation_pk PRIMARY KEY (ReservationID),
    CONSTRAINT FOREIGN KEY (ReservationID) REFERENCES ReservationEmployees (ReservationID)
)

CREATE TABLE Tables
(
    TableID int NOT NULL,
    Seats int NOT NULL,
    Location varchar(255) NOT NULL,

    CONSTRAINT Tables_pk PRIMARY KEY (TableID)
)
-- Wyświetla zniżki (i ich typ) wykorzystane w danym roku --
CREATE VIEW DiscountPerYear AS
    SELECT DISTINCT DiscountID,
           Type,
           YEAR(OrderDate) as Year
    FROM Discounts D
    INNER JOIN IndividualCustomers I on I.CustomerID = D.CustomerID
    INNER JOIN Customer C on I.CustomerID = C.CustomerID
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    GROUP BY Year, Type
go

-- Wyświetla wszystkie znizki (ich typ) przyznane w kazdym miesiacu --
CREATE VIEW DiscountMonthly AS
    SELECT Type,
           YEAR(OrderDate) as Year,
           MONTH(OrderDate) as Month
    FROM Discounts D
    INNER JOIN IndividualCustomers I on I.CustomerID = D.CustomerID
    INNER JOIN Customer C on I.CustomerID = C.CustomerID
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    GROUP BY Year, Month, Type
go

-- Wyświetla ilość zniżek przyznanych w danym roku i miesiącu
CREATE VIEW DiscountCountMonthly AS
    SELECT Type,
           YEAR(OrderDate) as Year,
           MONTH(OrderDate) as Month
           COUNT(D.DiscountID) as DiscountCount
    FROM Discounts D
    INNER JOIN IndividualCustomers I on I.CustomerID = D.CustomerID
    INNER JOIN Customer C on I.CustomerID = C.CustomerID
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    GROUP BY Year, Month, Type
go

-- Wyświetla informacje o kliencie i ilości jego zamówień
CREATE VIEW CustomerInfo AS
    SELECT C.CustomerID,
           C.City + ', ' + C.PostalCode + ', ' + C.Street as address,
           COUNT(O.OrderID)
    FROM Customers C
    INNER JOIN Orders O on O.CustomerID = C.CustomerID
    GROUP BY C.CustomerID, C.City + ', ' + C.PostalCode + ', ' + C.Street
go

-- Wyświetla ile zamówień złożyli poszczególni pracownicy firm
CREATE VIEW CompanyCustomersOrders AS
    SELECT C.CustomerID,
           COUNT(O.OrderID)
    FROM Customers C
    INNER JOIN Orders O on O.CustomerID = C.CustomerID
    LEFT JOIN CompanyCustomers CC on CC.CustomerID = C.CustomerID
    GROUP BY C.CustomerID
go

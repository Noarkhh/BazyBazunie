CREATE VIEW Menu AS
SELECT M.NameMeals, M.Price, C.CategoryName FROM CurrentMenu AS Curr
    LEFT JOIN Meals AS M ON M.MealID = Curr.MealID
    INNER JOIN Category C ON C.CategoryID = M.CategoryID

WHERE DATEDIFF(DAY,GETDATE(),Curr.IntroduceDate) <= 14;

CREATE VIEW OrdersForToday AS
SELECT  M.NameMeals, M.Price,AC.Quantity, o.OrderDate FROM Orders AS o
    INNER JOIN OrderContents AC ON AC.OrderID = o.OrderID
        INNER JOIN Meals AS M ON M.MealID = AC.MealID
WHERE DATEDIFF(DAY,GETDATE(),o.OrderDate) = 0

CREATE VIEW MealInfo AS
    SELECT C.CategoryName, M.NameMeals, C.Description FROM Meals AS M
        INNER JOIN Category C on M.CategoryID = C.CategoryID

CREATE VIEW NumberOfOrders AS
SELECT C.customerID, COUNT(O.OrderID) AS NumbersOrders FROM Customers C
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
GROUP BY C.CustomerID


CREATE VIEW RankOfMeals as
SELECT M.NameMeals, COUNT(OC.Quantity) as OrdersQuantity FROM Orders O
    INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
        INNER JOIN Meals M on M.MealID = OC.MealID
WHERE DATEDIFF(DAY,GETDATE(),O.OrderDate) <= 14
GROUP BY M.MealID,M.NameMeals

CREATE VIEW OrdersToPay AS
SELECT O.OrderID, R.CustomerID, O.OrderDate FROM Orders O
    INNER JOIN Reservations R ON O.OrderID = R.OrderID
    INNER JOIN IndividualReservations IR ON IR.ReservationID = R.ReservationID
WHERE IR.Paid = 0 AND R.Status='Pending'


CREATE VIEW OrdersInfo AS
SELECT O.OrderID,M.NameMeals,O.CustomerID FROM Orders O
    INNER JOIN OrderContents OC ON OC.OrderID = O.OrderID
        INNER JOIN Meals M ON M.MealID = OC.MealID
GROUP BY O.OrderID,O.CustomerID,M.NameMeals


CREATE VIEW LastVisibleMeals AS
SELECT M.NameMeals,M.Price,IntroduceDate FROM MenuHistory
    INNER JOIN Meals M ON MenuHistory.MealID = M.MealID
ORDER BY IntroduceDate DESC OFFSET 0 ROWS


CREATE VIEW MaxPrice AS
SELECT MAX(MealPrice) AS MaxPrice, MealID FROM MealsHistory
GROUP BY MealID

CREATE VIEW MinPrice AS
SELECT MIN(MealPrice) AS MinPrice, MealID FROM MealsHistory
GROUP BY MealID

CREATE VIEW AvgPrice AS
SELECT AVG(MealPrice) AS AvgPrice, MealID FROM MealsHistory
GROUP BY MealID

CREATE VIEW SeeCurrentMenu AS
SELECT M.NameMeals, M.Price, C.CategoryName FROM Meals M
INNER JOIN CurrentMenu CM ON M.MealID = CM.MealID
INNER JOIN Category C ON C.CategoryID = M.CategoryID


CREATE VIEW ReservedSeatsPerDay AS
SELECT YEAR(ArrivalDate) AS Y, MONTH(ArrivalDate) AS M, DAY(ArrivalDate) AS D, SUM(NumberOfCustomers) AS SumOfCustomers FROM Reservations
GROUP BY YEAR(ArrivalDate), MONTH(ArrivalDate), DAY(ArrivalDate)

CREATE VIEW AverageReservedSeats AS
SELECT YEAR(ArrivalDate) AS Y, MONTH(ArrivalDate) AS M, DAY(ArrivalDate) AS D, AVG(NumberOfCustomers) AS AvgOfCustomers FROM Reservations
GROUP BY YEAR(ArrivalDate), MONTH(ArrivalDate), DAY(ArrivalDate)


-- Wyświetla zniżki (i ich typ) wykorzystane w danym roku --
CREATE VIEW DiscountPerYear AS
    SELECT DISTINCT
           DiscountType,
           YEAR(OrderDate) as Year
    FROM Discounts D
    INNER JOIN IndividualCustomers I on I.CustomerID = D.CustomerID
    INNER JOIN Customers C on I.CustomerID = C.CustomerID
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    GROUP BY YEAR(OrderDate), DiscountType

-- Wyświetla wszystkie znizki (ich typ) przyznane w kazdym miesiacu --
CREATE VIEW DiscountMonthly AS
    SELECT DiscountType,
           YEAR(OrderDate) as Year,
           MONTH(OrderDate) as Month
    FROM Discounts D
    INNER JOIN IndividualCustomers I on I.CustomerID = D.CustomerID
    INNER JOIN Customers C on I.CustomerID = C.CustomerID
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    GROUP BY YEAR(OrderDate), MONTH(OrderDate), DiscountType

-- Wyświetla ilość zniżek przyznanych w danym roku i miesiącu
CREATE VIEW DiscountCountMonthly AS
    SELECT DiscountType,
           YEAR(OrderDate) as Year,
           MONTH(OrderDate) as Month,
           COUNT(D.DiscountID) as DiscountCount
    FROM Discounts D
    INNER JOIN IndividualCustomers I on I.CustomerID = D.CustomerID
    INNER JOIN Customers C on I.CustomerID = C.CustomerID
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
    GROUP BY YEAR(OrderDate), MONTH(OrderDate), DiscountType

-- Wyświetla informacje o kliencie i ilości jego zamówień
CREATE VIEW CustomerInfo AS
    SELECT C.CustomerID,
           C.City + ', ' + C.PostalCode + ', ' + C.Street as address,
           COUNT(O.OrderID) AS AmountOfOrders
    FROM Customers C
    INNER JOIN Orders O on O.CustomerID = C.CustomerID
    GROUP BY C.CustomerID, C.City + ', ' + C.PostalCode + ', ' + C.Street

-- Wyświetla ile zamówień złożyli poszczególni pracownicy firm
CREATE VIEW CompanyCustomersOrders AS
    SELECT C.CustomerID,
           COUNT(O.OrderID) AS AmountOfOrders
    FROM Customers C
    INNER JOIN Orders O on O.CustomerID = C.CustomerID
    LEFT JOIN CompanyCustomers CC on CC.CustomerID = C.CustomerID
    GROUP BY C.CustomerID





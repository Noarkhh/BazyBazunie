CREATE VIEW CurrentMenu AS
SELECT M.Name, M.Price, C.CategoryName
    FROM CurrentMenu AS Curr 
        LEFT JOIN Meals AS M ON M.MealID = Curr.MealID
WHERE DATEDIFF(DAY,GETDATE(),Curr.IntroduceDate) <= 14;

CREATE VIEW OrdersForToday AS
SELECT  M.Name, M.Price,AC.Quantity, o.OrderDate FROM Orders AS o 
    INNER JOIN OrderContents AC ON AC.OrderID = o.OrderID
        INNER JOIN Meals AS M ON M.MealID = AC.MealID
WHERE DATEDIFF(DAY,GETDATE(),o.OrderDate) = 0

CREATE VIEW MealInfo AS
    SELECT C.CategoryName, M.Name, C.Description FROM Meals AS M
        INNER JOIN Categories C on M.CategoryID = C.CategoryID
GROUP BY MealID

create view TotalValues as
SELECT O.OrderID,C.CustomerID,SUM(OC.Quantity * M.Price) * (1-ISNULL(
    (SELECT TOP 1 CAST(D.Value AS FLOAT)/100 FROM Discount D
    WHERE D.StartingDate <= GETDATE()
    ORDER BY D.StartingDate DESC))) AS TotalValue FROM Customers C
        INNER JOIN Orders O ON C.CustomerID = O.CustomerID
            INNER JOIN OrderContents OC ON O.OrderID = OC.OrderID
                INNER JOIN Meals M ON OC.MealID = M.MealID
                    LEFT JOIN Discounts D ON C.CustomerID = D.CustomerID
GROUP BY C.CustomerID, O.OrderID, D.StartingDate, D.Type


CREATE VIEW NumberOfOrders AS
SELECT C.customerID, COUNT(O.OrderID) AS NumbersOrders FROM Customers C
    INNER JOIN Orders O on C.CustomerID = O.CustomerID
GROUP BY C.CustomerID


CREATE VIEW RankOfMeals as
SELECT M.Name, COUNT(OC.Quantity) as OrdersQuantity FROM Orders O
    INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
        INNER JOIN Meals M on M.MealID = OC.MealID
WHERE DATEDIFF(DAY,GETDATE(),O.OrderDate) <= 14
GROUP BY M.MealID,M.Name

CREATE VIEW OrdersToPay AS
SELECT O.OrderID, R.CustomerID, O.OrderDate,FROM Orders O 
    INNER JOIN Reservations R ON O.OrderID = R.OrderID
        INNER JOIN IndividualReservation IR WHERE IR.ReservationID = R.ReservationID 
WHERE IR.Prepaid = 0


CREATE VIEW OrdersInfo AS
SELECT O.OrderID,M.Name,O.CustomerID FROM Orders O
    INNER JOIN OrderContents OC ON OC.OrderID = O.OrderID
        INNER JOIN Meals M ON M.MealID = OC.MealID
GROUP BY O.OrderID,O.CustomerID,M.Name


CREATE VIEW LastVisableMeals AS
SELECT M.Name,M.Price,ChangeDate FROM MealsHistory
    INNER JOIN Meals M ON M.MealID = OC.MealID
ORDER BY ChangeDate DESC
GROUP By M.MealID

CREATE VIEW MaxPrice AS
SELECT MAX(Price),MealID FROM MealsHistory
GROUP BY MealID

CREATE VIEW MinPrice AS
SELECT MIN(Price),MealID FROM MealsHistory
GROUP BY MealID

CREATE VIEW AvgPrice AS
SELECT AVG(Price),MealID FROM MealsHistory
GROUP BY MealID





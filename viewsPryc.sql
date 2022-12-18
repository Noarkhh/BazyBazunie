CREATE VIEW Menu AS
SELECT M.Name, M.Price, C.CategoryName FROM Meals M
INNER JOIN CurrentMenu CM ON M.MealID = CM.MealID
INNER JOIN Categories C ON C.CategoryID = M.CategoryID


CREATE VIEW ReservedSeatsPerDay AS
SELECT YEAR(ArrivalDate) AS Y, MONTH(ArrivalDate) AS M, DAY(ArrivalDate) AS D, SUM(NumberOfCustomers)
GROUP BY Y, M, D

CREATE VIEW AverageReservedSeats AS
SELECT YEAR(ArrivalDate) AS Y, MONTH(ArrivalDate) AS M, DAY(ArrivalDate) AS D, AVG(NumberOfCustomers)
GROUP BY Y, M, D



CREATE FUNCTION getAvgCurrentMenuPrice()
RETURNS float AS
    BEGIN
        RETURN
            (SELECT AVG(M.Price)
             FROM CurrentMenu CR
             LEFT JOIN Meals M on M.MealID = CR.MealID)
    end
go


CREATE FUNCTION getClientDiscounts(@date date)
    RETURNS TABLE AS
        RETURN
        SELECT DISTINCT DiscountType, DiscountValue, StartDate, EndDate, Status
        FROM Discounts
    WHERE (MONTH(StartDate) = MONTH(@date) AND YEAR(StartDate) = YEAR(@date) ) OR
          (MONTH(EndDate) = MONTH(@date) AND YEAR(EndDate) = YEAR(@date))
go

grant select on getClientDiscounts to worker
go



CREATE FUNCTION dbo.getClientOrders(@customerID int)
    RETURNS TABLE AS
        RETURN
        SELECT O.OrderID, O.OrderDate, SUM(M.Price * OC.Quantity * (1-Discount)) as Price
        FROM Orders O
        LEFT JOIN OrderContents OC on O.OrderID = OC.OrderID
        LEFT JOIN Meals M on OC.MealID = M.MealID
        GROUP BY O.OrderID, O.OrderDate, O.CustomerID
        HAVING O.CustomerID = @customerID
go



CREATE FUNCTION FreeTables(@StartTime datetime, @Duration time, @Seats int)
RETURNS TABLE AS
    RETURN

    SELECT Tables.TableID FROM (SELECT DISTINCT Tables.TableID FROM Tables
            INNER JOIN Reservations R2 ON Tables.TableID = R2.TableID
            WHERE ((ArrivalDate < @StartTime AND
                    @StartTime < ArrivalDate + CAST(Duration AS datetime))
                       OR
                   (ArrivalDate < @StartTime + CAST(@Duration AS datetime) AND
                    @StartTime + CAST(@Duration AS datetime) < ArrivalDate + CAST(Duration AS datetime))
                       OR
                    @StartTime < ArrivalDate AND
                    ArrivalDate < @StartTime + CAST(@Duration AS datetime)
                   OR Seats < @Seats) AND R2.Status='Pending') AS Taken
    RIGHT JOIN Tables ON Tables.TableID=Taken.TableID
    WHERE Taken.TableID IS NULL
go

grant select on getFreeTables to Customer
go

grant select on getFreeTables to worker
go


CREATE FUNCTION getIndividualClientsWithMostReservations(@val int, @date date)
RETURNS TABLE AS
    RETURN
    SELECT DISTINCT TOP (@val)  C.CustomerID, C.Street, C.City, C.PostalCode, C.Phone, COUNT(R.ReservationID) as Reservations
    FROM Reservations R
    LEFT JOIN Customers C on C.CustomerID = R.CustomerID
    LEFT JOIN Orders O on O.CustomerID = C.CustomerID
    GROUP BY C.Street, C.City, C.PostalCode, C.Phone, C.CustomerID, R.PlacementDate
    HAVING MONTH(R.PlacementDate) = MONTH(@date) AND YEAR(R.PlacementDate) = YEAR(@date)
ORDER BY COUNT(R.ReservationID)
go


CREATE FUNCTION getMealsSoldAtLeastXTimes(@val int)
RETURNS TABLE AS
    RETURN
    SELECT COUNT(OC.MealID) as NumberSold, M.NameMeals
    FROM Meals M
    INNER JOIN OrderContents OC on M.MealID = OC.MealID
GROUP BY M.NameMeals
go


CREATE FUNCTION getMenuItemsByDate(@date date)
RETURNS TABLE AS
    RETURN
    SELECT M.NameMeals, C.CategoryName, M.Price, MH.IntroduceDate
    FROM Meals M
    INNER JOIN MenuHistory MH ON M.MealID = MH.MealID
    INNER JOIN Category C on C.CategoryID = M.CategoryID
WHERE DATEDIFF(day, @date, MH.IntroduceDate) < MH.DurationDays
  AND DATEDIFF(day, @date, MH.IntroduceDate) >=0
go


CREATE FUNCTION getOrdersWithHigherValue(@val float)
RETURNS TABLE AS
    RETURN
    SELECT O.OrderID, SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
    FROM Orders O
    INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
    INNER JOIN Meals M on M.MealID = OC.MealID
GROUP BY O.OrderID
HAVING SUM(M.Price * OC.Quantity * (1 - O.Discount)) > @val
go


CREATE FUNCTION getOrderValue(@id int)
    RETURNS float AS
    BEGIN
        RETURN
            (SELECT SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
            FROM Orders O
            INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
            INNER JOIN Meals M on M.MealID = OC.MealID
            GROUP BY O.OrderID
        HAVING O.OrderID = @id)
    end
go



CREATE FUNCTION getThisDayOrdersValue(@date date)
RETURNS TABLE AS
    RETURN
    SELECT O.OrderID, SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
    FROM Orders O
    INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
    INNER JOIN Meals M on M.MealID = OC.MealID
GROUP BY O.OrderID, OrderDate
HAVING O.OrderDate = @date
go



CREATE FUNCTION getThisMonthOrdersValue(@date date)
RETURNS TABLE AS
    RETURN
    SELECT O.OrderID, SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
    FROM Orders O
    INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
    INNER JOIN Meals M on M.MealID = OC.MealID
GROUP BY O.OrderID, OrderDate
HAVING MONTH(O.OrderDate) = MONTH(@date)
go



CREATE FUNCTION getThisYearTotalIncome(@date date)
RETURNS float AS
    BEGIN
        RETURN
            (SELECT SUM(M.Price * OC.Quantity * (1 - O.Discount)) as TotalValue
            FROM Meals M
            INNER JOIN OrderContents OC on M.MealID = OC.MealID
            INNER JOIN Orders O on O.OrderID = OC.OrderID
            WHERE YEAR(@date) = YEAR(O.OrderDate))
    end
go


CREATE FUNCTION getWeeklyClientDiscounts(@date date)
    RETURNS TABLE AS
        RETURN
        SELECT DISTINCT DiscountType, DiscountValue, StartDate, EndDate, Status
        FROM Discounts
    WHERE (DATEPART(week, StartDate) = DATEPART(week, @date) AND YEAR(StartDate) = YEAR(@date) ) OR
          (DATEPART(week, EndDate) = DATEPART(week, @date) AND YEAR(EndDate) = YEAR(@date))
go



CREATE FUNCTION getWeeklyReservations(@date date)
RETURNS TABLE AS
    RETURN
    SELECT DISTINCT C.CustomerID, C.Street, C.City, C.PostalCode, C.Phone, COUNT(R.ReservationID) as Reservations
    FROM Reservations R
    LEFT JOIN Customers C on C.CustomerID = R.CustomerID
    LEFT JOIN Orders O on O.CustomerID = C.CustomerID
    GROUP BY C.Street, C.City, C.PostalCode, C.Phone, C.CustomerID, R.PlacementDate
    HAVING DATEPART(week, R.PlacementDate) = DATEPART(week, @date) AND YEAR(R.PlacementDate) = YEAR(@date)
go

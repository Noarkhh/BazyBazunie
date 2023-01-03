CREATE FUNCTION getMenuItemsByDate(@date date)
RETURNS TABLE AS
    RETURN
    SELECT M.NameMeals, C.CategoryName, M.Price, MH.IntroduceDate
    FROM Meals M
    INNER JOIN MenuHistory MH ON M.MealID = MH.MealID
    INNER JOIN Category C on C.CategoryID = M.CategoryID
WHERE DATEDIFF(day, @date, MH.IntroduceDate) < MH.DurationDays
  AND DATEDIFF(day, @date, MH.IntroduceDate) >=0


CREATE FUNCTION getThisDayOrdersValue(@date date)
RETURNS TABLE AS
    RETURN
    SELECT O.OrderID, SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
    FROM Orders O
    INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
    INNER JOIN Meals M on M.MealID = OC.MealID
GROUP BY O.OrderID, OrderDate
HAVING O.OrderDate = @date


CREATE FUNCTION getThisMonthOrdersValue(@date date)
RETURNS TABLE AS
    RETURN
    SELECT O.OrderID, SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
    FROM Orders O
    INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
    INNER JOIN Meals M on M.MealID = OC.MealID
GROUP BY O.OrderID, OrderDate
HAVING MONTH(O.OrderDate) = MONTH(@date)


CREATE FUNCTION getOrdersWithHigherValue(@val float)
RETURNS TABLE AS
    RETURN
    SELECT O.OrderID, SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
    FROM Orders O
    INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
    INNER JOIN Meals M on M.MealID = OC.MealID
GROUP BY O.OrderID
HAVING SUM(M.Price * OC.Quantity * (1 - O.Discount)) > @val


CREATE FUNCTION getMealsSoldAtLeastXTimes(@val int)
RETURNS TABLE AS
    RETURN
    SELECT COUNT(OC.MealID) as NumberSold, M.NameMeals
    FROM Meals M
    INNER JOIN OrderContents OC on M.MealID = OC.MealID
GROUP BY M.NameMeals


CREATE FUNCTION getXMostPopularMeals(@val int)
RETURNS TABLE AS
    RETURN
    SELECT DISTINCT TOP (@val) M.MealID, SUM(OC.Quantity)
    FROM Meals M
    INNER JOIN OrderContents OC on M.MealID = OC.MealID
GROUP BY M.MealID
ORDER BY SUM(OC.Quantity)


CREATE FUNCTION getXIndividualClientsWithTheMostExpensiveOrders(@val int)
RETURNS TABLE AS
    RETURN
    SELECT DISTINCT TOP (@val) IC.CustomerName, C.Street, C.City, C.PostalCode, C.Phone, SUM(M.Price * OC.Quantity * (1 - O.Discount))
    FROM IndividualCustomers IC
    LEFT JOIN Customers C on IC.CustomerID = C.CustomerID
    LEFT JOIN Orders O on IC.CustomerID = O.CustomerID
    LEFT JOIN OrderContents OC on O.OrderID = OC.OrderID
    LEFT JOIN Meals M on OC.MealID = M.MealID
GROUP BY IC.CustomerName, C.Street, C.City, C.PostalCode, C.Phone
ORDER BY SUM(M.Price * OC.Quantity * (1 - O.Discount))


CREATE FUNCTION getIndividualClientsWithMostReservations(@val int)
RETURNS TABLE AS
    RETURN
    SELECT DISTINCT TOP (@val)  IC.CustomerName, C.Street, C.City, C.PostalCode, C.Phone, COUNT(IR.ReservationID)
    FROM IndividualReservations IR
    LEFT JOIN ReservationEmployees RE on RE.ReservationID = IR.ReservationID
    LEFT JOIN IndividualCustomers IC on RE.EmployeeID = IC.CustomerID
    LEFT JOIN Employees E on IC.CustomerID = E.EmployeeID
    LEFT JOIN CompanyCustomers CC on E.CompanyID = CC.CustomerID
    LEFT JOIN Customers C on C.CustomerID = CC.CustomerID
    GROUP BY IC.CustomerName, C.Street, C.City, C.PostalCode, C.Phone
ORDER BY COUNT(IR.ReservationID)


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

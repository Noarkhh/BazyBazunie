alter trigger Sea_Food_Check_TR
    on OrderContents
    for insert
    as begin
    set NOCOUNT ON;

    IF(Select Top 1 O.OrderID
       From OrderContents inner join Meals M on M.MealID = OrderContents.MealID
       inner join Category C on C.CategoryID = M.CategoryID
       inner join Orders O on OrderContents.OrderID = O.OrderID
       inner join TakeawayOrders T on O.OrderID = T.OrderID
       INNER JOIN Reservations R on O.OrderID = R.OrderID
       INNER JOIN TakeawayOrders TaO on O.OrderID = TaO.OrderID
       where CategoryName like 'SeaFood'
        and ((datename(weekday, O.OrderDate) like 'Thursday' and datediff(day, O.OrderDate, R.ArrivalDate) <= 2)
           or (datename(weekday, O.OrderDate) like 'Friday' and datediff(day, O.OrderDate, R.ArrivalDate) <= 3)
           or (datename(weekday, O.OrderDate) like 'Saturday' and datediff(day, O.OrderDate, R.ArrivalDate) <= 4)
           or (datename(weekday, O.OrderDate) like 'Thursday' and datediff(day, O.OrderDate, TaO.TakeawayDate) <= 2)
           or (datename(weekday, O.OrderDate) like 'Friday' and datediff(day, O.OrderDate, TaO.TakeawayDate) <= 3)
           or (datename(weekday, O.OrderDate) like 'Saturday' and datediff(day, O.OrderDate, TaO.TakeawayDate) <= 4)
           )
    ) is not null
    BEGIN;
        THROW 601, 'This meals have to be ordered early', 1
    END
end
go

create trigger Tables_Person_Rser_TR
    on Reservations
    for insert, update
    as
    begin
        SET NOCOUNT ON;
            if(SELECT Top 1 ReservationID from
            (SELECT COUNT(T.Seats) as PersonNumber,R.ReservationID, R.NumberOfCustomers as Number
            from Reservations R inner join Tables T on R.TableID = T.TableID
            GROUP BY R.ReservationID,R.NumberOfCustomers) as PR where PersonNumber > Number)
            is not null
        begin
            throw 2011,'There is more people than seats', 1;
        end
end

create trigger Reservations_TR
    on Reservations
    for insert,update
    as
    begin
        if(Select ReservationID from Reservations
            where NumberOfCustomers < 2) is not null
        begin
            throw 2535,N'The number of people in the reservation must be greater than 1!',1
        end
        if(SELECT Pf.ReservationID FROM (Select Sum(M.Price*OC.Quantity) as price,R.ReservationID,R.CustomerID,MinReservationValue,MinOrdersForReservation
            from Reservations R
            inner join Orders O on O.OrderID = R.OrderID
            INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
            inner join Meals M on M.MealID = OC.MealID
            inner join MealsHistory MH on M.MealID = MH.MealID
            inner join Config on MH.ChangeDate = Config.ChangeDate
            group by R.ReservationID, R.CustomerID,MinOrdersForReservation,MinReservationValue) as Pf
            inner join (SELECT Sum(O.OrderID) as QuanitytyOrder,C.CustomerID FROM Orders O inner join Customers C on C.CustomerID = O.CustomerID
        group by C.CustomerID) as Wn ON  Pf.CustomerID = Wn.CustomerID
            where price < MinReservationValue or QuanitytyOrder < MinOrdersForReservation) is not null
        begin
            throw 2536,N'order quantity or order value is too small!',1
        end
end

create trigger Config_TR
    on Config
    for insert,update
    as
    begin
        if(Select TOP 1ChangeDate from Config
            where (DATEDIFF(day,IntroduceDate,ChangeDate) < 1)) is not null
        begin
            throw 2534, 'Dates configuration is not correct!',1
        end
end

CREATE TRIGGER Invalid_Menu_TR
ON OrderContents
AFTER UPDATE
AS
BEGIN
    IF EXISTS (SELECT TOP 1 OC.MealID, CM.MealID AS OrderMeal
               FROM OrderContents OC
               LEFT JOIN CurrentMenu CM ON OC.MealID = CM.MealID
               WHERE CM.MealID IS NULL)
    BEGIN
        THROW 52392, 'The dish is included in an unfinished order.', 1;
    END
END

CREATE TRIGGER Menu_Change_TR
ON CurrentMenu
AFTER UPDATE
AS
BEGIN
    DECLARE @MenuChangedDate DATETIME;

    SELECT @MenuChangedDate = MAX(CurrentMenu.IntroduceDate)
    FROM CurrentMenu;

    IF DATEDIFF(wk, @MenuChangedDate, GETDATE()) >= 2
    BEGIN
        RAISERROR('The menu has not been changed in over two weeks.', 16, 1);
    END
END

CREATE TRIGGER Change_Menu_TR
ON CurrentMenu
AFTER UPDATE
AS
BEGIN
    DECLARE @current_meal_id INT;

    DECLARE @last_introduce_date DATE;

    SET @current_meal_id = (SELECT MealID FROM inserted);

    set @last_introduce_date = (select Top 1 IntroduceDate from MenuHistory order by IntroduceDate desc)

    begin

    IF EXISTS (SELECT 1 FROM MenuHistory WHERE MealID = @current_meal_id and MenuHistory.IntroduceDate = @last_introduce_date)

        RAISERROR('Meal cannot be added to the menu because it has already been served', 16, 1);
    END
END

create trigger Correct_Discount_TR on Discounts
for insert
as
    begin
    if (select DiscountValue from inserted) < 0
        or (select DiscountValue from inserted) > 1
    BEGIN
    RAISERROR('Discount1Valuefrom is not correction', 16, 1)
    END
    end
go



CREATE PROCEDURE ActivateDiscount
@DiscountID int
AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT DiscountID FROM Discounts WHERE DiscountID=@DiscountID)
                BEGIN
                    THROW 52000, N'Znizka nie istnieje', 1
                END
            SET NOCOUNT ON

            DECLARE @EndDate datetime
            DECLARE @Type int
            DECLARE @DiscountValue float

            SELECT @Type=DiscountType FROM Discounts WHERE DiscountID=@DiscountID

            IF @Type=1
                BEGIN
                    SET @DiscountValue=(SELECT Discount1Value FROM Config WHERE ChangeDate IS NULL)
                END

            IF @Type=2
                BEGIN
                    SET @EndDate=DATEADD(DAY, (SELECT Discount2DurationDays FROM Config WHERE ChangeDate IS NULL), GETDATE())
                    SET @DiscountValue=(SELECT Discount2Value FROM Config WHERE ChangeDate IS NULL)
                END


            UPDATE Discounts
            SET Status='Active', StartDate=GETDATE(), EndDate=@EndDate, DiscountValue=@DiscountValue
            WHERE @DiscountID=DiscountID

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd aktywowania zniżki: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.ActivateDiscount TO worker
GO


    CREATE PROCEDURE AddCategory
    @CategoryName varchar(55),
    @Description varchar(255)
AS
    BEGIN
        BEGIN TRY
            IF EXISTS(SELECT * FROM Category WHERE @CategoryName = CategoryName)
                BEGIN
                    THROW 52000, N'Kategoria jest już dodana', 1
                END
            SET NOCOUNT ON;
            INSERT INTO Category
            VALUES (@CategoryName, @Description)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodwania kategorii: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.AddCategory TO Moderator
GO

GRANT EXECUTE ON dbo.AddCategory TO worker
GO

CREATE PROCEDURE AddCustomer
    @Email varchar(255),
    @Phone char(12),
    @City varchar(255),
    @Street varchar(255),
    @PostalCode varchar(255),
    @Name varchar(255),
    @Type varchar(10),
    @IsEmployee bit,
    @EmployeeCompany varchar(255),
    @NIP char(10)
AS
    BEGIN
        BEGIN TRY
            IF @Type!='Individual' AND @Type!='Company'
                BEGIN
                    THROW 52000, N'Niepoprawny typ klienta', 1
                END

            IF @Type='Individual' AND @IsEmployee=1 AND
               NOT EXISTS(SELECT * FROM CompanyCustomers WHERE Name=@EmployeeCompany)
                BEGIN
                    THROW 52000, N'Niepoprawna firma pracownika', 1
                END

            IF @Type='Individual' AND EXISTS(SELECT * FROM IndividualCustomers WHERE @Name = CustomerName)
                BEGIN
                    THROW 52000, N'Klient indywidualny już w bazie', 1
                END

            IF @Type='Company' AND EXISTS(SELECT * FROM CompanyCustomers WHERE @Name = Name)
                BEGIN
                    THROW 52000, N'Klient firmowy już w bazie', 1
                END
            DECLARE @CustomerID int

            SET NOCOUNT ON;
            INSERT INTO Customers
            VALUES (@Email, @Phone, @City, @Street, @PostalCode)

            SET @CustomerID = SCOPE_IDENTITY()

            IF @Type='Company'
                BEGIN
                    INSERT INTO CompanyCustomers
                    VALUES (@CustomerID, @Name, @NIP)
                END

            IF @Type='Individual'
                BEGIN
                    INSERT INTO IndividualCustomers
                    VALUES (@CustomerID, @Name)
                    EXEC AddDiscount 1, @CustomerID
                    EXEC AddDiscount 2, @CustomerID

                    IF @IsEmployee=1
                        BEGIN
                            DECLARE @CompanyID int
                            SELECT @CompanyID = CustomerID FROM CompanyCustomers WHERE Name=@EmployeeCompany

                            INSERT INTO Employees
                            VALUES (@CustomerID, @CompanyID)
                        END
                END
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodwania klienta: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.AddCustomer TO worker
GO

CREATE PROCEDURE AddDiscount
@Type int,
@CustomerID int
AS
    BEGIN
        BEGIN TRY
            IF @Type NOT IN (1, 2)
                BEGIN
                    THROW 52000, N'Zly typ znizki', 1
                END
            IF NOT EXISTS(SELECT CustomerID FROM Customers WHERE CustomerID=@CustomerID)
                BEGIN
                    THROW 52000, N'Brak podanego klienta', 1
                END
            SET NOCOUNT ON

            INSERT INTO Discounts
            VALUES (@CustomerID, @Type, 0, NULL, NULL, 'Counting', 0, 0)

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodwania zniżki: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.AddDiscount TO Moderator
GO

CREATE PROCEDURE AddEmployeeToReservation
@EmployeeName varchar(255),
@ReservationID int
AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM IndividualCustomers WHERE CustomerName=@EmployeeName)
                BEGIN
                    THROW 52000, N'Brak pracownika w bazie klientów', 1
                END
            DECLARE @EmployeeID int = (SELECT CustomerID FROM IndividualCustomers WHERE CustomerName=@EmployeeName)
            DECLARE @CompanyID int = (SELECT CustomerID FROM Reservations WHERE ReservationID=@ReservationID)
            IF NOT EXISTS(SELECT * FROM Employees WHERE EmployeeID=@EmployeeID AND CompanyID=@CompanyID)
                BEGIN
                    THROW 52000, N'Podana osoba nie jest pracownikiem podanej firmy', 1
                END
            IF NOT EXISTS(SELECT * FROM CompanyReservation WHERE ReservationID=@ReservationID)
                BEGIN
                    THROW 52000, N'Podana razerwacja nie jest na firmę', 1
                END

            INSERT INTO ReservationEmployees
            VALUES (@ReservationID, @EmployeeID)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodawania pracownika do rezerwacji: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.AddEmployeeToReservation TO Customer
GO

GRANT EXECUTE ON dbo.AddEmployeeToReservation TO worker
GO

CREATE PROCEDURE AddMeal
    @MealName varchar(55),
    @Price int,
    @CategoryName varchar(255)
AS
    BEGIN
        BEGIN TRY
            IF EXISTS(SELECT * FROM Meals WHERE @MealName = NameMeals)
                BEGIN
                    THROW 52000, N'Posiłek jest już dodany', 1
                END
            IF NOT EXISTS(SELECT * FROM Category WHERE @CategoryName = CategoryName)
                BEGIN
                    THROW 52000, N'Nie ma takiej kategorii ', 1
                END
            DECLARE @CategoryID int
            SELECT @CategoryID = CategoryID FROM Category WHERE CategoryName = @CategoryName

            SET NOCOUNT ON;
            INSERT INTO Meals
            VALUES (@CategoryID, @MealName, @Price, 0)
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodwania posiłku: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.AddMeal TO Moderator
GO

GRANT EXECUTE ON dbo.AddMeal TO worker
GO

CREATE PROCEDURE AddTable
@Seats int,
@Location varchar(255)
AS
    BEGIN
        INSERT INTO Tables
        VALUES (@Seats, @Location)
    END
GO

GRANT EXECUTE ON dbo.AddTable TO Moderator
GO

CREATE PROCEDURE AddToOrder
@OrderID int,
@MealName varchar(55),
@Quantity int
AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID=@OrderID)
                BEGIN
                    THROW 52000, N'Brak zamówienia w bazie', 1
                END

            IF NOT EXISTS(SELECT * FROM Meals WHERE NameMeals=@MealName)
                BEGIN
                    THROW 52000, N'Brak posiłku w bazie', 1
                END
            SET NOCOUNT ON

            DECLARE @MealID int
            SELECT @MealID = MealID FROM Meals WHERE NameMeals=@MealName

            INSERT INTO OrderContents
            VALUES (@OrderID, @MealID, @Quantity)

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodwania do zamówienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.AddToOrder TO Customer
GO

GRANT EXECUTE ON dbo.AddToOrder TO Moderator
GO

GRANT EXECUTE ON dbo.AddToOrder TO worker
GO

CREATE PROCEDURE CancelReservation
@ReservationID int
AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Reservations WHERE ReservationID=@ReservationID)
                BEGIN
                    THROW 52000, N'Brak podanej rezerwacji', 1
                END

            IF (SELECT Status FROM Reservations WHERE ReservationID=@ReservationID)='Complete'
                BEGIN
                    THROW 52000, N'Rezerwacja już rozpatrzona', 1
                END

            SET NOCOUNT ON

            IF EXISTS(SELECT * FROM IndividualReservations WHERE ReservationID=@ReservationID)
                BEGIN
                    DELETE FROM IndividualReservations
                    WHERE ReservationID=@ReservationID
                END

            ELSE IF EXISTS(SELECT * FROM CompanyReservation WHERE ReservationID=@ReservationID)
                BEGIN
                    DELETE FROM ReservationEmployees
                    WHERE ReservationID=@ReservationID
                    DELETE FROM CompanyReservation
                    WHERE ReservationID=@ReservationID
                END

            DECLARE @OrderID int = (SELECT OrderID FROM Reservations WHERE ReservationID=@ReservationID)

            DELETE FROM OrderContents
            WHERE OrderID=@OrderID

            DELETE FROM Orders
            WHERE OrderID=@OrderID

            DELETE FROM Reservations
            WHERE ReservationID=@ReservationID


        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd anulowania rezerwacji: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.CancelReservation TO Moderator
GO

GRANT EXECUTE ON dbo.CancelReservation TO worker
GO

CREATE PROCEDURE CompleteOrder
@OrderID int
AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT OrderID FROM Orders WHERE OrderID=@OrderID)
                BEGIN
                    THROW 52000, N'Zamówienie nie istnieje', 1
                END
            SET NOCOUNT ON

            IF (SELECT Status FROM Orders WHERE OrderID=@OrderID)='Complete'
                BEGIN
                    THROW 52000, N'Zamówienie już potwierdzone', 1
                END

            DECLARE @CustomerID int
            SELECT @CustomerID=CustomerID FROM Orders WHERE OrderID=@OrderID

            DECLARE @Discount1ID int = (SELECT DiscountID FROM Discounts WHERE CustomerID=@CustomerID AND DiscountType=1)
            DECLARE @Discount2ID int = (SELECT DiscountID FROM Discounts WHERE CustomerID=@CustomerID AND DiscountType=2)

            UPDATE Orders
            SET Status='Complete'
            WHERE @OrderID=OrderID

            IF (SELECT EndDate FROM Discounts WHERE DiscountID=@Discount2ID) > GETDATE()
                BEGIN
                    UPDATE Discounts
                    SET Status='Deactivated'
                    WHERE DiscountID=@Discount2ID
                    EXEC AddDiscount 2, @CustomerID
                END

            IF (SELECT SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
                FROM Orders O
                INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
                INNER JOIN Meals M on M.MealID = OC.MealID
                WHERE O.OrderID = @OrderID
                GROUP BY O.OrderID) >= (SELECT MinOrderValueForDiscount1 FROM Config WHERE ChangeDate IS NULL)
                BEGIN
                    UPDATE Discounts
                    SET OrdersAccumulated += 1
                    WHERE DiscountID=@Discount1ID AND Status='Counting'
                END

            UPDATE Discounts
            SET MoneyAccumulated += (SELECT SUM(M.Price * OC.Quantity * (1 - O.Discount)) as OrderPrice
                                                        FROM Orders O
                                                        INNER JOIN OrderContents OC on O.OrderID = OC.OrderID
                                                        INNER JOIN Meals M on M.MealID = OC.MealID
                                                        WHERE O.OrderID = @OrderID
                                                        GROUP BY O.OrderID)
            WHERE DiscountID=@Discount2ID AND Status='Counting'

            IF (SELECT OrdersAccumulated FROM Discounts WHERE DiscountID=@Discount1ID) >= (SELECT OrdersForDiscount1 FROM Config WHERE ChangeDate IS NULL)
                BEGIN
                    EXEC ActivateDiscount @Discount1ID
                END

            IF (SELECT MoneyAccumulated FROM Discounts WHERE DiscountID=@Discount2ID) >= (SELECT OrdersValueForDiscount2 FROM Config WHERE ChangeDate IS NULL)
                BEGIN
                    EXEC ActivateDiscount @Discount2ID
                END

            DECLARE @RestaurantNIP varchar(10) = (SELECT TOP 1 NIP FROM Restaurant)
            INSERT INTO Invoices
            VALUES (@OrderID, @RestaurantNIP)

            IF EXISTS(SELECT * FROM Reservations WHERE OrderID=@OrderID)
                BEGIN
                    UPDATE Reservations
                    SET Status='Complete'
                    WHERE OrderID=@OrderID
                END

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd potwierdzania zamówienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.CompleteOrder TO worker
GO

CREATE PROCEDURE CreateCompanyReservation
@OrderID int,
@ArrivalDate datetime,
@Duration time,
@Seats int
AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID=@OrderID)
                BEGIN
                    THROW 52000, N'Brak podanego zamówienia w bazie', 1
                END
            IF EXISTS(SELECT * FROM Reservations WHERE OrderID=@OrderID)
                BEGIN
                    THROW 52000, N'Istnieje już rezerwacja do podanego zamówienia', 1
                END

            DECLARE @CompanyID int = (SELECT CustomerID FROM Orders WHERE OrderID=@OrderID)

            IF NOT EXISTS(SELECT * FROM CompanyCustomers WHERE CustomerID=@CompanyID)
                BEGIN
                    THROW 52000, N'Podane zamównienie nie zostało złożone przez firmę', 1
                END

            IF EXISTS(SELECT * FROM TakeawayOrders WHERE OrderID=@OrderID)
                BEGIN
                    THROW 52000, N'Podane zamówienie zostało złożone na wynos', 1
                END
            IF NOT EXISTS(SELECT * FROM getFreeTables(@ArrivalDate, @Duration, @Seats))
                BEGIN
                    THROW 52000, N'Brak wolnych stolików', 1
                END

            DECLARE @TableID int
            SELECT TOP 1 @TableID = TableID FROM getFreeTables(@ArrivalDate, @Duration, @Seats)

            INSERT INTO Reservations
            VALUES (@OrderID, @CompanyID, @TableID, GETDATE(), @ArrivalDate, @Duration, @Seats, 'Pending')

            INSERT INTO CompanyReservation
            VALUES (SCOPE_IDENTITY())

            RETURN SCOPE_IDENTITY()

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd tworzenia rezerwacji: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.CreateCompanyReservation TO Customer
GO

GRANT EXECUTE ON dbo.CreateCompanyReservation TO Moderator
GO

GRANT EXECUTE ON dbo.CreateCompanyReservation TO worker
GO

CREATE PROCEDURE CreateIndividualReservation
@OrderID int,
@ArrivalDate datetime,
@Duration time,
@Seats int,
@PaymentMethod varchar(255),
@Paid bit

AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Orders WHERE OrderID=@OrderID)
                BEGIN
                    THROW 52000, N'Brak podanego zamówienia w bazie', 1
                END
            IF EXISTS(SELECT * FROM Reservations WHERE OrderID=@OrderID)
                BEGIN
                    THROW 52000, N'Istnieje już rezerwacja do podanego zamówienia', 1
                END
            DECLARE @CustomerID int = (SELECT CustomerID FROM Orders WHERE OrderID=@OrderID)
            IF NOT EXISTS(SELECT * FROM IndividualCustomers WHERE CustomerID=@CustomerID)
                BEGIN
                    THROW 52000, N'Podane zamównienie nie zostało złożone przez indywidualnego klienta', 1
                END

            IF EXISTS(SELECT * FROM TakeawayOrders WHERE OrderID=@OrderID)
                BEGIN
                    THROW 52000, N'Podane zamówienie zostało złożone na wynos', 1
                END
            IF NOT EXISTS(SELECT * FROM getFreeTables(@ArrivalDate, @Duration, @Seats))
                BEGIN
                    THROW 52000, N'Brak wolnych stolików', 1
                END

            SET NOCOUNT ON


            DECLARE @TableID int
            SELECT TOP 1 @TableID = TableID FROM getFreeTables(@ArrivalDate, @Duration, @Seats)

            INSERT INTO Reservations
            VALUES (@OrderID, @CustomerID, @TableID, GETDATE(), @ArrivalDate, @Duration, @Seats, 'Pending')

            INSERT INTO IndividualReservations
            VALUES (SCOPE_IDENTITY(), @PaymentMethod, @Paid)

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd tworzenia rezerwacji: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.CreateIndividualReservation TO Customer
GO

GRANT EXECUTE ON dbo.CreateIndividualReservation TO Moderator
GO

GRANT EXECUTE ON dbo.CreateIndividualReservation TO worker
GO

CREATE PROCEDURE CreateMenu
@NewMenu Menu READONLY
AS
    BEGIN
        BEGIN TRY

            IF DATEDIFF(DAY, CAST(GETDATE() AS date), (SELECT TOP 1 IntroduceDate FROM CurrentMenu)) < 14
                BEGIN
                    THROW 52000, N'Zbyt malo czasu od poprzedniej zmiany menu', 1
                END
            DECLARE @MenuLength int = (SELECT COUNT(*) FROM CurrentMenu)
            IF (SELECT COUNT(*) FROM @NewMenu INNER JOIN CurrentMenu ON CurrentMenu.MealID=[@NewMenu].MealID) > @MenuLength / 2
                BEGIN
                    THROW 52000, N'Mniej niż połowa posiłków zmieniona w stosunku do starego menu', 1
                END

            SET NOCOUNT ON
            DECLARE @DurationTime int = DATEDIFF(DAY, CAST(GETDATE() AS date), (SELECT TOP 1 IntroduceDate FROM CurrentMenu))

            INSERT INTO MenuHistory
            SELECT MealID, IntroduceDate, @DurationTime FROM CurrentMenu

            DELETE FROM CurrentMenu

            INSERT INTO CurrentMenu
            SELECT CAST(GETDATE() AS date), MealID FROM @NewMenu

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd Generowania menu: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.CreateMenu TO Moderator
GO

GRANT EXECUTE ON dbo.CreateMenu TO worker
GO

CREATE PROCEDURE StartEmptyOrder
@CustomerID int,
@TakeawayDate datetime = NULL
AS
    BEGIN
        BEGIN TRY
            IF NOT EXISTS(SELECT * FROM Customers WHERE CustomerID=@CustomerID)
                BEGIN
                    THROW 52000, N'Brak klienta w bazie', 1
                END
            SET NOCOUNT ON

            DECLARE @DiscountID int
            DECLARE @DiscountValue float
            DECLARE @DiscountType int
            DECLARE @OrderID int
            IF EXISTS(SELECT * FROM Discounts WHERE Status='Active' AND CustomerID=@CustomerID)
                BEGIN
                    SELECT TOP 1 @DiscountID = DiscountID, @DiscountValue = DiscountValue, @DiscountType = DiscountType FROM Discounts
                           WHERE Status='Active' AND CustomerID=@CustomerID
                           ORDER BY DiscountValue DESC
                END
            ELSE
                SET @DiscountValue = 0
                SET @DiscountType = 0

            INSERT INTO Orders
            VALUES (@CustomerID, GETDATE(), @DiscountValue, 'Pending')

            SET @OrderID = SCOPE_IDENTITY()

            IF @TakeawayDate IS NOT NULL
                BEGIN
                    INSERT INTO TakeawayOrders
                    VALUES (@OrderID, @TakeawayDate)
                END

            RETURN @OrderID

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd dodwania zamówienia: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO

GRANT EXECUTE ON dbo.StartEmptyOrder TO Customer
GO

CREATE PROCEDURE UpdateConfig
@NewMinReservationValue float = NULL,
@NewMinOrdersForReservation int = NULL,
@NewOrdersForDiscount1 int = NULL,
@NewMinOrderValueForDiscount1 float = NULL,
@NewDiscount1Value float = NULL,
@NewOrdersValueForDiscount2 float = NULL,
@NewDiscount2Value float = NULL,
@NewDiscount2DurationDays int = NULL

AS
BEGIN
    BEGIN TRY
        DECLARE @MinReservationValue float
        DECLARE @MinOrdersForReservation int
        DECLARE @OrdersForDiscount1 int
        DECLARE @MinOrderValueForDiscount1 float
        DECLARE @Discount1Value float
        DECLARE @OrdersValueForDiscount2 float
        DECLARE @Discount2Value float
        DECLARE @Discount2DurationDays int

        SELECT TOP 1 @MinReservationValue = MinReservationValue,
                     @MinOrdersForReservation = MinOrdersForReservation,
                     @OrdersForDiscount1 = OrdersForDiscount1,
                     @MinOrderValueForDiscount1 = MinOrderValueForDiscount1,
                     @Discount1Value = Discount1Value,
                     @OrdersValueForDiscount2 = OrdersValueForDiscount2,
                     @Discount2Value = Discount2Value,
                     @Discount2DurationDays = Discount2DurationDays
                     FROM Config
        ORDER BY IntroduceDate DESC

        UPDATE Config
        SET ChangeDate = GETDATE()
        WHERE ChangeDate IS NULL

        IF @NewMinReservationValue IS NOT NULL
            BEGIN
                SET @MinReservationValue = @NewMinReservationValue
            END

        IF @NewMinOrdersForReservation IS NOT NULL
            BEGIN
                SET @MinOrdersForReservation = @NewMinOrdersForReservation
            END

        IF @NewOrdersForDiscount1 IS NOT NULL
            BEGIN
                SET @OrdersForDiscount1 = @NewOrdersForDiscount1
            END

        IF @NewMinOrderValueForDiscount1 IS NOT NULL
            BEGIN
                SET @MinOrderValueForDiscount1 = @NewMinOrderValueForDiscount1
            END

        IF @NewDiscount1Value IS NOT NULL
            BEGIN
                SET @Discount1Value = @NewDiscount1Value
            END

        IF @NewOrdersValueForDiscount2 IS NOT NULL
            BEGIN
                SET @OrdersValueForDiscount2 = @NewOrdersValueForDiscount2
            END

        IF @NewDiscount2Value IS NOT NULL
            BEGIN
                SET @Discount2Value = @NewDiscount2Value
            END

        IF @NewDiscount2DurationDays IS NOT NULL
            BEGIN
                SET @Discount2DurationDays = @NewDiscount2DurationDays
            END

        INSERT INTO Config
        VALUES (GETDATE(), NULL,
                @MinReservationValue,
                @MinOrdersForReservation,
                @OrdersForDiscount1,
                @MinOrderValueForDiscount1,
                @Discount1Value,
                @OrdersValueForDiscount2,
                @Discount2Value,
                @Discount2DurationDays)

    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048) = N'Błąd aktualizowania konfiguracji: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
END
GO

CREATE PROCEDURE UpdateMeal
@MealName varchar(255),
@NewCategory varchar(255) = NULL,
@NewMealName varchar(255) = NULL,
@NewPrice money = NULL,
@Discontinued bit = 0
AS
    BEGIN
        BEGIN TRY
            DECLARE @MealID int = (SELECT MealID FROM Meals WHERE NameMeals=@MealName)
            IF NOT EXISTS(SELECT * FROM Category WHERE CategoryName=@NewCategory)
                BEGIN
                    THROW 52000, N'Brak podanej kategorii', 1
                END
            IF (SELECT Discontinued FROM Meals WHERE MealID=@MealID)=1
                BEGIN
                    THROW 52000, N'Posiłek wycofany', 1
                END
            IF @NewCategory IS NULL AND @NewMealName IS NULL AND @NewPrice IS NULL AND @Discontinued=0
                BEGIN
                    THROW 52000, N'Brak zmian', 1
                END

            SET NOCOUNT ON
            INSERT INTO MealsHistory
            SELECT CAST(GETDATE() AS date), @MealID, NameMeals, Price, CategoryID FROM Meals WHERE MealID=@MealID

            IF @NewCategory IS NOT NULL
                BEGIN
                    UPDATE Meals
                    SET CategoryID=(SELECT CategoryID FROM Category WHERE CategoryName=@NewCategory)
                    WHERE MealID=@MealID
                END

            IF @NewMealName IS NOT NULL
                BEGIN
                    UPDATE Meals
                    SET NameMeals=@NewMealName
                    WHERE MealID=@MealID
                END

            IF @NewPrice IS NOT NULL
                BEGIN
                    UPDATE Meals
                    SET Price=@NewPrice
                    WHERE MealID=@MealID
                END

            IF @Discontinued=1
                BEGIN
                    UPDATE Meals
                    SET Discontinued=1
                    WHERE MealID=@MealID
                END

        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd aktualizowania posiłku: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1;
        END CATCH
    END
GO



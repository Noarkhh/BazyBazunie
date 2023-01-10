create index Category_index
    on Category (CategoryName, CategoryID)
go

create index CompanyCustomers_index
    on CompanyCustomers (NIP, Name, CustomerID)
go 

create index Config_index
    on Config (IntroduceDate,ChangeDate)
go

create index CurrentMenu_index
    on CurrentMenu (IntroduceDate)
go

create index Customer_index
    on Customers (Phone,Email,CustomerID)
go

create index Discounts_index
    on Discounts (Status,StartDate, DiscountID)
go

create index Customer_info
    on IndividualCustomers (CustomerName,CustomerID)
go

create index Paid_index
    on IndividualReservations (Paid)
go

create index Price_meals_index
    on Meals (Price)
go

create index Meals_Change_index
    on MealsHistory (ChangeDate)
go

create index Menu_date_index
    on MenuHistory (IntroduceDate,DurationDays)
go

create index Order_quantity_index
    on OrderContents (Quantity, MealID)
go

create index Order_date_index
    on Orders (OrderDate)
go

create index Reservation_date_index
    on Reservations (PlacementDate, OrderID, TableID, CustomerID)
go

create index Seats_index
    on Tables (Seats)
go

create index Takeaway_Orders_index
    on TakeawayOrders (TakeawayDate, OrderID)
go



-- Pracownicy
grant select on OrdersInfo to worker

grant select on OrdersToPay to worker

grant select on CustomerInfo to worker

grant select on OrdersForToday to worker

grant select on NumberOfOrders to worker

grant select on SeeCurrentMenu to worker

GRANT SELECT ON Config TO Worker;

GRANT SELECT ON Discounts TO Worker;

GRANT SELECT ON Reservations TO Worker;

GRANT SELECT, UPDATE ON CurrentMenu TO Worker;

GRANT SELECT, UPDATE ON OrderContents TO Worker;

GRANT SELECT ON CompanyCustomers TO Worker;

GRANT SELECT ON Customers TO Worker;

GRANT SELECT ON StartEmptyOrder TO Worker;

GRANT SELECT ON Orders TO Worker;

GRANT EXECUTE ON GetOrderValue TO Worker;

GRANT SELECT ON GetClientOrders TO Worker;

GRANT SELECT, UPDATE ON Reservations TO Worker;

GRANT SELECT ON Tables TO Worker;

GRANT EXECUTE ON ActivateDiscount TO Worker;

GRANT EXECUTE ON AddCategory TO Worker;

GRANT EXECUTE ON AddCustomer TO Worker;

GRANT EXECUTE ON AddMeal TO Worker;

GRANT EXECUTE ON AddToOrder TO Worker;

GRANT EXECUTE ON CancelReservation TO Worker;

GRANT EXECUTE ON CompleteOrder TO Worker;

GRANT EXECUTE ON CreateCompanyReservation TO Worker;

GRANT EXECUTE ON CreateIndividualReservation TO Worker;

GRANT EXECUTE ON CreateMenu TO Worker;

GRANT SELECT ON GetFreeTables TO Worker;

GRANT EXECUTE ON AddEmployeeToReservation TO Worker;

--------------------------------------------
-- Klienci
GRANT SELECT ON CurrentMenu TO Customer

GRANT EXECUTE ON AddToOrder TO Customer

GRANT EXECUTE ON CreateIndividualReservation TO Customer

GRANT EXECUTE ON CreateCompanyReservation TO Customer

GRANT EXECUTE ON getOrderValue to Customer

GRANT SELECT ON getFreeTables to Customer

GRANT SELECT on Config to Customer

GRANT EXECUTE on StartEmptyOrder to Customer

GRANT EXECUTE on AddEmployeeToReservation to Customer


----------------------------------------------
--Moderator 
grant execute on AddTable to Moderator

grant execute on AddCategory to Moderator

grant execute on AddDiscount to Moderator

grant execute on AddMeal to Moderator

grant execute on CreateMenu to Moderator

grant execute on CancelReservation to Moderator

grant execute on CreateCompanyReservation  to Moderator

grant execute on CreateIndividualReservation to Moderator

grant execute on AddToOrder to Moderator

grant select on CurrentMenu to Moderator

grant select on Reservations to Moderator

grant select on MenuHistory to Moderator

grant select on MealsHistory to Moderator

grant select on Meals to Moderator

grant select on Config to Moderator

grant execute on ActivateDiscount to Moderator

grant select on RankOfMeals to Moderator

grant select on CustomerInfo to Moderator

grant select on MealInfo to Moderator

grant select on LastVisibleMeals to Moderator

grant select on AvgPrice to Moderator

-----------------------------------------------
-- Menadżer
grant execute on getAvgCurrentMenuPrice to Manager

grant select on getIndividualClientsWithMostReservations  to Manager

grant select on getMealsSoldAtLeastXTimes to Manager

grant select on getThisDayOrdersValue to Manager

grant select on getOrdersWithHigherValue  to Manager

grant select on getThisMonthOrdersValue  to Manager

grant execute on getThisYearTotalIncome to Manager

grant select on getWeeklyReservations to Manager

grant select on getWeeklyClientDiscounts to Manager

grant select on ReservedSeatsPerDay to Manager

grant select on RankOfMeals to Manager

grant select on DiscountMonthly to Manager

grant select on DiscountPerYear to Manager

grant select on CustomerInfo to Manager

grant select on OrdersForToday to Manager
-----------------------------------------------------
-- Procedure to add employee with address
CREATE OR ALTER PROCEDURE addEmployeeWithAddress
    @p_firstName VARCHAR(50),
    @p_lastName VARCHAR(50),
    @p_phoneNumber VARCHAR(20),
    @p_age INT,
    @p_sex VARCHAR(20),
    @p_employeeAddressCountry VARCHAR(50),
    @p_employeeAddressCity VARCHAR(50),
    @p_employeeAddressPostalCode VARCHAR(20),
    @p_employeeAddressStreet VARCHAR(50),
    @p_employeeAddressBuildingNumber VARCHAR(20),
    @p_salary FLOAT,
    @p_position VARCHAR(20)
AS
BEGIN
	INSERT INTO Addresses(	
		country,
		city,
		postalCode,
		street,
		buildingNumber
	)
	VALUES (
		@p_employeeAddressCountry,
		@p_employeeAddressCity,
		@p_employeeAddressPostalCode,
		@p_employeeAddressStreet,
		@p_employeeAddressBuildingNumber
	);
	
	DECLARE @addressId INT;
	SET @addressId = SCOPE_IDENTITY();

    INSERT INTO Employees(
		firstName,
		lastName ,
		phoneNumber,
		age,
		sex,
		addressId,
		salary,
		position
	)
	VALUES (
        @p_firstName,
        @p_lastName,
        @p_phoneNumber,
        @p_age,
        @p_sex,
        @addressId,
        @p_salary,
        @p_position
    );

END
Go

-- Procedute to book ticket with given seatNumber
CREATE OR ALTER PROCEDURE bookSpecifyTicket
	@p_flightId INT,
	@p_seatNumber INT,
	@p_passportNumber VARCHAR(20)
AS
BEGIN
	UPDATE Tickets
	SET IsBooked = 1
	FROM Tickets t
	INNER JOIN FlightTickets ft ON t.TicketId = ft.TicketId
	INNER JOIN Flights f ON ft.FlightId = f.flightId
 	WHERE SeatNumber = @p_seatNumber AND ft.FlightId = @p_flightId;
END
Go

-- Procedute to book first free ticket
CREATE OR ALTER PROCEDURE bookTicket
	@p_flightId INT,
	@p_passportNumber VARCHAR(20)
AS
BEGIN
	UPDATE Tickets
	SET IsBooked = 1
	FROM Tickets t
	INNER JOIN FlightTickets ft ON t.TicketId = ft.TicketId
	INNER JOIN Flights f ON ft.FlightId = f.flightId
 	WHERE SeatNumber = @p_seatNumber AND ft.FlightId = @p_flightId;
END
Go

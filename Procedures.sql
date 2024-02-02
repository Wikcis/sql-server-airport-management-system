USE AIRPORT;
Go

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
	DECLARE @v_passengerId INT;
	DECLARE @v_ticketId INT;
	
	SET @v_passengerId = (SELECT passengerId FROM Passengers WHERE passportNumber = @p_passportNumber);

	SET @v_ticketId = (SELECT TicketId FROM Tickets WHERE SeatNumber = @p_seatNumber);

	INSERT INTO PassengerTickets (PassengerId, TicketId)
	SELECT @v_passengerId, @v_ticketId
	WHERE @v_ticketId IN (SELECT TicketId FROM FlightTickets WHERE FlightId = @p_flightId);
END
Go


-- Procedute to book first free ticket
CREATE OR ALTER PROCEDURE bookTicket
	@p_flightId INT,
	@p_passportNumber VARCHAR(20)
AS
BEGIN
	DECLARE @v_passengerId INT;
	DECLARE @v_ticketId INT;

	SET @v_passengerId = (SELECT passengerId FROM Passengers WHERE passportNumber = @p_passportNumber);
	
	SET @v_ticketId = (
		SELECT TOP 1 ft.TicketId
		FROM FlightTickets ft
		WHERE ft.FlightId = @p_flightId AND ft.TicketId NOT IN (SELECT TicketId FROM PassengerTickets)
	);

	INSERT INTO PassengerTickets (PassengerId, TicketId)
	VALUES (@v_passengerId, @v_ticketId);
END
Go

-- Procedure to add tickets for every seat on the Plane
CREATE OR ALTER PROCEDURE addTicketsForFlight
	@p_flightId INT
AS
BEGIN
	DECLARE @NumberOfRows INT;
	DECLARE @NumberOfColumns INT;

	SELECT @NumberOfRows = numberOfRows, @NumberOfColumns = numberOfColumns
	FROM Planes
	WHERE planeId = (SELECT planeUsed FROM Flights WHERE flightId = @p_flightId);

	INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price, ModifiedDate, rowguid)
	SELECT 
		SYSDATETIME() AS timeOfDeparture,
		ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS SeatNumber,
		(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1) / @NumberOfColumns + 1 AS RowNumber,
		(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1) % @NumberOfColumns + 1 AS ColumnNumber,
		1 AS Class,
		10.0 AS Price,
		SYSDATETIME() AS ModifiedDate,
		NEWID() AS rowguid
	FROM master.dbo.spt_values v
	WHERE v.type = 'P' AND v.number BETWEEN 1 AND @NumberOfRows * @NumberOfColumns;

	INSERT INTO FlightTickets (FlightId, TicketId)
	SELECT @p_flightId AS FlightId, TicketId
	FROM Tickets
	WHERE TicketId BETWEEN SCOPE_IDENTITY() - @@ROWCOUNT + 1 AND SCOPE_IDENTITY();
END
GO

USE AIRPORT;
Go

-- Procedures ---------------------------------------------------------------------

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
	
	IF NOT EXISTS (
		SELECT * 
		FROM FLIGHTS 
		WHERE FlightId = @p_flightId
	)
	BEGIN
		print('There is not any flight with this id.')
		return;
	END;
	IF NOT EXISTS (
		SELECT * 
		FROM FlightTickets ft
		INNER JOIN Tickets t On ft.TicketId = t.TicketId 
		WHERE FlightId = @p_flightId AND SeatNumber = @p_seatNumber
	)
	BEGIN
		print('There is not any seat in this plane with this id.')
		return;
	END;
	IF NOT EXISTS (
		SELECT * 
		FROM Passengers 
		WHERE passportNumber = @p_passportNumber
	)
	BEGIN
		print('There is not any passenger with this passport number.')
		return;
	END;

	DECLARE @v_passengerId INT;
	DECLARE @v_ticketId INT;
	
	SET @v_passengerId = (SELECT passengerId FROM Passengers WHERE passportNumber = @p_passportNumber);

	SET @v_ticketId = (SELECT t.TicketId 
		FROM Tickets t 
		INNER JOIN FlightTickets ft ON ft.TicketId = t.TicketId 
		WHERE SeatNumber = @p_seatNumber AND ft.FlightId = @p_flightId
	);

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
	IF NOT EXISTS (
		SELECT * 
		FROM FLIGHTS 
		WHERE FlightId = @p_flightId
	)
	BEGIN
		print('There is not any flight with this id.');
		return;
	END;
	IF NOT EXISTS (
		SELECT * 
		FROM Passengers 
		WHERE passportNumber = @p_passportNumber
	)
	BEGIN
		print('There is not any passenger with this passport number.')
		return;
	END;
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
	IF NOT EXISTS (
		SELECT * 
		FROM FLIGHTS 
		WHERE FlightId = @p_flightId
	)
	BEGIN
		print('There is not any flight with this id.');
		return;
	END;	
    DECLARE @NumberOfRows INT;
    DECLARE @NumberOfColumns INT;
    DECLARE @timeOfDeparture DATE;

    SELECT @timeOfDeparture = timeOfDeparture FROM Flights;

    SELECT @NumberOfRows = numberOfRows, @NumberOfColumns = numberOfColumns
    FROM Planes
    WHERE planeId = (SELECT planeUsed FROM Flights WHERE flightId = @p_flightId);

    DECLARE @SeatNumber INT;
    DECLARE @RowNumber INT;
    DECLARE @ColumnNumber INT;

    DECLARE @Counter INT = 1;
	DECLARE @id INT = (SELECT TOP 1 TicketId FROM Tickets ORDER BY TicketId DESC);
    WHILE @Counter <= @NumberOfRows * @NumberOfColumns
    BEGIN
        SET @SeatNumber = @Counter;
        SET @RowNumber = (@Counter - 1) / @NumberOfColumns + 1;
        SET @ColumnNumber = (@Counter - 1) % @NumberOfColumns + 1;
        INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
        VALUES (
            @timeOfDeparture,
            @SeatNumber,
            @RowNumber,
            @ColumnNumber,
            1, 
            10.0
        );
		SET @id = @id + 1;
        INSERT INTO FlightTickets (FlightId, TicketId)
        VALUES (@p_flightId, @id);
        SET @Counter = @Counter + 1;
    END;
END;
GO

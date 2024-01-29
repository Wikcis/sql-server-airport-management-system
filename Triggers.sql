USE AIRPORT;
Go
-- Triggers ------------------------------------------------------------------------------

--Trigger to check if the ticket is available to book, so if it is booked
CREATE OR ALTER TRIGGER check_ticket_availability
ON PassengerTickets
FOR INSERT
AS
BEGIN
	DECLARE @p_ticketId INT;
	SET @p_ticketId = (SELECT ticketId FROM inserted);
    IF EXISTS (
        SELECT *
        FROM PassengerTickets pt
        WHERE pt.ticketId = @p_ticketId
    )
    BEGIN
        RAISERROR ('Ticket is already booked.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO PassengerTickets
        SELECT * FROM inserted;
    END;
END;
Go

--Trigger to check if the time of departure on the ticket is in the past
CREATE OR ALTER TRIGGER check_if_ticket_date_in_past
ON Tickets
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE i.timeOfDeparture < SYSDATETIME()
    )
    BEGIN
        RAISERROR ('Ticket has departure date in the past.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
        SELECT timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price
        FROM INSERTED;
    END;
    ELSE
    BEGIN
        UPDATE t
        SET t.timeOfDeparture = i.timeOfDeparture,
            t.SeatNumber = i.SeatNumber,
            t.RowNumber = i.RowNumber,
            t.ColumnNumber = i.ColumnNumber,
            t.Class = i.Class,
            t.Price = i.Price,
            t.ModifiedDate = i.ModifiedDate,
            t.rowguid = i.rowguid
        FROM Tickets t
        INNER JOIN INSERTED i ON t.TicketId = i.TicketId;
    END;
END;
GO


--Trigger to check if the departure is before arrival
CREATE OR ALTER TRIGGER check_if_departure_before_arrival
ON Flights
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE i.timeOfDeparture > i.timeOfArrival
    )
    BEGIN
        RAISERROR ('Time of departure must be before the arrival', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
        SELECT routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed
        FROM INSERTED;
	END;
	ELSE 
	BEGIN
        UPDATE f
		SET f.routeId = i.routeId,
			f.timeOfDeparture = i.timeOfDeparture,
			f.timeOfArrival = i.timeOfArrival,
			f.departurePlaceId = i.departurePlaceId,
			f.duration = i.duration,
			f.addedBy = i.addedBy,
			f.planeUsed = i.planeUsed,
			f.ModifiedDate = i.ModifiedDate,
			f.rowguid = i.rowguid
		FROM Flights f
		INNER JOIN INSERTED i ON f.FlightId = i.FlightId;
    END;
END;
Go

--Trigger to check if the source of the flight is different to destination
CREATE OR ALTER TRIGGER check_if_source_and_destination_different
ON Routes
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE i.sourceAirport != i.destinationAirport
    )
    BEGIN
        RAISERROR ('Destination of the flight must be different from source.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO Routes (sourceAirport, destinationAirport)
        SELECT sourceAirport, destinationAirport
        FROM INSERTED;
	END;
	ELSE 
	BEGIN
        UPDATE r
		SET r.sourceAirport = i.sourceAirport,
			r.destinationAirport = i.destinationAirport,
			r.ModifiedDate = i.ModifiedDate,
			r.rowguid = i.rowguid
		FROM Routes r
		INNER JOIN INSERTED i ON r.routeId = i.routeId;
    END;
END;
Go

--Trigger to check if the departure time of the flight is in the past
CREATE OR ALTER TRIGGER check_if_departure_in_past
ON Flights
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE i.timeOfDeparture < SYSDATETIME()
    )
    BEGIN
        RAISERROR ('Time of departure must be in the future.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
        SELECT routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed
        FROM INSERTED;
	END;
	ELSE 
	BEGIN
        UPDATE f
		SET f.routeId = i.routeId,
			f.timeOfDeparture = i.timeOfDeparture,
			f.timeOfArrival = i.timeOfArrival,
			f.departurePlaceId = i.departurePlaceId,
			f.duration = i.duration,
			f.addedBy = i.addedBy,
			f.planeUsed = i.planeUsed,
			f.ModifiedDate = i.ModifiedDate,
			f.rowguid = i.rowguid
		FROM Flights f
		INNER JOIN INSERTED i ON f.FlightId = i.FlightId;
    END;
END;
Go

--Trigger to check if the number of tickets is smaller or equal to capacity
CREATE OR ALTER TRIGGER check_if_number_of_tickets_smaller_or_equal_to_capacity
ON FlightTickets
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @FlightId INT;
    DECLARE @TotalSeats INT;
    DECLARE @OccupiedSeats INT;

    SELECT @FlightId = i.FlightId
    FROM INSERTED i;

    SELECT @TotalSeats = p.capacity
    FROM Flights f
    INNER JOIN Planes p ON f.planeUsed = p.planeId
    WHERE f.flightId = @FlightId;

    SELECT @OccupiedSeats = COUNT(*)
    FROM FlightTickets ft
    WHERE ft.FlightId = @FlightId;

    IF @OccupiedSeats > @TotalSeats
	BEGIN
        RAISERROR ('Number of tickets must be smaller or equal to number of seats.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO FlightTickets
        SELECT *
        FROM INSERTED;
	END;
	ELSE 
	BEGIN
        UPDATE ft
		SET ft.FlightId = i.FlightId,
			ft.TicketId = i.TicketId
		FROM FlightTickets ft
		INNER JOIN INSERTED i ON ft.TicketId = i.TicketId;
    END;
END;
Go

--Trigger to check if the ticket has unique row and column
CREATE OR ALTER TRIGGER check_if_ticket_is_unique
ON Tickets
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @FlightId INT;
	DECLARE @Row INT;
	DECLARE @Column INT;

    SELECT @FlightId = f.FlightId
    FROM INSERTED i
    INNER JOIN FlightTickets ft ON i.TicketId = ft.TicketId
	INNER JOIN Flights f ON ft.FlightId = f.flightId;

    SELECT @Row = i.RowNumber, @Column = i.ColumnNumber
    FROM inserted i;

    IF EXISTS (
		SELECT *
		FROM Tickets t 
		INNER JOIN FlightTickets ft ON t.TicketId = ft.TicketId
		INNER JOIN Flights f ON ft.FlightId = f.flightId
		WHERE f.flightId = @FlightId AND t.RowNumber = @Row AND t.ColumnNumber = @Column
		)
	BEGIN
        RAISERROR ('Ticket must have unique row and column in the same flight.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
        SELECT timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price
        FROM INSERTED;
	END;
	ELSE 
	BEGIN
        UPDATE t
		SET t.timeOfDeparture = i.timeOfDeparture,
			t.SeatNumber = i.SeatNumber,
			t.RowNumber = i.RowNumber,
			t.ColumnNumber = i.ColumnNumber,
			t.Class = t.Class,
			t.Price = i.Price,
			t.ModifiedDate = i.ModifiedDate,
			t.rowguid = i.rowguid
		FROM Tickets t
		INNER JOIN INSERTED i ON t.TicketId = i.TicketId;
    END;
END;
Go

--Trigger to check if the ticket has free seat
CREATE OR ALTER TRIGGER check_if_ticket_has_free_seat
ON FlightTickets
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @FlightId INT;
	DECLARE @TicketId INT;
	DECLARE @Seat INT;

    SELECT @FlightId = i.FlightId
    FROM INSERTED i;

	SELECT @TicketId = i.TicketId
    FROM INSERTED i;

    SELECT @Seat = t.SeatNumber
    FROM Tickets t
	WHERE t.TicketId = @TicketId;

    IF EXISTS (
		SELECT *
		FROM FlightTickets ft 
		INNER JOIN Tickets t ON t.TicketId = ft.TicketId
		INNER JOIN Flights f ON ft.FlightId = f.flightId
		WHERE f.flightId = @FlightId AND t.SeatNumber = @Seat
		)
	BEGIN
        RAISERROR ('Ticket must have unique seat in the same flight.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO FlightTickets (FlightId, TicketId)
        SELECT FlightId, TicketId
        FROM INSERTED;
	END;
	ELSE 
	BEGIN
        UPDATE ft
		SET ft.FlightId = i.FlightId,
			ft.TicketId = i.ticketId
		FROM FlightTickets ft
		INNER JOIN INSERTED i ON ft.TicketId = i.TicketId;
    END;
END;
Go

--Trigger to check if the number of rows times number of columns are equal to capacity
CREATE OR ALTER TRIGGER check_if_capacity_correct
ON Planes
FOR INSERT, UPDATE
AS
BEGIN

    IF EXISTS (
		SELECT 1
		FROM INSERTED i
		WHERE i.numberOfRows * i.numberOfColumns != i.capacity
	)
	BEGIN
        RAISERROR ('Number of tickets must be smaller or equal to number of seats.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO Planes (airlineCode, name, numberOfRows, numberOfColumns, capacity)
        SELECT airlineCode, name, numberOfRows, numberOfColumns, capacity
        FROM INSERTED;
	END;
	ELSE 
	BEGIN
        UPDATE p
		SET p.airlineCode = i.airlineCode,
			p.name = i.name,
			p.numberOfRows = i.numberOfRows,
			p.numberOfColumns = i.numberOfColumns,
			p.capacity = i.capacity,
			p.ModifiedDate = i.ModifiedDate,
			p.rowguid = i.rowguid
		FROM Planes p
		INNER JOIN INSERTED i ON p.planeId = i.planeId;
    END;
END;
Go

--Trigger to check if flight is added by flight manager
CREATE OR ALTER TRIGGER check_if_flight_added_by_flight_manager
ON Flights
FOR INSERT, UPDATE
AS
BEGIN

    IF EXISTS (
		SELECT 1
		FROM INSERTED i
		INNER JOIN Employees e ON i.addedBy = e.employeeId
		WHERE e.position = 'FlightManager'
	)
	BEGIN
        RAISERROR ('Only flight manager is authorized to add flights.', 16, 1);
    END;
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
		INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
        SELECT routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed
        FROM INSERTED;
	END;
	ELSE 
	BEGIN
        UPDATE f
		SET f.routeId = i.routeId,
			f.timeOfDeparture = i.timeOfDeparture,
			f.timeOfArrival = i.timeOfArrival,
			f.departurePlaceId = i.departurePlaceId,
			f.duration = i.duration,
			f.addedBy = i.addedBy,
			f.planeUsed = i.planeUsed,
			f.ModifiedDate = i.ModifiedDate,
			f.rowguid = i.rowguid
		FROM Flights f
		INNER JOIN INSERTED i ON f.FlightId = i.FlightId;
    END;
END;
Go

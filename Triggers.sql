USE AIRPORT;
Go
-- Triggers ------------------------------------------------------------------------------

--Trigger to check if the ticket is available to book, so if it is booked
CREATE OR ALTER TRIGGER check_ticket_availability
ON PassengerTickets
INSTEAD OF INSERT
AS
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM AvailableTickets at
		INNER JOIN INSERTED i ON at.TicketId = i.TicketId
	)
	BEGIN
		RAISERROR ('Ticket is already booked.', 16, 1);
	END;
	ELSE
	BEGIN
		INSERT INTO PassengerTickets
		SELECT * FROM inserted;
	END;
END;
Go

--Trigger to check if the time of departure on the ticket is in the past
CREATE OR ALTER TRIGGER check_if_ticket_date_in_past
ON Tickets
INSTEAD OF INSERT
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
END;
GO

--Trigger to check if the ticket has free seat, row and column and to check if number of tickets is smaller or equal to capacity
CREATE OR ALTER TRIGGER check_if_ticket_is_valid
ON FlightTickets
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @FlightId INT;
	DECLARE @TicketId INT;
	DECLARE @Seat INT;
	DECLARE @Row INT;
	DECLARE @Column INT;
	DECLARE @Capacity INT;

	SELECT @FlightId = i.FlightId
	FROM INSERTED i;

	SELECT @TicketId = i.TicketId
	FROM INSERTED i;
	
	SELECT @Row = t.RowNumber, @Column = t.ColumnNumber
	FROM inserted i
	INNER JOIN Tickets t ON t.TicketId = i.TicketId;

	SELECT @Seat = t.SeatNumber
	FROM Tickets t
	WHERE t.TicketId = @TicketId;

	SELECT @Capacity = p.capacity 
	FROM Planes p
	WHERE planeId = (SELECT planeUsed FROM Flights WHERE flightId = @FlightId);

	IF EXISTS (
		SELECT *
		FROM FlightTickets ft 
		INNER JOIN Tickets t ON t.TicketId = ft.TicketId
		WHERE ft.flightId = @FlightId AND (t.SeatNumber = @Seat OR (t.RowNumber = @Row AND t.ColumnNumber = @Column))
		)
	BEGIN
		RAISERROR ('Ticket must have unique seat, row, and column in the same flight.', 16, 1);
	END;
	ELSE IF (
		SELECT COUNT(*)
		FROM FlightTickets ft 
		WHERE ft.flightId = @FlightId
		) >= @Capacity 
	BEGIN
		RAISERROR ('Number of tickets must be smaller or equal to capacity', 16, 1);
	END;
	ELSE IF EXISTS (SELECT * FROM inserted)
	BEGIN
		INSERT INTO FlightTickets (FlightId, TicketId)
		SELECT FlightId, TicketId
		FROM INSERTED;
	END;
END;
Go

--Trigger to check if the source of the flight is different to destination
CREATE OR ALTER TRIGGER check_if_source_and_destination_different
ON Routes
INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS (
		SELECT 1
		FROM INSERTED i
		WHERE i.sourceAirport = i.destinationAirport
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
END;
Go

--Trigger to check if the number of rows times number of columns are equal to capacity
CREATE OR ALTER TRIGGER check_if_capacity_correct
ON Planes
INSTEAD OF INSERT
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
END;
Go

-- Trigger to check if the departure time of the flight is in the past
CREATE OR ALTER TRIGGER check_if_flight_is_valid
ON Flights
INSTEAD OF INSERT
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
	ELSE IF EXISTS (
		SELECT 1
		FROM INSERTED i
		WHERE i.timeOfDeparture > i.timeOfArrival
	)
	BEGIN
		RAISERROR ('Time of departure must be before the arrival', 16, 1);
	END;
	ELSE
	BEGIN
		INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
		SELECT routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed
		FROM INSERTED;
	END;
END;
Go
USE AIRPORT;
Go

-- TESTING ---------------------------------------------------------------------------------

-- Inserting data --------

-- Inserting terminals
INSERT INTO Terminals DEFAULT VALUES;
INSERT INTO Terminals DEFAULT VALUES;
INSERT INTO Terminals DEFAULT VALUES;
INSERT INTO Terminals DEFAULT VALUES;

-- Inserting gates
INSERT INTO Gates (TerminalId) VALUES (1);
INSERT INTO Gates (TerminalId) VALUES (1);
INSERT INTO Gates (TerminalId) VALUES (1);
INSERT INTO Gates (TerminalId) VALUES (2);
INSERT INTO Gates (TerminalId) VALUES (2);
INSERT INTO Gates (TerminalId) VALUES (3);
INSERT INTO Gates (TerminalId) VALUES (3);
INSERT INTO Gates (TerminalId) VALUES (4);

-- Inserting addresses
INSERT INTO Addresses (country, city, postalCode, street, buildingNumber) 
VALUES ('Country1', 'City1', '12345', 'Street1', '1A');
INSERT INTO Addresses (country, city, postalCode, street, buildingNumber) 
VALUES ('Country2', 'City2', '54321', 'Street2', '2B');

-- Inserting passengers
INSERT INTO Passengers (passportNumber, firstName, lastName, phoneNumber, age, sex, addressId)
VALUES ('AB123456', 'John', 'Doe', '123456789', 25, 'Male', 1);
INSERT INTO Passengers (passportNumber, firstName, lastName, phoneNumber, age, sex, addressId)
VALUES ('CD789012', 'Jane', 'Smith', '987654321', 30, 'Female', 2);

-- Inserting planes
INSERT INTO Planes (airlineCode, name, numberOfRows, numberOfColumns, capacity)
VALUES ('ABC', 'Plane1', 2, 3, 6);
INSERT INTO Planes (airlineCode, name, numberOfRows, numberOfColumns, capacity)
VALUES ('XYZ', 'Plane2', 25, 8, 200);

-- Inserting employees
INSERT INTO Employees (firstName, lastName, phoneNumber, age, sex, addressId, salary, position)
VALUES ('Bob', 'Johnson', '555-1234', 35, 'Male', 1, 50000, 'FlightManager');
INSERT INTO Employees (firstName, lastName, phoneNumber, age, sex, addressId, salary, position)
VALUES ('Alice', 'Williams', '555-5678', 28, 'Female', 2, 45000, 'GateManager');

-- Inserting airports
INSERT INTO Airports (name, addressId) 
VALUES ('Airport1', 1);
INSERT INTO Airports (name, addressId) 
VALUES ('Airport2', 2);

-- Inserting routes
INSERT INTO Routes (sourceAirport, destinationAirport)
VALUES (1, 2);
INSERT INTO Routes (sourceAirport, destinationAirport)
VALUES (2, 1);

-- Inserting departurePlaces
INSERT INTO DeparturePlaces (departureTerminalId, departureGateId)
VALUES (1, 1);
INSERT INTO DeparturePlaces (departureTerminalId, departureGateId)
VALUES (2, 2);

-- Inserting flights
INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
VALUES (1, '2024-10-10 10:10:10', '2024-10-10 15:10:10', 1, '5 hours', 1, 1);
INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
VALUES (2, DATEADD(HOUR, 10, GETDATE()), DATEADD(HOUR, 13, GETDATE()), 2, '3 hours', 2, 2);

-- Inserting tickets
INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
VALUES ('2024-10-10 10:10:10', 1, 1, 1, 1, 150.00);
INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
VALUES ('2024-10-10 10:10:10', 2, 2, 1, 2, 100.00);

-- Inserting FlightTickets
INSERT INTO FlightTickets (FlightId, TicketId)
VALUES (1, 1);
INSERT INTO FlightTickets (FlightId, TicketId)
VALUES (2, 2);

-- Inserting PassengerTickets
INSERT INTO PassengerTickets (PassengerId, TicketId)
VALUES (1, 1);
INSERT INTO PassengerTickets (PassengerId, TicketId)
VALUES (2, 2);

-- Inserting EventLogs
INSERT INTO EventLogs (loggedBy, loggedOn, status, source, message)
VALUES (1, 1, 'Success', 'System', 'Flight added successfully');
INSERT INTO EventLogs (loggedBy, loggedOn, status, source, message)
VALUES (2, 2, 'Error', 'System', 'Ticket not booked');

-- Selecting tables ------

SELECT * FROM Terminals;
SELECT * FROM Gates;
SELECT * FROM Addresses;
SELECT * FROM Passengers;
SELECT * FROM Planes;
SELECT * FROM Employees;
SELECT * FROM Airports;
SELECT * FROM Routes;
SELECT * FROM DeparturePlaces;
SELECT * FROM Flights;
SELECT * FROM Tickets;
SELECT * FROM PassengerTickets;
SELECT * FROM FlightTickets;
SELECT * FROM EventLogs;

-- Testing Functions --------

SELECT dbo.GetEmployeeForFlight(1) as Employee;
SELECT dbo.GetGateCountForTerminal(1) as NumberOfGatesOnTerminal;
SELECT dbo.GetGateModificationDayOfWeek(1) as DayOfWeekOfTheModificationOfTheTicket;
SELECT * FROM dbo.GetReservationDatesForTicket(1) as DatesAndTicketDates;

-- Testing Views -----------

SELECT * FROM TicketInformation;
SELECT * FROM BookedTickets;
SELECT * FROM AvailableTickets;
SELECT * FROM TicketsInFlight;

-- Testing triggers --------

-- Testing check_ticket_availability trigger ------
INSERT INTO PassengerTickets (PassengerId, TicketId)
VALUES (1, 2);

-- Testing check_if_ticket_date_in_past trigger ------

INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
VALUES ('2024-01-01 10:10:10', 1, 2, 1, 1, 150.00);

-- Testing check_if_ticket_is_valid trigger ------

-- Same seat
INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
VALUES ('2024-10-10 10:10:10', 1, 1, 1, 1, 150.00);


INSERT INTO FlightTickets (FlightId, TicketId)
VALUES (1, 3);

-- Same Column and row
INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
VALUES ('2024-10-10 10:10:10', 2, 1, 1, 1, 150.00);

INSERT INTO FlightTickets (FlightId, TicketId)
VALUES (1, 4);

-- Too many tickets for the capacity of the plane
INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
VALUES (1, '2024-10-10 10:10:10', '2024-10-10 15:10:10', 1, '5 hours', 1, 1);

EXEC addTicketsForFlight @p_flightId = 3;

INSERT INTO Tickets (timeOfDeparture, SeatNumber, RowNumber, ColumnNumber, Class, Price)
VALUES ('2024-10-10 10:10:10', 7, 3, 1, 1, 150.00);

INSERT INTO FlightTickets (FlightId, TicketId)
VALUES (3, 11);
-- Testing check_if_source_and_destination_different trigger ------

INSERT INTO Routes (sourceAirport, destinationAirport)
VALUES (1, 1);

-- Testing check_if_capacity_correct trigger ------

INSERT INTO Planes (airlineCode, name, numberOfRows, numberOfColumns, capacity)
VALUES ('ABC', 'Plane1', 10, 4, 41);

-- Testing check_if_flight_is_valid trigger ------

-- Time of departure in the past
INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
VALUES (1, '2024-01-01 10:10:10', '2024-10-10 15:10:10', 1, '5 hours', 1, 1);

-- Departure before arrival
INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
VALUES (1, '2024-10-10 10:10:10', '2024-10-9 15:10:10', 1, '5 hours', 1, 1);

-- Testing procedures -------

EXEC bookSpecifyTicket @p_flightId = 3, @p_seatNumber = 1, @p_passportNumber = 'AB123456'; 

EXEC bookTicket @p_flightId = 3, @p_passportNumber = 'AB123456';

-- Testing roles
EXECUTE AS USER = 'adminUSER';
SELECT * FROM dbo.Flights;
EXEC addEmployeeWithAddress
    @p_firstName = 'John',
    @p_lastName = 'Doe',
    @p_phoneNumber = '1234567890',
    @p_age = 30,
    @p_sex = 'Male',
    @p_employeeAddressCountry = 'Country',
    @p_employeeAddressCity = 'City',
    @p_employeeAddressPostalCode = '12345',
    @p_employeeAddressStreet = 'Street',
    @p_employeeAddressBuildingNumber = '123',
    @p_salary = 50000.00,
    @p_position = 'FlightManager';

REVERT;

EXECUTE AS USER = 'flightManagerUSER';

INSERT INTO Flights (routeId, timeOfDeparture, timeOfArrival, departurePlaceId, duration, addedBy, planeUsed)
VALUES (1, '2024-10-10 10:10:10', '2024-10-9 15:10:10', 1, '5 hours', 1, 1);

EXEC addTicketsForFlight @p_flightId = 4;

REVERT;

EXECUTE AS USER = 'terminalManagerUSER';
SELECT * FROM dbo.Terminals;
SELECT dbo.GetGateCountForTerminal(1) as NumberOfGatesOnTerminal;
REVERT;

EXECUTE AS USER = 'gateManagerUSER';
SELECT * FROM dbo.Gates;
SELECT dbo.GetGateModificationDayOfWeek(1) as DayOfWeekOfTheModificationOfTheTicket;
REVERT;

EXECUTE AS USER = 'passengerUSER';
SELECT * FROM dbo.AvailableTickets;
EXEC dbo.bookTicket @p_flightId = 1, @p_passportNumber = 'AB123456';
REVERT;


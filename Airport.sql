USE master;
Go
DROP DATABASE IF EXISTS AIRPORT;
GO

-- Create database
CREATE DATABASE AIRPORT;
Go
Use Airport;
Go

-- Tables --------------------------------------------------------------------------

-- Terminals table
CREATE TABLE dbo.Terminals (
    terminalId INT PRIMARY KEY IDENTITY(1,1),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Gates table
CREATE TABLE dbo.Gates (
    gateId INT PRIMARY KEY IDENTITY(1,1),
	terminalId INT FOREIGN KEY REFERENCES terminals(terminalId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- addresses table
CREATE TABLE dbo.Addresses (
    addressId INT PRIMARY KEY IDENTITY(1,1),
    country VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    postalCode VARCHAR(20) NOT NULL,
    street VARCHAR(50),
    buildingNumber VARCHAR(20),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- Passengers table
CREATE TABLE dbo.Passengers (
	passengerId INT PRIMARY KEY IDENTITY(1,1),
    passportNumber VARCHAR(20) NOT NULL,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    phoneNumber VARCHAR(20) NOT NULL,
    age INT CHECK (age >= 0) NOT NULL,
    sex VARCHAR(20) CHECK (sex IN ('Male', 'Female')) NOT NULL,
    addressId INT FOREIGN KEY REFERENCES addresses(addressId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
    CONSTRAINT UQ_passportNumber UNIQUE (passportNumber)
);
GO

-- Planes table
CREATE TABLE dbo.Planes (
    planeId INT PRIMARY KEY IDENTITY(1,1),
    airlineCode VARCHAR(10),
    name VARCHAR(50) NOT NULL,
    numberOfRows INT NOT NULL,
    numberOfColumns INT NOT NULL,
    capacity INT NOT NULL,
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);
GO

-- Employees table
CREATE TABLE dbo.Employees (
    employeeId INT PRIMARY KEY IDENTITY(1,1),
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    phoneNumber VARCHAR(20),
    age INT CHECK (age >= 0) NOT NULL,
    sex VARCHAR(20) CHECK (sex IN ('Male', 'Female')) NOT NULL,
    addressId INT FOREIGN KEY REFERENCES addresses(addressId),
    salary FLOAT,
    position VARCHAR(20) CHECK (position IN ('FlightManager', 'TerminalManager', 'GateManager')),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Airports table
CREATE TABLE dbo.Airports (
    airportId INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50) NOT NULL,
    addressId INT FOREIGN KEY REFERENCES addresses(addressId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Routes table
CREATE TABLE dbo.Routes (
    routeId INT PRIMARY KEY IDENTITY(1,1),
    sourceAirport INT FOREIGN KEY REFERENCES airports(airportId) NOT NULL,
    destinationAirport INT FOREIGN KEY REFERENCES airports(airportId) NOT NULL,
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- DeparturePlaces table
CREATE TABLE dbo.DeparturePlaces (
    departurePlaceId INT PRIMARY KEY IDENTITY(1,1),
    departureTerminalId INT FOREIGN KEY REFERENCES terminals(terminalId),
    departureGateId INT FOREIGN KEY REFERENCES gates(gateId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);
Go

-- Flights table
CREATE TABLE dbo.Flights (
    flightId INT PRIMARY KEY IDENTITY(1,1),
    routeId INT FOREIGN KEY REFERENCES routes(routeId),
    timeOfDeparture DATETIME NOT NULL,
    timeOfArrival DATETIME NOT NULL,
    departurePlaceId INT FOREIGN KEY REFERENCES departurePlaces(departurePlaceId),
    duration VARCHAR(20),
    addedBy INT FOREIGN KEY REFERENCES employees(employeeId),
    planeUsed INT FOREIGN KEY REFERENCES planes(planeId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Tickets table
CREATE TABLE dbo.Tickets (
    TicketId INT PRIMARY KEY IDENTITY(1,1),
	timeOfDeparture DATETIME NOT NULL,
    SeatNumber INT NOT NULL,
    RowNumber INT NOT NULL,
	ColumnNumber INT NOT NULL,
	Class INT NOT NULL,
	Price FLOAT NOT NULL,
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);
Go

-- PassengerTickets table
CREATE TABLE dbo.PassengerTickets (
    PassengerId INT FOREIGN KEY REFERENCES Passengers(PassengerId),
    TicketId INT FOREIGN KEY REFERENCES Tickets(TicketId),
	PRIMARY KEY (PassengerId,TicketId),
	ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- FlightTickets table
CREATE TABLE dbo.FlightTickets (
    FlightId INT FOREIGN KEY REFERENCES Flights(FlightId),
    TicketId INT FOREIGN KEY REFERENCES Tickets(TicketId),
    PRIMARY KEY (FlightId, TicketId),
	ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- EventLogs table
CREATE TABLE dbo.EventLogs (
    eventId INT PRIMARY KEY IDENTITY(1,1),
    loggedBy INT FOREIGN KEY REFERENCES Employees(employeeId),
    loggedOn INT FOREIGN KEY REFERENCES Passengers(passengerId),
    status VARCHAR(20),
    source VARCHAR(20),
    message VARCHAR(255),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Descriptions -----------------------------------------------------------------------

-- Terminals table descriprion
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about airport terminals.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'terminals';

-- Gates table description
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about gates at the airport and a associated terminal.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'gates';

--- Addresses table description
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about passenger and employee addresses.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'addresses';

-- Passengers table description
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about passengers at the airport.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'passengers';

-- Planes table descriprion
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about planes.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'planes';

-- Employees table description
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about airport employees.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'employees';

-- Airports table description
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information airports.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'airports';

-- Routes table description
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about source of the flight and the destination.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'routes';

-- DeparturePlaces table descriprition
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about departure terminal and a departure gate.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'departurePlaces';

-- Flights table descriprition
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about flights, source and destination airports, which employee added the flight and which plane was used.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'flights';

-- Tickets table descriprition
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about tickets.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'tickets';

-- PassengerTickets table descriprition
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about booked tickets.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'passengerTickets';

-- FlightTickets table descriprition
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about tickets for the flight.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'flightTickets';

-- EventLogs table descriprition
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about event logs, which is an information if the action was successful or not.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'eventLogs';

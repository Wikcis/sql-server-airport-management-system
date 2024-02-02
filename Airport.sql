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
CREATE TABLE Terminals (
    terminalId INT PRIMARY KEY IDENTITY(1,1),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Gates table
CREATE TABLE Gates (
    gateId INT PRIMARY KEY IDENTITY(1,1),
	terminalId INT FOREIGN KEY REFERENCES terminals(terminalId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- addresses table
CREATE TABLE Addresses (
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
CREATE TABLE Passengers (
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
CREATE TABLE Planes (
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
CREATE TABLE Employees (
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
CREATE TABLE Airports (
    airportId INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(50) NOT NULL,
    addressId INT FOREIGN KEY REFERENCES addresses(addressId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Routes table
CREATE TABLE Routes (
    routeId INT PRIMARY KEY IDENTITY(1,1),
    sourceAirport INT FOREIGN KEY REFERENCES airports(airportId) NOT NULL,
    destinationAirport INT FOREIGN KEY REFERENCES airports(airportId) NOT NULL,
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- DeparturePlaces table
CREATE TABLE DeparturePlaces (
    departurePlaceId INT PRIMARY KEY IDENTITY(1,1),
    departureTerminalId INT FOREIGN KEY REFERENCES terminals(terminalId),
    departureGateId INT FOREIGN KEY REFERENCES gates(gateId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);
Go

-- Flights table
CREATE TABLE Flights (
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
CREATE TABLE Tickets (
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
CREATE TABLE PassengerTickets (
    PassengerId INT FOREIGN KEY REFERENCES Passengers(PassengerId),
    TicketId INT FOREIGN KEY REFERENCES Tickets(TicketId),
	PRIMARY KEY (PassengerId,TicketId),
	ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- FlightTickets table
CREATE TABLE FlightTickets (
    FlightId INT FOREIGN KEY REFERENCES Flights(FlightId),
    TicketId INT FOREIGN KEY REFERENCES Tickets(TicketId),
    PRIMARY KEY (FlightId, TicketId),
	ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- EventLogs table
CREATE TABLE EventLogs (
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
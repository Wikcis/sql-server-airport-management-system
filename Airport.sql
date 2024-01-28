--------------------------------------------------------------------------------------------------------------
--Projekty mog¹ byæ realizowane w grupach do 3 osób w³¹cznie. 
--Projekt jest na zal. i jest wymagany do zaliczenia przedmiotu.
--------------------------------------------------------------------------------------------------------------

--Projekt ma zwieraæ plik z opisem w formacie pdf, który powinien zawieraæ:
--Strona tytu³owa - Nazwa bazy danych oraz nazwiska, imiê i numer albumu studentów realizuj¹cych projekt. 
--Rozdz. 1. Podstawowe za³o¿enia projektu (cel, g³ówne za³o¿enia, mo¿liwoœci, ograniczenia przyjête przy projektowaniu),
--Rozdz. 2. Schemat bazy danych - czytelny,
--Rozdz. 3. Obiekty bazy danych i ich opis.
--- tabele, ograniczenia (CHECK,DEFAULT,FK,PK,Unique) i ich opis (przynajmniej ka¿da tabela powinna mieæ swój opis zdefiniowane bezpoœrednio w SSMS lub za pomoc¹ sp_addextendedproperty)
--   • dodatkowo w bazie danych powinno byæ w ka¿dej tabeli pole ModifiedDate z wyzwalaczem, który przy modyfikacji danych w danej tabeli ustawi aktualna datê modyfikacji. 
--   Przy wstawianiu danych wykorzystamy ograniczenie DEFAULT.
--   • dodatkowo w bazie danych powinno byæ w ka¿dej tabeli pole rowguid i ograniczniem DEFAULT z funkcj¹ newid() 
--   • baza powinna spe³niaæ trzy pierwsze postacie normalne, a jeœli jakiœ element nie spe³nia to proszê opisaæ dlaczego (mo¿e to byæ zamierzone przez projektanta).
--- opis indeksów, które zosta³y automatycznie utworzone przy tworzniu ograniczenia PK i Unique. Jeœli chcemy zdefiniowaæ w³asny indeks to tak¿e proszê go opisaæ.
--- triggery i ich opis
--- procedury i ich opis (np. do wstawiania danych do bazy)
--- funkcje i ich opis (np. zdefiniowaæ przynajmniej jedn¹ funkcjê u¿ytkownika)
--- widoki i ich opis (np. z podstawowymi funkcjonalnoœciami bazy danych)
--Rozdz. 4. Role bazy danych, uprawnienia i przypisaæ do nich po jednym u¿ytkowniku. 
--	Np. U¿ytkownik Admin - mo¿e wszystko w danej bazie danych (jest w³aœcicielem) 
--	U¿ytkownik Pracownik ma prawo do wykonywania procedury przechowywanej bez praw do tabel.
--	U¿ytkownik Klient_anonimowy ma prawo do ogl¹dania danych na widoku bez operacji INSERT, UPDATE i DELETE oraz bez praw do tabel wykorzystywanych w widoku.
--Rozdz. 5. Uwagi z czym by³y k³opoty i co nie zosta³o zralizowane pomyœlnie.

--Oprócz pliku pdf do³¹czamy skrypt wygenerowany do wyboru: 
--	- za pomoc¹ opcji Taks|Generate Scripts ³¹cznie z danymi, 
--	- pliku Backupu bazy danych 
--	- pliku Export Data-tier Application (bacpac). 

--Do ka¿dego projektu dok³adamy krótki 3-5 minut film z przedstawieniem projektu.
--------------------------------------------------------------------------------------------------------------
-- Create database
CREATE DATABASE AIRPORT;
Use Airport;

-- Terminals table
CREATE TABLE Terminals (
    terminalId INT PRIMARY KEY,
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Gates table
CREATE TABLE Gates (
    gateId INT PRIMARY KEY,
	terminalId INT FOREIGN KEY REFERENCES terminals(terminalId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- addresses table
CREATE TABLE Addresses (
    addressId INT PRIMARY KEY,
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
	passengerId INT PRIMARY KEY,
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
    planeId INT PRIMARY KEY,
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
    employeeId INT PRIMARY KEY,
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
    airportId INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    addressId INT FOREIGN KEY REFERENCES addresses(addressId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

-- Routes table
CREATE TABLE Routes (
    routeId INT PRIMARY KEY,
    sourceAirport INT FOREIGN KEY REFERENCES airports(airportId) NOT NULL,
    destinationAirport INT FOREIGN KEY REFERENCES airports(airportId) NOT NULL,
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- DeparturePlaces table
CREATE TABLE DeparturePlaces (
    departurePlaceId INT PRIMARY KEY,
    departureTerminalId INT FOREIGN KEY REFERENCES terminals(terminalId),
    departureGateId INT FOREIGN KEY REFERENCES gates(gateId),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID()
);
Go

-- Flights table descriprition
CREATE TABLE Flights (
    flightId INT PRIMARY KEY,
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

-- EventLogs table
CREATE TABLE EventLogs (
    eventId INT PRIMARY KEY,
    loggedBy INT FOREIGN KEY REFERENCES Employees(employeeId),
    loggedOn INT FOREIGN KEY REFERENCES Passengers(passengerId),
    status VARCHAR(20),
    source VARCHAR(20),
    message VARCHAR(255),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    rowguid UNIQUEIDENTIFIER DEFAULT NEWID(),
);
GO

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


-- EventLogs table descriprition
EXEC sys.sp_addextendedproperty 
    @name=N'MS_Description', 
    @value=N'Table storing information about event logs, which is an information if the action was successful or not.', 
    @level0type=N'SCHEMA', @level0name=N'dbo', 
    @level1type=N'TABLE', @level1name=N'eventLogs';

USE AIRPORT;
Go

-- Roles ----------------------------------------------------------------

-- Creating logins
CREATE LOGIN AdminLOGIN WITH PASSWORD = 'Password123';
CREATE LOGIN FlightManagerLOGIN WITH PASSWORD = 'Password123';
CREATE LOGIN TerminalManagerLOGIN WITH PASSWORD = 'Password123';
CREATE LOGIN GateManagerLOGIN WITH PASSWORD = 'Password123';
CREATE LOGIN PassengerLOGIN WITH PASSWORD = 'Password123';

-- Creating users
CREATE USER adminUSER FOR LOGIN AdminLOGIN;
CREATE USER flightManagerUSER FOR LOGIN FlightManagerLOGIN;
CREATE USER terminalManagerUSER FOR LOGIN TerminalManagerLOGIN;
CREATE USER gateManagerUSER FOR LOGIN GateManagerLOGIN;
CREATE USER passengerUSER FOR LOGIN PassengerLOGIN;

-- Creating roles
CREATE ROLE Admin;
CREATE ROLE FlightManager;
CREATE ROLE TerminalManager;
CREATE ROLE GateManager;
CREATE ROLE Passenger;

-- Add members to roles
ALTER ROLE Admin ADD MEMBER adminUSER;
ALTER ROLE FlightManager ADD MEMBER flightManagerUSER;
ALTER ROLE TerminalManager ADD MEMBER terminalManagerUSER;
ALTER ROLE GateManager ADD MEMBER gateManagerUSER;
ALTER ROLE Passenger ADD MEMBER passengerUSER;

-- Grant permissions to Admin role
GRANT CONTROL ON DATABASE::AIRPORT TO Admin;

-- Grant permissions to FlightManager role
GRANT INSERT, SELECT, UPDATE ON dbo.Flights TO FlightManager;
GRANT INSERT, SELECT, UPDATE ON dbo.Tickets TO FlightManager;
GRANT INSERT, SELECT, UPDATE ON dbo.EventLogs TO FlightManager;
GRANT EXECUTE ON dbo.addTicketsForFlight TO FlightManager;
GRANT EXECUTE ON dbo.GetEmployeeForFlight TO FlightManager;

-- Grant permissions to TerminalManager role
GRANT INSERT, SELECT, UPDATE ON dbo.Terminals TO TerminalManager;
GRANT INSERT, SELECT, UPDATE ON dbo.EventLogs TO TerminalManager;
GRANT EXECUTE ON dbo.GetGateCountForTerminal TO TerminalManager;

-- Grant permissions to GateManager role
GRANT INSERT, SELECT, UPDATE ON dbo.Gates TO GateManager;
GRANT INSERT, SELECT, UPDATE ON dbo.EventLogs TO GateManager;
GRANT EXECUTE ON dbo.GetGateModificationDayOfWeek TO GateManager;

-- Grant permissions to Passenger role
GRANT SELECT ON dbo.AvailableTickets TO Passenger;
GRANT EXECUTE ON dbo.bookTicket TO Passenger;
GRANT EXECUTE ON dbo.bookSpecifyTicket TO Passenger;


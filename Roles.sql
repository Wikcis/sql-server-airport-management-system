REVERT;
ALTER ROLE db_owner DROP MEMBER admin_user;
ALTER ROLE db_owner DROP MEMBER flight_manager_user;
ALTER ROLE db_owner DROP MEMBER terminal_manager_user;
ALTER ROLE db_owner DROP MEMBER gate_manager_user;
ALTER ROLE db_owner DROP MEMBER passenger_user;

USE AIRPORT; 
DROP LOGIN AdminLOGIN;
DROP LOGIN FlightManagerLOGIN;
DROP LOGIN TerminalManagerLOGIN;
DROP LOGIN GateManagerLOGIN;
DROP LOGIN PassengerLOGIN;

DROP ROLE IF EXISTS Admin;
DROP ROLE IF EXISTS FlightManager;
DROP ROLE IF EXISTS TerminalManager;
DROP ROLE IF EXISTS GateManager;
DROP ROLE IF EXISTS Passenger;

CREATE LOGIN AdminLOGIN WITH PASSWORD = 'Password123';
CREATE LOGIN FlightManagerLOGIN WITH PASSWORD = 'Password123';
CREATE LOGIN TerminalManagerLOGIN WITH PASSWORD = 'Password123';
CREATE LOGIN GateManagerLOGIN WITH PASSWORD = 'Password123';
CREATE LOGIN PassengerLOGIN WITH PASSWORD = 'Password123';

CREATE USER admin_user FOR LOGIN AdminLOGIN;
CREATE USER flight_manager_user FOR LOGIN FlightManagerLOGIN;
CREATE USER terminal_manager_user FOR LOGIN TerminalManagerLOGIN;
CREATE USER gate_manager_user FOR LOGIN GateManagerLOGIN;
CREATE USER passenger_user FOR LOGIN PassengerLOGIN;

CREATE ROLE Admin;
CREATE ROLE FlightManager;
CREATE ROLE TerminalManager;
CREATE ROLE GateManager;
CREATE ROLE Passenger;

ALTER ROLE Admin ADD MEMBER admin_user;
ALTER ROLE FlightManager ADD MEMBER flight_manager_user;
ALTER ROLE TerminalManager ADD MEMBER terminal_manager_user;
ALTER ROLE GateManager ADD MEMBER gate_manager_user;
ALTER ROLE Passenger ADD MEMBER passenger_user;

-- Grant permissions to Admin role
GRANT CONTROL ON DATABASE::AIRPORT TO Admin;

-- Grant permissions to FlightManager role
GRANT INSERT, SELECT, UPDATE ON dbo.Flights TO FlightManager;
GRANT INSERT, SELECT, UPDATE ON dbo.Tickets TO FlightManager;
GRANT INSERT, SELECT, UPDATE ON dbo.EventLogs TO FlightManager;
GRANT EXECUTE ON dbo.addTicketsForFlight TO FlightManager;

-- Grant permissions to TerminalManager role
GRANT INSERT, SELECT, UPDATE ON dbo.Terminals TO TerminalManager;
GRANT INSERT, SELECT, UPDATE ON dbo.EventLogs TO TerminalManager;

-- Grant permissions to GateManager role
GRANT INSERT, SELECT, UPDATE ON dbo.Gates TO GateManager;
GRANT INSERT, SELECT, UPDATE ON dbo.EventLogs TO GateManager;

-- Grant permissions to Passenger role
GRANT SELECT ON dbo.AvailableTickets TO Passenger;
GRANT EXECUTE ON dbo.bookTicket TO Passenger;
GRANT EXECUTE ON dbo.bookSpecifyTicket TO Passenger;

-- Add members to roles
ALTER ROLE Admin ADD MEMBER [admin_user];
ALTER ROLE FlightManager ADD MEMBER [flight_manager_user];
ALTER ROLE TerminalManager ADD MEMBER [terminal_manager_user];
ALTER ROLE GateManager ADD MEMBER [gate_manager_user];
ALTER ROLE Passenger ADD MEMBER [passenger_user];


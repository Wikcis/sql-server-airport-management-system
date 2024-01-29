-- Creating users
CREATE LOGIN admin_user WITH PASSWORD = 'admin_password';
CREATE LOGIN flight_manager_user WITH PASSWORD = 'flight_manager_password';
CREATE LOGIN terminal_manager_user WITH PASSWORD = 'terminal_manager_password';
CREATE LOGIN regular_user WITH PASSWORD = 'regular_user_password';

CREATE USER admin_user FOR LOGIN admin_user;
CREATE USER flight_manager_user FOR LOGIN flight_manager_user;
CREATE USER terminal_manager_user FOR LOGIN terminal_manager_user;
CREATE USER regular_user FOR LOGIN regular_user;

-- 1. Admin role
CREATE ROLE Admin;

GRANT ALTER ANY LOGIN TO Admin;
GRANT ALTER ANY USER TO Admin;
GRANT CREATE ANY DATABASE TO Admin;
GRANT CREATE PROCEDURE TO Admin;
GRANT CREATE TABLE TO Admin;
GRANT EXECUTE TO Admin;
GRANT INSERT TO Admin;
GRANT SELECT TO Admin;
GRANT UPDATE TO Admin;
GRANT DELETE TO Admin;

-- 2. Flight Manager role
CREATE ROLE FlightManager;

GRANT INSERT, SELECT, UPDATE ON dbo.Flights TO FlightManager;
GRANT INSERT, SELECT, UPDATE ON dbo.Tickets TO FlightManager;

-- 3. Terminal Manager role
CREATE ROLE TerminalManager;

GRANT INSERT, SELECT, UPDATE ON dbo.Terminals TO TerminalManager;
GRANT INSERT, SELECT, UPDATE ON dbo.Gates TO TerminalManager;

-- 4. Rola U¿ytkownika
CREATE ROLE RegularUser;

USE AIRPORT;
Go

GRANT SELECT ON dbo.AvailableTickets TO RegularUser;
GRANT EXECUTE ON dbo.bookSpecifyTicket TO RegularUser;

USE master;
Go

ALTER ROLE Admin ADD MEMBER [admin_user];
ALTER ROLE FlightManager ADD MEMBER [flight_manager_user];
ALTER ROLE TerminalManager ADD MEMBER [terminal_manager_user];
ALTER ROLE RegularUser ADD MEMBER [regular_user];

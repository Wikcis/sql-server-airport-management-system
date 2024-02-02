USE AIRPORT;
Go

-- Functions -------------------------------------------------------------

-- Function to get full name of the employee, who added specific flight 
CREATE OR ALTER FUNCTION dbo.GetEmployeeForFlight
(
    @flightId INT
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @EmployeeFullName NVARCHAR(200);

    SELECT @EmployeeFullName = e.FirstName + ' ' + e.LastName
    FROM dbo.Flights f
    INNER JOIN dbo.Employees e ON f.addedBy = e.employeeId
    WHERE f.flightId = @flightId;

    RETURN @EmployeeFullName;
END;
GO

-- Function to get number of gates on specific terminal
CREATE OR ALTER FUNCTION dbo.GetGateCountForTerminal
(
    @terminalId INT
)
RETURNS INT
AS
BEGIN
    DECLARE @GateCount INT;

    SELECT @GateCount = COUNT(g.gateId)
    FROM dbo.Gates g
    WHERE g.terminalId = @terminalId;

    RETURN @GateCount;
END;
GO

-- Function to get day of week of the modification date of the gate
CREATE OR ALTER FUNCTION dbo.GetGateModificationDayOfWeek(
	@gateId INT
)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @modificationDayOfWeek NVARCHAR(20);

    SELECT @modificationDayOfWeek = FORMAT(ModifiedDate, 'dddd')
    FROM Gates
    WHERE gateId = @gateId;

    RETURN @modificationDayOfWeek;
END;
Go

-- Function to get id of the ticket and a modification date for a specitic passenger
CREATE OR ALTER FUNCTION dbo.GetReservationDatesForTicket(
	@PassengerId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT pt.ticketId, t.timeOfDeparture
    FROM PassengerTickets pt
	INNER JOIN Tickets t ON t.TicketId = pt.TicketId
    WHERE pt.PassengerId = @PassengerId
);
Go 
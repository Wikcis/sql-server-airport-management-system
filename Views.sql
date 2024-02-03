USE AIRPORT;
Go

-- Views ----------------------------------------------------------------------

-- View to display ticket informations and a passenger on this ticket
CREATE OR ALTER VIEW TicketInformation AS
SELECT
    t.TicketId,
    t.timeOfDeparture,
    t.SeatNumber,
    t.RowNumber,
    t.ColumnNumber,
    t.Class,
    t.Price,
    f.FlightId,
    f.timeOfDeparture AS FlightDepartureTime,
    f.timeOfArrival AS FlightArrivalTime,
    p.passengerId,
    p.passportNumber,
    p.firstName,
    p.lastName,
    p.phoneNumber,
    a.country AS passengerCountry,
    a.city AS passengerCity,
    a.postalCode AS passengerPostalCode,
    a.street AS passengerStreet,
    a.buildingNumber AS passengerBuildingNumber
FROM
    Tickets t
JOIN
    PassengerTickets pt ON t.TicketId = pt.TicketId
JOIN
    FlightTickets ft ON pt.TicketId = ft.TicketId
JOIN
    Flights f ON ft.FlightId = f.FlightId
JOIN
    Passengers p ON pt.PassengerId = p.passengerId
JOIN
    Addresses a ON p.addressId = a.addressId;
Go

-- View to display tickets that are booked
CREATE OR ALTER VIEW BookedTickets AS
SELECT
    t.TicketId,
	ft.FlightId,
    t.timeOfDeparture,
    t.SeatNumber,
    t.RowNumber,
    t.ColumnNumber,
    t.Class,
    t.Price
FROM
    Tickets t
INNER JOIN
    PassengerTickets pt ON t.TicketId = pt.TicketId
INNER JOIN 
	FlightTickets ft ON ft.ticketId = t.ticketId
Go

-- View to display tickets that available to book
CREATE OR ALTER VIEW AvailableTickets AS
SELECT
    t.TicketId,
	ft.flightId,
    t.timeOfDeparture,
    t.SeatNumber,
    t.RowNumber,
    t.ColumnNumber,
    t.Class,
    t.Price
FROM
    Tickets t
INNER JOIN 
	FlightTickets ft ON ft.ticketId = t.ticketId
WHERE
    NOT EXISTS (
        SELECT 1
        FROM
            PassengerTickets pt
        WHERE
            pt.TicketId = t.TicketId
    );
GO

-- View to display flight and its tickets
CREATE OR ALTER VIEW TicketsInFlight AS
SELECT
	ft.flightId,
    t.TicketId,
    t.timeOfDeparture,
    t.SeatNumber,
    t.RowNumber,
    t.ColumnNumber,
    t.Class,
    t.Price
FROM
    Tickets t
INNER JOIN 
	FlightTickets ft ON ft.ticketId = t.ticketId
GO


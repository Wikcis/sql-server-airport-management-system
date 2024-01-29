USE AIRPORT;
Go

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

SELECT * FROM TicketInformation

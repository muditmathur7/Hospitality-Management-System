-- Drop tables if they exist
IF OBJECT_ID('dbo.Bookings', 'U') IS NOT NULL
    DROP TABLE dbo.Bookings;
GO
IF OBJECT_ID('dbo.Rooms', 'U') IS NOT NULL
    DROP TABLE dbo.Rooms;
GO
IF OBJECT_ID('dbo.Hotels', 'U') IS NOT NULL
    DROP TABLE dbo.Hotels;
GO
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL
    DROP TABLE dbo.Users;
GO

-- Create Users Table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(255) UNIQUE NOT NULL,
    Password NVARCHAR(255) NOT NULL,
    Role NVARCHAR(50)
);
GO

-- Create Hotels Table
CREATE TABLE Hotels (
    HotelID INT IDENTITY(1,1) PRIMARY KEY,
    HotelName NVARCHAR(255) NOT NULL,
    Location NVARCHAR(255) NOT NULL
);
GO

-- Create Rooms Table
CREATE TABLE Rooms (
    RoomID INT IDENTITY(1,1) PRIMARY KEY,
    RoomNumber NVARCHAR(255) NOT NULL,
    HotelID INT,
    RoomType NVARCHAR(255),
    Price DECIMAL(10, 2),
    FOREIGN KEY (HotelID) REFERENCES Hotels(HotelID)
);
GO

-- Create Bookings Table
CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    RoomID INT,
    CheckIn DATE,
    CheckOut DATE,
    Status NVARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);
GO

-- Insert test data into Hotels
INSERT INTO Hotels (HotelName, Location)
VALUES ('Grand Hotel', 'Downtown');
INSERT INTO Hotels (HotelName, Location)
VALUES ('Redisson', 'Jodhpur');
GO

-- Insert test data into Users
INSERT INTO Users (Username, Password, Role)
VALUES ('user1', 'password123', 'guest');
INSERT INTO Users (Username, Password, Role)
VALUES ('user2', 'password1234', 'guest');
GO

-- Insert test data into Rooms
INSERT INTO Rooms (RoomNumber, HotelID, RoomType, Price)
VALUES ('101', 1, 'Deluxe', 25000.00);
INSERT INTO Rooms (RoomNumber, HotelID, RoomType, Price)
VALUES ('102', 2, 'Deluxe', 30000.00);
GO

-- Insert test data into Bookings
INSERT INTO Bookings (UserID, RoomID, CheckIn, CheckOut, Status)
VALUES (1, 1, '2024-07-01', '2024-07-15', 'Pending');
INSERT INTO Bookings (UserID, RoomID, CheckIn, CheckOut, Status)
VALUES (2, 2, '2024-12-19', '2024-12-21', 'Pending');
GO

-- Drop existing procedures if they exist
IF OBJECT_ID('CheckRoomAvailability', 'P') IS NOT NULL
    DROP PROCEDURE CheckRoomAvailability;
GO

IF OBJECT_ID('UserLogin', 'P') IS NOT NULL
    DROP PROCEDURE UserLogin;
GO

IF OBJECT_ID('RegisterRoom', 'P') IS NOT NULL
    DROP PROCEDURE RegisterRoom;
GO

IF OBJECT_ID('RegisterHotel', 'P') IS NOT NULL
    DROP PROCEDURE RegisterHotel;
GO

IF OBJECT_ID('GenerateBill', 'P') IS NOT NULL
    DROP PROCEDURE GenerateBill;
GO

IF OBJECT_ID('CheckIn', 'P') IS NOT NULL
    DROP PROCEDURE CheckIn;
GO

IF OBJECT_ID('CheckOut', 'P') IS NOT NULL
    DROP PROCEDURE CheckOut;
GO

-- Checking Room Availability
CREATE PROCEDURE CheckRoomAvailability
    @CheckIn DATE,
    @CheckOut DATE,
    @RoomID INT
AS
BEGIN
    SELECT 
        r.RoomID,
        r.RoomNumber,
        CASE
            WHEN b.BookingID IS NULL THEN 'Available'
            ELSE 'Unavailable'
        END AS Availability
    FROM 
        Rooms r
    LEFT JOIN 
        Bookings b ON r.RoomID = b.RoomID
        AND ((b.CheckIn <= @CheckOut AND b.CheckOut >= @CheckIn))
    WHERE
        r.RoomID = @RoomID;
END;
GO

-- User Login
CREATE PROCEDURE UserLogin
    @Username NVARCHAR(255),
    @Password NVARCHAR(255)
AS
BEGIN
    SELECT 
        UserID, 
        Username 
    FROM 
        Users 
    WHERE 
        Username = @Username 
        AND Password = @Password;
END;
GO

-- Register Rooms
CREATE PROCEDURE RegisterRoom
    @RoomNumber NVARCHAR(255),
    @HotelID INT,
    @RoomType NVARCHAR(255),
    @Price DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO Rooms (RoomNumber, HotelID, RoomType, Price)
    VALUES (@RoomNumber, @HotelID, @RoomType, @Price);
    
    SELECT 'Room Registered Successfully' AS Message;
END;
GO

-- Register Hotels
CREATE PROCEDURE RegisterHotel
    @HotelName NVARCHAR(255),
    @Location NVARCHAR(255)
AS
BEGIN
    INSERT INTO Hotels (HotelName, Location)
    VALUES (@HotelName, @Location);
    
    SELECT 'Hotel Registered Successfully' AS Message;
END;
GO

-- Generate Bill
CREATE PROCEDURE GenerateBill
    @BookingID INT
AS
BEGIN
    SELECT 
        b.BookingID,
        b.RoomID,
        r.RoomNumber,
        b.CheckIn,
        b.CheckOut,
        DATEDIFF(DAY, b.CheckIn, b.CheckOut) * r.Price AS TotalAmount
    FROM 
        Bookings b
    JOIN 
        Rooms r ON b.RoomID = r.RoomID
    WHERE 
        b.BookingID = @BookingID;
END;
GO

-- Check-in
CREATE PROCEDURE CheckIn
    @BookingID INT
AS
BEGIN
    UPDATE Bookings
    SET Status = 'Checked-In'
    WHERE BookingID = @BookingID;

    SELECT 'Check-In Successful' AS Message;
END;
GO

-- Check-out
CREATE PROCEDURE CheckOut
    @BookingID INT
AS
BEGIN
    UPDATE Bookings
    SET Status = 'Checked-Out'
    WHERE BookingID = @BookingID;

    SELECT 'Check-Out Successful' AS Message;
END;
GO

-- Call to CheckRoomAvailability
DECLARE @CheckIn DATE = '2024-07-01';
DECLARE @CheckOut DATE = '2024-07-10';
DECLARE @RoomID INT = 1;

EXEC CheckRoomAvailability @CheckIn, @CheckOut, @RoomID;
GO

-- Call to UserLogin
DECLARE @Username NVARCHAR(255) = 'user1';
DECLARE @Password NVARCHAR(255) = 'password123';

EXEC UserLogin @Username, @Password;
GO

-- Call to RegisterRoom
DECLARE @RoomNumber NVARCHAR(255) = '101';
DECLARE @HotelID INT = 1;
DECLARE @RoomType NVARCHAR(255) = 'Deluxe';
DECLARE @Price DECIMAL(10, 2) = 150.00;

EXEC RegisterRoom @RoomNumber, @HotelID, @RoomType, @Price;
GO

-- Call to RegisterHotel
DECLARE @HotelName NVARCHAR(255) = 'Grand Hotel';
DECLARE @Location NVARCHAR(255) = 'Downtown';

EXEC RegisterHotel @HotelName, @Location;
GO

-- Call to GenerateBill
DECLARE @BookingID INT = 1;

EXEC GenerateBill @BookingID;
GO

-- Call to CheckIn
DECLARE @BookingID INT = 1;

EXEC CheckIn @BookingID;
GO

-- Call to CheckOut
DECLARE @BookingID INT = 1;

EXEC CheckOut @BookingID;
GO
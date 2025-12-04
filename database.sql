DROP DATABASE IF EXISTS cinema;
CREATE DATABASE cinema;
USE cinema;

-- ============================
-- MOVIE TABLE
-- ============================
CREATE TABLE movie (
    movie_id INT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(50) NOT NULL,
    duration_minutes INT NOT NULL,
    release_date DATE NOT NULL ,
    director VARCHAR(100) NOT NULL
);

-- ============================
-- ROOM TABLE
-- ============================
CREATE TABLE room (
    room_id INT PRIMARY KEY,
    room_name VARCHAR(50) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
	room_type VARCHAR(50) NOT NULL DEFAULT 'Standard',
	CHECK (room_type IN ('Standard', 'IMAX', '4DX')) 
);

-- ============================
-- SEAT TABLE
-- ============================
CREATE TABLE seat (
    seat_id INT PRIMARY KEY,
    room_id INT NOT NULL,
    seat_row CHAR(1) NOT NULL,
    seat_number INT  NOT NULL,
    seat_type VARCHAR(50) NOT NULL DEFAULT 'Standard',
	CHECK (seat_type IN ('Standard', 'Premium', 'Recliner')),
    
    CONSTRAINT fk_seat_room
        FOREIGN KEY (room_id)
        REFERENCES room(room_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================
-- SHOWTIME TABLE
-- ============================
CREATE TABLE showtime (
    showtime_id INT PRIMARY KEY,
    movie_id INT NOT NULL,
    room_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    price DECIMAL(6,2),
    
    CONSTRAINT fk_showtime_movie
        FOREIGN KEY (movie_id)
        REFERENCES movie(movie_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_showtime_room
        FOREIGN KEY (room_id)
        REFERENCES room(room_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================
-- TICKET TABLE
-- ============================
CREATE TABLE ticket (
    ticket_id INT PRIMARY KEY,
    showtime_id INT NOT NULL,
    seat_id INT NOT NULL,
final_price DECIMAL(6,2) NOT NULL DEFAULT 0.00,


    CONSTRAINT fk_ticket_showtime
        FOREIGN KEY (showtime_id)
        REFERENCES showtime(showtime_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_ticket_seat
        FOREIGN KEY (seat_id)
        REFERENCES seat(seat_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- SAMPLE DATA
INSERT INTO movie VALUES
  (1, 'Inception', 'Sci-Fi', 148, '2010-07-16', 'Christopher Nolan'),
  (2, 'Interstellar', 'Sci-Fi', 169, '2014-11-07', 'Christopher Nolan'),
  (3, 'Avatar', 'Fantasy', 162, '2009-12-18', 'James Cameron'),
  (4, 'Oppenheimer', 'Biography', 180, '2023-07-21', 'Christopher Nolan'),
  (5, 'Dune', 'Sci-Fi', 155, '2021-10-22', 'Denis Villeneuve'),
  (6, 'The Dark Knight', 'Action', 152, '2008-07-18', 'Christopher Nolan'),
  (7, 'Titanic', 'Romance', 195, '1997-12-19', 'James Cameron');

INSERT INTO room VALUES
  (101, 'IMAX Hall 1', 250, 'IMAX'),
  (102, 'Standard Room A', 120, 'Standard'),
  (103, '4DX Hall', 80, '4DX');

INSERT INTO seat VALUES
  (1, 101, 'A', 1, 'Standard'),
  (2, 101, 'A', 2, 'Premium'),
  (3, 102, 'B', 5, 'Standard'),
  (4, 103, 'C', 10, 'Recliner'),
  (5, 101, 'B', 1, 'Premium'),
  (6, 102, 'A', 1, 'Standard'),
  (7, 103, 'A', 1, 'Recliner');

INSERT INTO showtime VALUES
  (1, 1, 101, '2025-11-02 18:00:00', '2025-11-02 20:30:00', 80.00),
  (2, 2, 102, '2025-11-02 19:00:00', '2025-11-02 22:00:00', 60.00),
  (3, 3, 103, '2025-11-03 21:00:00', '2025-11-03 23:30:00', 100.00),
  (4, 1, 101, '2025-11-03 15:00:00', '2025-11-03 17:30:00', 80.00), 
  (5, 4, 102, '2025-11-03 17:00:00', '2025-11-03 20:00:00', 70.00);

INSERT INTO ticket VALUES
  (1, 1, 1, 80.00),
  (2, 1, 2, 100.00),
  (3, 2, 3, 60.00),
  (4, 3, 4, 120.00),
  (5, 4, 5, 80.00),
  (6, 5, 3, 70.00),
  (7, 5, 7, 110.00);

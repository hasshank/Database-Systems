/* Hassan Hankir, 02/11/2025, SQL queries */

USE cinema;

/* Showtimes where all tickets cost above 70 */

SELECT DISTINCT st.showtime_id, m.title 
FROM showtime AS st
JOIN movie AS m ON st.movie_id = m.movie_id
WHERE st.showtime_id IN (
    SELECT showtime_id FROM ticket WHERE final_price > 70
);

/* Show seats and their room type */

SELECT s.seat_id, s.seat_row, r.room_type 
FROM seat AS s
JOIN room AS r ON s.room_id = r.room_id;

/* Show ticket prices and related movie titles */

SELECT m.title, t.final_price 
FROM ticket AS t
JOIN showtime AS st ON t.showtime_id = st.showtime_id
JOIN movie AS m ON st.movie_id = m.movie_id;

/* Movies with no showtimes */

SELECT movie_id, title
FROM movie
WHERE movie_id NOT IN (SELECT movie_id FROM showtime);

/* Rooms without scheduled showtimes */

SELECT room_id, room_name
FROM room
WHERE room_id NOT IN (SELECT room_id FROM showtime);

/* Showtimes for movies by Christopher Nolan */

SELECT m.title, st.start_time, r.room_name
FROM movie AS m
JOIN showtime AS st ON m.movie_id = st.movie_id
JOIN room AS r ON st.room_id = r.room_id
WHERE m.director = 'Christopher Nolan';

/* List unsold seats */

SELECT seat_id, seat_row, seat_number
FROM seat
WHERE seat_id NOT IN (SELECT seat_id FROM ticket);

/* Show each movie, its room, and showtime */

SELECT m.title, r.room_name, st.start_time
FROM movie AS m
JOIN showtime AS st ON m.movie_id = st.movie_id
JOIN room AS r ON st.room_id = r.room_id;

/* Find movies whose showtime price is more than 80 dhs and longer than 120 minutes */

SELECT m.title, st.start_time, st.price, m.duration_minutes
FROM movie AS m
JOIN showtime AS st ON m.movie_id = st.movie_id
WHERE st.price > 80 AND m.duration_minutes > 120;

/* Find rooms that have only premium or recliner seats */

SELECT r.room_id, r.room_name, s.seat_type 
FROM room AS r
JOIN seat AS s ON r.room_id = s.room_id
WHERE s.seat_type= 'Premium' OR s.seat_type= 'Recliner';

/*	Find movies that are scheduled only in IMAX rooms*/

SELECT DISTINCT m.movie_id, m.title, r.room_type
FROM movie AS m
JOIN showtime AS st ON m.movie_id = st.movie_id
JOIN room r ON st.room_id = r.room_id
WHERE r.room_type= 'IMAX';

/*	Movies that are shown in a Standard room */

SELECT movie_id, title
FROM movie
EXCEPT
SELECT m.movie_id, m.title
FROM movie AS m
JOIN showtime AS st ON m.movie_id = st.movie_id
JOIN room AS r ON st.room_id = r.room_id
WHERE r.room_type = 'Standard';

/* Find all tickets whose price is greater than the average price of their showtime.correlated query */

SELECT ticket_id, showtime_id, final_price
FROM ticket t
WHERE final_price > (
    SELECT AVG(final_price)
    FROM ticket as t2
    WHERE t2.showtime_id = t.showtime_id
);

/* Longest 2 movies shown in IMAX */

SELECT *
FROM movie
WHERE movie_id IN (
    SELECT movie_id
    FROM showtime NATURAL JOIN room
    WHERE room_type = 'IMAX'
)
ORDER BY duration_minutes DESC
LIMIT 2;

/* Room with highest total sales */

WITH rs AS (
    SELECT room_id, room_name, SUM(final_price) AS total_sales
    FROM ticket NATURAL JOIN showtime NATURAL JOIN room
    GROUP BY room_id
)
SELECT *
FROM rs
WHERE total_sales = (SELECT MAX(total_sales) FROM rs);

/* Movie with the highest number of tickets sold */

WITH movie_sales AS (
    SELECT s.movie_id, COUNT(*) AS tickets_sold
    FROM ticket t
    JOIN showtime AS s ON t.showtime_id = s.showtime_id
    GROUP BY s.movie_id
)
SELECT movie_id, tickets_sold
FROM movie_sales
WHERE tickets_sold = (SELECT MAX(tickets_sold) FROM movie_sales);

/*  Total number of tickets sold per movie */

SELECT m.title, COUNT(t.ticket_id) AS tickets_sold FROM movie AS m
JOIN showtime AS st ON m.movie_id = st.movie_id
LEFT JOIN ticket AS t ON st.showtime_id = t.showtime_id
GROUP BY m.movie_id, m.title
ORDER BY tickets_sold DESC;

/* Average ticket price per room type */

SELECT r.room_type, AVG(t.final_price) AS avg_price FROM room AS r
JOIN showtime AS st ON r.room_id = st.room_id
JOIN ticket AS t ON st.showtime_id = t.showtime_id
GROUP BY r.room_type
ORDER BY avg_price DESC;

/* Total number of showtimes per director */

SELECT m.director, COUNT(st.showtime_id) AS showtime_count FROM movie AS m
LEFT JOIN showtime AS st ON m.movie_id = st.movie_id
GROUP BY m.director
ORDER BY showtime_count DESC;

/* Directors with average movie duration */

SELECT director_stats.director, director_stats.movie_count, director_stats.avg_duration
FROM (
    SELECT director, COUNT(*) AS movie_count, AVG(duration_minutes) AS avg_duration FROM movie
    GROUP BY director
) AS director_stats
WHERE director_stats.movie_count >= 1
ORDER BY director_stats.avg_duration DESC;

/* CTE: Movies Longer Than Average Duration */

WITH avg_length AS (
    SELECT AVG(duration_minutes) AS avg_duration
    FROM movie
)
SELECT 
    movie_id,
    title,
    duration_minutes
FROM movie, avg_length
WHERE duration_minutes > avg_duration;

/* CTE: Most Popular Movie */

WITH ticket_counts AS (
    SELECT 
        m.movie_id,
        m.title,
        COUNT(t.ticket_id) AS ticket_count
    FROM movie AS m
    JOIN showtime AS s ON m.movie_id = s.movie_id
    JOIN ticket AS t ON s.showtime_id = t.showtime_id
    GROUP BY m.movie_id, m.title
)
SELECT * 
FROM ticket_counts
ORDER BY ticket_count DESC
LIMIT 1;

/* CTE: Movie with duration higher than average */

WITH avg_length AS (
    SELECT AVG(duration_minutes) AS avg_duration
    FROM movie
)
SELECT 
    movie_id,
    title,
    duration_minutes
FROM movie, avg_length
WHERE duration_minutes > avg_duration;

/* View */

DROP VIEW IF EXISTS view_showtime_details;
CREATE VIEW view_showtime_details AS
SELECT 
    s.showtime_id,
    m.title AS movie_title,
    m.genre,
    r.room_name,
    r.room_type,
    s.start_time,
    s.end_time,
    s.price
FROM showtime AS s
JOIN movie AS m ON s.movie_id = m.movie_id
JOIN room AS r ON s.room_id = r.room_id;

/* View */

DROP VIEW IF EXISTS view_movie_revenue;
CREATE VIEW view_movie_revenue AS
SELECT 
    m.movie_id,
    m.title,
    SUM(t.final_price) AS total_revenue,
    COUNT(t.ticket_id) AS total_tickets_sold
FROM movie AS m
LEFT JOIN showtime AS s ON m.movie_id = s.movie_id
LEFT JOIN ticket AS t ON s.showtime_id = t.showtime_id
GROUP BY m.movie_id, m.title;

/* View */

DROP VIEW IF EXISTS view_seat_occupancy;
CREATE VIEW view_seat_occupancy AS
SELECT 
    s.showtime_id,
    r.room_name,
    COUNT(t.ticket_id) AS seats_taken,
    COUNT(se.seat_id) AS total_seats,
    (COUNT(t.ticket_id) / COUNT(se.seat_id)) * 100 AS occupancy_rate
FROM showtime AS s
JOIN room AS r ON s.room_id = r.room_id
JOIN seat AS se ON r.room_id = se.room_id
LEFT JOIN ticket t ON s.showtime_id = t.showtime_id AND se.seat_id = t.seat_id
GROUP BY s.showtime_id, r.room_name;

/* Trigger */

DELIMITER $$

DROP TRIGGER IF EXISTS trg_check_capacity;
CREATE TRIGGER trg_check_capacity
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
    DECLARE total_sold INT;
    DECLARE room_cap INT;
    DECLARE roomid INT;

    SELECT room_id INTO roomid
    FROM showtime WHERE showtime_id = NEW.showtime_id;

    SELECT capacity INTO room_cap
    FROM room WHERE room_id = roomid;

    SELECT COUNT(ticket_id) INTO total_sold
    FROM ticket WHERE showtime_id = NEW.showtime_id;

    IF total_sold >= room_cap THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Room capacity exceeded!';
    END IF;
END$$

DELIMITER ;

/* Trigger */

DELIMITER $$

DROP TRIGGER IF EXISTS trg_prevent_double_booking;
CREATE TRIGGER trg_prevent_double_booking
BEFORE INSERT ON ticket
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM ticket
        WHERE seat_id = NEW.seat_id
        AND showtime_id = NEW.showtime_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Seat already booked for this showtime!';
    END IF;
END$$

DELIMITER ;

/* Procedure */

DROP PROCEDURE IF EXISTS get_movie_revenue;

DELIMITER $$

CREATE PROCEDURE get_movie_revenue(p_movie_id INT)
BEGIN
    SELECT 
        m.movie_id,
        m.title,
        SUM(t.final_price) AS total_revenue
    FROM movie AS m
    JOIN showtime AS s ON m.movie_id = s.movie_id
    JOIN ticket AS t ON s.showtime_id = t.showtime_id
    WHERE m.movie_id = p_movie_id
    GROUP BY m.movie_id, m.title;
END$$

DELIMITER ;

/* Procedure */

DROP PROCEDURE IF EXISTS get_available_seats;

DELIMITER $$

CREATE PROCEDURE get_available_seats(p_showtime_id INT)
BEGIN
    SELECT 
        se.seat_id,
        se.seat_row,
        se.seat_number,
        se.seat_type
    FROM seat AS se
    JOIN showtime AS sh ON se.room_id = sh.room_id
    WHERE sh.showtime_id = p_showtime_id
    AND se.seat_id NOT IN (
        SELECT seat_id FROM ticket WHERE showtime_id = p_showtime_id
    );
END$$

DELIMITER ;




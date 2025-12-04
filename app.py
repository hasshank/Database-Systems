from flask import Flask, render_template, request, redirect
import mysql.connector

app = Flask(__name__)

db = mysql.connector.connect(
    host="localhost",
    user="username",
    password="password",
    database="cinema"
)
cursor = db.cursor(dictionary=True)

# ============================
# NAV BAR
# ============================
@app.context_processor
def inject_nav():
    return dict()

# ============================
# MOVIES (index page)
# ============================
@app.route("/", methods=["GET", "POST"])
def movies():
    search = request.form.get("search", "")

    if search:
        cursor.execute("SELECT * FROM movie WHERE title LIKE %s", (f"%{search}%",))
    else:
        cursor.execute("SELECT * FROM movie")

    movies = cursor.fetchall()
    return render_template("index.html", movies=movies, search=search)

@app.route("/add", methods=["POST"])
def add_movie():
    cursor.execute("""
        INSERT INTO movie (movie_id, title, genre, duration_minutes, release_date, director)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        request.form["movie_id"],
        request.form["title"],
        request.form["genre"],
        request.form["duration"],
        request.form["release_date"],
        request.form["director"]
    ))
    db.commit()
    return redirect("/")

@app.route("/edit/<int:id>")
def edit_movie(id):
    cursor.execute("SELECT * FROM movie WHERE movie_id=%s", (id,))
    movie = cursor.fetchone()
    return render_template("edit.html", movie=movie)

@app.route("/update/<int:id>", methods=["POST"])
def update_movie(id):
    cursor.execute("""
        UPDATE movie SET title=%s, genre=%s, duration_minutes=%s, release_date=%s, director=%s
        WHERE movie_id=%s
    """, (
        request.form["title"],
        request.form["genre"],
        request.form["duration"],
        request.form["release_date"],
        request.form["director"],
        id
    ))
    db.commit()
    return redirect("/")

@app.route("/delete/<int:id>")
def delete_movie(id):
    cursor.execute("DELETE FROM movie WHERE movie_id=%s", (id,))
    db.commit()
    return redirect("/")

# ============================
# ROOMS
# ============================
@app.route("/rooms")
def rooms():
    cursor.execute("SELECT * FROM room")
    rooms = cursor.fetchall()
    return render_template("rooms.html", rooms=rooms)

@app.route("/rooms/add", methods=["POST"])
def add_room():
    cursor.execute("""
        INSERT INTO room VALUES (%s, %s, %s, %s)
    """, (
        request.form["room_id"],
        request.form["room_name"],
        request.form["capacity"],
        request.form["room_type"]
    ))
    db.commit()
    return redirect("/rooms")

@app.route("/rooms/edit/<int:id>")
def edit_room(id):
    cursor.execute("SELECT * FROM room WHERE room_id=%s", (id,))
    room = cursor.fetchone()
    return render_template("edit_room.html", room=room)

@app.route("/rooms/update/<int:id>", methods=["POST"])
def update_room(id):
    cursor.execute("""
        UPDATE room SET room_name=%s, capacity=%s, room_type=%s WHERE room_id=%s
    """, (
        request.form["room_name"],
        request.form["capacity"],
        request.form["room_type"],
        id
    ))
    db.commit()
    return redirect("/rooms")

@app.route("/rooms/delete/<int:id>")
def delete_room(id):
    cursor.execute("DELETE FROM room WHERE room_id=%s", (id,))
    db.commit()
    return redirect("/rooms")

# ============================
# SEATS
# ============================
@app.route("/seats")
def seats():
    cursor.execute("""
        SELECT seat.*, room.room_name
        FROM seat
        JOIN room ON room.room_id = seat.room_id
    """)
    seats = cursor.fetchall()
    cursor.execute("SELECT * FROM room")
    rooms = cursor.fetchall()
    return render_template("seats.html", seats=seats, rooms=rooms)

@app.route("/seats/add", methods=["POST"])
def add_seat():
    cursor.execute("""
        INSERT INTO seat VALUES (%s, %s, %s, %s, %s)
    """, (
        request.form["seat_id"],
        request.form["room_id"],
        request.form["seat_row"],
        request.form["seat_number"],
        request.form["seat_type"]
    ))
    db.commit()
    return redirect("/seats")

@app.route("/seats/edit/<int:id>")
def edit_seat(id):
    cursor.execute("SELECT * FROM seat WHERE seat_id=%s", (id,))
    seat = cursor.fetchone()
    cursor.execute("SELECT * FROM room")
    rooms = cursor.fetchall()
    return render_template("edit_seat.html", seat=seat, rooms=rooms)

@app.route("/seats/update/<int:id>", methods=["POST"])
def update_seat(id):
    cursor.execute("""
        UPDATE seat SET room_id=%s, seat_row=%s, seat_number=%s, seat_type=%s
        WHERE seat_id=%s
    """, (
        request.form["room_id"],
        request.form["seat_row"],
        request.form["seat_number"],
        request.form["seat_type"],
        id
    ))
    db.commit()
    return redirect("/seats")

@app.route("/seats/delete/<int:id>")
def delete_seat(id):
    cursor.execute("DELETE FROM seat WHERE seat_id=%s", (id,))
    db.commit()
    return redirect("/seats")

# ============================
# SHOWTIMES
# ============================
@app.route("/showtimes")
def showtimes():
    cursor.execute("""
        SELECT s.*, m.title, r.room_name
        FROM showtime s
        JOIN movie m ON m.movie_id = s.movie_id
        JOIN room r ON r.room_id = s.room_id
    """)
    showtimes = cursor.fetchall()

    cursor.execute("SELECT movie_id, title FROM movie")
    movies = cursor.fetchall()

    cursor.execute("SELECT room_id, room_name FROM room")
    rooms = cursor.fetchall()

    return render_template("showtimes.html", showtimes=showtimes, movies=movies, rooms=rooms)

@app.route("/showtimes/add", methods=["POST"])
def add_showtime():
    cursor.execute("""
        INSERT INTO showtime VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        request.form["showtime_id"],
        request.form["movie_id"],
        request.form["room_id"],
        request.form["start_time"],
        request.form["end_time"],
        request.form["price"]
    ))
    db.commit()
    return redirect("/showtimes")

@app.route("/showtimes/edit/<int:id>")
def edit_showtime(id):
    cursor.execute("SELECT * FROM showtime WHERE showtime_id=%s", (id,))
    showtime = cursor.fetchone()

    cursor.execute("SELECT movie_id, title FROM movie")
    movies = cursor.fetchall()

    cursor.execute("SELECT room_id, room_name FROM room")
    rooms = cursor.fetchall()

    return render_template("edit_showtime.html", showtime=showtime, movies=movies, rooms=rooms)

@app.route("/showtimes/update/<int:id>", methods=["POST"])
def update_showtime(id):
    cursor.execute("""
        UPDATE showtime
        SET movie_id=%s, room_id=%s, start_time=%s, end_time=%s, price=%s
        WHERE showtime_id=%s
    """, (
        request.form["movie_id"],
        request.form["room_id"],
        request.form["start_time"],
        request.form["end_time"],
        request.form["price"],
        id
    ))
    db.commit()
    return redirect("/showtimes")

@app.route("/showtimes/delete/<int:id>")
def delete_showtime(id):
    cursor.execute("DELETE FROM showtime WHERE showtime_id=%s", (id,))
    db.commit()
    return redirect("/showtimes")

# ============================
# TICKETS
# ============================
@app.route("/tickets")
def tickets():
    cursor.execute("""
        SELECT t.*, s.start_time, m.title, seat.seat_row, seat.seat_number
        FROM ticket t
        JOIN showtime s ON s.showtime_id = t.showtime_id
        JOIN movie m ON m.movie_id = s.movie_id
        JOIN seat ON seat.seat_id = t.seat_id
    """)
    tickets = cursor.fetchall()

    cursor.execute("SELECT showtime_id FROM showtime")
    showtimes = cursor.fetchall()

    cursor.execute("SELECT seat_id FROM seat")
    seats = cursor.fetchall()

    return render_template("tickets.html", tickets=tickets, showtimes=showtimes, seats=seats)

@app.route("/tickets/add", methods=["POST"])
def add_ticket():
    cursor.execute("""
        INSERT INTO ticket VALUES (%s, %s, %s, %s)
    """, (
        request.form["ticket_id"],
        request.form["showtime_id"],
        request.form["seat_id"],
        request.form["final_price"]
    ))
    db.commit()
    return redirect("/tickets")

@app.route("/tickets/edit/<int:id>")
def edit_ticket(id):
    cursor.execute("SELECT * FROM ticket WHERE ticket_id=%s", (id,))
    ticket = cursor.fetchone()

    cursor.execute("SELECT showtime_id FROM showtime")
    showtimes = cursor.fetchall()

    cursor.execute("SELECT seat_id FROM seat")
    seats = cursor.fetchall()

    return render_template("edit_ticket.html", ticket=ticket, showtimes=showtimes, seats=seats)

@app.route("/tickets/update/<int:id>", methods=["POST"])
def update_ticket(id):
    cursor.execute("""
        UPDATE ticket SET showtime_id=%s, seat_id=%s, final_price=%s
        WHERE ticket_id=%s
    """, (
        request.form["showtime_id"],
        request.form["seat_id"],
        request.form["final_price"],
        id
    ))
    db.commit()
    return redirect("/tickets")

@app.route("/tickets/delete/<int:id>")
def delete_ticket(id):
    cursor.execute("DELETE FROM ticket WHERE ticket_id=%s", (id,))
    db.commit()
    return redirect("/tickets")

if __name__ == "__main__":
    app.run(debug=True)

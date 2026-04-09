USE platinumrx;

-- =========================
-- HOTEL SYSTEM
-- =========================

DROP TABLE IF EXISTS booking_commercials;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS users;

-- =========================
-- TABLE CREATION
-- =========================

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    user_id INT,
    room_no INT,
    booking_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE items (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100),
    rate DECIMAL(10,2)
);

CREATE TABLE booking_commercials (
    bill_id INT PRIMARY KEY,
    booking_id INT,
    item_id INT,
    qty INT,
    bill_date DATE,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);

-- =========================
-- SAMPLE DATA
-- =========================

INSERT INTO users VALUES
(1,'A'),(2,'B'),(3,'C');

INSERT INTO bookings VALUES
(101,1,201,'2021-10-10'),
(102,1,202,'2021-11-15'),
(103,2,203,'2021-11-20'),
(104,3,204,'2021-10-25');

INSERT INTO items VALUES
(1,'Food',100),
(2,'Laundry',50),
(3,'Spa',500);

INSERT INTO booking_commercials VALUES
(1,101,1,5,'2021-10-10'),
(2,101,2,10,'2021-10-10'),
(3,102,3,3,'2021-11-15'),
(4,103,1,8,'2021-11-20'),
(5,104,3,1,'2021-10-25');

-- =========================
-- Q1: Latest booking per user
-- =========================
SELECT user_id, room_no
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) rn
    FROM bookings
) t
WHERE rn = 1;

-- =========================
-- Q2: Total bill in Nov 2021
-- =========================
SELECT b.booking_id,
       SUM(bc.qty * i.rate) AS total_bill
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date)=11 AND YEAR(bc.bill_date)=2021
GROUP BY b.booking_id;

-- =========================
-- Q3: October bills > 1000
-- =========================
SELECT bc.bill_id,
       SUM(bc.qty * i.rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date)=10 AND YEAR(bc.bill_date)=2021
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

-- =========================
-- Q4: Most & least ordered item per month
-- =========================
WITH item_counts AS (
    SELECT MONTH(bill_date) AS mth,
           item_id,
           SUM(qty) AS total_qty
    FROM booking_commercials
    WHERE YEAR(bill_date)=2021
    GROUP BY mth, item_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY mth ORDER BY total_qty DESC) r_desc,
           RANK() OVER (PARTITION BY mth ORDER BY total_qty ASC) r_asc
    FROM item_counts
)
SELECT * FROM ranked
WHERE r_desc=1 OR r_asc=1;

-- =========================
-- Q5: 2nd highest bill per month
-- =========================
WITH bill_totals AS (
    SELECT MONTH(bill_date) AS mth,
           bill_id,
           SUM(qty * i.rate) AS total
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bill_date)=2021
    GROUP BY mth, bill_id
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY mth ORDER BY total DESC) rnk
    FROM bill_totals
)
SELECT * FROM ranked
WHERE rnk = 2;
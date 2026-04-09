USE platinumrx;

-- =========================
-- CLINIC SYSTEM
-- =========================

DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS clinic_sales;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS clinics;

-- =========================
-- TABLE CREATION
-- =========================

CREATE TABLE clinics (
    clinic_id INT PRIMARY KEY,
    clinic_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100)
);

CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE clinic_sales (
    sale_id INT PRIMARY KEY,
    clinic_id INT,
    customer_id INT,
    sales_channel VARCHAR(50),
    amount DECIMAL(10,2),
    sale_date DATE,
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE expenses (
    expense_id INT PRIMARY KEY,
    clinic_id INT,
    amount DECIMAL(10,2),
    expense_date DATE,
    FOREIGN KEY (clinic_id) REFERENCES clinics(clinic_id)
);

-- =========================
-- SAMPLE DATA
-- =========================

INSERT INTO clinics VALUES
(1,'ClinicA','Hyd','TS'),
(2,'ClinicB','Hyd','TS'),
(3,'ClinicC','Blr','KA');

INSERT INTO customer VALUES
(1,'Cust1'),(2,'Cust2'),(3,'Cust3');

INSERT INTO clinic_sales VALUES
(1,1,1,'Online',1000,'2021-01-10'),
(2,1,2,'Offline',2000,'2021-02-10'),
(3,2,3,'Online',3000,'2021-03-15'),
(4,3,1,'Offline',4000,'2021-03-20');

INSERT INTO expenses VALUES
(1,1,500,'2021-01-10'),
(2,1,1000,'2021-02-10'),
(3,2,2000,'2021-03-15'),
(4,3,1500,'2021-03-20');

-- =========================
-- Q1: Revenue per channel
-- =========================
SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(sale_date)=2021
GROUP BY sales_channel;

-- =========================
-- Q2: Top 10 customers
-- =========================
SELECT customer_id,
       SUM(amount) AS total_spend
FROM clinic_sales
WHERE YEAR(sale_date)=2021
GROUP BY customer_id
ORDER BY total_spend DESC
LIMIT 10;

-- =========================
-- Q3: Month-wise revenue, expense, profit
-- =========================
WITH r AS (
    SELECT clinic_id, MONTH(sale_date) mth, SUM(amount) rev
    FROM clinic_sales
    GROUP BY clinic_id, mth
),
e AS (
    SELECT clinic_id, MONTH(expense_date) mth, SUM(amount) exp
    FROM expenses
    GROUP BY clinic_id, mth
)
SELECT r.mth,
       SUM(r.rev) AS revenue,
       SUM(IFNULL(e.exp,0)) AS expense,
       SUM(r.rev - IFNULL(e.exp,0)) AS profit,
       CASE WHEN SUM(r.rev - IFNULL(e.exp,0)) > 0 THEN 'profitable'
            ELSE 'not-profitable' END AS status
FROM r
LEFT JOIN e ON r.clinic_id=e.clinic_id AND r.mth=e.mth
GROUP BY r.mth
ORDER BY r.mth;

-- =========================
-- Q4: Most profitable clinic per city
-- =========================
WITH revenue AS (
    SELECT clinic_id, SUM(amount) AS total_revenue
    FROM clinic_sales
    GROUP BY clinic_id
),
expense AS (
    SELECT clinic_id, SUM(amount) AS total_expense
    FROM expenses
    GROUP BY clinic_id
),
profit_calc AS (
    SELECT c.city,
           c.clinic_id,
           (r.total_revenue - IFNULL(e.total_expense,0)) AS profit
    FROM clinics c
    LEFT JOIN revenue r ON c.clinic_id = r.clinic_id
    LEFT JOIN expense e ON c.clinic_id = e.clinic_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) rnk
    FROM profit_calc
)
SELECT *
FROM ranked
WHERE rnk = 1;

-- =========================
-- Q5: 2nd least profitable clinic per state
-- =========================
WITH revenue AS (
    SELECT clinic_id, SUM(amount) AS total_revenue
    FROM clinic_sales
    GROUP BY clinic_id
),
expense AS (
    SELECT clinic_id, SUM(amount) AS total_expense
    FROM expenses
    GROUP BY clinic_id
),
profit_calc AS (
    SELECT c.state,
           c.clinic_id,
           (r.total_revenue - IFNULL(e.total_expense,0)) AS profit
    FROM clinics c
    LEFT JOIN revenue r ON c.clinic_id = r.clinic_id
    LEFT JOIN expense e ON c.clinic_id = e.clinic_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY state ORDER BY profit ASC) rnk
    FROM profit_calc
)
SELECT *
FROM ranked
WHERE rnk = 2;
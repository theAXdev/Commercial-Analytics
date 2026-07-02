
-- Exploring SQL and Power BI Integration

-- For this  Commercial Analytics Project , Dataset used  got derived  from Plato's Pizza , a leading Pizza Selling Company.

--------------------------------------------------------------------
--------------------------------------------------------------------

-- TABLE CREATION
-- I am creating the table to hold our initial dataset.
CREATE TABLE plato_combined (
    order_details_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id VARCHAR(50) NOT NULL,         
    quantity INT NOT NULL,
    order_date DATE NOT NULL,              
    order_time TIME NOT NULL,
    unit_price NUMERIC(5, 2) NOT NULL,
    total_price NUMERIC(6, 2) NOT NULL,
    pizza_size VARCHAR(10) NOT NULL,
    pizza_category VARCHAR(50) NOT NULL,
    pizza_ingredients TEXT NOT NULL,
    pizza_name VARCHAR(100) NOT NULL
);

--------------------------------------------------------------------
--------------------------------------------------------------------

-- NORMALIZATION
-- I am starting the process of normalization now.
-- My goal is to break the big 'plato_combined' table into the four smaller,
-- related tables needed for a clean Star Schema design in Power BI.

-- 1. Creating the PIZZA_TYPES Dimension Table
-- This table will hold the static details about each unique pizza type (category, ingredients, name).
-- I am using DISTINCT to ensure I only get one row per pizza type.
CREATE TABLE pizza_types AS
SELECT DISTINCT
    -- Extracting the base ID by removing the last 2 characters (e.g., '_m', '_l') from pizza_id
    LEFT(pizza_id, LENGTH(pizza_id) - 2) AS pizza_type_id,
    pizza_name AS name,
    pizza_category AS category,
    pizza_ingredients AS ingredients
FROM plato_combined;

-- Adding a Primary Key to my new dimension table for good data practice.
ALTER TABLE pizza_types
ADD PRIMARY KEY (pizza_type_id);

SELECT *
FROM pizza_types;


-- 2. Creating the PIZZAS Dimension Table
-- This table defines the unique SKU for each pizza size and price combination.
-- It links back to the pizza_types table via the pizza_type_id.
DROP TABLE IF EXISTS pizzas;
CREATE TABLE pizzas AS
SELECT DISTINCT
    pizza_id,
    -- Extracting the base ID by removing the last 2 characters (e.g., '_m', '_l') from pizza_id
    LEFT(pizza_id, LENGTH(pizza_id) - 2) AS pizza_type_id,
    pizza_size AS size,
    unit_price AS price
FROM plato_combined;

-- Adding a Primary Key to my new dimension table.
ALTER TABLE pizzas
ADD PRIMARY KEY (pizza_id);

SELECT *
FROM pizzas;


-- 3. Creating the ORDERS Dimension Table
-- This table captures the date and time of the customer transactions.
-- I'm using DISTINCT on order_id to get one record per unique transaction.
-- Since I corrected the order_date type in the source table, the date conversion is clean here!
DROP TABLE IF EXISTS orders;
CREATE TABLE orders AS
SELECT DISTINCT
    order_id,
    order_date AS date,
    order_time AS time
FROM plato_combined;

-- Adding a Primary Key to my order dimension table.
ALTER TABLE orders
ADD PRIMARY KEY (order_id);

SELECT *
FROM orders;


-- 4. Creating the ORDER_DETAILS Fact Table
-- This is our central Fact table! It contains the measurable metrics (quantity) and foreign keys.
-- The total_price is renamed to line_item_revenue since it's the actual metric for that line item.
DROP TABLE IF EXISTS order_details;
CREATE TABLE order_details AS
SELECT
    order_details_id,
    order_id,
    pizza_id,
    quantity,
    total_price AS line_item_revenue -- Renaming to match BI naming conventions
FROM plato_combined;

-- This is the unique identifier for each row in my Fact table.
ALTER TABLE order_details
ADD PRIMARY KEY (order_details_id);

SELECT *
FROM order_details;

--------------------------------------------------------------------
--------------------------------------------------------------------

-- KEY PERFORMANCE INDICATORS
-- In the next sets of queries, I will be calculating and displaying my Key Performance Indicators (KPIs).
-- These give us an immediate, high-level view of our restaurant's financial health and operational performance.

-- 1. Total Revenue
-- My first KPI: Calculating the total money we generated from all pizza sales.
SELECT
    SUM(total_price) AS "Total Revenue"
FROM plato_combined;

-- Total Revenue = $817,860.05


-- 2. Total Quantity Sold
-- Next, I am calculating the total count of all pizza slices/units we sold across all orders.
SELECT
    SUM(quantity) AS "Total Quantity Sold"
FROM plato_combined;

-- Total Quantity Sold = 49,574


-- 3. Total Orders
-- This KPI shows the total number of unique transactions placed by our customers.
SELECT
    COUNT(DISTINCT order_id) AS "Total Orders"
FROM plato_combined;

-- Total Orders = 21,350


-- 4. Average Order Value
-- This is a very important financial KPI, telling us the average revenue we get per transaction—a key metric for upselling efforts.
-- I calculate this by dividing our Total Revenue by our Total Orders.
SELECT
    SUM(total_price) / COUNT(DISTINCT order_id) AS "Average Order Value"
FROM plato_combined;

-- Average Order Value = $38.31


-- 5. Average Daily Orders
-- This is a key operational KPI, showing the average number of orders our staff handles on any given day.
-- I calculate the Total Orders and divide it by the count of unique dates in the dataset.
SELECT
    COUNT(DISTINCT order_id) / COUNT(DISTINCT order_date) AS "Average Daily Orders"
FROM plato_combined;

-- Average Daily Orders = 59

--------------------------------------------------------------------
--------------------------------------------------------------------

-- ANALYSIS QUERIES
-- Now I am starting the detailed analysis queries to find trends, best/worst sellers, and peak times for the Power BI report.

-- 1. Top 5 Pizzas by Revenue
-- I want to start by identifying our top revenue generators. I'm grouping the sales data by pizza name and ordering by total revenue, then taking the top 5.
SELECT
    pizza_name,
    SUM(total_price) AS total_revenue
FROM plato_combined
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 2. Bottom 5 Pizzas by Revenue
-- Next, I need to find the inventory drags. These are our bottom 5 pizzas by revenue—potential candidates for menu removal to simplify operations and save us money.
SELECT
    pizza_name,
    SUM(total_price) AS total_revenue
FROM plato_combined
GROUP BY 1
ORDER BY 2 ASC
LIMIT 5;


-- 3. Total Revenue by Month
-- I'll look for seasonality now. I'm analyzing our Total Revenue broken down monthly. I'm using TO_CHAR to format the date correctly so we can sort by year and month.
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS "Year-Month",
    SUM(total_price) AS total_revenue
FROM plato_combined
GROUP BY 1
ORDER BY 1;


-- 4. Total Quantity Sold by Month
-- This query shows our monthly volume (quantity sold) to check if raw order counts follow the same seasonality pattern as revenue.
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS "Year-Month",
    SUM(quantity) AS total_quantity_sold
FROM plato_combined
GROUP BY 1
ORDER BY 1;


-- 5. Total Orders Placed by Month
-- I need the raw total order count per month to compare our customer traffic trends.
SELECT
    TO_CHAR(order_date, 'YYYY-MM') AS "Year-Month",
    COUNT(DISTINCT order_id) AS total_orders
FROM plato_combined
GROUP BY 1
ORDER BY 1;


-- 6. Quantity Sold by Pizza Size
-- This answers which pizza sizes are most popular, which is crucial for our pricing strategy and ingredient stock levels.
SELECT
    pizza_size,
    SUM(quantity) AS total_quantity_sold
FROM plato_combined
GROUP BY 1
ORDER BY 2 DESC;


-- 7. Revenue by Pizza Category
-- I'm calculating revenue by category (Classic, Chicken, Veggie) to see which product grouping is our strongest performer and deserves the most focus.
SELECT
    pizza_category,
    SUM(total_price) AS total_revenue
FROM plato_combined
GROUP BY 1
ORDER BY 2 DESC;


-- 8. Total Revenue by Day of the Week
-- This query shows our daily revenue trends. I'm using EXTRACT(DOW) to ensure the days are sorted chronologically (Sunday=0 to Saturday=6).
SELECT
    EXTRACT(DOW FROM order_date) AS day_of_week_num, -- DOW 0=Sunday, 6=Saturday
    TO_CHAR(order_date, 'Day') AS day_name,
    SUM(total_price) AS total_revenue
FROM plato_combined
GROUP BY 1, 2
ORDER BY 1;


-- 9. Orders by Day & Hour (for Heatmap visualization)
-- This is the core operational query for the heatmap. It shows us exactly when the demand hits—Day of Week AND Hour of Day—which is vital for scheduling.
SELECT
    EXTRACT(DOW FROM order_date) AS day_of_week_num,
    TO_CHAR(order_date, 'Day') AS day_name,
    EXTRACT(HOUR FROM order_time) AS order_hour,
    COUNT(DISTINCT order_id) AS total_orders
FROM plato_combined
GROUP BY 1, 2, 3
ORDER BY 1, 3;


-- 10. Total Revenue by Day Type (Weekday vs. Weekend)
-- Finally, I'll group our sales into Weekday vs. Weekend buckets to understand the overall difference in business volume.
SELECT
    CASE
        WHEN EXTRACT(DOW FROM order_date) IN (0, 6) THEN 'Weekend' -- 0=Sunday, 6=Saturday
        ELSE 'Weekday'
    END AS day_type,
    SUM(total_price) AS total_revenue
FROM plato_combined
GROUP BY 1;


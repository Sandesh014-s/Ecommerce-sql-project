-- ============================================================
-- E-COMMERCE DATABASE MANAGEMENT SYSTEM
-- Database  : MS SQL Server (T-SQL)
-- Author    : [Your Name]
-- Description: Full SQL project for an e-commerce platform
--              covering schema design, data insertion, and
--              real-world business queries.
-- ============================================================


-- ============================================================
-- SECTION 1: DATABASE SETUP
-- ============================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ecommerce_db')
    CREATE DATABASE ecommerce_db;
GO

USE ecommerce_db;
GO


-- ============================================================
-- SECTION 2: TABLE CREATION (Normalized to 3NF)
-- ============================================================

-- Drop tables in reverse FK order if they exist (for re-runs)
IF OBJECT_ID('reviews',     'U') IS NOT NULL DROP TABLE reviews;
IF OBJECT_ID('payments',    'U') IS NOT NULL DROP TABLE payments;
IF OBJECT_ID('order_items', 'U') IS NOT NULL DROP TABLE order_items;
IF OBJECT_ID('orders',      'U') IS NOT NULL DROP TABLE orders;
IF OBJECT_ID('customers',   'U') IS NOT NULL DROP TABLE customers;
IF OBJECT_ID('products',    'U') IS NOT NULL DROP TABLE products;
IF OBJECT_ID('categories',  'U') IS NOT NULL DROP TABLE categories;
GO

-- 1. Categories
CREATE TABLE categories (
    category_id   INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(100)      NOT NULL,
    description   VARCHAR(MAX)
);
GO

-- 2. Products
CREATE TABLE products (
    product_id    INT IDENTITY(1,1) PRIMARY KEY,
    product_name  VARCHAR(200)      NOT NULL,
    category_id   INT               NOT NULL,
    price         DECIMAL(10,2)     NOT NULL CHECK (price >= 0),
    stock_qty     INT               NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    created_at    DATETIME          DEFAULT GETDATE(),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
GO

-- 3. Customers
CREATE TABLE customers (
    customer_id   INT IDENTITY(1,1) PRIMARY KEY,
    first_name    VARCHAR(100)      NOT NULL,
    last_name     VARCHAR(100)      NOT NULL,
    email         VARCHAR(200)      NOT NULL UNIQUE,
    phone         VARCHAR(20),
    city          VARCHAR(100),
    state         VARCHAR(100),
    created_at    DATETIME          DEFAULT GETDATE()
);
GO

-- 4. Orders
CREATE TABLE orders (
    order_id      INT IDENTITY(1,1) PRIMARY KEY,
    customer_id   INT               NOT NULL,
    order_date    DATETIME          DEFAULT GETDATE(),
    status        VARCHAR(20)       DEFAULT 'Pending'
                  CHECK (status IN ('Pending','Processing','Shipped','Delivered','Cancelled')),
    total_amount  DECIMAL(10,2)     DEFAULT 0,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
GO

-- 5. Order Items
CREATE TABLE order_items (
    item_id       INT IDENTITY(1,1) PRIMARY KEY,
    order_id      INT               NOT NULL,
    product_id    INT               NOT NULL,
    quantity      INT               NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2)     NOT NULL,
    CONSTRAINT fk_item_order   FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);
GO

-- 6. Payments
CREATE TABLE payments (
    payment_id    INT IDENTITY(1,1) PRIMARY KEY,
    order_id      INT               NOT NULL UNIQUE,
    payment_date  DATETIME          DEFAULT GETDATE(),
    amount        DECIMAL(10,2)     NOT NULL,
    method        VARCHAR(30)       CHECK (method IN ('Credit Card','Debit Card','UPI','Net Banking','Cash on Delivery')),
    status        VARCHAR(20)       DEFAULT 'Pending'
                  CHECK (status IN ('Pending','Completed','Failed','Refunded')),
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
GO

-- 7. Reviews
CREATE TABLE reviews (
    review_id     INT IDENTITY(1,1) PRIMARY KEY,
    product_id    INT               NOT NULL,
    customer_id   INT               NOT NULL,
    rating        TINYINT           CHECK (rating BETWEEN 1 AND 5),
    review_text   VARCHAR(MAX),
    review_date   DATETIME          DEFAULT GETDATE(),
    CONSTRAINT fk_review_product  FOREIGN KEY (product_id)  REFERENCES products(product_id),
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
GO


-- ============================================================
-- SECTION 3: INDEXES FOR PERFORMANCE
-- ============================================================

CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_status     ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_products_category ON products(category_id);
GO


-- ============================================================
-- SECTION 4: SAMPLE DATA
-- ============================================================

-- Categories
INSERT INTO categories (category_name, description) VALUES
('Electronics',    'Mobiles, laptops, and gadgets'),
('Fashion',        'Clothing, footwear, and accessories'),
('Home & Kitchen', 'Furniture, cookware, and appliances'),
('Books',          'Academic and general interest books'),
('Sports',         'Sports equipment and accessories');
GO

-- Products
INSERT INTO products (product_name, category_id, price, stock_qty) VALUES
('Samsung Galaxy S24',               1,  79999.00,  50),
('Apple iPhone 15',                  1,  89999.00,  30),
('Dell Laptop Inspiron 15',          1,  65000.00,  20),
('Sony Noise Cancelling Headphones', 1,  12999.00, 100),
('Men''s Slim Fit Jeans',            2,   1499.00, 200),
('Women''s Kurti Set',               2,    999.00, 150),
('Running Shoes - Nike',             2,   4999.00,  80),
('Leather Handbag',                  2,   2499.00,  60),
('Instant Pot Pressure Cooker',      3,   6999.00,  40),
('Non-Stick Cookware Set',           3,   3499.00,  70),
('Wooden Study Table',               3,   8999.00,  25),
('The Alchemist - Novel',            4,    399.00, 300),
('Data Structures & Algorithms',     4,    799.00, 200),
('Clean Code - Robert Martin',       4,    699.00, 180),
('Cricket Bat - SS',                 5,   2999.00,  90),
('Yoga Mat',                         5,    799.00, 120);
GO

-- Customers
INSERT INTO customers (first_name, last_name, email, phone, city, state) VALUES
('Rahul',   'Sharma',  'rahul.sharma@gmail.com',   '9876543210', 'Delhi',     'Delhi'),
('Priya',   'Patel',   'priya.patel@gmail.com',    '9876543211', 'Mumbai',    'Maharashtra'),
('Amit',    'Verma',   'amit.verma@gmail.com',     '9876543212', 'Bangalore', 'Karnataka'),
('Sneha',   'Gupta',   'sneha.gupta@gmail.com',    '9876543213', 'Hyderabad', 'Telangana'),
('Karan',   'Mehta',   'karan.mehta@gmail.com',    '9876543214', 'Chennai',   'Tamil Nadu'),
('Anjali',  'Singh',   'anjali.singh@gmail.com',   '9876543215', 'Kolkata',   'West Bengal'),
('Rohit',   'Kumar',   'rohit.kumar@gmail.com',    '9876543216', 'Pune',      'Maharashtra'),
('Neha',    'Joshi',   'neha.joshi@gmail.com',     '9876543217', 'Jaipur',    'Rajasthan'),
('Vikas',   'Rao',     'vikas.rao@gmail.com',      '9876543218', 'Lucknow',   'Uttar Pradesh'),
('Pooja',   'Nair',    'pooja.nair@gmail.com',     '9876543219', 'Ahmedabad', 'Gujarat');
GO

-- Orders
INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES
(1,  '2024-01-05 10:30:00', 'Delivered',   92498.00),
(2,  '2024-01-10 14:00:00', 'Delivered',    5998.00),
(3,  '2024-02-14 09:15:00', 'Shipped',     81498.00),
(4,  '2024-02-20 11:45:00', 'Processing',   7998.00),
(5,  '2024-03-01 16:00:00', 'Delivered',    3198.00),
(6,  '2024-03-15 13:30:00', 'Pending',     12999.00),
(7,  '2024-04-02 08:00:00', 'Delivered',    1897.00),
(8,  '2024-04-18 17:20:00', 'Cancelled',   89999.00),
(9,  '2024-05-05 12:00:00', 'Delivered',   10498.00),
(10, '2024-05-20 10:00:00', 'Shipped',      4798.00),
(1,  '2024-06-01 09:00:00', 'Delivered',    1998.00),
(3,  '2024-06-10 15:00:00', 'Delivered',    3499.00);
GO

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1,  1,  1,  79999.00),
(1,  4,  1,  12999.00),
(2,  7,  1,   4999.00),
(2,  16, 1,    999.00),
(3,  2,  1,  89999.00),
(3,  13, 1,    799.00),
(4,  9,  1,   6999.00),
(4,  10, 1,   3499.00),
(5,  15, 1,   2999.00),
(5,  6,  1,    999.00),
(6,  4,  1,  12999.00),
(7,  5,  1,   1499.00),
(7,  12, 1,    399.00),
(8,  2,  1,  89999.00),
(9,  3,  1,  65000.00),
(9,  13, 1,    799.00),
(10, 7,  1,   4999.00),
(11, 5,  1,   1499.00),
(11, 12, 1,    399.00),
(12, 10, 1,   3499.00);
GO

-- Payments
INSERT INTO payments (order_id, payment_date, amount, method, status) VALUES
(1,  '2024-01-05 10:32:00',  92498.00, 'Credit Card',      'Completed'),
(2,  '2024-01-10 14:05:00',   5998.00, 'UPI',              'Completed'),
(3,  '2024-02-14 09:20:00',  81498.00, 'Net Banking',      'Completed'),
(4,  '2024-02-20 11:50:00',   7998.00, 'Debit Card',       'Pending'),
(5,  '2024-03-01 16:05:00',   3198.00, 'UPI',              'Completed'),
(6,  '2024-03-15 13:35:00',  12999.00, 'Credit Card',      'Pending'),
(7,  '2024-04-02 08:10:00',   1897.00, 'Cash on Delivery', 'Completed'),
(8,  '2024-04-18 17:25:00',  89999.00, 'Credit Card',      'Refunded'),
(9,  '2024-05-05 12:05:00',  10498.00, 'Net Banking',      'Completed'),
(10, '2024-05-20 10:05:00',   4798.00, 'UPI',              'Completed'),
(11, '2024-06-01 09:05:00',   1998.00, 'UPI',              'Completed'),
(12, '2024-06-10 15:05:00',   3499.00, 'Debit Card',       'Completed');
GO

-- Reviews
INSERT INTO reviews (product_id, customer_id, rating, review_text) VALUES
(1,  1, 5, 'Excellent phone! Great camera and battery life.'),
(2,  3, 4, 'Good phone but slightly overpriced.'),
(4,  6, 5, 'Best headphones I have ever used!'),
(7,  2, 4, 'Comfortable and good quality.'),
(9,  4, 5, 'Makes cooking so much faster!'),
(3,  9, 4, 'Good laptop for the price, runs fast.'),
(13, 3, 5, 'A must-read for every programmer.'),
(15, 5, 3, 'Decent bat but could be better quality.'),
(5,  7, 4, 'Good fit, comfortable material.'),
(16, 2, 5, 'Great yoga mat, non-slip surface.');
GO


-- ============================================================
-- SECTION 5: VIEWS
-- ============================================================

-- View 1: Full Order Summary
CREATE OR ALTER VIEW vw_order_summary AS
SELECT
    o.order_id,
    c.first_name + ' ' + c.last_name   AS customer_name,
    c.email,
    c.city,
    o.order_date,
    o.status,
    o.total_amount,
    p.method        AS payment_method,
    p.status        AS payment_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN payments p ON o.order_id = p.order_id;
GO

-- View 2: Product Sales Summary
CREATE OR ALTER VIEW vw_product_sales AS
SELECT
    pr.product_id,
    pr.product_name,
    cat.category_name,
    pr.price,
    pr.stock_qty,
    ISNULL(SUM(oi.quantity), 0)                   AS total_units_sold,
    ISNULL(SUM(oi.quantity * oi.unit_price), 0)   AS total_revenue
FROM products pr
JOIN categories cat ON pr.category_id = cat.category_id
LEFT JOIN order_items oi ON pr.product_id = oi.product_id
GROUP BY pr.product_id, pr.product_name, cat.category_name, pr.price, pr.stock_qty;
GO

-- View 3: Customer Purchase History
CREATE OR ALTER VIEW vw_customer_history AS
SELECT
    c.customer_id,
    c.first_name + ' ' + c.last_name   AS customer_name,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ISNULL(SUM(o.total_amount), 0)      AS lifetime_value,
    MAX(o.order_date)                   AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;
GO


-- ============================================================
-- SECTION 6: STORED PROCEDURES
-- ============================================================

-- Procedure 1: Place a New Order
CREATE OR ALTER PROCEDURE sp_place_order
    @p_customer_id INT,
    @p_product_id  INT,
    @p_quantity    INT,
    @p_order_id    INT OUTPUT,
    @p_message     VARCHAR(200) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_price   DECIMAL(10,2);
    DECLARE @v_stock   INT;
    DECLARE @v_total   DECIMAL(10,2);

    -- Get product price and stock
    SELECT @v_price = price, @v_stock = stock_qty
    FROM products
    WHERE product_id = @p_product_id;

    IF @v_stock < @p_quantity
    BEGIN
        SET @p_message  = 'Insufficient stock available.';
        SET @p_order_id = -1;
    END
    ELSE
    BEGIN
        SET @v_total = @v_price * @p_quantity;

        -- Create order
        INSERT INTO orders (customer_id, status, total_amount)
        VALUES (@p_customer_id, 'Pending', @v_total);

        SET @p_order_id = SCOPE_IDENTITY();

        -- Add order item
        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (@p_order_id, @p_product_id, @p_quantity, @v_price);

        -- Deduct stock
        UPDATE products
        SET stock_qty = stock_qty - @p_quantity
        WHERE product_id = @p_product_id;

        SET @p_message = 'Order placed successfully. Order ID: ' + CAST(@p_order_id AS VARCHAR);
    END
END;
GO

-- Procedure 2: Monthly Sales Report
CREATE OR ALTER PROCEDURE sp_monthly_sales_report
    @p_year  INT,
    @p_month INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.product_name,
        cat.category_name,
        SUM(oi.quantity)                  AS units_sold,
        SUM(oi.quantity * oi.unit_price)  AS revenue
    FROM order_items oi
    JOIN orders     o   ON oi.order_id   = o.order_id
    JOIN products   p   ON oi.product_id = p.product_id
    JOIN categories cat ON p.category_id = cat.category_id
    WHERE YEAR(o.order_date)  = @p_year
      AND MONTH(o.order_date) = @p_month
      AND o.status != 'Cancelled'
    GROUP BY p.product_id, p.product_name, cat.category_name
    ORDER BY revenue DESC;
END;
GO


-- ============================================================
-- SECTION 7: TRIGGERS
-- ============================================================

-- Trigger 1: Auto-update order total when items are added
CREATE OR ALTER TRIGGER trg_update_order_total
ON order_items
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE orders
    SET total_amount = (
        SELECT SUM(quantity * unit_price)
        FROM order_items
        WHERE order_id = inserted.order_id
    )
    FROM orders
    JOIN inserted ON orders.order_id = inserted.order_id;
END;
GO

-- Trigger 2: Prevent deletion of delivered orders
CREATE OR ALTER TRIGGER trg_prevent_delete_delivered
ON orders
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM deleted WHERE status = 'Delivered')
    BEGIN
        RAISERROR('Cannot delete a delivered order.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    DELETE FROM orders WHERE order_id IN (SELECT order_id FROM deleted);
END;
GO


-- ============================================================
-- SECTION 8: BUSINESS QUERIES
-- ============================================================

-- Q1: Top 5 Best-Selling Products by Revenue
SELECT TOP 5
    product_name,
    category_name,
    total_units_sold,
    total_revenue
FROM vw_product_sales
ORDER BY total_revenue DESC;
GO


-- Q2: Monthly Revenue Trend
SELECT
    YEAR(o.order_date)                        AS [Year],
    DATENAME(MONTH, o.order_date)             AS [Month],
    COUNT(DISTINCT o.order_id)                AS total_orders,
    SUM(o.total_amount)                       AS monthly_revenue
FROM orders o
WHERE o.status != 'Cancelled'
GROUP BY YEAR(o.order_date), MONTH(o.order_date), DATENAME(MONTH, o.order_date)
ORDER BY YEAR(o.order_date), MONTH(o.order_date);
GO


-- Q3: Top 5 Customers by Lifetime Value
SELECT TOP 5
    customer_name,
    total_orders,
    lifetime_value,
    last_order_date
FROM vw_customer_history
ORDER BY lifetime_value DESC;
GO


-- Q4: Category-wise Revenue Share with Percentage
SELECT
    cat.category_name,
    COUNT(DISTINCT p.product_id)                                    AS total_products,
    SUM(oi.quantity * oi.unit_price)                                AS category_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price) * 100.0 /
        (SELECT SUM(quantity * unit_price) FROM order_items), 2
    )                                                               AS revenue_share_pct
FROM categories cat
JOIN products    p   ON cat.category_id = p.category_id
JOIN order_items oi  ON p.product_id   = oi.product_id
JOIN orders      o   ON oi.order_id    = o.order_id
WHERE o.status != 'Cancelled'
GROUP BY cat.category_id, cat.category_name
ORDER BY category_revenue DESC;
GO


-- Q5: Full Order Details with Payment Info
SELECT
    order_id,
    customer_name,
    order_date,
    status,
    total_amount,
    payment_method,
    payment_status
FROM vw_order_summary
ORDER BY order_date DESC;
GO


-- Q6: Customers Who Have NOT Placed Any Order
SELECT
    customer_id,
    first_name + ' ' + last_name AS customer_name,
    email,
    city
FROM customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);
GO


-- Q7: Products Low on Stock (less than 30 units)
SELECT
    product_id,
    product_name,
    category_name,
    stock_qty
FROM vw_product_sales
WHERE stock_qty < 30
ORDER BY stock_qty ASC;
GO


-- Q8: Average Rating per Product
SELECT
    p.product_name,
    cat.category_name,
    COUNT(r.review_id)           AS total_reviews,
    ROUND(AVG(CAST(r.rating AS FLOAT)), 2) AS avg_rating
FROM products p
JOIN categories cat ON p.category_id = cat.category_id
JOIN reviews r      ON p.product_id  = r.product_id
GROUP BY p.product_id, p.product_name, cat.category_name
HAVING COUNT(r.review_id) >= 1
ORDER BY avg_rating DESC;
GO


-- Q9: Revenue by Payment Method
SELECT
    method                          AS payment_method,
    COUNT(*)                        AS total_transactions,
    SUM(amount)                     AS total_collected
FROM payments
WHERE status = 'Completed'
GROUP BY method
ORDER BY total_collected DESC;
GO


-- Q10: Window Function – Customer Order Rank by Amount
SELECT
    customer_name,
    order_id,
    order_date,
    total_amount,
    RANK() OVER (PARTITION BY customer_name ORDER BY total_amount DESC) AS order_rank,
    SUM(total_amount) OVER (PARTITION BY customer_name)                 AS customer_total
FROM vw_order_summary
WHERE status != 'Cancelled';
GO


-- Q11: Running Total of Revenue Over Time
SELECT
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                               AS running_total
FROM vw_order_summary
WHERE status NOT IN ('Cancelled', 'Pending')
ORDER BY order_date;
GO


-- Q12: Month-over-Month Revenue Growth (CTE + LAG)
WITH monthly AS (
    SELECT
        FORMAT(order_date, 'yyyy-MM')   AS ym,
        SUM(total_amount)               AS revenue
    FROM orders
    WHERE status != 'Cancelled'
    GROUP BY FORMAT(order_date, 'yyyy-MM')
)
SELECT
    ym,
    revenue,
    LAG(revenue) OVER (ORDER BY ym)                                   AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY ym)) * 100.0 /
        NULLIF(LAG(revenue) OVER (ORDER BY ym), 0), 2
    )                                                                  AS growth_pct
FROM monthly
ORDER BY ym;
GO


-- Q13: Duplicate Email Detection (Data Quality Check)
SELECT email, COUNT(*) AS occurrences
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;
GO


-- Q14: Most Popular Product in Each Category (CTE + RANK)
WITH ranked AS (
    SELECT
        cat.category_name,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        RANK() OVER (
            PARTITION BY cat.category_id
            ORDER BY SUM(oi.quantity * oi.unit_price) DESC
        ) AS rnk
    FROM categories  cat
    JOIN products    p   ON cat.category_id = p.category_id
    JOIN order_items oi  ON p.product_id    = oi.product_id
    JOIN orders      o   ON oi.order_id     = o.order_id
    WHERE o.status != 'Cancelled'
    GROUP BY cat.category_id, cat.category_name, p.product_id, p.product_name
)
SELECT category_name, product_name, revenue
FROM ranked
WHERE rnk = 1;
GO


-- Q15: Customers Who Ordered More Than Once
SELECT
    customer_name,
    total_orders,
    lifetime_value
FROM vw_customer_history
WHERE total_orders > 1
ORDER BY total_orders DESC;
GO


-- ============================================================
-- HOW TO CALL THE STORED PROCEDURE (Example)
-- ============================================================
/*
DECLARE @oid INT, @msg VARCHAR(200);
EXEC sp_place_order
    @p_customer_id = 1,
    @p_product_id  = 5,
    @p_quantity    = 2,
    @p_order_id    = @oid OUTPUT,
    @p_message     = @msg OUTPUT;
SELECT @oid AS order_id, @msg AS message;

-- Monthly Report for January 2024
EXEC sp_monthly_sales_report @p_year = 2024, @p_month = 1;
*/


-- ============================================================
-- END OF PROJECT
-- ============================================================

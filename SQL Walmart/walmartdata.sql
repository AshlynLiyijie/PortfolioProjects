-- data import & attribute
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- feature engineer
-- time_of_day
SELECT `time`, 
	   (CASE 
			WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
            WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
            ELSE "Evening" END
	   ) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening" END
);

-- day_name
SELECT date,
	   DAYNAME(date)
FROM sales;

ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- month_name
SELECT date,
	   MONTHNAME(date)
FROM sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- Generic Question
-- How many unique cities does the data have?
SELECT DISTINCT city
FROM sales;

-- In which city is each branch?
SELECT DISTINCT city, branch
FROM sales;

-- Product
-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) AS count
FROM sales;

-- What is the most common payment method?
SELECT payment, COUNT(payment) AS count
FROM sales
GROUP BY payment
ORDER BY count DESC
LIMIT 1;

-- What is the most selling product line?
SELECT product_line, COUNT(product_line) AS count
FROM sales
GROUP BY product_line
ORDER BY count DESC
LIMIT 1;

-- What is the total revenue by month?
SELECT month_name AS month, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT month_name as month, SUM(cogs) AS COGS
FROM sales
GROUP BY month_name
ORDER BY COGS DESC
LIMIT 1;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC
LIMIT 1;

-- What city had the largest revenue?
SELECT city, branch, SUM(total) AS revenue
FROM sales
GROUP BY city, branch
ORDER BY revenue DESC
LIMIT 1;

-- What product line had the largest VAT/tax?
SELECT product_line, AVG(tax_pct) AS VAT
FROM sales
GROUP BY product_line
ORDER BY VAT DESC
LIMIT 1;

-- Which branch sold more products than average product sold?
SELECT B1.branch, B1.qty AS qty
FROM (SELECT S1.branch AS branch, SUM(S1.quantity) AS qty
	  FROM sales S1
	  GROUP BY S1.Branch) B1
WHERE B1.qty > (SELECT AVG(B2.qty)
			   FROM (SELECT S2.branch, SUM(S2.quantity) AS qty
					 FROM sales S2
					 GROUP BY S2.branch) B2
			  )
GROUP BY B1.branch;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales
SELECT S1.product_line, 
	   CASE
			WHEN S1.quantity > (SELECT AVG(S2.quantity) 
								FROM sales S2) THEN "Good"
            ELSE "BAD"
			END AS Remark
FROM sales S1;

-- What is the most common product line by gender?
SELECT gender, product_line, COUNT(*) AS frequency
FROM sales
GROUP BY gender, product_line
ORDER BY gender, COUNT(*) DESC;

-- What is the average rating of each product line?
SELECT product_line, AVG(rating) AS average_rating
FROM sales
GROUP BY product_line;

-- Customers
-- How many unique customer types does the data have?
SELECT COUNT(*) AS count
FROM (SELECT DISTINCT customer_type
	  FROM sales S1) S2;
      
-- How many unique payment methods does the data have?
SELECT COUNT(*) AS count
FROM (SELECT DISTINCT payment
	  FROM sales S1) S2;
      
-- What is the most common customer type?
SELECT customer_type, COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC
LIMIT 1;










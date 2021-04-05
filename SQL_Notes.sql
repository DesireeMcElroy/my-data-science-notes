



-- SQL Functions Notes

SELECT concat('Good morning ', 'Florence');
SELECT concat('Good morning',  ' Florence',  ' Hope you had a great weekend');


USE chipotle;
 SHOW TABLES;
 
 
SELECT * FROM orders;


SELECT CONCAT(item_name, ': ', choice_description) 
AS 'item_plus_choice_desc' FROM orders;


SELECT item_name
FROM orders
WHERE item_name LIKE '%b%';


-- SUBSTRINGS: SUBSTR

SELECT SUBSTR('When I see the sun always shines on TV', 12, 7);
SELECT SUBSTR('When I see the sun always shines on TV', 12);


SELECT substr(item_name, 10, 5)
AS 'garbo'
FROM orders;



-- REPLACE

SELECT REPLACE('This is a STRING', 'string', "not a string I am lying");

-- Replaces bowl with unburrito
SELECT REPLACE(item_name, 'Bowl', 'Unburrito')
FROM orders;


-- UPPER / LOWER
SELECT upper('yelling');
SELECT lower('whispeRRRR');


-- Returns all uppercase choice_description
SELECT upper(choice_description)
FROM orders;

-- Functions wrapped in functions
SELECT upper(
concat(item_name, ': ', choice_description))
AS 'column_name_custom'
FROM orders;



-- TIME FUNCTIONS

SELECT now();

SELECT curtime();

SELECT unix_timestamp();



-- MATH functions
SELECT *
FROM orders;

-- maximum/minimum
SELECT MAX(quantity)
FROM orders;

SELECT MIN(quantity)
FROM orders;

SELECT AVG(quantity)
FROM orders;

-- Casting

SELECT concat(1, 'ham sandwich');


SELECT 
	CAST(123 AS CHAR(2)),
	CAST('123' AS UNSIGNED);




-- SUBQUERIES notes **************************************

USE join_example_db;
SELECT *
FROM users;

SELECT * FROM roles;

-- show users that have the role of reviewer
SELECT *
FROM users
WHERE role_id IN(
	SELECT id
	FROM roles
	WHERE `name` = 'reviewer'
	);
	
	
	
USE chipotle;

SELECT *
FROM orders
LIMIT 5;


SELECT *
FROM orders
WHERE item_name IN(
	SELECT item_name
	FROM orders
	WHERE item_name LIKE '%bowl%');
	
-- same as 

SELECT *
FROM orders
WHERE item_name LIKE '%bowl%';



-- now let's use an aggregate
SELECT *
FROM orders


SELECT *
FROM orders
WHERE quantity = (
	SELECT MIN(quantity)
	FROM orders
	);
	
	
	
-- find the names of all current managers that are women

USE employees;

SELECT first_name, last_name
FROM employees
WHERE emp_no IN(
	SELECT emp_no
	FROM dept_manager
	WHERE to_date > NOW();
	)
AND gender LIKE '%f%';




-- TEMP TABLES *********************************************



USE test3;

CREATE TEMPORARY TABLE current_salary AS (
    SELECT employees.employees.first_name, 
    employees.employees.last_name, 
    employees.salaries.salary
    FROM employees.salaries
    JOIN employees.employees USING(emp_no)
    WHERE to_date > curdate()
);

-- If we do 5% raises for all current employees
-- what is the sum of those salaries

-- UPDATE my_numbers SET n = n + 1 (where clause, if needed)

UPDATE current_salary SET salary = salary + salary * .05;

USE test3;
SELECT sum(salary) FROM current_salary;

SELECT sum(salary) FROM employees.salaries WHERE to_date > curdate();

SELECT (SELECT sum(salary) FROM current_salary) - 
(SELECT sum(salary) FROM employees.salaries
WHERE to_date > curdate());

SELECT 3 + 2;


CREATE TEMPORARY TABLE fruits AS (
    SELECT *
    FROM fruits_db.fruits
);


UPDATE current_salary SET salary = 100;

SELECT *
FROM current_salary;


-- Table EXERCISES review

-- Exercise 1
-- Using the example from the lesson, create a temporary table called employees_with_departments 
-- Add a column named full_name to this table. It should be a VARCHAR whose length is the sum of the lengths of the first name and last name columns
-- Update the table so that full name column contains the correct data
-- Remove the first_name and last_name columns from the table.
-- What is another way you could have ended up with this same table?

-- step 1: create the query using the db_name.table_name syntax
SELECT first_name, last_name, dept_name
FROM employees.employees
JOIN employees.dept_emp USING(emp_no)
JOIN employees.departments USING(dept_no)
WHERE to_date > curdate();

-- use that query to make a temporary table
USE test3;
CREATE TEMPORARY TABLE employees_with_departments AS (
    SELECT first_name, last_name, dept_name
    FROM employees.employees
    JOIN employees.dept_emp USING(emp_no)
    JOIN employees.departments USING(dept_no)
    WHERE to_date > curdate()
);

-- step 3
ALTER TABLE employees_with_departments ADD full_name VARCHAR(30);

-- step 4
UPDATE employees_with_departments SET full_name = concat(first_name, ' ', last_name);

-- step 5
ALTER TABLE employees_with_departments DROP COLUMN first_name;
ALTER TABLE employees_with_departments DROP COLUMN last_name;

-- double check
SELECT * FROM employees_with_departments;

-- Another way to create the same result? Create the full_name in the original query





-- Exercise 2
-- Write the SQL necessary to transform the amount column such that it is stored as an integer representing the number of cents of the payment. For example, 1.99 should become 199.

USE test3;

-- clean up any old version of this table (only if it already exists)
DROP TABLE IF EXISTS payments;

CREATE TEMPORARY TABLE payments AS (
    SELECT payment_id, customer_id, staff_id, rental_id, amount * 100 AS amount_in_pennies, payment_date, last_update
    FROM sakila.payment
);

SELECT * FROM payments;
DESCRIBE payments;

ALTER TABLE payments MODIFY amount_in_pennies INT NOT NULL;

DESCRIBE payments;





-- Exercise 3
-- Find out how the current average pay in each department compares to the overall, historical average pay. 
-- In order to make the comparison easier, you should use the Z-score for salaries. 
-- In terms of salary, what is the best department right now to work for? The worst?

-- Historic average and standard deviation b/c the problem says "use historic average"
-- 63,810 historic average salary
-- 16,904 historic standard deviation

-- Obtain the average histortic salary and the historic standard deviation of salary
-- Write the numbers down:
-- 63,810 historic average salary
-- 16,904 historic standard deviation
SELECT AVG(salary) AS avg_salary, std(salary) AS std_salary
FROM employees.salaries ;

CREATE TEMPORARY TABLE current_info AS (
    SELECT dept_name, AVG(salary) AS department_current_average
    FROM employees.salaries
    JOIN employees.dept_emp USING(emp_no)
    JOIN employees.departments USING(dept_no)
    WHERE employees.dept_emp.to_date > curdate()
    AND employees.salaries.to_date > curdate()
    GROUP BY dept_name
);

-- Create columns to hold the average salary, std, and the zscore
ALTER TABLE current_info ADD average FLOAT(10,2);
ALTER TABLE current_info ADD standard_deviation FLOAT(10,2);
ALTER TABLE current_info ADD zscore FLOAT(10,2);

UPDATE current_info SET average = 63810;
UPDATE current_info SET standard_deviation = 16904;

-- z_score  = (avg(x) - x) / std(x) */
UPDATE current_info 
SET zscore = (department_current_average - historic_avg) / historic_std;

SELECT * FROM current_info
ORDER BY zscore DESC;




-- Exercise 3 in a more programmatic way
-- Historic average and standard deviation b/c the problem says "use historic average"
-- 63,810 historic average salary
-- 16,904 historic standard deviation
USE florence08;


CREATE TEMPORARY TABLE historic_aggregates AS (
    SELECT AVG(salary) AS avg_salary, std(salary) AS std_salary
    FROM employees.salaries 
);

CREATE TEMPORARY TABLE current_info AS (
    SELECT dept_name, AVG(salary) AS department_current_average
    FROM employees.salaries
    JOIN employees.dept_emp USING(emp_no)
    JOIN employees.departments USING(dept_no)
    WHERE employees.dept_emp.to_date > curdate()
    AND employees.salaries.to_date > curdate()
    GROUP BY dept_name
);

SELECT * FROM current_info;

ALTER TABLE current_info ADD historic_avg FLOAT(10,2);
ALTER TABLE current_info ADD historic_std FLOAT(10,2);
ALTER TABLE current_info ADD zscore FLOAT(10,2);

UPDATE current_info SET historic_avg = (SELECT avg_salary FROM historic_aggregates);
UPDATE current_info SET historic_std = (SELECT std_salary FROM historic_aggregates);

SELECT * FROM current_info;

UPDATE current_info 
SET zscore = (department_current_average - historic_avg) / historic_std;

SELECT * FROM current_info
ORDER BY zscore DESC; 



-- ***************
-- CASE STATEMENTS

-- If I'm only referencing one column and only testing for equality.

SELECT
    CASE COLUMN_NAME
        WHEN condition_a THEN value_1
        WHEN condition_b THEN value_2
        ELSE value_3
        END AS new_column_name
FROM TABLE_NAME;

/*
CASE statement syntax. This allows me to reference different columns in my logic as well as use all of the conditional operators available to me in a WHERE Clause.
*/
SELECT
    COLUMN_NAME,
    CASE
        WHEN COLUMN_NAME logic_1 THEN value1
        WHEN COLUMN_NAME logic_2 THEN value2
        WHEN COLUMN_NAME logic_3 THEN value3
        ELSE catch_all_value
        END AS new_column_name
FROM TABLE_NAME;


-- Choose the chipotle database
USE chipotle;

-- Check out my orders table.
SELECT *
FROM orders;

-- Use a `CASE` statement to create bins called item_type using item names.
SELECT 
    item_name,
    CASE
        WHEN item_name LIKE '%chicken%' THEN 'Chicken Item'
        WHEN item_name LIKE '%veggie%' THEN 'Veggie Item'
        WHEN item_name LIKE '%beef%' THEN 'Beef Item'
        WHEN item_name LIKE '%barbacoa%' 
            OR item_name LIKE '%carnitas%' 
            OR item_name LIKE '%steak%' THEN 'Specialty Item'       
        WHEN item_name LIKE '%chips%' THEN 'Side'
        ELSE 'Other'
        END AS item_type
FROM orders;


-- How many different items do I have for each item type bin or category?
SELECT 
    CASE
        WHEN item_name LIKE '%chicken%' THEN 'Chicken Item'
        WHEN item_name LIKE '%veggie%' THEN 'Veggie Item'
        WHEN item_name LIKE '%beef%' THEN 'Beef Item'
        WHEN item_name LIKE '%barbacoa%' 
            OR item_name LIKE '%carnitas%' 
            OR item_name LIKE '%steak%' THEN 'Specialty Item'       
        WHEN item_name LIKE '%chips%' THEN 'Side'
        ELSE 'Other'
        END AS item_type,
    COUNT(*) count_of_records
FROM orders
GROUP BY item_type
ORDER BY count_of_records DESC;


-- Filter my return set to Specialty Items item types only and see which item in this category is most popular.
SELECT 
    item_name,
    CASE
        WHEN item_name LIKE '%chicken%' THEN 'Chicken Item'
        WHEN item_name LIKE '%veggie%' THEN 'Veggie Item'
        WHEN item_name LIKE '%beef%' THEN 'Beef Item'
        WHEN item_name LIKE '%barbacoa%' 
            OR item_name LIKE '%carnitas%' 
            OR item_name LIKE '%steak%' THEN 'Specialty Item'
        WHEN item_name LIKE '%chips%' THEN 'Side'
        ELSE 'Other'
        END AS item_type,
    COUNT(*) AS count_of_records
FROM orders
GROUP BY item_type, item_name
HAVING item_type = 'Specialty Item'
ORDER BY count_of_records DESC;



-- bucket data

-- Create buckets for quantity to create a new categorical variable.
SELECT
    item_name,
    CASE
        WHEN quantity = 1 THEN 'single_item'
        WHEN quantity BETWEEN 2 AND 5 THEN 'family_and_friends'
        WHEN quantity BETWEEN 6 AND 9 THEN 'small_gathering'
        WHEN quantity > 9 THEN 'party'
        ELSE 'other'
        END AS quant_cats
FROM orders;


-- Add a GROUP BY Clause to Zoom Out and take a look at my new categorical variables quant_cats
SELECT
    COUNT(*) AS count_of_records,
    CASE
        WHEN quantity = 1 THEN 'single_item'
        WHEN quantity BETWEEN 2 AND 5 THEN 'family_and_friends'
        WHEN quantity BETWEEN 6 AND 9 THEN 'small_gathering'
        WHEN quantity > 9 THEN 'party'
        ELSE 'other'
        END AS quant_cats
FROM orders
GROUP BY quant_cats
ORDER BY count_of_records DESC;



-- Reference Multiple Columns

-- Use mall_customers database.
USE mall_customers;

-- Check out the customers table.
SELECT *
FROM customers;



-- Reference more than one column in CASE Statement logic.
SELECT
    gender,
    age,
    CASE
        WHEN gender = 'Male' AND age < 20 THEN 'Teen Male'
        WHEN gender = 'Male' AND age < 30 THEN 'Twenties Male'
        WHEN gender = 'Male' AND age < 40 THEN 'Thirties Male'
        WHEN gender = 'Male' AND age < 50 THEN 'Forties Male'
        WHEN gender = 'Male' AND age < 60 THEN 'Fifties Male'
        WHEN gender = 'Male' AND age < 70 THEN 'Sixties Male'
        WHEN gender = 'Male' AND age >= 70 THEN 'Older Male'
        WHEN gender = 'Female' AND age < 20 THEN 'Teen Female'
        WHEN gender = 'Female' AND age < 30 THEN 'Twenties Female'
        WHEN gender = 'Female' AND age < 40 THEN 'Thirties Female'
        WHEN gender = 'Female' AND age < 50 THEN 'Forties Female'
        WHEN gender = 'Female' AND age < 60 THEN 'Fifties Female'
        WHEN gender = 'Female' AND age < 70 THEN 'Sixties Female'
        WHEN gender = 'Female' AND age >= 70 THEN 'Older Female'
        ELSE 'Other'
        END AS gen_age_cat
FROM customers;



-- Zoom Out by adding a Group By Clause and a COUNT() function.
SELECT
    CASE
        WHEN gender = 'Male' AND age < 20 THEN 'Teen Male'
        WHEN gender = 'Male' AND age < 30 THEN 'Twenties Male'
        WHEN gender = 'Male' AND age < 40 THEN 'Thirties Male'
        WHEN gender = 'Male' AND age < 50 THEN 'Forties Male'
        WHEN gender = 'Male' AND age < 60 THEN 'Fifties Male'
        WHEN gender = 'Male' AND age < 70 THEN 'Sixties Male'
        WHEN gender = 'Male' AND age >= 70 THEN 'Older Male'
        WHEN gender = 'Female' AND age < 20 THEN 'Teen Female'
        WHEN gender = 'Female' AND age < 30 THEN 'Twenties Female'
        WHEN gender = 'Female' AND age < 40 THEN 'Thirties Female'
        WHEN gender = 'Female' AND age < 50 THEN 'Forties Female'
        WHEN gender = 'Female' AND age < 60 THEN 'Fifties Female'
        WHEN gender = 'Female' AND age < 70 THEN 'Sixties Female'
        WHEN gender = 'Female' AND age >= 70 THEN 'Older Female'
        ELSE 'Other'
        END AS gen_age_cat,
    COUNT(*) AS count_of_customers
FROM customers
GROUP BY gen_age_cat
ORDER BY count_of_customers DESC;


-- Use the mall_customers database.
USE mall_customers;

-- Check out the customers table.
SELECT *
FROM customers;

-- Use an IF Function to create a dummy variable for gender.
SELECT
    gender,
    IF(gender = 'Female', TRUE, FALSE) AS is_female
FROM customers;

-- Or another method is 


SELECT
    gender,
    IF(gender = 'Female', 'F', 'M') AS is_female
FROM customers;

-- I can create this new boolean column in another simple way, just evaluate the equality statement to True of False

SELECT
	gender,
	gender = 'Female' AS is_female
	FROM customers;
	
	

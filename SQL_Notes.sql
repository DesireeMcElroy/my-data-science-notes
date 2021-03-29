



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






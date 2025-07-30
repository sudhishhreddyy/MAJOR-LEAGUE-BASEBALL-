USE maven_advanced_sql;

SELECT country, population, LOG(population) AS log_pop,
ROUND(LOG(population),2) AS log_pop2 FROM country_stats;

SELECT * FROM country_stats;

WITH pm AS (SELECT country, population, FLOOR(population/1000000) AS pop_mil FROM country_stats)
SELECT pop_mil, COUNT(country) FROM pm
GROUP BY pop_mil
ORDER BY pop_mil;

SELECT customer_id, product_id, units FROM orders;
SELECT product_id, unit_price FROM products;

-- ASSIGNMENT NUMERIC FUNCTIONS 
WITH abc AS (SELECT o.customer_id, SUM(o.units * p.unit_price) AS spend,
FLOOR(SUM(o.units * p.unit_price)/10)*10 AS total_spend_bin FROM orders o
LEFT JOIN products p ON p.product_id = o.product_id
GROUP BY o.customer_id)

SELECT total_spend_bin, COUNT(customer_id) AS bcd FROM abc
GROUP BY total_spend_bin
ORDER BY total_spend_bin;

-- ASSIGNMENT DATETIME FUNCTIONS
SELECT order_id, order_date, DATE_ADD(order_date, INTERVAL 2 DAY) AS ship_date FROM orders
WHERE YEAR(order_date)= 2024 AND MONTH(order_date) BETWEEN 4 AND 6;


-- STRING ASSIGNMENT 
WITH abc AS (SELECT factory, product_id,
REPLACE(REPLACE(factory, "'","")," ","-") AS factory_name1
FROM products
ORDER BY product_id, factory)
SELECT factory, product_id, 
CONCAT(factory_name1,"-", product_id) AS data_clean
FROM abc;

-- PATTERN MATCHING 
SELECT product_name,
	REPLACE(product_name, "Wonka Bar - ","") AS new_product_name
FROM products
ORDER BY product_name;
-- OR
SELECT product_name,
	CASE WHEN INSTR(product_name, "-") = 0 THEN product_name
	ELSE SUBSTR(product_name,INSTR(product_name, "-")+2) END AS new_product_name
FROM products
ORDER BY product_name;

-- NULL FUNCTIONS 
SELECT product_name, factory, division,
	COALESCE(division, 'Other') AS new_division
FROM products
ORDER BY factory, division;

WITH np AS(SELECT factory, division, COUNT(product_name) AS num_products
			FROM products
			WHERE division IS NOT NULL
			GROUP BY division, factory
			ORDER BY division, factory),
	np_rank AS (SELECT factory, division, num_products,
				ROW_NUMBER() OVER(PARTITION BY factory ORDER BY num_products DESC) AS num_products_rank FROM np),
	top_div AS (SELECT factory, division FROM np_rank
				WHERE num_products_rank = 1)
                
SELECT p.product_name, p.factory, p.division,
	COALESCE(p.division, 'Other') AS new_division,
    COALESCE(p.division, td.division) AS division_top
    FROM products p
    LEFT JOIN top_div td ON p.factory = td.factory
    ORDER BY p.factory, p.division;

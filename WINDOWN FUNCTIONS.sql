USE maven_advanced_sql;

SELECT year, country, happiness_score, ROW_NUMBER() OVER(PARTITION BY country ORDER BY happiness_score DESC) AS row_num
FROM happiness_scores
ORDER BY country, row_num;

-- ASSIGNMENT WINDOW FUNCTION
SELECT * FROM ORDERS;

SELECT customer_id, order_id, order_date, transaction_id, 
ROW_NUMBER() OVER(PARTITION BY customer_id) AS transaction_number FROM orders
ORDER BY customer_id, order_date;


-- ASSIGNMENT 2 ROW NUMBERING
SELECT order_id, product_id, units,
DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units) AS product_rank
FROM orders
WHERE order_id LIKE '%44262'
ORDER BY order_id, product_rank;

-- CREATING A NEW TABLE 
CREATE TABLE baby_names (
gender VARCHAR (10),
name VARCHAR (50),
babies INT);

INSERT INTO baby_names (gender, name, babies) VALUES
('Female','Charlotte',80),
('Female','Emma', 82),
('Female','Olivia',99),
('Male', 'James', 85), 
('Male', 'Liam', 110), 
('Male', 'Noah', 95);

-- TESTING THE VALUE FUNCTION IN WINDOW 
SELECT * FROM
(SELECT gender, name, babies, FIRST_VALUE(name) OVER(PARTITION BY gender ORDER BY babies DESC) AS top_name 
FROM baby_names) AS top_name
WHERE name = top_name;

-- ASSIGNMENT 
SELECT * FROM
(SELECT order_id, product_id, units, 
NTH_VALUE(product_id,2) OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank FROM orders
ORDER BY order_id, product_rank) AS second_product
WHERE product_id = product_rank;

SELECT * FROM
(SELECT order_id, product_id, units, 
DENSE_RANK() OVER(PARTITION BY order_id ORDER BY units DESC) AS product_rank
FROM orders) AS pr
WHERE product_rank = 2;

-- LEAD AND LAG FUNCTIONS 
SELECT * FROM happiness_scores;

SELECT year, country, happiness_score,
LAG(happiness_score) OVER(PARTITION BY country ORDER BY happiness_score) AS prior_hs_score 
FROM happiness_scores;
-- CONVERTING THIS INTO A CTE 
WITH prio_score AS (SELECT year, country, happiness_score,
LAG(happiness_score) OVER(PARTITION BY country ORDER BY happiness_score) AS prior_hs_score 
FROM happiness_scores)

SELECT country, year, happiness_score, prior_hs_score, happiness_score - prior_hs_score AS diff_happiness_score 
FROM prio_score;

-- ASSIGNMENT LEAD AND LAG FUNCTIONS 
SELECT * FROM orders;

SELECT customer_id, order_id, MIN(transaction_id) AS min_tid, SUM(units) AS total_units FROM orders
GROUP BY customer_id, order_id
ORDER BY customer_id, min_tid;
-- Converting this into a CTE

WITH abc AS (SELECT customer_id, order_id, MIN(transaction_id) AS min_tid, SUM(units) AS total_units FROM orders
			GROUP BY customer_id, order_id
			ORDER BY customer_id, min_tid)
SELECT customer_id, order_id, total_units,
		LAG(total_units)OVER(PARTITION BY customer_id ORDER BY min_tid) AS prior_units,
        total_units - LAG(total_units)OVER(PARTITION BY customer_id ORDER BY min_tid) AS Diff
FROM abc;
-- Now here what we did is we copied the complete Window function to calculate the diff, instead we will create another CTE

WITH abc AS (SELECT customer_id, order_id, MIN(transaction_id) AS min_tid, SUM(units) AS total_units FROM orders
			GROUP BY customer_id, order_id
			ORDER BY customer_id, min_tid),
	 bcd AS	(SELECT customer_id, order_id, total_units,
					LAG(total_units)OVER(PARTITION BY customer_id ORDER BY min_tid) AS prior_units
			FROM abc)
SELECT customer_id, order_id, total_units, prior_units, 
total_units - prior_units AS diff_units FROM bcd;
            

 





USE maven_advanced_sql;
-- 1.
WITH country_hs AS (SELECT country, AVG(happiness_score)AS avg_hs_by_country FROM happiness_scores
GROUP BY country)
SELECT hs.year, hs.country, hs.happiness_score, country_hs.avg_hs_by_country FROM happiness_scores hs
LEFT JOIN country_hs ON hs.country = country_hs.country;

-- 2. 
WITH hs AS (SELECT * FROM happiness_scores WHERE year = 2023)
SELECT hs1.region, hs1.country, hs1.happiness_score, hs2.country, hs2.happiness_score FROM  hs hs1 
LEFT JOIN hs hs2 ON hs1.region = hs2.region
WHERE hs1.happiness_score > hs2.happiness_score;

-- ASSIGNMENT CTE
SELECT * FROM ORDERS;
SELECT * FROM products;

SELECT o.order_id, SUM(o.units * p.unit_price) AS total_amount_spent FROM orders o
LEFT JOIN products p ON p.product_id = o.product_id
GROUP BY o.order_id
HAVING total_amount_spent > 200
ORDER BY total_amount_spent DESC;

-- NO OF ORDERS ABOVE 200
WITH ts AS (SELECT o.order_id, SUM(o.units * p.unit_price) AS total_amount_spent FROM orders o
LEFT JOIN products p ON p.product_id = o.product_id
GROUP BY o.order_id
HAVING total_amount_spent > 200
ORDER BY total_amount_spent DESC)
SELECT COUNT(*) AS no_of_orders FROM ts;

-- MULTIPLE CTE ASSIGNMENT 
WITH fp AS (SELECT factory, product_name FROM products),
	 fn AS (SELECT factory, count(product_id) AS num_products FROM products
			GROUP BY factory)
SELECT fp.factory, fp.product_name, fn.num_products FROM fp 
LEFT JOIN fn ON fp.factory = fn.factory
ORDER BY fp.factory;



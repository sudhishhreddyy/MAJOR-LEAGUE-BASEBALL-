SELECT * FROM happiness_scores;

SELECT AVG(happiness_score) FROM happiness_scores;

SELECT 
    year,
    country,
    happiness_score,
    (SELECT 
            AVG(happiness_score)
        FROM
            happiness_scores) AS avg_hs,
    happiness_score - (SELECT 
            AVG(happiness_score)
        FROM
            happiness_scores) AS diff_hs
FROM
    happiness_scores;
    
SELECT 
    product_id,
    product_name,
    unit_price,
    (SELECT 
            AVG(unit_price)
        FROM
            products) AS avg_unit_price,
    unit_price - (SELECT 
            AVG(unit_price)
        FROM
            products) AS diff_price
FROM
    products
ORDER BY diff_price DESC;

-- JUST PRACTICE
SELECT 
    hs.year,
    hs.country,
    hs.happiness_score,
    chs.avg_hs_by_country
FROM
    happiness_scores hs
        LEFT JOIN
    (SELECT 
        country, AVG(happiness_score) AS avg_hs_by_country
    FROM
        happiness_scores
    GROUP BY country) AS chs ON hs.country = chs.country
WHERE hs.country = 'United States';

-- MULTIPLE SUBQUERIES
-- 1. Return country happiness_score for evrey year
SELECT year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT 2024 ,country, ladder_score FROM happiness_scores_current;

-- 2. Return happiness_score as well as avearage happiness_score
SELECT hs.year, hs.country, hs.happiness_score, chs.avg_hs_by_country FROM (SELECT year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT 2024 ,country, ladder_score FROM happiness_scores_current) AS hs
LEFT JOIN (SELECT country, AVG(happiness_score) AS avg_hs_by_country FROM happiness_scores GROUP BY country) AS chs
ON hs.country = chs.country;


SELECT * FROM
(SELECT hs.year, hs.country, hs.happiness_score, chs.avg_hs_by_country FROM (SELECT year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT 2024 ,country, ladder_score FROM happiness_scores_current) AS hs
LEFT JOIN (SELECT country, AVG(happiness_score) AS avg_hs_by_country FROM happiness_scores GROUP BY country) AS chs
ON hs.country = chs.country) AS chls
WHERE happiness_score >= avg_hs_by_country + 1;

SELECT hs.year, hs.country, hs.happiness_score, chs.avg_hs_by_country FROM (SELECT year, country, happiness_score FROM happiness_scores
UNION ALL
SELECT 2024 ,country, ladder_score FROM happiness_scores_current) AS hs
LEFT JOIN (SELECT country, AVG(happiness_score) AS avg_hs_by_country FROM happiness_scores GROUP BY country) AS chs
ON hs.country = chs.country
WHERE hs.happiness_score >= chs.avg_hs_by_country + 1;

-- ASSIGNMENT MULTIPLE SUBQUERIES
SELECT factory, product_name FROM products;

SELECT factory, COUNT(product_id) AS num_products FROM products 
GROUP BY factory;


SELECT fp.factory, fp.product_name, fn.num_products FROM
(SELECT factory, product_name FROM products) AS fp
LEFT JOIN 
(SELECT factory, COUNT(product_id) AS num_products FROM products 
GROUP BY factory) AS fn
ON fp.factory = fn.factory
ORDER BY fp.factory, fp.product_name;

-- SUBQUERIES IN THE WHERE AND HAVING CLAUSE 
-- IN THE HAVING CLAUSE
SELECT region, AVG(happiness_score) AS avg_hs FROM happiness_scores
GROUP BY region
HAVING avg_hs > (SELECT AVG(happiness_score) AS avg_hs FROM happiness_scores);

-- IN THE WHERE CLAUSE 
SELECT * FROM happiness_scores
WHERE happiness_score > (SELECT AVG(happiness_score) AS avg_hs FROM happiness_scores);

SELECT * FROM happiness_scores h
WHERE EXISTS ( SELECT i.country_name FROM inflation_rates i 
WHERE i.country_name = h.country);

SELECT * FROM happiness_scores h
INNER JOIN inflation_rates i ON h.country = i.country_name AND h.year = i.year;

-- ASSIGNMENT SUBQUERIES IN THE WHERE CLAUSE 
SELECT * FROM products 
WHERE unit_price < ALL(SELECT unit_price FROM products 
WHERE factory = "Wicked Choccy's");




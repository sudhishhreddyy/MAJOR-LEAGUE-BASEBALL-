
USE maven_advanced_sql;
-- Create the table
CREATE TABLE employee_details (
    region VARCHAR(50),
    employee_name VARCHAR(50),
    salary INTEGER
);

-- Insert data into the table
INSERT INTO employee_details (region, employee_name, salary) VALUES
('East', 'Ava', 85000),
('East', 'Ava', 85000),
('East', 'Bob', 72000),
('East', 'Cat', 59000),
('West', 'Cat', 63000),
('West', 'Dan', 85000),
('West', 'Eve', 72000),
('West', 'Eve', 75000);

-- View the employee_details table
SELECT * FROM employee_details;

-- View Duplicate Values
SELECT region, employee_name, COUNT(*) AS dup_count FROM employee_details
GROUP BY employee_name,region
HAVING count(*) > 1;

-- Fully duplicate rows
SELECT salary, region, employee_name, COUNT(*) AS dup_count FROM employee_details
GROUP BY employee_name,region, salary
HAVING count(*) > 1;

-- Exclude Duplicate rows (Fully duplicate)
SELECT DISTINCT salary, region, employee_name FROM employee_details;

-- Exclude Partially duplicate (USE WINDOW FUNCTIONS)
SELECT * FROM (SELECT salary, region, employee_name,
	   ROW_NUMBER() OVER(PARTITION BY employee_name ORDER BY salary DESC) AS top_sal
FROM employee_details) AS abc
WHERE top_sal = 1;

-- Exclude Partially duplicate unique region and employee_name
SELECT * FROM (SELECT salary, region, employee_name,
	   ROW_NUMBER() OVER(PARTITION BY region, employee_name ORDER BY salary DESC) AS top_sal
FROM employee_details) AS abc
WHERE top_sal = 1;

-- ASSIGNMENT DATA ANALYSIS 1 (Cleaning student data)
WITH abc AS (SELECT id, student_name, email,
	   ROW_NUMBER() OVER(PARTITION BY student_name ORDER BY id DESC) AS student_count
FROM students)
SELECT * FROM abc 
WHERE student_count = 1;

-- Create the table (MIN MAX VALUE FILTERING)
CREATE TABLE sales (
    id INT PRIMARY KEY,
    sales_rep VARCHAR(50),
    date DATE,
    sales INT
);
INSERT INTO sales (id, sales_rep, date, sales) VALUES
(1, 'Emma', '2024-08-01', 6),
(2, 'Emma', '2024-08-02', 17),
(3, 'Jack', '2024-08-02', 14),
(4, 'Emma', '2024-08-04', 20),
(5, 'Jack', '2024-08-05', 5),
(6, 'Emma', '2024-08-07', 1);

SELECT * FROM sales;

WITH ms AS (SELECT sales_rep, MAX(date) AS Most_recent_date FROM sales
GROUP BY sales_rep)

SELECT s.sales_rep, s.date, s.sales FROM ms
LEFT JOIN sales s ON ms.sales_rep = s.sales_rep
AND ms.Most_recent_date  = s.date;

-- MIN/MAX VALUE FILTERING
SELECT * FROM students;
SELECT * FROM student_grades;

WITH dscf AS (SELECT s.id, s.student_name, gs.final_grade, gs.class_name,
	   DENSE_RANK() OVER(PARTITION BY s.student_name ORDER BY gs.final_grade DESC) AS top FROM students s
INNER JOIN student_grades gs ON s.id = gs.student_id)

SELECT * FROM dscf
WHERE top = 1;

-- ASSIGNENT PIVOTING 
SELECT * FROM student_grades;
SELECT * FROM students;

SELECT sg.department,
	   ROUND(AVG(CASE WHEN s.grade_level = 9 THEN sg.final_grade END)) AS freshamn,
	   ROUND(AVG(CASE WHEN s.grade_level = 10 THEN sg.final_grade END)) AS sophomore,
	   ROUND(AVG(CASE WHEN s.grade_level = 11 THEN sg.final_grade END)) AS junior,
       ROUND(AVG(CASE WHEN s.grade_level = 12 THEN sg.final_grade END)) AS Senior
FROM students s
LEFT JOIN student_grades sg ON s.id = sg.student_id
WHERE department IS NOT NULL
GROUP BY department;

-- MOVING AVERAGE 
SELECT * FROM happiness_scores;

SELECT country, year, ROUND(happiness_score,2),
ROUND(AVG(happiness_score) OVER(PARTITION BY country ORDER BY year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS abc
FROM happiness_scores;

-- ASSIGNMENT ROLLING CALCULATIONS
WITH ts AS (SELECT YEAR(o.order_date) AS yr, MONTH(o.order_date) AS mnth, SUM(o.units * p.unit_price) AS total_sales FROM orders o
LEFT JOIN products p ON o.product_id = p.product_id
GROUP BY YEAR(o.order_date), MONTH(O.order_date)
ORDER BY YEAR(o.order_date), MONTH(O.order_date))

SELECT *,
	ROW_NUMBER() OVER(ORDER BY yr, mnth) AS rn,
    SUM(total_sales) OVER(ORDER BY yr, mnth) AS cumm_sales,
    AVG(total_sales) OVER(ORDER BY yr, mnth ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS avg_sales
FROM ts;








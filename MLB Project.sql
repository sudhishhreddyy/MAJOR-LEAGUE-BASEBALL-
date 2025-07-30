USE data_1;

SELECT * FROM players;
SELECT * FROM school_details;
SELECT * FROM schools;

-- TASK 1 : In each decade how many schools have produced players?
SELECT ROUND(yearID,-1) AS Decade, COUNT(DISTINCT schoolID) AS Num_schools FROM schools
GROUP BY Decade;

-- TASK 2 : What are the names of the top 5 schools that produced the most players?
SELECT sd.name_full, COUNT(DISTINCT s.playerID) AS player_count
FROM schools s
LEFT JOIN school_details sd ON s.schoolID = sd.schoolID
GROUP BY s.schoolID
ORDER BY player_count DESC LIMIT  5;

-- TASK 3 : For each decade, what are the names of the top three schools that produced the most players?
WITH a AS (SELECT ROUND(s.yearID,-1) AS decade, sd.name_full, 
		   COUNT(DISTINCT s.playerID) AS player_count
		   FROM schools s
		   LEFT JOIN school_details sd ON s.schoolID = sd.schoolID
		   GROUP BY decade, s.schoolID),

     b AS  (SELECT *, 
			ROW_NUMBER() OVER(PARTITION BY decade ORDER BY player_count DESC) AS row_num FROM a)

SELECT decade, name_full, player_count FROM b
WHERE row_num <= 3
ORDER BY decade DESC, row_num;

-- TASK 4 : Return the top 20% of teams in terms of average annual spending.
WITH a AS (SELECT teamID, yearID, SUM(salary) AS total_spend FROM salaries
GROUP BY teamID, yearID
ORDER BY teamID, yearID),

	b AS  (SELECT teamID, AVG(total_spend) AS avg_spend,
		NTILE(5) OVER(ORDER BY AVG(total_spend) DESC) AS spend_pct
		FROM a
		GROUP BY teamID)
        
SELECT teamID, ROUND(avg_spend / 1000000) AS avg_spend_millions FROM b
WHERE spend_pct = 1;


-- TASK 5 : For each team show the cumilative sum of spending over the years.
WITH a AS (SELECT teamID, yearID, SUM(salary) AS total_sum FROM salaries
GROUP BY teamID, yearID
ORDER BY teamID, yearID)

SELECT teamID, yearID,
ROUND(SUM(total_sum) OVER(PARTITION BY teamID ORDER BY yearID)/ 1000000,1) AS total_spend FROM a;

-- TASK 6 : Return the first year that each teams cumulative spending surpassed 1 billion.
WITH a AS (
    SELECT teamID, yearID, SUM(salary) AS total_sum
    FROM salaries
    GROUP BY teamID, yearID
),
b AS (
    SELECT teamID, yearID,
           SUM(total_sum) OVER(PARTITION BY teamID ORDER BY yearID) AS total_spend
    FROM a
),
c AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY teamID ORDER BY total_spend) AS rn
    FROM b
    WHERE total_spend > 1000000000
)
SELECT teamID, yearID, ROUND(total_spend / 1000000000.0, 2) AS spend_billions
FROM c
WHERE rn = 1;

-- TASK 7 : For each player, calculate thier average age their first (Debut) game, their last game, 
-- and their career length
SELECT * FROM players;
SELECT count(*) from players;

SELECT nameGiven, debut, finalGame,
	   CAST(CONCAT(birthYear,'-',birthMonth,'-', birthDay) AS DATE) AS birthDate,
       TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear,'-',birthMonth,'-', birthDay) AS DATE), debut) AS starting_age,
	   TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear,'-',birthMonth,'-', birthDay) AS DATE), finalGame) AS ending_age,
       TIMESTAMPDIFF(YEAR, debut, finalGame) AS career_length
FROM players;

-- TASK 8 : What team did each player play for in thier starting and ending years?
SELECT 
    p.nameGiven, 
    s.yearID AS debutYear, 
    s.teamID AS debutTeam, 
    e.yearID AS finalYear, 
    e.teamID AS finalTeam
FROM players p 
INNER JOIN salaries s 
    ON s.playerID = p.playerID AND YEAR(p.debut) = s.yearID
INNER JOIN salaries e 
    ON e.playerID = p.playerID AND YEAR(p.finalGame) = e.yearID;
    
-- TASK 9 : How many players started and ended in the same team and played for over a decade?
SELECT 
    p.nameGiven, 
    s.yearID AS debutYear, 
    s.teamID AS debutTeam, 
    e.yearID AS finalYear, 
    e.teamID AS finalTeam
FROM players p 
INNER JOIN salaries s 
    ON s.playerID = p.playerID AND YEAR(p.debut) = s.yearID
INNER JOIN salaries e 
    ON e.playerID = p.playerID AND YEAR(p.finalGame) = e.yearID
WHERE s.teamID = e.teamID AND e.yearID - s.yearID >= 10;

-- TASK 10 : 
WITH a AS (SELECT nameGiven,
		   CAST(CONCAT(birthYear,'-', birthMonth,'-', birthDay) AS DATE) AS birthDate FROM players)
SELECT birthDate, GROUP_CONCAT(nameGiven SEPARATOR ', ') FROM a
WHERE YEAR(birthDate) BETWEEN 1980 AND 1990
GROUP BY birthDate
ORDER BY birthDate;

-- TASK 11 : Create a summary table to show for each team, what percent bat with right arm, left arm, etc.
SELECT s.teamID, COUNT(s.playerID) AS num_player, 
		ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END)/COUNT(s.playerID) * 100,1) AS right_bat,
        ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END)/COUNT(s.playerID) * 100,1) AS left_bat,
        ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END)/COUNT(s.playerID) * 100,1) AS both_bat
FROM salaries s
LEFT JOIN players p ON s.playerID = p.playerID
GROUP BY s.teamID;

-- TASK 12 : How have average height and weight at the debut game changed over the years, what's the decade over decade diff?
WITH a AS (SELECT ROUND(YEAR(debut),-1) AS decade, AVG(height) AS avg_height, AVG(weight) AS avg_weight FROM players
GROUP BY decade
ORDER BY decade)

SELECT decade,
		avg_height - LAG(avg_height)OVER(ORDER BY decade) AS height_prior,
        avg_weight - LAG(avg_weight)OVER(ORDER BY decade) AS weight_prior
FROM a
WHERE decade IS NOT NULL;






            
            

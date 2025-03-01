-- 1. How many unique post types are found in the 'fact_content' table?

SELECT DISTINCT post_type AS unique_post_types FROM fact_content

-- 2. What are the highest and lowest recorded impressions for each post type?

SELECT post_type, 
		MAX(impressions) AS max_impression, 
        MIN(impressions) AS Min_impression 
FROM fact_content
GROUP BY post_type

-- 3. Filter all the posts that were published on a weekend in the month of March and April and export them to a separate csv file.

SELECT c.*
FROM fact_content c
JOIN dim_dates d
ON d.date = c.date
WHERE weekday_or_weekend = 'Weekend' AND
	month_name IN ('March','April')
    
-- 4. Create a report to get the statistics for the account. The final output includes the following fields:
 -- month_name
 -- total_profile_visits
 -- total_new_followers
 
 SELECT month_name,
		SUM(profile_visits) AS total_profile_visits,
        SUM(new_followers) AS total_new_followers
 FROM dim_dates d
 JOIN fact_account a
 ON d.date = a.date
 GROUP BY month_name
 
-- 5. Write a CTE that calculates the total number of 'likes’ for each 'post_category' 
-- during the month of 'July' and subsequently, arrange the 'post_category' values in descending order according to their total likes.

WITH cte1 AS(
	SELECT post_category, SUM(likes) as total_likes FROM fact_content c
	JOIN dim_dates d
	ON d.date = c.date
	WHERE month_name = 'July'
	GROUP BY post_category 
)
SELECT * FROM cte1
ORDER BY post_category DESC

-- 6. Create a report that displays the unique post_category names alongside their respective counts for each month. 
-- The output should have three columns: month_name, post_category_names, post_category_count
-- Example: 'April', 'Earphone,Laptop,Mobile,Other Gadgets,Smartwatch', '5'
-- 'February', 'Earphone,Laptop,Mobile,Smartwatch', '4'

SELECT d.month_name, 
		GROUP_CONCAT(DISTINCT post_category SEPARATOR ', ') AS post_category_names,
        COUNT(DISTINCT post_category) AS post_category_count
FROM fact_content c
JOIN dim_dates d
ON d.date = c.date
GROUP BY d.month_name

-- 7. What is the percentage breakdown of total reach by post type? The final output includes the following fields:
-- post_type, total_reach, reach_percentage

SELECT post_type,
		SUM(reach) AS total_reach,
		CONCAT(ROUND(SUM(reach)/ (SELECT SUM(reach) FROM fact_content)*100,2),"%") AS reach_pct
FROM fact_content
GROUP BY post_type


-- 8. Create a report that includes the quarter, total comments, and total saves recorded for each post category. 
-- Assign the following quarter groupings: - (January, February, March) → “Q1”, (April, May, June) → “Q2”, (July, August, September) → “Q3”
-- The final output columns should consist of: post_category, quarter, total_comments, total_saves

SELECT post_category,
	CASE
		WHEN d.month_name IN ("January", "February", "March") THEN "Q1"
        WHEN d.month_name IN ("April", "May", "June") THEN "Q2"
        WHEN d.month_name IN ("July", "August", "September") THEN "Q3"
	END AS quarters,
        SUM(comments) AS total_comments,
        SUM(saves) AS total_saves
FROM fact_content c
JOIN dim_dates d
ON c.date = d.date
GROUP BY post_category,quarters

-- 9. List the top three dates in each month with the highest number of new followers. The final output should include the following columns:
-- month, date, new_followers

WITH highest_followers AS(
	SELECT MONTHNAME(date) AS month,
			date,
			new_followers,
			ROW_NUMBER() OVER(PARTITION BY MONTHNAME(date) ORDER BY new_followers DESC) AS ranks  
	FROM fact_account
)
SELECT * FROM highest_followers
WHERE ranks <=3

-- 10. Create a stored procedure that takes the 'Week_no' as input and generates a report displaying the total shares for each 'Post_type'. 
-- The output of the procedure should consist of two columns: post_type, total_shares

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_total_shares`(
IN week_num VARCHAR(255)
)
BEGIN
SELECT post_type,
		SUM(shares) AS total_shares
FROM fact_content c
JOIN dim_dates d
ON c.date = d.date
WHERE d.week_no = week_num
GROUP BY post_type, week_no
ORDER BY total_shares DESC;
END


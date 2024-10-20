CREATE TABLE netflix
(
	show_id VARCHAR(10),	
	type VARCHAR(10) ,	
	title VARCHAR(150),	
	director VARCHAR(208),	
	casts VARCHAR(1000),	
	country VARCHAR(150),
	date_added VARCHAR(50),	
	release_year INT,	
	rating VARCHAR(10),	
	duration VARCHAR(15),	
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT count(*) FROM netflix;

-- **15 Business Problems**: 

-- 1. Count the number of Movies vs TV shows

SELECT type, COUNT(*) FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

SELECT type, rating FROM 
(
SELECT type, rating, COUNT (*), 
RANK () OVER (PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1, 2
) AS t1
WHERE ranking = 1

-- 3. List all movies released in a specific year (e.g, 2020)

SELECT * FROM netflix
WHERE release_year= '2020' AND type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix

SELECT UNNEST (STRING_TO_ARRAY(country, ',')) as new_country,
COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

-- 5. Identify the longest movie

SELECT * FROM netflix
WHERE type = 'Movie' AND duration = (SELECT MAX(duration)
FROM netflix);

-- 6. Find content added in the last 5 years

SELECT * FROM netflix
WHERE 
TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT * FROM netflix
WHERE type = 'TV Show' 
AND SPLIT_PART(duration, ' ', 1)::numeric > 5;

-- 9. Count the number of content items in each genre

SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, COUNT(show_id) 
FROM netflix
GROUP BY 1;

-- 10. What is the yearly distribution and average percentage of total content added to Netflix from Turkey

SELECT EXTRACT (YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year, 
COUNT (*) AS yearly_content,
ROUND(
COUNT (*)::numeric/ (SELECT COUNT(*) FROM netflix WHERE country = 'Turkey')::numeric * 100 
,2) as avg_content_per_year
FROM NETFLIX
WHERE country = 'Turkey'
GROUP BY 1;

-- 11. List all movies that are documentaries 

SELECT * FROM netflix
WHERE type = 'Movie' AND listed_in ILIKE '%Documentaries%';

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Mark Ruffalo' appeared in the last 10 years

SELECT * FROM netflix
WHERE casts ILIKE '%Mark Ruffalo%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in the United Kingdom

SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
COUNT (*) as total_content
FROM netflix
WHERE country ILIKE '%United Kingdom%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description. 
-- Label content containing these keywords as 'Dark-themed' and all other content as 'Wholesome'. Count how many items fall into each category

WITH new_table
AS
(
SELECT *,
	CASE 
		WHEN description ILIKE '%kill%' OR 
		description ILIKE '%violence%' THEN 'Dark_Content'
		ELSE 'Good_Content'
	END AS category
FROM netflix
)
SELECT category, COUNT(*) as total_content
FROM new_table
GROUP BY 1;




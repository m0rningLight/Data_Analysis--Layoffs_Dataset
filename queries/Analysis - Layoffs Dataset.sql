/*
Objectives

Top 5 Companies with the most layoffs overall
Top 5 Companies that laid off year-wise.
Which companies perform layoffs most often
When do layoffs peak within a year?
Is there any corolation between number of layoffs in global and that in the US?
Top 5 industries affected the most globally?
Industries/Countries with most company ceased operations
In which stage of the company had the most lay-offs?


VISUALISATION

Total layoffs per location per year
Industries total layoffs per month with significant events as reference
Regression of total employee number over time. Partitioned per quarter to add new hires
*/


-- Top 5 Companies with the most layoffs overall

SELECT 
	company, 
    SUM(total_laid_off) AS Total_layoffs
FROM layoffs_cleaned
GROUP BY company
ORDER BY Total_layoffs DESC
LIMIT 5;


-- Top 5 Companies with the most layoffs year-wise

WITH Yearly_layoffs AS 
(
SELECT 
	YEAR (layoff_date) AS `Year`,
    company, 
    SUM(total_laid_off) AS No_of_layoffs
FROM layoffs_cleaned
GROUP BY company, `Year`
),
Rankings AS (
SELECT
	`Year`,
    company,
    No_of_layoffs,
    DENSE_RANK () OVER( PARTITION BY `Year` ORDER BY No_of_layoffs DESC) AS Ranking
    FROM Yearly_layoffs
    WHERE `Year` IS NOT NULL
    )
    SELECT *
    FROM Rankings
    WHERE Ranking <= 5
    ORDER BY `Year` ASC, Ranking ASC
    ;

-- Which companies perform layoffs most often

WITH occurances AS (
SELECT 
	*,
    ROW_NUMBER() OVER( PARTITION BY company, location ) AS layoff_occurance
FROM layoffs_cleaned
WHERE total_laid_off > 0
)
SELECT 
	company,
    MAX(layoff_occurance) AS layoff_occurances,
    SUM(total_laid_off) AS Total_laid_off
FROM occurances
GROUP BY company
ORDER BY layoff_occurances DESC ;

-- When do layoffs peak within a year?

SELECT 
    YEAR (layoff_date) AS `Year`,
    MONTH(layoff_date) AS `Month`,
    SUM(total_laid_off) AS Total_layoffs
FROM layoffs_cleaned
WHERE 
	layoff_date IS NOT NULL 
GROUP BY `Year`, `Month`
ORDER BY `Year`, Total_layoffs DESC
;

 -- Is there any corolation between number of layoffs globally compared to the US?

CREATE TEMPORARY TABLE Global_vs_US_layoffs (
	`Year` INT,
    Total_Global_layoffs INT,
    Total_USA_layoffs INT,
    `% Difference from global` INT);
    
INSERT INTO Global_vs_US_layoffs
SELECT *
FROM (
WITH US_yearly_layoffs AS (
SELECT 
	YEAR (layoff_date) AS `Year`,
    SUM(total_laid_off) AS Total_USA_layoffs
FROM layoffs_cleaned
WHERE 
	layoff_date IS NOT NULL
	AND country = 'United States'
GROUP BY `Year`
ORDER BY `Year`
),
Global_early_layoffs AS (
SELECT 
	YEAR (layoff_date) AS `Year`,
    SUM(total_laid_off) AS Total_Global_layoffs
FROM layoffs_cleaned
WHERE 
	layoff_date IS NOT NULL
	AND country != 'United States'
GROUP BY `Year`
ORDER BY `Year`
) 
SELECT 
	G.`Year`,
    G.Total_Global_layoffs,
    US.Total_USA_layoffs,
    ABS((G.Total_Global_layoffs - US.Total_USA_layoffs) / G.Total_Global_layoffs * 100) AS `%`
FROM Global_early_layoffs AS G
JOIN US_yearly_layoffs AS US
	ON G.`Year`= US.`Year`
 ) AS US_v_G;   

SELECT *
FROM Global_vs_US_layoffs;

-- US vs Global differences for the top 5 industries

CREATE TEMPORARY TABLE US_vs_Global_industry (
`Year` INT,
Country varchar(255),
Industry varchar(255),
Total_layoffs INT);

-- To insert the US industry data
INSERT INTO US_vs_Global_industry
WITH Yearly_industry_layoffs AS (
SELECT 
	YEAR (layoff_date) AS `Year`,
    country,
    industry, 
    SUM(total_laid_off) AS Total_layoffs
FROM layoffs_cleaned
WHERE 
	layoff_date IS NOT NULL
    AND country = 'United States'
GROUP BY `Year`, industry
ORDER BY `Year`, Total_layoffs DESC
),
Rankings AS (
SELECT
	`Year`,
    country,
    industry,
    Total_layoffs
    FROM Yearly_industry_layoffs
    WHERE `Year` IS NOT NULL
    ),
US AS (
SELECT 
	`Year`,
    country,
    industry,
    Total_layoffs
FROM Rankings
ORDER BY `Year` ASC, Total_layoffs DESC
) 
SELECT *
FROM US;
;

SELECT *
FROM US_vs_Global_industry;

INSERT INTO US_vs_Global_industry
WITH Yearly_industry_layoffs AS (
SELECT 
	YEAR (layoff_date) AS `Year`,
    'Global' AS country,
    industry, 
    SUM(total_laid_off) AS Total_layoffs
FROM layoffs_cleaned
WHERE 
	layoff_date IS NOT NULL
    AND country != 'United States'
GROUP BY `Year`, industry
ORDER BY `Year`, Total_layoffs DESC
),
Rankings AS (
SELECT
	`Year`,
    country,
    industry,
    Total_layoffs
    FROM Yearly_industry_layoffs
    WHERE `Year` IS NOT NULL
    ),
G AS (
SELECT 
	`Year`,
    country,
    industry,
    Total_layoffs
FROM Rankings
ORDER BY `Year` ASC, Total_layoffs DESC
) 
SELECT *
FROM G;
;



-- Top 10 industries affected the most globally

CREATE TEMPORARY TABLE TOP_10_industries
SELECT 
	industry, 
    SUM(total_laid_off) AS Total_layoffs
FROM layoffs_cleaned
GROUP BY industry
ORDER BY Total_layoffs DESC
LIMIT 10;

SELECT *
FROM TOP_10_industries;

-- Select the top 10 industries to perform the comparison 

SELECT *
FROM US_vs_Global_industry
WHERE 
	Industry IN ( SELECT industry FROM TOP_10_industries)
ORDER BY `Year`, Total_layoffs DESC;

-- Top 5 industries affected the most yearly

WITH Yearly_industry_layoffs AS (
SELECT 
	YEAR (layoff_date) AS `Year`,
    industry, 
    SUM(total_laid_off) AS Total_layoffs
FROM layoffs_cleaned
WHERE layoff_date IS NOT NULL
GROUP BY `Year`, industry
ORDER BY `Year`, Total_layoffs DESC
),
Rankings AS (
SELECT
	`Year`,
    industry,
    Total_layoffs,
    DENSE_RANK () OVER( PARTITION BY `Year` ORDER BY Total_layoffs DESC) AS Ranking
    FROM Yearly_industry_layoffs
    WHERE `Year` IS NOT NULL
    )
SELECT 
	`Year`,
    industry,
    Total_layoffs
FROM Rankings
WHERE Ranking <= 5
ORDER BY `Year` ASC, Ranking ASC;

-- Industries/Countries with most company ceased operations

WITH IndustryCounts AS (      		-- Industry
    SELECT
        YEAR(layoff_date) AS `Year`,
        industry,
        COUNT(company) AS `Out_of_business`
    FROM layoffs_cleaned
    WHERE percentage_laid_off = 1
    GROUP BY `Year`, industry
),
RankedIndustries AS (
    SELECT
        `Year`,
        industry,
        `Out_of_business`,
        RANK() OVER (PARTITION BY `Year` ORDER BY `Out_of_business` DESC) AS `Ranking`
    FROM IndustryCounts
)
SELECT
    `Year`,
    industry,
    `Out_of_business`
FROM RankedIndustries
WHERE `Ranking` <= 5
ORDER BY `Year` ASC, `Ranking` ASC;



WITH Country_Counts AS (			-- Country
    SELECT
        YEAR(layoff_date) AS `Year`,
        country,
        COUNT(company) AS `Out_of_business`
    FROM layoffs_cleaned
    WHERE percentage_laid_off = 1
    GROUP BY `Year`, country
),
RankedCountries AS (
    SELECT
        `Year`,
        country,
        `Out_of_business`,
        RANK() OVER (PARTITION BY `Year` ORDER BY `Out_of_business` DESC) AS `Ranking`
    FROM country_Counts
)
SELECT
    `Year`,
    country,
    `Out_of_business`
FROM Rankedcountries
WHERE `Ranking` <= 5
ORDER BY `Year` ASC, `Ranking` ASC;

    
-- In which stage of the company had the most layoffs?

SELECT 
	stage,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY stage
ORDER BY total_layoffs DESC;

-- The average percentage laid off per stage
SELECT 
	stage,
    AVG(percentage_laid_off) AS total_layoffs
FROM layoffs_cleaned
WHERE 
	percentage_laid_off IS NOT NULL
	AND stage IS NOT NULL
GROUP BY stage
ORDER BY total_layoffs DESC;


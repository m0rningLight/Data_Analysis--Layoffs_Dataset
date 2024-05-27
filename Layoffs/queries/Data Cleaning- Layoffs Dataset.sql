-- SQL Project - Layoffs Dataset 

-- LOAD DATA

CREATE TABLE layoffs (
company VARCHAR(255),
location VARCHAR(255),
industry VARCHAR(255),
total_laid_off INT,
percentage_laid_off INT,
layoff_date VARCHAR(255),
stage VARCHAR(255),
country VARCHAR(255),
funds_raised_millions INT) ;

SELECT *
FROM layoffs;

-- Let's create a staging table for cleaning

DELIMITER $$
CREATE TABLE layoffs_staging
LIKE layoffs;
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;
$$
DELIMITER ;

SELECT *
FROM layoffs_staging;

-- CLEANING:

-- 1. Address NULL entries
-- 2. Remove duplicates
-- 3. Standardise data and remove errors


-- 1. Address NULL entries

SELECT *
FROM layoffs_staging
WHERE industry IS NULL
OR industry = '';

-- Lot's of blank entries instead of NULL. Let's convert the blanks to NULL first
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging
WHERE company = 'Airbnb';

-- Now lets add the industry to the companies already existing

-- First let's see if our JOIN works
SELECT t1.company, t1.industry, t2.company, t2.industry
FROM layoffs_staging AS t1
JOIN layoffs_staging as t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Now to update the table
UPDATE layoffs_staging AS t1
JOIN layoffs_staging as t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Test 
SELECT *
FROM layoffs_staging
WHERE industry IS NULL; -- Only Bally's Interactive is left with a NULL but it will be removed later

-- Now to remove all that have NULL layoffs and percentage layoffs

SELECT *
FROM layoffs_staging
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;

-- 2. Remove duplicates

-- We are partitioning by company, location, industry, country and layoff_date to see if we have duplicates 
DROP TABLE IF EXISTS duplicates;
CREATE TEMPORARY TABLE duplicates
(SELECT *,
	ROW_NUMBER() OVER( 
		PARTITION BY company, location, industry, country, layoff_date  
		ORDER BY total_laid_off DESC
    ) AS row_num
	FROM layoffs_staging );
    
SELECT * 
FROM duplicates; -- TEMP table created with row_num

SELECT * 
FROM duplicates
WHERE row_num > 1
ORDER BY company ASC;

-- Let's check to make sure they are legitimate duplicates
SELECT *
FROM duplicates
WHERE company = 'Wildlife Studios'; -- There is a duplicate here

SELECT *
FROM duplicates
WHERE company = 'StockX'; -- There is a duplicate here but the total_laid_off numbers are different

-- The duplicate with the highest number of total_laid_off will be chosen, the other is discarded

-- Create new table without duplicates
DROP TABLE IF EXISTS layoffs_staging_2;
CREATE TABLE layoffs_staging_2
LIKE duplicates;

INSERT INTO layoffs_staging_2
SELECT *
FROM duplicates
WHERE row_num = 1;

SELECT *
FROM layoffs_staging_2;

-- Test
SELECT *
FROM layoffs_staging_2
WHERE company = 'StockX'; 
-- No more duplicates

-- 3. Standardise data and remove errors

-- Company
-- Remove spaces at the beginning of the company names
UPDATE layoffs_staging_2
SET company = TRIM(LEADING ' ' FROM company);

SELECT *
FROM layoffs_staging_2
ORDER BY company;

-- Location
SELECT DISTINCT location
FROM layoffs_staging_2
ORDER BY location; 

-- The following cities need to be corrected
-- DÃ¼sseldorf
-- FlorianÃ³polis

UPDATE layoffs_staging_2
SET location = 'Florianópolis'
WHERE location = 'FlorianÃ³polis'; 

UPDATE layoffs_staging_2
SET location = 'Düsseldorf'
WHERE location = 'DÃ¼sseldorf'; 

SELECT location
FROM layoffs_staging_2
WHERE location = 'Düsseldorf' 
	OR location = 'Florianópolis';
    
-- Industry
SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY industry; 

-- There are multiple crypto currency entries for industry
UPDATE layoffs_staging_2
SET industry = 'Crypto Currency'
WHERE industry LIKE '%crypto%'; 

-- Country
-- Remove periods at the end of countries
UPDATE layoffs_staging_2
SET country = TRIM( TRAILING '.' FROM country);

-- layoff_date
-- Let's convert to date type

-- Updating the string date format to DATE format
UPDATE layoffs_staging_2
SET layoff_date = STR_TO_DATE(layoff_date, '%m/%d/%Y');

-- Changing the column type to DATE 
ALTER TABLE layoffs_staging_2
MODIFY layoff_date DATE;

-- Finally to remove num_row as the cleaning is complete
CREATE TABLE `layoffs_cleaned` (
  `company` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `industry` varchar(255) DEFAULT NULL,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` int DEFAULT NULL,
  `layoff_date` date DEFAULT NULL,
  `stage` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_cleaned
SELECT * 
FROM layoffs_staging_2;

ALTER TABLE layoffs_cleaned
DROP COLUMN row_num;

SELECT *
FROM layoffs_cleaned;



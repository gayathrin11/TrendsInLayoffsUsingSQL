-- SQL DATA CLEANING OF LAYOFF DATASET(Kaggle)

SELECT * FROM layoffs;
-- SOME STEPS TO PERFORM DATA CLEANING
-- 1. Check and remove duplicates if any
-- 2. Standardize data
-- 3. Remove/populate null or blank values
-- 4. Remove unwanted columns or rows if possible

-- Create a staging table so that the raw data remains unaffected.
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- Step 1: Remove duplicates
-- Check for duplicates

-- Partition By all is done since entries may vary if the value in a single column is different(checked and confirmed)
WITH CTE AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) RN
FROM layoffs_staging)
SELECT * FROM CTE
WHERE RN>1;

-- We want to delete the entries with RN>1 that is, the one with duplicate entries.
-- We perform the delete by creating another staging table with a new column, row_num and then deleting entries with row_num>1
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised_millions) RN
FROM layoffs_staging ;

SELECT * FROM layoffs_staging2 WHERE row_num > 1;

-- Now, delete rows with row_num > 1
DELETE FROM layoffs_staging2 WHERE row_num > 1;



-- Step 2: Standardizing data
SELECT DISTINCT company from layoffs_staging2;

-- Removing whitespaces
SELECT company,TRIM(company) from layoffs_staging2;
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardizing the industry name Crypto
SELECT DISTINCT industry from layoffs_staging2 ORDER BY 1;
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Removing trailing unwanted characters
SELECT distinct country FROM layoffs_staging2 ORDER BY 1;
SELECT * FROM layoffs_staging2
WHERE country LIKE 'United States%';
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) FROM layoffs_staging2 ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Fix the date columns
SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

-- Converting data type to date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;



-- Step 3: Working with null and blank values

-- some industry values have null or empty rows
SELECT *
from layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- Taking the example of airbnb; there are entries where industry name is not populated
SELECT *
from layoffs_staging2
WHERE company ='Airbnb';

-- To fix this - if there is another row with the same company name and empty industry name, update it to the non-null industry values
SELECT t1.industry, t2.industry
from layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry=t2.industry
WHERE (t1.industry IS NULL OR t1.industry ='')
AND t2.industry IS NOT NULL;

-- Set the blanks to null since those are normally easier to work with
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;



-- Step 4: Remove unnecessary columns
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Deleting the entries where no one was laid off
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2;

-- Delete the column row_num created for deleting the duplicate entries
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Data cleaning done

















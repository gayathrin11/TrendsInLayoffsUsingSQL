-- EXPLORATORY DATA ANALYSIS
-- data exploration to find trends or patterns

SELECT * FROM layoffs_staging2;

-- Checking maximum counts and percentage of layoffs
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies where 100 percent employees were laid off
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off=1 
ORDER BY total_laid_off DESC;

-- Companies that had high potential funding but still went under
SELECT * FROM layoffs_staging2
WHERE percentage_laid_off=1 
ORDER BY funds_raised_millions DESC;

-- USING GROUP BY
-- Companies with highest layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company 
ORDER BY 2 DESC
LIMIT 5;


-- Finding the industry with highest layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry 
ORDER BY 2 DESC; 

-- Layoffs based on country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country 
ORDER BY 2 DESC; 

-- Layoffs based on date
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date` 
ORDER BY 1 DESC;

-- Layoffs grouped by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`) 
ORDER BY 1 DESC; 

-- Layoffs based on company stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage 
ORDER BY 2 DESC;

-- To check the progression of layoffs - find rolling sum
SELECT *
FROM layoffs_staging2;

-- Layoffs per Month
SELECT month(`date`), sum(total_laid_off)
FROM layoffs_staging2
group by month(`date`) ;

-- Layoffs per Year-Month
-- Way 1 - Year-Month extraction
SELECT date_format(`date`,"%Y-%m")  `MONTH`, sum(total_laid_off)
FROM layoffs_staging2
WHERE date_format(`date`,"%Y-%m") IS NOT NULL
group by  `MONTH`
ORDER BY 1 ASC ;

-- Way 2
SELECT SUBSTRING(`date`,1, 7) `MONTH`, sum(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1, 7) IS NOT NULL
group by `MONTH`
ORDER BY 1 ASC ;

-- Using a CTE to query off of it to find Rolling Sum of Layoffs Per Month
WITH CTE AS(
SELECT SUBSTRING(`date`,1, 7) AS MONTH, sum(total_laid_off) AS TOTAL_LAYOFF
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1, 7) IS NOT NULL
group by SUBSTRING(`date`,1, 7)
ORDER BY 1 ASC
)
SELECT MONTH, TOTAL_LAYOFF, SUM(TOTAL_LAYOFF) OVER(ORDER BY MONTH) AS ROLLING_SUM 
FROM CTE;

-- Company Layoffs per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`) 
ORDER BY 3 DESC;

-- Ranking the companies based on the number of employee layoffs per year
WITH YEAR_CTE (Company, Years, Total_laid_off) AS(
SELECT company, YEAR(`date`), SUM(total_laid_off) AS TOTAL_LAYOFF
FROM layoffs_staging2
GROUP BY company, YEAR(`date`) 
ORDER BY 3 DESC),
RANKING_CTE AS(
SELECT * , dense_rank() OVER(PARTITION BY Years ORDER BY Total_laid_off DESC) AS RANKING
FROM YEAR_CTE
WHERE Years IS NOT NULL)
SELECT * FROM RANKING_CTE
WHERE RANKING <= 5
;

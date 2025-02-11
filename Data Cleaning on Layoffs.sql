create database db1;
use db1;

select *from layoffs;

--  1) Remove duplicates 
-- 2) Standardize the data
-- 3) Null Values or Blank Values 
-- 4) Remove Any Columns or Rows


Create table layoffs_staging 
like layoffs;

insert  layoffs_staging 
select *from layoffs;

select *from layoffs_staging;



--  1) Remove duplicates 



WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
               ) AS row_nums
    FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte 
WHERE row_nums > 1;


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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select * from layoffs_staging2;


insert into layoffs_staging2
 SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
               ) AS row_nums
FROM layoffs_staging;

DELETE
from layoffs_staging2
where row_num > 1;

select *from layoffs_staging2;




-- 2) Standardize the data
-- standardizing the data means finding the issues and fixing it;





-- now we remove the space.
select company , TRIM(company)
from layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

 -- check null and blank values 
 
select distinct industry 
from layoffs_staging2
order by 1;  

-- this check name of same industry but slightly difference in their name and make them same.


select *
from layoffs_staging2
where industry like 'crypto%'; 

Update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- check issues with location

select distinct location 
from layoffs_staging2
order by 1;

-- check issues with Country fix it if it's have.
 
 select distinct country 
 from layoffs_staging2
 order by 1;
 
 update layoffs_staging2 
 set country =  'United States'
 where country like 'United States%';

-- we can also update like this 
--  update layoffs_staging2 
--  set country =  TRIM(trailing  '.' from  country )
--  where country like 'United States%';


-- check issues with Date fix it if it's have.

select date from layoffs_staging2;

select `date` , str_to_date(`date` , '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2 
set `date` = str_to_date(`date` , '%m/%d/%Y');

Alter table layoffs_staging2
modify column `date` Date;


select * from layoffs_staging;




-- 3) Null Values or Blank Values 



select * from layoffs_staging2
where total_laid_off is NULL and
percentage_laid_off is NULL ;


select *  from layoffs_staging2
where industry is NULL or
industry = ' ';


select * from layoffs_staging2
where company = 'Airbnb';  


-- In this company and location data of rows are almost same so we populate NULL and Blank values on rows from rows having data
-- Make all the blank Values NULL

UPDATE layoffs_staging2
SET industry =  NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 
  ON t1.company = t2.company
WHERE t1.industry IS NULL 
  AND t2.industry IS NOT NULL;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Delete Data where total_laid_off and percentage_laid_off both are null.
select * 
from layoffs_staging2 
where total_laid_off is NULL and
percentage_laid_off is NULL;


DELETE from layoffs_staging2 
where total_laid_off is NULL and
percentage_laid_off is NULL;

select * from layoffs_staging2;


-- 4) Remove Any Columns or Rows
-- Delete Column Row_num because it is not used and it's also increase size of dataset.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

select * from layoffs_staging2;


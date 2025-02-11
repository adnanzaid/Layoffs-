use db1;

describe layoffs_staging2;

-- Maximum No. of employees and Maximum  percentage of  employees  Laidoff by company 

select Max(total_laid_off) , Max(percentage_laid_off)
from layoffs_staging2;


-- Company data who laidoffs their 100 percent employees 
Select *
from layoffs_staging2
where percentage_laid_off = 1;

-- Company data who laidoffs their 100 percent employees 
Select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- Company had Maximum Laidoff

select company , sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- Industry had Maximum Laidoff

select industry , sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;


-- Country had Maximum Laidoff

select Country , sum(total_laid_off)
from layoffs_staging2
group by Country
order by 2 desc;

-- Year had Maximum Laidoff

select Year(`date`) , sum(total_laid_off)
from layoffs_staging2
group by Year(`date`)
order by 2 desc;

-- Stage had Maximum Laidoff

select stage , sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

-- Date Range

select Min(`date`) as `start` , Max(`date`) as `end`
from layoffs_staging2;

-- Rolling total of Layoffs per Month



select substr(`date` , 1 , 7) as `month` , sum(total_laid_off) as total_laid_off
from layoffs_staging2
where substr(`date` , 1 , 7)  is not NULL
group by `month`
order by 1 asc ;


-- now use it in a CTE so we can query off of it

with Rolling_total as (
select substr(`date` , 1 , 7) as `month` , sum(total_laid_off) as total_laid_off
from layoffs_staging2
where substr(`date` , 1 , 7)  is not NULL
group by `month`
order by 1 asc 
)

select `month` , total_laid_off , 
sum(total_laid_off) over(order by `Month`) as rolling_total
from Rolling_total;  -- rolling_total is like Cummulative_Sum



select company , year(`date`) as date_year , sum(total_laid_off) as total
from layoffs_staging2
group by company , year(`date`)
order by 3 desc;


-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year.



with company_year (company , years , total_laidoffs) as (
select company , year(`date`)  , sum(total_laid_off)
from layoffs_staging2
group by company , year(`date`)
order by 3 desc )

, company_year_rank as (
select company , years, total_laidoffs ,
dense_rank()over(partition by years order by total_laidoffs desc) as ranking 
from company_year
where years is not NULL
)

select *
from company_year_rank
where ranking <= 5;




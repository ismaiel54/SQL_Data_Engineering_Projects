-- count rows - aggregation only

SELECT
    COUNT(*)
FROM 
    job_postings_fact;

-- count rows - window function

SELECT  
    job_id,
    COUNT(*) OVER ()
FROM 
    job_postings_fact;


-- partition by - hourly salary

SELECT  
    job_id,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY (job_title_short)
    ) AS salary_by_title
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL;

-- ORDER BY - ranking salary hour average

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        ORDER BY salary_hour_avg DESC
    )
FROM
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC;

-- PARTITION BY AND ORDER BY - running average hourly Salary

SELECT  
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY  job_posted_date
    ) AS salary_by_title
FROM 
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY 
    job_title_short,
    job_posted_date
LIMIT 10;




SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    )
FROM
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY
    job_title_short,
    salary_hour_avg DESC;

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER (
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    )
FROM
    job_postings_fact
WHERE 
    salary_hour_avg IS NOT NULL
ORDER BY
    salary_hour_avg DESC,
    job_title_short;


DENSE_RANK()

-- LAG() - TIME BASED COMPARISON OF COMPANT YEARLY SALARY

SELECT 
    job_id,
    company_id,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS prev_salary,
    salary_year_avg - salary_year_avg,
    LAG(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    ) AS prev_diff
FROM job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL
ORDER BY 
    company_id, 
    job_posted_date
LIMIT 60;





-- RECAP    
-- LAG() - TIME BASED COMPARISON OF COMPANT YEARLY SALARY
SELECT 
    job_id,
    company_id,
    job_title_short,
    job_posted_date,
    salary_year_avg,
    LAG(salary_year_avg) OVER (
        PARTITION BY company_id
        ORDER BY job_posted_date
    )
FROM
    job_postings_fact
WHERE 
    salary_year_avg IS NOT NULL
ORDER BY  
    company_id,
    job_posted_date
LIMIT 60;

-- PARTITION BY AND ORDER BY - running average hourly Salary

SELECT  
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER (
        PARTITION BY job_title_short
        ORDER BY job_posted_date
    )
FROM
    job_postings_fact
WHERE
    salary_hour_avg IS NOT NULL
ORDER BY
    job_title_short,
    job_posted_date;
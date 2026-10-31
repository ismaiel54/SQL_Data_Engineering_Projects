-- Bucket Salaries
-- < 25 'Low'
-- 25-50 = 'Medium'
-- ? 50 = 'High'

SELECT
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_classification
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL;


-- Handling Missing Data (Nulls)
-- Filter NULL salary values

SELECT
    job_title_short,
    salary_hour_avg,
    CASE
        WHEN salary_hour_avg IS NULL THEN 'Missing'
        WHEN salary_hour_avg < 25 THEN 'Low'
        WHEN salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_classification
FROM job_postings_fact
LIMIT 1O;


-- Categorizing Categorical Values
-- Classify the 'job_title' column values as:
-- 'Data Analyst'
-- 'Data Engineer'
-- 'Data Scientist'

SELECT
    job_title,
    job_title_short,
    CASE 
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Anaylist%' THEN 'Data Anaylist' 
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Engineer%' THEN 'Data Engineer' 
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END 
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 20;


-- Conditional Aggregation
-- Calculate Median Salaries for Different Buckets
-- < $100K
-- >= $100K

SELECT
    job_title_short,
    MEDIAN(
        CASE
            WHEN salary_year_avg < 100_000 THEN salary_year_avg
        END
    ) AS lower_threshold,
    MEDIAN(
        CASE
            WHEN salary_year_avg >= 100_000 THEN salary_year_avg
        END
    ) AS higher_threshold
FROM job_postings_fact
GROUP BY job_title_short;



-- Final Example: Conditional Calculations
-- Compute a standardized_salary using yearly salary and adjusted hourly salary (e.g.
-- Categorize salaries into tiers of:
-- < 75K 'Low'
-- 75K - 150K 'Medium'
-- >= 150K 'High'

SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    CASE
        WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
        WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
    END AS standardized_salary,
    CASE
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 150_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_classification
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 20;

WITH standardized_CTE AS (
    SELECT
        job_title_short,
        salary_year_avg,
        salary_hour_avg,
        CASE
            WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
            WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
        END AS standardized_salary,
    FROM job_postings_fact
    WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
)
SELECT
    *,
    CASE
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 150_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_classification
FROM standardized_CTE;


SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg*2028) AS standardized_salary,
    CASE
        WHEN COALESCE(salary_year_avg, salary_hour_avg*2028) < 75_000 THEN 'LOW'
        WHEN COALESCE(salary_year_avg, salary_hour_avg*2028) < 150_000 THEN 'MEDUIM'
        ELSE 'HIGH'  
    END
FROM job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
    OR 
    salary_hour_avg IS NOT NULL;






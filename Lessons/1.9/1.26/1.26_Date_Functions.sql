SELECT 
    job_posted_date,
    job_posted_date::DATE AS date,
    job_posted_date::TIME AS time,
    job_posted_date::TIMESTAMP AS time_stamp,
    job_posted_date::TIMESTAMPTZ AS time_zone
FROM job_postings_fact
LIMIT 10;


SELECT 
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE
    job_title_short = 'Data Engineer'
GROUP BY
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date)
ORDER BY
    year,
    month;


SELECT 
    job_posted_date,
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    DATE_TRUNC( 'year', job_posted_date) AS truncated_year,
    DATE_TRUNC( 'quarter', job_posted_date) AS truncated_quarter,
    DATE_TRUNC( 'month', job_posted_date) AS truncated_month,
    DATE_TRUNC( 'week', job_posted_date) AS truncated_week,
    DATE_TRUNC('day', job_posted_date) AS truncated_hour 
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;


SELECT 
    DATE_TRUNC('month', job_posted_date) AS month_posted,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE
    job_title_short = 'Data Engineer'
    AND 
    EXTRACT(YEAR FROM job_posted_date) = 2024
GROUP BY
    DATE_TRUNC('month', job_posted_date)
ORDER BY month_posted;






SELECT
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    COUNT(*),
    COUNT(*) FILTER (
        CASE
            WHEN job_title_short = 'Data Engineer'
        END
    ) AS data_numbers,
    COUNT(*) FILTER (
        CASE
            WHEN job_title_short = 'Software Engineer' 
        END
    ) AS software_numbers
FROM job_postings_fact
-- WHERE   
--     job_title_short = 'Data Engineer'
GROUP BY    
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date)
ORDER BY
    EXTRACT(YEAR FROM job_posted_date),
    EXTRACT(MONTH FROM job_posted_date);




SELECT
    DATE_TRUNC('month', job_posted_date) AS posting_month,

    COUNT(*) AS total_jobs,

    COUNT(*) FILTER (
        WHERE job_title_short = 'Data Engineer'
    ) AS data_engineer_jobs,

    COUNT(*) FILTER (
        WHERE job_title_short = 'Software Engineer'
    ) AS software_engineer_jobs

FROM job_postings_fact

WHERE job_posted_date IS NOT NULL

GROUP BY posting_month
ORDER BY posting_month;
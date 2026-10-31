
SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE
        salary_year_avg IS NOT NULL
        OR
        salary_hour_avg IS NOT NULL
)
LIMIT 10;

-- CTE
WITH valid_salaries AS (
    SELECT *
    FROM job_postings_fact
    WHERE
        salary_year_avg IS NOT NULL
        OR
        salary_hour_avg IS NOT NULL
)
SELECT *
FROM valid_salaries
LIMIT 10;

/*
🧩 Scenario 1 – Subquery in SELECT
- Show each job's salary next to the overall market median.
*/
SELECT
    job_title_short,
    salary_year_avg,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
    )
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

SELECT COUNT(*) 
FROM (
    SELECT
    job_title_short,
    salary_year_avg,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
    )
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
);

/*
🧩 Scenario 2 – Subquery in FROM
- Stage only jobs that are remote before aggregating.
*/
WITH remote_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE job_work_from_home
)
SELECT 
    job_title_short,
    salary_year_avg,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM remote_jobs
    )
FROM remote_jobs
WHERE salary_year_avg
LIMIT 10;

SELECT
    job_title_short,
    salary_year_avg,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE 
            job_work_from_home = TRUE
    )
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;


SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    (
        SELECT MEDIAN(salary_year_avg),
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE 
    ) AS median_market_salary
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS clean_jobs
-- WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short
ORDER BY median_salary DESC;


/*
🧩 Scenario 3 – Subquery in HAVING
- Keep only job titles whose median salary is above the overall median.
*/

SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS median_market_salary
FROM (
    SELECT
    job_title_short,
    salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS clean_jobs
GROUP BY job_title_short
HAVING median_salary > (
    SELECT MEDIAN(salary_year_avg)
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
)
ORDER BY median_salary DESC;



-- CTE Example
-- Compare how much more (or less) remote roles pay compared to onsite roles for each job title.
-- Use a CTE to calculate the median salary by title and work arrangement, then compare those medians.

WITH remote_role AS (
    SELECT
        job_title_short,
        MEDIAN(salary_year_avg) AS remote_median
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
    GROUP BY job_title_short
),
onsite_role AS (
    SELECT
        job_title_short,
        MEDIAN(salary_year_avg) AS onsite_median
    FROM job_postings_fact AS jpf
    WHERE jpf.job_country = 'United States'
    GROUP BY job_title_short
)
SELECT 
    jpf.job_title_short,
--    MEDIAN(salary_year_avg) AS median_salary,
    rr.remote_median,
    ro.onsite_median,
    rr.remote_median - ro.onsite_median AS diff_salary
FROM job_postings_fact AS jpf
LEFT JOIN remote_role AS rr
    ON jpf.job_title_short = rr.job_title_short
LEFT JOIN onsite_role AS ro
    ON jpf.job_title_short = ro.job_title_short
-- WHERE jpf.job_country = 'United States'
GROUP BY
    jpf.job_title_short,
    rr.remote_median,
    ro.onsite_median
ORDER BY diff_salary DESC
LIMIT 10;



WITH title_median AS (
    SELECT 
        job_title_short,
        job_work_from_home,
        MEDIAN(salary_year_avg)::INT AS median_salary
    FROM job_postings_fact
    WHERE job_country = 'United States'
    GROUP BY
        job_title_short,
        job_work_from_home
)

SELECT 
    r.job_title_short,
    r.median_salary AS remote_median,
    o.median_salary AS onsite_median,
    (remote_median - onsite_median) AS diff_salary
FROM title_median AS r
LEFT JOIN title_median AS o
    ON r.job_title_short = o.job_title_short
WHERE
    r.job_work_from_home = TRUE
    AND
    o.job_work_from_home = FALSE
ORDER BY diff_salary DESC;



/* EXISTS AND NOT EXISTS */

SELECT *
FROM range(3) AS src(key);

SELECT *
FROM range(2) AS tgt(key);

SELECT *
FROM range(3) AS src(key)
WHERE EXISTS (
    SELECT 1
    FROM range(2) AS tgt(key)
    WHERE tgt.key = src.key
);

SELECT *
FROM range(3) AS src(key)
WHERE NOT EXISTS (
    SELECT 1
    FROM range(2) AS tgt(key)
    WHERE tgt.key = src.key
);


-- Final Example
-- Identify job postings that have no associated skills before loading them into a data mart

SELECT *
FROM skills_job_dim
ORDER BY job_id
LIMIT 20;

SELECT *
FROM job_postings_fact AS tgt
WHERE NOT EXISTS (
    SELECT 1
    FROM skills_job_dim AS src
    WHERE src.job_id = tgt.job_id
)
ORDER BY job_id;

SELECT jpf.*
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
WHERE sjd.job_id IS NULL
ORDER BY jpf.job_id;



/*
🧩 Scenario 1 – Subquery in SELECT
- Show each job's salary next to the overall market median.
*/

SELECT
    job_title_short,
    MEDIAN(salary_year_avg) AS job_median,
    (
        SELECT
            MEDIAN(salary_year_avg)
        FROM job_postings_fact
    ) AS market_median
FROM job_postings_fact
GROUP BY job_title_short;

/*
🧩 Scenario 2 – Subquery in FROM
- Stage only jobs that are remote before aggregating.
*/

SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS job_median,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS market_median
    FROM (
        SELECT *
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    )
    GROUP BY job_title_short
    ORDER BY job_median DESC;


/*
🧩 Scenario 3 – Subquery in HAVING
- Keep only job titles whose median salary is above the overall median.
*/

SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS job_median,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS market_median
    FROM (
        SELECT *
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    )
    GROUP BY job_title_short
    HAVING job_median >= market_median
    ORDER BY job_median DESC;

    -- CTE Example
-- Compare how much more (or less) remote roles pay compared to onsite roles for each job title.
-- Use a CTE to calculate the median salary by title and work arrangement, then compare those medians.

WITH remote_role AS (
    SELECT 
        job_title_short,
        MEDIAN(salary_year_avg) AS median_salary,
        job_work_from_home
    FROM job_postings_fact
    GROUP BY
        job_title_short,
        job_work_from_home
) 
SELECT 
    r.job_title_short,
    r.median_salary,
    o.median_salary,
    (r.median_salary - o.median_salary) AS diff_salary 
FROM remote_role AS r
LEFT JOIN remote_role AS o
    ON r.job_title_short = o.job_title_short
WHERE 
    r.job_work_from_home = TRUE
    OR 
    o.job_work_from_home
ORDER BY diff_salary DESC;




WITH title_median AS (
    SELECT 
        job_title_short,
        job_work_from_home,
        MEDIAN(salary_year_avg)::INT AS median_salary
    FROM job_postings_fact
    -- WHERE job_country = 'United States'
    GROUP BY
        job_title_short,
        job_work_from_home
)
SELECT 
    r.job_title_short,
    r.median_salary AS remote_median,
    o.median_salary AS onsite_median,
    (remote_median - onsite_median) AS diff_salary
FROM title_median AS r
LEFT JOIN title_median AS o
    ON r.job_title_short = o.job_title_short
WHERE
    r.job_work_from_home = TRUE
    AND
    o.job_work_from_home = FALSE
ORDER BY diff_salary DESC;


/*
WITH title_median AS (
    SELECT
        job_title_short,
        job_work_from_home,
        MEDIAN(salary_year_avg) AS median_salary
    FROM job_postings_fact
    GROUP BY 
        job_title_short,
        job_work_from_home
)
SELECT
    r.job_title_short,
    r.median_salary AS remote_median,
    o.median_salary AS onsite_median,
    (remote_median - onsite_median) AS diff_salary 
FROM title_median AS r
LEFT JOIN title_median AS o
    ON r.job_title_short = o.job_title_short
WHERE
    r.job_work_from_home = TRUE
    AND 
    o.job_work_from_home = FALSE
ORDER BY diff_salary DESC;



SELECT
    sd.skills,
    COUNT(*)
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE sd.skills = 'dbt'
GROUP BY sd.skills;


SELECT *
FROM skills_dim
WHERE skills LIKE '%d%';
*/



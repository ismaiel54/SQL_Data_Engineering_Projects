SELECT [1, 1, 1, 2];

-- UNION

SELECT UNNEST([1, 1, 1, 2])
UNION
SELECT UNNEST([1, 1, 3]);

SELECT UNNEST([1, 1, 1, 2])
UNION ALL
SELECT UNNEST([1, 1, 3]);

-- INTERSECT

SELECT UNNEST([1, 1, 1, 2])
INTERSECT 
SELECT UNNEST([1, 1, 3]);

SELECT UNNEST([1, 1, 1, 2])
INTERSECT ALL
SELECT UNNEST([1, 1, 3]);

-- EXCEPT 

SELECT UNNEST([1, 1, 1, 2])
EXCEPT 
SELECT UNNEST([1, 1, 3]);

SELECT UNNEST([1, 1, 1, 2])
EXCEPT ALL
SELECT UNNEST([1, 1, 3]);


-- TASK

CREATE OR REPLACE TEMP TABLE twentytree_jobs AS
    SELECT * EXCLUDE(job_id, job_posted_date)
    FROM job_postings_fact
    WHERE 
        EXTRACT(YEAR FROM job_posted_date) = 2023;

SELECT *
FROM twentytree_jobs;

CREATE OR REPLACE TEMP TABLE twentyfo_jobs AS
    SELECT * EXCLUDE(job_id, job_posted_date)
    FROM job_postings_fact
    WHERE 
    EXTRACT(YEAR FROM job_posted_date) = 2024;

SELECT *
FROM twentyfo_jobs;

SELECT COUNT(*)
FROM twentytree_jobs
UNION 
SELECT COUNT(*)
FROM twentyfo_jobs;


SELECT *
FROM twentytree_jobs
UNION 
SELECT *
FROM twentyfo_jobs;

SELECT *
FROM twentytree_jobs
UNION ALL
SELECT *
FROM twentyfo_jobs;

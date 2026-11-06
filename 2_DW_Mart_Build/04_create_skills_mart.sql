-- Step 4: Mart - Create skills demand mart

DROP SCHEMA IF EXISTS skills_mart CASCADE;


CREATE SCHEMA skills_mart;

CREATE TABLE skills_mart.dim_skills (
    skill_id        INTEGER     PRIMARY KEY,
    skills          VARCHAR,
    type            VARCHAR
);

SELECT '=== Loading dim_skills Table ===' AS info;

INSERT INTO skills_mart.dim_skills (
    skill_id,
    skills,
    type
)
SELECT
    skill_id,
    skills,
    type
FROM skills_dim;



CREATE TABLE skills_mart.dim_date_month (
    month_start_date    DATE   PRIMARY KEY,
    year        INTEGER,
    month       INTEGER,
    quarter     INTEGER,
    quarter_name    VARCHAR,
    year_quarter    VARCHAR
);

SELECT '=== Loading dim_date_month Table ===' AS info;

INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR
FROM job_postings_fact
ORDER BY month_start_date;


CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id                INTEGER,
    month_start_date        DATE,
    job_title_short         VARCHAR,
    postings_count          INTEGER,
    remote_postings_count   INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_postings_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skills(skill_id)
);


SELECT '=== Loading fact_skill_demand_monthly Table ===' AS info;

INSERT INTO skills_mart.fact_skill_demand_monthly (
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_postings_count
)
WITH job_postings_prep AS (
    SELECT  
        sjd.skill_id AS skill_id,
        DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
        jpf.job_title_short AS job_title_short,
        -- convert boolean flags (1 or 0)
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurnace,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mentioned
    FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd
        ON jpf.job_id = sjd.job_id
)
SELECT 
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS postings_count,
    SUM(is_remote) AS remote_postings_count,
    SUM(has_health_insurnace) AS health_insurance_postings_count,
    SUM(no_degree_mentioned) AS no_degree_postings_count
FROM job_postings_prep
GROUP BY
    skill_id,
    month_start_date,
    job_title_short
ORDER BY month_start_date;



SELECT 'Skill Dimension' AS table_name, COUNT(*) AS record_count FROM skills_mart.dim_skills
UNION
SELECT 'Skill Dimension' AS table_name, COUNT(*) AS record_count FROM skills_mart.dim_date_month
UNION
SELECT 'Skill Dimension' AS table_name, COUNT(*) AS record_count FROM skills_mart.fact_skill_demand_monthly;

SELECT '=== Skill Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_skills LIMIT 5;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '=== Fact Skill Demand Dimension Sample ===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;
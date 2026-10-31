/*
===========================================================
SQL PRACTICE — DUCKDB DATA ENGINEERING
Database: data_jobs
Topics: Subqueries, CTEs, JOINs, EXISTS, NOT EXISTS,
        Data Cleaning, Staging Tables, DML and MERGE
===========================================================
*/


/*
===========================================================
QUESTION 1 — SUBQUERY IN SELECT
Difficulty: Easy

Scenario:
A recruitment company wants to compare individual Data
Engineer salaries against the overall market median.

Requirements:
- Only include Data Engineer jobs in the United States.
- Exclude jobs with NULL annual salaries.
- Return job_id, job_title_short and salary_year_avg.
- Use a subquery in SELECT to calculate the overall
  median annual salary for US Data Engineer jobs.
- Display this median alongside each individual salary.
- Limit the results to 20 rows.
===========================================================
*/

SELECT 
    job_id,
    job_title_short,
    salary_year_avg,
    (
        SELECT 
            MEDIAN(salary_year_avg)
        FROM job_postings_fact
        WHERE 
        job_title LIKE '%Data Engineer%'
        AND 
        job_location = 'United States'
    ) AS median_market_salary
FROM job_postings_fact
WHERE 
    job_title LIKE '%Data Engineer%'
    AND
    salary_year_avg IS NOT NULL
    AND
    job_location = 'United States'
LIMIT 20;



/*
===========================================================
QUESTION 2 — SUBQUERY IN FROM
Difficulty: Intermediate

Scenario:
A recruitment analyst wants to identify the highest-paying
remote job categories in the United Kingdom.

Requirements:
- Use a subquery in FROM to filter remote UK jobs.
- Exclude NULL annual salaries.
- Group the filtered jobs by job_title_short.
- Calculate the median annual salary for each job title.
- Count the number of salary observations per title.
- Order by median salary, highest first.
- Return the top 10 job titles.
===========================================================
*/

SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    COUNT(*),
FROM (
    SELECT 
        *
    FROM job_postings_fact
    WHERE 
        job_work_from_home = TRUE
        AND 
        job_location = 'United Kingdom'
        AND 
        salary_year_avg IS NOT NULL
)
GROUP BY job_title_short
ORDER BY median_salary
LIMIT 10;

/*
===========================================================
QUESTION 3 — SUBQUERY IN WHERE
Difficulty: Intermediate

Scenario:
A recruitment platform wants to find Data Engineer jobs
that pay above the market median in the United States.

Requirements:
- Only include US Data Engineer jobs.
- Exclude NULL annual salaries.
- Use a subquery in WHERE to calculate the median
  annual salary for US Data Engineer jobs.
- Return only jobs paying above that median.
- Display job_id, job_title, job_location and
  salary_year_avg.
- Order by salary_year_avg descending.
- Return the top 20 jobs.
===========================================================
*/





/*
===========================================================
QUESTION 4 — SUBQUERY IN HAVING
Difficulty: Intermediate

Scenario:
Identify job categories that pay more than the overall
US job market median.

Requirements:
- Only include jobs located in the United States.
- Exclude NULL annual salaries.
- Group results by job_title_short.
- Calculate the median annual salary for each title.
- Count the number of salary observations.
- Use HAVING with a subquery to return only titles
  whose median exceeds the overall US median.
- Only include titles with at least 30 salary observations.
- Order by median salary descending.
===========================================================
*/


/*
===========================================================
QUESTION 5 — MULTIPLE CTEs
Difficulty: Intermediate

Scenario:
A recruitment company wants to compare remote and
non-remote salaries across technical roles.

Requirements:
- Only analyse jobs in the United States.
- Focus on Data Engineer, Data Analyst and Data Scientist.
- Exclude NULL annual salaries.
- Create one CTE calculating remote median salaries.
- Create another CTE calculating non-remote median salaries.
- Join both CTEs using job_title_short.
- Return job_title_short, remote_median, onsite_median.
- Calculate the difference: remote_median - onsite_median.
- Only include roles with salary data in both groups.
- Order by salary difference descending.
===========================================================
*/


/*
===========================================================
QUESTION 6 — CTEs WITH MULTIPLE JOINs
Difficulty: Intermediate

Scenario:
A recruitment analytics company wants to find the most
in-demand technical skills for remote Data Engineers.

Requirements:
- Only include US Data Engineer jobs.
- Only include remote positions.
- Create a CTE containing these filtered jobs.
- Join with skills_job_dim and skills_dim.
- Count the number of distinct job postings
  requiring each skill.
- Return skill name, skill type and demand count.
- Order by demand count descending.
- Return the top 15 skills.
===========================================================
*/


/*
===========================================================
QUESTION 7 — JOINs AND AGGREGATION
Difficulty: Intermediate

Scenario:
Identify which companies advertise the most Data Engineer
positions in the United Kingdom.

Requirements:
- Join job_postings_fact with company_dim.
- Filter for UK Data Engineer jobs.
- Exclude NULL company names.
- Count the number of job postings per company.
- Only include companies with at least 5 postings.
- Return company name and total job postings.
- Order by posting count descending.
- Limit the results to 15 companies.
===========================================================
*/


/*
===========================================================
QUESTION 8 — EXISTS
Difficulty: Intermediate

Scenario:
A recruiter wants to find UK Data Engineer job postings
that explicitly require Python.

Requirements:
- Use job_postings_fact, skills_job_dim and skills_dim.
- Filter for UK Data Engineer positions.
- Use a correlated EXISTS subquery.
- Check whether each job has the skill 'python'.
- Do not use a JOIN in the outer query.
- Return job_id, job_title and job_location.
- Limit the results to 25 rows.
===========================================================
*/


/*
===========================================================
QUESTION 9 — NOT EXISTS
Difficulty: Intermediate

Scenario:
A data engineer wants to identify job postings that have
no associated skills in the database.

Requirements:
- Use job_postings_fact and skills_job_dim.
- Use a correlated NOT EXISTS subquery.
- Find job postings with no matching skill records.
- Group the unmatched postings by job_title_short.
- Count the number of unmatched postings per title.
- Order by the highest count.
- Return the top 10 job categories.
===========================================================
*/


/*
===========================================================
QUESTION 10 — DATA QUALITY WITH NOT EXISTS
Difficulty: Intermediate

Scenario:
Before loading data into a warehouse, you need to check
whether every job posting references a valid company.

Requirements:
- Use job_postings_fact and company_dim.
- Identify jobs whose company_id is non-NULL
  but does not match any record in company_dim.
- Use NOT EXISTS rather than a LEFT JOIN.
- Return the total number of orphaned job postings.
- Write a second query returning 20 examples,
  including job_id, company_id and job_title.
===========================================================
*/


/*
===========================================================
QUESTION 11 — DATA CLEANING WITH CTEs
Difficulty: Intermediate

Scenario:
The recruitment dataset contains inconsistent job board
names that can distort analytics.

For example:
- 'LinkedIn'
- 'via LinkedIn'

Both should be treated as the same source.

Requirements:
- Create a CTE that standardises these two values.
- Use CASE to convert both to 'LinkedIn'.
- Preserve other job board names unchanged.
- Group by the cleaned job board name.
- Count the number of job postings per source.
- Return the 10 most frequently used sources.
===========================================================
*/


/*
===========================================================
QUESTION 12 — CREATE TEMP TABLE
Difficulty: Intermediate

Scenario:
A data engineering pipeline needs a temporary staging
table of US technical jobs with valid annual salaries.

Requirements:
- Create a temporary table called staging_salary_jobs.
- Include only US jobs.
- Include only these job titles:
  Data Engineer, Data Analyst and Data Scientist.
- Exclude NULL annual salaries.
- Include job_id, job_title_short, job_posted_date,
  salary_year_avg and job_work_from_home.
- Write a second query to calculate the median salary
  and number of jobs per job title from the temp table.
===========================================================
*/


/*
===========================================================
QUESTION 13 — UPDATE, INSERT AND DELETE
Difficulty: Challenging

Scenario:
A company maintains a snapshot of priority technical
job postings.

The latest source data is held in src_priority_jobs.
The target is priority_jobs_snapshot.

Both tables contain:
- job_id
- job_title_short
- company_name
- priority_lvl
- updated_at

Assume job_id uniquely identifies each job.

Requirements:
1. Write an UPDATE statement that changes priority_lvl
   and updated_at for existing jobs, but only when
   priority_lvl has changed.

2. Write an INSERT statement that adds jobs from the
   source that do not exist in the target.

3. Write a DELETE statement that removes jobs from the
   target that no longer exist in the source.

4. Use EXISTS or NOT EXISTS where appropriate.

IMPORTANT:
Use temporary practice tables rather than modifying
production tables.
===========================================================
*/


/*
===========================================================
QUESTION 14 — MERGE INTO
Difficulty: Challenging

Scenario:
Rewrite Question 13 using one MERGE statement instead
of three separate statements.

Requirements:
- MERGE source data into priority_jobs_snapshot.
- Match records using job_id.
- When matched and priority_lvl is different:
  Update priority_lvl and updated_at.
- When a source job does not exist in the target:
  Insert the new record.
- When a target job no longer exists in the source:
  Delete the record.
- Do not update unchanged records.
- Use IS DISTINCT FROM to handle NULL comparisons.

IMPORTANT:
Use temporary practice tables.
===========================================================
*/


/*
===========================================================
QUESTION 15 — DATA VALIDATION
Difficulty: Challenging

Scenario:
After synchronising a snapshot table with its source,
a data engineer needs to verify that the operation
completed correctly.

Assume:
- src_priority_jobs contains the expected current data.
- priority_jobs_snapshot contains the synchronised data.

Requirements:
1. Count the total records in both tables.
2. Identify source jobs missing from the snapshot.
3. Identify snapshot jobs missing from the source.
4. Identify matching job_id values where priority_lvl
   differs between source and snapshot.
5. Use CTEs to organise the validation.
6. Return a summary showing:
   - source_count
   - target_count
   - missing_from_target
   - missing_from_source
   - priority_mismatches

A successful synchronisation should have zero missing
records and zero priority mismatches.

IMPORTANT:
Use your temporary practice tables.
===========================================================
*/
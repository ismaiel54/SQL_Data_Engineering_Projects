-- Array Intro 
SELECT [1, 2, 3];

SELECT ['python', 'sql', 'dbt'];


SELECT 'python' AS skill
UNION ALL
SELECT 'sql'
UNION 
SELECT 'dbt';


-- ARRAY_AGG()
WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION 
    SELECT 'dbt'
),
skills_array AS (
    SELECT ARRAY_AGG(skill ORDER BY skill) AS skill_array
    FROM skills;
)
SELECT 
    skill_array[1] AS first_skill,
    skill_array[2] AS second_skill,
    skill_array[3] AS third_skill
FROM 
    skills_array;


-- STRUCT
SELECT { skill: 'python', type: 'programming' } AS skill_struct;


SELECT  
    STRUCT_PACK(
        skill := 'python',
        type := 'programming'
    ) AS s;


-- STRUCT_PACK()
WITH skill_struct AS (
    SELECT  
        STRUCT_PACK(
            skill := 'python',
            type := 'programming'
        ) AS s
)
SELECT
    s.skill AS s_skill,
    s.type AS s_type
FROM
    skill_struct;



WITH skill_table AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION 
    SELECT 'dbt', 'programming'
)
SELECT
    STRUCT_PACK(
        skill_key := skills,
        type_key :=  types
    )
FROM skill_table;


-- ARRAY OF STRUCTS

SELECT [
    {'skill': 'python', 'type': 'programming'},
    {'skill': 'sql', 'type': 'query_language'},
    {'skill': 'dbt', 'type': 'programming'}
] AS struct_skills_array;


WITH skill_table AS (
    SELECT 'python' AS skills, 'programming' AS types
    UNION
    SELECT 'SQL', 'query_langauge'
    UNION
    SELECT 'dbt', 'programming'
), skills_array_struct AS (
    SELECT
        ARRAY_AGG(
            STRUCT_PACK(
                skill := skills,
                type := types
            ) ORDER BY skills
        ) AS array_struct
    FROM skill_table
)
SELECT 
    array_struct[1].skill,
    array_struct[2].type,
    array_struct[3]
FROM skills_array_struct;


-- MAP/ DICT

SELECT MAP {'python' : 'skill'};

-- JSON DATA
WITH raw_skill_json AS (
    SELECT
        '{"skill":"programming", "type":"programming"}'::JSON AS skill_json
)
SELECT 
    STRUCT_PACK(
        skill := json_extract_string(skill_json, '$.skill'),
        type := json_extract_string(skill_json, '$.type')
    ) AS skill_struct
FROM raw_skill_json;

-- JSON to Array of Structs
SELECT
'[
    {"skill": "python", "type": "programming"}, 
    {"skill": "sql", "type": "query_language"}, 
    {"skill": "r", "type":"programming"}
]'
::JSON AS skills_ison;


WITH json_raw_skill AS (
    SELECT
'[
    {"skill": "python", "type": "programming"}, 
    {"skill": "sql", "type": "query_language"}, 
    {"skill": "r", "type":"programming"}
]'::JSON AS skills_json
)
SELECT
    ARRAY_AGG(
        STRUCT_PACK(
            skill := json_extract_string(j.value, '$.skill'),
            type := json_extract_string(j.value, '$.type')
        )
    -- ORDER BY json_extract_string(j.value, '$.skill')
    ) AS skills
FROM json_raw_skill, 
json_each(skills_json) AS j;



-- Arrays - Final Example
-- Build a flat skill table for co-workers to access job titles, salary info, and skills in one table


CREATE OR REPLACE TEMPORARY TABLE jobs_skills_array AS 
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM 
    job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    salary_year_avg IS NOT NULL
GROUP BY 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;

-- From the perspective of a Data Analyst, analyze the median salary per skill
WITH flat_skill AS (
    SELECT 
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS skill
    FROM jobs_skills_array
)
SELECT
    skill,
    MEDIAN(salary_year_avg) AS median
FROM flat_skill
GROUP BY skill
ORDER BY median DESC;


-- Array of Structs - Final Example
-- Build a flat skill & type table for co-workers to access job titles, salary info, skills, and type in one table

CREATE OR REPLACE TEMPORARY TABLE jobs_skills_array_struct AS 
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill := sd.skills,
            type := sd.type
        )
    ) AS skill_type
FROM 
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    salary_year_avg IS NOT NULL
GROUP BY 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;

-- From the perspective of a Data Analyst, analyze the median salary per type of skill

WITH flat_skill AS (
    SELECT 
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skill_type).skill AS skills_n,
        UNNEST(skill_type).type AS skills_t
    FROM jobs_skills_array_struct
)
SELECT
    skills_t,
    MEDIAN(salary_year_avg) AS median
FROM flat_skill
GROUP BY skills_t
ORDER BY median DESC;

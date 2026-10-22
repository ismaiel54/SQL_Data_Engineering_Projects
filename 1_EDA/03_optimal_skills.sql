/*
Question: What are the most optimal skills for Data Engineers, balancing both demand and salary?

- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.

- Why?
    - This approach highlights skills that balance market demand and financial reward.
    - It weights core skills appropriately, rather than prioritising skills solely based on high salaries or popularity.
*/


SELECT
    sd.skills,
    ROUND(MEDIAN(salary_year_avg), 0) AS salary_median,
--    COUNT(jpf.*) AS skill_demand,
    ROUND(ln(COUNT(jpf.*)), 1) AS ln_skill_demand,
    ROUND((ln(COUNT(jpf.*)) * MEDIAN(salary_year_avg)) / 1_000_000, 2) AS optimal_skill
FROM
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE
    job_title_short = 'Data Engineer'
    AND
    job_work_from_home = TRUE
    AND
    salary_year_avg IS NOT NULL
GROUP BY
    sd.skills
HAVING
    COUNT(jpf.*) > 100
ORDER BY
    optimal_skill DESC
LIMIT 25;


/*
Here's a breakdown of the most optimal skills for Data Engineers, based on both high demand and high salaries:

Top Skills by Optimal Score:
- Terraform leads the list with a $184K median salary and 193 postings, resulting in the highest optimal score (0.97).
- Python and SQL dominate demand (over 1,100 postings each), with strong median salaries of $135K and $130K, respectively.
- AWS ($137K median), Spark ($140K median), and Airflow ($150K median) combine strong salaries with high demand.
- Kafka offers high compensation ($145K median) and solid demand (292 postings).
- Snowflake, Azure, and Databricks also rank highly, with median salaries between $128K and $136K.
- Kubernetes stands out with a $150.5K median salary, although demand is lower than for Python and SQL.

Key Takeaways:
- Terraform ranks highest using the optimal score, making it an attractive specialised skill.
- Python and SQL remain essential due to their exceptionally high demand and competitive salaries.
- Cloud technologies such as AWS and Azure are valuable for Data Engineers.
- Data orchestration and processing tools like Airflow, Spark, and Kafka offer a strong balance of salary and demand.
- Learning Python, SQL, cloud platforms, and modern data pipeline tools provides a strong foundation for Data Engineering.

Note:
- The optimal score is calculated using ln(skill demand) * median salary / 1,000,000.
- Logarithmic scaling reduces the influence of extremely high demand counts.
- Results only include remote Data Engineer postings with reported salaries and skills appearing in more than 100 postings.
- These results show associations between skills and advertised salaries, not that learning a skill directly causes higher pay.

┌────────────┬───────────────┬─────────────────┬───────────────┐
│   skills   │ salary_median │ ln_skill_demand │ optimal_skill │
│  varchar   │    double     │     double      │    double     │
├────────────┼───────────────┼─────────────────┼───────────────┤
│ terraform  │      184000.0 │             5.3 │          0.97 │
│ python     │      135000.0 │             7.0 │          0.95 │
│ sql        │      130000.0 │             7.0 │          0.91 │
│ aws        │      137320.0 │             6.7 │          0.91 │
│ airflow    │      150000.0 │             6.0 │          0.89 │
│ spark      │      140000.0 │             6.2 │          0.87 │
│ snowflake  │      135500.0 │             6.1 │          0.82 │
│ kafka      │      145000.0 │             5.7 │          0.82 │
│ azure      │      128000.0 │             6.2 │          0.79 │
│ java       │      135000.0 │             5.7 │          0.77 │
│ scala      │      137290.0 │             5.5 │          0.76 │
│ kubernetes │      150500.0 │             5.0 │          0.75 │
│ git        │      140000.0 │             5.3 │          0.75 │
│ databricks │      132750.0 │             5.6 │          0.74 │
│ redshift   │      130000.0 │             5.6 │          0.73 │
│ gcp        │      136000.0 │             5.3 │          0.72 │
│ hadoop     │      135000.0 │             5.3 │          0.71 │
│ nosql      │      134415.0 │             5.3 │          0.71 │
│ pyspark    │      140000.0 │             5.0 │           0.7 │
│ docker     │      135000.0 │             5.0 │          0.67 │
│ mongodb    │      135750.0 │             4.9 │          0.67 │
│ r          │      134775.0 │             4.9 │          0.66 │
│ go         │      140000.0 │             4.7 │          0.66 │
│ github     │      135000.0 │             4.8 │          0.65 │
│ bigquery   │      135000.0 │             4.8 │          0.65 │
└────────────┴───────────────┴─────────────────┴───────────────┘
  25 rows                                            4 columns
*/
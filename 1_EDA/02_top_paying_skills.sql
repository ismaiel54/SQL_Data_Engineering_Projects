/*
Question: What are the highest-paying skills for data engineers?

- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
- Why? Helps identify which skills command the highest compensation while also showing
  how common those skills are, providing a more complete picture for skill development priorities
*/

SELECT
    sd.skills,
    COUNT(jpf.*) AS skill_demand,
    ROUND(MEDIAN(salary_year_avg), 0) AS salary_median
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
GROUP BY
    sd.skills
HAVING
    COUNT(jpf.*) > 100
ORDER BY
    salary_median DESC
LIMIT 25;

/*
Highest-Paying Skills for Remote Data Engineers

Key Insights
- Rust is associated with the highest median salary at $210,000, appearing in 232 job postings. However, its relatively low demand suggests it is a more specialised skill.
- Golang and Terraform both have median salaries of $184,000, but Terraform has significantly greater demand (3,248 postings versus 912 for Golang).
- Spring and Neo4j are also associated with high salaries, with median salaries of $175,500 and $170,000 respectively, although both appear in fewer than 400 postings.
- Airflow and Kubernetes stand out for their strong demand, appearing in 9,996 and 4,202 postings respectively, while maintaining median salaries of approximately $150,000.
- Terraform offers one of the strongest combinations of salary and demand, with a $184,000 median salary and 3,248 postings.
- Specialised skills do not necessarily have the highest demand. Rust has the highest median salary but appears in far fewer postings than widely used tools such as Airflow, Kubernetes and Terraform.

Takeaway
While niche skills such as Rust and Golang are associated with higher salaries, Terraform, Kubernetes and Airflow appear particularly attractive for Data Engineers because they combine strong market demand with high median salaries.
For someone pursuing a career in Data Engineering, **developing expertise in widely demanded technologies such as Airflow, Terraform and Kubernetes may offer broader opportunities than focusing exclusively on the highest-paying niche skills.

┌────────────┬──────────────┬───────────────┐
│   skills   │ skill_demand │ salary_median │
│  varchar   │    int64     │    double     │
├────────────┼──────────────┼───────────────┤
│ rust       │          232 │      210000.0 │
│ golang     │          912 │      184000.0 │
│ terraform  │         3248 │      184000.0 │
│ spring     │          364 │      175500.0 │
│ neo4j      │          277 │      170000.0 │
│ gdpr       │          582 │      169616.0 │
│ zoom       │          127 │      168438.0 │
│ graphql    │          445 │      167500.0 │
│ mongo      │          265 │      162250.0 │
│ fastapi    │          204 │      157500.0 │
│ django     │          265 │      155000.0 │
│ bitbucket  │          478 │      155000.0 │
│ crystal    │          129 │      154224.0 │
│ c          │          444 │      151500.0 │
│ atlassian  │          249 │      151500.0 │
│ typescript │          388 │      151000.0 │
│ kubernetes │         4202 │      150500.0 │
│ ruby       │          736 │      150000.0 │
│ node       │          179 │      150000.0 │
│ airflow    │         9996 │      150000.0 │
│ css        │          262 │      150000.0 │
│ redis      │          605 │      149000.0 │
│ vmware     │          136 │      148798.0 │
│ ansible    │          475 │      148798.0 │
│ jupyter    │          400 │      147500.0 │
└────────────┴──────────────┴───────────────┘
  25 rows                         3 columns
*/
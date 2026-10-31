-- .read Lessons/1.9/1.24/1.24_priority_roles.sql
/*
SELECT *
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';
*/

CREATE OR REPLACE TABLE staging.priority_roles (
    role_id INTEGER PRIMARY KEY,
    role_name VARCHAR,
    priority_lvl INTEGER
);

INSERT INTO staging.priority_roles (role_id, role_name, priority_lvl)
VALUES
    (1, 'Data Engineer',        2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer',    3),
    (4, 'Data Scientist',       1);

/*
UPDATE staging.priority_roles
SET priority_lvl = 1
WHERE role_id = 3;
*/

SELECT *
FROM staging.priority_roles;
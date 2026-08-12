CREATE OR REPLACE VIEW ANAPLAN.MD_ACCOUNT_CLOUD AS
WITH account_cloud_src AS (
    SELECT
        ac,
        ac_name,
        f5,
        f4,
        f3,
        f2,
        f1,
        in_use,
        consolidation
    FROM M3SKY.FPM_ACCOUNT_STRUCTURE
    WHERE ac < '9999999'
)
SELECT
    CAST(ac          AS VARCHAR(10))  AS account,
    CAST(ac_name     AS VARCHAR(108)) AS account_name,
    CAST(SUBSTRING(f5,3)  AS VARCHAR(108)) AS l1_name,
    CAST(SUBSTRING(f4,4)  AS VARCHAR(108)) AS l2_name,
    CAST(SUBSTRING(f3,5)  AS VARCHAR(108)) AS l3_name,
    CAST(SUBSTRING(f2,6)  AS VARCHAR(108)) AS l4_name,
    CAST(SUBSTRING(f1,8)  AS VARCHAR(108)) AS l5_name,
    CAST(SUBSTRING(f5,1,1) AS VARCHAR(10)) AS l1_code,
    CAST(SUBSTRING(f4,1,2) AS VARCHAR(10)) AS l2_code,
    CAST(SUBSTRING(f3,1,3) AS VARCHAR(10)) AS l3_code,
    CAST(SUBSTRING(f2,1,4) AS VARCHAR(10)) AS l4_code,
    CAST(SUBSTRING(f1,1,6) AS VARCHAR(10)) AS l5_code,
    CAST(in_use      AS VARCHAR(10))  AS a1_used,
    CAST(consolidation AS VARCHAR(108)) AS a2_consolidation,
    CAST(' '         AS VARCHAR(108)) AS a3_attr3,
    CAST(' '         AS VARCHAR(108)) AS a3_attr4,
    CAST(' '         AS VARCHAR(108)) AS a3_attr5
FROM account_cloud_src
ORDER BY ac;

COMMENT ON VIEW ANAPLAN.MD_ACCOUNT_CLOUD IS
    'Cloud account hierarchy from M3SKY.FPM_ACCOUNT_STRUCTURE (Division 400 M3SKY schema).';
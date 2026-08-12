CREATE OR REPLACE VIEW ANAPLAN.MD_COSTCENTER AS
WITH costcenter_src AS (
    SELECT
        CAST(divi        AS VARCHAR(10))  AS l1_division,
        CAST(cc_name     AS VARCHAR(108)) AS l2_costcenter,
        CAST(cc          AS VARCHAR(108)) AS l2_code,
        CAST(SUBSTRING(f2_shortname, 4)    AS VARCHAR(108)) AS a1_function,
        CAST(SUBSTRING(f2_shortname, 1, 3) AS VARCHAR(10))  AS a1_code,
        CAST(f1_name     AS VARCHAR(108)) AS a2_subfunction,
        CAST(f1          AS VARCHAR(10))  AS a2_code,
        CAST(in_use      AS VARCHAR(108)) AS a3_attr,
        CAST(' '         AS VARCHAR(10))  AS a3_code,
        CAST(' '         AS VARCHAR(108)) AS a4_attr,
        CAST(' '         AS VARCHAR(10))  AS a4_code
    FROM bousr.fpm_costcenter_structure
    WHERE divi || '-' || cc NOT LIKE '200-9%'
      AND divi || '-' || cc NOT LIKE '700-9%'
      AND divi || '-' || cc NOT LIKE '707-9%'
      AND yea4::TEXT = TO_CHAR(CURRENT_DATE,'YYYY')
      AND divi NOT IN ('800','400')
)
SELECT *
FROM costcenter_src

UNION ALL

SELECT L1_DIVISION, L2_COSTCENTER, L2_CODE, A1_FUNCTION, A1_CODE,
       A2_SUBFUNCTION, A2_CODE, A3_ATTR, A3_CODE, A4_ATTR, A4_CODE
FROM LIDSKOE.MD_COSTCENTER
WHERE L1_DIVISION = '800'

UNION ALL

SELECT L1_DIVISION, L2_COSTCENTER, L2_CODE, A1_FUNCTION, A1_CODE,
       A2_SUBFUNCTION, A2_CODE, A3_ATTR, A3_CODE, A4_ATTR, A4_CODE
FROM M3SKY.MD_COSTCENTER
WHERE L1_DIVISION = '400';

COMMENT ON VIEW ANAPLAN.MD_COSTCENTER IS
    'Cost centre hierarchy. SubStr 0-based → 1-based; yea4 integer cast; DB link → compat table.';
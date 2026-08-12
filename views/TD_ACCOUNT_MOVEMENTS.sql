CREATE OR REPLACE VIEW ANAPLAN.TD_ACCOUNT_MOVEMENTS AS
WITH
    CTE_GL_SOURCE AS (
        SELECT *
        FROM bousr.fpm_gl2_hst
        UNION ALL
        SELECT *
        FROM bousr.fpm_gl2_extra
    ),
    CTE_DIM3 AS (
        SELECT DISTINCT
            SUBSTRING(eaaitm, 1, 3) AS dim3
        FROM MVXJDTA.FCHACC
        WHERE eacono = 100
          AND eadivi = ' '
          AND eaaitp = 3
          AND eaaitm BETWEEN 'A' AND 'Z'
    ),
    CTE_ACCOUNT_MOVEMENTS AS (
        SELECT
            a.acperi AS period,
            a.divi AS division,
            a.ait1 AS account_code,
            SUBSTRING(a.ait3, 1, 3) AS dim3_code,
            a.ait4 AS counterpart_code,
            SUM(a.acam) AS amount_loc
        FROM CTE_GL_SOURCE a
        INNER JOIN CTE_DIM3 mov
            ON mov.dim3 = SUBSTRING(a.ait3, 1, 3)
        WHERE a.ait1 BETWEEN '1000000' AND '5999999'
          AND a.divi NOT IN ('800','400')
          AND a.acperi >= '202201'
        GROUP BY
            a.acperi,
            a.divi,
            a.ait1,
            SUBSTRING(a.ait3, 1, 3),
            a.ait4
    )
SELECT
    period,
    division,
    account_code,
    dim3_code,
    counterpart_code,
    amount_loc
FROM CTE_ACCOUNT_MOVEMENTS

UNION ALL

SELECT
    PERIOD,
    DIVISION,
    ACCOUNT_CODE,
    DIM3_CODE,
    COUNTERPART_CODE,
    AMOUNT_LOC
FROM LIDSKOE.TD_ACCOUNT_MOVEMENTS
WHERE DIVISION = '800'

UNION ALL

SELECT
    PERIOD,
    DIVISION,
    ACCOUNT_CODE,
    DIM3_CODE,
    COUNTERPART_CODE,
    AMOUNT_LOC
FROM M3SKY.TD_ACCOUNT_MOVEMENTS
WHERE DIVISION = '400';
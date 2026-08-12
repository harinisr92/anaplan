CREATE OR REPLACE VIEW ANAPLAN.TD_GL_SUM_BACKUP_20220616 AS

WITH CTE_PL_ACCOUNTS AS (
    SELECT
        CAST(divi   AS VARCHAR(10)) AS division,
        CAST(acperi AS VARCHAR(10)) AS period,
        CAST(ait1   AS VARCHAR(30)) AS account_code,
        CAST(ait2   AS VARCHAR(30)) AS costcenter_code,
        acam                        AS amount_loc,
        CAST(ait3   AS VARCHAR(30)) AS dim3_code,
        CAST(ait4   AS VARCHAR(30)) AS counterpart_code,
        CAST(' '    AS VARCHAR(30)) AS ad_dim1,
        CAST(' '    AS VARCHAR(30)) AS ad_dim2,
        CAST(' '    AS VARCHAR(30)) AS ad_dim3
    FROM bousr.fpm_gl2_hst
    WHERE datatype = 'ACT'
      AND acperi >= '202001'
      AND ait1 BETWEEN '8000000' AND '9999998'
),
CTE_PL_ACCOUNTS_SUMMED AS (
    SELECT
        division, period, account_code, costcenter_code,
        SUM(amount_loc) AS amount_loc,
        dim3_code, counterpart_code, ad_dim1, ad_dim2, ad_dim3
    FROM CTE_PL_ACCOUNTS
    GROUP BY division, period, account_code, costcenter_code,
             dim3_code, counterpart_code, ad_dim1, ad_dim2, ad_dim3
),

CTE_BS_GROUPING_KEYS AS (
    SELECT divi, ait1, ait3,
           CASE WHEN ait1 LIKE '%9' THEN ait4 ELSE ' ' END AS ait4
    FROM bousr.fpm_gl2_hst
    WHERE datatype = 'ACT'
      AND ait1 BETWEEN '1000000' AND '7999999'
    GROUP BY divi, ait1, ait3, CASE WHEN ait1 LIKE '%9' THEN ait4 ELSE ' ' END
    HAVING COUNT(1) > 0
),
CTE_BS_PERIODS AS (
    SELECT DISTINCT SUBSTRING(cdymd8::TEXT,1,6) AS period
    FROM MVXJDTA.CSYCAL
    WHERE SUBSTRING(cdymd8::TEXT,1,6) BETWEEN '201712' AND TO_CHAR(CURRENT_DATE,'YYYYMM')
),
CTE_BS_GRID AS (
    SELECT ac.divi, per.period, ac.ait1, ac.ait3, ac.ait4
    FROM CTE_BS_GROUPING_KEYS ac
    RIGHT JOIN CTE_BS_PERIODS per ON 1=1
),
CTE_BS_ACTUALS AS (
    SELECT
        divi, ait1, ait3, acperi,
        CASE WHEN ait1 LIKE '%9' THEN ait4 ELSE ' ' END AS ait4,
        SUM(acam) AS acam
    FROM bousr.fpm_gl2_hst
    WHERE datatype = 'ACT'
    GROUP BY divi, ait1, ait3, CASE WHEN ait1 LIKE '%9' THEN ait4 ELSE ' ' END, acperi
),
CTE_BS_CUMULATIVE AS (
    SELECT
        f.divi, f.period, f.ait1, f.ait3, f.ait4,
        COALESCE(dta.acam, 0) AS periodsum,
        SUM(COALESCE(dta.acam, 0)) OVER (
            PARTITION BY f.divi, f.ait1, f.ait3, f.ait4
            ORDER BY f.period
            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumul
    FROM CTE_BS_GRID f
    LEFT JOIN CTE_BS_ACTUALS dta
           ON f.divi = dta.divi AND f.ait1 = dta.ait1 AND f.ait3 = dta.ait3
          AND f.ait4 = dta.ait4 AND dta.acperi = f.period
),
CTE_BS_ACCOUNTS AS (
    SELECT
        CAST(divi     AS VARCHAR(10)) AS division,
        CAST(period   AS VARCHAR(10)) AS period,
        CAST(ait1     AS VARCHAR(30)) AS account_code,
        CAST('BS999'  AS VARCHAR(30)) AS costcenter_code,
        cumul                          AS amount_loc,
        CAST(ait3     AS VARCHAR(30)) AS dim3_code,
        CAST(ait4     AS VARCHAR(30)) AS counterpart_code,
        CAST(' '      AS VARCHAR(30)) AS ad_dim1,
        CAST(' '      AS VARCHAR(30)) AS ad_dim2,
        CAST(' '      AS VARCHAR(30)) AS ad_dim3
    FROM CTE_BS_CUMULATIVE
    WHERE cumul <> 0 AND period >= '202001'
)

SELECT * FROM CTE_PL_ACCOUNTS_SUMMED
UNION ALL
SELECT * FROM CTE_BS_ACCOUNTS;

COMMENT ON VIEW ANAPLAN.TD_GL_SUM_BACKUP_20220616 IS
    'P&L (period actuals) + BS (cumulative running total) GL amounts from bousr.fpm_gl2_hst. Historical backup view from 2022-06-16 — confirm with the business whether this snapshot is still needed before relying on it going forward.';
CREATE OR REPLACE VIEW ANAPLAN.TD_GL_SUM_FULL AS
WITH
CTE_AD_COUNTERUNITS AS (
    SELECT DISTINCT divi AS division, cp AS counterpart, f1 AS counterunit
    FROM bousr.fpm_consolidation_structure
    WHERE f2 = '9'
),
CTE_MD_COSTCENTER AS (
    SELECT CAST(divi AS VARCHAR(10)) AS l1_division, CAST(cc AS VARCHAR(108)) AS l2_code
    FROM bousr.fpm_costcenter_structure
    WHERE yea4::TEXT = TO_CHAR(CURRENT_DATE,'YYYY')
      AND divi NOT IN ('800','400')
    UNION ALL
    SELECT L1_DIVISION, L2_CODE FROM LIDSKOE.MD_COSTCENTER WHERE L1_DIVISION = '800'
    UNION ALL
    SELECT L1_DIVISION, L2_CODE FROM M3SKY.MD_COSTCENTER WHERE L1_DIVISION = '400'
),
GL_BASE AS (
    SELECT
        CAST(divi   AS VARCHAR(10))  AS division,
        CAST(acperi AS VARCHAR(10))  AS period,
        CAST(ait1   AS VARCHAR(30))  AS account_code,
        CAST(CASE WHEN cc.l1_division IS NULL THEN '49099' ELSE ait2 END AS VARCHAR(30)) AS costcenter_code,
        acam AS amount_loc,
        CAST(ait3   AS VARCHAR(30))  AS dim3_code,
        CAST(COALESCE(cu.counterunit, ' ') AS VARCHAR(30)) AS counterpart_code,
        CAST(' '    AS VARCHAR(30))  AS ad_dim1,
        CAST(' '    AS VARCHAR(30))  AS ad_dim2,
        CAST(' '    AS VARCHAR(30))  AS ad_dim3
    FROM bousr.fpm_gl2_hst
    LEFT JOIN CTE_AD_COUNTERUNITS cu ON divi = cu.division AND ait4 = cu.counterpart
    LEFT JOIN CTE_MD_COSTCENTER   cc ON cc.l1_division = divi AND cc.l2_code = ait2
    WHERE datatype = 'ACT'
      AND acperi >= '202001' AND ait1 BETWEEN '8000000' AND '9999998'

    UNION ALL

    SELECT
        CAST(divi   AS VARCHAR(10))  AS division,
        CAST(acperi AS VARCHAR(10))  AS period,
        CAST(ait1   AS VARCHAR(30))  AS account_code,
        CAST(CASE WHEN cc.l1_division IS NULL THEN '49099' ELSE ait2 END AS VARCHAR(30)) AS costcenter_code,
        acam AS amount_loc,
        CAST(ait3   AS VARCHAR(30))  AS dim3_code,
        CAST(COALESCE(cu.counterunit, ' ') AS VARCHAR(30)) AS counterpart_code,
        CAST(' '    AS VARCHAR(30))  AS ad_dim1,
        CAST(' '    AS VARCHAR(30))  AS ad_dim2,
        CAST(' '    AS VARCHAR(30))  AS ad_dim3
    FROM bousr.fpm_gl2_extra
    LEFT JOIN CTE_AD_COUNTERUNITS cu ON divi = cu.division AND ait4 = cu.counterpart
    LEFT JOIN CTE_MD_COSTCENTER   cc ON cc.l1_division = divi AND cc.l2_code = ait2
),
GL_PL_SUMMARY AS (
    SELECT division, period, account_code, costcenter_code,
           SUM(amount_loc) AS amount_loc,
           dim3_code, counterpart_code, ad_dim1, ad_dim2, ad_dim3
    FROM GL_BASE
    GROUP BY division, period, account_code, costcenter_code,
             dim3_code, counterpart_code, ad_dim1, ad_dim2, ad_dim3
),
-- Balance sheet accounts (cumulative running total)
PERIOD_SPINE AS (
    SELECT DISTINCT SUBSTRING(cdymd8::TEXT, 1, 6) AS period
    FROM MVXJDTA.CSYCAL
    WHERE SUBSTRING(cdymd8::TEXT, 1, 6) BETWEEN '201712' AND TO_CHAR(CURRENT_DATE,'YYYYMM')
),
BS_ACCOUNTS AS (
    SELECT divi, ait1, ait3,
           COALESCE(cu.counterunit, ' ') AS ait4
    FROM bousr.fpm_gl2_hst
    LEFT JOIN CTE_AD_COUNTERUNITS cu ON divi = cu.division AND ait4 = cu.counterpart
    WHERE datatype = 'ACT' AND ait1 BETWEEN '1000000' AND '7999999'
    GROUP BY divi, ait1, ait3, cu.counterunit
    HAVING COUNT(1) > 0
),
BS_MOVEMENTS AS (
    SELECT a.divi, a.ait1, a.ait3, COALESCE(cu.counterunit,' ') AS ait4, a.acperi, SUM(a.acam) AS acam
    FROM bousr.fpm_gl2_hst a
    LEFT JOIN CTE_AD_COUNTERUNITS cu ON divi = cu.division AND ait4 = cu.counterpart
    WHERE datatype = 'ACT'
    GROUP BY a.divi, a.ait1, a.ait3, cu.counterunit, a.acperi
),
BS_CUMULATIVE AS (
    SELECT
        f.divi, per.period, f.ait1, f.ait3, f.ait4,
        SUM(COALESCE(dta.acam, 0))
            OVER (PARTITION BY f.divi, f.ait1, f.ait3, f.ait4
                  ORDER BY per.period
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumul
    FROM BS_ACCOUNTS f
    CROSS JOIN PERIOD_SPINE per
    LEFT JOIN BS_MOVEMENTS dta
           ON f.divi = dta.divi AND f.ait1 = dta.ait1
          AND f.ait3 = dta.ait3 AND f.ait4 = dta.ait4
          AND dta.acperi = per.period
)
SELECT division, period, account_code, costcenter_code, amount_loc,
       dim3_code, counterpart_code, ad_dim1, ad_dim2, ad_dim3
FROM GL_PL_SUMMARY

UNION ALL

SELECT
    CAST(divi  AS VARCHAR(10))  AS division,
    CAST(period AS VARCHAR(10)) AS period,
    CAST(ait1  AS VARCHAR(30))  AS account_code,
    CAST('BS999' AS VARCHAR(30)) AS costcenter_code,
    cumul AS amount_loc,
    CAST(ait3  AS VARCHAR(30))  AS dim3_code,
    CAST(ait4  AS VARCHAR(30))  AS counterpart_code,
    CAST(' '   AS VARCHAR(30))  AS ad_dim1,
    CAST(' '   AS VARCHAR(30))  AS ad_dim2,
    CAST(' '   AS VARCHAR(30))  AS ad_dim3
FROM BS_CUMULATIVE
WHERE cumul <> 0 AND period >= '202001';

COMMENT ON VIEW ANAPLAN.TD_GL_SUM_FULL IS
    'Full GL summary: P&L periods + cumulative BS. AD_COUNTERUNITS + MD_COSTCENTER inlined as CTEs. Uses MVXJDTA for calendar. bousr sources preserved. Schema compat unions point to LIDSKOE/M3SKY.';
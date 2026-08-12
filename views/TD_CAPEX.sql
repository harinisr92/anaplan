CREATE OR REPLACE VIEW ANAPLAN.TD_CAPEX AS

WITH

/* ==========================================================
   GL Source
   ========================================================== */
CTE_FGLEDG AS (

    SELECT
        EGDIVI,
        EGACDT,
        EGAIT1,
        EGAIT3,
        EGAIT4,
        EGAIT5,
        EGAIT6,
        EGACAM

    FROM MVXJDTA.FGLEDG

    WHERE EGCONO = 100
      AND EGAIT1 BETWEEN '1000000' AND '1399999'
),

/* ==========================================================
   CAPEX Classification
   ========================================================== */
CTE_CAPEX_MAPPING AS (

    SELECT

        CAST(EGDIVI AS VARCHAR(10))      AS division,

        SUBSTRING(EGACDT::TEXT, 1, 6)    AS period,

        CAST(EGAIT1 AS VARCHAR(30))      AS account_code,

        CAST(
            CASE
                WHEN EGACDT < 20260101 THEN EGAIT5
                WHEN EGDIVI IN ('100','300') THEN EGAIT5
                ELSE EGAIT6
            END
        AS VARCHAR(30))                  AS investment_code,

        EGACAM

    FROM CTE_FGLEDG

    WHERE
        CASE
            WHEN EGDIVI = '800'
            THEN EGAIT4
            ELSE EGAIT3
        END LIKE 'FAC%'
),

/* ==========================================================
   Main CAPEX Aggregation
   ========================================================== */
CTE_CAPEX AS (

    SELECT

        division,
        period,
        account_code,
        investment_code,

        SUM(EGACAM) AS amount_loc

    FROM CTE_CAPEX_MAPPING

    WHERE investment_code <> ' '
      AND division NOT IN ('800','400')
      AND period BETWEEN
            TO_CHAR(CURRENT_DATE - INTERVAL '3 months','YYYYMM')
        AND TO_CHAR(CURRENT_DATE,'YYYYMM')

    GROUP BY
        division,
        period,
        account_code,
        investment_code

    HAVING SUM(EGACAM) <> 0
)

/* ==========================================================
   Final Output
   ========================================================== */

SELECT
    division,
    period,
    account_code,
    investment_code,
    amount_loc
FROM CTE_CAPEX

UNION ALL

SELECT
    division,
    period,
    account_code,
    investment_code,
    amount_loc
FROM LIDSKOE.TD_CAPEX
WHERE division = '800'

UNION ALL

SELECT
    division,
    period,
    account_code,
    investment_code,
    amount_loc
FROM M3SKY.TD_CAPEX
WHERE division = '400';
CREATE OR REPLACE VIEW ANAPLAN.TD_COGS_OH_COSTING AS

WITH

/* ==========================================================
   Costing Source
   ========================================================== */
CTE_MCCOMA AS (
    SELECT
        KPFACI,
        KPITNO,
        KPPCDT,
        KPPCTP,
        KPCB02,
        KPCB03,
        KPCB04,
        KPCB05,
        KPCB06,
        KPCB07,
        KPCB08,
        KPCE01,
        KPCE02,
        KPCE03,
        KPCE04,
        KPCE05,
        KPCE06,
        KPCE07,
        KPCE08
    FROM MVXJDTA.MCCOMA
    WHERE KPCONO = 100
      AND KPSTRT = '100'
),

/* ==========================================================
   UNPIVOT replacement (VALUES)
   ========================================================== */
CTE_COMPONENTS AS (
    SELECT
        KPFACI AS DIVISION,
        KPITNO AS ITEM_CODE,
        KPPCDT AS COSTING_DATE,
        KPPCTP AS COSTING_TYPE,
        UPV.COMPONENT,
        UPV.RATE
    FROM CTE_MCCOMA
    CROSS JOIN LATERAL (
        VALUES
            ('B02', KPCB02),
            ('B03', KPCB03),
            ('B04', KPCB04),
            ('B05', KPCB05),
            ('B06', KPCB06),
            ('B07', KPCB07),
            ('B08', KPCB08),
            ('E01', KPCE01),
            ('E02', KPCE02),
            ('E03', KPCE03),
            ('E04', KPCE04),
            ('E05', KPCE05),
            ('E06', KPCE06),
            ('E07', KPCE07),
            ('E08', KPCE08)
    ) AS UPV(COMPONENT, RATE)
),

/* ==========================================================
   Business Rule Filtering
   ========================================================== */
CTE_COSTING_FILTERED AS (
    SELECT *
    FROM CTE_COMPONENTS
    WHERE (
            COSTING_TYPE::TEXT = '8'
            AND COSTING_DATE > 20230901
        )
        OR (
            COSTING_TYPE::TEXT = '3'
            AND SUBSTRING(COSTING_DATE::TEXT, 1, 6) >= TO_CHAR(CURRENT_DATE - 1, 'YYYYMM')
        )
),

/* ==========================================================
   Cost Normalization
   ========================================================== */
CTE_NORMALIZED_RATES AS (
    SELECT
        CASE WHEN COSTING_TYPE::TEXT = '8' THEN 'BUD' ELSE 'ACT' END AS COSTINGTYPE,
        DIVISION,
        ITEM_CODE,
        COSTING_DATE,
        COMPONENT,
        CASE
            WHEN MIT.MMVOL3 = 0 THEN RATE
            ELSE ROUND(RATE::NUMERIC / MIT.MMVOL3, 4)
        END AS RATE
    FROM CTE_COSTING_FILTERED F
    INNER JOIN MVXJDTA.MITMAS MIT
        ON MIT.MMITNO = F.ITEM_CODE
    WHERE RATE <> 0
      AND DIVISION NOT IN ('800','400')
)

/* ==========================================================
   Final Output
   ========================================================== */

SELECT
    COSTINGTYPE,
    DIVISION,
    ITEM_CODE,
    COSTING_DATE,
    COMPONENT,
    RATE
FROM CTE_NORMALIZED_RATES

UNION ALL

SELECT
    COSTINGTYPE,
    DIVISION,
    ITEM_CODE,
    COSTING_DATE,
    COMPONENT,
    RATE
FROM LIDSKOE.TD_COGS_OH_COSTING
WHERE DIVISION = '800'

UNION ALL

SELECT
    COSTINGTYPE,
    DIVISION,
    ITEM_CODE,
    COSTING_DATE,
    COMPONENT,
    RATE
FROM M3SKY.TD_COGS_OH_COSTING
WHERE DIVISION = '400';
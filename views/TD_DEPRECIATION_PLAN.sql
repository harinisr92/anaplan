CREATE OR REPLACE VIEW ANAPLAN.TD_DEPRECIATION_PLAN AS

WITH CTE_FIXED_ASSETS AS (

    SELECT
        FFASMA.FMDIVI AS division,

        CASE FFASMA.FMFAST
            WHEN 1 THEN 'Normal'
            WHEN 5 THEN 'Preliminary'
            WHEN 8 THEN 'Fully depreciated'
            WHEN 9 THEN 'Sold_Disposed'
            ELSE 'Other'
        END AS status,

        FFASMA.FMFATP AS fa_typeid,

        FATP.CTTX40 AS fa_type,

        FFASMA.FMAIT2 AS costcenter,

        CASE DEP.FDDPMD
            WHEN 0 THEN 'Not depreciated'
            WHEN 1 THEN 'Linear'
            WHEN 2 THEN 'Declining'
            ELSE 'Other'
        END AS deprmethod,

        FFAHIS.FHVATP AS transactionid,

        FFAHIS.FHVPER AS period,

        FFAHIS.FHFAVA AS amount

    FROM MVXJDTA.FFASMA FFASMA

    LEFT JOIN MVXJDTA.FFAHIS FFAHIS
           ON FFAHIS.FHDIVI = FFASMA.FMDIVI
          AND FFAHIS.FHASID = FFASMA.FMASID
          AND FFAHIS.FHSBNO = FFASMA.FMSBNO

    LEFT JOIN MVXJDTA.CSYTAB FATP
           ON FATP.CTDIVI = FFASMA.FMDIVI
          AND FATP.CTSTKY = FFASMA.FMFATP::VARCHAR
          AND FATP.CTSTCO = 'FATP'

    LEFT JOIN MVXJDTA.FFASDM DEP
           ON DEP.FDDIVI = FFASMA.FMDIVI
          AND DEP.FDDASID = FFASMA.FMASID
          AND DEP.FDDSBNO = FFASMA.FMSBNO

    WHERE FFAHIS.FHDIVI <> '800'
)

SELECT
    CAST(division AS VARCHAR(108))   AS division,
    CAST(period AS VARCHAR(108))     AS period,
    CAST(fa_typeid AS VARCHAR(108))  AS fa_typeid,
    CAST(fa_type AS VARCHAR(108))    AS fa_type,
    CAST(costcenter AS VARCHAR(108)) AS costcenter,
    ROUND(SUM(amount)::NUMERIC,2)    AS amount,
    CAST(0 AS NUMERIC) AS ext_m1,
    CAST(0 AS NUMERIC) AS ext_m2,
    CAST(0 AS NUMERIC) AS ext_m3,
    CAST(NULL AS VARCHAR(108)) AS attr1,
    CAST(NULL AS VARCHAR(108)) AS attr2,
    CAST(NULL AS VARCHAR(108)) AS attr3
FROM CTE_FIXED_ASSETS
WHERE transactionid = '30'
  AND deprmethod <> 'Not depreciated'
  AND status = 'Normal'
  AND period >= '202301'
  AND division NOT IN ('400')
GROUP BY
    division,
    costcenter,
    period,
    fa_typeid,
    fa_type

UNION ALL

SELECT
    DIVISION,
    PERIOD,
    FA_TYPEID,
    FA_TYPE,
    COSTCENTER,
    AMOUNT,
    EXT_M1,
    EXT_M2,
    EXT_M3,
    ATTR1,
    ATTR2,
    ATTR3
FROM M3SKY.TD_DEPRECIATION_PLAN;
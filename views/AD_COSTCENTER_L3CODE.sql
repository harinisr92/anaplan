CREATE OR REPLACE VIEW ANAPLAN.AD_COSTCENTER_L3CODE AS
WITH opla AS (
    SELECT DISTINCT eaaitm
    FROM MVXJDTA.FCHACC
    WHERE eacono = 100
      AND eadivi IN ('100','300')
      AND eaaitp = '2'
      AND earesp = 'PLANNING'
)
SELECT DISTINCT
    cd.okdivi AS division,
    TRIM(SUBSTRING(
        CASE WHEN opla.eaaitm IS NULL
             THEN '9999 OTHER'
             ELSE opla.eaaitm || ' ' || COALESCE(ea1.cttx40, '')
        END,
        1,
        5
    )) AS costcenter,
    CASE WHEN opla.eaaitm IS NULL
         THEN '9999'
         ELSE TRIM(cu.okacrf)
    END AS l3_code
FROM MVXJDTA.CCUDIV cd
INNER JOIN MVXJDTA.OCUSMA cu
        ON cu.okcono = 100
       AND cu.okcuno = cd.okcuno
LEFT JOIN opla
       ON TRIM(cu.okacrf) = TRIM(opla.eaaitm)
LEFT JOIN MVXJDTA.CSYTAB ea1
       ON ea1.ctcono = 100
      AND ea1.ctstco = 'ACRF'
      AND ea1.ctstky = TRIM(cu.okacrf)
      AND ea1.ctdivi = ' '
WHERE cd.okdivi IN ('100','300')
  AND cd.okcuno != ' ';

COMMENT ON VIEW ANAPLAN.AD_COSTCENTER_L3CODE IS
    'AD-layer costcenter/l3_code lookup for divisions 100/300. Reads MVXJDTA directly; FCHACC filtering moved into a CTE.';
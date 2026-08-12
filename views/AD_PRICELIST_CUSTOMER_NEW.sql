CREATE OR REPLACE VIEW ANAPLAN.AD_PRICELIST_CUSTOMER_NEW AS
WITH cte_costcenter_l3 AS (
    SELECT DISTINCT
        cd.okdivi AS division,
        TRIM(SUBSTRING(
            CASE WHEN opla.eaaitm IS NULL THEN '9999 OTHER'
                 ELSE opla.eaaitm || ' ' || COALESCE(ea1.cttx40, '')
            END, 1, 5
        )) AS costcenter,
        CASE WHEN opla.eaaitm IS NULL THEN '9999' ELSE TRIM(cu.okacrf) END AS l3_code
    FROM MVXJDTA.CCUDIV cd
    INNER JOIN MVXJDTA.OCUSMA cu
            ON cu.okcono = 100
           AND cu.okcuno = cd.okcuno
    LEFT JOIN (
        SELECT eaaitm
        FROM MVXJDTA.FCHACC
        WHERE eacono = 100
          AND eadivi IN ('100','300')
          AND eaaitp = '2'
          AND earesp = 'PLANNING'
    ) opla
           ON TRIM(cu.okacrf) = TRIM(opla.eaaitm)
    LEFT JOIN MVXJDTA.CSYTAB ea1
           ON ea1.ctcono = 100
          AND ea1.ctstco = 'ACRF'
          AND ea1.ctstky = TRIM(cu.okacrf)
          AND ea1.ctdivi = ' '
    WHERE cd.okdivi IN ('100','300')
      AND cd.okcuno <> ' '
)
SELECT
    SUBSTRING(od.odprrf, 1, 1) || '00'         AS division,
    od.odcuno                                   AS customer1,
    'L2'                                        AS customer2,
    'L3'                                        AS customer3,
    od.odprrf || '-' || od.odcuno               AS pricelist_ref,
    od.oditno                                   AS itemcode,
    od.odsapr                                   AS price,
    20230101                                    AS startdate,
    20300629                                    AS enddate
FROM MVXJDTA.OPRBAS od
INNER JOIN (
    SELECT odprrf AS prrf,
           odcuno AS cuno,
           MAX(odfvdt) AS fvdt,
           odcono AS cono
    FROM MVXJDTA.OPRBAS
    WHERE odcuno <> ' '
      AND odlvdt >= TO_CHAR(CURRENT_DATE,'YYYYMMDD')::integer
      AND odfvdt <= TO_CHAR(CURRENT_DATE,'YYYYMMDD')::integer
    GROUP BY odprrf, odcuno, odcono
) temp
        ON temp.cuno = od.odcuno
       AND temp.cono = od.odcono
       AND temp.prrf = od.odprrf
       AND od.odfvdt = temp.fvdt
INNER JOIN MVXJDTA.OCUSMA
        ON okcono = 100
       AND okcuno = od.odcuno
WHERE od.odcono = 100
  AND okcucl BETWEEN '900' AND '910'
  AND SUBSTRING(od.odprrf, 1, 1) IN ('6','7','4')
  AND od.odprrf NOT IN ('7C1','6R1','2A0')

UNION ALL

SELECT
    CASE WHEN SUBSTRING(od.odprrf,1,1) = '2' THEN '1'
         ELSE SUBSTRING(od.odprrf,1,1)
    END || '00'                                 AS division,
    'L1'                                        AS customer1,
    'L2'                                        AS customer2,
    cc.l3_code                                  AS customer3,
    od.odprrf                                   AS pricelist_ref,
    od.oditno                                   AS itemcode,
    od.odsapr                                   AS price,
    od.odfvdt                                   AS startdate,
    oj.ojlvdt                                   AS enddate
FROM MVXJDTA.OPRBAS od
INNER JOIN MVXJDTA.MBMTRD td
        ON td.tdcono = od.odcono
       AND td.tddivi = '100'
       AND td.tdidtr = 440
       AND od.odprrf = td.tdmbmd
INNER JOIN MVXJDTA.OPRICH oj
        ON oj.ojcono = od.odcono
       AND oj.ojprrf = od.odprrf
       AND oj.ojcuno = od.odcuno
       AND oj.ojcmno = od.odcmno
       AND oj.ojcucd = od.odcucd
       AND oj.ojfvdt = od.odfvdt
INNER JOIN cte_costcenter_l3 cc
        ON cc.division = (CASE WHEN SUBSTRING(od.odprrf,1,1) = '2' THEN '1' ELSE SUBSTRING(od.odprrf,1,1) END) || '00'
       AND cc.costcenter = td.tdmvxd
WHERE od.odcono = 100
  AND od.odfvdt >= 20230101
  AND oj.ojcucd = 'EUR'
  AND oj.ojcuno = ' ';

COMMENT ON VIEW ANAPLAN.AD_PRICELIST_CUSTOMER_NEW IS
    'New customer pricelist assignments. Same structure as AD_PRICELIST_CUSTOMER but tddivi = 100 only; AD_COSTCENTER_L3CODE logic inlined as CTE.';
CREATE OR REPLACE VIEW ANAPLAN.MD_PRICELIST AS
WITH
cte_cc AS (
    SELECT DISTINCT
        cd.okdivi AS division,
        TRIM(
            SUBSTRING(
                CASE
                    WHEN opla.eaaitm IS NULL THEN '9999 OTHER'
                    ELSE opla.eaaitm || ' ' || COALESCE(ea1.cttx40, '')
                END,
                1,
                5
            )
        ) AS costcenter,
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
),
cte_pricelist_customer AS (
    SELECT
        SUBSTRING(od.odprrf, 1, 1) || '00' AS division,
        'L1' AS customer1,
        'L2' AS customer2,
        cc.l3_code AS customer3,
        od.odprrf AS pricelist_ref,
        od.oditno AS itemcode,
        od.odsapr AS price,
        od.odfvdt AS startdate,
        oj.ojlvdt AS enddate
    FROM MVXJDTA.OPRBAS od
    INNER JOIN MVXJDTA.MBMTRD td
        ON td.tdcono = od.odcono
       AND td.tddivi IN ('100','300')
       AND td.tdidtr = 440
       AND od.odprrf = td.tdmbmd
    INNER JOIN MVXJDTA.OPRICH oj
        ON oj.ojcono = od.odcono
       AND oj.ojprrf = od.odprrf
       AND oj.ojcuno = od.odcuno
       AND oj.ojcmno = od.odcmno
       AND oj.ojcucd = od.odcucd
       AND oj.ojfvdt = od.odfvdt
    INNER JOIN cte_cc cc
        ON cc.division = (
            CASE WHEN SUBSTRING(od.odprrf, 1, 1) = '2' THEN '1'
                 ELSE SUBSTRING(od.odprrf, 1, 1)
            END
        ) || '00'
       AND cc.costcenter = td.tdmvxd
    WHERE od.odcono = 100
      AND od.odfvdt >= 20230101
      AND oj.ojcucd = 'EUR'
      AND oj.ojcuno = ' '
    UNION ALL
    SELECT
        SUBSTRING(od.odprrf, 1, 1) || '00',
        'L1',
        'L2',
        'L3',
        od.odprrf || '-' || od.odcuno,
        od.oditno,
        od.odsapr,
        20230101,
        20300629
    FROM MVXJDTA.OPRBAS od
    INNER JOIN (
        SELECT
            oprbas_1.odprrf AS prrf,
            oprbas_1.odcuno AS cuno,
            MAX(oprbas_1.odfvdt) AS fvdt,
            oprbas_1.odcono AS cono
        FROM MVXJDTA.OPRBAS oprbas_1
        WHERE oprbas_1.odprrf::text = ANY (ARRAY[
            '2A0'::text, '2A2'::text, '2B2'::text, '2B8'::text,
            '7C1'::text, '7CE'::text, '7CG'::text,
            '6R1'::text, '400'::text
        ])
          AND oprbas_1.odcuno::text = ''::text
          AND oprbas_1.odlvdt >= TO_CHAR(CURRENT_DATE::timestamp with time zone, 'YYYYMMDD'::text)::integer
        GROUP BY oprbas_1.odprrf, oprbas_1.odcuno, oprbas_1.odcono
    ) temp
        ON temp.cuno::text = od.odcuno::text
       AND temp.cono = od.odcono
       AND temp.prrf::text = od.odprrf::text
       AND od.odfvdt = temp.fvdt
    INNER JOIN MVXJDTA.OCUSMA
        ON okcono = 100
       AND okcuno = od.odcuno
    WHERE od.odcono = 100
      AND okcucl BETWEEN '900' AND '910'
      AND SUBSTRING(od.odprrf, 1, 1) IN ('6','7','4')
      AND od.odprrf NOT IN ('7C1','6R1','2A0')
),
cte_bi_pricelist AS (
    SELECT
        unnamed_subquery.companycode,
        unnamed_subquery.division,
        unnamed_subquery.pricelist_code,
        unnamed_subquery.pricelist_region,
        unnamed_subquery.pricelist_cucl,
        unnamed_subquery.date_from,
        unnamed_subquery.date_to,
        unnamed_subquery.itemcode,
        round(max(unnamed_subquery.price), 2) AS price,
        unnamed_subquery.price_multiple,
        max(unnamed_subquery.registrydate) AS registrydate,
        max(unnamed_subquery.registrytime) AS registrytime,
        max(unnamed_subquery.lastmodifydate) AS lastmodifydate,
        max(unnamed_subquery.changedby::text) AS changed_by
    FROM (
        SELECT
            oprbas.odcono AS companycode,
            CASE
                WHEN oprbas.odprrf::text ~~ '2%'::text THEN 200
                WHEN oprbas.odprrf::text ~~ '7%'::text THEN 700
                WHEN oprbas.odprrf::text ~~ '6%'::text THEN 600
                WHEN oprbas.odprrf::text ~~ '4%'::text THEN 400
                ELSE NULL::integer
            END AS division,
            oprbas.odprrf AS pricelist_code,
            CASE
                WHEN oprbas.odprrf::text = ANY (ARRAY[
                    '2A0'::text, '7C1'::text, '6R1'::text, '400'::text
                ]) THEN 'DOMESTIC'::text
                WHEN oprbas.odprrf::text = ANY (ARRAY[
                    '2A2'::text, '2B8'::text, '7CE'::text
                ]) THEN 'EXPORT'::text
                WHEN oprbas.odprrf::text = ANY (ARRAY[
                    '2B2'::text, '7CG'::text
                ]) THEN 'GROUP'::text
                ELSE NULL::text
            END AS pricelist_region,
            ' '::text AS pricelist_cucl,
            oprbas.odfvdt AS date_from,
            oprbas.odlvdt AS date_to,
            oprbas.oditno AS itemcode,
            oprbas.odsapr * mitaun.mucofa AS price,
            oprbas.odsacd AS price_multiple,
            oprbas.odrgdt AS registrydate,
            oprbas.odrgtm AS registrytime,
            oprbas.odlmdt AS lastmodifydate,
            oprbas.odchid AS changedby
        FROM MVXJDTA.OPRBAS
        JOIN (
            SELECT
                oprbas_1.odprrf AS prrf,
                oprbas_1.odcuno AS cuno,
                MAX(oprbas_1.odfvdt) AS fvdt,
                oprbas_1.odcono AS cono
            FROM MVXJDTA.OPRBAS oprbas_1
            WHERE oprbas_1.odprrf::text = ANY (ARRAY[
                '2A0'::text, '2A2'::text, '2B2'::text, '2B8'::text,
                '7C1'::text, '7CE'::text, '7CG'::text,
                '6R1'::text, '400'::text
            ])
              AND oprbas_1.odcuno::text = ''::text
              AND oprbas_1.odlvdt >= TO_CHAR(CURRENT_DATE::timestamp with time zone, 'YYYYMMDD'::text)::integer
            GROUP BY oprbas_1.odprrf, oprbas_1.odcuno, oprbas_1.odcono
        ) temp
            ON temp.cuno::text = oprbas.odcuno::text
           AND temp.cono = oprbas.odcono
           AND temp.prrf::text = oprbas.odprrf::text
           AND oprbas.odfvdt = temp.fvdt
        LEFT JOIN MVXJDTA.MITAUN
            ON mitaun.mucono = oprbas.odcono
           AND mitaun.muitno::text = oprbas.oditno::text
           AND mitaun.mualun::text = 'PCS'::text
           AND mitaun.muautp = '2'::smallint
        WHERE oprbas.odcono = 100
    ) unnamed_subquery
    GROUP BY
        unnamed_subquery.companycode,
        unnamed_subquery.division,
        unnamed_subquery.pricelist_code,
        unnamed_subquery.pricelist_region,
        unnamed_subquery.pricelist_cucl,
        unnamed_subquery.date_from,
        unnamed_subquery.date_to,
        unnamed_subquery.itemcode,
        unnamed_subquery.price_multiple
    UNION
    SELECT
        oprbas.odcono AS companycode,
        CASE
            WHEN oprbas.odprrf::text ~~ '2%'::text THEN 200
            WHEN oprbas.odprrf::text ~~ '7%'::text THEN 700
            WHEN oprbas.odprrf::text ~~ '6%'::text THEN 600
            ELSE NULL::integer
        END AS division,
        oprbas.odprrf AS pricelist_code,
        CASE
            WHEN oprbas.odprrf::text = ANY (ARRAY[
                '2A0'::text, '7C1'::text
            ]) THEN 'TRAVELTRADE'::text
            ELSE NULL::text
        END AS pricelist_region,
        ' '::text AS pricelist_cucl,
        oprbas.odfvdt AS date_from,
        oprbas.odlvdt AS date_to,
        oprbas.oditno AS itemcode,
        oprbas.odsapr AS price,
        oprbas.odsacd AS price_multiple,
        oprbas.odrgdt AS registrydate,
        oprbas.odrgtm AS registrytime,
        oprbas.odlmdt AS lastmodifydate,
        oprbas.odchid AS changed_by
    FROM MVXJDTA.OPRBAS
    JOIN (
        SELECT
            oprbas_1.odprrf AS prrf,
            oprbas_1.odcuno AS cuno,
            MAX(oprbas_1.odfvdt) AS fvdt,
            oprbas_1.odcono AS cono
        FROM MVXJDTA.OPRBAS oprbas_1
        WHERE oprbas_1.odprrf::text = ANY (ARRAY[
            '2A0'::text, '7C1'::text
        ])
          AND oprbas_1.odcuno::text = ' '::text
          AND oprbas_1.odlvdt >= TO_CHAR(CURRENT_DATE::timestamp with time zone, 'YYYYMMDD'::text)::integer
        GROUP BY oprbas_1.odprrf, oprbas_1.odcuno, oprbas_1.odcono
    ) temp
        ON temp.cuno::text = oprbas.odcuno::text
       AND temp.cono = oprbas.odcono
       AND temp.prrf::text = oprbas.odprrf::text
       AND oprbas.odfvdt = temp.fvdt
    WHERE oprbas.odcono = 100
)
SELECT
    CAST(division AS VARCHAR(10)) AS division,
    CAST('L1' AS VARCHAR(108)) AS customer1,
    CAST('L2' AS VARCHAR(108)) AS customer2,
    CAST('L3' AS VARCHAR(108)) AS customer3,
    CAST(
        COALESCE(rm.PRICELIST_REF, bi.pricelist_code)
        AS VARCHAR(108)
    ) AS pricelist_ref,
    CAST(itemcode AS VARCHAR(108)) AS itemcode,
    price,
    20230101 AS startdate,
    20350629 AS enddate
FROM cte_bi_pricelist bi
LEFT JOIN ref.PRICELIST_REGION_MAP rm
       ON rm.PRICELIST_CODE = bi.pricelist_code
      AND rm.PRICELIST_REGION = bi.pricelist_region
WHERE division <> '800'

UNION ALL

SELECT
    CAST(division AS VARCHAR(10)) AS division,
    CAST('L1' AS VARCHAR(108)) AS customer1,
    CAST('L2' AS VARCHAR(108)) AS customer2,
    CAST(
        CASE WHEN division IN ('100','300') THEN customer3 ELSE 'L3' END
        AS VARCHAR(108)
    ) AS customer3,
    CAST(pricelist_ref AS VARCHAR(108)) AS pricelist_ref,
    CAST(itemcode AS VARCHAR(108)) AS itemcode,
    price,
    startdate,
    enddate
FROM cte_pricelist_customer
WHERE division NOT IN ('800','400')

UNION ALL

SELECT
    division,
    customer1,
    customer2,
    customer3,
    pricelist_ref,
    itemcode,
    price,
    20230101 AS startdate,
    20300629 AS enddate
FROM LIDSKOE.MD_PRICELIST
WHERE division = '800'

UNION ALL

SELECT
    division,
    customer1,
    customer2,
    customer3,
    pricelist_ref,
    itemcode,
    price,
    20230101 AS startdate,
    20300629 AS enddate
FROM M3SKY.MD_PRICELIST
WHERE division = '400';

COMMENT ON VIEW ANAPLAN.MD_PRICELIST IS
    'Price list entries by division/customer/item. AD_PRICELIST_CUSTOMER inlined as CTE. Expanded bousr.bi_pricelist_v into cte_bi_pricelist and ref_dev → ref.';
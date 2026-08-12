CREATE OR REPLACE VIEW ANAPLAN.MD_CUSTOMER AS
WITH
cte_chargemodel AS (
    SELECT DISTINCT
        cm2.mechsy AS chargemodel,
        CASE WHEN exc.chmodel IS NULL THEN 'NO' ELSE 'YES' END AS excise,
        CASE WHEN dep.chmodel IS NULL THEN 'NO' ELSE 'YES' END AS depofee
    FROM MVXJDTA.OLICHM cm2
    LEFT JOIN (
        SELECT DISTINCT o.mechsy AS chmodel FROM MVXJDTA.OLICHM o
        INNER JOIN ref.CHARGE_MODEL_EXCISE_IDS r ON o.mecrid = r.MECRID
    ) exc ON cm2.mechsy = exc.chmodel
    LEFT JOIN (
        SELECT DISTINCT o.mechsy AS chmodel FROM MVXJDTA.OLICHM o
        INNER JOIN ref.CHARGE_MODEL_DEPOFEE_IDS r ON o.mecrid = r.MECRID
    ) dep ON cm2.mechsy = dep.chmodel
),
cte_sales_check_customer AS (
    SELECT customercode, SUM(volume) AS salesvolume
    FROM ANAPLAN.TD_SALES_SUM_FULL
    WHERE PERIOD BETWEEN
        TO_CHAR(CURRENT_DATE - INTERVAL '24 months','YYYY') || '01'
        AND TO_CHAR(CURRENT_DATE,'YYYYMM')
    GROUP BY customercode
    HAVING SUM(volume) <> 0
),
-- Inline of MD_CUSTOMER_DETAIL_V's base-table logic (division-800 UNION
-- branch omitted — see note above). Full column set kept so the downstream
-- logic below is unchanged; only the FROM source moved from the view to
-- the underlying MVXJDTA/REF/ANAPLAN tables it reads.
cte_customer_detail_full AS (
    SELECT
        CAST(cs.divi AS VARCHAR(108)) AS division,
        CAST(CASE
            WHEN cu.okcfc3 IN ('RET','HOR','HRC') THEN 'DOMESTIC'
            WHEN cu.okcfc3 = 'EXP'               THEN 'EXPORT'
            WHEN cu.okcfc3 = 'GRP'               THEN 'GROUP'
            WHEN cu.okcfc3 = 'TRA'               THEN 'TRAVELTRADE'
            WHEN cu.okcucl IN (SELECT CODE FROM ref.L1_REGION_CODES WHERE RULE_ID = 'l1_rule_5')  THEN 'EXPORT'
            WHEN cu.okcucl IN (SELECT CODE FROM ref.L1_REGION_CODES WHERE RULE_ID = 'l1_rule_6')  THEN 'TRAVELTRADE'
            WHEN cu.okacrf BETWEEN '4410' AND '4449' THEN 'EXPORT'
            WHEN cu.okacrf = 'L9000'              THEN 'GROUP'
            WHEN cu.okcucl IN (SELECT CODE FROM ref.L1_REGION_CODES WHERE RULE_ID = 'l1_rule_9')  THEN 'GROUP'
            ELSE 'DOMESTIC'
        END AS VARCHAR(108)) AS l1_region,
        CAST(CASE
            WHEN cu.okrasn='800' AND cu.okcfc6='8HORE?A'                                    THEN 'HORECA'
            WHEN cu.okrasn='800' AND cu.okcfc6 IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_2')  THEN 'RETAIL'
            WHEN cu.oksdst='217'                                                              THEN 'RETAIL'
            WHEN cu.okcfc3 IN ('HOR','HRC')                                                  THEN 'HORECA'
            WHEN cu.okcfc3 = 'EXP'                                                           THEN 'EXPORT'
            WHEN cu.okcfc3 = 'GRP'                                                           THEN 'GROUP'
            WHEN cu.okcfc3 = 'TRA'                                                           THEN 'TRAVELTRADE'
            WHEN cu.okrasn <> '700' AND cu.okcfc3 = 'RET'                                   THEN 'RETAIL'
            WHEN cu.okacrf IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_9')  THEN 'HORECA'
            WHEN cu.okacrf BETWEEN '4410' AND '4449'                                         THEN 'EXPORT'
            WHEN cu.okacrf IN ('4460')                                                        THEN 'EXPORT'
            WHEN cu.okacrf IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_12')  THEN 'GROUP'
            WHEN cu.okcucl IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_13')  THEN 'RETAIL'  -- fixed: ',218' typo -> clean '217','218' (confirmed zero behaviour change against production data)
            WHEN cu.okacrf = 'L9000'                                                         THEN 'GROUP'
            WHEN cu.okcucl BETWEEN '400' AND '408'                                           THEN 'RETAIL'
            WHEN cu.okcucl IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_16')  THEN 'HORECA'
            WHEN cu.okcucl BETWEEN '891' AND '896'                                           THEN 'HORECA'
            WHEN cu.okcucl IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_18')  THEN 'TRAVELTRADE'
            WHEN cu.okcucl IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_19')  THEN 'EXPORT'
            WHEN cu.okcucl IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_20')  THEN 'GROUP'
            WHEN cu.okcfc1 NOT IN (SELECT CODE FROM ref.L2_SALESCHANNEL_CODES WHERE RULE_ID = 'l2_rule_21')  THEN 'RETAIL'
            ELSE 'WHOLESALES'
        END AS VARCHAR(108)) AS l2_saleschannel,
        CAST(CASE
            WHEN cu.okrasn = '800'              THEN CASE WHEN cu.okcfc6 = ' ' THEN 'NA' ELSE fr2.cttx40 END
            WHEN cs.divi IN ('100','300')       THEN CASE WHEN opla.eaaitm IS NULL THEN '9999 OTHER' ELSE opla.eaaitm || ' ' || ea1.cttx40 END
            WHEN (cs.divi NOT IN ('400','100') OR cu.okrasn NOT IN ('400','100')) AND cu.okcucl BETWEEN '905' AND '909' THEN cu2.oksmcd || ' ' || ct4.cttx40
            WHEN cu.okacrf = 'L9000' OR cu.okcucl = '910' THEN UPPER(py.okcunm || ' (' || py.okcuno || ')')
            WHEN cu.okrasn = '200'             THEN ct1.cttx15
            WHEN cu.okcucl = ' '              THEN 'OTHER'
            ELSE ct1.cttx40
        END AS VARCHAR(108)) AS l3_customergroup,
        CAST(CASE
            WHEN cu.okcucl = '910' OR cu.okacrf = 'L9000' THEN UPPER(py.okcunm || ' (' || py.okcuno || ')')
            WHEN cu.okcucl BETWEEN '905' AND '909'         THEN ct9.cttx15
            WHEN cu.okrasn IN ('100','300') AND cu.okcucl <> '910' THEN CASE WHEN opla.eaaitm IS NULL THEN 'OTHER' ELSE ea1.cttx40 END
            WHEN cu.okrasn = '200'                         THEN ct11.cttx40
            WHEN cu.okrasn IN ('200','600') AND cu.okcfc8 <> ' ' THEN ct10.cttx40
            WHEN cu.okrasn = '700' AND cu.okcfc9 <> ' '   THEN UPPER(ct7.cttx40)
            WHEN cu.okcfc1 IN (' ')                        THEN 'NO CHAIN'
            ELSE ct8.cttx40
        END AS VARCHAR(108)) AS l4_chain,
        CAST(CASE
            WHEN cu.okcucl BETWEEN '905' AND '910' OR cu.okacrf = 'L9000' THEN
                CASE WHEN py.okcunm IS NULL THEN UPPER(cu.okcunm||' ('||cu.okcuno||')') ELSE UPPER(py.okcunm||' ('||py.okcuno||')') END
            WHEN cu.okrasn IN ('100','300') AND cu.okcucl <> '910' THEN CASE WHEN opla.eaaitm IS NULL THEN 'OTHER' ELSE ea1.cttx40 END
            WHEN cu.okrasn IN ('200','600') AND cu.okcfc8 <> ' '   THEN ct10.cttx40
            WHEN cu.okrasn = '700' AND cu.okcfc9 <> ' '            THEN UPPER(ct7.cttx40)
            WHEN cu.okcfc1 IN (' ')                                 THEN 'NO CHAIN'
            ELSE ct8.cttx40
        END AS VARCHAR(108)) AS l5_customer,
        CAST((
            CASE WHEN cm.excise IS NULL THEN 'no excise'
                 ELSE CASE cm.excise WHEN 'YES' THEN 'excise' WHEN 'NO' THEN 'no excise' ELSE cm.excise END
            END || '-' ||
            CASE WHEN cm.depofee IS NULL THEN 'no deposit'
                 ELSE CASE cm.depofee WHEN 'YES' THEN 'deposit' WHEN 'NO' THEN 'no deposit' ELSE cm.depofee END
            END
        ) AS VARCHAR(108)) AS l6_excise_depo,
        CAST(CASE
            WHEN cu.okrasn = '800'              THEN cu.okcfc6
            WHEN cs.divi IN ('100','300')       THEN CASE WHEN opla.eaaitm IS NULL THEN '9999' ELSE cu.okacrf END
            WHEN (cs.divi NOT IN ('400','100') OR cu.okrasn NOT IN ('400','100')) AND cu.okcucl BETWEEN '905' AND '909' THEN cu2.oksmcd
            WHEN cu.okacrf = 'L9000' OR cu.okcucl = '910' THEN py.okcuno
            WHEN cu.okrasn = '200'             THEN cu.okcucl
            WHEN cu.okcucl = ' '              THEN '999'
            ELSE cu.okcucl
        END AS VARCHAR(108)) AS l3_code,
        CAST(CASE
            WHEN cu.okcucl = '910' OR cu.okacrf = 'L9000' THEN py.okcuno
            WHEN cu.okcucl BETWEEN '905' AND '909'         THEN cu.okcscd
            WHEN cu.okrasn IN ('100','300') AND cu.okcucl <> '910' THEN CASE WHEN opla.eaaitm IS NULL THEN '9999' ELSE cu.okacrf END
            WHEN cu.okrasn = '200'                         THEN cu.oksdst
            WHEN cu.okrasn IN ('200','600') AND cu.okcfc8 <> ' '  THEN UPPER(cu.okcfc8)
            WHEN cu.okrasn = '700' AND cu.okcfc9 <> ' '           THEN cu.okcfc9
            WHEN cu.okcfc1 IN (' ')                               THEN '999'
            ELSE UPPER(cu.okcfc1)
        END AS VARCHAR(108)) AS l4_code,
        CAST(CASE
            WHEN cu.okcucl BETWEEN '905' AND '910' OR cu.okacrf = 'L9000' THEN
                CASE WHEN py.okcuno IS NULL THEN cu.okcuno ELSE py.okcuno END
            WHEN cu.okrasn IN ('100','300') AND cu.okcucl <> '910' THEN CASE WHEN opla.eaaitm IS NULL THEN '9999' ELSE cu.okacrf END
            WHEN cu.okrasn IN ('200','600') AND cu.okcfc8 <> ' '   THEN UPPER(cu.okcfc8)
            WHEN cu.okrasn = '700' AND cu.okcfc9 <> ' '            THEN cu.okcfc9
            WHEN cu.okcfc1 IN (' ')                                THEN '999'
            ELSE UPPER(cu.okcfc1)
        END AS VARCHAR(108)) AS l5_code,
        CAST((
            CASE WHEN cm.excise IS NULL THEN '0' ELSE CASE cm.excise WHEN 'YES' THEN '1' WHEN 'NO' THEN '0' ELSE '0' END END
            || '-' ||
            CASE WHEN cm.depofee IS NULL THEN '0' ELSE CASE cm.depofee WHEN 'YES' THEN '1' WHEN 'NO' THEN '0' ELSE '0' END END
        ) AS VARCHAR(108)) AS l6_code,
        CAST(cu.okchsy  AS VARCHAR(108)) AS chargemodel,
        CAST(cu.okcuno  AS VARCHAR(108)) AS m3customercode,
        CAST(cu.okstat  AS VARCHAR(108)) AS m3status,
        CAST(CASE
            WHEN cs.divi='200' AND cu.okcucl LIKE '2%' THEN 'YES'
            WHEN cs.divi='700' AND cu.okcucl LIKE '7%' THEN 'YES'
            WHEN cs.divi='700' AND cu.okcucl BETWEEN '900' AND '903' THEN 'YES'
            WHEN cs.divi='800' AND cu.okcucl LIKE '8%' THEN 'YES'
            WHEN cm.excise IS NULL THEN 'NO'
            ELSE cm.excise
        END AS VARCHAR(3)) AS excise,
        CAST(CASE
            WHEN cs.divi='200' AND cu.okcucl='910' THEN 'NO'
            WHEN cs.divi='700' AND cu.okcucl LIKE '7%' THEN 'YES'
            WHEN cs.divi='700' AND cu.okcucl BETWEEN '900' AND '903' THEN 'YES'
            WHEN cs.divi='600' AND cu.okcucl='910' AND cu.okpyno NOT IN ('9900616','9900009') THEN 'NO'
            WHEN cm.depofee IS NULL THEN 'NO'
            ELSE cm.depofee
        END AS VARCHAR(3)) AS depofee,
        CAST(COALESCE(pr.pricelist_ref, 'NA') AS VARCHAR(108)) AS pricelist_ref,
        CAST('NA' AS VARCHAR(108)) AS bonusgroup_ref,
        CAST(CASE WHEN cu.okmodl='03' OR cu.okmodl=' ' THEN 'NA' ELSE modl.cttx15 END AS VARCHAR(108)) AS deliverygroup,
        CAST(CASE WHEN cu.okmodl='03' OR cu.okmodl=' ' THEN '999' ELSE cu.okmodl END AS VARCHAR(108)) AS deliverygroup_code,
        CASE WHEN cs.divi IN ('100','300') THEN cu.okacrf
             WHEN cs.divi='800'            THEN cu.okcfc6
             ELSE cu.okcucl END  AS local_region,
        CASE WHEN cs.divi IN ('200','700','600') AND cu.okcucl BETWEEN '905' AND '909'
             THEN cu2.oksmcd ELSE ' ' END AS salesperson,
        CASE WHEN cs.divi <> '200' AND bud.customercode IS NULL THEN cu.okcuno
             WHEN cs.divi = '200' AND alc.customercode IS NULL  THEN cu.okcuno
             WHEN cs.divi = '200' AND alc.customercode IS NOT NULL THEN alc.customercode
             ELSE bud.customercode END    AS budget_customercode,
        (cu.okcunm || ' (' || cu.okcuno || ')') AS shop
    FROM (
        SELECT DISTINCT divi, cuno
        FROM (
            SELECT okdivi AS divi, okcuno AS cuno FROM MVXJDTA.CCUDIV
            UNION ALL
            SELECT okrasn AS divi, okcuno AS cuno FROM MVXJDTA.OCUSMA
        ) t WHERE divi <> ' '
    ) cs
    LEFT JOIN MVXJDTA.OCUSMA   cu    ON cs.cuno = cu.okcuno
    LEFT JOIN MVXJDTA.CCUDIV   cu2   ON cu2.okcuno = cs.cuno AND cs.divi = cu2.okdivi
    LEFT JOIN MVXJDTA.OCUSMA   py    ON cu.okcono = py.okcono AND py.okcuno = cu.okpyno
    LEFT JOIN MVXJDTA.CSYTAB   ct1   ON cu.okcono=ct1.ctcono AND ct1.ctstco='CUCL' AND ct1.ctstky=cu.okcucl AND ct1.ctdivi=' '
    LEFT JOIN MVXJDTA.CSYTAB   ct4   ON cu.okcono=ct4.ctcono AND ct4.ctstco='SMCD' AND ct4.ctstky=cu2.oksmcd AND ct4.ctdivi=' '
    LEFT JOIN MVXJDTA.CSYTAB   ct7   ON cu.okcono=ct7.ctcono AND ct7.ctstco='CFC9' AND ct7.ctstky=cu.okcfc9 AND ct7.ctdivi=' '
    LEFT JOIN MVXJDTA.CSYTAB   ct8   ON cu.okcono=ct8.ctcono AND ct8.ctstco='CFC1' AND ct8.ctstky=cu.okcfc1 AND ct8.ctdivi=' '
    LEFT JOIN MVXJDTA.CSYTAB   ct9   ON cu.okcono=ct9.ctcono AND ct9.ctstco='CSCD' AND ct9.ctstky=cu.okcscd AND ct9.ctdivi=' '
    LEFT JOIN MVXJDTA.CSYTAB   ct10  ON cu.okcono=ct10.ctcono AND ct10.ctstco='CFC8' AND ct10.ctstky=cu.okcfc8 AND ct10.ctdivi=' '
    LEFT JOIN MVXJDTA.CSYTAB   ct11  ON cu.okcono=ct11.ctcono AND ct11.ctstco='SDST' AND ct11.ctstky=cu.oksdst AND ct11.ctdivi=' '
    LEFT JOIN MVXJDTA.CSYTAB   ea1   ON cu.okcono=ea1.ctcono AND ea1.ctstky=TRIM(cu.okacrf) AND ea1.ctstco='ACRF' AND ea1.ctdivi=' '
    LEFT JOIN MVXJDTA.CSYTAB   fr2   ON cu.okcono=fr2.ctcono AND fr2.ctstco='CFC6' AND fr2.ctstky=cu.okcfc6
    LEFT JOIN cte_chargemodel  cm    ON cu.okchsy = cm.chargemodel
    LEFT JOIN MVXJDTA.CSYTAB   modl  ON modl.ctcono=cu.okcono AND modl.ctstco='MODL' AND modl.ctlncd=cu.oklhcd AND modl.ctstky<>'03' AND cu.okmodl=modl.ctstky
    LEFT JOIN (
        SELECT eaaitm FROM MVXJDTA.FCHACC
        WHERE eacono=100 AND eadivi IN ('100','300') AND eaaitp='2' AND earesp='PLANNING'
    ) opla ON cu.okacrf = opla.eaaitm
    LEFT JOIN (
        SELECT DISTINCT ON (DIVISION, OKCUCL_EXACT, OKCUCL_FROM) *
        FROM ref.PRICELIST_CUSTOMER_REF
        ORDER BY DIVISION, OKCUCL_EXACT NULLS LAST, OKCUCL_FROM NULLS LAST, SORT_ORDER
    ) pr ON pr.DIVISION = cs.divi
         AND (
             (pr.OKCUCL_EXACT IS NOT NULL AND cu.okcucl = pr.OKCUCL_EXACT)
             OR (pr.OKCUCL_EXACT IS NULL AND pr.OKCUCL_FROM IS NOT NULL
                 AND cu.okcucl BETWEEN pr.OKCUCL_FROM AND pr.OKCUCL_TO)
             OR (pr.OKCUCL_EXACT IS NULL AND pr.OKCUCL_FROM IS NULL)
         )
    LEFT JOIN ANAPLAN.MD_BUDGET_CUSTOMER     bud ON cs.divi = bud.DIVISION
         AND bud.LOCAL_REGION = CASE WHEN cs.divi IN ('100','300') THEN cu.okacrf ELSE cu.okcucl END
    LEFT JOIN ANAPLAN.MD_BUDGET_CUSTOMER_200 alc ON cs.divi = alc.DIVISION
         AND alc.LOCAL_REGION = cu.okcucl AND alc.DISTRICT = cu.oksdst
    WHERE cu.okcono = 100
      AND cu.okcutp NOT IN ('8','9')
      AND cu.okcuno NOT IN ('80105956','80107549','80153425')
      AND cu.okrasn <> '800'
      AND cs.divi <> '800'
),
cte_customer_detail AS (
    SELECT
        division, l1_region, l2_saleschannel, l3_customergroup, l4_chain,
        l5_customer, l6_excise_depo, l3_code, l4_code, l5_code, l6_code,
        chargemodel, m3customercode, m3status, excise, depofee,
        pricelist_ref, bonusgroup_ref, deliverygroup, deliverygroup_code,
        local_region, salesperson, budget_customercode, shop
    FROM cte_customer_detail_full
    WHERE division NOT IN ('800','400')
)
SELECT
    cd.division,
    cd.l1_region,
    cd.l2_saleschannel,
    cd.l3_customergroup,
    cd.l4_chain,
    cd.l5_customer,
    cd.l6_excise_depo,
    cd.division || '-' || cd.l2_saleschannel || '-' || cd.l3_code                              AS l3_code,
    cd.division || '-' || cd.l2_saleschannel || '-' || cd.l3_code || '-' || cd.l4_code         AS l4_code,
    cd.division || '-' || cd.l2_saleschannel || '-' || cd.division || '-' || cd.l2_saleschannel
        || '-' || cd.l3_code || '-' || cd.l4_code
        || CASE WHEN cd.l5_code = cd.l4_code THEN '' ELSE '-' || cd.l5_code END                AS l5_code,
    cd.division || '-' || cd.l2_saleschannel || '-' || cd.l3_code || '-' || cd.l4_code
        || CASE WHEN cd.l5_code = cd.l4_code THEN '' ELSE '-' || cd.l5_code END
        || '-' || cd.l6_code                                                                    AS customercode,
    cd.excise,
    cd.depofee,
    cd.pricelist_ref,
    cd.bonusgroup_ref,
    MIN(cd.deliverygroup_code || '-' || cd.deliverygroup) AS deliverygroup,
    COUNT(cd.shop)                                         AS shop_count,
    CAST(NULL AS VARCHAR(108)) AS attr1,
    CAST(NULL AS VARCHAR(108)) AS attr2,
    CAST(NULL AS VARCHAR(108)) AS attr3,
    CAST(NULL AS VARCHAR(108)) AS attr4,
    CAST(NULL AS VARCHAR(108)) AS attr5,
    cd.local_region,
    cd.salesperson,
    cd.budget_customercode
FROM cte_customer_detail cd
LEFT JOIN cte_sales_check_customer sc
       ON sc.customercode = cd.division || '-' || cd.l2_saleschannel
          || '-' || cd.l3_code || '-' || cd.l4_code
          || CASE WHEN cd.l5_code = cd.l4_code THEN '' ELSE '-' || cd.l5_code END
          || '-' || cd.l6_code
WHERE (cd.m3status <= '20' OR sc.customercode IS NOT NULL)
GROUP BY
    cd.division, cd.l1_region, cd.l2_saleschannel, cd.l3_customergroup,
    cd.l4_chain, cd.l5_customer, cd.l6_excise_depo,
    cd.division || '-' || cd.l2_saleschannel || '-' || cd.l3_code,
    cd.division || '-' || cd.l2_saleschannel || '-' || cd.l3_code || '-' || cd.l4_code,
    cd.division || '-' || cd.l2_saleschannel || '-' || cd.division || '-' || cd.l2_saleschannel
        || '-' || cd.l3_code || '-' || cd.l4_code
        || CASE WHEN cd.l5_code = cd.l4_code THEN '' ELSE '-' || cd.l5_code END,
    cd.division || '-' || cd.l2_saleschannel || '-' || cd.l3_code || '-' || cd.l4_code
        || CASE WHEN cd.l5_code = cd.l4_code THEN '' ELSE '-' || cd.l5_code END
        || '-' || cd.l6_code,
    cd.l3_code, cd.l4_code, cd.l5_code, cd.l6_code,
    cd.excise, cd.depofee, cd.pricelist_ref, cd.bonusgroup_ref,
    cd.local_region, cd.salesperson, cd.budget_customercode

UNION ALL

SELECT division, l1_region, l2_saleschannel, l3_customergroup, l4_chain,
       l5_customer, l6_excise_depo, l3_code, l4_code, l5_code, customercode,
       excise, depofee, pricelist_ref, bonusgroup_ref, deliverygroup,
       shop_count, attr1, attr2, attr3, attr4, attr5,
       local_region, salesperson, budget_customercode
FROM LIDSKOE.MD_CUSTOMER WHERE division = '800'

UNION ALL

SELECT division, l1_region, l2_saleschannel, l3_customergroup, l4_chain,
       l5_customer, l6_excise_depo, l3_code, l4_code, l5_code, customercode,
       excise, depofee, pricelist_ref, bonusgroup_ref, deliverygroup,
       shop_count, attr1, attr2, attr3, attr4, attr5,
       local_region, salesperson, budget_customercode
FROM M3SKY.MD_CUSTOMER WHERE division = '400';

COMMENT ON VIEW ANAPLAN.MD_CUSTOMER IS
    'Customer hierarchy flattened to customercode key. MD_CUSTOMER_DETAIL + AD_SALES_CHECK_CUSTOMER inlined as CTEs (chain depth 3 via AD_CHARGEMODEL).';

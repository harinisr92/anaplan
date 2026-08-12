CREATE OR REPLACE VIEW ANAPLAN.TD_DELIVERY AS
WITH
cte_monthly_sales AS (
    SELECT
        md.divi,
        md.period::TEXT AS period,
        md.customercode,
        SUM(md.volume) AS volume,
        0::NUMERIC AS delivery
    FROM bousr.prep_monthlysales md
    INNER JOIN bousr.bi_ordertypes_v ot
        ON ot.division::TEXT = md.divi::TEXT
       AND ot.ordertype::TEXT = md.ordertype::TEXT
    WHERE md.period >= '202101'
      AND ot.ordertypegroup = 'NORMAL'
    GROUP BY md.divi, md.period, md.customercode
),
cte_delivery_amounts AS (
    SELECT
        dedivi AS divi,
        deperi::TEXT AS period,
        CASE WHEN decuno IS NULL THEN depyno ELSE decuno END AS customercode,
        0::NUMERIC AS volume,
        SUM(dedeam) AS delivery
    FROM bousr.prep_salesdelivery
    WHERE deperi >= '202101'
    GROUP BY
        deperi,
        dedivi,
        CASE WHEN decuno IS NULL THEN depyno ELSE decuno END
),
cte_delivery_base AS (
    SELECT divi, period, customercode, volume, delivery FROM cte_monthly_sales
    UNION ALL
    SELECT divi, period, customercode, volume, delivery FROM cte_delivery_amounts
),
cte_customer_detail AS (
    SELECT
        DIVISION,
        L1_REGION,
        L2_SALESCHANNEL,
        L3_CODE,
        L4_CODE,
        L5_CODE,
        L6_CODE,
        M3CUSTOMERCODE
    FROM ANAPLAN.MD_CUSTOMER_DETAIL_T
)
SELECT
    CAST(dta.divi AS VARCHAR(108)) AS division,
    CAST(dta.period AS VARCHAR(108)) AS period,
    CAST(cu.division || '-' || cu.l1_region AS VARCHAR(108)) AS l1_region,
    CAST(cu.division || '-' || cu.l2_saleschannel AS VARCHAR(108)) AS l2_saleschannel,
    CAST(cu.division || '-' || cu.l2_saleschannel || '-' || cu.l3_code AS VARCHAR(108)) AS l3_customergroup,
    CAST(cu.division || '-' || cu.l2_saleschannel || '-' || cu.l3_code || '-' || cu.l4_code AS VARCHAR(108)) AS l4_chain,
    CAST(
        cu.division || '-' || cu.l2_saleschannel || '-' || cu.l3_code || '-' || cu.l4_code
        || CASE WHEN cu.l5_code = cu.l4_code THEN '' ELSE '-' || cu.l5_code END
        || '-' || cu.l6_code
        AS VARCHAR(108)
    ) AS customercode,
    ROUND(SUM(dta.volume)::NUMERIC, 4) AS volume,
    ROUND(SUM(dta.delivery)::NUMERIC, 4) AS delivery,
    CAST(0 AS NUMERIC) AS ext_m1,
    CAST(0 AS NUMERIC) AS ext_m2,
    CAST(0 AS NUMERIC) AS ext_m3,
    CAST(NULL AS VARCHAR(108)) AS attr1,
    CAST(NULL AS VARCHAR(108)) AS attr2,
    CAST(NULL AS VARCHAR(108)) AS attr3
FROM cte_delivery_base dta
LEFT JOIN cte_customer_detail cu
    ON cu.m3customercode = dta.customercode
GROUP BY
    cu.division,
    cu.l1_region,
    cu.l2_saleschannel,
    cu.l3_code,
    cu.l4_code,
    CASE WHEN cu.l5_code = cu.l4_code THEN '' ELSE '-' || cu.l5_code END,
    cu.l6_code,
    dta.divi,
    dta.period;

COMMENT ON VIEW ANAPLAN.TD_DELIVERY IS
    'CTE-standardized TD delivery view. Aggregates monthly sales and delivery amounts by customer (periods >= 202101). Uses ANAPLAN.MD_CUSTOMER_DETAIL_T for hierarchy lookup (avoids view-over-view).';
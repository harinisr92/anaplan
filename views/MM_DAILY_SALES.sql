CREATE OR REPLACE VIEW ANAPLAN.MM_DAILY_SALES AS
WITH SALES_SRC AS (
    SELECT
        ss.division AS divi,
        ss.invoicedate::TEXT AS invoicedate,
        ss.deliverydate::TEXT AS deliverydate,
        ss.customercode,
        ss.itemcode,
        ss.invoicequantity * c.volume AS volume,
        ss.orderquantity * c.volume AS order_volume,
        CASE
            WHEN ss.division IN ('100','300')
                THEN ss.grosssales - 2 * ss.discountamount - ss.onk2 - ss.exciseamount
            WHEN ss.division = '800'
                THEN ss.netsales
            ELSE ss.netsales - ss.onk2
        END AS netsales,
        ss.discountamount AS discount,
        ss.exciseamount AS excise,
        ss.onk2 AS depofee,
        ss.grosssales AS gross,
        ss.costamountlocalcurr AS totalcogs,
        ss.onk3 AS additionalcogs,
        ss.extra1 AS campaign
    FROM bousr.bi_sales ss
    INNER JOIN bousr.bi_ordertypes_v ot
        ON ot.division::TEXT = ss.division::TEXT
       AND ot.ordertype::TEXT = ss.ordertype::TEXT
    INNER JOIN bousr.bi_product c
        ON ss.companycode = c.companycode
       AND ss.itemcode = c.itemcode
    WHERE (
        SUBSTRING(ss.invoicedate::TEXT, 1, 6) BETWEEN TO_CHAR(CURRENT_DATE - INTERVAL '1 month', 'YYYYMM') AND TO_CHAR(CURRENT_DATE, 'YYYYMM')
        OR SUBSTRING(ss.deliverydate::TEXT, 1, 6) BETWEEN TO_CHAR(CURRENT_DATE - INTERVAL '1 month', 'YYYYMM') AND TO_CHAR(CURRENT_DATE, 'YYYYMM')
        OR (
            ss.division IN ('100','300','400')
            AND ss.invoicedate = 0
            AND SUBSTRING(ss.deliverydate::TEXT, 1, 6) BETWEEN TO_CHAR(CURRENT_DATE - INTERVAL '1 month', 'YYYYMM') AND TO_CHAR(CURRENT_DATE, 'YYYYMM')
        )
    )
      AND ot.ordertypegroup = 'NORMAL'
      AND c.itemtype = '10'
      AND (ss.iid = 'X' OR ss.division IN ('100','300','400'))
)
SELECT
    CAST(dta.divi AS VARCHAR(108)) AS division,
    CAST(dta.invoicedate AS VARCHAR(108)) AS invoicedate,
    CAST(dta.deliverydate AS VARCHAR(108)) AS deliverydate,
    CAST(
        cu.DIVISION || '-' || cu.L2_SALESCHANNEL || '-' || cu.L3_CODE || '-' || cu.L4_CODE
        || CASE WHEN cu.L5_CODE = cu.L4_CODE THEN '' ELSE '-' || cu.L5_CODE END
        || '-' || cu.L6_CODE
        AS VARCHAR(108)
    ) AS customercode,
    CAST(dta.itemcode AS VARCHAR(108)) AS itemcode,
    ROUND(SUM(dta.volume)::NUMERIC, 4) AS volume,
    ROUND(SUM(dta.order_volume)::NUMERIC, 4) AS order_volume,
    ROUND(SUM(dta.netsales)::NUMERIC, 4) AS netsales,
    ROUND(SUM(dta.discount)::NUMERIC, 4) AS discount,
    ROUND(SUM(dta.excise)::NUMERIC, 4) AS excise,
    ROUND(SUM(dta.depofee)::NUMERIC, 4) AS depofee,
    ROUND(SUM(dta.gross)::NUMERIC, 4) AS gross,
    ROUND(SUM(dta.totalcogs)::NUMERIC, 4) AS cogs,
    ROUND(SUM(dta.additionalcogs)::NUMERIC, 4) AS addcogs,
    CAST(NULL AS VARCHAR(108)) AS attr1,
    CAST(NULL AS VARCHAR(108)) AS attr2,
    CAST(NULL AS VARCHAR(108)) AS attr3,
    CAST(
        CASE WHEN TRIM(dta.campaign::TEXT) = '1' THEN '1' ELSE '0' END
        AS VARCHAR(108)
    ) AS campaign,
    cu.L1_REGION,
    cu.L2_SALESCHANNEL,
    cu.L3_CUSTOMERGROUP,
    cu.L4_CHAIN,
    cu.L5_CUSTOMER
FROM SALES_SRC dta
LEFT JOIN ANAPLAN.MD_CUSTOMER_DETAIL_T cu
    ON cu.M3CUSTOMERCODE = dta.customercode
GROUP BY
    cu.DIVISION || '-' || cu.L2_SALESCHANNEL || '-' || cu.L3_CODE || '-' || cu.L4_CODE
    || CASE WHEN cu.L5_CODE = cu.L4_CODE THEN '' ELSE '-' || cu.L5_CODE END || '-' || cu.L6_CODE,
    dta.divi,
    dta.itemcode,
    dta.invoicedate,
    dta.deliverydate,
    CASE WHEN TRIM(dta.campaign::TEXT) = '1' THEN '1' ELSE '0' END,
    cu.L1_REGION,
    cu.L2_SALESCHANNEL,
    cu.L3_CUSTOMERGROUP,
    cu.L4_CHAIN,
    cu.L5_CUSTOMER;

COMMENT ON VIEW ANAPLAN.MM_DAILY_SALES IS
    'Daily sales with customer hierarchy. Reads MD_CUSTOMER_DETAIL_T TABLE (not a view). SubStr 0-based → 1-based; add_months → INTERVAL; DECODE → CASE; type casts for join and ROUND.';
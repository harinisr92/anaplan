CREATE OR REPLACE VIEW ANAPLAN.MM_DAILY_SALES_DET AS
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
    WHERE SUBSTRING(ss.invoicedate::TEXT, 1, 6) BETWEEN
          TO_CHAR(CURRENT_DATE - INTERVAL '1 month', 'YYYYMM')
          AND TO_CHAR(CURRENT_DATE, 'YYYYMM')
      AND ot.ordertypegroup = 'NORMAL'
      AND c.itemtype = '10'
)
SELECT
    CAST(dta.divi AS VARCHAR(108)) AS division,
    CAST(SUBSTRING(dta.invoicedate, 1, 6) AS VARCHAR(108)) AS period,
    CAST(dta.customercode AS VARCHAR(108)) AS customercode,
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
    COUNT(DISTINCT dta.invoicedate) AS days,
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
    dta.customercode,
    dta.divi,
    dta.itemcode,
    SUBSTRING(dta.invoicedate, 1, 6),
    CASE WHEN TRIM(dta.campaign::TEXT) = '1' THEN '1' ELSE '0' END,
    cu.L1_REGION,
    cu.L2_SALESCHANNEL,
    cu.L3_CUSTOMERGROUP,
    cu.L4_CHAIN,
    cu.L5_CUSTOMER;

COMMENT ON VIEW ANAPLAN.MM_DAILY_SALES_DET IS
    'Detailed daily sales aggregated to period. Oracle had hardcoded test date range (Aug-Sep 2024) — replaced with rolling 2-month window to match mm_daily_sales_v behaviour.';
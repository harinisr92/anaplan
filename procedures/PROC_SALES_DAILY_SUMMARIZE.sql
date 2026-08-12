-- =============================================================================
-- PROCEDURE: ANAPLAN.PROC_SALES_DAILY_SUMMARIZE()
-- =============================================================================
-- Migrated from: Oracle ANAPLAN.PROC_SALES_DAILY_SUMMARIZE
-- Oracle conversions applied:
--   to_char(add_months(sysdate,-1),'YYYYMM') -> TO_CHAR(CURRENT_DATE - INTERVAL '1 month','YYYYMM')
--   to_char(sysdate,'YYYYMM')                -> TO_CHAR(CURRENT_DATE,'YYYYMM')
--   SubStr(x,0,6)                            -> SUBSTRING(x::TEXT,1,6)  (0-based->1-based)
--   DECODE(trim(to_char(campaign)),'1','1',null,'0','0') -> CASE WHEN TRIM(CAST(campaign AS TEXT))='1' THEN '1' ELSE '0' END
--   DECODE(CAMPAIGN,NULL,'0',CAMPAIGN)       -> COALESCE(campaign,'0')
--   REPLACE(TO_CHAR(VOLUME),'.',',')         -> REPLACE(TO_CHAR(volume,'FM9999999990.0000'),'.',',')
--   anaplan.* schema                         -> ANAPLAN.*
--   DELETE FROM / INSERT INTO / COMMIT       -> same in PG (no COMMIT needed inside procedure, autocommit off)
--   Commented-out Oracle blocks preserved as PG comments for traceability
-- Behaviour: unchanged — refreshes md_customer_detail_t snapshot,
--            then rebuilds daily sales tables for rolling 2-month window
-- =============================================================================

CREATE OR REPLACE PROCEDURE ANAPLAN.PROC_SALES_DAILY_SUMMARIZE()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Oracle: fromperiod varchar(20); toperiod varchar(20);
    fromperiod VARCHAR(20);
    toperiod   VARCHAR(20);
BEGIN
    -- Oracle: fromperiod := to_char(add_months(sysdate,-1),'YYYYMM');
    fromperiod := TO_CHAR(CURRENT_DATE - INTERVAL '1 month', 'YYYYMM');
    -- Oracle: toperiod := to_char(sysdate,'YYYYMM');
    toperiod   := TO_CHAR(CURRENT_DATE, 'YYYYMM');

    -- Oracle: DELETE FROM anaplan.MD_CUSTOMER_DETAIL_T;
    --         INSERT INTO anaplan.MD_CUSTOMER_DETAIL_T select * FROM anaplan.MD_CUSTOMER_DETAIL;
    DELETE FROM ANAPLAN.MD_CUSTOMER_DETAIL_T;
    INSERT INTO ANAPLAN.MD_CUSTOMER_DETAIL_T
    SELECT * FROM ANAPLAN.MD_CUSTOMER_DETAIL;

    -- Oracle commented-out block preserved:
    -- --BY data nowadays is separated
    -- --INSERT INTO anaplan.MD_CUSTOMER_DETAIL_T select * FROM anaplan.MD_CUSTOMER_DETAIL@LBM3PRD1_ANAPLAN;

    -- Oracle: delete from anaplan.td_sales_sum_daily_full where substr(invoicedate,0,6) between fromperiod and toperiod;
    -- PG    : SUBSTRING(x,1,6) replaces SUBSTR(x,0,6) (0-based->1-based)
    DELETE FROM ANAPLAN.TD_SALES_SUM_DAILY_FULL
     WHERE SUBSTRING(INVOICEDATE::TEXT, 1, 6) BETWEEN fromperiod AND toperiod;

    DELETE FROM ANAPLAN.TD_SALES_SUM_DAILY_FULL
     WHERE DIVISION IN ('100','300','400') AND INVOICEDATE = '0';

    INSERT INTO ANAPLAN.TD_SALES_SUM_DAILY_FULL
    SELECT
        CAST(dta.divi        AS VARCHAR(108)) AS DIVISION,
        CAST(dta.invoicedate AS VARCHAR(108)) AS INVOICEDATE,
        CAST(dta.deliverydate AS VARCHAR(108)) AS DELIVERYDATE,
        CAST(
            cu.DIVISION || '-' || cu.L2_SALESCHANNEL || '-' || cu.L3_CODE || '-' || cu.L4_CODE
            || CASE WHEN cu.L5_CODE = cu.L4_CODE THEN '' ELSE '-' || cu.L5_CODE END
            || '-' || cu.L6_CODE
        AS VARCHAR(108)) AS CUSTOMERCODE,
        CAST(dta.itemcode    AS VARCHAR(108)) AS ITEMCODE,
        ROUND(SUM(dta.volume), 4)             AS VOLUME,
        ROUND(SUM(dta.order_volume), 4)       AS ORDER_VOLUME,
        CAST(NULL AS VARCHAR(108))            AS ATTR1,
        CAST(NULL AS VARCHAR(108))            AS ATTR2,
        CAST(NULL AS VARCHAR(108))            AS ATTR3,
        -- Oracle: DECODE(trim(to_char(dta.campaign)),'1','1',null,'0','0')
        CAST(CASE WHEN TRIM(CAST(dta.campaign AS TEXT)) = '1' THEN '1' ELSE '0' END
        AS VARCHAR(108))                      AS CAMPAIGN
    FROM (
        SELECT
            ss.division                              AS divi,
            TO_CHAR(ss.invoicedate)                  AS invoicedate,
            TO_CHAR(ss.deliverydate)                 AS deliverydate,
            ss.customercode,
            ss.itemcode,
            ss.invoicequantity * c.volume            AS volume,
            ss.orderquantity   * c.volume            AS order_volume,
            ss.extra1                                AS campaign
        FROM bousr.bi_sales ss
        INNER JOIN bousr.bi_ordertypes_v ot
               ON ot.division = ss.division AND ot.ordertype = ss.ordertype
        INNER JOIN bousr.bi_product c
               ON ss.companycode = c.companycode AND ss.itemcode = c.itemcode
        WHERE
            (
                -- Oracle: SubStr(invoicedate,0,6) -> SUBSTRING(x,1,6)
                (SUBSTRING(ss.invoicedate::TEXT, 1, 6) BETWEEN fromperiod AND toperiod
                 OR SUBSTRING(ss.deliverydate::TEXT, 1, 6) BETWEEN fromperiod AND toperiod)
                OR (ss.division IN ('100','300','400')
                    AND ss.invoicedate = 0
                    AND SUBSTRING(ss.deliverydate::TEXT, 1, 6) BETWEEN fromperiod AND toperiod)
            )
            AND ot.ordertypegroup = 'NORMAL'
            AND c.itemtype = '10'
            AND (ss.iid = 'X' OR ss.division IN ('100','300','400'))
    ) dta
    LEFT JOIN ANAPLAN.MD_CUSTOMER_DETAIL_T cu ON cu.M3CUSTOMERCODE = dta.customercode
    GROUP BY
        cu.DIVISION || '-' || cu.L2_SALESCHANNEL || '-' || cu.L3_CODE || '-' || cu.L4_CODE
        || CASE WHEN cu.L5_CODE = cu.L4_CODE THEN '' ELSE '-' || cu.L5_CODE END
        || '-' || cu.L6_CODE,
        dta.divi, dta.itemcode, dta.invoicedate, dta.deliverydate,
        CASE WHEN TRIM(CAST(dta.campaign AS TEXT)) = '1' THEN '1' ELSE '0' END;

    -- Oracle: delete from anaplan.td_sales_sum_daily where (SubStr(invoicedate,0,6) between ...
    DELETE FROM ANAPLAN.TD_SALES_SUM_DAILY
     WHERE (SUBSTRING(INVOICEDATE::TEXT, 1, 6) BETWEEN fromperiod AND toperiod)
        OR  SUBSTRING(DELIVERYDATE::TEXT, 1, 6) BETWEEN fromperiod AND toperiod
        OR (INVOICEDATE = '0' AND SUBSTRING(DELIVERYDATE::TEXT, 1, 6) BETWEEN fromperiod AND toperiod);

    INSERT INTO ANAPLAN.TD_SALES_SUM_DAILY
    SELECT
        DIVISION,
        INVOICEDATE,
        DELIVERYDATE,
        CUSTOMERCODE,
        ITEMCODE,
        -- Oracle: REPLACE(TO_CHAR(VOLUME),'.',',')
        -- PG    : explicit format mask to guarantee 4 decimal places (TO_CHAR with no mask
        --         does not reproduce Oracle's default numeric formatting)
        REPLACE(TO_CHAR(VOLUME,       'FM9999999990.0000'), '.', ',') AS VOLUME,
        REPLACE(TO_CHAR(ORDER_VOLUME, 'FM9999999990.0000'), '.', ',') AS ORDER_VOLUME,
        -- Oracle: DECODE(CAMPAIGN,NULL,'0',CAMPAIGN)
        COALESCE(CAMPAIGN, '0') AS CAMPAIGN
    FROM ANAPLAN.TD_SALES_SUM_DAILY_FULL
    WHERE (SUBSTRING(INVOICEDATE::TEXT,  1, 6) BETWEEN fromperiod AND toperiod)
       OR  SUBSTRING(DELIVERYDATE::TEXT, 1, 6) BETWEEN fromperiod AND toperiod
       OR (INVOICEDATE = '0' AND SUBSTRING(DELIVERYDATE::TEXT, 1, 6) BETWEEN fromperiod AND toperiod);

    -- Oracle commented-out block preserved:
    -- --insert into anaplan.td_sales_sum_daily select * FROM M3SKY.td_sales_sum_daily WHERE ...

END;
$$;

COMMENT ON PROCEDURE ANAPLAN.PROC_SALES_DAILY_SUMMARIZE() IS
    'Refreshes md_customer_detail_t and daily sales summary tables for rolling 2-month window. Migrated from Oracle PROC_SALES_DAILY_SUMMARIZE - add_months/sysdate->INTERVAL/CURRENT_DATE, SUBSTR(x,0,6)->SUBSTRING(x,1,6), DECODE->CASE/COALESCE, anaplan.*->ANAPLAN.*, explicit TO_CHAR format mask for volume formatting.';

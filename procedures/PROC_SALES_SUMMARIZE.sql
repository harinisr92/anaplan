-- =============================================================================
-- PROCEDURE: ANAPLAN.PROC_SALES_SUMMARIZE()
-- =============================================================================
-- Migrated from: Oracle ANAPLAN.PROC_SALES_SUMMARIZE
-- Oracle conversions applied:
--   to_char(add_months(sysdate,-1),'YYYYMM') -> TO_CHAR(CURRENT_DATE - INTERVAL '1 month','YYYYMM')
--   to_char(sysdate,'YYYYMM')                -> TO_CHAR(CURRENT_DATE,'YYYYMM')
--   DECODE(botype,'DISCOUNT',boboam,0)       -> CASE WHEN botype='DISCOUNT' THEN boboam ELSE 0 END
--   CAST((0) AS NUMBER)                      -> CAST(0 AS NUMERIC)
--   anaplan.* schema                         -> ANAPLAN.*
--   M3SKY.*                          -> M3SKY.* (unchanged - compat schema)
--   COMMIT                                   -> not needed inside PL/pgSQL procedure
--   Commented-out Oracle lines preserved as comments for traceability
-- Behaviour: unchanged — refreshes md_customer_detail_t, rebuilds monthly
--            sales summary tables for rolling 2-month window,
--            appends Division 400 data from M3SKY
-- =============================================================================

CREATE OR REPLACE PROCEDURE ANAPLAN.PROC_SALES_SUMMARIZE()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Oracle: fromperiod varchar(20); toperiod varchar(20);
    fromperiod VARCHAR(20);
    toperiod   VARCHAR(20);
BEGIN
    -- Oracle: fromperiod := to_char(add_months(sysdate,-1),'YYYYMM');
    --         toperiod   := to_char(sysdate,'YYYYMM');
    fromperiod := TO_CHAR(CURRENT_DATE - INTERVAL '1 month', 'YYYYMM');
    toperiod   := TO_CHAR(CURRENT_DATE, 'YYYYMM');

    -- Oracle: DELETE FROM anaplan.MD_CUSTOMER_DETAIL_T;
    --         INSERT INTO anaplan.MD_CUSTOMER_DETAIL_T (select * FROM anaplan.MD_CUSTOMER_DETAIL);
    DELETE FROM ANAPLAN.MD_CUSTOMER_DETAIL_T;
    INSERT INTO ANAPLAN.MD_CUSTOMER_DETAIL_T
    SELECT * FROM ANAPLAN.MD_CUSTOMER_DETAIL;

    -- Oracle: delete from anaplan.td_sales_sum_full where period between fromperiod and toperiod;
    DELETE FROM ANAPLAN.TD_SALES_SUM_FULL
     WHERE PERIOD BETWEEN fromperiod AND toperiod;

    INSERT INTO ANAPLAN.TD_SALES_SUM_FULL
    SELECT
        CAST(dta.divi    AS VARCHAR(108)) AS DIVISION,
        CAST(dta.period  AS VARCHAR(108)) AS PERIOD,
        CAST(
            cu.DIVISION || '-' || cu.L2_SALESCHANNEL || '-' || cu.L3_CODE || '-' || cu.L4_CODE
            || CASE WHEN cu.L5_CODE = cu.L4_CODE THEN '' ELSE '-' || cu.L5_CODE END
            || '-' || cu.L6_CODE
        AS VARCHAR(108))                  AS CUSTOMERCODE,
        CAST(dta.itemcode AS VARCHAR(108)) AS ITEMCODE,
        ROUND(SUM(dta.volume),       4)   AS VOLUME,
        ROUND(SUM(dta.gross),        4)   AS GROSS,
        ROUND(SUM(dta.discount),     4)   AS DISCOUNT,
        ROUND(SUM(dta.excise),       4)   AS EXCISE,
        ROUND(SUM(dta.depofee),      4)   AS DEPOFEE,
        ROUND(SUM(dta.salesbonus),   4)   AS SALESBONUS,
        ROUND(SUM(dta.netsales - dta.salesbonus), 4) AS NETSALES,
        ROUND(SUM(dta.cogs),         4)   AS COGS,
        ROUND(SUM(dta.promodiscount),4)   AS PROMODISCOUNT,
        -- Oracle: CAST((0) AS NUMBER)
        CAST(0 AS NUMERIC)                AS EXT_M1,
        CAST(0 AS NUMERIC)                AS EXT_M2,
        CAST(0 AS NUMERIC)                AS EXT_M3,
        CAST(NULL AS VARCHAR(108))        AS ATTR1,
        CAST(NULL AS VARCHAR(108))        AS ATTR2,
        CAST(NULL AS VARCHAR(108))        AS ATTR3,
        ROUND(SUM(dta.deliverycost),  4)  AS DELIVERYCOST,
        ROUND(SUM(dta.campaignvolume),4)  AS CAMPAIGNVOLUME
    FROM (
        -- ── BI_SALES from OSBSTD, aggregated to month ─────────────────────
        SELECT
            md.divi,
            TO_CHAR(period)                                                    AS period,
            CASE WHEN cv.NEWCUSTOMER IS NULL
                 THEN md.customercode
                 ELSE cv.NEWCUSTOMER
            END                                                                AS customercode,
            itemcode,
            SUM(md.volume)    AS volume,
            SUM(md.netsales)  AS netsales,
            SUM(md.discount)  AS discount,
            0                 AS promodiscount,
            SUM(md.excise)    AS excise,
            SUM(md.depofee)   AS depofee,
            0                 AS salesbonus,
            SUM(md.gross)     AS gross,
            SUM(md.totalcogs) AS cogs,
            0                 AS deliverycost,
            SUM(CASE
                    WHEN md.divi IN ('100','300') THEN 0
                    WHEN extra4 = '0'   THEN 0
                    WHEN extra4 IS NULL THEN 0
                    WHEN extra4 = ' '   THEN 0
                    WHEN extra4 = ''    THEN 0
                    ELSE md.volume
                END)          AS campaignvolume
        FROM bousr.prep_monthlysales md
        LEFT JOIN ANAPLAN.AD_CUSTOMER_CONVERSION cv
               ON md.divi = cv.DIVI AND md.customercode = cv.OLDCUSTOMER
        INNER JOIN bousr.bi_ordertypes_v ot ON ot.ordertype = md.ordertype
        WHERE md.period BETWEEN fromperiod AND toperiod
          AND ot.ordertypegroup = 'NORMAL'
        GROUP BY
            md.divi, period,
            CASE WHEN cv.NEWCUSTOMER IS NULL THEN md.customercode ELSE cv.NEWCUSTOMER END,
            itemcode

        UNION ALL

        -- ── Sales adjustments (bonus/promo/discount) ──────────────────────
        SELECT
            bodivi AS divi,
            CAST(boperi AS VARCHAR(108)) AS period,
            CASE WHEN cv.NEWCUSTOMER IS NULL
                 THEN CASE WHEN bocuno IS NULL THEN bopyno ELSE bocuno END
                 ELSE cv.NEWCUSTOMER
            END    AS customercode,
            boitno AS itemcode,
            0      AS volume,
            0      AS netsales,
            -- Oracle: Sum(DECODE(botype,'DISCOUNT',boboam,0))
            SUM(CASE WHEN botype = 'DISCOUNT'   THEN boboam ELSE 0 END) AS discount,
            SUM(CASE WHEN botype = 'PROMO'      THEN boboam ELSE 0 END) AS promodiscount,
            0 AS excise,
            0 AS depofee,
            SUM(CASE WHEN botype = 'SALESBONUS' THEN boboam ELSE 0 END) AS salesbonus,
            0 AS gross,
            0 AS cogs,
            0 AS deliverycost,
            0 AS campaignvolume
        FROM bousr.prep_salesadjustments
        LEFT JOIN ANAPLAN.AD_CUSTOMER_CONVERSION cv
               ON bodivi = cv.DIVI
              AND CASE WHEN bocuno IS NULL THEN bopyno ELSE bocuno END = cv.OLDCUSTOMER
        WHERE (botype = 'SALESBONUS'
               OR (bodivi = '800' AND botype IN ('PROMO','DISCOUNT')))
          AND boperi BETWEEN fromperiod AND toperiod
        GROUP BY
            bodivi, boperi,
            CASE WHEN cv.NEWCUSTOMER IS NULL
                 THEN CASE WHEN bocuno IS NULL THEN bopyno ELSE bocuno END
                 ELSE cv.NEWCUSTOMER
            END,
            boitno
    ) dta
    LEFT JOIN ANAPLAN.MD_CUSTOMER_DETAIL_T cu
           ON cu.M3CUSTOMERCODE = dta.customercode AND dta.divi = cu.DIVISION
    GROUP BY
        cu.DIVISION || '-' || cu.L2_SALESCHANNEL || '-' || cu.L3_CODE || '-' || cu.L4_CODE
        || CASE WHEN cu.L5_CODE = cu.L4_CODE THEN '' ELSE '-' || cu.L5_CODE END
        || '-' || cu.L6_CODE,
        dta.divi, dta.itemcode, dta.period;

    -- Oracle: delete from anaplan.td_sales_sum where period between fromperiod and toperiod;
    --         insert into anaplan.td_sales_sum (select * from anaplan.td_sales_sum_full where period...);
    DELETE FROM ANAPLAN.TD_SALES_SUM
     WHERE PERIOD BETWEEN fromperiod AND toperiod;

    INSERT INTO ANAPLAN.TD_SALES_SUM
    SELECT * FROM ANAPLAN.TD_SALES_SUM_FULL
     WHERE PERIOD BETWEEN fromperiod AND toperiod;

    -- Oracle: delete from anaplan.td_sales_sum where DIVISION='400' and period...;
    --         insert into anaplan.td_sales_sum (select * from M3SKY.TD_SALES_SUM where division='400'...);
    DELETE FROM ANAPLAN.TD_SALES_SUM
     WHERE DIVISION = '400' AND PERIOD BETWEEN fromperiod AND toperiod;

    INSERT INTO ANAPLAN.TD_SALES_SUM
    SELECT * FROM M3SKY.TD_SALES_SUM
     WHERE DIVISION = '400' AND PERIOD BETWEEN fromperiod AND toperiod;

END;
$$;

COMMENT ON PROCEDURE ANAPLAN.PROC_SALES_SUMMARIZE() IS
    'Refreshes md_customer_detail_t and monthly sales summary tables for rolling 2-month window, appends Division 400 from M3SKY. Migrated from Oracle PROC_SALES_SUMMARIZE - add_months/sysdate->INTERVAL/CURRENT_DATE, DECODE->CASE, NUMBER->NUMERIC, anaplan.*->ANAPLAN.*, COMMIT removed (PL/pgSQL handles transactions).';

CREATE OR REPLACE VIEW ANAPLAN.AD_SALES_CHECK_ITEM AS
WITH sales_src AS (
    SELECT
        ITEMCODE,
        VOLUME,
        PERIOD
    FROM ANAPLAN.TD_SALES_SUM_FULL
    WHERE PERIOD BETWEEN
        TO_CHAR(CURRENT_DATE - INTERVAL '24 months','YYYY') || '01'
        AND TO_CHAR(CURRENT_DATE,'YYYYMM')
)
SELECT
    itemcode,
    SUM(volume) AS salesvolume
FROM sales_src
GROUP BY itemcode;

COMMENT ON VIEW ANAPLAN.AD_SALES_CHECK_ITEM IS
    'Items with sales volume in rolling 24-month window. Reads table td_sales_sum_full (not a view).';
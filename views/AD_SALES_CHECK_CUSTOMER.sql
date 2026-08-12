CREATE OR REPLACE VIEW ANAPLAN.AD_SALES_CHECK_CUSTOMER AS
WITH customer_src AS (
    SELECT
        CUSTOMERCODE,
        VOLUME,
        PERIOD
    FROM ANAPLAN.TD_SALES_SUM_FULL
    WHERE PERIOD BETWEEN
        TO_CHAR(CURRENT_DATE - INTERVAL '24 months','YYYY') || '01'
        AND TO_CHAR(CURRENT_DATE,'YYYYMM')
)
SELECT
    customercode,
    SUM(volume) AS salesvolume
FROM customer_src
GROUP BY customercode
HAVING SUM(volume) <> 0;

COMMENT ON VIEW ANAPLAN.AD_SALES_CHECK_CUSTOMER IS
    'Customers with non-zero sales volume in rolling 24-month window. Reads table td_sales_sum_full (not a view).';
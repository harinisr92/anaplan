CREATE OR REPLACE VIEW ANAPLAN.TD_COGS_LATESTCOST AS

WITH
    CTE_LATEST_COST AS (
        SELECT
            divi,
            product,
            costcomponent,
            eurl
        FROM bousr.m_detailed_costing_hst
        WHERE period = 'NOW'
          AND costcomponent NOT IN ('A03B','A03T')
          AND divi NOT IN ('400')
    ),
    CTE_AGGREGATED_COST AS (
        SELECT
            divi,
            product,
            costcomponent,
            ROUND(SUM(eurl)::NUMERIC, 4) AS eurperl
        FROM CTE_LATEST_COST
        GROUP BY
            divi,
            product,
            costcomponent
    )
SELECT
    divi,
    product,
    costcomponent,
    eurperl
FROM CTE_AGGREGATED_COST

UNION ALL

SELECT
    DIVI,
    PRODUCT,
    COSTCOMPONENT,
    EURPERL
FROM M3SKY.TD_COGS_LATESTCOST
WHERE DIVI = '400';

COMMENT ON VIEW ANAPLAN.TD_COGS_LATESTCOST IS
    'Latest cost per product/costcomponent. Source: bousr.m_detailed_costing_hst; division 400 from M3SKY compat schema.';
CREATE OR REPLACE VIEW ANAPLAN.TD_NATUREBASED_COGS AS
SELECT
    CAST(company AS VARCHAR(3)) AS division,
    CAST(company AS VARCHAR(3)) || '_' || ait2 AS costcenter,
    period,
    COALESCE(
        nl.is_line_label,
        CASE
            WHEN source LIKE '2.1%' THEN 'Other production costs'
            WHEN source LIKE '5%'   THEN 'Other production costs'
            WHEN source LIKE '0%'   THEN 'Balancing'
            WHEN source LIKE '9%'   THEN 'Change of inventory of WIP and fin prod'
            ELSE 'Other production costs'
        END
    ) AS is_line,
    SUM(eur) AS amount
FROM bousr.fpm_vs11000_hst m
LEFT JOIN LATERAL (
    SELECT r.IS_LINE_LABEL
    FROM ref.NATUREBASED_COGS_IS_LINE r
    WHERE (r.MATCH_TYPE = 'EXACT' AND r.AIT1_VALUE = m.ait1)
       OR (r.MATCH_TYPE = 'LIKE'  AND m.ait1 LIKE r.AIT1_VALUE
           AND r.AIT1_VALUE LIKE '9%')   -- only ait1-targeted LIKE rows
    ORDER BY r.SORT_ORDER
    LIMIT 1
) nl ON TRUE
WHERE period >= '202101'
  AND company NOT IN ('800','400')
  AND ait1 NOT LIKE '9001%'
GROUP BY company, period, ait2,
    COALESCE(
        nl.is_line_label,
        CASE
            WHEN source LIKE '2.1%' THEN 'Other production costs'
            WHEN source LIKE '5%'   THEN 'Other production costs'
            WHEN source LIKE '0%'   THEN 'Balancing'
            WHEN source LIKE '9%'   THEN 'Change of inventory of WIP and fin prod'
            ELSE 'Other production costs'
        END
    )

UNION ALL

SELECT division, costcenter, period, is_line, amount
FROM LIDSKOE.TD_NATUREBASED_COGS WHERE division = '800'

UNION ALL

SELECT division, costcenter, period, is_line, amount
FROM M3SKY.TD_NATUREBASED_COGS WHERE division = '400';

COMMENT ON VIEW ANAPLAN.TD_NATUREBASED_COGS IS
    'Nature-based COGS by account line. Uses ref.NATUREBASED_COGS_IS_LINE for ait1 matches; preserves source LIKE fallback; compatibility unions to LIDSKOE/M3SKY.';
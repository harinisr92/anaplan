CREATE OR REPLACE VIEW ANAPLAN.MD_DELIVERYGROUPS AS
WITH source AS (
    SELECT DISTINCT
        ctstky AS deliverygroup,
        CASE
            WHEN NULLIF(REPLACE(SUBSTRING(ctparm,37,6),' ',''),'')::NUMERIC > 0
            THEN NULLIF(REPLACE(SUBSTRING(ctparm,37,6),' ',''),'')::NUMERIC
            ELSE 0
        END AS weight
    FROM MVXJDTA.CSYTAB
    WHERE ctcono = 100
      AND ctstco = 'MODL'
      AND ctstky BETWEEN '100' AND '900'
)
SELECT deliverygroup, weight
FROM source

UNION ALL

SELECT '999-NA' AS deliverygroup, 1 AS weight;

COMMENT ON VIEW ANAPLAN.MD_DELIVERYGROUPS IS
    'Delivery group codes and their weight values. Oracle FROM DUAL removed; TO_NUMBER/REPLACE → ::NUMERIC cast with NULLIF.';
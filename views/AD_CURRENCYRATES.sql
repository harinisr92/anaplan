CREATE OR REPLACE VIEW ANAPLAN.AD_CURRENCYRATES AS
WITH source_bousr AS (
    SELECT
        divi              AS division,
        period,
        conversioncurrency,
        ROUND(rate, 4)    AS rate
    FROM bousr.prep_currencyrates
    WHERE divi NOT IN ('400')
),
source_m3sky AS (
    SELECT
        DIVISION,
        PERIOD,
        CONVERSIONCURRENCY,
        RATE
    FROM M3SKY.AD_CURRENCYRATES
    WHERE DIVISION IN ('400')
)
SELECT * FROM source_bousr
UNION ALL
SELECT * FROM source_m3sky;

COMMENT ON VIEW ANAPLAN.AD_CURRENCYRATES IS
    'Currency conversion rates by division and period. Division 400 from M3SKY compat table.';
CREATE OR REPLACE VIEW ANAPLAN.AD_CURRENCYRATES_LAST AS
WITH max_date AS (
    SELECT cucono,
           cudivi,
           culocd,
           cucucd,
           MAX(cucutd) AS cucutd
    FROM MVXJDTA.CCURRA
    WHERE cucono = 100
      AND cudivi <> ' '
      AND cucrtp = 1
    GROUP BY cucono, cucucd, cudivi, culocd
),
mvx_source AS (
    SELECT
        curr.cudivi AS division,
        curr.culocd AS localcurrency,
        curr.cucucd AS conversioncurrency,
        curr.cuarat AS rate,
        curr.cucutd AS max_date
    FROM MVXJDTA.CCURRA curr
    JOIN max_date
      ON max_date.cucono = curr.cucono
     AND max_date.cudivi = curr.cudivi
     AND max_date.cucucd = curr.cucucd
     AND max_date.cucutd = curr.cucutd
    WHERE curr.cucrtp = 1
      AND curr.cudivi NOT IN ('800','400')
),
lidskoe_source AS (
    SELECT DIVISION,
           LOCALCURRENCY,
           CONVERSIONCURRENCY,
           1.0 / RATE AS rate,
           MAX_DATE
    FROM LIDSKOE.AD_CURRENCYRATES_LAST
    WHERE DIVISION = '800'
),
m3sky_source AS (
    SELECT DIVISION,
           LOCALCURRENCY,
           CONVERSIONCURRENCY,
           1.0 / RATE AS rate,
           MAX_DATE
    FROM M3SKY.AD_CURRENCYRATES_LAST
    WHERE DIVISION = '400'
)
SELECT * FROM mvx_source
UNION ALL
SELECT * FROM lidskoe_source
UNION ALL
SELECT * FROM m3sky_source;

COMMENT ON VIEW ANAPLAN.AD_CURRENCYRATES_LAST IS
    'Most recent currency rate per division. LIDSKOE and M3SKY compat tables used for divisions 800 and 400.';
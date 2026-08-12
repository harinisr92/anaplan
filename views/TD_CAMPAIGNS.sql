CREATE OR REPLACE VIEW ANAPLAN.TD_CAMPAIGNS AS
WITH
    CTE_DIV200 AS (
        SELECT
            '200'::VARCHAR AS division,
            '200_DOMESTIC'::VARCHAR AS l1_region,
            period AS month,
            chain,
            item AS itemcode,
            selling_in_from,
            campaign_time_to,
            TO_CHAR(TO_DATE(selling_in_from::TEXT, 'YYYYMMDD'), 'IYYYIW') AS week,
            SUM(campaign_volume) AS campaign_ltr
        FROM alc.campinfo200
        WHERE campaign_time_to >= 20230401
          AND confirmed IN ('Yes','Bron')
        GROUP BY period, chain, item, selling_in_from, campaign_time_to
    ),
    CTE_DIV600 AS (
        SELECT
            '600'::VARCHAR AS division,
            '600_DOMESTIC'::VARCHAR AS l1_region,
            TO_CHAR(pp.a02_campaign_begin, 'YYYYMM') AS month,
            ok.okcfc1 AS chain,
            dd.a02_prod_id AS itemcode,
            TO_NUMBER(TO_CHAR(pp.a02_supply_begin, 'YYYYMMDD'), '99999999') AS selling_in_from,
            TO_NUMBER(TO_CHAR(pp.a02_campaign_end, 'YYYYMMDD'), '99999999') AS campaign_time_to,
            TO_CHAR(pw.a02_week_start_date, 'YYYYMMDD') AS week,
            SUM(pw.a02_plan_liter) AS campaign_ltr
        FROM ve.a02v_campaign_plan_h hh
        INNER JOIN ve.a02_campaign_plan_d dd
            ON dd.a02_plan_id = hh.plan_id
        LEFT JOIN ve.a02_campaign_planned pp
            ON pp.a02_plan_id = dd.a02_plan_id
           AND pp.a02_prod_id = dd.a02_prod_id
        LEFT JOIN (
            SELECT a02_plan_id, a02_prod_id, a02_week_start_date, SUM(a02_plan_liter) AS a02_plan_liter
            FROM ve.a02_campaign_planned_w
            GROUP BY a02_plan_id, a02_prod_id, a02_week_start_date
            HAVING SUM(a02_plan_liter) >= 1
        ) pw
            ON pw.a02_plan_id = pp.a02_plan_id
           AND pw.a02_prod_id = pp.a02_prod_id
        LEFT JOIN MVXJDTA.OCUSMA ok
            ON ok.okcuno = hh.customer_id
        WHERE pw.a02_plan_liter IS NOT NULL
          AND pp.a02_status = 'GOING'
        GROUP BY pp.a02_campaign_begin, ok.okcfc1, dd.a02_prod_id, pp.a02_supply_begin, pp.a02_campaign_end, pw.a02_week_start_date
    ),
    CTE_DIV700 AS (
        SELECT
            '700'::VARCHAR AS division,
            '700_DOMESTIC'::VARCHAR AS l1_region,
            ROUND(cowest / 100.0, 0)::TEXT AS month,
            cochain AS chain,
            coitno AS itemcode,
            TO_NUMBER(cofrdt::TEXT, '99999999') AS selling_in_from,
            TO_NUMBER(cotodt::TEXT, '99999999') AS campaign_time_to,
            TO_CHAR(TO_DATE(cowest::TEXT, 'YYYYMMDD'), 'IYYYIW') AS week,
            ROUND(SUM(covol3)) AS campaign_ltr
        FROM cesu.campinfo200
        WHERE costatus <> 9
        GROUP BY cowest, cochain, coitno, cofrdt, cotodt
    )
SELECT * FROM CTE_DIV200

UNION ALL

SELECT * FROM CTE_DIV600

UNION ALL

SELECT * FROM CTE_DIV700

UNION ALL

SELECT
    DIVISION,
    L1_REGION,
    MONTH,
    CHAIN,
    ITEMCODE,
    SELLING_IN_FROM,
    CAMPAIGN_TIME_TO,
    WEEK,
    CAMPAIGN_LTR
FROM M3SKY.TD_CAMPAIGNS
WHERE DIVISION = '400';

COMMENT ON VIEW ANAPLAN.TD_CAMPAIGNS IS
    'Campaign volume by division/month/chain/item. Divisions: 200 (alc.campinfo200), 600 (ve campaign-planning schema), 700 (cesu.campinfo200), 400 (M3SKY compat schema).';
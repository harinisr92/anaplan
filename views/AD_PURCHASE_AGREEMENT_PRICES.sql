CREATE OR REPLACE VIEW ANAPLAN.AD_PURCHASE_AGREEMENT_PRICES AS
WITH
periods AS (
    SELECT TO_CHAR(CURRENT_DATE + (n || ' months')::INTERVAL, 'YYYYMM') AS period
    FROM generate_series(0, 19) AS gs(n)   -- ~19 months forward ≈ 580 days
),
itemprice AS (
    SELECT gr.ajcono, gr.ajsuno, gr.ajobv1,
           gr.ajfvdt AS aifvdt, rl.aiuvdt, hh.ahcucd, gr.ajpupr, wh.mwfaci
    FROM MVXJDTA.MPAGRP gr
    LEFT JOIN MVXJDTA.MPAGRL rl
           ON rl.aicono = gr.ajcono
          AND rl.aiobv1 = gr.ajobv1
          AND rl.aisuno = gr.ajsuno
          AND rl.aiseqn = gr.ajseqn
          AND rl.aiagnb = gr.ajagnb
    LEFT JOIN MVXJDTA.MPAGRH hh
           ON rl.aicono = hh.ahcono
          AND rl.aiagnb = hh.ahagnb
          AND hh.ahsuno = rl.aisuno
    LEFT JOIN MVXJDTA.MITWHL wh
           ON wh.mwcono = hh.ahcono
          AND wh.mwwhlo = hh.ahwhlo
    WHERE rl.aiuvdt > TO_CHAR(CURRENT_DATE,'YYYYMMDD')::integer
      AND rl.aisagl <> '90'
      AND hh.ahpast = '40'
      AND gr.ajmapr = '1'
      AND gr.ajpupr > 0
      AND gr.ajsuno NOT IN (
          SELECT SUPPLIERCODE
          FROM ref.EXCLUDED_INTERNAL_SUPPLIER_CODES
      )
),
prgroupprice AS (
    SELECT gr.ajcono, gr.ajsuno, gr.ajobv1,
           gr.ajfvdt AS aifvdt, rl.aiuvdt, hh.ahcucd, gr.ajpupr, wh.mwfaci
    FROM MVXJDTA.MPAGRP gr
    LEFT JOIN MVXJDTA.MPAGRL rl
           ON rl.aicono = gr.ajcono
          AND rl.aiobv1 = gr.ajobv1
          AND rl.aisuno = gr.ajsuno
          AND rl.aiseqn = gr.ajseqn
          AND rl.aiagnb = gr.ajagnb
    LEFT JOIN MVXJDTA.MPAGRH hh
           ON rl.aicono = hh.ahcono
          AND rl.aiagnb = hh.ahagnb
          AND hh.ahsuno = rl.aisuno
    LEFT JOIN MVXJDTA.MITWHL wh
           ON wh.mwcono = hh.ahcono
          AND wh.mwwhlo = hh.ahwhlo
    WHERE rl.aiuvdt > TO_CHAR(CURRENT_DATE,'YYYYMMDD')::integer
      AND rl.aisagl <> '90'
      AND hh.ahpast = '40'
      AND gr.ajmapr = '1'
      AND gr.ajpupr > 0
      AND gr.ajsuno NOT IN (
          SELECT SUPPLIERCODE
          FROM ref.EXCLUDED_INTERNAL_SUPPLIER_CODES
      )
),
groupprice AS (
    SELECT gr.ajcono, gr.ajsuno, gr.ajobv1,
           gr.ajfvdt AS aifvdt, rl.aiuvdt, hh.ahcucd, gr.ajpupr, wh.mwfaci
    FROM MVXJDTA.MPAGRP gr
    LEFT JOIN MVXJDTA.MPAGRL rl
           ON rl.aicono = gr.ajcono
          AND rl.aiobv1 = gr.ajobv1
          AND rl.aisuno = gr.ajsuno
          AND rl.aiseqn = gr.ajseqn
          AND rl.aiagnb = gr.ajagnb
    LEFT JOIN MVXJDTA.MPAGRH hh
           ON rl.aicono = hh.ahcono
          AND rl.aiagnb = hh.ahagnb
          AND hh.ahsuno = rl.aisuno
    LEFT JOIN MVXJDTA.MITWHL wh
           ON wh.mwcono = hh.ahcono
          AND wh.mwwhlo = hh.ahwhlo
    WHERE rl.aiuvdt > TO_CHAR(CURRENT_DATE,'YYYYMMDD')::integer
      AND rl.aisagl <> '90'
      AND hh.ahpast = '40'
      AND gr.ajmapr = '1'
      AND gr.ajpupr > 0
      AND gr.ajsuno NOT IN (
          SELECT SUPPLIERCODE
          FROM ref.EXCLUDED_INTERNAL_SUPPLIER_CODES
      )
),
base AS (
    SELECT
        mm.mmcono                               AS cono,
        mm.mmitno                               AS itemcode,
        COALESCE(ip.mwfaci, pg.mwfaci, gg.mwfaci, mf.m9faci) AS division,
        COALESCE(ip.ajsuno, pg.ajsuno, gg.ajsuno, mf.m9faci) AS supplier,
        COALESCE(ip.aifvdt, pg.aifvdt, gg.aifvdt)            AS valid_from,
        COALESCE(ip.aiuvdt, pg.aiuvdt, gg.aiuvdt)            AS valid_until,
        COALESCE(ip.ajpupr, pg.ajpupr, gg.ajpupr)            AS pur_price,
        COALESCE(ip.ahcucd, pg.ahcucd, gg.ahcucd)            AS curency,
        mm.mmppun                               AS price_um,
        mm.mmunms                               AS bum
    FROM MVXJDTA.MITMAS mm
    LEFT JOIN itemprice    ip ON ip.ajcono = mm.mmcono AND ip.ajobv1 = mm.mmitno
    LEFT JOIN prgroupprice pg ON pg.ajcono = mm.mmcono AND pg.ajobv1 = mm.mmprgp
    LEFT JOIN groupprice   gg ON gg.ajcono = mm.mmcono AND gg.ajobv1 = mm.mmitgr
    LEFT JOIN MVXJDTA.MITFAC mf ON mf.m9itno = mm.mmitno AND mf.m9cono = mm.mmcono
    WHERE mm.mmitty IN ('20','30','85')
),
enriched AS (
    SELECT
        b.cono,
        b.itemcode,
        b.division,
        b.supplier,
        b.curency,
        TO_CHAR(TO_DATE(b.valid_from::TEXT,'YYYYMMDD'),'YYYYMM') AS valid_from_ym,
        CASE WHEN b.valid_until::TEXT = '99999999'
             THEN TO_CHAR(CURRENT_DATE + INTERVAL '580 days','YYYYMM')
             ELSE TO_CHAR(TO_DATE(b.valid_until::TEXT,'YYYYMMDD'),'YYYYMM')
        END AS valid_until_ym,
        CASE WHEN mu.mudmcf = '1' THEN b.pur_price / mu.mucofa
             WHEN mu.mudmcf = '2' THEN b.pur_price * mu.mucofa
             ELSE b.pur_price
        END AS bum_price
    FROM base b
    LEFT JOIN MVXJDTA.CIDMAS ci
           ON ci.idcono = b.cono
          AND b.supplier = ci.idsuno
    LEFT JOIN MVXJDTA.MITAUN mu
           ON mu.mucono = b.cono
          AND mu.muautp = '2'
          AND mu.muitno = b.itemcode
          AND mu.mualun = b.price_um
    WHERE b.pur_price > 0
)
SELECT
    e.division,
    e.itemcode,
    e.curency,
    p.period,
    MAX(e.bum_price) AS price_bum
FROM enriched e
LEFT JOIN periods p
       ON p.period BETWEEN e.valid_from_ym AND e.valid_until_ym
WHERE e.cono::TEXT = '100'
  AND e.division NOT IN ('800','400')
GROUP BY e.division, e.itemcode, e.curency, p.period

UNION ALL

SELECT division, itemcode, curency, period, price_bum
FROM LIDSKOE.AD_PURCHASE_AGREEMENT_PRICES
WHERE division = '800'

UNION ALL

SELECT division, itemcode, curency, period, price_bum
FROM M3SKY.AD_PURCHASE_AGREEMENT_PRICES
WHERE division IN ('400');

COMMENT ON VIEW ANAPLAN.AD_PURCHASE_AGREEMENT_PRICES IS
    'Purchase agreement prices expanded by period. CONNECT BY LEVEL → generate_series; @LBM3PRD1_ANAPLAN DB link → LIDSKOE compat table; sysdate → CURRENT_DATE.';
CREATE OR REPLACE VIEW ANAPLAN.TD_COGS_RECIPE AS

WITH RECURSIVE

/* ==========================================================
   Recipe Base
   ========================================================== */
CTE_RECIPE_BASE AS (
    SELECT
        r.pmcono,
        r.pmfaci,
        r.pmprno,
        r.pmstrt,
        r.pmmtno,
        r.pmmseq,
        r.pmpeun,
        ROUND(
            (
                (
                    CASE
                        WHEN r.pmwapc <> 0::numeric THEN r.pmwapc
                        WHEN mat.mmwapc <> 0::numeric THEN mat.mmwapc
                        ELSE 0::numeric
                    END + 100::numeric
                )
                * r.pmcnqt
                * CASE WHEN r.pmbypr = 0 THEN 1 ELSE -1 END::numeric
                / 100::numeric
                / CASE WHEN h.phbaqt = 0::numeric THEN 1::numeric ELSE h.phbaqt END
            ),
            8
        ) AS pmcnqt,
        ROUND(
            CASE WHEN r.pmbypr = 0 THEN 1 ELSE -1 END::numeric
            * r.pmcnqt
            / CASE WHEN h.phbaqt = 0::numeric THEN 1::numeric ELSE h.phbaqt END,
            8
        ) AS pmcnqt2
    FROM MVXJDTA.MPDMAT r
    JOIN MVXJDTA.MITMAS mat
      ON mat.mmcono = r.pmcono
     AND mat.mmitno::text = r.pmmtno::text
    JOIN MVXJDTA.MPDHED h
      ON h.phcono = r.pmcono
     AND h.phfaci::text = r.pmfaci::text
     AND h.phstrt::text = r.pmstrt::text
     AND h.phprno::text = r.pmprno::text
    WHERE r.pmcono = 100
      AND r.pmfaci::text <> '800'::text
      AND r.pmstrt::text = '100'::text
      AND r.pmmtno::text <> '2400999'::text
),

/* ==========================================================
   Recursive Recipe Explosion
   Keeps expression text for receipt_multiplier compatibility.
   ========================================================== */
CTE_RECIPE_RECURSIVE AS (
    SELECT DISTINCT
        rb.pmcono,
        rb.pmfaci,
        rb.pmprno,
        rb.pmprno AS root_id,
        rb.pmmtno,
        rb.pmmseq,
        rb.pmcnqt,
        rb.pmcnqt2,
        1 AS level,
        rb.pmcnqt::varchar AS formula_text_all
    FROM CTE_RECIPE_BASE rb

    UNION ALL

    SELECT DISTINCT
        child.pmcono,
        child.pmfaci,
        child.pmprno,
        parent.root_id,
        child.pmmtno,
        child.pmmseq,
        child.pmcnqt,
        child.pmcnqt2,
        parent.level + 1 AS level,
        parent.formula_text_all || '*' || child.pmcnqt::varchar AS formula_text_all
    FROM CTE_RECIPE_BASE child
    JOIN CTE_RECIPE_RECURSIVE parent
      ON parent.pmmtno::text = child.pmprno::text
),

/* ==========================================================
   Leaf Materials Only
   ========================================================== */
CTE_RECIPE_LEAF AS (
    SELECT
        r.pmcono,
        r.pmfaci,
        r.pmprno,
        r.root_id,
        r.pmmtno,
        r.pmmseq,
        r.pmcnqt,
        r.pmcnqt2,
        r.level,
        r.formula_text_all
    FROM CTE_RECIPE_RECURSIVE r
    WHERE NOT EXISTS (
        SELECT 1
        FROM CTE_RECIPE_RECURSIVE r2
        WHERE r2.pmprno::text = r.pmmtno::text
    )
),

/* ==========================================================
   Unit Conversion
   ========================================================== */
CTE_UNIT_CONVERSION AS (
    SELECT DISTINCT
        r.pmfaci AS faci,
        r.pmprno AS prod,
        r.pmmtno AS mat,
        r.pmpeun,
        mat.mmunms,
        CASE
            WHEN u.mudmcf = 2 THEN 1::numeric / u.mucofa
            WHEN u.mudmcf = 1 THEN 1::numeric * u.mucofa
            ELSE 1::numeric
        END AS conv_f
    FROM MVXJDTA.MPDMAT r
    JOIN MVXJDTA.MITMAS mat
      ON mat.mmcono = r.pmcono
     AND mat.mmitno::text = r.pmmtno::text
    JOIN MVXJDTA.MITAUN u
      ON u.mucono = mat.mmcono
     AND u.muitno::text = mat.mmitno::text
     AND u.muautp = 1
    WHERE r.pmfaci::numeric = 100::numeric
      AND mat.mmitty::text <> '10'::text
      AND mat.mmunms::text <> r.pmpeun::text
),

/* ==========================================================
   Full Recipe
   Restores receipt_multiplier expression evaluation.
   ========================================================== */
CTE_FULL_RECIPE AS (
    SELECT
        leaf.pmcono,
        leaf.pmfaci,
        leaf.root_id,
        leaf.pmprno,
        leaf.pmmtno,
        leaf.pmmseq,
        leaf.pmcnqt,
        leaf.pmcnqt2,
        COALESCE(conv.conv_f, 1::numeric) AS unms_convertformula,
        ROUND(bousr.receipt_multiplier('1' || leaf.formula_text_all)::numeric, 6)
            * COALESCE(conv.conv_f, 1::numeric) AS full_qty,
        ROUND(bousr.receipt_multiplier('1' || leaf.formula_text_all)::numeric, 6) AS formula
    FROM CTE_RECIPE_LEAF leaf
    JOIN MVXJDTA.MITMAS mat
      ON mat.mmcono = leaf.pmcono
     AND mat.mmitno::text = leaf.pmmtno::text
     AND mat.mmitty::text <> ALL (ARRAY['10'::varchar, '40'::varchar]::text[])
    LEFT JOIN CTE_UNIT_CONVERSION conv
      ON conv.faci::text = leaf.pmfaci::text
     AND conv.prod::text = leaf.pmprno::text
     AND conv.mat::text = leaf.pmmtno::text
),

/* ==========================================================
   1. Standard Recipes
   ========================================================== */
CTE_STANDARD_RECIPES AS (
    SELECT
        fr.pmcono AS cono,
        fr.pmfaci AS divi,
        fr.root_id AS product,
        fr.pmmtno AS material,
        SUM(fr.full_qty * 1000::numeric) AS qty1000
    FROM CTE_FULL_RECIPE fr
    JOIN MVXJDTA.MITFAC mf
      ON mf.m9cono = fr.pmcono
     AND mf.m9faci::text = fr.pmfaci::text
     AND mf.m9itno::text = fr.root_id::text
    WHERE mf.m9vamt::text = '1'::text
    GROUP BY fr.pmcono, fr.pmfaci, fr.root_id, fr.pmmtno
),

/* ==========================================================
   2. Ready Products with Purchased Sub-materials
   ========================================================== */
CTE_READY_PRODUCTS AS (
    SELECT
        p1.mmcono AS cono,
        f1.m9faci AS divi,
        p1.mmitno AS product,
        m1.mmitno AS material,
        ROUND(1000::numeric * r1.pmcnqt, 6) AS qty1000
    FROM MVXJDTA.MITMAS p1
    JOIN MVXJDTA.MITFAC f1
      ON f1.m9cono = p1.mmcono
     AND f1.m9itno::text = p1.mmitno::text
    LEFT JOIN MVXJDTA.MPDMAT r1
      ON r1.pmcono = p1.mmcono
     AND r1.pmfaci::text = f1.m9faci::text
     AND r1.pmprno::text = p1.mmitno::text
     AND r1.pmstrt::text = '100'::text
    LEFT JOIN MVXJDTA.MITMAS m1
      ON m1.mmcono = r1.pmcono
     AND m1.mmitno::text = r1.pmmtno::text
     AND m1.mmitty::text <> '90'::text
    LEFT JOIN MVXJDTA.MITFAC f2
      ON f2.m9cono = m1.mmcono
     AND f2.m9itno::text = m1.mmitno::text
     AND f2.m9faci::text = f1.m9faci::text
    LEFT JOIN MVXJDTA.MPDHED h2
      ON h2.phcono = m1.mmcono
     AND h2.phprno::text = m1.mmitno::text
     AND h2.phfaci::text = f2.m9faci::text
     AND h2.phstrt::text = '100'::text
     AND h2.phstat::text <= '20'::text
    LEFT JOIN MVXJDTA.MPDMAT r2
      ON r2.pmcono = h2.phcono
     AND r2.pmprno::text = h2.phprno::text
     AND r2.pmmtno::text = h2.phprno::text
     AND r2.pmstrt::text = h2.phstrt::text
    WHERE p1.mmitty::text = '10'::text
      AND f1.m9vamt::text = '1'::text
      AND f2.m9vamt::text = '2'::text
      AND m1.mmitty::text = ANY (ARRAY['10'::varchar, '40'::varchar]::text[])
      AND p1.mmstat::text <= '50'::text
      AND m1.mmstat::text <= '50'::text
      AND r2.pmmtno IS NULL
),

/* ==========================================================
   3. Purchased Items Without Recipe
   ========================================================== */
CTE_PURCHASED_ITEMS AS (
    SELECT
        p.mmcono AS cono,
        f.m9faci AS divi,
        p.mmitno AS product,
        p.mmitno AS material,
        ROUND(1000::numeric, 6) AS qty1000
    FROM MVXJDTA.MITMAS p
    JOIN MVXJDTA.MITFAC f
      ON f.m9cono = p.mmcono
     AND f.m9itno::text = p.mmitno::text
    LEFT JOIN MVXJDTA.MPDMAT r
      ON r.pmcono = p.mmcono
     AND r.pmprno::text = p.mmitno::text
     AND r.pmfaci::text = f.m9faci::text
     AND r.pmstrt::text = '100'::text
    WHERE p.mmitty::text = '10'::text
      AND f.m9vamt::text = '2'::text
      AND p.mmvol3 <> 0::numeric
      AND p.mmstat::text <= '50'::text
      AND (
            r.pmmtno IS NULL
            OR f.m9faci::text = ANY (ARRAY['300'::varchar, '600'::varchar]::text[])
          )
),

/* ==========================================================
   Combined Recipe Source
   ========================================================== */
CTE_RECIPE_SOURCE AS (
    SELECT cono, divi, product, material, qty1000 FROM CTE_STANDARD_RECIPES
    UNION ALL
    SELECT cono, divi, product, material, qty1000 FROM CTE_READY_PRODUCTS
    UNION ALL
    SELECT cono, divi, product, material, qty1000 FROM CTE_PURCHASED_ITEMS
),

/* ==========================================================
   Final Recipe Output Before Compatibility Unions
   ========================================================== */
CTE_RECIPE_FINAL AS (
    SELECT
        '100'::varchar AS type,
        rcp.divi::varchar(10) AS division,
        rcp.product::varchar AS productcode,
        rcp.material::varchar AS materialcode,
        CASE
            WHEN m1.mmitty::text = '10'::text THEN rcp.qty1000
            ELSE ROUND(rcp.qty1000 / p1.mmvol3, 6)
        END AS qty1000l
    FROM CTE_RECIPE_SOURCE rcp
    JOIN MVXJDTA.MITMAS p1
      ON p1.mmitno::text = rcp.product::text
    JOIN MVXJDTA.MITMAS m1
      ON m1.mmitno::text = rcp.material::text
     AND m1.mmitty::text <> '90'::text
    WHERE p1.mmstat::text <= '50'::text
      AND p1.mmitty::text = ANY (ARRAY['10'::varchar, '40'::varchar]::text[])
      AND (
            p1.mmitno::text = p1.mmgrti::text
            OR substring(p1.mmitno::text, 1, 1) = ANY (ARRAY['1','6','8','3']::text[])
          )
      AND rcp.divi::text <> ALL (ARRAY['800'::varchar, '400'::varchar]::text[])
)

/* ==========================================================
   Final Output
   ========================================================== */
SELECT
    type::varchar AS type,
    division::varchar(10) AS division,
    productcode::varchar AS productcode,
    materialcode::varchar AS materialcode,
    qty1000l
FROM CTE_RECIPE_FINAL

UNION ALL

SELECT
    TYPE::varchar AS type,
    DIVISION,
    PRODUCTCODE::varchar AS productcode,
    MATERIALCODE::varchar AS materialcode,
    QTY1000L
FROM LIDSKOE.TD_COGS_RECIPE
WHERE DIVISION::text = '800'::text

UNION ALL

SELECT
    TYPE::varchar AS type,
    DIVISION,
    PRODUCTCODE::varchar AS productcode,
    MATERIALCODE::varchar AS materialcode,
    QTY1000L
FROM M3SKY.TD_COGS_RECIPE
WHERE DIVISION::text = '400'::text;

COMMENT ON VIEW ANAPLAN.TD_COGS_RECIPE IS
    'Explodes product recipes (recursive BOM) and computes material quantities per 1000L for finished products. Handles unit conversions, receipt-multiplier expression evaluation, and includes standard, ready-product and purchased-item sources. Excludes divisions 800/400 in core logic and unions compat data from LIDSKOE/M3SKY for those divisions.';
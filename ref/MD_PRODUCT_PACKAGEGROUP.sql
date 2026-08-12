-- =============================================================================
-- TABLE: ref.MD_PRODUCT_PACKAGEGROUP
-- Replaces: 3 separate CASE mm.mmgrp4 trees in MD_PRODUCT, all keyed on the
--           same column, that had drifted into 3 different copy-pasted forms:
--             1) l3_packagetype   — descriptive label,  e.g. '1.GLASS'
--             2) l5_uniqueitem    — word-only form,     e.g. 'GLASS'
--             3) l3_code/l5_code  — normalized code,    e.g. '36' -> '31'
-- Used by:  md_product_v
--
-- IMPORTANT — code_normalize column does NOT include a '43' row:
--   The original l3_code CASE has an extra "WHEN '43' THEN '99'" branch that
--   the equivalent CASE embedded in l5_code does NOT have (l5_code falls
--   through to its own ELSE for mmgrp4='43', producing literal '43' instead
--   of '99'). This is a real inconsistency in the original SQL, confirmed
--   currently harmless in production (0 live rows with mmgrp4='43' as of
--   this check), but NOT fixed here per instruction to keep behavior
--   byte-identical. The '43'->'99' mapping stays as an inline CASE override
--   in l3_code's view SQL only — deliberately NOT added to this shared
--   table, so l5_code's current (arguably buggy) behavior is preserved
--   unchanged. See MIGRATION_TRACKER.md for the open item.
--
-- NULL in packagetype_label / packagetype_word / code_normalize means "no
-- explicit mapping for this mmgrp4 value" — the view falls back to each
-- CASE's original ELSE (a literal default for label/word, or a passthrough
-- of mm.mmgrp4 itself for code_normalize) via COALESCE, exactly matching
-- the original CASE's ELSE behavior.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.MD_PRODUCT_PACKAGEGROUP (
    MMGRP4             VARCHAR(10) NOT NULL PRIMARY KEY,
    PACKAGETYPE_LABEL  VARCHAR(30),   -- l3_packagetype's mapped value; NULL -> ELSE '99.OTHER'
    PACKAGETYPE_WORD   VARCHAR(30),   -- l5_uniqueitem's mapped value; NULL -> ELSE 'OTHER'
    CODE_NORMALIZE     VARCHAR(10)    -- l3_code / l5_code's mapped value; NULL -> ELSE mm.mmgrp4 (passthrough)
);

TRUNCATE ref.MD_PRODUCT_PACKAGEGROUP;
INSERT INTO ref.MD_PRODUCT_PACKAGEGROUP (MMGRP4, PACKAGETYPE_LABEL, PACKAGETYPE_WORD, CODE_NORMALIZE) VALUES
    ('31', '1.GLASS',    'GLASS',    NULL),
    ('36', '1.GLASS',    'GLASS',    '31'),
    ('32', '3.PET',      'PET',      NULL),
    ('37', '3.PET',      'PET',      '32'),
    ('33', '2.CAN',      'CAN',      NULL),
    ('34', '4.KEG',      'KEG',      NULL),
    ('35', '5.TETRA',    'TETRA',    NULL),
    ('38', '6.FOOD',     'FOOD',     NULL),
    ('41', '7.PET-KEG',  'PET-KEG',  NULL),
    ('40', '8.BARREL',   'BARREL',   NULL),
    ('39', '9.TANK',     'TANK',     NULL),
    ('42', '91.BIB',     'BIB',      NULL),
    (' ',  NULL,         NULL,       '99');

COMMENT ON TABLE ref.MD_PRODUCT_PACKAGEGROUP IS
    'Package-type/group lookup keyed on mmgrp4. Consolidates 3 duplicate CASE mm.mmgrp4 trees from MD_PRODUCT (l3_packagetype label, l5_uniqueitem word form, l3_code/l5_code normalization). code_normalize deliberately excludes the mmgrp4=''43'' override that only applied to l3_code in the original SQL -- kept inline in md_product_v.sql to preserve exact original per-column behavior.';

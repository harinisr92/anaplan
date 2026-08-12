-- =============================================================================
-- TABLE: ref.MD_PRODUCT_HIE3_REMAP
-- Replaces: the ONE genuinely shared row ('720001' -> '806200') of the
--           CASE mm.mmhie3 trees used in both brand3_code and l5_code in
--           MD_PRODUCT.
--
-- IMPORTANT — deliberately does NOT cover the blank-value (' ') branch:
--   brand3_code's CASE maps mmhie3=' ' to the static literal '999999'.
--   l5_code's CASE maps mmhie3=' ' to the dynamic expression
--   mm.mmgrp1||'-999999' (depends on another column of the same row).
--   These two defaults are different and one of them isn't even a static
--   value, so they cannot share a lookup row. Both blank-value branches, and
--   both consumers' final ELSE (passthrough of mm.mmhie3), stay inline in
--   md_product_v.sql exactly as in the original CASE trees. This table only
--   removes the duplicated exact-match literal pair.
-- Used by:  md_product_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.MD_PRODUCT_HIE3_REMAP (
    MMHIE3       VARCHAR(10) NOT NULL PRIMARY KEY,
    REMAP_VALUE  VARCHAR(10) NOT NULL
);

TRUNCATE ref.MD_PRODUCT_HIE3_REMAP;
INSERT INTO ref.MD_PRODUCT_HIE3_REMAP (MMHIE3, REMAP_VALUE) VALUES
    ('720001', '806200');

COMMENT ON TABLE ref.MD_PRODUCT_HIE3_REMAP IS
    'mmhie3 exact-match remap shared by MD_PRODUCT brand3_code and l5_code. Blank-value (mmhie3='' '') and passthrough ELSE branches differ per consumer and stay inline in the view -- not part of this table.';

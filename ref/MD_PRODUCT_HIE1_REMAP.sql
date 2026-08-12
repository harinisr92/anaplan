-- =============================================================================
-- TABLE: ref.MD_PRODUCT_HIE1_REMAP
-- Replaces: CASE mm.mmhie1 WHEN ... branch inside l2_code's CASE mm.mmgrp2
--           (the ELSE arm, for mmgrp2 NOT IN ('02','03')) in MD_PRODUCT.
-- Used by:  md_product_v
--
-- NULL match (no row for a given mmhie1) -> ELSE mm.mmhie1 (passthrough),
-- exactly matching the original CASE's ELSE behavior via COALESCE.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.MD_PRODUCT_HIE1_REMAP (
    MMHIE1       VARCHAR(10) NOT NULL PRIMARY KEY,
    REMAP_VALUE  VARCHAR(10) NOT NULL
);

TRUNCATE ref.MD_PRODUCT_HIE1_REMAP;
INSERT INTO ref.MD_PRODUCT_HIE1_REMAP (MMHIE1, REMAP_VALUE) VALUES
    ('784', '106'),
    ('742', '256'),
    ('783', '650'),
    ('720', '806'),
    (' ',   '999');

COMMENT ON TABLE ref.MD_PRODUCT_HIE1_REMAP IS
    'mmhie1 remap for MD_PRODUCT l2_code (applies only when mmgrp2 NOT IN (''02'',''03'')). No row -> passthrough of mm.mmhie1 itself, matching the original CASE ELSE.';

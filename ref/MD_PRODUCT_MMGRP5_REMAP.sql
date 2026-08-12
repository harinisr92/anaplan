-- =============================================================================
-- TABLE: ref.MD_PRODUCT_MMGRP5_REMAP
-- Replaces: CASE mm.mmgrp5 WHEN ... END, which appeared TWICE, character-for-
--           character identical, in MD_PRODUCT (once as l4_code, once as the
--           mmgrp5 segment inside l5_code's concatenation). Confirmed
--           byte-identical WHEN/THEN/ELSE branches in both places before
--           consolidating -- this is a true duplicate, not a near-match like
--           the mmgrp4 case, so no override/exception handling is needed.
-- Used by:  md_product_v
--
-- NULL match (no row for a given mmgrp5) -> ELSE mm.mmgrp5 (passthrough),
-- exactly matching the original CASE's ELSE behavior via COALESCE.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.MD_PRODUCT_MMGRP5_REMAP (
    MMGRP5       VARCHAR(10) NOT NULL PRIMARY KEY,
    REMAP_VALUE  VARCHAR(10) NOT NULL
);

TRUNCATE ref.MD_PRODUCT_MMGRP5_REMAP;
INSERT INTO ref.MD_PRODUCT_MMGRP5_REMAP (MMGRP5, REMAP_VALUE) VALUES
    ('85', '47'),
    ('54', '35'),
    ('33', '999'),
    (' ',  '999');

COMMENT ON TABLE ref.MD_PRODUCT_MMGRP5_REMAP IS
    'mmgrp5 remap shared identically by MD_PRODUCT l4_code and l5_code (verified byte-identical CASE trees before merging). No row -> passthrough of mm.mmgrp5 itself, matching the original CASE ELSE.';

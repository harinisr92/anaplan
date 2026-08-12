-- =============================================================================
-- TABLE: ref.MD_PRODUCT_HIE2_REMAP
-- Replaces: CASE mm.mmhie2 WHEN ... END (brand2_code) in MD_PRODUCT.
-- Used by:  md_product_v
--
-- NULL match (no row for a given mmhie2) -> ELSE mm.mmhie2 (passthrough),
-- exactly matching the original CASE's ELSE behavior via COALESCE.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.MD_PRODUCT_HIE2_REMAP (
    MMHIE2       VARCHAR(10) NOT NULL PRIMARY KEY,
    REMAP_VALUE  VARCHAR(10) NOT NULL
);

TRUNCATE ref.MD_PRODUCT_HIE2_REMAP;
INSERT INTO ref.MD_PRODUCT_HIE2_REMAP (MMHIE2, REMAP_VALUE) VALUES
    ('7200', '8062'),
    ('7420', '2560'),
    ('4200', '2170'),
    ('4202', '2171'),
    ('260J', '2600'),
    ('2810', '7460'),
    ('200L', '2720'),
    (' ',    '9999');

COMMENT ON TABLE ref.MD_PRODUCT_HIE2_REMAP IS
    'mmhie2 remap for MD_PRODUCT brand2_code. No row -> passthrough of mm.mmhie2 itself, matching the original CASE ELSE.';

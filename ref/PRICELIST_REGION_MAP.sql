-- =============================================================================
-- TABLE: ref.PRICELIST_REGION_MAP
-- Replaces: CASE WHEN pricelist_code/region logic in MD_PRICELIST
-- Used by:  md_pricelist_v, md_pricelist_new_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.PRICELIST_REGION_MAP (
    PRICELIST_CODE   VARCHAR(20) NOT NULL,
    PRICELIST_REGION VARCHAR(30) NOT NULL,
    PRICELIST_REF    VARCHAR(30) NOT NULL,
    PRIMARY KEY (PRICELIST_CODE, PRICELIST_REGION)
);

TRUNCATE ref.PRICELIST_REGION_MAP;
INSERT INTO ref.PRICELIST_REGION_MAP (PRICELIST_CODE, PRICELIST_REGION, PRICELIST_REF) VALUES
    ('2A0', 'DOMESTIC',    'DOM-2A0'),
    ('2A0', 'TRAVELTRADE', 'TT-2A0'),
    ('7C1', 'DOMESTIC',    'DOM-7C1'),
    ('7C1', 'TRAVELTRADE', 'TT-7C1');

COMMENT ON TABLE ref.PRICELIST_REGION_MAP IS
    'Maps pricelist code + region to pricelist_ref. Replaces CASE logic in MD_PRICELIST Oracle view.';

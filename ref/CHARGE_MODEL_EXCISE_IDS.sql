-- =============================================================================
-- TABLE: ref.CHARGE_MODEL_EXCISE_IDS
-- Replaces: Hardcoded IN (...) list of excise mecrid values in AD_CHARGEMODEL
-- Used by:  ad_chargemodel_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.CHARGE_MODEL_EXCISE_IDS (
    MECRID VARCHAR(10) NOT NULL PRIMARY KEY,
    NOTE   VARCHAR(100)
);

TRUNCATE ref.CHARGE_MODEL_EXCISE_IDS;
INSERT INTO ref.CHARGE_MODEL_EXCISE_IDS (MECRID, NOTE) VALUES
    ('1600','Excise'), ('1650','Excise'), ('2999','Excise'),
    ('3600','Excise'), ('3601','Excise'), ('4999','Excise'),
    ('6999','Excise'), ('7997','Excise'), ('7999','Excise'),
    ('8800','Excise'), ('8820','Excise');

COMMENT ON TABLE ref.CHARGE_MODEL_EXCISE_IDS IS
    'mecrid values classified as Excise charge type. Replaces hardcoded IN list in AD_CHARGEMODEL.';

-- =============================================================================
-- TABLE: ref.CHARGE_MODEL_DEPOFEE_IDS
-- Replaces: Hardcoded IN (...) list of deposit-fee mecrid values in AD_CHARGEMODEL
-- Used by:  ad_chargemodel_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.CHARGE_MODEL_DEPOFEE_IDS (
    MECRID VARCHAR(10) NOT NULL PRIMARY KEY,
    NOTE   VARCHAR(100)
);

TRUNCATE ref.CHARGE_MODEL_DEPOFEE_IDS;
INSERT INTO ref.CHARGE_MODEL_DEPOFEE_IDS (MECRID, NOTE) VALUES
    ('1610','DepositFee'), ('1611','DepositFee'), ('1612','DepositFee'),
    ('2997','DepositFee'), ('3610','DepositFee'), ('3611','DepositFee'),
    ('3612','DepositFee'), ('4997','DepositFee'), ('6810','DepositFee'),
    ('7280','DepositFee');

COMMENT ON TABLE ref.CHARGE_MODEL_DEPOFEE_IDS IS
    'mecrid values classified as DepositFee charge type. Replaces hardcoded IN list in AD_CHARGEMODEL.';

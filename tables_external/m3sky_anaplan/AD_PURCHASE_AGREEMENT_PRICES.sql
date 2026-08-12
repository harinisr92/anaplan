-- =============================================================================
-- TABLE: M3SKY.AD_PURCHASE_AGREEMENT_PRICES
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.AD_PURCHASE_AGREEMENT_PRICES;

CREATE TABLE IF NOT EXISTS M3SKY.AD_PURCHASE_AGREEMENT_PRICES (
    DIVISION VARCHAR(10),
    ITEMCODE VARCHAR(100),
    CURENCY  VARCHAR(20),
    PERIOD   VARCHAR(20),
    PRICE_BUM NUMERIC
);

COMMENT ON TABLE M3SKY.AD_PURCHASE_AGREEMENT_PRICES IS
    'External compat placeholder for division 400 purchase agreement prices.';

-- M3SKY.MD_COGS_MATERIALS
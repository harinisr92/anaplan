-- =============================================================================
-- TABLE: LIDSKOE.AD_PURCHASE_AGREEMENT_PRICES
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.AD_PURCHASE_AGREEMENT_PRICES;

CREATE TABLE IF NOT EXISTS LIDSKOE.AD_PURCHASE_AGREEMENT_PRICES (
    DIVISION   VARCHAR(10),
    ITEMCODE   VARCHAR(100),
    CURENCY    VARCHAR(20),
    PERIOD     VARCHAR(20),
    PRICE_BUM  NUMERIC
);

-- LIDSKOE.MD_COGS_MATERIALS
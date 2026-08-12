-- =============================================================================
-- TABLE: LIDSKOE.TD_NATUREBASED_COGS
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.TD_NATUREBASED_COGS;

CREATE TABLE IF NOT EXISTS LIDSKOE.TD_NATUREBASED_COGS (
    DIVISION    VARCHAR(10),
    COSTCENTER  VARCHAR(100),
    PERIOD      VARCHAR(20),
    IS_LINE     VARCHAR(255),
    AMOUNT      NUMERIC
);

COMMENT ON TABLE LIDSKOE.TD_NATUREBASED_COGS IS
    'External compat placeholder for division 800 nature-based COGS.';
-- LIDSKOE.AD_CURRENCYRATES
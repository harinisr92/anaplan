-- =============================================================================
-- TABLE: M3SKY.TD_COGS_OPERATIONS
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.TD_COGS_OPERATIONS;

CREATE TABLE IF NOT EXISTS M3SKY.TD_COGS_OPERATIONS (
    DIVISION       VARCHAR(10),
    PRODUCT_CODE   VARCHAR(100),
    WC_CODE        VARCHAR(100),
    FILL_MH_1000L  NUMERIC,
    FILL_LH_1000L  NUMERIC,
    SETUP_MH_1000L NUMERIC,
    SETUP_LH_1000L NUMERIC,
    ORDERQTY_L     NUMERIC,
    SETUP_TIME     NUMERIC,
    SETUP_PEOPLE   NUMERIC
);

COMMENT ON TABLE M3SKY.TD_COGS_OPERATIONS IS
    'External compat placeholder for division 400 COGS operations data.';

-- M3SKY.TD_COGS_RECIPE
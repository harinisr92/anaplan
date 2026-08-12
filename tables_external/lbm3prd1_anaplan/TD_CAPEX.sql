-- =============================================================================
-- TABLE: LIDSKOE.TD_CAPEX
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.TD_CAPEX;

CREATE TABLE IF NOT EXISTS LIDSKOE.TD_CAPEX (
    DIVISION        VARCHAR(10),
    PERIOD          VARCHAR(20),
    ACCOUNT_CODE    VARCHAR(50),
    INVESTMENT_CODE VARCHAR(100),
    AMOUNT_LOC      NUMERIC
);

COMMENT ON TABLE LIDSKOE.TD_CAPEX IS
    'External compat placeholder for division 800 capex data.';

-- LIDSKOE.TD_COGS_OH_COSTING

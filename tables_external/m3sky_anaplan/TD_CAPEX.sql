-- =============================================================================
-- TABLE: M3SKY.TD_CAPEX
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.TD_CAPEX;

CREATE TABLE IF NOT EXISTS M3SKY.TD_CAPEX (
    DIVISION        VARCHAR(10),
    PERIOD          VARCHAR(20),
    ACCOUNT_CODE    VARCHAR(50),
    INVESTMENT_CODE VARCHAR(100),
    AMOUNT_LOC      NUMERIC
);

COMMENT ON TABLE M3SKY.TD_CAPEX IS
    'External compat placeholder for division 400 capex data.';

-- M3SKY.TD_COGS_LATESTCOST
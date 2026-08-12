-- =============================================================================
-- TABLE: M3SKY.TD_COGS_LATESTCOST
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.TD_COGS_LATESTCOST;

CREATE TABLE IF NOT EXISTS M3SKY.TD_COGS_LATESTCOST (
    DIVI           VARCHAR(10),
    PRODUCT        VARCHAR(100),
    COSTCOMPONENT  VARCHAR(50),
    EURPERL        NUMERIC
);

COMMENT ON TABLE M3SKY.TD_COGS_LATESTCOST IS
    'External compat placeholder for division 400 latest COGS cost data.';

-- M3SKY.TD_COGS_OH_COSTING
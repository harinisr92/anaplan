-- =============================================================================
-- TABLE: LIDSKOE.TD_COGS_OH_COSTING
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.TD_COGS_OH_COSTING;

CREATE TABLE IF NOT EXISTS LIDSKOE.TD_COGS_OH_COSTING (
    COSTINGTYPE VARCHAR(20),
    DIVISION VARCHAR(10),
    ITEM_CODE VARCHAR(100),
    COSTING_DATE NUMERIC,
    COMPONENT VARCHAR(20),
    RATE NUMERIC
);

COMMENT ON TABLE LIDSKOE.TD_COGS_OH_COSTING IS
    'External compat placeholder for division 800 overhead costing data.';

-- LIDSKOE.TD_COGS_OPERATIONS
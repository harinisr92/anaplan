-- =============================================================================
-- TABLE: M3SKY.TD_COGS_OH_COSTING
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.TD_COGS_OH_COSTING;

CREATE TABLE IF NOT EXISTS M3SKY.TD_COGS_OH_COSTING (
    COSTINGTYPE VARCHAR(20),
    DIVISION VARCHAR(10),
    ITEM_CODE VARCHAR(100),
    COSTING_DATE NUMERIC,
    COMPONENT VARCHAR(20),
    RATE NUMERIC
);

COMMENT ON TABLE M3SKY.TD_COGS_OH_COSTING IS
    'External compat placeholder for division 400 overhead costing data.';

-- M3SKY.TD_COGS_OPERATIONS
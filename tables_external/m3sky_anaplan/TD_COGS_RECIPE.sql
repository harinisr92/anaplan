-- =============================================================================
-- TABLE: M3SKY.TD_COGS_RECIPE
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.TD_COGS_RECIPE;

CREATE TABLE IF NOT EXISTS M3SKY.TD_COGS_RECIPE (
    TYPE         VARCHAR(20),
    DIVISION     VARCHAR(10),
    PRODUCTCODE  VARCHAR(100),
    MATERIALCODE VARCHAR(100),
    QTY1000L     NUMERIC
);

COMMENT ON TABLE M3SKY.TD_COGS_RECIPE IS
    'External compat placeholder for division 400 COGS recipe data.';

-- M3SKY.TD_DEPRECIATION_PLAN
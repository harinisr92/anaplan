-- =============================================================================
-- TABLE: LIDSKOE.TD_COGS_RECIPE
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.TD_COGS_RECIPE;

CREATE TABLE IF NOT EXISTS LIDSKOE.TD_COGS_RECIPE (
    TYPE          VARCHAR(20),
    DIVISION      VARCHAR(10),
    PRODUCTCODE   VARCHAR(100),
    MATERIALCODE  VARCHAR(100),
    QTY1000L      NUMERIC
);

COMMENT ON TABLE LIDSKOE.TD_COGS_RECIPE IS
    'External compat placeholder for division 800 COGS recipe data.';

-- LIDSKOE.TD_MARKETINGMONEY
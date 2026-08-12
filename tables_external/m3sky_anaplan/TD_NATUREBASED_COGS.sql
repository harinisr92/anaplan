-- =============================================================================
-- TABLE: M3SKY.TD_NATUREBASED_COGS
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

CREATE TABLE IF NOT EXISTS M3SKY.TD_NATUREBASED_COGS (
    DIVISION   VARCHAR(10),
    COSTCENTER VARCHAR(100),
    PERIOD     VARCHAR(20),
    IS_LINE    VARCHAR(255),
    AMOUNT     NUMERIC
);

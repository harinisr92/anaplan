-- =============================================================================
-- TABLE: M3SKY.TD_DEPRECIATION_PLAN
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

CREATE TABLE IF NOT EXISTS M3SKY.TD_DEPRECIATION_PLAN (
    DIVISION   VARCHAR(10),
    PERIOD     VARCHAR(20),
    FA_TYPEID  VARCHAR(100),
    FA_TYPE    VARCHAR(100),
    COSTCENTER VARCHAR(100),
    AMOUNT     NUMERIC,
    EXT_M1     NUMERIC,
    EXT_M2     NUMERIC,
    EXT_M3     NUMERIC,
    ATTR1      VARCHAR(255),
    ATTR2      VARCHAR(255),
    ATTR3      VARCHAR(255)
);

-- M3SKY.TD_MARKETINGMONEY
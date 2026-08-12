-- =============================================================================
-- TABLE: LIDSKOE.TD_MARKETINGMONEY
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.TD_MARKETINGMONEY;

CREATE TABLE IF NOT EXISTS LIDSKOE.TD_MARKETINGMONEY (
    DIVISION         VARCHAR(10),
    PERIOD           VARCHAR(20),
    L1_REGION        VARCHAR(255),
    L2_SALESCHANNEL  VARCHAR(255),
    L3_CODE          VARCHAR(255),
    L4_CODE          VARCHAR(255),
    L5_CODE          VARCHAR(255),
    AMOUNT           NUMERIC,
    ITEM_CODE        VARCHAR(100)
);

COMMENT ON TABLE LIDSKOE.TD_MARKETINGMONEY IS
    'External compat placeholder for division 800 marketing money data.';

-- LIDSKOE.TD_NATUREBASED_COGS
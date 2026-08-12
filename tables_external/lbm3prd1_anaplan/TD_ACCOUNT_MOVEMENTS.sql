-- =============================================================================
-- TABLE: LIDSKOE.TD_ACCOUNT_MOVEMENTS
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.TD_ACCOUNT_MOVEMENTS;

CREATE TABLE IF NOT EXISTS LIDSKOE.TD_ACCOUNT_MOVEMENTS (
    PERIOD           VARCHAR(20),
    DIVISION         VARCHAR(10),
    ACCOUNT_CODE     VARCHAR(50),
    DIM3_CODE        VARCHAR(50),
    COUNTERPART_CODE VARCHAR(50),
    AMOUNT_LOC       NUMERIC
);

COMMENT ON TABLE LIDSKOE.TD_ACCOUNT_MOVEMENTS IS
    'External compat placeholder for division 800 account movements.';

-- LIDSKOE.TD_CAPEX

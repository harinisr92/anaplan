-- =============================================================================
-- TABLE: M3SKY.TD_ACCOUNT_MOVEMENTS
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.TD_ACCOUNT_MOVEMENTS;

CREATE TABLE IF NOT EXISTS M3SKY.TD_ACCOUNT_MOVEMENTS (
    PERIOD           VARCHAR(20),
    DIVISION         VARCHAR(10),
    ACCOUNT_CODE     VARCHAR(50),
    DIM3_CODE        VARCHAR(50),
    COUNTERPART_CODE VARCHAR(50),
    AMOUNT_LOC       NUMERIC
);

COMMENT ON TABLE M3SKY.TD_ACCOUNT_MOVEMENTS IS
    'External compat placeholder for division 400 account movements.';

-- M3SKY.TD_ACTUAL_MO_TIME
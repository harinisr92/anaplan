-- =============================================================================
-- TABLE: M3SKY.TD_ACTUAL_MO_TIME
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.TD_ACTUAL_MO_TIME;

CREATE TABLE IF NOT EXISTS M3SKY.TD_ACTUAL_MO_TIME (
    DIVISION            VARCHAR(10),
    WORKCENTER          VARCHAR(100),
    ITEMCODE            VARCHAR(100),
    PERIOD              VARCHAR(20),
    TOTAL_MACHINE_TIME  NUMERIC,
    TOTAL_LABOR_TIME    NUMERIC
);

COMMENT ON TABLE M3SKY.TD_ACTUAL_MO_TIME IS
    'External compat placeholder for division 400 actual MO time.';

-- M3SKY.TD_CAMPAIGNS
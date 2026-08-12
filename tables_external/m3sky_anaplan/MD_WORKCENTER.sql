-- =============================================================================
-- TABLE: M3SKY.MD_WORKCENTER
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.MD_WORKCENTER;

CREATE TABLE IF NOT EXISTS M3SKY.MD_WORKCENTER (
    DIVISION         VARCHAR(10),
    WORKCENTER_CODE  VARCHAR(100),
    WORKCENTER_NAME  VARCHAR(255),
    COSTCENTER_CODE  VARCHAR(100),
    WORKCENTER_GROUP VARCHAR(100)
);

COMMENT ON TABLE M3SKY.MD_WORKCENTER IS
    'External compat placeholder for division 400 workcenter master.';

-- M3SKY.TD_ACCOUNT_MOVEMENTS
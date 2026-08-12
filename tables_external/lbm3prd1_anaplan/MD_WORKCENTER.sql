-- =============================================================================
-- TABLE: LIDSKOE.MD_WORKCENTER
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.MD_WORKCENTER;

CREATE TABLE IF NOT EXISTS LIDSKOE.MD_WORKCENTER (
    DIVISION         VARCHAR(10),
    WORKCENTER_CODE  VARCHAR(100),
    WORKCENTER_NAME  VARCHAR(255),
    COSTCENTER_CODE  VARCHAR(100),
    WORKCENTER_GROUP VARCHAR(100)
);

COMMENT ON TABLE LIDSKOE.MD_WORKCENTER IS
    'External compat placeholder for division 800 workcenter master.';

-- LIDSKOE.MWOPTS

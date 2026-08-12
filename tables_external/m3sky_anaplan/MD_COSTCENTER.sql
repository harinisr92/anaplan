-- =============================================================================
-- TABLE: M3SKY.MD_COSTCENTER
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.MD_COSTCENTER;

CREATE TABLE IF NOT EXISTS M3SKY.MD_COSTCENTER (
    L1_DIVISION    VARCHAR(10),
    L2_COSTCENTER  VARCHAR(255),
    L2_CODE        VARCHAR(100),
    A1_FUNCTION    VARCHAR(255),
    A1_CODE        VARCHAR(100),
    A2_SUBFUNCTION VARCHAR(255),
    A2_CODE        VARCHAR(100),
    A3_ATTR        VARCHAR(255),
    A3_CODE        VARCHAR(100),
    A4_ATTR        VARCHAR(255),
    A4_CODE        VARCHAR(100)
);

COMMENT ON TABLE M3SKY.MD_COSTCENTER IS
    'External compat placeholder for division 400 cost center master.';

-- M3SKY.MD_CUSTOMER
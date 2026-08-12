-- =============================================================================
-- TABLE: M3SKY.MD_COGS_MATERIALS
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.MD_COGS_MATERIALS;

CREATE TABLE IF NOT EXISTS M3SKY.MD_COGS_MATERIALS (
    DIVISION                VARCHAR(10),
    L1_ITEMTYPE             VARCHAR(255),
    L2_MATERIAL_GROUP1      VARCHAR(255),
    L3_MATERIAL_GROUP2      VARCHAR(255),
    L4_ITEMNAME             VARCHAR(255),
    L1_CODE                 VARCHAR(100),
    L2_CODE                 VARCHAR(100),
    L3_CODE                 VARCHAR(100),
    L4_CODE                 VARCHAR(100),
    SUPPLIER                VARCHAR(255),
    BASICUNITOFMEASURE      VARCHAR(100),
    GROSSWEIGHT             VARCHAR(100),
    NETWEIGHT               VARCHAR(100),
    RESPONSIBLE             VARCHAR(255),
    M3STATUS                VARCHAR(50),
    PROCUREMENTGROUP        VARCHAR(255),
    PROCUREMENTGROUPCODE    VARCHAR(100),
    M3AVGPRICE              NUMERIC,
    ATTR1                   VARCHAR(255),
    ATTR2                   VARCHAR(255),
    ATTR3                   VARCHAR(255),
    ATTR4                   VARCHAR(255),
    ATTR5                   VARCHAR(255),
    L4_CODE_OLD             VARCHAR(100)
);

COMMENT ON TABLE M3SKY.MD_COGS_MATERIALS IS
    'External compat placeholder for division 400 materials master.';

-- M3SKY.MD_COSTCENTER
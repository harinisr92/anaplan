-- =============================================================================
-- TABLE: LIDSKOE.MD_CUSTOMER
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

CREATE TABLE IF NOT EXISTS LIDSKOE.MD_CUSTOMER (
    DIVISION            VARCHAR(10),
    L1_REGION           VARCHAR(255),
    L2_SALESCHANNEL     VARCHAR(255),
    L3_CUSTOMERGROUP    VARCHAR(255),
    L4_CHAIN            VARCHAR(255),
    L5_CUSTOMER         VARCHAR(255),
    L6_EXCISE_DEPO      VARCHAR(255),
    L3_CODE             VARCHAR(255),
    L4_CODE             VARCHAR(255),
    L5_CODE             VARCHAR(255),
    CUSTOMERCODE        VARCHAR(255),
    EXCISE              VARCHAR(10),
    DEPOFEE             VARCHAR(10),
    PRICELIST_REF       VARCHAR(100),
    BONUSGROUP_REF      VARCHAR(100),
    DELIVERYGROUP       VARCHAR(255),
    SHOP_COUNT          NUMERIC,
    ATTR1               VARCHAR(255),
    ATTR2               VARCHAR(255),
    ATTR3               VARCHAR(255),
    ATTR4               VARCHAR(255),
    ATTR5               VARCHAR(255),
    LOCAL_REGION        VARCHAR(100),
    SALESPERSON         VARCHAR(100),
    BUDGET_CUSTOMERCODE VARCHAR(100)
);

-- LIDSKOE.MD_CUSTOMER_DETAIL
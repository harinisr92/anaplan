-- =============================================================================
-- TABLE: LIDSKOE.MD_CUSTOMER_DETAIL
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.MD_CUSTOMER_DETAIL;

CREATE TABLE IF NOT EXISTS LIDSKOE.MD_CUSTOMER_DETAIL (
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
    L6_CODE             VARCHAR(255),
    EXC_TMP             VARCHAR(50),
    DEP_TMP             VARCHAR(50),
    SHOP                VARCHAR(255),
    CHARGEMODEL         VARCHAR(100),
    M3CUSTOMERCODE      VARCHAR(100),
    M3STATUS            VARCHAR(50),
    EXCISE              VARCHAR(10),
    DEPOFEE             VARCHAR(10),
    PRICELIST_REF       VARCHAR(100),
    BONUSGROUP_REF      VARCHAR(100),
    DISCOUNTGROUP_REF   VARCHAR(100),
    DELIVERYGROUP       VARCHAR(255),
    DELIVERYGROUP_CODE  VARCHAR(100),
    LOCAL_REGION        VARCHAR(100),
    SALESPERSON         VARCHAR(100),
    BUDGET_CUSTOMERCODE VARCHAR(100)
);

COMMENT ON TABLE LIDSKOE.MD_CUSTOMER_DETAIL IS
    'External compat placeholder for division 800 customer detail.';
-- LIDSKOE.MD_DELIVERYDATE
-- =============================================================================
-- TABLE: LIDSKOE.MD_PRICELIST
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.MD_PRICELIST;

CREATE TABLE IF NOT EXISTS LIDSKOE.MD_PRICELIST (
    DIVISION      VARCHAR(10),
    CUSTOMER1     VARCHAR(255),
    CUSTOMER2     VARCHAR(255),
    CUSTOMER3     VARCHAR(255),
    PRICELIST_REF VARCHAR(100),
    ITEMCODE      VARCHAR(100),
    PRICE         NUMERIC,
    STARTDATE     NUMERIC,
    ENDDATE       NUMERIC
);

COMMENT ON TABLE LIDSKOE.MD_PRICELIST IS
    'External compat placeholder for division 800 price list.';
-- LIDSKOE.MD_PRODUCT
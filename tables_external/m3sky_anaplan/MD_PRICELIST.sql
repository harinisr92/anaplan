-- =============================================================================
-- TABLE: M3SKY.MD_PRICELIST
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.MD_PRICELIST;

CREATE TABLE IF NOT EXISTS M3SKY.MD_PRICELIST (
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

COMMENT ON TABLE M3SKY.MD_PRICELIST IS
    'External compat placeholder for division 400 price list.';

-- M3SKY.MD_PRODUCT

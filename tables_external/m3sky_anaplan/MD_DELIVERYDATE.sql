-- =============================================================================
-- TABLE: M3SKY.MD_DELIVERYDATE
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.MD_DELIVERYDATE;

CREATE TABLE IF NOT EXISTS M3SKY.MD_DELIVERYDATE (
    DIVISION           VARCHAR(10),
    DELIVERYDATE       NUMERIC,
    DELIVERYDATESTATUS VARCHAR(50)
);

COMMENT ON TABLE M3SKY.MD_DELIVERYDATE IS
    'External compat placeholder for division 400 delivery date status.';

-- M3SKY.MD_PRICELIST
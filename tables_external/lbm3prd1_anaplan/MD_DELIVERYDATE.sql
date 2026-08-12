-- =============================================================================
-- TABLE: LIDSKOE.MD_DELIVERYDATE
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.MD_DELIVERYDATE;

CREATE TABLE IF NOT EXISTS LIDSKOE.MD_DELIVERYDATE (
    DIVISION             VARCHAR(10),
    DELIVERYDATE         NUMERIC,
    DELIVERYDATESTATUS   VARCHAR(50)
);

COMMENT ON TABLE LIDSKOE.MD_DELIVERYDATE IS
    'External compat placeholder for division 800 delivery date status.';

-- LIDSKOE.MD_PRICELIST
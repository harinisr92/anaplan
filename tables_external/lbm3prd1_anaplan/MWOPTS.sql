-- =============================================================================
-- TABLE: LIDSKOE.MWOPTS
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.MWOPTS;

CREATE TABLE IF NOT EXISTS LIDSKOE.MWOPTS (
    DHCONO NUMERIC,
    DHFACI VARCHAR(10),
    DHMFNO VARCHAR(50),
    DHPRNO VARCHAR(100),
    DHANBR NUMERIC,
    DHMAQT NUMERIC,
    DHTRDT NUMERIC,
    DHPLGR VARCHAR(50),
    DHUPIT NUMERIC,
    DHUMAT NUMERIC,
    DHUSET NUMERIC,
    DHUMAS NUMERIC
);

COMMENT ON TABLE LIDSKOE.MWOPTS IS
    'External compat placeholder for division 800 manufacturing work order options.';

-- LIDSKOE.TD_ACCOUNT_MOVEMENTS
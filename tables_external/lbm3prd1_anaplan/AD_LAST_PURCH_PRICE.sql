-- =============================================================================
-- TABLE: LIDSKOE.AD_LAST_PURCH_PRICE
-- Compat placeholder for Division 800 (LIDA / LIDSKOE)
-- Needed by: ANAPLAN.refresh_ad_last_purch_price()
-- NOTE: not present in the original upload — same gap as
-- ANAPLAN.ad_last_purch_price_calc_v. If 00_create_external_compat_tables.sql
-- already defines this table, reconcile column types against that instead.
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.AD_LAST_PURCH_PRICE;

CREATE TABLE IF NOT EXISTS LIDSKOE.AD_LAST_PURCH_PRICE (
    DIVISION         VARCHAR(9),
    SUPPLIER         VARCHAR(108),
    L4_CODE          VARCHAR(45),
    CURRENCY         VARCHAR(9),
    PURCHDATE        NUMERIC,
    PRICE_CURR       NUMERIC,
    CHARGE_LOCCURR   NUMERIC
);

COMMENT ON TABLE LIDSKOE.AD_LAST_PURCH_PRICE IS
    'External compat placeholder for division 800 last purchase price data.';
-- =============================================================================
-- TABLE: M3SKY.AD_LAST_PURCH_PRICE
-- Compat placeholder for Division 400 (SkyNet M3 instance / M3SKY)
-- Needed by: ANAPLAN.refresh_ad_last_purch_price()
-- NOTE: not present in the original upload — same gap as
-- ANAPLAN.ad_last_purch_price_calc_v. If a numbered compat-tables script
-- already defines this table, reconcile column types against that instead.
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.AD_LAST_PURCH_PRICE;

CREATE TABLE IF NOT EXISTS M3SKY.AD_LAST_PURCH_PRICE (
    DIVISION         VARCHAR(9),
    SUPPLIER         VARCHAR(108),
    L4_CODE          VARCHAR(45),
    CURRENCY         VARCHAR(9),
    PURCHDATE        NUMERIC,
    PRICE_CURR       NUMERIC,
    CHARGE_LOCCURR   NUMERIC
);

COMMENT ON TABLE M3SKY.AD_LAST_PURCH_PRICE IS
    'External compat placeholder for division 400 last purchase price data.';
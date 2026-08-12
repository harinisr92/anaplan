-- =============================================================================
-- TABLE: ANAPLAN.AD_LAST_PURCH_PRICE
-- Source: Oracle ANAPLAN.AD_LAST_PURCH_PRICE
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.AD_LAST_PURCH_PRICE (
    DIVISION         VARCHAR(9)   NOT NULL,
    SUPPLIER         VARCHAR(108),
    L4_CODE          VARCHAR(45)  NOT NULL,
    CURRENCY         VARCHAR(9)   NOT NULL,
    PURCHDATE        NUMERIC,
    PRICE_CURR       NUMERIC,
    CHARGE_LOCCURR   NUMERIC
);
COMMENT ON TABLE ANAPLAN.AD_LAST_PURCH_PRICE IS
    'Last purchase price per item/division — refreshed by prc_refresh_ad_last_purch_price.';

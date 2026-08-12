-- =============================================================================
-- TABLE: anaplan_dev.last_purchase_price
-- Source: Oracle ANAPLAN.LAST_PURCHASE_PRICE
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.LAST_PURCHASE_PRICE (
    DIVISION       VARCHAR(3),
    SUPPLIER       VARCHAR(34),
    L4_CODE        VARCHAR(7),
    CURRENCY       VARCHAR(3),
    PURCHDATE      NUMERIC(8,0),
    PRICE_CURR     NUMERIC(17,7),
    CHARGE_LOCCURR NUMERIC(15,7)
);

COMMENT ON TABLE ANAPLAN.LAST_PURCHASE_PRICE IS
    'Last purchase price — alternate staging table with tighter column sizes.';

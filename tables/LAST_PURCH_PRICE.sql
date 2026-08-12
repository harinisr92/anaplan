-- =============================================================================
-- TABLE: anaplan_dev.last_purch_price
-- Source: Oracle ANAPLAN.LAST_PURCH_PRICE
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.LAST_PURCH_PRICE (
    DIVISION       VARCHAR(9)  NOT NULL,
    SUPPLIER       VARCHAR(108),
    L4_CODE        VARCHAR(45) NOT NULL,
    CURRENCY       VARCHAR(9)  NOT NULL,
    PURCHDATE      NUMERIC,
    PRICE_CURR     NUMERIC,
    CHARGE_LOCCURR NUMERIC
);

COMMENT ON TABLE ANAPLAN.LAST_PURCH_PRICE IS
    'Last purchase price — intermediate staging table used by refresh procedure.';
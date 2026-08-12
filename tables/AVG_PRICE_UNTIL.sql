-- =============================================================================
-- TABLE: ANAPLAN.AVG_PRICE_UNTIL
-- Source: Oracle ANAPLAN.AVG_PRICE_UNTIL
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.AVG_PRICE_UNTIL (
    FACILITY         VARCHAR(9)    NOT NULL,
    SKU              VARCHAR(45)   NOT NULL,
    DESCRIPTION      VARCHAR(180)  NOT NULL,
    ON_HAND_BALANCE  NUMERIC(15,6) NOT NULL,
    AVG_COST         NUMERIC(17,6) NOT NULL,
    AVG_COST_UNTIL   NUMERIC(8,0),
    AVG_UNTIL_PERIOD VARCHAR(6),
    PRIMARY KEY (FACILITY, SKU)
);
COMMENT ON TABLE ANAPLAN.AVG_PRICE_UNTIL IS
    'Average cost cutoff per facility/SKU — refreshed by prc_refresh_avg_price_until.';

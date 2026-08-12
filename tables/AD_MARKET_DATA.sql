-- =============================================================================
-- TABLE: ANAPLAN.AD_MARKET_DATA
-- Source: Oracle ANAPLAN.AD_MARKET_DATA
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.AD_MARKET_DATA (
    DIVI     VARCHAR(3),
    IVDT     VARCHAR(10),
    CATEGORY VARCHAR(28),
    VOLUME   NUMERIC(15,7)
);
COMMENT ON TABLE ANAPLAN.AD_MARKET_DATA IS
    'Market volume data loaded externally.';

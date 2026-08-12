-- =============================================================================
-- TABLE: LIDSKOE.AD_CURRENCYRATES_LAST
-- Compat placeholder for Division 800 / LIDSKOE
-- =============================================================================

DROP TABLE IF EXISTS LIDSKOE.AD_CURRENCYRATES_LAST;

CREATE TABLE IF NOT EXISTS LIDSKOE.AD_CURRENCYRATES_LAST (
    DIVISION           VARCHAR(10),
    LOCALCURRENCY      VARCHAR(20),
    CONVERSIONCURRENCY VARCHAR(20),
    RATE               NUMERIC,
    MAX_DATE           NUMERIC
);

COMMENT ON TABLE LIDSKOE.AD_CURRENCYRATES_LAST IS
    'External compat placeholder for division 800 currency rates.';

-- LIDSKOE.AD_PURCHASE_AGREEMENT_PRICES

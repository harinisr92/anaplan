-- =============================================================================
-- TABLE: M3SKY.AD_CURRENCYRATES_LAST
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.AD_CURRENCYRATES_LAST;

CREATE TABLE IF NOT EXISTS M3SKY.AD_CURRENCYRATES_LAST (
    DIVISION           VARCHAR(10),
    LOCALCURRENCY      VARCHAR(20),
    CONVERSIONCURRENCY VARCHAR(20),
    RATE               NUMERIC,
    MAX_DATE           NUMERIC
);

COMMENT ON TABLE M3SKY.AD_CURRENCYRATES_LAST IS
    'External compat placeholder for division 400 currency rates.';

-- M3SKY.AD_PURCHASE_AGREEMENT_PRICES
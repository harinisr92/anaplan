-- =============================================================================
-- TABLE: M3SKY.TD_CAMPAIGNS
-- Compat placeholder for Division 400 (Vestfyen / M3SKY)
-- Source: originally defined in 00_create_external_compat_tables.sql
-- =============================================================================

DROP TABLE IF EXISTS M3SKY.TD_CAMPAIGNS;

CREATE TABLE IF NOT EXISTS M3SKY.TD_CAMPAIGNS (
    DIVISION          VARCHAR(10),
    L1_REGION         VARCHAR(100),
    MONTH             VARCHAR(20),
    CHAIN             VARCHAR(100),
    ITEMCODE          VARCHAR(100),
    SELLING_IN_FROM   NUMERIC,
    CAMPAIGN_TIME_TO  NUMERIC,
    WEEK              VARCHAR(20),
    CAMPAIGN_LTR      NUMERIC
);

COMMENT ON TABLE M3SKY.TD_CAMPAIGNS IS
    'External compat placeholder for division 400 campaign data.';


-- M3SKY.TD_CAPEX

-- =============================================================================
-- TABLE: anaplan_dev.td_sales_sum_daily_full
-- Source: Oracle ANAPLAN.TD_SALES_SUM_DAILY_FULL
-- Purpose: Full rolling daily sales history — source for td_sales_sum_daily.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.TD_SALES_SUM_DAILY_FULL (
    DIVISION     VARCHAR(108),
    INVOICEDATE  VARCHAR(108),
    DELIVERYDATE VARCHAR(108),
    CUSTOMERCODE VARCHAR(108),
    ITEMCODE     VARCHAR(108),
    VOLUME       NUMERIC,
    ORDER_VOLUME NUMERIC,
    ATTR1        VARCHAR(108),
    ATTR2        VARCHAR(108),
    ATTR3        VARCHAR(108),
    CAMPAIGN     VARCHAR(108)
);

COMMENT ON TABLE ANAPLAN.TD_SALES_SUM_DAILY_FULL IS
    'Full rolling daily sales history. Refreshed by prc_refresh_sales_daily_summary (rolling 2-month window delete+insert).';
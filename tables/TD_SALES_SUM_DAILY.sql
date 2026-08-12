-- =============================================================================
-- TABLE: anaplan_dev.td_sales_sum_daily
-- Source: Oracle ANAPLAN.TD_SALES_SUM_DAILY
-- Purpose: Published subset of td_sales_sum_daily_full for Anaplan consumption.
-- =============================================================================

CREATE TABLE IF NOT EXISTS ANAPLAN.TD_SALES_SUM_DAILY (
    DIVISION     VARCHAR(108),
    INVOICEDATE  VARCHAR(108),
    DELIVERYDATE VARCHAR(108),
    CUSTOMERCODE VARCHAR(108),
    ITEMCODE     VARCHAR(108),
    VOLUME       VARCHAR(108),
    ORDER_VOLUME VARCHAR(108),
    CAMPAIGN     VARCHAR(108)
);

CREATE INDEX IF NOT EXISTS td_sales_sum_daily_idx1
    ON ANAPLAN.TD_SALES_SUM_DAILY (DIVISION, DELIVERYDATE);

COMMENT ON TABLE ANAPLAN.TD_SALES_SUM_DAILY IS
    'Published daily sales subset for Anaplan. Refreshed by prc_refresh_sales_daily_summary.';
-- =============================================================================
-- TABLE: anaplan_dev.td_sales_sum_full
-- Source: Oracle ANAPLAN.TD_SALES_SUM_FULL
-- Purpose: Full monthly sales history — source for td_sales_sum (published subset).
--          Also used by ad_sales_check_customer_v and ad_sales_check_item_v.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.TD_SALES_SUM_FULL (
    DIVISION       VARCHAR(108),
    PERIOD         VARCHAR(108),
    CUSTOMERCODE   VARCHAR(108),
    ITEMCODE       VARCHAR(108),
    VOLUME         NUMERIC,
    GROSS          NUMERIC,
    DISCOUNT       NUMERIC,
    EXCISE         NUMERIC,
    DEPOFEE        NUMERIC,
    SALESBONUS     NUMERIC,
    NETSALES       NUMERIC,
    COGS           NUMERIC,
    PROMODISCOUNT  NUMERIC,
    EXT_M1         NUMERIC,
    EXT_M2         NUMERIC,
    EXT_M3         NUMERIC,
    ATTR1          VARCHAR(108),
    ATTR2          VARCHAR(108),
    ATTR3          VARCHAR(108),
    DELIVERYCOST   NUMERIC,
    CAMPAIGNVOLUME NUMERIC
);

CREATE INDEX IF NOT EXISTS td_sales_sum_full_idx1
    ON ANAPLAN.TD_SALES_SUM_FULL (DIVISION, PERIOD);
CREATE INDEX IF NOT EXISTS td_sales_sum_full_idx2
    ON ANAPLAN.TD_SALES_SUM_FULL (CUSTOMERCODE);

COMMENT ON TABLE ANAPLAN.TD_SALES_SUM_FULL IS
    'Full monthly sales history. Refreshed by prc_refresh_sales_monthly_summary.';
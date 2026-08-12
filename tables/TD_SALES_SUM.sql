-- =============================================================================
-- TABLE: anaplan_dev.td_sales_sum
-- Source: Oracle ANAPLAN.TD_SALES_SUM
-- Purpose: Published monthly sales summary — refreshed by prc_refresh_sales_monthly_summary.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.TD_SALES_SUM (
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

CREATE INDEX IF NOT EXISTS td_sales_sum_idx1
    ON ANAPLAN.TD_SALES_SUM (DIVISION, PERIOD);
CREATE INDEX IF NOT EXISTS td_sales_sum_idx2
    ON ANAPLAN.TD_SALES_SUM (CUSTOMERCODE);

COMMENT ON TABLE ANAPLAN.TD_SALES_SUM IS
    'Published monthly sales summary subset. Refreshed by prc_refresh_sales_monthly_summary.';
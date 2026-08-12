-- =============================================================================
-- TABLE: anaplan_dev.md_customer_detail_t
-- Source: Oracle ANAPLAN.MD_CUSTOMER_DETAIL_T
-- Purpose: Materialized snapshot of the md_customer_detail view.
--          Refreshed by prc_refresh_sales_daily_summary.
--          Dependency: td_delivery_v, mm_daily_sales_v, mm_daily_sales_det_v
--          all JOIN this TABLE (not the view) to avoid chain latency.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.MD_CUSTOMER_DETAIL_T (
    DIVISION             VARCHAR(108),
    L1_REGION            VARCHAR(108),
    L2_SALESCHANNEL      VARCHAR(108),
    L3_CUSTOMERGROUP     VARCHAR(108),
    L4_CHAIN             VARCHAR(108),
    L5_CUSTOMER          VARCHAR(108),
    L6_EXCISE_DEPO       VARCHAR(108),
    L3_CODE              VARCHAR(108),
    L4_CODE              VARCHAR(108),
    L5_CODE              VARCHAR(108),
    L6_CODE              VARCHAR(108),
    EXC_TMP              VARCHAR(3),
    DEP_TMP              VARCHAR(3),
    SHOP                 VARCHAR(108),
    CHARGEMODEL          VARCHAR(108),
    M3CUSTOMERCODE       VARCHAR(108),
    M3STATUS             VARCHAR(108),
    EXCISE               VARCHAR(3),
    DEPOFEE              VARCHAR(3),
    PRICELIST_REF        VARCHAR(108),
    BONUSGROUP_REF       VARCHAR(108),
    DISCOUNTGROUP_REF    VARCHAR(108),
    DELIVERYGROUP        VARCHAR(108),
    DELIVERYGROUP_CODE   VARCHAR(108),
    LOCAL_REGION         VARCHAR(24),
    SALESPERSON          VARCHAR(30),
    BUDGET_CUSTOMERCODE  VARCHAR(10)
);

CREATE INDEX IF NOT EXISTS MD_CUSTOMER_DETAIL_T_IDX1
    ON ANAPLAN.MD_CUSTOMER_DETAIL_T (M3CUSTOMERCODE);
CREATE INDEX IF NOT EXISTS MD_CUSTOMER_DETAIL_T_IDX2
    ON ANAPLAN.MD_CUSTOMER_DETAIL_T (DIVISION);

COMMENT ON TABLE ANAPLAN.MD_CUSTOMER_DETAIL_T IS
    'Materialized snapshot of ANAPLAN.MD_CUSTOMER_DETAIL_V. Refreshed by CALL ANAPLAN.PRC_REFRESH_SALES_DAILY_SUMMARY(). Empty until first procedure run.';

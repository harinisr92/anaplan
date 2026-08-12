-- =============================================================================
-- TABLE: anaplan_dev.md_budget_customer_200
-- Source: Oracle ANAPLAN.MD_BUDGET_CUSTOMER_200
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.MD_BUDGET_CUSTOMER_200 (
    DIVISION      VARCHAR(3),
    LOCAL_REGION  VARCHAR(6),
    DISTRICT      VARCHAR(6),
    CUSTOMERCODE  VARCHAR(10)
);

COMMENT ON TABLE ANAPLAN.MD_BUDGET_CUSTOMER_200 IS
    'Budget customer list for Division 200 with district breakdown.';

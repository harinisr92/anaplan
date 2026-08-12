-- =============================================================================
-- TABLE: anaplan_dev.md_budget_customer
-- Source: Oracle ANAPLAN.MD_BUDGET_CUSTOMER
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.MD_BUDGET_CUSTOMER (
    DIVISION      VARCHAR(3),
    LOCAL_REGION  VARCHAR(6),
    CUSTOMERCODE  VARCHAR(10)
);

COMMENT ON TABLE ANAPLAN.MD_BUDGET_CUSTOMER IS
    'Budget customer list for Division 200 (ALC) and 700 (CESU).';

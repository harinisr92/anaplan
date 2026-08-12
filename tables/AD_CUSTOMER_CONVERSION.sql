-- =============================================================================
-- TABLE: ANAPLAN.AD_CUSTOMER_CONVERSION
-- Source: Oracle ANAPLAN.AD_CUSTOMER_CONVERSION
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.AD_CUSTOMER_CONVERSION (
    DIVI        VARCHAR(3)  NOT NULL,
    OLDCUSTOMER VARCHAR(11) NOT NULL,
    NEWCUSTOMER VARCHAR(11) NOT NULL,
    TXTCOMMENT  VARCHAR(85),
    PRIMARY KEY (DIVI, OLDCUSTOMER)
);
COMMENT ON TABLE ANAPLAN.AD_CUSTOMER_CONVERSION IS
    'Customer code conversion mapping — used by TD_MARKETINGMONEY to remap old to new customer codes.';
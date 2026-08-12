-- =============================================================================
-- TABLE: anaplan_dev.ol_salesinvoicediscounts
-- Source: Oracle ANAPLAN.OL_SALESINVOICEDISCOUNTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.OL_SALESINVOICEDISCOUNTS (
    VAITNO VARCHAR(45),
    VASAAM NUMERIC(15,3),
    VAVOL3 NUMERIC(15,3),
    VAOVQT NUMERIC(15,3),
    VAEXCI NUMERIC(15,3),
    VAINVO NUMERIC(15,3),
    VAINPR NUMERIC(15,3),
    VACBVO NUMERIC(15,3),
    VACAPR NUMERIC(15,3),
    VAMAVO NUMERIC(15,3),
    VAMAPR NUMERIC(15,3),
    VACOVO NUMERIC(15,3),
    VACOPR NUMERIC(15,3),
    VAMAEU NUMERIC(15,3),
    VASMVO NUMERIC(15,3),
    VASCBV NUMERIC(15,3),
    VASDIV NUMERIC(15,3),
    VASMAV NUMERIC(15,3),
    VASCBP NUMERIC(15,3),
    VASDIP NUMERIC(15,3),
    VAACRF VARCHAR(100),
    VAYEMO NUMERIC(15,0)
);

COMMENT ON TABLE ANAPLAN.OL_SALESINVOICEDISCOUNTS IS
    'Sales invoice discount detail rows loaded from M3 OLVI.';
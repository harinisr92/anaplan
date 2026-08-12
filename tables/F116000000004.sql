-- =============================================================================
-- TABLE: anaplan_dev.f116000000004
-- Source: Oracle ANAPLAN.F116000000004 (was ORGANIZATION EXTERNAL, comma-delimited CSV)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.F116000000004 (
    MATERIALS_L4_MATERIALS_SS_CODE VARCHAR(100),
    TIME                             VARCHAR(38),
    COMPANYCODE                      VARCHAR(38),
    DIVISION                         VARCHAR(38),
    PERIOD                           NUMERIC(6,0),
    ITEMCODE                         VARCHAR(45),
    QUANTITY                         NUMERIC(38,6),
    PRICE                            NUMERIC(38,6),
    PRICE_PURE                       NUMERIC(38,6),
    PRICE_AVG                        NUMERIC(38,6),
    CURR_RATE                        NUMERIC(10,4)
);

COMMENT ON TABLE ANAPLAN.F116000000004 IS
    'Anaplan load staging — was Oracle external table (116000000004.csv). Load via ETL.';

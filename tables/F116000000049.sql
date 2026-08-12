-- =============================================================================
-- TABLE: anaplan_dev.f116000000049
-- Source: Oracle ANAPLAN.F116000000049 (was ORGANIZATION EXTERNAL, comma-delimited CSV)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.F116000000049 (
    TIME           VARCHAR(35),
    DIVISION       VARCHAR(35),
    PERIOD         VARCHAR(35),
    DATATYPE       VARCHAR(35),
    PRODUCT_CODE   VARCHAR(35),
    MATERIAL_CODE  VARCHAR(35),
    COST_COMPONENT VARCHAR(35),
    QTY_1000L      VARCHAR(35),
    PRICE          VARCHAR(35),
    COST_L         VARCHAR(35)
);

COMMENT ON TABLE ANAPLAN.F116000000049 IS
    'Anaplan load staging — was Oracle external table (116000000049.csv). Load via ETL.';
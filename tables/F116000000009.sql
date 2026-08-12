-- =============================================================================
-- TABLE: anaplan_dev.f116000000009
-- Source: Oracle ANAPLAN.F116000000009 (was ORGANIZATION EXTERNAL, comma-delimited CSV)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.F116000000009 (
    ITEM      VARCHAR(35),
    CUSTOMERS VARCHAR(35),
    DAY       VARCHAR(10),
    VERSION   VARCHAR(35),
    FORECAST  VARCHAR(35),
    VALUE     VARCHAR(35)
);

COMMENT ON TABLE ANAPLAN.F116000000009 IS
    'Anaplan load staging — was Oracle external table (116000000009.csv). Load via ETL.';

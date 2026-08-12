-- =============================================================================
-- TABLE: ANAPLAN.ANAP_CURRENCYRATES
-- Source: Oracle ANAPLAN.ANAP_CURRENCYRATES (was ORGANIZATION EXTERNAL from CSV)
-- Note: Oracle external table reading 116000000011.csv — load via ETL in PG.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.ANAP_CURRENCYRATES (
    COMPANY        VARCHAR(100),
    TIME           VARCHAR(20),
    VERSIONS       VARCHAR(30),
    DIVI           VARCHAR(30),
    LOCALCURRENCY  VARCHAR(3),
    PERIOD         VARCHAR(6),
    AVERAGE_RATE   VARCHAR(35),
    CLOSING_RATE   VARCHAR(35),
    DATATYPE       VARCHAR(15)
);
COMMENT ON TABLE ANAPLAN.ANAP_CURRENCYRATES IS
    'Currency rates. Originally Oracle external table (116000000011.csv) — load via ETL pipeline in PostgreSQL.';
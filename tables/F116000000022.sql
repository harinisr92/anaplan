-- =============================================================================
-- TABLE: anaplan_dev.f116000000022
-- Source: Oracle ANAPLAN.F116000000022 (was ORGANIZATION EXTERNAL, pipe-delimited CSV)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.F116000000022 (
    CONO VARCHAR(3),
    DIVI VARCHAR(3),
    WHLO VARCHAR(3),
    ITNO VARCHAR(35),
    FDAT VARCHAR(35),
    TDAT VARCHAR(35),
    VOL3 VARCHAR(35)
);

COMMENT ON TABLE ANAPLAN.F116000000022 IS
    'Anaplan load staging — was Oracle external table (116000000022.csv, pipe-delimited). Load via ETL.';

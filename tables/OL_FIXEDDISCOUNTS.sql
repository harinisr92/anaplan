-- =============================================================================
-- TABLE: anaplan_dev.ol_fixeddiscounts
-- Source: Oracle ANAPLAN.OL_FIXEDDISCOUNTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.OL_FIXEDDISCOUNTS (
    VFCONT VARCHAR(30),
    VFCUNO VARCHAR(30),
    VFITNO VARCHAR(45),
    VFIVDT NUMERIC(8,0),
    VFSAAM NUMERIC(15,2),
    VFSYTP VARCHAR(100),
    VFDIVI VARCHAR(9)
);

COMMENT ON TABLE ANAPLAN.OL_FIXEDDISCOUNTS IS
    'Fixed discount contracts loaded from M3 OLVI.';
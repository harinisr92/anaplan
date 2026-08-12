-- =============================================================================
-- TABLE: ref.DIVISION_FILTER
-- Purpose: Central registry of which divisions come from external schemas.
--          Used to document the NOT IN ('800','400') patterns across views.
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.DIVISION_FILTER (
    DIVISION      VARCHAR(10) NOT NULL,
    SOURCE_SYSTEM VARCHAR(20) NOT NULL,
    ACTIVE        BOOLEAN     NOT NULL DEFAULT TRUE,
    NOTE          VARCHAR(100),
    PRIMARY KEY (DIVISION, SOURCE_SYSTEM)
);

TRUNCATE ref.DIVISION_FILTER;
INSERT INTO ref.DIVISION_FILTER (DIVISION, SOURCE_SYSTEM, ACTIVE, NOTE) VALUES
    ('800', 'LBM3PRD1', TRUE, 'LIDA — fetched via compat schema lbm3prd1_anaplan'),
    ('400', 'M3SKY',    TRUE, 'VESTFYEN — fetched via compat schema m3sky_anaplan');

COMMENT ON TABLE ref.DIVISION_FILTER IS
    'Registry of divisions sourced from external compat schemas. Documents the NOT IN (800,400) patterns.';

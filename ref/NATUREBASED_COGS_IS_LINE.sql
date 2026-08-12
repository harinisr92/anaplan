-- =============================================================================
-- TABLE: ref.NATUREBASED_COGS_IS_LINE
-- Replaces: Large CASE WHEN ait1 IN (...) THEN label in TD_NATUREBASED_COGS
-- Used by:  td_naturebased_cogs_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.NATUREBASED_COGS_IS_LINE (
    MATCH_TYPE    VARCHAR(10)  NOT NULL,   -- 'EXACT' or 'LIKE'
    AIT1_VALUE    VARCHAR(50)  NOT NULL,
    IS_LINE_LABEL VARCHAR(100) NOT NULL,
    SORT_ORDER    INT          NOT NULL,
    PRIMARY KEY (MATCH_TYPE, AIT1_VALUE)
);

TRUNCATE ref.NATUREBASED_COGS_IS_LINE;
INSERT INTO ref.NATUREBASED_COGS_IS_LINE (MATCH_TYPE, AIT1_VALUE, IS_LINE_LABEL, SORT_ORDER) VALUES
    ('EXACT', '2001000P',   'Materials purchased (raw + packaging)', 1),
    ('EXACT', '2004000P',   'Materials purchased (raw + packaging)', 2),
    ('EXACT', '2001000COI', 'Materials purchased (raw + packaging)', 3),
    ('EXACT', '2005000P',   'Purchased ready products for resale',   4),
    ('EXACT', '2003000P',   'Purchased ready products for resale',   5),
    ('EXACT', '1020000M',   'Production depreciation',               6),
    ('EXACT', '9101020',    'Production depreciation',               7),
    ('EXACT', '5106020M',   'Production direct salaries',            8),
    ('EXACT', '5106030M',   'Water and waste water',                 9),
    ('EXACT', '5106040M',   'Production electricity',               10),
    ('EXACT', '5106050M',   'Production heating',                   11),
    ('EXACT', '5106060M',   'Production repairs and spare parts',   12),
    ('EXACT', '5106090M',   'Other production costs',               13),
    ('LIKE',  '9002%',      'Semi-finished costs',                  14),
    ('LIKE',  '9003%',      'Variances',                            15),
    ('LIKE',  '9004%',      'Variances',                            16),
    ('LIKE',  '2.1%',       'Other production costs',               17),
    ('LIKE',  '5%',         'Other production costs',               18),
    ('LIKE',  '0%',         'Balancing',                            19),
    ('LIKE',  '9%',         'Change of inventory of WIP and fin prod', 20);

COMMENT ON TABLE ref.NATUREBASED_COGS_IS_LINE IS
    'IS_LINE label lookup for TD_NATUREBASED_COGS. Replaces hardcoded CASE WHEN ait1 IN (...) Oracle logic.';

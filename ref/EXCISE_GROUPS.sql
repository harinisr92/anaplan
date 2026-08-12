-- =============================================================================
-- TABLE: ref.EXCISE_GROUPS
-- Replaces: Hardcoded UNION ALL SELECT FROM DUAL in Oracle AD_EXCISEGROUPS
-- Used by:  ad_excisegroups_v, md_product_v
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS ref;

CREATE TABLE IF NOT EXISTS ref.EXCISE_GROUPS (
    EXCISEGROUPCODE  VARCHAR(50)  NOT NULL PRIMARY KEY,
    EXCISEGROUPNAME  VARCHAR(255) NOT NULL
);

TRUNCATE ref.EXCISE_GROUPS;
INSERT INTO ref.EXCISE_GROUPS (EXCISEGROUPCODE, EXCISEGROUPNAME) VALUES
    ('beer',          'Beer'),
    ('ferm_over6',    'Other fermented drink over 6% alc'),
    ('ferm_till_8.5', 'Other fermented drink until 8.5% alc'),
    ('ferm_over_8.5', 'Other fermented drink over 8.5% alc'),
    ('ferm_till6',    'Other fermented drink until 6% alc'),
    ('inter',         'Intermediate products alc'),
    ('spirit',        'Spirit-based alcoholic drinks'),
    ('soft',          'Soft drinks'),
    ('sugar',         'Containing sugar'),
    ('undefined',     'Undefined excise group'),
    ('no',            'No excise'),
    ('800winebased',  'Слабоалкогольные на винной основе'),
    ('800beerover7',  'Пиво крепкое (>7%)'),
    ('800beerto7',    'Пиво'),
    ('800cider',      'Сидр'),
    ('800energy',     'Энергетические напитки');

COMMENT ON TABLE ref.EXCISE_GROUPS IS
    'Excise group code/name lookup. Replaces hardcoded DUAL UNION ALL in AD_EXCISEGROUPS Oracle view.';

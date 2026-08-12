-- =============================================================================
-- TABLE: ref.CAPEX_INVESTMENT_CODE_RULES
-- Replaces: CASE WHEN division/date logic for investment_code in TD_CAPEX
-- Used by:  td_capex_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.CAPEX_INVESTMENT_CODE_RULES (
    RULE_ID        SERIAL PRIMARY KEY,
    CONDITION_TYPE VARCHAR(30) NOT NULL,
    DIVISION       VARCHAR(10),
    CUTOFF_DATE    INT,
    SOURCE_DIM     VARCHAR(5)  NOT NULL,
    NOTE           VARCHAR(200)
);

TRUNCATE ref.CAPEX_INVESTMENT_CODE_RULES;
INSERT INTO ref.CAPEX_INVESTMENT_CODE_RULES
    (CONDITION_TYPE, DIVISION, CUTOFF_DATE, SOURCE_DIM, NOTE) VALUES
    ('DATE_BEFORE',   NULL,  20260101, 'DIM5', 'All divisions: before 2026-01-01 use DIM5'),
    ('DIVISION_DIM5', '100', NULL,     'DIM5', 'Olvi always uses DIM5'),
    ('DIVISION_DIM5', '300', NULL,     'DIM5', 'Servaali always uses DIM5'),
    ('DEFAULT_DIM6',  NULL,  NULL,     'DIM6', 'All other divisions after 2026-01-01 use DIM6');

COMMENT ON TABLE ref.CAPEX_INVESTMENT_CODE_RULES IS
    'Rules for CAPEX investment_code derivation. Replaces CASE logic in TD_CAPEX Oracle view.';

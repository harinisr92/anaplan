-- =============================================================================
-- TABLE: ref.L1_REGION_CODES
-- Replaces: the 3 pure code-list branches (of 9 total WHEN branches) inside
--           the l1_region CASE expression, duplicated identically in
--           MD_CUSTOMER_DETAIL and MD_CUSTOMER. The other 6 branches are
--           single-value/BETWEEN comparisons on other columns and are left
--           inline in the CASE — this table only replaces the literal
--           IN (...) lists, nothing else.
-- IMPORTANT: rule order in the CASE (priority) is NOT reconstructed from
--           this table — the WHEN branches stay in their original order in
--           the view SQL. This table is purely a lookup for the codes each
--           branch tests against, referenced via a scalar subquery per
--           branch (WHERE rule_id = 'l1_rule_5' etc.), so "first match
--           wins" semantics are unaffected.
-- Used by:  md_customer_detail_v, md_customer_v, tst_customer_detail_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.L1_REGION_CODES (
    RULE_ID      VARCHAR(20) NOT NULL,
    PRIORITY     INT         NOT NULL,   -- position in the original CASE, for reference/audit only
    MATCH_COLUMN VARCHAR(20) NOT NULL,
    CODE         VARCHAR(10) NOT NULL,
    RESULT_LABEL VARCHAR(30) NOT NULL,
    PRIMARY KEY (RULE_ID, CODE)
);

INSERT INTO ref.L1_REGION_CODES (RULE_ID, PRIORITY, MATCH_COLUMN, CODE, RESULT_LABEL) VALUES
    ('l1_rule_5', 5, 'okcucl', '905', 'EXPORT'),
    ('l1_rule_5', 5, 'okcucl', '907', 'EXPORT'),
    ('l1_rule_6', 6, 'okcucl', '900', 'TRAVELTRADE'),
    ('l1_rule_6', 6, 'okcucl', '901', 'TRAVELTRADE'),
    ('l1_rule_6', 6, 'okcucl', '903', 'TRAVELTRADE'),
    ('l1_rule_9', 9, 'okcucl', '910', 'GROUP'),
    ('l1_rule_9', 9, 'okcucl', '176', 'GROUP'),
    ('l1_rule_9', 9, 'okcucl', '177', 'GROUP'),
    ('l1_rule_9', 9, 'okcucl', '178', 'GROUP'),
    ('l1_rule_9', 9, 'okcucl', '179', 'GROUP'),
    ('l1_rule_9', 9, 'okcucl', '180', 'GROUP')
ON CONFLICT (RULE_ID, CODE) DO NOTHING;

COMMENT ON TABLE ref.L1_REGION_CODES IS
    'Code lists for the 3 IN(...) branches of the l1_region CASE (of 9 total branches — the other 6 are single-value/BETWEEN checks left inline). Order of evaluation is preserved in the view SQL itself, not in this table.';

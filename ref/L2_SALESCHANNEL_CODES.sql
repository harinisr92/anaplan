-- =============================================================================
-- TABLE: ref.L2_SALESCHANNEL_CODES
-- Replaces: the 8 pure code-list branches (of 21 total WHEN branches) inside
--           the l2_saleschannel CASE expression, duplicated identically in
--           MD_CUSTOMER_DETAIL, MD_CUSTOMER, and TST_CUSTOMER_DETAIL. The
--           other 13 branches are single-value/BETWEEN/compound-AND
--           comparisons and are left inline in the CASE — this table only
--           replaces literal IN (...) / NOT IN (...) lists.
-- IMPORTANT: same as ref.L1_REGION_CODES — rule order (priority) is
--           NOT reconstructed from this table. The WHEN branches keep their
--           original order in the view SQL; this table is a lookup
--           referenced via a scalar subquery per branch, so "first match
--           wins" semantics are unaffected.
-- Rule 21 is a NOT IN in the original CASE (matches everything NOT in this
--           list) — referenced as "okcfc1 NOT IN (SELECT code FROM ...
--           WHERE rule_id = 'l2_rule_21')" in the view, same codes, inverted
--           membership test, not a different meaning of this table.
-- Used by:  md_customer_detail_v, md_customer_v, tst_customer_detail_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.L2_SALESCHANNEL_CODES (
    RULE_ID      VARCHAR(20) NOT NULL,
    PRIORITY     INT         NOT NULL,   -- position in the original CASE, for reference/audit only
    MATCH_COLUMN VARCHAR(20) NOT NULL,
    CODE         VARCHAR(10) NOT NULL,
    RESULT_LABEL VARCHAR(30) NOT NULL,
    PRIMARY KEY (RULE_ID, CODE)
);

INSERT INTO ref.L2_SALESCHANNEL_CODES (RULE_ID, PRIORITY, MATCH_COLUMN, CODE, RESULT_LABEL) VALUES
    -- rule 2: division-800 RETAIL codes (okrasn='800' AND okcfc6 IN (...))
    ('l2_rule_2', 2, 'okcfc6', '8RKA', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8RKA1', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8RKA2', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8OTHERS', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8TR', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8DISTRIBUT', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8E-TRADE', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8OPS', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8OPT', 'RETAIL'),
    ('l2_rule_2', 2, 'okcfc6', '8???', 'RETAIL'),
    -- rule 9: HORECA account codes (okacrf IN (...))
    ('l2_rule_9', 9, 'okacrf', '4720', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4721', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4722', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4723', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4724', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4725', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4726', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4730', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4740', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4745', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4750', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4755', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4756', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4760', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4761', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4762', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4818', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4846', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4847', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '4844', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42032', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42039', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42041', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42042', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42043', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42044', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42045', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42046', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42047', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42048', 'HORECA'),
    ('l2_rule_9', 9, 'okacrf', '42049', 'HORECA'),
    -- rule 12: GROUP account codes (okacrf IN (...))
    ('l2_rule_12', 12, 'okacrf', '4451', 'GROUP'),
    ('l2_rule_12', 12, 'okacrf', '4457', 'GROUP'),
    ('l2_rule_12', 12, 'okacrf', '4459', 'GROUP'),
    ('l2_rule_12', 12, 'okacrf', '4839', 'GROUP'),
    ('l2_rule_12', 12, 'okacrf', '2501', 'GROUP'),
    -- rule 13: RETAIL customer classes (okcucl IN (...))
    ('l2_rule_13', 13, 'okcucl', '182', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '154', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '155', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '156', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '250', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '255', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '211', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '212', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '213', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '214', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '215', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '216', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '217', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '218', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '219', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '230', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '259', 'RETAIL'),
    ('l2_rule_13', 13, 'okcucl', '459', 'RETAIL'),
    -- rule 16: HORECA customer classes (okcucl IN (...))
    ('l2_rule_16', 16, 'okcucl', '220', 'HORECA'),
    ('l2_rule_16', 16, 'okcucl', '606', 'HORECA'),
    ('l2_rule_16', 16, 'okcucl', '720', 'HORECA'),
    ('l2_rule_16', 16, 'okcucl', '420', 'HORECA'),
    ('l2_rule_16', 16, 'okcucl', '419', 'HORECA'),
    -- rule 18: TRAVELTRADE customer classes (okcucl IN (...))
    ('l2_rule_18', 18, 'okcucl', '900', 'TRAVELTRADE'),
    ('l2_rule_18', 18, 'okcucl', '903', 'TRAVELTRADE'),
    ('l2_rule_18', 18, 'okcucl', '901', 'TRAVELTRADE'),
    ('l2_rule_18', 18, 'okcucl', '183', 'TRAVELTRADE'),
    -- rule 19: EXPORT customer classes (okcucl IN (...))
    ('l2_rule_19', 19, 'okcucl', '905', 'EXPORT'),
    ('l2_rule_19', 19, 'okcucl', '907', 'EXPORT'),
    -- rule 20: GROUP customer classes (okcucl IN (...))
    ('l2_rule_20', 20, 'okcucl', '910', 'GROUP'),
    ('l2_rule_20', 20, 'okcucl', '176', 'GROUP'),
    ('l2_rule_20', 20, 'okcucl', '177', 'GROUP'),
    ('l2_rule_20', 20, 'okcucl', '178', 'GROUP'),
    ('l2_rule_20', 20, 'okcucl', '179', 'GROUP'),
    ('l2_rule_20', 20, 'okcucl', '180', 'GROUP'),
    -- rule 21: NOT IN — wholesale-exclusion codes (okcfc1 NOT IN (...) -> RETAIL)
    ('l2_rule_21', 21, 'okcfc1', '7006', 'RETAIL'),
    ('l2_rule_21', 21, 'okcfc1', '7010', 'RETAIL'),
    ('l2_rule_21', 21, 'okcfc1', '7011', 'RETAIL'),
    ('l2_rule_21', 21, 'okcfc1', '7012', 'RETAIL'),
    ('l2_rule_21', 21, 'okcfc1', '7013', 'RETAIL'),
    ('l2_rule_21', 21, 'okcfc1', '7014', 'RETAIL'),
    ('l2_rule_21', 21, 'okcfc1', '7015', 'RETAIL'),
    ('l2_rule_21', 21, 'okcfc1', '7018', 'RETAIL'),
    ('l2_rule_21', 21, 'okcfc1', '7019', 'RETAIL')
ON CONFLICT (RULE_ID, CODE) DO NOTHING;

COMMENT ON TABLE ref.L2_SALESCHANNEL_CODES IS
    'Code lists for the 8 IN(...)/NOT IN(...) branches of the l2_saleschannel CASE (of 21 total branches). Order of evaluation is preserved in the view SQL itself, not in this table. Rule 21 is inverted (NOT IN) in the view.';

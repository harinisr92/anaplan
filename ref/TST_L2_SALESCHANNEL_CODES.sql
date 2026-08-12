-- =============================================================================
-- TABLE: ref.TST_L2_SALESCHANNEL_CODES
-- Replaces: the code-list branches inside TST_CUSTOMER_DETAIL's
--           l2_saleschannel CASE. NOT the same rule set as
--           ref.L2_SALESCHANNEL_CODES (MD_CUSTOMER_DETAIL) — confirmed
--           via live data comparison that TST_CUSTOMER_DETAIL classifies
--           customers differently (systematically calls HORECA customers
--           RETAIL, because it's missing MD's okcfc3/okacrf-based rules).
--           See ad-hoc investigation, [date of this conversation] — 50/50
--           sampled customers showed l2_saleschannel disagreement, 0 rows
--           in all_dependencies (nothing inside Oracle references this
--           view). Kept as its own separate table rather than reusing
--           ref.L2_SALESCHANNEL_CODES.
-- IMPORTANT — deliberately NOT bug-fixed: rule 1 preserves the same
--           malformed ',218' literal (a single 5-character string
--           containing a leading comma, not two codes '217'/'218') found
--           in MD_CUSTOMER_DETAIL. For MD, we confirmed via production data
--           that fixing it changes nothing (all affected customers land on
--           RETAIL via a later catch-all rule anyway) before fixing it.
--           That same investigation has NOT been done for
--           TST_CUSTOMER_DETAIL's data, and this view has no later
--           catch-all rule protecting against it the way MD's rule 21
--           does — so the fix's impact here is unverified. Preserved as-is
--           for faithful parity; flagged as an open item to revisit.
-- l1_region: TST_CUSTOMER_DETAIL's 3 code-list branches (EXPORT/TRAVELTRADE/
--           GROUP) are byte-identical in content to MD_CUSTOMER_DETAIL's
--           l1_rule_5/l1_rule_6/l1_rule_9 — reused directly from
--           ref.L1_REGION_CODES, no separate table needed for l1.
-- Used by:  tst_customer_detail_v only
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.TST_L2_SALESCHANNEL_CODES (
    RULE_ID      VARCHAR(20) NOT NULL,
    PRIORITY     INT         NOT NULL,   -- position in the original CASE, for reference/audit only
    MATCH_COLUMN VARCHAR(20) NOT NULL,
    CODE         VARCHAR(10) NOT NULL,
    RESULT_LABEL VARCHAR(30) NOT NULL,
    PRIMARY KEY (RULE_ID, CODE)
);

INSERT INTO ref.TST_L2_SALESCHANNEL_CODES (RULE_ID, PRIORITY, MATCH_COLUMN, CODE, RESULT_LABEL) VALUES
    -- rule 1: RETAIL customer classes (okcucl IN (...)) — NOT bug-fixed, see note above
    ('tst_l2_rule_1', 1, 'okcucl', '182', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '154', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '155', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '156', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '250', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '255', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '211', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '212', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '213', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '214', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '215', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '216', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '217', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', ',218', 'RETAIL'),   -- malformed literal preserved as-is, deliberately (see header note)
    ('tst_l2_rule_1', 1, 'okcucl', '219', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '230', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '259', 'RETAIL'),
    ('tst_l2_rule_1', 1, 'okcucl', '459', 'RETAIL'),
    -- rule 4: RETAIL by specific payer code (okpyno IN (...))
    ('tst_l2_rule_4', 4, 'okpyno', '20009048', 'RETAIL'),
    ('tst_l2_rule_4', 4, 'okpyno', '20011837', 'RETAIL'),
    -- rule 5: HORECA customer classes (okcucl IN (...)) — differs from MD's HORECA list
    ('tst_l2_rule_5', 5, 'okcucl', '220', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '606', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '154', 'HORECA'),   -- also appears in rule 1 (RETAIL) — unreachable here since rule 1 fires first; same dead-branch pattern as the ,218 bug, preserved as-is
    ('tst_l2_rule_5', 5, 'okcucl', '170', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '172', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '173', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '174', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '175', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '720', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '420', 'HORECA'),
    ('tst_l2_rule_5', 5, 'okcucl', '419', 'HORECA'),
    -- rule 6: HORECA, compound (okcucl IN (...) AND okcfc3='SK' stays inline in the view)
    ('tst_l2_rule_6', 6, 'okcucl', '130', 'HORECA'),
    ('tst_l2_rule_6', 6, 'okcucl', '140', 'HORECA'),
    ('tst_l2_rule_6', 6, 'okcucl', '171', 'HORECA'),
    -- rule 8: TRAVELTRADE customer classes
    ('tst_l2_rule_8', 8, 'okcucl', '900', 'TRAVELTRADE'),
    ('tst_l2_rule_8', 8, 'okcucl', '903', 'TRAVELTRADE'),
    ('tst_l2_rule_8', 8, 'okcucl', '901', 'TRAVELTRADE'),
    ('tst_l2_rule_8', 8, 'okcucl', '183', 'TRAVELTRADE'),
    -- rule 9: EXPORT customer classes
    ('tst_l2_rule_9', 9, 'okcucl', '905', 'EXPORT'),
    ('tst_l2_rule_9', 9, 'okcucl', '907', 'EXPORT'),
    -- rule 11: GROUP customer classes
    ('tst_l2_rule_11', 11, 'okcucl', '910', 'GROUP'),
    ('tst_l2_rule_11', 11, 'okcucl', '176', 'GROUP'),
    ('tst_l2_rule_11', 11, 'okcucl', '177', 'GROUP'),
    ('tst_l2_rule_11', 11, 'okcucl', '178', 'GROUP'),
    ('tst_l2_rule_11', 11, 'okcucl', '179', 'GROUP'),
    ('tst_l2_rule_11', 11, 'okcucl', '180', 'GROUP'),
    -- rule 12: NOT IN — wholesale-exclusion codes (okcfc1 NOT IN (...) -> RETAIL)
    ('tst_l2_rule_12', 12, 'okcfc1', '7006', 'RETAIL'),
    ('tst_l2_rule_12', 12, 'okcfc1', '7010', 'RETAIL'),
    ('tst_l2_rule_12', 12, 'okcfc1', '7011', 'RETAIL'),
    ('tst_l2_rule_12', 12, 'okcfc1', '7012', 'RETAIL'),
    ('tst_l2_rule_12', 12, 'okcfc1', '7013', 'RETAIL'),
    ('tst_l2_rule_12', 12, 'okcfc1', '7014', 'RETAIL'),
    ('tst_l2_rule_12', 12, 'okcfc1', '7015', 'RETAIL'),
    ('tst_l2_rule_12', 12, 'okcfc1', '7018', 'RETAIL'),
    ('tst_l2_rule_12', 12, 'okcfc1', '7019', 'RETAIL')
ON CONFLICT (RULE_ID, CODE) DO NOTHING;

COMMENT ON TABLE ref.TST_L2_SALESCHANNEL_CODES IS
    'Code lists for TST_CUSTOMER_DETAIL l2_saleschannel — a separate, less complete rule set than MD_CUSTOMER_DETAIL (confirmed via data comparison: misclassifies HORECA as RETAIL for at least 50 sampled customers; 0 rows in all_dependencies, no known consumer). Converted faithfully, bugs included, per decision to preserve as-is rather than align to MD or drop.';

-- =============================================================================
-- TABLE: ref.PRICELIST_CUSTOMER_REF
-- Replaces: Division/okcucl CASE logic in MD_CUSTOMER_DETAIL + MD_CUSTOMER
-- Used by:  md_customer_detail_v, md_customer_v
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.PRICELIST_CUSTOMER_REF (
    DIVISION      VARCHAR(10) NOT NULL,
    OKCUCL_FROM   VARCHAR(10),
    OKCUCL_TO     VARCHAR(10),
    OKCUCL_EXACT  VARCHAR(10),
    PRICELIST_REF VARCHAR(30) NOT NULL,
    NOTE          VARCHAR(100),
    SORT_ORDER    INT NOT NULL DEFAULT 10
);

TRUNCATE ref.PRICELIST_CUSTOMER_REF;
INSERT INTO ref.PRICELIST_CUSTOMER_REF
    (DIVISION, OKCUCL_FROM, OKCUCL_TO, OKCUCL_EXACT, PRICELIST_REF, NOTE, SORT_ORDER) VALUES
    ('200', '900', '903', NULL,  'TT-2A0',  'ALC TravelTrade', 1),
    ('200', NULL,  NULL,  NULL,  'DOM-2A0', 'ALC Domestic (okcucl<900)', 2),
    ('600', NULL,  NULL,  NULL,  '6R1',     'Volfas domestic', 1),
    ('700', '900', '903', NULL,  'TT-7C1',  'Cesu TravelTrade', 1),
    ('700', NULL,  NULL,  NULL,  'DOM-7C1', 'Cesu Domestic', 2),
    ('400', NULL,  NULL,  '400', '404',     'Vestfyen cucl 400', 1),
    ('400', NULL,  NULL,  '401', '405',     'Vestfyen cucl 401', 2),
    ('400', NULL,  NULL,  '402', '415',     'Vestfyen cucl 402', 3),
    ('400', NULL,  NULL,  '403', '412',     'Vestfyen cucl 403', 4),
    ('400', NULL,  NULL,  '404', '414',     'Vestfyen cucl 404', 5),
    ('400', NULL,  NULL,  '405', '410',     'Vestfyen cucl 405', 6),
    ('400', NULL,  NULL,  '406', '418',     'Vestfyen cucl 406', 7),
    ('400', NULL,  NULL,  '407', '413',     'Vestfyen cucl 407', 8),
    ('400', NULL,  NULL,  '408', '446',     'Vestfyen cucl 408', 9),
    ('400', NULL,  NULL,  '409', '432',     'Vestfyen cucl 409', 10),
    ('400', NULL,  NULL,  '419', '426',     'Vestfyen cucl 419', 11),
    ('400', NULL,  NULL,  '420', '438',     'Vestfyen cucl 420', 12),
    ('400', NULL,  NULL,  '430', '434',     'Vestfyen cucl 430', 13),
    ('400', NULL,  NULL,  '459', '454',     'Vestfyen cucl 459', 14),
    ('400', NULL,  NULL,  '903', '416',     'Vestfyen cucl 903', 15),
    ('400', NULL,  NULL,  '907', '449',     'Vestfyen cucl 907', 16);

COMMENT ON TABLE ref.PRICELIST_CUSTOMER_REF IS
    'Maps (division, okcucl) to pricelist_ref. Replaces CASE logic in MD_CUSTOMER_DETAIL + MD_CUSTOMER Oracle views.';

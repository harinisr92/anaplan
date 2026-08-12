-- =============================================================================
-- TABLE: ref.EXCLUDED_INTERNAL_SUPPLIER_CODES
-- Replaces: Hardcoded NOT IN (...) list of internal/dummy supplier codes,
--           pasted 3 times identically in AD_PURCHASE_AGREEMENT_PRICES
-- Used by:  ad_purchase_agreement_prices_v (all 3 sourcing branches:
--           item-level, purchase-group-level, item-group-level pricing)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref.EXCLUDED_INTERNAL_SUPPLIER_CODES (
    SUPPLIERCODE VARCHAR(10) NOT NULL PRIMARY KEY,
    NOTE         VARCHAR(100)
);

INSERT INTO ref.EXCLUDED_INTERNAL_SUPPLIER_CODES (SUPPLIERCODE, NOTE) VALUES
    ('9900001', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900002', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900004', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900005', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900006', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900007', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900009', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900010', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900011', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900069', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9900616', 'Internal/dummy supplier code — excluded from purchase agreement pricing'),
    ('9001049', 'Internal/dummy supplier code — excluded from purchase agreement pricing')
ON CONFLICT (SUPPLIERCODE) DO NOTHING;

COMMENT ON TABLE ref.EXCLUDED_INTERNAL_SUPPLIER_CODES IS
    'Internal/dummy supplier codes excluded from AD_PURCHASE_AGREEMENT_PRICES. Extracted from a literal list pasted 3 times identically in the Oracle original — now a single source of truth.';

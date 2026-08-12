-- =============================================================================
-- TABLE: anaplan_dev.td_mondays
-- Source: Oracle ANAPLAN.TD_MONDAYS
-- =============================================================================
CREATE TABLE IF NOT EXISTS ANAPLAN.TD_MONDAYS (
    COWEST NUMERIC
);

COMMENT ON TABLE ANAPLAN.TD_MONDAYS IS
    'List of Mondays (as week numbers) used for campaign weekly aggregation in TD_CAMPAIGNS_V.';
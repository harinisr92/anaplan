-- =============================================================================
-- 02_drop_schemas.sql
-- DESTRUCTIVE. Only run this after reviewing the output of
-- 01_check_dependencies.sql — specifically, check whether query #2 in that
-- script ("anything OUTSIDE these 4 schemas that depends on something
-- INSIDE them") returned any rows. If it did, either drop/update those
-- dependents deliberately first, or accept that CASCADE will remove them
-- too and confirm that's actually what you want.
--
-- Scope: drops ONLY the 4 schemas this package created:
--   anaplan_dev, ref_dev, lbm3prd1_anaplan, m3sky_anaplan
-- Does NOT touch mvxjdta, bousr, ve, alc, cesu, or anything else — those
-- are external source schemas this package reads FROM, never creates or
-- modifies.
--
-- CASCADE is required because objects within these schemas depend on each
-- other (views on tables, procedures on views, etc.) — DROP SCHEMA without
-- CASCADE will simply fail with a dependency error rather than partially
-- drop things, so this is safe in that sense: it's all-or-nothing per
-- schema, not a partial/inconsistent state.
-- =============================================================================

DROP SCHEMA IF EXISTS anaplan_dev CASCADE;
DROP SCHEMA IF EXISTS ref_dev CASCADE;
DROP SCHEMA IF EXISTS lbm3prd1_anaplan CASCADE;
DROP SCHEMA IF EXISTS m3sky_anaplan CASCADE;

-- After this, deploy_all.py / deploy_all.sh recreates all 4 schemas fresh
-- via CREATE SCHEMA IF NOT EXISTS as their first step — no manual schema
-- creation needed before re-running the full deploy.

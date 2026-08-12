-- =============================================================================
-- 03_check_original_schemas.sql
-- Read-only. Checks whether the "real" target schemas (anaplan, ref, and
-- whatever the non-_dev equivalents of lbm3prd1_anaplan/m3sky_anaplan are)
-- already exist, and what's currently in them — before deciding whether
-- anaplan_dev/ref_dev are meant to eventually replace them, run alongside
-- them, or get renamed into them.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Which schemas actually exist in this database right now?
--    Look for both the _dev ones we've been using AND their non-_dev
--    counterparts, plus anything else that might be relevant
--    (m3sky/lbm3prd1 without the _anaplan suffix, in case naming differs).
-- ---------------------------------------------------------------------------
SELECT nspname AS schema_name
FROM pg_namespace
WHERE nspname !~ '^(pg_|information_schema)'
ORDER BY
    CASE
        WHEN nspname IN ('anaplan','ref') THEN 1
        WHEN nspname IN ('anaplan_dev','ref_dev') THEN 2
        WHEN nspname ~ 'm3sky|lbm3prd1' THEN 3
        WHEN nspname IN ('mvxjdta','bousr','ve','alc','cesu') THEN 4
        ELSE 5
    END,
    nspname;

-- ---------------------------------------------------------------------------
-- 2. If 'anaplan' and/or 'ref' exist — what's actually in them?
--    This tells us whether they're empty placeholders, legacy content from
--    an older migration attempt, or something actively in use.
-- ---------------------------------------------------------------------------
SELECT
    n.nspname AS schema,
    c.relname AS object_name,
    CASE c.relkind
        WHEN 'r' THEN 'table'
        WHEN 'v' THEN 'view'
        WHEN 'm' THEN 'materialized view'
        WHEN 'f' THEN 'foreign table'
        ELSE c.relkind::text
    END AS object_type
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname IN ('anaplan', 'ref')
  AND c.relkind IN ('r','v','m','f')
ORDER BY n.nspname, c.relname;

-- Row counts on any physical tables in those schemas, if they exist
SELECT
    schemaname AS schema,
    relname    AS table_name,
    n_live_tup AS approx_row_count
FROM pg_stat_user_tables
WHERE schemaname IN ('anaplan', 'ref')
ORDER BY n_live_tup DESC, schema, table_name;

-- ---------------------------------------------------------------------------
-- 3. Does anything already depend on objects in 'anaplan'/'ref'?
--    Same style of check as the earlier drop-safety query — if Anaplan
--    itself (or another schema) is already pointed at ANAPLAN.* objects
--    here, that changes the cutover plan significantly.
-- ---------------------------------------------------------------------------
SELECT DISTINCT
    dependent_ns.nspname   AS dependent_schema,
    dependent_view.relname AS dependent_object,
    source_ns.nspname      AS depends_on_schema,
    source_table.relname   AS depends_on_object
FROM pg_depend
JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid
JOIN pg_class AS dependent_view ON pg_rewrite.ev_class = dependent_view.oid
JOIN pg_class AS source_table ON pg_depend.refobjid = source_table.oid
JOIN pg_namespace AS dependent_ns ON dependent_view.relnamespace = dependent_ns.oid
JOIN pg_namespace AS source_ns ON source_table.relnamespace = source_ns.oid
WHERE source_ns.nspname IN ('anaplan', 'ref')
  AND dependent_ns.nspname NOT IN ('anaplan', 'ref')
  AND dependent_view.relname != source_table.relname
ORDER BY dependent_schema, dependent_object;

-- ---------------------------------------------------------------------------
-- 4. Grants on 'anaplan'/'ref' — who currently has access, which tells us
--    who/what would be affected by any rename or cutover.
-- ---------------------------------------------------------------------------
SELECT grantee, table_schema, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema IN ('anaplan', 'ref')
ORDER BY table_schema, table_name, grantee;

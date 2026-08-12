-- =============================================================================
-- 01_check_dependencies.sql
-- RUN THIS FIRST. Read-only — nothing here modifies anything.
--
-- Purpose: before dropping anaplan_dev / ref_dev / lbm3prd1_anaplan /
-- m3sky_anaplan, confirm (a) what currently exists in each, and (b) whether
-- anything OUTSIDE these 4 schemas depends on objects inside them. That
-- second check matters because DROP SCHEMA ... CASCADE (in 02_drop_schemas.sql)
-- will also drop any external object that depends on something in these
-- schemas — e.g. a report view someone built in another schema that
-- references anaplan_dev.md_customer_v. This script surfaces that before it
-- happens, not after.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Inventory: everything currently in the 4 schemas we're about to touch
-- ---------------------------------------------------------------------------
SELECT
    n.nspname  AS schema,
    c.relname  AS object_name,
    CASE c.relkind
        WHEN 'r' THEN 'table'
        WHEN 'v' THEN 'view'
        WHEN 'm' THEN 'materialized view'
        WHEN 'f' THEN 'foreign table'
        ELSE c.relkind::text
    END AS object_type
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname IN ('anaplan_dev', 'ref_dev', 'lbm3prd1_anaplan', 'm3sky_anaplan')
  AND c.relkind IN ('r','v','m','f')
ORDER BY n.nspname, c.relname;

-- Functions/procedures in anaplan_dev (to_number_spec, receipt_multiplier, etc.)
SELECT
    n.nspname AS schema,
    p.proname AS object_name,
    CASE p.prokind WHEN 'f' THEN 'function' WHEN 'p' THEN 'procedure' ELSE p.prokind::text END AS object_type
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname IN ('anaplan_dev', 'ref_dev', 'lbm3prd1_anaplan', 'm3sky_anaplan')
ORDER BY n.nspname, p.proname;

-- ---------------------------------------------------------------------------
-- 2. THE IMPORTANT ONE: anything OUTSIDE these 4 schemas that depends on
--    something INSIDE them. If this returns any rows, review them before
--    proceeding — CASCADE will drop these dependents too.
-- ---------------------------------------------------------------------------
SELECT DISTINCT
    dependent_ns.nspname  AS dependent_schema,
    dependent_view.relname AS dependent_object,
    source_ns.nspname      AS depends_on_schema,
    source_table.relname   AS depends_on_object
FROM pg_depend
JOIN pg_rewrite ON pg_depend.objid = pg_rewrite.oid
JOIN pg_class AS dependent_view ON pg_rewrite.ev_class = dependent_view.oid
JOIN pg_class AS source_table ON pg_depend.refobjid = source_table.oid
JOIN pg_namespace AS dependent_ns ON dependent_view.relnamespace = dependent_ns.oid
JOIN pg_namespace AS source_ns ON source_table.relnamespace = source_ns.oid
WHERE source_ns.nspname IN ('anaplan_dev', 'ref_dev', 'lbm3prd1_anaplan', 'm3sky_anaplan')
  AND dependent_ns.nspname NOT IN ('anaplan_dev', 'ref_dev', 'lbm3prd1_anaplan', 'm3sky_anaplan')
  AND dependent_view.relname != source_table.relname
ORDER BY dependent_schema, dependent_object;

-- ---------------------------------------------------------------------------
-- 3. Row counts on the physical tables (not views) — a sanity check on
--    whether these schemas hold real accumulated data you'd lose (e.g. if
--    procedures have already been run and populated td_sales_sum etc.)
--    vs. being effectively empty/fresh.
-- ---------------------------------------------------------------------------
SELECT
    schemaname AS schema,
    relname    AS table_name,
    n_live_tup AS approx_row_count
FROM pg_stat_user_tables
WHERE schemaname IN ('anaplan_dev', 'ref_dev', 'lbm3prd1_anaplan', 'm3sky_anaplan')
ORDER BY n_live_tup DESC, schema, table_name;

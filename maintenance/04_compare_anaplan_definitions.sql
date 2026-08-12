-- =============================================================================
-- 04_compare_anaplan_definitions.sql
-- Read-only. Pulls the ACTUAL SQL definitions from the existing 'anaplan'
-- schema so we can diff them against what's in anaplan_dev, rather than
-- just comparing object name lists (which we already did in
-- 03_check_original_schemas.sql).
--
-- Goal: figure out whether 'anaplan' is an abandoned earlier migration
-- attempt, the schema Anaplan/reporting is currently actually pointed at,
-- or something else — by seeing whether its view logic matches ours,
-- differs meaningfully, or looks like an older/simpler version.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Full view definitions for everything in anaplan (this is the main one —
--    output can be long, see notes below on exporting to a file instead of
--    reading in a grid).
-- ---------------------------------------------------------------------------
SELECT
    n.nspname   AS schema,
    c.relname   AS view_name,
    pg_get_viewdef(c.oid, true) AS view_definition
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'anaplan'
  AND c.relkind = 'v'
ORDER BY c.relname;

-- ---------------------------------------------------------------------------
-- 2. Column definitions for the physical tables in anaplan (for comparing
--    against anaplan_dev's table DDL — column names/types/order).
-- ---------------------------------------------------------------------------
SELECT
    c.relname   AS table_name,
    a.attname   AS column_name,
    format_type(a.atttypid, a.atttypmod) AS data_type,
    a.attnum    AS column_order
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_attribute a ON a.attrelid = c.oid
WHERE n.nspname = 'anaplan'
  AND c.relkind = 'r'
  AND a.attnum > 0
  AND NOT a.attisdropped
ORDER BY c.relname, a.attnum;

-- ---------------------------------------------------------------------------
-- 3. Specifically flag the objects that DON'T exist in our anaplan_dev
--    package at all, or exist with a different name — these need direct
--    attention regardless of the broader diff:
--      - anaplan.md_product_20260330   (never seen before, dated like a
--        snapshot — same pattern as td_gl_sum_backup_20220616)
--      - anaplan.td_mondays            (the table cesu.campinfo200 depends
--        on — 0 rows currently, but td_campaigns_v's division-700 branch
--        is transitively dependent on this being populated eventually)
--      - anaplan.td_depreciaton_plan   (note the spelling — ours is
--        td_depreciation_plan_v; confirm if this is a typo in the original
--        or intentional)
-- ---------------------------------------------------------------------------
SELECT pg_get_viewdef('anaplan.md_product_20260330'::regclass, true) AS md_product_20260330_definition;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'anaplan' AND table_name = 'td_mondays'
ORDER BY ordinal_position;

SELECT pg_get_viewdef('anaplan.td_depreciaton_plan'::regclass, true) AS td_depreciaton_plan_definition;

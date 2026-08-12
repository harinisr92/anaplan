-- =============================================================================
-- PostgreSQL procedure for Oracle job: GM3_ANAPLAN_UPDATES_050000
-- Oracle schedule: FREQ=DAILY;BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN
-- Naming rule: keep Oracle job name unchanged using quoted PostgreSQL identifier.
-- Manual run: CALL ANAPLAN."GM3_ANAPLAN_UPDATES_050000"();
--
-- Important:
-- The Oracle job contains many ANAPLAN.SEND_DATA_NO_CHUNKS(...) export calls.
-- Those are intentionally skipped because send_data_no_chunks/authenticate/get_file
-- currently depend on missing HTTP integration objects:
--   http_response, http_header, http_post().
-- =============================================================================

CREATE OR REPLACE PROCEDURE ANAPLAN."GM3_ANAPLAN_UPDATES_050000"()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Oracle: ANAPLAN.PROC_SALES_DAILY_SUMMARIZE();
    IF EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'ANAPLAN'
          AND p.prokind = 'p'
          AND p.proname = 'proc_sales_daily_summarize'
    ) THEN
        CALL ANAPLAN.PROC_SALES_DAILY_SUMMARIZE();
    ELSIF EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'ANAPLAN'
          AND p.prokind = 'p'
          AND p.proname = 'refresh_sales_daily_summary'
    ) THEN
        CALL ANAPLAN.REFRESH_SALES_DAILY_SUMMARY();
    ELSE
        RAISE NOTICE 'Daily sales summary procedure not found; skipped.';
    END IF;

    -- Oracle: ANAPLAN.PROC_SALES_SUMMARIZE();
    IF EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'ANAPLAN'
          AND p.prokind = 'p'
          AND p.proname = 'proc_sales_summarize'
    ) THEN
        CALL ANAPLAN.PROC_SALES_SUMMARIZE();
    ELSIF EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'ANAPLAN'
          AND p.prokind = 'p'
          AND p.proname = 'refresh_sales_monthly_summary'
    ) THEN
        CALL ANAPLAN.REFRESH_SALES_MONTHLY_SUMMARY();
    ELSE
        RAISE NOTICE 'Monthly sales summary procedure not found; skipped.';
    END IF;

    RAISE NOTICE 'SEND_DATA_NO_CHUNKS export calls skipped. Pending HTTP integration migration for http_response/http_header/http_post or external ETL replacement.';
END;
$$;

COMMENT ON PROCEDURE ANAPLAN."GM3_ANAPLAN_UPDATES_050000"() IS
    'PostgreSQL partial equivalent of Oracle job GM3_ANAPLAN_UPDATES_050000. Runs migrated sales summary refreshes only. Anaplan export calls are pending HTTP integration migration.';

-- Optional scheduling via pg_cron. Safe skip when pg_cron is unavailable.
-- The original Oracle job name indicates 05:00 and its DBMS_SCHEDULER start date was at 05:00.
DO $$
BEGIN
    IF to_regnamespace('cron') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'GM3_ANAPLAN_UPDATES_050000') THEN
            PERFORM cron.schedule(
                'GM3_ANAPLAN_UPDATES_050000',
                '0 5 * * *',
                $cron$CALL ANAPLAN."GM3_ANAPLAN_UPDATES_050000"();$cron$
            );
        ELSE
            RAISE NOTICE 'Cron job already exists: GM3_ANAPLAN_UPDATES_050000';
        END IF;
    ELSE
        RAISE NOTICE 'pg_cron not available - scheduling skipped. Manual call: CALL ANAPLAN."GM3_ANAPLAN_UPDATES_050000"();';
    END IF;
END;
$$;

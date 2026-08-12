-- =============================================================================
-- PostgreSQL procedure for Oracle job: REFRESH_AVG_PRICE_UNTIL
-- Oracle job action: ANAPLAN.PROC_REFRESH_AVG_PRICE_UNTIL
-- Oracle schedule: FREQ=DAILY;BYTIME=010000
-- Naming rule: keep Oracle job name unchanged using quoted PostgreSQL identifier.
-- Manual run: CALL ANAPLAN."REFRESH_AVG_PRICE_UNTIL"();
-- =============================================================================

CREATE OR REPLACE PROCEDURE ANAPLAN."REFRESH_AVG_PRICE_UNTIL"()
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'ANAPLAN'
          AND p.prokind = 'p'
          AND p.proname = 'proc_refresh_avg_price_until'
    ) THEN
        CALL ANAPLAN.PROC_REFRESH_AVG_PRICE_UNTIL();
    ELSIF EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'ANAPLAN'
          AND p.prokind = 'p'
          AND p.proname = 'refresh_avg_price_until'
    ) THEN
        CALL ANAPLAN.REFRESH_AVG_PRICE_UNTIL();
    ELSE
        RAISE EXCEPTION 'Required avg price refresh procedure not found. Expected ANAPLAN.PROC_REFRESH_AVG_PRICE_UNTIL() or ANAPLAN.REFRESH_AVG_PRICE_UNTIL().';
    END IF;
END;
$$;

COMMENT ON PROCEDURE ANAPLAN."REFRESH_AVG_PRICE_UNTIL"() IS
    'PostgreSQL procedure equivalent of Oracle job REFRESH_AVG_PRICE_UNTIL. Calls migrated avg price refresh procedure.';

-- Optional scheduling via pg_cron. Safe skip when pg_cron is unavailable.
DO $$
BEGIN
    IF to_regnamespace('cron') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'REFRESH_AVG_PRICE_UNTIL') THEN
            PERFORM cron.schedule(
                'REFRESH_AVG_PRICE_UNTIL',
                '0 1 * * *',
                $cron$CALL ANAPLAN."REFRESH_AVG_PRICE_UNTIL"();$cron$
            );
        ELSE
            RAISE NOTICE 'Cron job already exists: REFRESH_AVG_PRICE_UNTIL';
        END IF;
    ELSE
        RAISE NOTICE 'pg_cron not available - scheduling skipped. Manual call: CALL ANAPLAN."REFRESH_AVG_PRICE_UNTIL"();';
    END IF;
END;
$$;

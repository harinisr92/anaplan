-- =============================================================================
-- PostgreSQL procedure for Oracle job: GM3_FILL_AD_LAST_PURCH_PRICE
-- Oracle schedule: FREQ=DAILY;BYTIME=010000
-- Naming rule: keep Oracle job name unchanged using quoted PostgreSQL identifier.
-- Manual run: CALL ANAPLAN."GM3_FILL_AD_LAST_PURCH_PRICE"();
-- =============================================================================

CREATE OR REPLACE PROCEDURE ANAPLAN."GM3_FILL_AD_LAST_PURCH_PRICE"()
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'ANAPLAN'
          AND p.prokind = 'p'
          AND p.proname = 'refresh_ad_last_purch_price'
    ) THEN
        CALL ANAPLAN.REFRESH_AD_LAST_PURCH_PRICE();
    ELSE
        RAISE EXCEPTION 'Required procedure not found: ANAPLAN.REFRESH_AD_LAST_PURCH_PRICE(). Create ad_last_purch_price_calc_v and REFRESH_AD_LAST_PURCH_PRICE() first.';
    END IF;
END;
$$;

COMMENT ON PROCEDURE ANAPLAN."GM3_FILL_AD_LAST_PURCH_PRICE"() IS
    'PostgreSQL procedure equivalent of Oracle job GM3_FILL_AD_LAST_PURCH_PRICE. Calls migrated REFRESH_AD_LAST_PURCH_PRICE(). Oracle DB-link portions must be covered by migrated calc view or external/federated replacement.';

-- Optional scheduling via pg_cron. Safe skip when pg_cron is unavailable.
DO $$
BEGIN
    IF to_regnamespace('cron') IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'GM3_FILL_AD_LAST_PURCH_PRICE') THEN
            PERFORM cron.schedule(
                'GM3_FILL_AD_LAST_PURCH_PRICE',
                '0 1 * * *',
                $cron$CALL ANAPLAN."GM3_FILL_AD_LAST_PURCH_PRICE"();$cron$
            );
        ELSE
            RAISE NOTICE 'Cron job already exists: GM3_FILL_AD_LAST_PURCH_PRICE';
        END IF;
    ELSE
        RAISE NOTICE 'pg_cron not available - scheduling skipped. Manual call: CALL ANAPLAN."GM3_FILL_AD_LAST_PURCH_PRICE"();';
    END IF;
END;
$$;

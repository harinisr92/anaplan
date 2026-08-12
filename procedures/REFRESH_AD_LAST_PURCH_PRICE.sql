-- =============================================================================
-- PROCEDURE: ANAPLAN.REFRESH_AD_LAST_PURCH_PRICE
-- Source: originally defined in 06_create_supporting_procedures.sql
-- =============================================================================
-- Migrated from: Oracle job GM3_FILL_AD_LAST_PURCH_PRICE (inline SQL, not a
-- named Oracle procedure). Reads ANAPLAN.AD_LAST_PURCH_PRICE_CALC for
-- the main (non-800/400) calculation, then appends division 800 from
-- LIDSKOE and division 400 from M3SKY — same compat-schema
-- pattern used in proc_refresh_avg_price_until().
-- NOTE: the previous version of this procedure only did the TRUNCATE +
-- main-calc INSERT below and silently dropped divisions 800/400. Restored
-- to match the original Oracle job's three-part refresh.
-- =============================================================================

CREATE OR REPLACE PROCEDURE ANAPLAN.REFRESH_AD_LAST_PURCH_PRICE()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Oracle: delete from ANAPLAN.AD_LAST_PURCH_PRICE where division <> '800';
    --         insert into ANAPLAN.AD_LAST_PURCH_PRICE select ... (main calc query)
    DELETE FROM ANAPLAN.AD_LAST_PURCH_PRICE WHERE DIVISION <> '800';

    INSERT INTO ANAPLAN.AD_LAST_PURCH_PRICE (
        DIVISION, SUPPLIER, L4_CODE, CURRENCY, PURCHDATE, PRICE_CURR, CHARGE_LOCCURR
    )
    SELECT division, supplier, l4_code, currency, purchdate, price_curr, charge_loccurr
    FROM ANAPLAN.AD_LAST_PURCH_PRICE_CALC;

    -- Oracle: delete from ANAPLAN.AD_LAST_PURCH_PRICE where division in ('800','400');
    --         insert into ANAPLAN.AD_LAST_PURCH_PRICE
    --         select * from ANAPLAN.AD_LAST_PURCH_PRICE@LBM3PRD1_ANAPLAN WHERE DIVISION = '800';
    DELETE FROM ANAPLAN.AD_LAST_PURCH_PRICE WHERE DIVISION IN ('800','400');

    INSERT INTO ANAPLAN.AD_LAST_PURCH_PRICE
    SELECT * FROM LIDSKOE.AD_LAST_PURCH_PRICE WHERE DIVISION = '800';

    -- Oracle: insert into ANAPLAN.AD_LAST_PURCH_PRICE
    --         select * from M3SKY_ANAPLAN.AD_LAST_PURCH_PRICE WHERE DIVISION = '400';
    INSERT INTO ANAPLAN.AD_LAST_PURCH_PRICE
    SELECT * FROM M3SKY.AD_LAST_PURCH_PRICE WHERE DIVISION = '400';
END;
$$;

COMMENT ON PROCEDURE ANAPLAN.REFRESH_AD_LAST_PURCH_PRICE() IS
    'Refreshes ANAPLAN.AD_LAST_PURCH_PRICE from ad_last_purch_price_calc_v via full truncate/reload. Call via CALL ANAPLAN.REFRESH_AD_LAST_PURCH_PRICE();';

-- ---------------------------------------------------------------------------
-- Optional: schedule this procedure via pg_cron (if extension is available).
-- Uses $cron$ as inner dollar-quote delimiter to avoid conflict with DO $$.
-- If pg_cron is not installed, the DO block gracefully skips scheduling.
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    IF to_regnamespace('cron') IS NOT NULL THEN
        PERFORM cron.schedule(
            'refresh_ad_last_purch_price_nightly',
            '0 1 * * *',
            $cron$CALL ANAPLAN.REFRESH_AD_LAST_PURCH_PRICE();$cron$
        );
    ELSE
        RAISE NOTICE 'pg_cron not available — scheduling skipped. Call manually: CALL ANAPLAN.REFRESH_AD_LAST_PURCH_PRICE();';
    END IF;
END;
$$;

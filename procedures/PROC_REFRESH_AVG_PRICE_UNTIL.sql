-- =============================================================================
-- PROCEDURE: ANAPLAN.PROC_REFRESH_AVG_PRICE_UNTIL()
-- =============================================================================
-- Migrated from: Oracle ANAPLAN.PROC_REFRESH_AVG_PRICE_UNTIL
-- Oracle : MERGE INTO ... USING (WITH ... SELECT) sourc ON ...
--          WHEN MATCHED THEN UPDATE SET ... DELETE WHERE TO_DEL='Y'
--          WHEN NOT MATCHED THEN INSERT ...
--          NVL(Run_Leftovers,0)
--          To_Char(To_Date(dt.MOPLDT,'YYYYMMDD')-16,'YYYYMM')
--          Add_Months(Sysdate, 17)
--          nvl(tmp.FACILITY,'Y') -- to_del flag
--          INSERT ... SELECT * FROM AVG_PRICE_UNTIL@LBM3PRD1_ANAPLAN
--          INSERT ... SELECT * FROM M3SKY_ANAPLAN.AVG_PRICE_UNTIL
--          COMMIT
-- PG     : MERGE (PG 15+) with WHEN MATCHED AND to_del THEN DELETE branch
--          COALESCE replaces NVL
--          TO_CHAR(TO_DATE(x,'YYYYMMDD') - 16) replaces Oracle date arithmetic
--          CURRENT_DATE + INTERVAL '17 months' replaces Add_Months(Sysdate,17)
--          (tmp.facility IS NULL) as boolean to_del replaces nvl(tmp.FACILITY,'Y')
--          LIDSKOE.AVG_PRICE_UNTIL replaces @LBM3PRD1_ANAPLAN DB link
--          M3SKY.AVG_PRICE_UNTIL replaces M3SKY_ANAPLAN.AVG_PRICE_UNTIL
--          Autocommit/transaction handled by PG session
-- Confirmed: DELETE semantics verified against Oracle source line 501:
--            WHEN MATCHED THEN UPDATE SET ... DELETE WHERE TO_DEL='Y'
--            Stale rows ARE deleted via the MERGE - not just skipped.
-- =============================================================================

CREATE OR REPLACE PROCEDURE ANAPLAN.PROC_REFRESH_AVG_PRICE_UNTIL()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Starting proc_refresh_avg_price_until at %', NOW();

    MERGE INTO ANAPLAN.AVG_PRICE_UNTIL AS dest
    USING (
        WITH avg_price_until_tmp AS (
            SELECT
                MITFAC.M9FACI                                                        AS facility,
                MITFAC.M9ITNO                                                        AS sku,
                MITMAS.MMFUDS                                                        AS description,
                MITFAC.M9FANO                                                        AS on_hand_balance,
                MITFAC.M9APPR                                                        AS avg_cost,
                dt.MOPLDT                                                            AS avg_cost_until,
                -- Oracle: To_Char(To_Date(dt.MOPLDT,'YYYYMMDD')-16,'YYYYMM')
                TO_CHAR((TO_DATE(dt.MOPLDT::TEXT, 'YYYYMMDD') - 16), 'YYYYMM')      AS avg_until_period,
                ROW_NUMBER() OVER (
                    PARTITION BY MITFAC.M9FACI, MITFAC.M9ITNO
                    ORDER BY dt.MOPLDT ASC, dt.MOTIHM ASC, MORIDN ASC
                )                                                                    AS rn
            FROM MVXJDTA.MITFAC
            INNER JOIN MVXJDTA.MITMAS ON MITFAC.M9ITNO = MITMAS.MMITNO
            LEFT JOIN (
                SELECT MOITNO, MWFACI, MOPLDT, MOTIHM, MORIDN, MOTRQT,
                    SUM(MOTRQT) OVER (
                        PARTITION BY MWFACI, MOITNO
                        ORDER BY MWFACI, MOITNO, MOPLDT ASC, MOORCA DESC, MORIDN ASC, MOTIHM ASC
                    ) AS run_leftovers
                FROM MVXJDTA.MITPLO
                INNER JOIN MVXJDTA.MITMAS ON MMCONO = 100 AND MOITNO = MITMAS.MMITNO
                INNER JOIN MVXJDTA.MITWHL ON MWWHLO = MOWHLO
                WHERE MOCONO = '100'
                  AND MITMAS.MMITTY IN ('20','30','85')
                  AND MOORCA IN ('110','111')
                  AND MWDIVI <> '800' AND MWFACI <> '800'
            ) dt ON dt.MOITNO = MITFAC.M9ITNO AND dt.MWFACI = MITFAC.M9FACI
            WHERE MITFAC.M9FANO > 0
              AND MITMAS.MMITTY IN ('20','30','85')
              -- Oracle: AND MITFAC.M9FANO + nvl(Run_Leftovers,0) <= 0
              AND MITFAC.M9FANO + COALESCE(dt.run_leftovers, 0) <= 0
              AND M9FACI <> '800'
        ),
        avg_price_until2_tmp AS (
            SELECT
                MITFAC.M9FACI                                                        AS facility,
                MITFAC.M9ITNO                                                        AS sku,
                MITMAS.MMFUDS                                                        AS description,
                MITFAC.M9FANO                                                        AS on_hand_balance,
                MITFAC.M9APPR                                                        AS avg_cost,
                dt.MOPLDT                                                            AS avg_cost_until,
                -- Oracle: To_Char(Add_Months(Sysdate, 17), 'YYYYMM')
                TO_CHAR(CURRENT_DATE + INTERVAL '17 months', 'YYYYMM')              AS avg_until_period,
                ROW_NUMBER() OVER (
                    PARTITION BY MITFAC.M9FACI, MITFAC.M9ITNO
                    ORDER BY dt.MOPLDT DESC, dt.MOTIHM DESC, MORIDN DESC
                )                                                                    AS rn
            FROM MVXJDTA.MITFAC
            LEFT JOIN MVXJDTA.MITMAS ON MITFAC.M9ITNO = MITMAS.MMITNO
            LEFT JOIN (
                SELECT MOITNO, MWFACI, MOPLDT, MOTIHM, MORIDN, MOTRQT,
                    SUM(MOTRQT) OVER (
                        PARTITION BY MWFACI, MOITNO
                        ORDER BY MWFACI, MOITNO, MOPLDT ASC, MOORCA DESC, MORIDN ASC, MOTIHM ASC
                    ) AS run_leftovers
                FROM MVXJDTA.MITPLO
                INNER JOIN MVXJDTA.MITMAS ON MMCONO = 100 AND MOITNO = MITMAS.MMITNO
                INNER JOIN MVXJDTA.MITWHL ON MWWHLO = MOWHLO
                WHERE MOCONO = '100'
                  AND MITMAS.MMITTY IN ('20','30','85')
                  AND MOORCA IN ('110','111')
                  AND MWDIVI <> '800' AND MWFACI <> '800'
            ) dt ON dt.MOITNO = MITFAC.M9ITNO AND dt.MWFACI = MITFAC.M9FACI
            WHERE MITFAC.M9FANO > 0
              AND MITMAS.MMITTY IN ('20','30','85')
              AND MITFAC.M9FANO + dt.run_leftovers > 0
              AND M9FACI <> '800'
        ),
        avg_price_until_tmp3 AS (
            SELECT
                MITFAC.M9FACI                                                        AS facility,
                MITFAC.M9ITNO                                                        AS sku,
                MITMAS.MMFUDS                                                        AS description,
                MITFAC.M9FANO                                                        AS on_hand_balance,
                MITFAC.M9APPR                                                        AS avg_cost,
                dt.MOPLDT                                                            AS avg_cost_until,
                TO_CHAR(CURRENT_DATE + INTERVAL '17 months', 'YYYYMM')              AS avg_until_period,
                ROW_NUMBER() OVER (
                    PARTITION BY MITFAC.M9FACI, MITFAC.M9ITNO
                    ORDER BY dt.MOPLDT DESC, dt.MOTIHM DESC, MORIDN DESC
                )                                                                    AS rn
            FROM MVXJDTA.MITFAC
            INNER JOIN MVXJDTA.MITMAS ON MITFAC.M9ITNO = MITMAS.MMITNO
            LEFT JOIN (
                SELECT MOITNO, MWFACI, MOPLDT, MOTIHM, MORIDN, MOTRQT,
                    SUM(MOTRQT) OVER (
                        PARTITION BY MWFACI, MOITNO
                        ORDER BY MWFACI, MOITNO, MOPLDT ASC, MOORCA DESC, MORIDN ASC, MOTIHM ASC
                    ) AS run_leftovers
                FROM MVXJDTA.MITPLO
                INNER JOIN MVXJDTA.MITMAS ON MMCONO = 100 AND MOITNO = MITMAS.MMITNO
                INNER JOIN MVXJDTA.MITWHL ON MWWHLO = MOWHLO
                WHERE MOCONO = '100'
                  AND MITMAS.MMITTY IN ('20','30','85')
                  AND MOORCA IN ('110','111')
                  AND MWDIVI <> '800' AND MWFACI <> '800'
            ) dt ON dt.MOITNO = MITFAC.M9ITNO AND dt.MWFACI = MITFAC.M9FACI
            LEFT JOIN (
                -- Oracle: MVXJDTA.MPDMAT (confirmed correct table name)
                SELECT PMFACI AS facility, PMMTNO AS sku, COUNT(*) AS row_count
                FROM MVXJDTA.MPDMAT
                GROUP BY PMFACI, PMMTNO
            ) mp ON mp.facility = MITFAC.M9FACI AND mp.sku = MITFAC.M9ITNO
            WHERE MITFAC.M9FANO > 0
              AND MITMAS.MMITTY IN ('20','30','85')
              AND dt.MOPLDT IS NULL
              AND M9FACI <> '800'
              AND mp.row_count IS NOT NULL
        ),
        missing_rows_tmp2 AS (
            SELECT avg_price_until2_tmp.*
            FROM avg_price_until2_tmp
            LEFT JOIN avg_price_until_tmp
                   ON avg_price_until2_tmp.facility = avg_price_until_tmp.facility
                  AND avg_price_until2_tmp.sku      = avg_price_until_tmp.sku
            WHERE avg_price_until_tmp.facility IS NULL
        ),
        missing_rows_tmp3 AS (
            SELECT avg_price_until_tmp3.*
            FROM avg_price_until_tmp3
            LEFT JOIN avg_price_until_tmp
                   ON avg_price_until_tmp3.facility = avg_price_until_tmp.facility
                  AND avg_price_until_tmp3.sku      = avg_price_until_tmp.sku
            WHERE avg_price_until_tmp.facility IS NULL
        ),
        avg_price_until_tmp_final AS (
            SELECT facility, sku, description, on_hand_balance, avg_cost, avg_cost_until, avg_until_period
            FROM avg_price_until_tmp
            WHERE rn = 1
            UNION
            SELECT facility, sku, description, on_hand_balance, avg_cost, avg_cost_until, avg_until_period
            FROM missing_rows_tmp3
            WHERE rn = 1
            -- Oracle source: third UNION also uses missing_rows_tmp3 (not tmp2)
            -- This appears to be a copy-paste issue in the original Oracle source.
            -- Preserved exactly as-is to match Oracle behaviour.
            UNION
            SELECT facility, sku, description, on_hand_balance, avg_cost, avg_cost_until, avg_until_period
            FROM missing_rows_tmp3
            WHERE rn = 1
        )
        SELECT
            COALESCE(tmp.facility,       perm.FACILITY)       AS facility,
            COALESCE(tmp.sku,            perm.SKU)            AS sku,
            COALESCE(tmp.description,    perm.DESCRIPTION)    AS description,
            COALESCE(tmp.on_hand_balance,perm.ON_HAND_BALANCE) AS on_hand_balance,
            COALESCE(tmp.avg_cost,       perm.AVG_COST)       AS avg_cost,
            COALESCE(tmp.avg_cost_until, perm.AVG_COST_UNTIL) AS avg_cost_until,
            COALESCE(tmp.avg_until_period,perm.AVG_UNTIL_PERIOD) AS avg_until_period,
            -- Oracle: nvl(tmp.FACILITY,'Y') as TO_DEL
            -- When tmp.facility IS NULL (no match in source) -> row is stale -> delete
            (tmp.facility IS NULL) AS to_del
        FROM avg_price_until_tmp_final tmp
        FULL OUTER JOIN ANAPLAN.AVG_PRICE_UNTIL perm
                     ON tmp.facility = perm.FACILITY AND tmp.sku = perm.SKU
    ) AS sourc
    ON (dest.FACILITY = sourc.facility AND dest.SKU = sourc.sku)
    -- Oracle: WHEN MATCHED THEN UPDATE SET ... DELETE WHERE TO_DEL='Y'
    -- PG     : DELETE is a separate WHEN MATCHED branch, evaluated before UPDATE
    WHEN MATCHED AND sourc.to_del THEN
        DELETE
    WHEN MATCHED THEN
        UPDATE SET
            ON_HAND_BALANCE  = sourc.on_hand_balance,
            AVG_COST         = sourc.avg_cost,
            AVG_COST_UNTIL   = sourc.avg_cost_until,
            AVG_UNTIL_PERIOD = sourc.avg_until_period
    -- Oracle: WHEN NOT MATCHED THEN INSERT (dest.FACILITY,...) VALUES (sourc.FACILITY,...)
    WHEN NOT MATCHED THEN
        INSERT (FACILITY, SKU, DESCRIPTION, ON_HAND_BALANCE, AVG_COST, AVG_COST_UNTIL, AVG_UNTIL_PERIOD)
        VALUES (sourc.facility, sourc.sku, sourc.description, sourc.on_hand_balance,
                sourc.avg_cost, sourc.avg_cost_until, sourc.avg_until_period);

    -- Oracle: commit; insert into anaplan.AVG_PRICE_UNTIL select * from AVG_PRICE_UNTIL@LBM3PRD1_ANAPLAN; commit;
    -- PG    : LIDSKOE schema (compat placeholder, populate via ETL)
    INSERT INTO ANAPLAN.AVG_PRICE_UNTIL
    SELECT * FROM LIDSKOE.AVG_PRICE_UNTIL;

    -- Oracle: insert into anaplan.AVG_PRICE_UNTIL select * from M3SKY_ANAPLAN.AVG_PRICE_UNTIL; commit;
    INSERT INTO ANAPLAN.AVG_PRICE_UNTIL
    SELECT * FROM M3SKY.AVG_PRICE_UNTIL;

    RAISE NOTICE 'proc_refresh_avg_price_until completed at %', NOW();
END;
$$;

COMMENT ON PROCEDURE ANAPLAN.PROC_REFRESH_AVG_PRICE_UNTIL() IS
    'Refreshes avg_price_until via MERGE then appends div 800/400 data. Migrated from Oracle PROC_REFRESH_AVG_PRICE_UNTIL - NVL->COALESCE, Add_Months->INTERVAL, SYSDATE->CURRENT_DATE, @LBM3PRD1->LIDSKOE schema, Oracle MERGE DELETE WHERE->PG WHEN MATCHED AND...THEN DELETE.';

CREATE OR REPLACE VIEW ANAPLAN.TD_PRODUCTION_PLAN AS

WITH

CTE_PRODUCTION_PLAN AS (

    SELECT
        MITFAC.M9FACI AS division,
        SRC.work_center AS workcenter,
        SRC.itemtype,
        SRC.itemcode,
        SRC.period,
        SUM(SRC.motrqt_vol) AS liters

    FROM (

        /* Order category 100 */
        SELECT
            MITPLO.MOCONO AS cono,
            MMOPLP.ROHLO AS whlo,
            MMOPLP.ROWCLN AS work_center,
            MITPLO.MOITNO AS itemcode,
            MITMAS.MMIMTY AS itemtype,
            MITPLO.MOPLDT AS transactiondate,

            TO_CHAR(
                TO_DATE(MITPLO.MOPLDT::TEXT,'YYYYMMDD'),
                'YYYYMM'
            ) AS period,

            (MITPLO.MOTRQT * MITMAS.MMVOL3)::NUMERIC(17,6) AS motrqt_vol

        FROM MVXJDTA.MITPLO
        JOIN MVXJDTA.MMOPLP
          ON MITPLO.MOCONO = MMOPLP.ROCONO
         AND MITPLO.MORIDN::TEXT = MMOPLP.ROPLPN::TEXT
         AND MITPLO.MOITNO = MMOPLP.ROPRNO
        JOIN MVXJDTA.MITMAS
          ON MITPLO.MOCONO = MITMAS.MMCONO
         AND MITPLO.MOITNO = MITMAS.MMITNO

        WHERE MITPLO.MOCONO = 100
          AND MMOPLP.ROFACI <> '800'
          AND MITPLO.MOORCA = '100'
          AND MITMAS.MMITTY IN ('10','40')
          AND MITMAS.MMMABU = 1

        UNION ALL

        /* Order category 101 */

        SELECT
            MITPLO.MOCONO,
            MWOHED.VHWHLO,
            MWOHED.VHWCLN,
            MITPLO.MOITNO,
            MITMAS.MMITTY,
            MITPLO.MOPLDT,

            TO_CHAR(
                TO_DATE(MITPLO.MOPLDT::TEXT,'YYYYMMDD'),
                'YYYYMM'
            ) AS period,

            (MWOHED.VHORQT * MITMAS.MMVOL3)::NUMERIC(17,6)

        FROM MVXJDTA.MITPLO
        JOIN MVXJDTA.MWOHED
          ON MITPLO.MOCONO = MWOHED.VHCONO
         AND MITPLO.MORIDN = MWOHED.VHMFNO
         AND MITPLO.MOITNO = MWOHED.VHPRNO
        JOIN MVXJDTA.MITMAS
          ON MITPLO.MOCONO = MITMAS.MMCONO
         AND MITPLO.MOITNO = MITMAS.MMITNO

        WHERE MITPLO.MOCONO = 100
          AND MWOHED.VHFACI <> '800'
          AND MITPLO.MOORCA = '101'
          AND MITMAS.MMITTY IN ('10','40')
          AND MITMAS.MMMABU = 1

    ) SRC

    JOIN MVXJDTA.MITFAC
      ON SRC.CONO = MITFAC.M9CONO
     AND SRC.WHLO = MITFAC.M9REWH
     AND MITFAC.M9ITNO = SRC.ITEMCODE

    WHERE SRC.TRANSACTIONDATE >
          TO_CHAR(NOW() - INTERVAL '31 days','YYYYMMDD')::INTEGER

    GROUP BY
        MITFAC.M9FACI,
        SRC.work_center,
        SRC.itemtype,
        SRC.itemcode,
        SRC.period
),

CTE_MANUFACTURING AS (

    SELECT
        MITWHL.MWDIVI AS division,
        MWOOPE.VOPLGR AS prod_line,
        MITTRA.MTITNO AS productcode,
        MITTRA.MTTRDT AS manuf_date,

        CASE
            WHEN SUBSTRING(
                     CASE
                       WHEN MITMAS.MMITTY='40'
                       THEN 'SEMI MANUFACTURING'
                       ELSE 'FILLING'
                     END
                 ,1,4) = 'SEMI'
            THEN '40'
            ELSE '10'
        END AS itemtype,

        SUM(MITTRA.MTTRQT * MITMAS.MMVOL3) AS manuf_vol

    FROM MVXJDTA.MITTRA

    LEFT JOIN MVXJDTA.MITMAS
        ON MITTRA.MTCONO = MITMAS.MMCONO
       AND MITTRA.MTITNO = MITMAS.MMITNO

    LEFT JOIN MVXJDTA.MITWHL
        ON MITWHL.MWCONO = MITTRA.MTCONO
       AND MITWHL.MWWHLO = MITTRA.MTWHLO

    LEFT JOIN MVXJDTA.MWOOPE
        ON MITTRA.MTCONO = MWOOPE.VOCONO
       AND MITTRA.MTRIDN = MWOOPE.VOMFNO

    WHERE MITTRA.MTCONO = 100
      AND MITWHL.MWDIVI <> '800'
      AND MITTRA.MTTTID IN ('WOP','WMP')
      AND MITMAS.MMITTY IN ('10','40')
      AND MITTRA.MTTRTP <> '171'
      AND MITTRA.MTWHLO NOT IN ('430','435')

    GROUP BY
        MITWHL.MWDIVI,
        MWOOPE.VOPLGR,
        MITTRA.MTITNO,
        MITTRA.MTTRDT,
        CASE
            WHEN SUBSTRING(
                     CASE
                       WHEN MITMAS.MMITTY='40'
                       THEN 'SEMI MANUFACTURING'
                       ELSE 'FILLING'
                     END
                 ,1,4) = 'SEMI'
            THEN '40'
            ELSE '10'
        END
)

SELECT
    division,
    division || '_' || workcenter AS workcenter,
    itemtype,
    itemcode,
    period,
    'PLAN' AS type,
    liters
FROM CTE_PRODUCTION_PLAN
WHERE workcenter <> ' '
  AND division <> '300'

UNION ALL

SELECT
    division,
    division || '_' || prod_line,
    itemtype,
    productcode,
    SUBSTRING(manuf_date::TEXT,1,6),
    'ACT',
    SUM(manuf_vol)
FROM CTE_MANUFACTURING
WHERE SUBSTRING(manuf_date::TEXT,1,6) >= '202201'
  AND division <> '300'
GROUP BY
    division,
    prod_line,
    itemtype,
    productcode,
    SUBSTRING(manuf_date::TEXT,1,6);

COMMENT ON VIEW ANAPLAN.TD_PRODUCTION_PLAN IS
    'Aggregates planned (MITPLO/MMOPLP) and actual (MITTRA/MITMAS) production volumes in liters by division, workcenter/prod_line, itemtype and item/product code. Uses MVXJDTA sources, excludes division 800 and filters out division 300 in final output; periods formatted as YYYYMM.';    
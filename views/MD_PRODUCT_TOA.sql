CREATE OR REPLACE VIEW ANAPLAN.MD_PRODUCT_TOA AS
WITH
cte_excisegroups AS (
    SELECT dodoid AS excisegroupcode, dodode AS excisegroupname
    FROM MVXJDTA.MPDDOC
    WHERE dodoty = 'VV'
    UNION ALL
    SELECT EXCISEGROUPCODE, EXCISEGROUPNAME
    FROM ref.EXCISE_GROUPS
),
cte_sales_check_item AS (
    SELECT itemcode, SUM(volume) AS salesvolume
    FROM ANAPLAN.TD_SALES_SUM_FULL
    WHERE PERIOD BETWEEN
        TO_CHAR(CURRENT_DATE - INTERVAL '24 months','YYYY') || '01'
        AND TO_CHAR(CURRENT_DATE,'YYYYMM')
    GROUP BY itemcode
),
product_base AS (
    SELECT
        m9faci AS division,
        CAST((mm.mmgrp1 || '.' || sg1.sgtx40) AS VARCHAR(108)) AS l1_productgroup,
        CAST(
            CASE mm.mmgrp2
                WHEN '02' THEN 'PRIVATE LABEL'
                WHEN '03' THEN 'SUBCONTRACTING'
                ELSE CASE WHEN hi1.hitx40 IS NULL THEN 'NA' ELSE hi1.hitx40 END
            END AS VARCHAR(108)
        ) AS l2_brand,
        CAST(COALESCE(pkg.PACKAGETYPE_LABEL, '99.OTHER') AS VARCHAR(108)) AS l3_packagetype,
        CAST(
            CASE WHEN sg5.sgtx40 IS NULL THEN 'NA' ELSE sg5.sgtx40 END
            AS VARCHAR(108)
        ) AS l4_packagesize,
        CAST(
            (CASE WHEN hi3.hitx40 IS NULL THEN sg1.sgtx40 || '-NA' ELSE hi3.hitx40 END)
            || ' / ' || COALESCE(pkg.PACKAGETYPE_WORD, 'OTHER')
            || ' / ' || CASE WHEN sg5.sgtx40 IS NULL THEN 'NA' ELSE sg5.sgtx40 END
            AS VARCHAR(108)
        ) AS l5_uniqueitem,
        CAST((mm.mmitds || ' (' || mm.mmitno || ')') AS VARCHAR(108)) AS l6_sku,
        CAST(mm.mmgrp1 AS VARCHAR(108)) AS l1_code,
        CAST(
            CASE mm.mmgrp2
                WHEN '02' THEN 'PL'
                WHEN '03' THEN 'SUBC'
                ELSE COALESCE(hie1r.REMAP_VALUE, mm.mmhie1)
            END AS VARCHAR(108)
        ) AS l2_code,
        CAST(
            CASE WHEN mm.mmgrp4 = '43' THEN '99'
                 ELSE COALESCE(pkg.CODE_NORMALIZE, mm.mmgrp4)
            END AS VARCHAR(108)
        ) AS l3_code,
        CAST(COALESCE(grp5r.REMAP_VALUE, mm.mmgrp5) AS VARCHAR(108)) AS l4_code,
        CAST(
            (CASE WHEN mm.mmhie3 = ' ' THEN mm.mmgrp1 || '-999999'
                  ELSE COALESCE(hie3r.REMAP_VALUE, mm.mmhie3)
             END)
            || '-' || COALESCE(pkg.CODE_NORMALIZE, mm.mmgrp4)
            || '-' || COALESCE(grp5r.REMAP_VALUE, mm.mmgrp5)
            AS VARCHAR(108)
        ) AS l5_code,
        CAST(mm.mmitno AS VARCHAR(108)) AS l6_code,
        CAST(mm.mmstat AS VARCHAR(108)) AS m3status,
        CAST(mm.mmvol3 AS VARCHAR(108)) AS volume,
        CAST(
            CASE
                WHEN mm.mmunms = 'PC' THEN 1
                WHEN mm.mmgrp4 = '33' AND mm.mmgrp5 = '82' THEN 1
                ELSE mm.mmcfi2
            END AS VARCHAR(108)
        ) AS su_in_unit,
        CAST(
            CASE hi2.hitx40
                WHEN ' ' THEN 'NA'
                WHEN NULL THEN 'NA'
                ELSE hi2.hitx40
            END AS VARCHAR(108)
        ) AS brand2,
        CAST(
            CASE hi3.hitx40
                WHEN ' ' THEN 'NA'
                WHEN NULL THEN 'NA'
                ELSE hi3.hitx40
            END AS VARCHAR(108)
        ) AS brand3,
        CAST(COALESCE(hie2r.REMAP_VALUE, mm.mmhie2) AS VARCHAR(108)) AS brand2_code,
        CAST(
            CASE WHEN mm.mmhie3 = ' ' THEN '999999'
                 ELSE COALESCE(hie3r.REMAP_VALUE, mm.mmhie3)
            END AS VARCHAR(108)
        ) AS brand3_code,
        CAST(
            CASE WHEN tar.qsitno IS NOT NULL THEN tar.qsevtg::TEXT
                 ELSE ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1)::TEXT
            END AS VARCHAR(108)
        ) AS alc_vol_perc,
        CASE WHEN ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) > 0.5 THEN 'ALCO' ELSE 'NONALCO' END AS alco_nonalco,
        CAST(
            CASE
                WHEN mp1.mppopn IS NOT NULL THEN mp1.mppopn
                ELSE CASE WHEN mp1.mppopn IS NULL THEN 'NA' ELSE mp1.mppopn END
            END AS VARCHAR(108)
        ) AS eancode,
        CAST(
            CASE WHEN mp1.mppopn IS NULL THEN 'NA' ELSE mp1.mppopn END
            AS VARCHAR(108)
        ) AS ean_kupacode,
        CAST(
            CASE WHEN grti.mmitno IS NULL THEN mm.mmitno ELSE mm.mmgrti END
            AS VARCHAR(108)
        ) AS budgetitem,
        CAST(
            CASE m9vamt::TEXT
                WHEN '0' THEN '0-zero cost'
                WHEN '1' THEN '1-standard cost'
                WHEN '2' THEN '2-average cost'
                WHEN '3' THEN '3-dynamic cost'
                ELSE '99-other'
            END AS VARCHAR(108)
        ) AS inv_acc_method,
        CAST(
            CASE WHEN mm.mmmabu = '2' THEN 'Purchased' ELSE 'Produced' END
            AS VARCHAR(108)
        ) AS producedpurchased,
        CAST(
            CASE mm.mmpdln
                WHEN '700' THEN CASE WHEN mm.mmcfi4 IS NULL OR mm.mmcfi4 = ' ' THEN '99999' ELSE mm.mmcfi4 END
                WHEN '200' THEN CASE WHEN mm.mmcfi5 IS NULL OR mm.mmcfi5 = ' '
                                       OR mm.mmcfi3 IS NULL OR mm.mmcfi3 = ' '
                                  THEN '99999'
                                  ELSE mm.mmgrp4 || '-' || mm.mmcfi5 || '-' || mm.mmcfi3
                             END
                WHEN '100' THEN CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3 = ' '
                                     OR mm.mmcfi3 = 'eip' THEN '99999'
                                  ELSE mm.mmcfi3
                             END
                WHEN '300' THEN CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3 = ' '
                                     OR mm.mmcfi3 = 'eip' THEN '99999'
                                  ELSE mm.mmcfi3
                             END
                WHEN '400' THEN CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3 = ' '
                                     THEN '99999'
                                  ELSE mm.mmcfi3 || '-' || mm.mmgrp4 || '-' || mm.mmgrp5
                             END
                ELSE CASE WHEN m9faci IN ('600','606','616') THEN
                              CASE WHEN mm.mmcfi5 IS NULL OR mm.mmcfi5 = ' ' THEN '99999'
                                   ELSE sg4.sgtx40 || '-' || cfi5.cttx15 || '-' || sg5.sgtx40
                              END
                          ELSE 'undefined'
                     END
            END AS VARCHAR(108)
        ) AS depofeegroupcode,
        CAST(
            CASE mm.mmpdln
                WHEN '700' THEN CASE WHEN mm.mmcfi4 IS NULL OR mm.mmcfi4 = ' '
                                     THEN 'No deposit fee'
                                     ELSE cfi4.cttx40
                                END
                WHEN '200' THEN CASE WHEN mm.mmcfi5 IS NULL OR mm.mmcfi5 = ' '
                                     OR mm.mmcfi3 IS NULL OR mm.mmcfi3 = ' '
                                THEN 'No deposit fee'
                                ELSE sg4.sgtx40 || '-' || cfi5.cttx15 || '-' || cfi3.cttx40
                                END
                WHEN '100' THEN CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3 = ' '
                                     OR mm.mmcfi3 = 'eip'
                                THEN 'No deposit fee'
                                ELSE cfi3.cttx40
                                END
                WHEN '300' THEN CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3 = ' '
                                     OR mm.mmcfi3 = 'eip'
                                THEN 'No deposit fee'
                                ELSE cfi3.cttx40
                                END
                WHEN '400' THEN CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3 = ' '
                                     THEN 'No deposit fee'
                                ELSE cfi3.cttx40 || '-' || sg4.sgtx40 || '-' || sg5.sgtx40
                                END
                ELSE CASE WHEN m9faci IN ('600','606') THEN
                              CASE WHEN mm.mmcfi5 IS NULL OR mm.mmcfi5 = ' '
                                   THEN 'No deposit fee'
                                   ELSE sg4.sgtx40 || '-' || cfi5.cttx15 || '-' || sg5.sgtx40
                              END
                          ELSE 'undefined'
                     END
            END AS VARCHAR(108)
        ) AS depofeegroupname,
        CAST(
            CASE mm.mmpdln
                WHEN '700' THEN
                    CASE WHEN mm.mmatmo = 'ALUS' THEN 'beer'
                         WHEN mm.mmatmo = 'RDZ' AND ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) <= 6.0 THEN 'ferm_till6'
                         WHEN mm.mmatmo = 'RDZ' AND ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) > 6.0 THEN 'ferm_over6'
                         WHEN mm.mmatmo IN ('WINE','RDZ_STR') THEN 'ferm_over6'
                         WHEN mm.mmatmo = 'P.A.DZ' THEN 'spirit'
                         WHEN mm.mmatmo IN ('STARPP','STARPP_STR','DRINKOT') THEN 'inter'
                         WHEN mm.mmatmo = 'B.A.DZ' THEN 'sugar'
                         WHEN mm.mmatmo = 'WATER' AND mm.mmcfi3 = 'SD' THEN 'sugar'
                         WHEN mm.mmatmo = 'B.A.DZ.C' AND mm.mmcfi3 = 'SDc' THEN 'soft'
                         WHEN mm.mmatmo = 'B.A.DZ.E' AND mm.mmcfi3 = 'SDe' THEN 'soft'
                         ELSE 'no'
                    END
                WHEN '200' THEN
                    CASE WHEN ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) <= 1.3 THEN 'no'
                         WHEN mm.mmgrp1 = '01' THEN 'beer'
                         WHEN mm.mmgrp1 IN ('02','03','04','05')
                              AND mm.mmitgr NOT IN ('2120')
                              AND ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) <= 6.0 THEN 'ferm_till6'
                         WHEN mm.mmgrp1 IN ('02','03','04','05')
                              AND mm.mmitgr NOT IN ('2120')
                              AND ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) > 6.0 THEN 'ferm_over6'
                         WHEN mm.mmitgr IN ('2120') THEN 'spirit'
                         ELSE 'no'
                    END
                WHEN '400' THEN
                    CASE WHEN ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) <= 1.2 THEN 'no'
                         WHEN mm.mmgrp1 = '01' AND ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) > 2.8 THEN 'beer'
                         WHEN mm.mmgrp1 IN ('02','03','04')
                              AND ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) <= 6.0 THEN 'ferm_till6'
                         WHEN mm.mmgrp1 IN ('02','03','04')
                              AND ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) > 6.0 THEN 'ferm_over6'
                         WHEN mm.mmgrp1 = '05' THEN 'spirit'
                         ELSE 'no'
                    END
                WHEN '800' THEN
                    CASE WHEN mm.mmitgr = '8140' AND mm.mmevgr = '1' THEN '800winebased'
                         WHEN mm.mmitgr = '8100' AND mm.mmevgr = '1' THEN '800beerover7'
                         WHEN mm.mmitgr = '8105' AND mm.mmevgr = '1' THEN '800beerto7'
                         WHEN mm.mmitgr = '8115' AND mm.mmevgr = '1' THEN '800cider'
                         WHEN mm.mmitgr = '8150' AND mm.mmevgr = '1' THEN '800energy'
                         WHEN mm.mmevgr IN ('0',' ') THEN 'no'
                         ELSE 'no'
                    END
                ELSE
                    CASE
                        WHEN mm.mmpdln IN ('100','300','310','320') THEN
                            CASE WHEN mm.mmdwno = ' ' THEN 'no' ELSE mm.mmdwno END
                        WHEN mm.mmpdln IN ('600','606','616') OR m9faci IN ('600','606','616') THEN
                            CASE
                                WHEN mm.mmcfi3 = 'SU2' THEN 'soft'
                                WHEN mm.mmcfi3 = 'SU0' THEN 'no'
                                WHEN mm.mmcfi3 IN ('SU1','SU3','SU4','SU5') THEN 'sugar'
                                WHEN ANAPLAN.TO_NUMBER_SPEC(mm.mmcfi1) <= 1.3 OR mm.mmspe4 = ' ' THEN 'no'
                                WHEN SUBSTRING(mm.mmspe4, 1, 3) IN ('110') THEN 'beer'
                                WHEN SUBSTRING(mm.mmspe4, 1, 3) IN ('280','299') THEN 'spirit'
                                WHEN SUBSTRING(mm.mmspe4, 1, 3) IN ('210','215') THEN 'ferm_till_8.5'
                                WHEN SUBSTRING(mm.mmspe4, 1, 3) IN ('230','235') THEN 'ferm_over_8.5'
                                ELSE 'no'
                            END
                        ELSE 'undefined'
                    END
            END AS VARCHAR(108)
        ) AS excisegroupcode,
        CAST(
            CASE WHEN mbsuno IN ('',' ') THEN 'NA'
                 ELSE UPPER(sup.idsunm) || '(' || mbsuno || ')'
            END AS VARCHAR(108)
        ) AS mainsupplier,
        CAST(
            CASE WHEN m9rewh = '200'
                 THEN '203 - LC excise warehouse'
                 ELSE m9rewh || ' - ' || mwwhnm
            END AS VARCHAR(108)
        ) AS mainwarehouse,
        m9wcln || '-' || ppplnm AS mainfillingline,
        CAST(
            CASE WHEN mm.mmprod IN ('',' ')
                 THEN 'NA'
                 ELSE UPPER(sul.idsunm) || '(' || mm.mmprod || ')'
            END AS VARCHAR(108)
        ) AS manufacturer,
        CAST(
            (CASE WHEN mm.mmitrf = ' ' THEN '99' ELSE mm.mmitrf END || ' - ' || 'OTHER')
            AS VARCHAR(108)
        ) AS launchperiod,
        CAST(
            CASE WHEN mbsttx IN (' ','') THEN 'NA' ELSE mbsttx END
            AS VARCHAR(108)
        ) AS endperiod,
        CAST(
            CASE
                WHEN mm.mmpdln = '100' THEN mm.mmitgr || ' - ' || itgr.cttx40
                WHEN mm.mmgrp1 IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14')
                     THEN mm.mmgrp1 || '.' || sg1.sgtx40
                ELSE '99.OTHER - ' || mm.mmgrp1
            END AS VARCHAR(108)
        ) AS localitemgroup,
        CAST((mm.mmitcl || ' - ' || itcl.cttx40) AS VARCHAR(108)) AS localproductgroup,
        CAST((mm.mmitno || ' ' || mm.mmfuds) AS VARCHAR(108)) AS locallongname,
        CAST(
            CASE
                WHEN mm.mmpdln = '200' AND mm.mmgrp4 = '31' AND mm.mmevgr = ' ' THEN 1
                WHEN mm.mmpdln = '400' AND mm.mmcfi3 IN ('4A','4A0') THEN 1
                WHEN mm.mmpdln = '600' AND mm.mmcfi5 = 'N' THEN 1
                WHEN mm.mmpdln = '700' AND mm.mmcfi4 IN ('7BB00','7DK00','7GB00','7ND00','7RD00') THEN 1
                WHEN mm.mmpdln = '100' AND mm.mmcfi3 = 'EIP' THEN 1
                ELSE 0
            END AS VARCHAR(108)
        ) AS attr1,
        CAST(sit.ifsite AS VARCHAR(108)) AS attr2,
        CAST(NULL AS VARCHAR(108)) AS attr3,
        CAST(NULL AS VARCHAR(108)) AS attr4,
        CAST(NULL AS VARCHAR(108)) AS attr5,
        mm.mmitrf AS launch_period,
        mbsttx AS ending_note,
        CASE WHEN mm.mmpdln IN ('100','400') THEN mm.mmgrp3 ELSE mm.mmgrp5 END AS multipack_code,
        CASE WHEN mm.mmpdln IN ('100','400') THEN sg3.sgtx40 ELSE sg5.sgtx40 END AS multipack
    FROM MVXJDTA.MITMAS mm
    LEFT JOIN MVXJDTA.MITMAS grti
        ON grti.mmcono = mm.mmcono
       AND grti.mmitno = mm.mmgrti
    LEFT JOIN cte_sales_check_item sc
        ON mm.mmitno = sc.itemcode
    LEFT JOIN MVXJDTA.MITSCH sg1
        ON sg1.sgcono = mm.mmcono
       AND sg1.sgglvl = 1
       AND sg1.sgsgp0 = mm.mmgrp1
    LEFT JOIN MVXJDTA.MITSCH sg2
        ON sg2.sgcono = mm.mmcono
       AND sg2.sgglvl = 2
       AND sg2.sgsgp0 = mm.mmgrp2
    LEFT JOIN MVXJDTA.MITSCH sg3
        ON sg3.sgcono = mm.mmcono
       AND sg3.sgglvl = 3
       AND sg3.sgsgp0 = mm.mmgrp3
    LEFT JOIN MVXJDTA.MITSCH sg4
        ON sg4.sgcono = mm.mmcono
       AND sg4.sgglvl = 4
       AND sg4.sgsgp0 = mm.mmgrp4
    LEFT JOIN MVXJDTA.MITSCH sg5
        ON sg5.sgcono = mm.mmcono
       AND sg5.sgglvl = 5
       AND sg5.sgsgp0 = mm.mmgrp5
    LEFT JOIN MVXJDTA.MITHRY hi1
        ON hi1.hicono = mm.mmcono
       AND hi1.hihlvl = 1
       AND hi1.hihie0 = mm.mmhie1
    LEFT JOIN MVXJDTA.MITHRY hi2
        ON hi2.hicono = mm.mmcono
       AND hi2.hihlvl = 2
       AND hi2.hihie0 = mm.mmhie2
    LEFT JOIN MVXJDTA.MITHRY hi3
        ON hi3.hicono = mm.mmcono
       AND hi3.hihlvl = 3
       AND hi3.hihie0 = mm.mmhie3
    LEFT JOIN MVXJDTA.CSYTAB cfi3
        ON cfi3.ctcono = mm.mmcono
       AND cfi3.ctstco = 'CFI3'
       AND cfi3.ctstky = mm.mmcfi3
    LEFT JOIN MVXJDTA.CSYTAB cfi4
        ON cfi4.ctcono = mm.mmcono
       AND cfi4.ctstco = 'CFI4'
       AND cfi4.ctstky = mm.mmcfi4
    LEFT JOIN MVXJDTA.CSYTAB cfi5
        ON cfi5.ctcono = mm.mmcono
       AND cfi5.ctstco = 'CFI5'
       AND cfi5.ctstky = mm.mmcfi5
    LEFT JOIN MVXJDTA.CSYTAB itgr
        ON itgr.ctcono = mm.mmcono
       AND itgr.ctstco = 'ITGR'
       AND itgr.ctstky = mm.mmitgr
    LEFT JOIN MVXJDTA.CSYTAB itcl
        ON itcl.ctcono = mm.mmcono
       AND itcl.ctstco = 'ITCL'
       AND itcl.ctstky = mm.mmitcl
    LEFT JOIN MVXJDTA.MITFAC
        ON mm.mmcono = m9cono
       AND mm.mmitno = m9itno
       AND m9faci <> '800'
    LEFT JOIN MVXJDTA.MITBAL
        ON mbcono = mm.mmcono
       AND mbitno = mm.mmitno
       AND mbwhlo = m9rewh
    LEFT JOIN MVXJDTA.MITWHL
        ON mwcono = mbcono
       AND mbwhlo = mwwhlo
    LEFT JOIN MVXJDTA.CIDMAS sup
        ON sup.idcono = mbcono
       AND sup.idsuno = mbsuno
    LEFT JOIN MVXJDTA.CIDMAS sul
        ON sul.idcono = mm.mmcono
       AND sul.idsuno = mm.mmprod
    LEFT JOIN MVXJDTA.MPDWCT pp
        ON mm.mmcono = pp.ppcono
       AND m9faci = ppplgr
       AND m9wcln = ppplgr
    LEFT JOIN (
        SELECT mpcono, mpitno, MAX(mppopn) AS mppopn
        FROM MVXJDTA.MITPOP
        WHERE mpalwt = '2'
        GROUP BY mpcono, mpitno
    ) mp1
        ON mp1.mpcono = mm.mmcono
       AND mp1.mpitno = mm.mmitno
    LEFT JOIN (
        SELECT qsitno, qsevtg
        FROM (
            SELECT ROW_NUMBER() OVER (
                       PARTITION BY qsitno
                       ORDER BY qsitno, qsqte1 DESC
                   ) AS ordr,
                   tmp.*
            FROM MVXJDTA.QMSTST tmp
            WHERE qsqtst = 'C265'
              AND SUBSTRING(qsspec, 9) = 'MAX ALC'
        ) sub
        WHERE ordr = 1
    ) tar
        ON mm.mmitno = tar.qsitno
    LEFT JOIN (
        SELECT DISTINCT ifitno, ifsuno, ifsite
        FROM MVXJDTA.MITVEN
    ) sit
        ON sit.ifitno = mm.mmitno
       AND sit.ifsuno = mbsuno
    LEFT JOIN ref.MD_PRODUCT_PACKAGEGROUP pkg
        ON pkg.MMGRP4 = mm.mmgrp4
    LEFT JOIN ref.MD_PRODUCT_HIE1_REMAP hie1r
        ON hie1r.MMHIE1 = mm.mmhie1
    LEFT JOIN ref.MD_PRODUCT_HIE2_REMAP hie2r
        ON hie2r.MMHIE2 = mm.mmhie2
    LEFT JOIN ref.MD_PRODUCT_HIE3_REMAP hie3r
        ON hie3r.MMHIE3 = mm.mmhie3
    LEFT JOIN ref.MD_PRODUCT_MMGRP5_REMAP grp5r
        ON grp5r.MMGRP5 = mm.mmgrp5
    WHERE mm.mmcono = 100
      AND mm.mmitty IN ('10')
      AND mm.mmstat >= '10'
      AND sg1.sgtx40 IS NOT NULL
      AND (mm.mmstat <= '20' OR sc.itemcode IS NOT NULL)
      AND m9faci <> '800'
      AND m9faci IS NOT NULL
),
md_product_inline AS (
    SELECT
        pr.division,
        pr.l1_productgroup,
        pr.l2_brand,
        pr.l3_packagetype,
        pr.l4_packagesize,
        pr.l5_uniqueitem,
        pr.l6_sku,
        pr.l1_code,
        pr.l2_code,
        pr.l3_code,
        pr.l4_code,
        pr.l5_code,
        pr.l6_code,
        pr.m3status,
        pr.volume,
        pr.su_in_unit,
        pr.brand2,
        pr.brand3,
        pr.brand2_code,
        pr.brand3_code,
        pr.alc_vol_perc,
        pr.alco_nonalco,
        pr.eancode,
        pr.ean_kupacode,
        pr.budgetitem,
        pr.inv_acc_method,
        pr.producedpurchased,
        pr.depofeegroupcode,
        pr.depofeegroupname,
        pr.excisegroupcode,
        CAST(eg.excisegroupname AS VARCHAR(108)) AS excisegroupname,
        pr.mainsupplier,
        pr.mainwarehouse,
        pr.mainfillingline,
        pr.manufacturer,
        pr.launchperiod,
        pr.endperiod,
        pr.localitemgroup,
        pr.localproductgroup,
        pr.locallongname,
        pr.attr1,
        pr.attr2,
        pr.attr3,
        pr.attr4,
        pr.attr5,
        pr.launch_period,
        pr.ending_note,
        pr.multipack_code,
        pr.multipack
    FROM product_base pr
    LEFT JOIN cte_excisegroups eg
        ON pr.excisegroupcode = eg.excisegroupcode

    UNION ALL

    SELECT
        division,
        l1_productgroup,
        l2_brand,
        l3_packagetype,
        l4_packagesize,
        l5_uniqueitem,
        l6_sku,
        l1_code,
        l2_code,
        l3_code,
        l4_code,
        l5_code,
        l6_code,
        m3status,
        volume,
        su_in_unit,
        brand2,
        brand3,
        brand2_code,
        brand3_code,
        alc_vol_perc,
        alco_nonalco,
        eancode,
        ean_kupacode,
        budgetitem,
        inv_acc_method,
        producedpurchased,
        depofeegroupcode,
        depofeegroupname,
        excisegroupcode,
        excisegroupname,
        mainsupplier,
        mainwarehouse,
        mainfillingline,
        manufacturer,
        launchperiod,
        endperiod,
        localitemgroup,
        localproductgroup,
        locallongname,
        attr1,
        attr2,
        attr3,
        attr4,
        attr5,
        launch_period,
        ending_note,
        multipack_code,
        multipack
    FROM LIDSKOE.MD_PRODUCT
    WHERE division = '800'

    UNION ALL

    SELECT
        division,
        l1_productgroup,
        l2_brand,
        l3_packagetype,
        l4_packagesize,
        l5_uniqueitem,
        l6_sku,
        l1_code,
        l2_code,
        l3_code,
        l4_code,
        l5_code,
        l6_code,
        m3status,
        volume,
        su_in_unit,
        brand2,
        brand3,
        brand2_code,
        brand3_code,
        alc_vol_perc,
        alco_nonalco,
        eancode,
        ean_kupacode,
        budgetitem,
        inv_acc_method,
        producedpurchased,
        depofeegroupcode,
        depofeegroupname,
        excisegroupcode,
        excisegroupname,
        mainsupplier,
        mainwarehouse,
        mainfillingline,
        manufacturer,
        launchperiod,
        endperiod,
        localitemgroup,
        localproductgroup,
        locallongname,
        attr1,
        attr2,
        attr3,
        attr4,
        attr5,
        launch_period,
        ending_note,
        multipack_code,
        multipack
    FROM M3SKY.MD_PRODUCT
    WHERE division = '400'
)
SELECT
    'DIVISION;L1_PRODUCTGROUP;L2_BRAND;L3_PACKAGETYPE;L4_PACKAGESIZE;L5_UNIQUEITEM;L6_SKU;'
    || 'L1_CODE;L2_CODE;L3_CODE;L4_CODE;L5_CODE;L6_CODE;'
    || 'M3STATUS;VOLUME;SU_IN_UNIT;BRAND2;BRAND3;BRAND2_CODE;BRAND3_CODE;'
    || 'ALC_VOL_PERC;ALCO_NONALCO;EANCODE;BUDGETITEM;INV_ACC_METHOD;PRODUCEDPURCHASED;'
    || 'DEPOFEEGROUPCODE;DEPOFEEGROUPNAME;EXCISEGROUPCODE;EXCISEGROUPNAME;MAINSUPPLIER;'
    || 'MAINWAREHOUSE;LAUNCHPERIOD;ENDPERIOD;LOCALITEMGROUP;LOCALPRODUCTGROUP;'
    || 'ATTR1;ATTR2;ATTR3;ATTR4;ATTR5' AS listrows,
    1 AS inde

UNION ALL

SELECT
    COALESCE(division,'')       || ';' || COALESCE(l1_productgroup,'') || ';' ||
    COALESCE(l2_brand,'')       || ';' || COALESCE(l3_packagetype,'')  || ';' ||
    COALESCE(l4_packagesize,'') || ';' || COALESCE(l5_uniqueitem,'')   || ';' ||
    COALESCE(l6_sku,'')         || ';' ||
    COALESCE(l1_code,'')        || ';' || COALESCE(l2_code,'') || ';' ||
    COALESCE(l3_code,'')        || ';' || COALESCE(l4_code,'') || ';' ||
    COALESCE(l5_code,'')        || ';' || COALESCE(l6_code,'') || ';' ||
    COALESCE(m3status,'')       || ';' || COALESCE(volume,'')         || ';' ||
    COALESCE(su_in_unit,'')     || ';' || COALESCE(brand2,'')         || ';' ||
    COALESCE(brand3,'')         || ';' || COALESCE(brand2_code,'')    || ';' ||
    COALESCE(brand3_code,'')    || ';' ||
    COALESCE(alc_vol_perc,'')   || ';' || COALESCE(alco_nonalco,'')   || ';' ||
    COALESCE(eancode,'')        || ';' || COALESCE(budgetitem,'')      || ';' ||
    COALESCE(inv_acc_method,'') || ';' || COALESCE(producedpurchased,'') || ';' ||
    COALESCE(depofeegroupcode,'') || ';' || COALESCE(depofeegroupname,'') || ';' ||
    COALESCE(excisegroupcode,'') || ';' || COALESCE(excisegroupname,'') || ';' ||
    COALESCE(mainsupplier,'')   || ';' || COALESCE(mainwarehouse,'')  || ';' ||
    COALESCE(launchperiod,'')   || ';' || COALESCE(endperiod,'')      || ';' ||
    COALESCE(localitemgroup,'') || ';' || COALESCE(localproductgroup,'') || ';' ||
    COALESCE(attr1,'')          || ';' || COALESCE(attr2,'') || ';' ||
    COALESCE(attr3,'')          || ';' || COALESCE(attr4,'') || ';' || COALESCE(attr5,'')
    AS listrows,
    2 AS inde
FROM md_product_inline;

COMMENT ON VIEW ANAPLAN.MD_PRODUCT_TOA IS
    'Serialised product master (semicolon-delimited) for Anaplan TOA load. MD_PRODUCT logic fully inlined (no view-on-view reference) via md_product_inline CTE, duplicated from md_product_v -- keep both copies in sync on any change to product master logic, including ref lookup joins.';

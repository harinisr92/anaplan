CREATE OR REPLACE VIEW ANAPLAN.MD_COGS_MATERIALS AS
WITH material_src AS (
    SELECT
        CAST(m9faci AS VARCHAR(10))  AS division,
        CAST(mat.groupinglevel1      AS VARCHAR(108)) AS l1_itemtype,
        CAST(CASE mat.groupinglevel2
                 WHEN 'null' THEN 'X999 Missing' WHEN ' ' THEN 'X999 Missing'
                 WHEN '  '   THEN 'X999 Missing' ELSE mat.groupinglevel2
             END AS VARCHAR(108)) AS l2_material_group1,
        CAST(CASE WHEN mat.itemtype IN ('10','40') THEN 'P999 Purchased goods'
                  ELSE CASE mat.groupinglevel3
                           WHEN 'null' THEN 'X999 Missing' WHEN ' ' THEN 'X999 Missing'
                           WHEN '  '   THEN 'X999 Missing' ELSE mat.groupinglevel3
                       END
             END AS VARCHAR(108)) AS l3_material_group2,
        CAST((mat.itemname2 || ' (' || mat.itemcode || ')') AS VARCHAR(108)) AS l4_itemname,
        CAST(mat.itemtype AS VARCHAR(108)) AS l1_code,
        CAST(CASE mat.groupinglevel2
                 WHEN 'null' THEN 'X9' WHEN ' ' THEN 'X9' WHEN '  ' THEN 'X9'
                 ELSE SUBSTRING(mat.groupinglevel2, 1, 2)
             END AS VARCHAR(108)) AS l2_code,
        CAST(CASE WHEN mat.itemtype IN ('10','40') THEN 'P999'
                  ELSE CASE mat.groupinglevel3
                           WHEN 'null' THEN 'X999' WHEN ' ' THEN 'X999' WHEN '  ' THEN 'X999'
                           ELSE SUBSTRING(mat.groupinglevel3, 1, 4)
                       END
             END AS VARCHAR(108)) AS l3_code,
        CAST(mat.itemcode AS VARCHAR(108)) AS l4_code,
        CAST(CASE mat.groupinglevel16 WHEN ' ' THEN 'NOT DEFINED' WHEN '' THEN 'NOT DEFINED'
                 ELSE mat.groupinglevel16 END AS VARCHAR(108)) AS supplier,
        CAST(mat.basicunitofmeasure AS VARCHAR(108)) AS basicunitofmeasure,
        CAST(mat.grossweight        AS VARCHAR(108)) AS grossweight,
        CAST(mat.netweight          AS VARCHAR(108)) AS netweight,
        CAST(mat.responsible        AS VARCHAR(108)) AS responsible,
        CAST(mat.itemstatus         AS VARCHAR(108)) AS m3status,
        CAST(prgp.cttx40            AS VARCHAR(108)) AS procurementgroup,
        CAST(CASE mat.procurementgroup WHEN 'null' THEN 'X999' WHEN ' ' THEN 'X999'
                 ELSE mat.procurementgroup END AS VARCHAR(108)) AS procurementgroupcode,
        CAST(m9appr AS NUMERIC) AS m3avgprice,
        CAST(NULL AS VARCHAR(108)) AS attr1,
        CAST(NULL AS VARCHAR(108)) AS attr2,
        CAST(NULL AS VARCHAR(108)) AS attr3,
        CAST(NULL AS VARCHAR(108)) AS attr4,
        CAST(NULL AS VARCHAR(108)) AS attr5,
        CAST(mat.itemcode AS VARCHAR(108)) AS l4_code_old
    FROM bousr.bi_product mat
    INNER JOIN MVXJDTA.MITFAC ON m9cono = 100 AND m9itno = mat.itemcode
    INNER JOIN MVXJDTA.MITMAS ON mmcono = 100 AND mmitno = mat.itemcode
    LEFT JOIN MVXJDTA.CSYTAB prgp
           ON prgp.ctcono = 100
          AND prgp.ctstco = 'PRGP'
          AND prgp.ctstky = mat.procurementgroup
    WHERE (m9vamt::TEXT LIKE '2%'
           OR mmitty = '99')
      AND mat.companycode = 100
      AND LENGTH(mat.itemcode) > 6
      AND mat.itemstatus::TEXT < '90'
      AND m9faci NOT IN ('800','400')
)
SELECT *
FROM material_src

UNION ALL

SELECT DIVISION, L1_ITEMTYPE, L2_MATERIAL_GROUP1, L3_MATERIAL_GROUP2, L4_ITEMNAME,
       L1_CODE, L2_CODE, L3_CODE, L4_CODE, SUPPLIER, BASICUNITOFMEASURE,
       GROSSWEIGHT, NETWEIGHT, RESPONSIBLE, M3STATUS, PROCUREMENTGROUP,
       PROCUREMENTGROUPCODE, M3AVGPRICE, ATTR1, ATTR2, ATTR3, ATTR4, ATTR5,
       L4_CODE AS l4_code_old
FROM LIDSKOE.MD_COGS_MATERIALS
WHERE DIVISION = '800'

UNION ALL

SELECT DIVISION, L1_ITEMTYPE, L2_MATERIAL_GROUP1, L3_MATERIAL_GROUP2, L4_ITEMNAME,
       L1_CODE, L2_CODE, L3_CODE, L4_CODE, SUPPLIER, BASICUNITOFMEASURE,
       GROSSWEIGHT, NETWEIGHT, RESPONSIBLE, M3STATUS, PROCUREMENTGROUP,
       PROCUREMENTGROUPCODE, M3AVGPRICE, ATTR1, ATTR2, ATTR3, ATTR4, ATTR5, L4_CODE_OLD
FROM M3SKY.MD_COGS_MATERIALS
WHERE DIVISION = '400';

COMMENT ON VIEW ANAPLAN.MD_COGS_MATERIALS IS
    'Material master for COGS analysis. DECODE → CASE; SubStr 0-based → 1-based; type casts for smallint comparisons; DB link replaced by compat table.';
--MD_ACCOUNT

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_ACCOUNT" ("ACCOUNT", "ACCOUNT_NAME", "L1_NAME", "L2_NAME", "L3_NAME", "L4_NAME", "L5_NAME", "L1_CODE", "L2_CODE", "L3_CODE", "L4_CODE", "L5_CODE", "A1_USED", "A2_CONSOLIDATION", "A3_ATTR3", "A3_ATTR4", "A3_ATTR5") AS 
  SELECT 

CAST((ac) AS VARCHAR(10)) AS account,
CAST((ac_name) AS VARCHAR(108)) AS account_name,

CAST((SubStr(f5,3)) AS VARCHAR(108)) AS L1_name,
CAST((SubStr(f4,4)) AS VARCHAR(108)) AS L2_name,
CAST((SubStr(f3,5)) AS VARCHAR(108)) AS L3_name,
CAST((SubStr(f2,6)) AS VARCHAR(108)) AS L4_name,
CAST((SubStr(f1,8)) AS VARCHAR(108)) AS L5_name,

CAST((SubStr(f5,0,1)) AS VARCHAR(10)) AS L1_code,
CAST((SubStr(f4,0,2)) AS VARCHAR(10)) AS L2_code,
CAST((SubStr(f3,0,3)) AS VARCHAR(10)) AS L3_code,
CAST((SubStr(f2,0,4)) AS VARCHAR(10)) AS L4_code,
CAST((SubStr(f1,0,6)) AS VARCHAR(10)) AS L5_code,

CAST((in_use) AS VARCHAR(10)) AS A1_USED,
CAST((consolidation) AS VARCHAR(108)) AS A2_CONSOLIDATION,
CAST((' ') AS VARCHAR(108)) AS A3_ATTR3,
CAST((' ') AS VARCHAR(108)) AS A3_ATTR4,
CAST((' ') AS VARCHAR(108)) AS A3_ATTR5
 FROM bousr.fpm_account_structure
WHERE ac<'9999999'
ORDER BY ac;


  GRANT SELECT ON "ANAPLAN"."MD_ACCOUNT" TO "LOTMAT";
  GRANT SELECT ON "ANAPLAN"."MD_ACCOUNT" TO "BOUSR";



--MD_ACCOUNT_CLOUD

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_ACCOUNT_CLOUD" ("ACCOUNT", "ACCOUNT_NAME", "L1_NAME", "L2_NAME", "L3_NAME", "L4_NAME", "L5_NAME", "L1_CODE", "L2_CODE", "L3_CODE", "L4_CODE", "L5_CODE", "A1_USED", "A2_CONSOLIDATION", "A3_ATTR3", "A3_ATTR4", "A3_ATTR5") AS 
  SELECT 

CAST((ac) AS VARCHAR(10)) AS account,
CAST((ac_name) AS VARCHAR(108)) AS account_name,

CAST((SubStr(f5,3)) AS VARCHAR(108)) AS L1_name,
CAST((SubStr(f4,4)) AS VARCHAR(108)) AS L2_name,
CAST((SubStr(f3,5)) AS VARCHAR(108)) AS L3_name,
CAST((SubStr(f2,6)) AS VARCHAR(108)) AS L4_name,
CAST((SubStr(f1,8)) AS VARCHAR(108)) AS L5_name,

CAST((SubStr(f5,0,1)) AS VARCHAR(10)) AS L1_code,
CAST((SubStr(f4,0,2)) AS VARCHAR(10)) AS L2_code,
CAST((SubStr(f3,0,3)) AS VARCHAR(10)) AS L3_code,
CAST((SubStr(f2,0,4)) AS VARCHAR(10)) AS L4_code,
CAST((SubStr(f1,0,6)) AS VARCHAR(10)) AS L5_code,

CAST((in_use) AS VARCHAR(10)) AS A1_USED,
CAST((consolidation) AS VARCHAR(108)) AS A2_CONSOLIDATION,
CAST((' ') AS VARCHAR(108)) AS A3_ATTR3,
CAST((' ') AS VARCHAR(108)) AS A3_ATTR4,
CAST((' ') AS VARCHAR(108)) AS A3_ATTR5
 FROM m3sky.fpm_account_structure
WHERE ac<'9999999'
ORDER BY ac;


--MD_COGS_MATERIALS

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_COGS_MATERIALS" ("DIVISION", "L1_ITEMTYPE", "L2_MATERIAL_GROUP1", "L3_MATERIAL_GROUP2", "L4_ITEMNAME", "L1_CODE", "L2_CODE", "L3_CODE", "L4_CODE", "SUPPLIER", "BASICUNITOFMEASURE", "GROSSWEIGHT", "NETWEIGHT", "RESPONSIBLE", "M3STATUS", "PROCUREMENTGROUP", "PROCUREMENTGROUPCODE", "M3AVGPRICE", "ATTR1", "ATTR2", "ATTR3", "ATTR4", "ATTR5", "L4_CODE_OLD") AS 
  SELECT 
CAST((M9FACI) AS VARCHAR(10)) AS division,
CAST((mat.groupinglevel1) AS VARCHAR(108)) AS L1_itemtype,
CAST(Decode(mat.groupinglevel2,'null','X999 Missing',' ','X999 Missing','  ','X999 Missing',mat.groupinglevel2) AS VARCHAR(108)) AS L2_material_group1,
CAST((CASE
          WHEN mat.itemtype IN ('10','40') THEN 'P999 Purchased goods'
          ELSE Decode(mat.groupinglevel3,'null','X999 Missing',' ','X999 Missing','  ','X999 Missing',mat.groupinglevel3)
     END) AS VARCHAR(108)) AS L3_material_group2,
CAST((mat.itemname2||' ('||mat.itemcode||')') AS VARCHAR(108)) AS L4_itemname,
CAST((mat.itemtype) AS VARCHAR(108)) AS L1_code,
CAST((Decode(mat.groupinglevel2,'null','X9',' ','X9','  ','X9',SubStr(mat.groupinglevel2,0,2))) AS VARCHAR(108)) AS L2_code,
CAST((CASE
          WHEN mat.itemtype IN ('10','40') THEN 'P999'
          ELSE Decode(mat.groupinglevel3,'null','X999',' ','X999','  ','X999',SubStr(mat.groupinglevel3,0,4))
     END) AS VARCHAR(108)) AS L3_code,
CAST((mat.itemcode) AS VARCHAR(108)) AS L4_code,
CAST((Decode(mat.groupinglevel16,' ','NOT DEFINED','','NOT DEFINED',mat.groupinglevel16)) AS VARCHAR(108)) AS supplier,
CAST((mat.basicunitofmeasure) AS VARCHAR(108)) AS basicunitofmeasure,
CAST((mat.grossweight) AS VARCHAR(108)) AS grossweight,
CAST((mat.netweight) AS VARCHAR(108)) AS netweight,
CAST((mat.responsible) AS VARCHAR(108)) AS responsible,
CAST((mat.itemstatus) AS VARCHAR(108)) AS m3status,
CAST((prgp.cttx40) AS VARCHAR(108)) AS procurementgroup,
CAST((Decode(mat.procurementgroup,'null','X999',' ','X999',mat.procurementgroup)) AS VARCHAR(108)) AS procurementgroupcode,
CAST((M9APPR) AS NUMBER) AS M3avgprice,
--CAST((c.kocsu1) AS NUMBER) AS M3avgprice,
CAST((null) AS VARCHAR(108)) AS attr1,
CAST((null) AS VARCHAR(108)) AS attr2,
CAST((null) AS VARCHAR(108)) AS attr3,
CAST((null) AS VARCHAR(108)) AS attr4,
CAST((null) AS VARCHAR(108)) AS attr5,
CAST((mat.itemcode) AS VARCHAR(108)) AS L4_code_OLD
FROM bousr.bi_product mat 
 inner join mvxjdta.mitfac ON m9cono=100 AND m9itno=mat.itemcode
 inner join mvxjdta.mitmas ON mmcono=100 AND mmitno=mat.itemcode
left join mvxjdta.csytab prgp ON prgp.ctcono=100 AND prgp.ctstco='PRGP' AND prgp.ctstky=mat.procurementgroup
/*left join 
    (select d.kofaci,d.koitno,max(d.kocsu1) as kocsu1 from mvxjdta.mchead d
         inner join  (select kofaci,koitno,max(kopcdt) maxdt  from mvxjdta.mchead  where kopctp='3' group by kofaci,koitno) a
        on a.kofaci=d.kofaci and a.koitno=d.koitno and a.maxdt=d.kopcdt
        group by d.kofaci,d.koitno
    ) c
    on c.kofaci=m9faci and c.koitno=mat.itemcode*/
WHERE  (m9vamt LIKE '2%' or mmitty='99') AND mat.companycode=100 AND Length(mat.itemcode)>6 AND mat.itemstatus<90 and division not in ('800','400')
UNION ALL
SELECT "DIVISION","L1_ITEMTYPE","L2_MATERIAL_GROUP1","L3_MATERIAL_GROUP2","L4_ITEMNAME","L1_CODE","L2_CODE","L3_CODE","L4_CODE","SUPPLIER","BASICUNITOFMEASURE","GROSSWEIGHT","NETWEIGHT","RESPONSIBLE","M3STATUS","PROCUREMENTGROUP","PROCUREMENTGROUPCODE","M3AVGPRICE","ATTR1","ATTR2","ATTR3","ATTR4","ATTR5","L4_CODE" as L4_CODE_OLD FROM ANAPLAN.MD_COGS_MATERIALS@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "DIVISION","L1_ITEMTYPE","L2_MATERIAL_GROUP1","L3_MATERIAL_GROUP2","L4_ITEMNAME","L1_CODE","L2_CODE","L3_CODE","L4_CODE","SUPPLIER","BASICUNITOFMEASURE","GROSSWEIGHT","NETWEIGHT","RESPONSIBLE","M3STATUS","PROCUREMENTGROUP","PROCUREMENTGROUPCODE","M3AVGPRICE","ATTR1","ATTR2","ATTR3","ATTR4","ATTR5","L4_CODE_OLD" FROM M3SKY_ANAPLAN.MD_COGS_MATERIALS WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."MD_COGS_MATERIALS" TO "LOTMAT";


--MD_COSTCENTER

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_COSTCENTER" ("L1_DIVISION", "L2_COSTCENTER", "L2_CODE", "A1_FUNCTION", "A1_CODE", "A2_SUBFUNCTION", "A2_CODE", "A3_ATTR", "A3_CODE", "A4_ATTR", "A4_CODE") AS 
  SELECT 
CAST((divi) AS VARCHAR(10)) AS L1_division,
CAST((cc_name) AS VARCHAR(108)) AS L2_costcenter,
CAST((cc) AS VARCHAR(108)) AS L2_code,
CAST((SubStr(f2_shortname,4)) AS VARCHAR(108)) AS A1_FUNCTION,
CAST((SubStr(f2_shortname,0,3)) AS VARCHAR(10)) AS A1_CODE,
CAST((f1_name) AS VARCHAR(108)) AS A2_SUBFUNCTION,
CAST((f1) AS VARCHAR(10)) AS A2_CODE,
CAST((in_use) AS VARCHAR(108)) AS A3_ATTR,
CAST((' ') AS VARCHAR(10)) AS A3_CODE,
CAST((' ') AS VARCHAR(108)) AS A4_ATTR,
CAST((' ') AS VARCHAR(10)) AS A4_CODE
 
FROM bousr.fpm_costcenter_structure
WHERE divi||'-'||cc NOT LIKE '200-9%' AND divi||'-'||cc NOT LIKE '700-9%' and divi||'-'||cc NOT LIKE '707-9%'  AND yea4=To_Char(SYSDATE,'YYYY') and
      divi not in ('800','400')
union all
select "L1_DIVISION","L2_COSTCENTER","L2_CODE","A1_FUNCTION","A1_CODE","A2_SUBFUNCTION","A2_CODE","A3_ATTR","A3_CODE","A4_ATTR","A4_CODE" from anaplan.MD_COSTCENTER@LBM3PRD1_ANAPLAN where L1_division = '800'
union all
select "L1_DIVISION","L2_COSTCENTER","L2_CODE","A1_FUNCTION","A1_CODE","A2_SUBFUNCTION","A2_CODE","A3_ATTR","A3_CODE","A4_ATTR","A4_CODE" from m3sky_anaplan.MD_COSTCENTER where L1_division = '400';


  GRANT SELECT ON "ANAPLAN"."MD_COSTCENTER" TO "LOTMAT";


--MD_CUSTOMER

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_CUSTOMER" ("DIVISION", "L1_REGION", "L2_SALESCHANNEL", "L3_CUSTOMERGROUP", "L4_CHAIN", "L5_CUSTOMER", "L6_EXCISE_DEPO", "L3_CODE", "L4_CODE", "L5_CODE", "CUSTOMERCODE", "EXCISE", "DEPOFEE", "PRICELIST_REF", "BONUSGROUP_REF", "DELIVERYGROUP", "SHOP_COUNT", "ATTR1", "ATTR2", "ATTR3", "ATTR4", "ATTR5", "LOCAL_REGION", "SALESPERSON", "BUDGET_CUSTOMERCODE") AS 
  SELECT division, l1_region,l2_saleschannel, /*case WHEN cd.division IN ('100','300') and cd.L1_REGION='GROUP' THEN /*CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE local_region||' '||ea1.cttx40 else l3_customergroup END as*/ l3_customergroup,
/*case WHEN cd.division IN ('100','300') and cd.L1_REGION='GROUP' THEN /*CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 else l4_chain END */l4_chain, 
/*case WHEN cd.division IN ('100','300') and cd.L1_REGION='GROUP' THEN /*CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 else l5_customer END */l5_customer,
l6_excise_depo,
division||'-'||l2_saleschannel||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l3_code /*END*/ AS l3_code,
division||'-'||l2_saleschannel||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l3_code/* END*/||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l4_code /*END*/ AS l4_code,
division||'-'||l2_saleschannel||'-'||division||'-'||l2_saleschannel||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l3_code/* END*/||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l4_code/* END*/||CASE WHEN l5_code=l4_code THEN '' ELSE '-'||l5_code END AS l5_code,
division||'-'||l2_saleschannel||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l3_code/* END*/||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l4_code/* END*/||CASE WHEN l5_code=l4_code THEN '' ELSE '-'||l5_code END||'-'||l6_code AS customercode,
excise, depofee,
cd.pricelist_ref AS pricelist_ref, 
bonusgroup_ref, min(deliverygroup_code||'-'||deliverygroup) AS deliverygroup,
count(shop) AS shop_count, 
CAST((NULL) AS VARCHAR(108)) AS ATTR1,
CAST((NULL) AS VARCHAR(108)) AS ATTR2,
CAST((NULL) AS VARCHAR(108)) AS ATTR3,
CAST((NULL) AS VARCHAR(108)) AS ATTR4,
CAST((NULL) AS VARCHAR(108)) AS ATTR5,
cd.LOCAL_REGION,
cd.SALESPERSON,
cd.BUDGET_CUSTOMERCODE as budget_customercode

FROM anaplan.MD_CUSTOMER_DETAIL cd
 left join anaplan.AD_SALES_CHECK_CUSTOMER sc ON sc.customercode=division||'-'||l2_saleschannel||'-'||l3_code||'-'||l4_code||CASE WHEN l5_code=l4_code THEN '' ELSE '-'||l5_code END||'-'||l6_code
  left join mvxjdta.OCUSMA cu ON cu.OKCONO=100 and cd.M3customercode=cu.okcuno
  left join mvxjdta.CSYTAB ea1 ON cu.OKCONO=ea1.CTCONO AND EA1.CTSTKY=Trim(cu.OKACRF) AND ea1.ctstco='ACRF' and ea1.ctdivi=' '
  left join (SELECT eaaitm FROM mvxjdta.fchacc WHERE eacono=100 AND eadivi='100' AND eaaitp='2' AND earesp='PLANNING') opla ON cu.okacrf=opla.eaaitm
WHERE  (cd.m3status<='20' OR sc.customercode IS NOT NULL) and division not in ('800','400') -- AND cd.M3customercode in ('9900002','10001000')
GROUP BY division, l1_region,l2_saleschannel,
/*case WHEN cd.division IN ('100','300') and cd.L1_REGION='GROUP' THEN /*CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE local_region||' '||ea1.cttx40 else l3_customergroup END as*/ l3_customergroup,
/*case WHEN cd.division IN ('100','300') and cd.L1_REGION='GROUP' THEN /*CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 else l4_chain END */l4_chain, 
/*case WHEN cd.division IN ('100','300') and cd.L1_REGION='GROUP' THEN /*CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 else l5_customer END */l5_customer,
l6_excise_depo, 
division||'-'||l2_saleschannel||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l3_code/* END*/,
division||'-'||l2_saleschannel||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l3_code/* END*/||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l4_code /*END*/ ,
division||'-'||l2_saleschannel||'-'||division||'-'||l2_saleschannel||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l3_code/* END*/||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l4_code/* END*/||CASE WHEN l5_code=l4_code THEN '' ELSE '-'||l5_code END ,
division||'-'||l2_saleschannel||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l3_code/* END*/||'-'||/*CASE WHEN cd.division IN ('100','300') AND cd.L1_REGION='GROUP' THEN cu.okacrf ELSE */l4_code/* END*/||CASE WHEN l5_code=l4_code THEN '' ELSE '-'||l5_code END||'-'||l6_code,
l3_code,l4_code,l5_code, l6_code,excise, depofee,pricelist_ref, bonusgroup_ref,cd.LOCAL_REGION,cd.SALESPERSON,cd.BUDGET_CUSTOMERCODE
union all
select "DIVISION","L1_REGION","L2_SALESCHANNEL","L3_CUSTOMERGROUP","L4_CHAIN","L5_CUSTOMER","L6_EXCISE_DEPO","L3_CODE","L4_CODE","L5_CODE","CUSTOMERCODE","EXCISE","DEPOFEE","PRICELIST_REF","BONUSGROUP_REF","DELIVERYGROUP","SHOP_COUNT","ATTR1","ATTR2","ATTR3","ATTR4","ATTR5","LOCAL_REGION","SALESPERSON","BUDGET_CUSTOMERCODE" from anaplan.md_customer@LBM3PRD1_ANAPLAN where division = '800'
UNION ALL
select "DIVISION","L1_REGION","L2_SALESCHANNEL","L3_CUSTOMERGROUP","L4_CHAIN","L5_CUSTOMER","L6_EXCISE_DEPO","L3_CODE","L4_CODE","L5_CODE","CUSTOMERCODE","EXCISE","DEPOFEE","PRICELIST_REF","BONUSGROUP_REF","DELIVERYGROUP","SHOP_COUNT","ATTR1","ATTR2","ATTR3","ATTR4","ATTR5","LOCAL_REGION","SALESPERSON","BUDGET_CUSTOMERCODE" from m3sky_anaplan.md_customer where division = '400';


  GRANT SELECT ON "ANAPLAN"."MD_CUSTOMER" TO "BOUSR" WITH GRANT OPTION;
  GRANT SELECT ON "ANAPLAN"."MD_CUSTOMER" TO "LOTMAT";


--MD_CUSTOMER_DETAIL

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_CUSTOMER_DETAIL" ("DIVISION", "L1_REGION", "L2_SALESCHANNEL", "L3_CUSTOMERGROUP", "L4_CHAIN", "L5_CUSTOMER", "L6_EXCISE_DEPO", "L3_CODE", "L4_CODE", "L5_CODE", "L6_CODE", "EXC_TMP", "DEP_TMP", "SHOP", "CHARGEMODEL", "M3CUSTOMERCODE", "M3STATUS", "EXCISE", "DEPOFEE", "PRICELIST_REF", "BONUSGROUP_REF", "DISCOUNTGROUP_REF", "DELIVERYGROUP", "DELIVERYGROUP_CODE", "LOCAL_REGION", "SALESPERSON", "BUDGET_CUSTOMERCODE") AS 
  SELECT
--VERSION2: BASED on LOCAL EXCEPTIONS
CAST((cs.divi) AS VARCHAR(108)) AS Division,

CAST((CASE
WHEN cu.OKCFC3 in ('RET','HOR','HRC') THEN 'DOMESTIC'                                                                  --OLVI Horeca
WHEN cu.OKCFC3='EXP' THEN 'EXPORT'                                                                             --OLVI EXPORT Costcenters (OKACRF)  
WHEN cu.OKCFC3='GRP' THEN 'GROUP'                                                                              --OLVI GROUP
WHEN cu.OKCFC3='TRA' THEN 'TRAVELTRADE'                                                                        --OLVI TREAVELTRADE
WHEN cu.OKCUCL IN ('905','907') THEN 'EXPORT'
WHEN cu.OKCUCL IN ('900','901','903') THEN 'TRAVELTRADE'
WHEN cu.OKACRF BETWEEN '4410' AND '4449' THEN 'EXPORT'
WHEN cu.OKACRF='L9000' THEN 'GROUP'
WHEN cu.OKCUCL IN ('910','176','177','178','179','180') THEN 'GROUP'
ELSE  'DOMESTIC'
END) AS VARCHAR(108)) AS L1_Region,

CAST((CASE
WHEN cu.okrasn='800' AND cu.okcfc6='8HORE?A' THEN 'HORECA'
WHEN cu.okrasn='800' AND cu.okcfc6 IN ('8RKA','8RKA1','8RKA2','8OTHERS','8TR','8DISTRIBUT','8E-TRADE','8OPS','8OPT','8???') THEN 'RETAIL'
when cu.oksdst='217' THEN 'RETAIL'
WHEN cu.OKCFC3 in ('HOR','HRC') THEN 'HORECA'                                                                  --OLVI Horeca
WHEN cu.OKCFC3='EXP' THEN 'EXPORT'                                                                             --OLVI EXPORT Costcenters (OKACRF)  
WHEN cu.OKCFC3='GRP' THEN 'GROUP'                                                                              --OLVI GROUP
WHEN cu.OKCFC3='TRA' THEN 'TRAVELTRADE'                                                                        --OLVI TREAVELTRADE
WHEN cu.okrasn!='700' AND cu.OKCFC3='RET' THEN 'RETAIL'                                                                         --OLVI RETAIL
WHEN cu.OKACRF IN ('4720','4721','4722','4723','4724','4725','4726','4730','4740','4745','4750','4755','4756','4760','4761','4762',
'4818','4846','4847','4844','42032','42039','42041','42042','42043','42044','42045','42046','42047','42048','42049') THEN 'HORECA'               --OLVI Horeca
WHEN cu.OKACRF BETWEEN '4410' AND '4449' THEN 'EXPORT'                                                                                           --OLVI EXPORT Costcenters (OKACRF)  
WHEN cu.OKACRF in ('4460') THEN 'EXPORT'                                                                                                          --OLVI EXPORT Costcenters (OKACRF)  
WHEN cu.OKACRF IN ('4451','4457','4459','4839','2501') THEN 'GROUP'                                                                              --OLVI GROUP
WHEN cu.OKCUCL IN ('182','154','155','156','250','255','211','212','213','214','215','216','217',',218','219','230','259','459') THEN 'RETAIL'   --RETAIL Customer Group's (OKCUCL)
WHEN cu.OKACRF='L9000' THEN 'GROUP'                                                                                                              --GROUP "Costcenter" LIDA (OKACRF)
WHEN cu.OKCUCL BETWEEN '400' AND '408' THEN 'RETAIL'                                                                                             --RETAIL Customer Group's (OKCUCL)
--WHEN cu.okpyno IN ('20009048','20011837') THEN 'RETAIL'                                                                                        --KAUPMEES, SANITEX in RETAIL for ALC
WHEN cu.OKCUCL IN ('220','606','720','420','419') THEN 'HORECA'                                                                                  --HORECA Customer Group's (OKCUCL)
--WHEN cu.OKCUCL in ('130','140','171') AND cu.OKCFC3='SK' THEN 'HORECA'                                                                         --HORECA special OLVI
WHEN cu.OKCUCL BETWEEN '891' AND '896' THEN 'HORECA'                                                                                             --HORECA Customer Group's (OKCUCL)
WHEN cu.OKCUCL IN ('900','903','901','183') THEN 'TRAVELTRADE'                                                                                   --TRAVELTRADE Customer Group's (OKCUCL)
WHEN cu.OKCUCL IN ('905','907') THEN 'EXPORT'                                                                                                    --EXPORT Customer Group's (OKCUCL)
WHEN cu.OKCUCL IN ('910','176','177','178','179','180') THEN 'GROUP'                                                                             --GROUP Customer Group's (OKCUCL)
WHEN cu.OKCFC1 NOT IN ('7006','7010','7011','7012','7013','7014','7015','7018','7019') THEN 'RETAIL'                                             --RETAIL, excluding number of CESU chains (OKCFC1)
ELSE 'WHOLESALES'                                                                                                                                --WHOLESALE - the rest of customers
END) AS VARCHAR(108)) AS L2_SalesChannel,
CAST((CASE
WHEN cu.okrasn='800' THEN CASE WHEN cu.okcfc6=' ' THEN 'NA' ELSE fr2.cttx40 end --THEN CASE WHEN cu.okfre1=' ' THEN 'NA' ELSE fr1.cttx40 END         --local ROP for LIDA (okkcfc3, previously okfre1)
WHEN cs.divi IN ('100','300') THEN CASE WHEN opla.eaaitm IS null THEN '9999 OTHER' ELSE opla.eaaitm||' '||ea1.cttx40 END    --COSTCENTER for OLVI SERVAALI
WHEN (cs.divi not in ('400','100') or cu.okrasn not in ('400','100')) and cu.okcucl BETWEEN '905' AND '909' THEN cu2.oksmcd||' '||ct4.CTTX40  --SALESPERSON for EXPORT
WHEN cu.OKACRF='L9000' OR cu.okcucl='910' THEN (Upper(py.okcunm||' ('||py.okcuno||')') )                                    --PAYER for GROUP counterpart
WHEN cu.OKRASN='200' THEN CT1.CTTX15
--WHEN cu.OKCFC1 IN ('IG','ELVI','SKY','STOCKMANN','LIDL') AND cu.OKRASN='700' and cu.okpyno not in ('77007597','77007719','77127636','77100935','77009067','77127391','77006879','77011771','77114838','77002387','77004760') THEN 'VIP - GLEBS' --Cesu YB2023 extra
WHEN cu.okcucl=' ' THEN 'OTHER' 
ELSE ct1.CTTX40                                                             --CUSTOMER GROUP (OKCUCL) for the rest
END) AS VARCHAR(108)) AS L3_CustomerGroup,
CAST((CASE
WHEN  cu.okcucl='910' OR cu.OKACRF='L9000'  THEN (Upper(py.okcunm||' ('||py.okcuno||')') )                                  --PAYER for GROUP counterpart
WHEN  cu.okcucl BETWEEN '905' AND '909'  THEN ct9.cttx15                                                                    --COUNTRY for EXPORT
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 END    --COSTCENTER for OLVI SERVAALI
WHEN CU.okrasn='200' THEN ct11.CTTX40
WHEN cu.okrasn IN ('200','600') AND cu.OKCFC8!=' ' THEN ct10.cttx40                                                         --CHAIN GROUP for ALC, VOLFAS
WHEN cu.okrasn='700'AND  cu.OKCFC9!=' ' THEN Upper(ct7.cttx40)                                                              --Cesu new chain group 16.09.2025 M-S Kadai
WHEN cu.OKCFC1 IN (' ') THEN 'NO CHAIN'                                                                                     --if CHAIN is BLANK - then "NO CHAIN"
                        ELSE ct8.cttx40                                                                                     --else CHAIN (OKCFC1)
END) AS VARCHAR(108)) AS l4_chain,
CAST((CASE
WHEN  cu.okcucl BETWEEN '905' AND '910' OR cu.OKACRF='L9000' THEN 
  CASE WHEN py.okcunm IS NULL THEN Upper(cu.okcunm||' ('||cu.okcuno||')') else  Upper(py.okcunm||' ('||py.okcuno||')') END  --PAYER for EXPORT and GROUP (if PAYER=' ' then CUSTOMER)
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 END    --COSTCENTER for OLVI SERVAALI
WHEN cu.okrasn IN ('200','600') AND cu.OKCFC8!=' ' THEN ct10.cttx40                                                         --CHAIN GROUP for ALC, VOLFAS.
WHEN cu.okrasn='700'AND  cu.OKCFC9!=' ' THEN Upper(ct7.cttx40)                                                              --Cesu new chain group 16.09.2025 M-S Kadai
WHEN cu.OKCFC1 IN (' ') THEN 'NO CHAIN'                                                                                     --if CHAIN is BLANK - then "NO CHAIN"
                        ELSE ct8.cttx40                                                                                     --else CHAIN (OKCFC1)
END) AS VARCHAR(108)) AS L5_Customer,

CAST((  CASE WHEN cm.excise IS NULL THEN 'no excise' ELSE Decode(cm.excise,'YES','excise','NO','no excise') END
      ||'-'||
        CASE WHEN cm.depofee IS NULL THEN 'no deposit' ELSE Decode(cm.depofee,'YES','deposit','NO','no deposit') END)
AS VARCHAR(108)) AS L6_excise_depo,

CAST((CASE
WHEN cu.okrasn='800' THEN cu.okcfc6                                            --Local ROP for LIDA
WHEN cs.divi IN ('100','300') THEN CASE WHEN opla.eaaitm IS null THEN '9999' ELSE cu.okacrf END      --COSTCENTER for OLVI SERVAALI
WHEN (cs.divi not in ('400','100') or cu.okrasn not in ('400','100')) and cu.okcucl BETWEEN '905' AND '909' THEN  cu2.OKSMCD  --SALESPERSON for EXPORT
WHEN cu.OKACRF='L9000' OR cu.okcucl='910' THEN py.okcuno
WHEN cu.OKRASN='200' THEN cu.OKCUCL
--WHEN cu.OKCFC1 IN ('IG','ELVI','SKY','STOCKMANN','LIDL') AND cu.OKRASN='700' and cu.okpyno not in ('77007597','77007719','77127636','77100935','77009067','77127391','77006879','77011771','77114838','77002387','77004760') THEN '751' --Cesu YB2023 extra--PAYER for GROUP counterpart
WHEN cu.okcucl=' ' THEN '999' ELSE cu.OKCUCL                                                                --CUSTOMER GROUP (OKCUCL) for the rest
END) AS VARCHAR(108)) AS L3_CODE,

CAST((CASE
WHEN  cu.okcucl='910' OR cu.OKACRF='L9000'  THEN py.okcuno                                                                  --PAYER for GROUP counterpart
WHEN  cu.okcucl BETWEEN '905' AND '909'   THEN cu.OKCSCD                                                                    --COUNTRY for EXPORT and GROUP
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN '9999' ELSE cu.okacrf END      --COSTCENTER for OLVI SERVAALI
WHEN cu.OKRASN='200' THEN cu.OKSDST
WHEN cu.okrasn IN ('200','600') AND cu.OKCFC8!=' ' THEN  Upper(cu.OKCFC8)                                                   --CHAIN GROUP for ALC, VOLFAS
WHEN cu.okrasn='700'  AND cu.OKCFC9!=' ' THEN cu.okcfc9                                                                     --Cesu new chain group 16.09.2025 M-S Kadai
WHEN cu.OKCFC1 IN (' ') THEN '999'                                                                                          --if CHAIN is BLANK - then "NO CHAIN"
                        ELSE Upper(cu.OKCFC1)                                                                               --else CHAIN (OKCFC1)
END) AS VARCHAR(108)) AS L4_CODE,

CAST((CASE
WHEN  cu.okcucl BETWEEN '905' AND '910' OR cu.OKACRF='L9000'  THEN 
  CASE WHEN py.okcuno IS NULL THEN cu.okcuno ELSE py.okcuno END                                                             --PAYER for EXPORT and GROUP (if PAYER=' ' then CUSTOMER)
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN '9999' ELSE cu.okacrf END      --COSTCENTER for OLVI SERVAALI
WHEN cu.okrasn IN ('200','600') AND cu.OKCFC8!=' ' THEN  Upper(cu.OKCFC8)                                                   --CHAIN GROUP for ALC, VOLFAS
WHEN cu.okrasn='700'  AND cu.OKCFC9!=' ' THEN cu.okcfc9                                                                     --Cesu new chain group 16.09.2025 M-S Kadai
WHEN cu.OKCFC1 IN (' ') THEN '999'                                                                                          --if CHAIN is BLANK - then "NO CHAIN"
                        ELSE Upper(cu.OKCFC1)                                                                               --else CHAIN (OKCFC1)
END) AS VARCHAR(108)) AS L5_CODE,


CAST(( CASE
WHEN cm.excise IS NULL THEN '0' ELSE Decode(cm.excise,'YES','1','NO','0') END ||'-'|| CASE WHEN cm.depofee IS NULL THEN '0' ELSE Decode(cm.depofee,'YES','1','NO','0') END)
AS VARCHAR(108)) AS L6_code,
cm.excise AS exc_tmp, cm.depofee AS dep_tmp,
cast((cu.okcunm||' ('||cu.okcuno||')') as VARCHAR(108)) as SHOP,
cast((cu.OKCHSY) AS VARCHAR(108)) AS chargemodel,
cast((cu.okcuno) as VARCHAR(108)) as M3CUSTOMERCODE,
cast((cu.okstat) as VARCHAR(108)) AS M3status,
CAST((
CASE 
WHEN cs.divi='200' AND cu.okcucl LIKE '2%' THEN 'YES'/*ALC WISH FOR ALL DOMESTIC EXCISE*/
WHEN cs.divi='700' AND cu.okcucl LIKE '7%' THEN 'YES'/*CESU WISH FOR ALL DOMESTIC EXCISE*/
WHEN cs.divi='700' and cu.okcucl BETWEEN '900' and '903' THEN 'YES'
WHEN cs.divi='800' AND cu.okcucl LIKE '8%' THEN 'YES'/*LIDA WISH FOR ALL DOMESTIC EXCISE*/ 
WHEN cm.excise IS NULL THEN 'NO' 
ELSE cm.excise  END) AS VARCHAR(3)) AS     excise,
CAST((
CASE 
WHEN cs.divi='200' and cu.OKCUCL='910' THEN 'NO'
WHEN cs.divi='700' AND cu.okcucl LIKE '7%' THEN 'YES' /*CESU WISH FOR ALL DOMESTIC depofee*/ 
WHEN cs.divi='700' and cu.okcucl BETWEEN '900' and '903' THEN 'YES'
WHEN cs.divi='600' AND  cu.OKCUCL='910' AND cu.okpyno not in ('9900616','9900009') THEN 'NO'/*CASE FOR VOLFAS DEPO FEE CHARGE TO INCLUDE FACILITY EXCEPTION*/ 
WHEN cm.depofee IS NULL THEN 'NO' 
ELSE cm.depofee END) AS VARCHAR(3)) AS     depofee,
CAST(
(CASE
      WHEN cu.okrasn='200' AND cu.OKCUCL IN ('900','901','903') THEN 'TT-2A0'
      WHEN cu.okrasn='200' AND cu.OKCUCL<'900' THEN 'DOM-2A0'
      WHEN cu.okrasn='600' AND cu.OKCUCL<'900' THEN '6R1'
      WHEN cu.okrasn='700' AND cu.OKCUCL IN ('900','901','903') THEN 'TT-7C1'
      WHEN cu.okrasn='700' AND cu.OKCUCL<'900' THEN 'DOM-7C1'
      WHEN cu.okrasn='400' AND cu.OKCUCL='400' THEN '404'
      WHEN cu.okrasn='400' AND cu.OKCUCL='401' THEN '405'
      WHEN cu.okrasn='400' AND cu.OKCUCL='402' THEN '415'
      WHEN cu.okrasn='400' AND cu.OKCUCL='403' THEN '412'
      WHEN cu.okrasn='400' AND cu.OKCUCL='404' THEN '414'
      WHEN cu.okrasn='400' AND cu.OKCUCL='405' THEN '410'
      WHEN cu.okrasn='400' AND cu.OKCUCL='406' THEN '418'
      WHEN cu.okrasn='400' AND cu.OKCUCL='407' THEN '413'
      WHEN cu.okrasn='400' AND cu.OKCUCL='408' THEN '446'
      WHEN cu.okrasn='400' AND cu.OKCUCL='409' THEN '432'
      WHEN cu.okrasn='400' AND cu.OKCUCL='419' THEN '426'
      WHEN cu.okrasn='400' AND cu.OKCUCL='420' THEN '438'
      WHEN cu.okrasn='400' AND cu.OKCUCL='430' THEN '434'
      WHEN cu.okrasn='400' AND cu.OKCUCL='459' THEN '454'
      WHEN cu.okrasn='400' AND cu.OKCUCL='903' THEN '416'
      WHEN cu.okrasn='400' AND cu.OKCUCL='907' THEN '449'
      ELSE 'NA' END
) AS VARCHAR(108)) AS pricelist_ref,
CAST(('NA') AS VARCHAR(108)) AS bonusgroup_ref,
CAST(('NA') AS VARCHAR(108)) AS discountgroup_ref,
CAST((CASE WHEN cu.OKMODL='03' OR cu.OKMODL=' ' THEN 'NA' ELSE MODL.cttx15 END) AS VARCHAR(108)) AS deliverygroup,
CAST((CASE WHEN cu.OKMODL='03' OR cu.OKMODL=' ' THEN '999' ELSE cu.OKMODL END) AS VARCHAR(108)) AS deliverygroup_code,
case when cs.divi in ('100','300') then cu.okacrf WHEN cs.divi='800' THEN cu.okcfc6 else cu.okcucl end as LOCAL_REGION,
CASE WHEN cs.divi in ('200','700','600') and cu.okcucl BETWEEN '905' AND '909' THEN cu2.OKSMCD ELSE ' ' END as SALESPERSON,
case when cs.divi!='200' and bud.customercode is null then cu.OKCUNO WHEN cs.divi='200' and alc.customercode is null THEN cu.OKCUNO when cs.divi='200' and alc.customercode is not null then alc.customercode ELSE bud.customercode END as BUDGET_CUSTOMERCODE
FROM (SELECT DISTINCT divi, cuno FROM (SELECT okdivi AS divi, okcuno AS cuno FROM mvxjdta.ccudiv UNION ALL SELECT okrasn AS divi,okcuno AS cuno FROM mvxjdta.ocusma) WHERE divi!=' ' ORDER BY cuno, divi ) cs     -- customer selection table, includes local exceptions!
 left join mvxjdta.OCUSMA cu ON cs.cuno=cu.okcuno
 left join mvxjdta.ccudiv cu2 ON cu2.okcuno=cs.cuno AND cs.divi=cu2.okdivi                                           --for each local exception own sales agent (exp) 02.10.2025 MSK
 left join mvxjdta.OCUSMA py ON cu.OKCONO=py.OKCONO AND py.OKCUNO=cu.OKPYNO
 left join mvxjdta.CSYTAB ct1 ON cu.OKCONO=ct1.CTCONO AND ct1.CTSTCO='CUCL' AND ct1.CTSTKY=cu.OKCUCL AND ct1.ctdivi=' '
 left join mvxjdta.CSYTAB ct2 ON cu.OKCONO=ct2.CTCONO AND ct2.CTSTCO='ECAR' AND ct2.CTSTKY=cu.OKECAR AND ct2.ctdivi=' '
 left join mvxjdta.CSYTAB ct3 ON cu.OKCONO=ct3.CTCONO AND ct3.CTSTCO='SDST' AND ct3.CTSTKY=cu.OKSDST AND ct3.ctdivi=' '
 left join mvxjdta.CSYTAB ct4 ON cu.OKCONO=ct4.CTCONO AND ct4.CTSTCO='SMCD' AND ct4.CTSTKY=cu2.OKSMCD AND ct4.ctdivi=' '
 left join mvxjdta.CSYTAB ct5 ON cu.OKCONO=ct5.CTCONO AND ct5.CTSTCO='CDRC' AND ct5.CTSTKY=cu.OKCDRC AND ct5.ctdivi=' '
 left join mvxjdta.CSYTAB ct6 ON cu.OKCONO=ct6.CTCONO AND ct6.CTSTCO='CFC6' AND ct6.CTSTKY=cu.OKCFC6 AND ct6.ctdivi=' '
 left join mvxjdta.CSYTAB ct7 ON cu.OKCONO=ct7.CTCONO AND ct7.CTSTCO='CFC9' AND ct7.CTSTKY=cu.OKCFC9 AND ct7.ctdivi=' '
 left join mvxjdta.CSYTAB ct8 ON cu.OKCONO=ct8.CTCONO AND ct8.CTSTCO='CFC1' AND ct8.CTSTKY=cu.OKCFC1 AND ct8.ctdivi=' '
 left join mvxjdta.CSYTAB ct9 ON cu.OKCONO=ct9.CTCONO AND ct9.CTSTCO='CSCD' AND ct9.CTSTKY=cu.OKCSCD AND ct9.ctdivi=' '
 left join mvxjdta.CSYTAB ct10 ON cu.OKCONO=ct10.CTCONO AND ct10.CTSTCO='CFC8' AND ct10.CTSTKY=cu.OKCFC8 AND ct10.ctdivi=' '
 left join mvxjdta.CSYTAB ct11 ON cu.OKCONO=ct11.CTCONO AND ct11.CTSTCO='SDST' AND ct11.CTSTKY=cu.OKSDST AND ct10.ctdivi=' '
 left join mvxjdta.CSYTAB ea1 ON cu.OKCONO=ea1.CTCONO AND EA1.CTSTKY=Trim(cu.OKACRF) AND ea1.ctstco='ACRF' and ea1.ctdivi=' '
 left join mvxjdta.csytab fr1 ON cu.okcono=fr1.ctcono AND fr1.ctstco='FRE1' AND fr1.ctstky=cu.okfre1
 left join mvxjdta.csytab fr2 ON cu.okcono=fr2.ctcono AND fr2.ctstco='CFC6' AND fr2.ctstky=cu.okcfc6
 left join anaplan.AD_CHARGEMODEL cm ON cu.OKCHSY=cm.chargemodel
 left join mvxjdta.csytab MODL on MODL.ctcono=cu.okcono AND MODL.ctstco='MODL' AND MODL.ctlncd=cu.oklhcd AND MODL.ctstky!='03' AND cu.okmodl=MODL.ctstky
 left join (SELECT eaaitm FROM mvxjdta.fchacc WHERE eacono=100 AND eadivi in('100','300') AND eaaitp='2' AND earesp='PLANNING') opla ON cu.okacrf=opla.eaaitm
 left join anaplan.MD_BUDGET_CUSTOMER bud on cs.divi=division and local_region=case when cs.divi in ('100','300') then cu.okacrf else cu.okcucl end
 left join anaplan.MD_BUDGET_CUSTOMER_200 alc ON cs.divi=alc.division AND alc.local_region=cu.okcucl AND alc.district=cu.oksdst
 WHERE cu.OKCONO=100 AND cu.okcutp NOT in ('8','9') 
--  and cu.okrasn||'-'||cu.okcutp not in '100-2' JTA 10.2.2024
   AND cu.okcuno not in ('80105956','80107549','80153425')
    AND cu.okrasn != '800' and cs.DIVI!='800' 
--ORDER BY division, m3customercode

union
select "DIVISION", "L1_REGION", "L2_SALESCHANNEL", "L3_CUSTOMERGROUP", "L4_CHAIN", "L5_CUSTOMER", "L6_EXCISE_DEPO", "L3_CODE", "L4_CODE", "L5_CODE", "L6_CODE", "EXC_TMP", "DEP_TMP", "SHOP", "CHARGEMODEL", "M3CUSTOMERCODE", "M3STATUS", "EXCISE", "DEPOFEE", "PRICELIST_REF", "BONUSGROUP_REF", "DISCOUNTGROUP_REF", "DELIVERYGROUP", "DELIVERYGROUP_CODE", "LOCAL_REGION", "SALESPERSON", "BUDGET_CUSTOMERCODE"
from MD_CUSTOMER_DETAIL@LBM3PRD1_ANAPLAN
--where DIVISION='800';


  GRANT SELECT ON "ANAPLAN"."MD_CUSTOMER_DETAIL" TO "LOTMAT";


--MD_DELIVERYDATE

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_DELIVERYDATE" ("DIVISION", "DELIVERYDATE", "DELIVERYDATESTATUS") AS 
  SELECT CDDIVI AS DIVISION, CDYMD8 AS DELIVERYDATE, 
case when cddivi in ('100','300') then CDDDAY else CDBDAY END AS DELIVERYDATESTATUS
FROM MVXJDTA.CSYCAL
WHERE CDCONO = 100 AND CDDIVI <> ' ' AND CDDIVI NOT IN ('400','800') AND
      CDYMD8 BETWEEN TO_NUMBER(TO_CHAR(SYSDATE-365,'YYYYMMDD')) AND TO_NUMBER(TO_CHAR(SYSDATE+730,'YYYYMMDD'))
UNION ALL
SELECT "DIVISION","DELIVERYDATE","DELIVERYDATESTATUS" FROM ANAPLAN.MD_DELIVERYDATE@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "DIVISION","DELIVERYDATE","DELIVERYDATESTATUS" FROM M3SKY_ANAPLAN.MD_DELIVERYDATE WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."MD_DELIVERYDATE" TO PUBLIC;
  GRANT SELECT ON "ANAPLAN"."MD_DELIVERYDATE" TO "LOTMAT";


--MD_DELIVERYGROUPS

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_DELIVERYGROUPS" ("DELIVERYGROUP", "WEIGHT") AS 
  select 
distinct
ctstky as DELIVERYGROUP,
CASE
     WHEN To_Number(To_Char(REPLACE(SubStr(ctparm,37,6),' ')))>0 then To_Number(To_Char(REPLACE(SubStr(ctparm,37,6),' ')))
     ELSE 0
END as WEIGHT
from mvxjdta.csytab where ctcono=100 and ctstco='MODL' and ctstky between '100' and '900'

union all 
select 
'999-NA' as DELIVERYGROUP,
1 as WEIGHT
from dual;


  GRANT SELECT ON "ANAPLAN"."MD_DELIVERYGROUPS" TO "LOTMAT";


--MD_PRICELIST


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_PRICELIST" ("DIVISION", "CUSTOMER1", "CUSTOMER2", "CUSTOMER3", "PRICELIST_REF", "ITEMCODE", "PRICE", "STARTDATE", "ENDDATE") AS 
  SELECT 
CAST((division) AS VARCHAR(10)) AS division,
CAST(('L1') AS VARCHAR(108)) AS customer1,
CAST(('L2') AS VARCHAR(108)) AS customer2,
CAST(('L3') AS VARCHAR(108)) AS customer3,

CAST((CASE
    WHEN pricelist_code='2A0' AND pricelist_region='DOMESTIC'     THEN 'DOM-2A0'
    WHEN pricelist_code='2A0' AND pricelist_region='TRAVELTRADE'  THEN 'TT-2A0'
    when pricelist_code='7C1' and pricelist_region='DOMESTIC'     then 'DOM-7C1'
    when pricelist_code='7C1' and pricelist_region='TRAVELTRADE'  then 'TT-7C1'                                                             
                                                            ELSE pricelist_code
END) AS VARCHAR(108)) AS pricelist_ref,
CAST((itemcode) AS VARCHAR(108)) AS itemcode,
price,
20230101 as startdate,
20350629 as enddate
FROM bousr.bi_pricelist_v where division <> '800'
--WHERE pricelist_code IN ('2A0','6R1','7C1')

UNION ALL 

SELECT 
CAST((division) AS VARCHAR(10)) AS division,
CAST(('L1') AS VARCHAR(108)) AS customer1,
CAST(('L2') AS VARCHAR(108)) AS customer2,
CAST(DECODE(division,'100',customer3,'300',customer3,'L3') AS VARCHAR(108)) AS customer3,
CAST((pricelist_ref) AS VARCHAR(108)) AS pricelist_ref,
CAST((itemcode) AS VARCHAR(108)) AS itemcode,
price,
startdate,
enddate
FROM anaplan.AD_PRICELIST_CUSTOMER where division not in ('800','400')

UNION ALL

SELECT "DIVISION","CUSTOMER1","CUSTOMER2","CUSTOMER3","PRICELIST_REF","ITEMCODE","PRICE", 20230101 as startdate, 20300629 as enddate FROM ANAPLAN.MD_PRICELIST@LBM3PRD1_ANAPLAN
WHERE DIVISION = '800'

UNION ALL

SELECT "DIVISION","CUSTOMER1","CUSTOMER2","CUSTOMER3","PRICELIST_REF","ITEMCODE","PRICE", 20230101 as startdate, 20300629 as enddate FROM M3SKY_ANAPLAN.MD_PRICELIST
WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."MD_PRICELIST" TO "LOTMAT";



--MD_PRICELIST_NEW


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_PRICELIST_NEW" ("DIVISION", "CUSTOMER1", "CUSTOMER2", "CUSTOMER3", "PRICELIST_REF", "ITEMCODE", "PRICE", "STARTDATE", "ENDDATE") AS 
  SELECT 
CAST((division) AS VARCHAR(10)) AS division,
CAST(('L1') AS VARCHAR(108)) AS customer1,
CAST(('L2') AS VARCHAR(108)) AS customer2,
CAST(('L3') AS VARCHAR(108)) AS customer3,

CAST((CASE
    WHEN pricelist_code='2A0' AND pricelist_region='DOMESTIC'     THEN 'DOM-2A0'
    WHEN pricelist_code='2A0' AND pricelist_region='TRAVELTRADE'  THEN 'TT-2A0'
    when pricelist_code='7C1' and pricelist_region='DOMESTIC'     then 'DOM-7C1'
    when pricelist_code='7C1' and pricelist_region='TRAVELTRADE'  then 'TT-7C1'                                                             
                                                            ELSE pricelist_code
END) AS VARCHAR(108)) AS pricelist_ref,
CAST((itemcode) AS VARCHAR(108)) AS itemcode,
price,
20230101 as startdate,
20350629 as enddate
FROM bousr.bi_pricelist_v where division <> '800'
--WHERE pricelist_code IN ('2A0','6R1','7C1')

UNION ALL 

SELECT 
CAST((division) AS VARCHAR(10)) AS division,
CAST(('L1') AS VARCHAR(108)) AS customer1,
CAST(('L2') AS VARCHAR(108)) AS customer2,
CAST(DECODE(division,'100',customer3,'300',customer3,'L3') AS VARCHAR(108)) AS customer3,
CAST((pricelist_ref) AS VARCHAR(108)) AS pricelist_ref,
CAST((itemcode) AS VARCHAR(108)) AS itemcode,
price,
startdate,
enddate
FROM anaplan.AD_PRICELIST_CUSTOMER_NEW where division <> '800'

UNION ALL

SELECT "DIVISION","CUSTOMER1","CUSTOMER2","CUSTOMER3","PRICELIST_REF","ITEMCODE","PRICE", 20230101 as startdate, 20300629 as enddate FROM ANAPLAN.MD_PRICELIST@LBM3PRD1_ANAPLAN
WHERE DIVISION = '800';


  GRANT SELECT ON "ANAPLAN"."MD_PRICELIST_NEW" TO "LOTMAT";


--MD_PRODUCT


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_PRODUCT" ("DIVISION", "L1_PRODUCTGROUP", "L2_BRAND", "L3_PACKAGETYPE", "L4_PACKAGESIZE", "L5_UNIQUEITEM", "L6_SKU", "L1_CODE", "L2_CODE", "L3_CODE", "L4_CODE", "L5_CODE", "L6_CODE", "M3STATUS", "VOLUME", "SU_IN_UNIT", "BRAND2", "BRAND3", "BRAND2_CODE", "BRAND3_CODE", "ALC_VOL_PERC", "ALCO_NONALCO", "EANCODE", "EAN_KUPACODE", "BUDGETITEM", "INV_ACC_METHOD", "PRODUCEDPURCHASED", "DEPOFEEGROUPCODE", "DEPOFEEGROUPNAME", "EXCISEGROUPCODE", "EXCISEGROUPNAME", "MAINSUPPLIER", "MAINWAREHOUSE", "MAINFILLINGLINE", "MANUFACTURER", "LAUNCHPERIOD", "ENDPERIOD", "LOCALITEMGROUP", "LOCALPRODUCTGROUP", "LOCALLONGNAME", "ATTR1", "ATTR2", "ATTR3", "ATTR4", "ATTR5", "LAUNCH_PERIOD", "ENDING_NOTE", "MULTIPACK_CODE", "MULTIPACK") AS 
  SELECT pr."DIVISION",pr."L1_PRODUCTGROUP",pr."L2_BRAND",pr."L3_PACKAGETYPE",pr."L4_PACKAGESIZE",pr."L5_UNIQUEITEM",pr."L6_SKU",
pr."L1_CODE",pr."L2_CODE",pr."L3_CODE",pr."L4_CODE",pr."L5_CODE",pr."L6_CODE",
pr."M3STATUS",pr."VOLUME",pr."SU_IN_UNIT",pr."BRAND2",pr."BRAND3",pr."BRAND2_CODE",pr."BRAND3_CODE",
pr."ALC_VOL_PERC",pr."ALCO_NONALCO",pr."EANCODE",pr."EAN_KUPACODE",pr."BUDGETITEM",pr."INV_ACC_METHOD",pr."PRODUCEDPURCHASED",
pr."DEPOFEEGROUPCODE",pr."DEPOFEEGROUPNAME",pr."EXCISEGROUPCODE", CAST((ex.excisegroupname) AS VARCHAR(108)) AS excisegroupname,
pr."MAINSUPPLIER",pr."MAINWAREHOUSE",pr."MAINFILLINGLINE",PR."MANUFACTURER",pr."LAUNCHPERIOD",pr."ENDPERIOD",pr."LOCALITEMGROUP",pr."LOCALPRODUCTGROUP",pr."LOCALLONGNAME",
pr."ATTR1" --multi use bottles
,pr."ATTR2" --supplier item code
,pr."ATTR3",pr."ATTR4",pr."ATTR5",pr."LAUNCH_PERIOD",pr."ENDING_NOTE", pr."MULTIPACK_CODE", pr."MULTIPACK"

 FROM
(
SELECT
 m9faci AS Division,

 CAST((mm.MMGRP1||'.'||sg1.SGTX40) AS VARCHAR(108))  AS L1_ProductGroup,   --product group

 CAST((CASE
 WHEN mm.MMGRP2='02' THEN 'PRIVATE LABEL'
 WHEN mm.MMGRP2='03' THEN 'SUBCONTRACTING'
 WHEN HI1.HITX40 IS NULL THEN 'NA'
 ELSE HI1.HITX40 END) AS VARCHAR(108))  AS L2_Brand,              --brand1 (or PL)

 CAST((CASE
 WHEN mm.MMGRP4 in ('31','36') THEN '1.GLASS'
 WHEN mm.MMGRP4 in ('32','37') THEN '3.PET'
 WHEN mm.MMGRP4 in ('33') THEN '2.CAN'
 WHEN mm.MMGRP4 in ('34') THEN '4.KEG'
 WHEN mm.MMGRP4 in ('35') THEN '5.TETRA'
 WHEN mm.MMGRP4 in ('38') THEN '6.FOOD'
 WHEN mm.MMGRP4 in ('41') THEN '7.PET-KEG'
 WHEN mm.MMGRP4 = '40' THEN '8.BARREL'
 WHEN mm.MMGRP4 = '39' THEN '9.TANK'
 WHEN mm.MMGRP4 = '42' THEN '91.BIB'
 ELSE '99.OTHER' END) AS VARCHAR(108)) AS L3_PackageType,          --package type

   CAST ((case /* WHEN mm.mmpdln='200' THEN To_CHAR(mm.MMVOL3/decode(mm.MMCFI2,0,1,mm.MMCFI2),'0.999')*/ WHEN SG5.SGTX40 IS NULL THEN 'NA' ELSE SG5.SGTX40 END) AS VARCHAR (108))   AS  L4_PackageSize,            --package size
          
 CAST(
 (CASE WHEN HI3.HITX40 IS NULL THEN SG1.SGTX40||'-NA' ELSE HI3.HITX40 END||' / '||
 (CASE
 WHEN mm.MMGRP4 in ('31','36') THEN 'GLASS'
 WHEN mm.MMGRP4 in ('32','37') THEN 'PET'
 WHEN mm.MMGRP4 in ('33') THEN 'CAN'
 WHEN mm.MMGRP4 in ('34') THEN 'KEG'
 WHEN mm.MMGRP4 in ('35') THEN 'TETRA'
 WHEN mm.MMGRP4 in ('38') THEN 'FOOD'
 WHEN mm.MMGRP4 in ('41') THEN 'PET-KEG'
 WHEN mm.MMGRP4 = '40' THEN 'BARREL'
 WHEN mm.MMGRP4 = '39' THEN 'TANK'
 WHEN mm.MMGRP4 = '42' THEN 'BIB'
 ELSE 'OTHER' END)||' / '||
 CASE WHEN SG5.SGTX40 IS NULL THEN 'NA' ELSE SG5.SGTX40 END
 ) AS VARCHAR(108))  AS  L5_UniqueItem,            --unique item

 CAST((mm.MMITDS||' ('||mm.MMITNO||')') AS VARCHAR(108))  AS  L6_SKU,                                     --item/SKU

 CAST((mm.MMGRP1) AS VARCHAR(108))  AS  L1_code,
 CAST((CASE
        WHEN mm.MMGRP2='02' THEN 'PL'
        WHEN mm.MMGRP2='03' THEN 'SUBC'
        ELSE  Decode(mm.MMHIE1,'784','106','742','256','783','650','720','806',' ','999',mm.MMHIE1)
       END) AS VARCHAR(108))  AS L2_code,                                                                               --brand1 (or PL)
 CAST((Decode(mm.MMGRP4,'36','31','37','32',' ','99','43','99',mm.MMGRP4)) AS VARCHAR(108)) AS L3_code,                                                                                   --package type
 CAST((Decode(mm.MMGRP5,'85','47','54','35','33','999',' ','999',mm.MMGRP5) ) AS VARCHAR(108))  AS  L4_code,                                --package size
 CAST((Decode(mm.MMHIE3,'720001','806200',' ',mm.MMGRP1||'-999999',mm.MMHIE3)||'-'||Decode(mm.MMGRP4,'36','31','37','32',' ','99',mm.MMGRP4)||'-'||Decode(mm.MMGRP5,'85','47','54','35','33','999',' ','999',mm.MMGRP5)) AS VARCHAR(108)) AS L5_code,        --unique item
 CAST((mm.MMITNO) AS VARCHAR(108)) AS L6_code,
 CAST((mm.MMSTAT) AS VARCHAR(108)) AS M3STATUS,                                                                                   --item/SKU
 CAST((mm.MMVOL3) AS VARCHAR(108)) AS VOLUME,
 CAST(case when mm.MMUNMS='PC' then 1
      when mm.MMGRP4='33' and mm.MMGRP5='82' then 1 else mm.MMCFI2 END AS VARCHAR(108)) AS SU_IN_UNIT,
 CAST((Decode(HI2.HITX40,' ','NA',NULL,'NA',HI2.HITX40)) AS VARCHAR(108)) AS BRAND2,
 CAST((Decode(HI3.HITX40,' ','NA',NULL,'NA',HI3.HITX40)) AS VARCHAR(108)) AS BRAND3,
 CAST((Decode(mm.MMHIE2,'7200','8062','7420','2560','4200','2170','4202','2171','260J','2600','2810','7460','200L','2720',' ','9999',mm.MMHIE2)) AS VARCHAR(108)) AS BRAND2_code,
 CAST((Decode(mm.MMHIE3,'720001','806200',' ','999999',mm.MMHIE3)) AS VARCHAR(108)) AS BRAND3_code,

 CAST(CASE
          WHEN tar.qsitno IS NOT null THEN tar.QSEVTG
          ELSE to_number_spec(mm.mmcfi1)
      END
 AS VARCHAR(108)) AS ALC_VOL_PERC,
 CASE when to_number_spec(mm.mmcfi1) > 0.5 then 'ALCO' else 'NONALCO' end ALCO_NONALCO,
 CAST((CASE
          WHEN ean.ean IS NOT NULL THEN ean.ean
          ELSE Decode(mp1.MPPOPN,NULL,'NA',mp1.MPPOPN) END) AS VARCHAR(108)) AS EANcode,
  CAST((CASE
          WHEN ean.ean_kupa IS NOT NULL THEN ean.ean_kupa
          ELSE Decode(mp1.MPPOPN,NULL,'NA',mp1.MPPOPN) END) AS VARCHAR(108)) AS EAN_KUPAcode,
 CAST( (CASE WHEN grti.mmitno IS NULL THEN mm.mmitno ELSE mm.mmgrti END) AS VARCHAR(108)) AS budgetitem,
 CAST(
 (
 CASE WHEN m9vamt='0' THEN '0-zero cost'
      WHEN m9vamt='1' THEN '1-standard cost'
      WHEN m9vamt='2' THEN '2-average cost'
      WHEN m9vamt='3' THEN '3-dynamic cost'
 ELSE '99-other' END
 )
 AS VARCHAR(108)) AS Inv_Acc_Method,
 CAST((CASE WHEN mm.mmmabu='2' THEN 'Purchased' ELSE 'Produced' END) AS VARCHAR(108)) AS ProducedPurchased,

--DEPOSIT FEE GROUPS:
  CAST(
      CASE
      --CESU deposit fee group definitions:
            WHEN mm.mmpdln='700' THEN
                  CASE WHEN mm.mmcfi4 IS NULL OR mm.mmcfi4=' ' THEN '99999' ELSE mm.mmcfi4 END
      --ALC deposit fee group definitions:
            WHEN mm.mmpdln='200' THEN
                  CASE WHEN mm.mmcfi5 IS NULL OR mm.mmcfi5=' ' OR mm.mmcfi3 IS NULL OR mm.mmcfi3=' ' THEN '99999' ELSE mm.mmgrp4||'-'||mm.mmcfi5||'-'||mm.mmcfi3 END
      --OLVI deposit fee group definitions:
            WHEN mm.mmpdln IN ('100','300','310','320') THEN
                 CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3=' ' OR mm.mmcfi3='eip' THEN '99999' ELSE mm.mmcfi3 END
       --VOLFAS deposit fee group definitions:
            WHEN m9faci IN ('600','606','616') THEN
                CASE WHEN mm.mmpdln='600' AND m9faci!='606' AND mm.mmprod='9900009' THEN '99999' 
                     WHEN mm.mmcfi5 IS NULL OR mm.mmcfi5=' '  THEN '99999'
                     ELSE sg4.sgtx40||'-'||cfi5.cttx15||'-'||sg5.sgtx40
                END
      --VESTFYEN depo fee group definitions:
            WHEN mm.mmpdln IN ('400') THEN
                  CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3=' ' THEN '99999' ELSE mm.mmcfi3||'-'||mm.mmgrp4||'-'||mm.mmgrp5 END
      -- all other groups currently undefined:
            ELSE 'undefined'
        END
  AS VARCHAR(108)) AS depofeegroupcode,

--DEPOSIT FEE GROUPS:
  CAST(
      CASE
      --CESU deposit fee group definitions:
            WHEN mm.mmpdln='700' THEN
                  CASE WHEN mm.mmcfi4 IS NULL OR mm.mmcfi4=' '  THEN 'No deposit fee' ELSE cfi4.cttx40 END
      --ALC deposit fee group definitions:
            WHEN mm.mmpdln='200' THEN
                  CASE WHEN mm.mmcfi5 IS NULL OR mm.mmcfi5=' ' OR mm.mmcfi3 IS NULL OR mm.mmcfi3=' ' THEN 'No deposit fee' ELSE sg4.sgtx40||'-'||cfi5.cttx15||'-'||cfi3.cttx40 END
      --OLVI deposit fee group definitions:
            WHEN mm.mmpdln IN ('100','300','310','320') THEN
                 CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3=' ' OR mm.mmcfi3='eip' THEN 'No deposit fee' ELSE cfi3.cttx40 END
       --VOLFAS deposit fee group definitions:
            WHEN mm.mmpdln IN ('600','606') THEN
                 CASE WHEN mm.mmcfi5 IS NULL OR mm.mmcfi5=' ' THEN 'No deposit fee' ELSE sg4.sgtx40||'-'||cfi5.cttx15||'-'||sg5.sgtx40 END
      --VESTFYEN depo fee group definitions:
            WHEN mm.mmpdln IN ('400') THEN
                  CASE WHEN mm.mmcfi3 IS NULL OR mm.mmcfi3=' ' THEN 'No deposit fee' ELSE cfi3.cttx40||'-'||sg4.sgtx40||'-'||sg5.sgtx40 END
      -- all other groups currently undefined:
            ELSE 'undefined'
        END
  AS VARCHAR(108)) AS depofeegroupname,

--EXCISE GROUPS
  CAST(
      CASE
      --CESU excise group definitions:
            WHEN mm.mmpdln='700' THEN
                  CASE          WHEN mm.mmatmo='ALUS'                                                                         THEN 'beer'
                                WHEN mm.mmatmo='RDZ' AND to_number_spec(mm.mmcfi1)<=6.0                                       THEN 'ferm_till6'
                                WHEN mm.mmatmo='RDZ' AND to_number_spec(mm.mmcfi1)>6.0                                        THEN 'ferm_over6'
                                WHEN mm.mmatmo IN ('WINE','RDZ_STR')                                                          THEN 'ferm_over6'
                                WHEN mm.mmatmo='P.A.DZ'                                                                       THEN 'spirit'
                                WHEN mm.mmatmo IN ('STARPP','STARPP_STR','DRINKOT')                                           THEN 'inter'
                                WHEN mm.mmatmo='B.A.DZ'                                                                       THEN 'sugar'
                                WHEN mm.mmatmo='WATER' AND mm.MMCFI3='SD'                                                     THEN 'sugar'
                                WHEN mm.mmatmo='B.A.DZ.C' and mm.MMCFI3='SDc'                                                 THEN 'soft'  --added on 2021-11-10
                                WHEN mm.mmatmo = 'B.A.DZ.E'  AND mm.MMCFI3 = 'SDe'                                              THEN 'soft' 
                                                                                                                              ELSE 'no'
                  END
      --ALC excise group definitions:
            WHEN mm.mmpdln='200' THEN
                  CASE
                                WHEN to_number_spec(mm.mmcfi1)<=1.3                                                                         THEN 'no'
                                WHEN mm.mmgrp1='01'                                                                                         THEN 'beer'
                                WHEN mm.mmgrp1 IN ('02','03','04','05') AND mm.mmitgr NOT IN ('2120') AND to_number_spec(mm.mmcfi1)<=6.0    THEN 'ferm_till6'
                                WHEN mm.mmgrp1 IN ('02','03','04','05') AND mm.mmitgr NOT IN ('2120') AND to_number_spec(mm.mmcfi1)>6.0     THEN 'ferm_over6'
                                WHEN mm.mmitgr IN ('2120')                                                                                  THEN 'spirit'
                                                                                                                                            ELSE 'no'
                  END
      --OLVI excise group definitions (=to be clarified):
            WHEN mm.mmpdln IN ('100','300','310','320') THEN
               CASE
                                WHEN mm.mmdwno=' '                                                                                          THEN 'no'
                                                                                                                                            ELSE mm.mmdwno
               END

       --VOLFAS excise group definitions:
            WHEN mm.mmpdln IN ('600','606','616') THEN
                  CASE          WHEN mm.MMCFI3='SU2'                                                                                        THEN 'soft'
                                WHEN mm.MMCFI3='SU0'                                                                                        THEN 'no'
                                WHEN mm.MMCFI3 in ('SU1','SU3','SU4','SU5')                                                                 THEN 'sugar'
                                WHEN (to_number_spec(mm.mmcfi1)<=1.3 OR mm.mmspe4=' ')                                                      THEN 'no'
                                WHEN SubStr(mm.mmspe4,0,3) IN ('110')                                                                       THEN 'beer'
                                WHEN SubStr(mm.mmspe4,0,3) IN ('280','299')                                                                 THEN 'spirit'
                                WHEN SubStr(mm.mmspe4,0,3) IN ('210','215')                                                                 THEN 'ferm_till_8.5'
                                WHEN SubStr(mm.mmspe4,0,3) IN ('230','235')                                                                 THEN 'ferm_over_8.5'
                                                                                                                                            ELSE 'no'
                  END
      --VESTFYEN excise group definitions (=to be clarified):
            WHEN mm.mmpdln IN ('400') THEN
                  CASE                WHEN to_number_spec(mm.mmcfi1)<=1.2                                                                   THEN 'no'
                                      WHEN mm.mmgrp1='01' AND  to_number_spec(mm.mmcfi1)>2.8                                                THEN 'beer'
                                      WHEN mm.mmgrp1 IN ('02','03','04')  AND to_number_spec(mm.mmcfi1)<=6.0                                THEN 'ferm_till6'
                                      WHEN mm.mmgrp1 IN ('02','03','04')  AND to_number_spec(mm.mmcfi1)>6.0                                 THEN 'ferm_over6'
                                      WHEN mm.mmgrp1 IN ('05')                                                                              THEN 'spirit'
                                                                                                                                            ELSE 'no'
                  END
      --LIDA excise group definitions (=to be clarified):
            WHEN mm.mmpdln IN ('800') THEN
                  CASE
                                      WHEN mm.mmitgr='8140' AND mm.mmevgr='1'                                                               THEN '800winebased'
                                      WHEN mm.mmitgr='8100' AND mm.mmevgr='1'                                                               THEN '800beerover7'
                                      WHEN mm.mmitgr='8105' AND mm.mmevgr='1'                                                               THEN '800beerto7'
                                      WHEN mm.mmitgr='8115' AND mm.mmevgr='1'                                                               THEN '800cider'
                                      WHEN mm.mmitgr='8150' AND mm.mmevgr='1'                                                               THEN '800energy'
                                      WHEN mm.mmitgr='8107' AND mm.mmevgr='1'                                                               THEN '800beershake'
                                      WHEN mm.mmitgr='8110' AND mm.mmevgr='1'                                                               THEN 'no'
                                      WHEN mm.mmevgr='0' OR mm.mmevgr=' '                                                                   THEN 'no'
                                                                                                                                            ELSE 'no'
                  END

      -- all other groups currently undefined:
            ELSE 'undefined'
        END
  AS VARCHAR(108)) AS excisegroupcode,
 CAST((CASE WHEN mbsuno IN ('',' ') THEN 'NA' ELSE Upper(sup.idsunm)|| '('||mbsuno||')' END) AS VARCHAR(108)) AS mainsupplier,
 CAST(case when m9rewh='200' then '203 - LC excise warehouse' ELSE (m9rewh||' - '||mwwhnm) END AS VARCHAR(108)) AS mainwarehouse,
 M9WCLN||'-'||ppplnm as mainFillingLine,
 CAST((CASE WHEN mm.mmprod IN ('',' ') THEN 'NA' ELSE Upper(sul.idsunm)|| '('||mm.mmprod||')' END) AS VARCHAR(108)) AS MANUFACTURER,
 CAST((Decode(mm.mmitrf,' ','99',mm.mmitrf)||' - '||Decode(lp.ittx40,NULL,'OTHER',lp.ittx40)) AS VARCHAR(108)) AS launchperiod,
 CAST((Decode(MBSTTX,' ','NA',NULL,'NA',MBSTTX)) AS VARCHAR(108)) AS endperiod,
 CAST((CASE WHEN mm.MMPDLN IN ('100') THEN  mm.MMITGR||' - '||itgr.CTTX40 ELSE
          CASE
          WHEN mm.MMGRP1 IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14') THEN mm.MMGRP1||'.'||sg1.SGTX40
          ELSE '99.OTHER - '||mm.MMGRP1 END
          END ) AS VARCHAR(108)) AS localitemgroup,
 CAST((mm.MMITCL||' - '||itcl.CTTX40) AS VARCHAR(108)) AS localproductgroup,
 CAST((mm.MMITNO||' '||mm.MMFUDS) AS VARCHAR(108)) AS locallongname,
 CAST(CASE when mm.MMPDLN='200' and mm.mmgrp4='31' and mm.mmevgr=' ' then 1
           when mm.MMPDLN='400' and mm.MMCFI3 in ('4A','4A0') then 1
           when mm.MMPDLN='600' and mm.MMCFI5='N' then 1
           when mm.MMPDLN='700' and mm.MMCFI4 in ('7BB00','7DK00','7GB00','7ND00','7RD00') then 1
           when mm.MMPDLN='100' and mm.MMCFI3='EIP' then 1
           ELSE 0 END AS VARCHAR(108)) AS ATTR1, --returnable glass bottles
 CAST( ifsite AS VARCHAR(108)) AS ATTR2, -- supplier item code from PPS040
 CAST( null AS VARCHAR(108)) AS ATTR3,
 CAST( null AS VARCHAR(108)) AS ATTR4,
 CAST( null AS VARCHAR(108)) AS ATTR5,
 mm.MMITRF AS LAUNCH_PERIOD, 
 MBSTTX AS ENDING_NOTE,
 CASE WHEN MM.MMPDLN IN ('100','400') THEN MM.MMGRP3 ELSE MM.MMGRP5 END AS MULTIPACK_CODE,
 CASE WHEN MM.MMPDLN IN ('100','400') THEN SG3.SGTX40 ELSE SG5.SGTX40 END AS MULTIPACK
FROM mvxjdta.MITMAS mm
 left join mvxjdta.mitmas grti ON grti.mmcono=mm.mmcono AND grti.mmitno=mm.mmgrti
 left join anaplan.ad_sales_check_item sc ON mm.mmitno=sc.itemcode
 left join mvxjdta.MITSCH sg1 on sg1.SGCONO=mm.MMCONO AND sg1.SGGLVL=1 AND sg1.SGSGP0=mm.MMGRP1
 left join mvxjdta.MITSCH sg2 on sg2.SGCONO=mm.MMCONO AND sg2.SGGLVL=2 AND sg2.SGSGP0=mm.MMGRP2
 left join mvxjdta.MITSCH sg3 on sg3.SGCONO=mm.MMCONO AND sg3.SGGLVL=3 AND sg3.SGSGP0=mm.MMGRP3
 left join mvxjdta.MITSCH sg4 on sg4.SGCONO=mm.MMCONO AND sg4.SGGLVL=4 AND sg4.SGSGP0=mm.MMGRP4
 left join mvxjdta.MITSCH sg5 on sg5.SGCONO=mm.MMCONO AND sg5.SGGLVL=5 AND sg5.SGSGP0=mm.MMGRP5
 left join mvxjdta.MITHRY hi1 on hi1.hiCONO=mm.MMCONO AND hi1.hihLVL=1 AND hi1.hihie0=mm.MMhie1
 left join mvxjdta.MITHRY hi2 on hi2.hiCONO=mm.MMCONO AND hi2.hihLVL=2 AND hi2.hihie0=mm.MMhie2
 left join mvxjdta.MITHRY hi3 on hi3.hiCONO=mm.MMCONO AND hi3.hihLVL=3 AND hi3.hihie0=mm.MMhie3
 left join mvxjdta.CSYTAB ct1 on ct1.CTCONO=mm.MMCONO AND ct1.CTSTCO='ITGR' and ct1.CTSTKY=mm.MMITGR
 left join mvxjdta.CSYTAB ct2 on ct2.CTCONO=mm.MMCONO AND ct2.CTSTCO='ITCL' and ct2.CTSTKY=mm.MMITCL
 left join mvxjdta.CIDMAS ct3 on ct3.IDCONO=mm.MMCONO AND ct3.IDSUNO=mm.MMPROD
 left join mvxjdta.CSYTAB ct5 on ct5.CTCONO=mm.MMCONO AND ct5.CTSTCO='CFI1' and ct5.CTSTKY=mm.MMCFI1
 left join mvxjdta.CSYTAB cfi3 on cfi3.CTCONO=mm.MMCONO AND cfi3.CTSTCO='CFI3' and cfi3.CTSTKY=mm.MMCFI3
 left join mvxjdta.CSYTAB cfi4 on cfi4.CTCONO=mm.MMCONO AND cfi4.CTSTCO='CFI4' and cfi4.CTSTKY=mm.MMCFI4
 left join mvxjdta.CSYTAB cfi5 on cfi5.CTCONO=mm.MMCONO AND cfi5.CTSTCO='CFI5' and cfi5.CTSTKY=mm.MMCFI5
 left join mvxjdta.CSYTAB itgr on itgr.CTCONO=mm.MMCONO AND itgr.CTSTCO='ITGR' and itgr.CTSTKY=mm.MMITGR
 left join mvxjdta.CSYTAB itcl on itcl.CTCONO=mm.MMCONO AND itcl.CTSTCO='ITCL' and itcl.CTSTKY=mm.MMITCL
 left join (SELECT mmitno, vahmyks AS ean, myks AS ean_kupa FROM OLVISII.QEAN02_300) ean ON mm.mmitno=ean.mmitno
-- left join (select m9cono, min(m9FACI) as m9faci, m9itno, Min(m9rewh)AS m9rewh, min(m9vamt) as m9vamt from mvxjdta.mitfac WHERE m9cono=100 group by m9cono, m9itno) ON m9cono=mm.mmcono AND m9itno=mm.mmitno
 left join mvxjdta.mitfac on mm.mmcono=m9cono and mm.mmitno=m9itno and M9FACI != '800'-- and CASE WHEN mm.MMPDLN IN ('310','320') THEN '300' ELSE mm.MMPDLN END=m9faci
 left join mvxjdta.mitbal     ON     mbcono=mm.mmcono AND     mbitno=mm.mmitno AND mbwhlo=m9rewh
 left join mvxjdta.mitwhl ON mwcono=mbcono AND mbwhlo=mwwhlo
 left join mvxjdta.mititr@GM3PRD1 lp ON lp.itcono=mm.mmcono AND lp.ititrf=mm.mmitrf
 left join mvxjdta.cidmas sup ON sup.idcono=mbcono AND sup.idsuno=mbsuno
 left join mvxjdta.cidmas sul ON sul.idcono=mm.mmcono AND sul.idsuno=mm.mmprod
 left join mvxjdta.mpdwct pp on mm.mmcono=pp.ppcono and m9faci=ppfaci and M9WCLN=PPPLGR
 left join (select mpcono, mpitno, max(mppopn) as mppopn from mvxjdta.MITPOP where mpalwt='2' group by mpcono, mpitno) mp1 ON mp1.MPCONO=mm.MMCONO /*AND mp1.MPALWT='2'*/ AND mp1.MPITNO=mm.MMITNO
 left join (
            SELECT qsitno,qsqte1,qsqti1,QSEVTG FROM (SELECT Row_Number() over (PARTITION BY qsitno ORDER BY qsitno,qsqte1 DESC) AS ordr, tmp.* FROM mvxjdta.QMSTST tmp where qsqtst = 'C265' and substr(qsspec, 9) = 'MAX ALC') WHERE ordr IN (1)
           ) tar ON mm.mmitno=tar.qsitno
left join (select distinct ifitno,ifsuno,ifsite from mvxjdta.mitven) sit on sit.ifitno=mm.mmitno and sit.ifsuno=mbsuno --join PPS040 supplier item mapping
WHERE mm.MMCONO=100  AND mm.MMITTY IN ('10') AND mm.mmstat>='10'   /*AND mm.mmsale='1' */  AND sg1.sgtx40 IS NOT null AND (mm.mmstat<='20' OR sc.itemcode IS NOT NULL) and
m9faci <> '800' and m9faci is not null
-- and (CASE WHEN mm.MMPDLN IN ('310','320') THEN '300' ELSE mm.MMPDLN END) = '800'
) pr left join anaplan.ad_excisegroups ex ON pr.excisegroupcode=ex.excisegroupcode
UNION ALL
SELECT "DIVISION","L1_PRODUCTGROUP","L2_BRAND","L3_PACKAGETYPE","L4_PACKAGESIZE","L5_UNIQUEITEM","L6_SKU","L1_CODE","L2_CODE","L3_CODE","L4_CODE","L5_CODE","L6_CODE","M3STATUS","VOLUME","SU_IN_UNIT","BRAND2","BRAND3","BRAND2_CODE","BRAND3_CODE","ALC_VOL_PERC","ALCO_NONALCO","EANCODE","EAN_KUPACODE","BUDGETITEM","INV_ACC_METHOD","PRODUCEDPURCHASED","DEPOFEEGROUPCODE","DEPOFEEGROUPNAME","EXCISEGROUPCODE","EXCISEGROUPNAME","MAINSUPPLIER","MAINWAREHOUSE","MAINFILLINGLINE","MANUFACTURER","LAUNCHPERIOD","ENDPERIOD","LOCALITEMGROUP","LOCALPRODUCTGROUP","LOCALLONGNAME","ATTR1","ATTR2","ATTR3","ATTR4","ATTR5","LAUNCH_PERIOD","ENDING_NOTE","MULTIPACK_CODE","MULTIPACK" FROM ANAPLAN.MD_PRODUCT@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "DIVISION","L1_PRODUCTGROUP","L2_BRAND","L3_PACKAGETYPE","L4_PACKAGESIZE","L5_UNIQUEITEM","L6_SKU","L1_CODE","L2_CODE","L3_CODE","L4_CODE","L5_CODE","L6_CODE","M3STATUS","VOLUME","SU_IN_UNIT","BRAND2","BRAND3","BRAND2_CODE","BRAND3_CODE","ALC_VOL_PERC","ALCO_NONALCO","EANCODE","EAN_KUPACODE","BUDGETITEM","INV_ACC_METHOD","PRODUCEDPURCHASED","DEPOFEEGROUPCODE","DEPOFEEGROUPNAME","EXCISEGROUPCODE","EXCISEGROUPNAME","MAINSUPPLIER","MAINWAREHOUSE","MAINFILLINGLINE","MANUFACTURER","LAUNCHPERIOD","ENDPERIOD","LOCALITEMGROUP","LOCALPRODUCTGROUP","LOCALLONGNAME","ATTR1","ATTR2","ATTR3","ATTR4","ATTR5","LAUNCH_PERIOD","ENDING_NOTE","MULTIPACK_CODE","MULTIPACK" FROM M3SKY_ANAPLAN.MD_PRODUCT WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."MD_PRODUCT" TO "LOTMAT";


--MD_PRODUCT_TOA

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_PRODUCT_TOA" ("LISTROWS", "INDE") AS 
  SELECT 
'DIVISION'||';'||'L1_PRODUCTGROUP'||';'||'L2_BRAND'||';'||'L3_PACKAGETYPE'||';'||'L4_PACKAGESIZE'||';'||'L5_UNIQUEITEM'||';'||'L6_SKU'||';'||
'L1_CODE'||';'||'L2_CODE'||';'||'L3_CODE'||';'||'L4_CODE'||';'||'L5_CODE'||';'||'L6_CODE'||';'||
'M3STATUS'||';'||'VOLUME'||';'||'SU_IN_UNIT'||';'||'BRAND2'||';'||'BRAND3'||';'||'BRAND2_CODE'||';'||'BRAND3_CODE'||';'||
'ALC_VOL_PERC'||';'||'ALCO_NONALCO'||';'||'EANCODE'||';'||'BUDGETITEM'||';'||'INV_ACC_METHOD'||';'||'PRODUCEDPURCHASED'||';'||
'DEPOFEEGROUPCODE'||';'||'DEPOFEEGROUPNAME'||';'||'EXCISEGROUPCODE'||';'||'EXCISEGROUPNAME'||';'||'MAINSUPPLIER'||';'||'MAINWAREHOUSE'||';'||'LAUNCHPERIOD'||';'||'ENDPERIOD'||';'||'LOCALITEMGROUP'||';'||'LOCALPRODUCTGROUP'||';'||
'ATTR1'||';'||'ATTR2'||';'||'ATTR3'||';'||'ATTR4'||';'||'ATTR5' AS LISTROWS, 1 AS INDE FROM DUAL
UNION ALL
SELECT
DIVISION||';'||L1_PRODUCTGROUP||';'||L2_BRAND||';'||L3_PACKAGETYPE||';'||L4_PACKAGESIZE||';'||L5_UNIQUEITEM||';'||L6_SKU||';'||
L1_CODE||';'||L2_CODE||';'||L3_CODE||';'||L4_CODE||';'||L5_CODE||';'||L6_CODE||';'||
M3STATUS||';'||VOLUME||';'||SU_IN_UNIT||';'||BRAND2||';'||BRAND3||';'||BRAND2_CODE||';'||BRAND3_CODE||';'||
ALC_VOL_PERC||';'||ALCO_NONALCO||';'||EANCODE||';'||BUDGETITEM||';'||INV_ACC_METHOD||';'||PRODUCEDPURCHASED||';'||
DEPOFEEGROUPCODE||';'||DEPOFEEGROUPNAME||';'||EXCISEGROUPCODE||';'||EXCISEGROUPNAME||';'||MAINSUPPLIER||';'||MAINWAREHOUSE||';'||LAUNCHPERIOD||';'||ENDPERIOD||';'||LOCALITEMGROUP||';'||LOCALPRODUCTGROUP||';'||
ATTR1||';'||ATTR2||';'||ATTR3||';'||ATTR4||';'||ATTR5 AS LISTROWS, 2 AS INDE
FROM ANAPLAN.MD_PRODUCT;



--MD_SEMIPRODUCT

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_SEMIPRODUCT" ("DIVISION", "L1_PRODUCTGROUP", "L1_CODE", "L6_SKU", "L6_CODE", "LOCALITEMGROUP", "PRODUCEDPURCHASED") AS 
  SELECT
 CASE WHEN mm.MMPDLN IN ('310','320') THEN '300' ELSE mm.MMPDLN END AS Division,
 CAST((CASE
 WHEN mm.MMGRP1 IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14') THEN mm.MMGRP1||'.'||sg1.SGTX40
 ELSE '99.OTHER - '||mm.MMGRP1 END) AS VARCHAR(108))  AS L1_ProductGroup,
 CAST((Decode(mm.MMGRP1,' ','99',mm.MMGRP1)) AS VARCHAR(108))  AS  L1_code,
 CAST((mm.MMITDS||' ('||mm.MMITNO||')') AS VARCHAR(108))  AS  L6_SKU,
 CAST((mm.MMITNO) AS VARCHAR(108)) AS L6_code,
 CAST((mm.MMITGR||' - '||itgr.CTTX40) AS VARCHAR(108)) AS localitemgroup,
CAST((CASE WHEN mm.mmmabu='2' THEN 'Purchased' ELSE 'Produced' END) AS VARCHAR(108)) AS ProducedPurchased
FROM mvxjdta.MITMAS mm
  left join mvxjdta.CSYTAB itgr on itgr.CTCONO=mm.MMCONO AND itgr.CTSTCO='ITGR' and itgr.CTSTKY=mm.MMITGR
  left join mvxjdta.MITSCH sg1 on sg1.SGCONO=mm.MMCONO AND sg1.SGGLVL=1 AND sg1.SGSGP0=mm.MMGRP1
  where mmitty='40' and mmsale=1 and mmstat<='20';


  GRANT SELECT ON "ANAPLAN"."MD_SEMIPRODUCT" TO "LOTMAT";



--MD_WORKCENTER

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MD_WORKCENTER" ("DIVISION", "WORKCENTER_CODE", "WORKCENTER_NAME", "COSTCENTER_CODE", "WORKCENTER_GROUP") AS 
  select 
      PPFACI as division
      ,PPFACI||'_'||PPPLGR as WorkCenter_Code
      ,PPPLNM as WorkCenter_Name
      ,PPFACI||'_'||PPCOCE as CostCenter_Code
      ,case 
        when PPPLGR in ('6','8','10','11','12','13','14','20','ÕLU','KLAAS','VAAT','PURK','PET2','TETRA','TETRA3','705','706','707','711','605','606','607','611','612','614','632','650','660','411','412','413','414','415','416','431','435') 
        then 'FILLING' 
        WHEN PPPLGR IN ('KL.MP','610','418','709','710','712','419','420','450')
        THEN 'MULTIPACKING & REPACKING'
        WHEN PPPLGR IN ('101','102','103','104','108','109','201','202','204','205','206','207','305','315','701','702','703','704','708','601','602','604','608','609','625','630','631','701','702','703','704','708','401','402','404','407','421','422','423','424','425','427')
        THEN 'BOILING AND MIXING' 
        ELSE 'OTHER' END as WorkCenter_Group
from mvxjdta.MPDWCT
where PPPLTP=1 and PPCINA=1 and PPFACI not in ('800','400')
union all
select "DIVISION","WORKCENTER_CODE","WORKCENTER_NAME","COSTCENTER_CODE","WORKCENTER_GROUP" from anaplan.MD_WORKCENTER@LBM3PRD1_ANAPLAN where division = '800'
union all
select "DIVISION","WORKCENTER_CODE","WORKCENTER_NAME","COSTCENTER_CODE","WORKCENTER_GROUP" from m3sky_anaplan.MD_WORKCENTER where division = '400';


  GRANT SELECT ON "ANAPLAN"."MD_WORKCENTER" TO "LOTMAT";


--MM_DAILY_SALES

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MM_DAILY_SALES" ("DIVISION", "INVOICEDATE", "DELIVERYDATE", "CUSTOMERCODE", "ITEMCODE", "VOLUME", "ORDER_VOLUME", "NETSALES", "DISCOUNT", "EXCISE", "DEPOFEE", "GROSS", "COGS", "ADDCOGS", "ATTR1", "ATTR2", "ATTR3", "CAMPAIGN", "L1_REGION", "L2_SALESCHANNEL", "L3_CUSTOMERGROUP", "L4_CHAIN", "L5_CUSTOMER") AS 
  SELECT 
CAST((dta.divi) AS VARCHAR(108)) AS division,
CAST((dta.invoicedate) AS VARCHAR(108)) AS invoicedate,
CAST((dta.deliverydate) AS VARCHAR(108)) AS deliverydate,
CAST(
    (cu.division||'-'||cu.l2_saleschannel||'-'||cu.l3_code||'-'||cu.l4_code||CASE WHEN cu.l5_code=cu.l4_code THEN '' ELSE '-'||cu.l5_code END||'-'||cu.l6_code)
AS VARCHAR(108)) AS customercode,
CAST((dta.itemcode) AS VARCHAR(108)) AS itemcode, 
Round(Sum(dta.volume),4) AS volume,
Round(Sum(dta.ORDER_VOLUME),4) AS order_volume,
Round(Sum(dta.Netsales),4) AS netsales,
Round(Sum(dta.Discount),4) AS discount,
Round(Sum(dta.Excise),4) AS excise,
Round(Sum(dta.Depofee),4) AS depofee,
Round(Sum(dta.Gross),4) AS gross,
Round(Sum(dta.TotalCogs),4) AS cogs,
Round(Sum(dta.AdditionalCogs),4) AS addcogs,
CAST(null AS varchar(108) ) AS attr1,
CAST(null AS varchar(108) ) AS attr2,
CAST(null AS varchar(108) ) AS attr3,
CAST(decode(trim(to_char(dta.campaign)),'1','1',null,'0','0') AS VARCHAR(108)) AS campaign,
l1_region, l2_saleschannel,l3_customergroup,l4_chain,l5_customer 
FROM 
(

SELECT ss.division AS divi, To_Char(ss.invoicedate) AS invoicedate,To_Char(ss.deliverydate) AS deliverydate,ss.customercode, ss.itemcode,
ss.INVOICEQUANTITY*c.volume AS volume, ss.ORDERQUANTITY*c.volume as ORDER_VOLUME,
CASE WHEN ss.DIVISION IN ('100','300') THEN ss.GROSSSALES-2*ss.DISCOUNTAMOUNT-ss.ONK2-ss.EXCISEAMOUNT  WHEN ss.DIVISION IN ('800') THEN ss.NETSALES  ELSE ss.NETSALES-ss.ONK2 END AS Netsales,
--Sum(CASE WHEN a.DIVISION IN ('100') THEN a.NETSALES+a.DISCOUNTAMOUNT-a.ONK2+a.ONK4  WHEN a.DIVISION IN ('800') THEN a.NETSALES  ELSE a.NETSALES-a.ONK2 END) AS Netsales,
--Sum(CASE WHEN a.DIVISION IN ('100','300') THEN a.NETSALES WHEN a.DIVISION IN ('800') THEN a.NETSALES  ELSE a.NETSALES-a.ONK2 END) AS Netsales,
ss.DISCOUNTAMOUNT AS Discount,
--Sum(CASE WHEN a.DIVISION IN ('100','800') THEN 0 ELSE a.DISCOUNTAMOUNT END) AS Discount,
ss.EXCISEAMOUNT AS Excise,
ss.ONK2 AS Depofee,
ss.GROSSSALES AS Gross,
--Sum(CASE WHEN a.DIVISION IN ('100','300') THEN a.GROSSSALES-a.DISCOUNTAMOUNT ELSE a.GROSSSALES END) AS Gross,
ss.COSTAMOUNTLOCALCURR AS TotalCoGS,
ss.ONK3 AS AdditionalCoGS,
ss.EXTRA1 as campaign
FROM bousr.bi_sales ss
inner JOIN bousr.bi_ordertypes_v ot ON ot.division=ss.division AND ot.ordertype=ss.ordertype
inner join  bousr.BI_PRODUCT c on ss.COMPANYCODE=c.COMPANYCODE	and ss.ITEMCODE=c.ITEMCODE  
WHERE 
  ((SubStr(invoicedate,0,6) between to_char(add_months(sysdate,-1), 'YYYYMM') and to_char(sysdate, 'YYYYMM')  OR SubStr(deliverydate,0,6) between to_char(add_months(sysdate,-1), 'YYYYMM') and to_char(sysdate, 'YYYYMM')) or (ss.DIVISION in ('100','300','400') and invoicedate = 0 and SubStr(deliverydate,0,6) between to_char(add_months(sysdate,-1), 'YYYYMM') and to_char(sysdate, 'YYYYMM')))
  AND ot.ordertypegroup='NORMAL'
  AND c.itemtype='10' 
  and (ss.IID='X' OR (ss.DIVISION in ('100','300','400')))
) dta
left join ANAPLAN.MD_CUSTOMER_DETAIL_T cu ON cu.m3customercode=dta.customercode 
GROUP BY 
cu.division||'-'||cu.l2_saleschannel||'-'||cu.l3_code||'-'||cu.l4_code||CASE WHEN cu.l5_code=cu.l4_code THEN '' ELSE '-'||cu.l5_code END||'-'||cu.l6_code, 
dta.divi,dta.itemcode,dta.invoicedate,dta.deliverydate, decode(trim(to_char(dta.campaign)),'1','1',null,'0','0'),
l1_region, l2_saleschannel,l3_customergroup,l4_chain,l5_customer;



--MM_DAILY_SALES_DET

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."MM_DAILY_SALES_DET" ("DIVISION", "PERIOD", "CUSTOMERCODE", "ITEMCODE", "VOLUME", "ORDER_VOLUME", "NETSALES", "DISCOUNT", "EXCISE", "DEPOFEE", "GROSS", "COGS", "ADDCOGS", "DAYS", "CAMPAIGN", "L1_REGION", "L2_SALESCHANNEL", "L3_CUSTOMERGROUP", "L4_CHAIN", "L5_CUSTOMER") AS 
  SELECT 
CAST((dta.divi) AS VARCHAR(108)) AS division,
CAST((substr(dta.invoicedate,0,6)) AS VARCHAR(108)) AS period,
-- CAST((dta.deliverydate) AS VARCHAR(108)) AS deliverydate,
CAST(dta.customercode AS VARCHAR(108)) AS customercode,
CAST((dta.itemcode) AS VARCHAR(108)) AS itemcode, 
Round(Sum(dta.volume),4) AS volume,
Round(Sum(dta.ORDER_VOLUME),4) AS order_volume,
Round(Sum(dta.Netsales),4) AS netsales,
Round(Sum(dta.Discount),4) AS discount,
Round(Sum(dta.Excise),4) AS excise,
Round(Sum(dta.Depofee),4) AS depofee,
Round(Sum(dta.Gross),4) AS gross,
Round(Sum(dta.TotalCogs),4) AS cogs,
Round(Sum(dta.AdditionalCogs),4) AS addcogs,
count(distinct dta.invoicedate) as days,
CAST(decode(trim(to_char(dta.campaign)),'1','1',null,'0','0') AS VARCHAR(108)) AS campaign,
l1_region, l2_saleschannel,l3_customergroup,l4_chain,l5_customer
--100*Round(Sum(dta.Discount)/sum(dta.discount+dta.netsales),3) AS discount_percent
FROM 
(

SELECT ss.division AS divi, To_Char(ss.invoicedate) AS invoicedate,To_Char(ss.deliverydate) AS deliverydate,ss.customercode, ss.itemcode,
ss.INVOICEQUANTITY*c.volume AS volume, ss.ORDERQUANTITY*c.volume as ORDER_VOLUME,
CASE WHEN ss.DIVISION IN ('100','300') THEN ss.GROSSSALES-2*ss.DISCOUNTAMOUNT-ss.ONK2-ss.EXCISEAMOUNT  WHEN ss.DIVISION IN ('800') THEN ss.NETSALES  ELSE ss.NETSALES-ss.ONK2 END AS Netsales,
--Sum(CASE WHEN a.DIVISION IN ('100') THEN a.NETSALES+a.DISCOUNTAMOUNT-a.ONK2+a.ONK4  WHEN a.DIVISION IN ('800') THEN a.NETSALES  ELSE a.NETSALES-a.ONK2 END) AS Netsales,
--Sum(CASE WHEN a.DIVISION IN ('100','300') THEN a.NETSALES WHEN a.DIVISION IN ('800') THEN a.NETSALES  ELSE a.NETSALES-a.ONK2 END) AS Netsales,
ss.DISCOUNTAMOUNT AS Discount,
--Sum(CASE WHEN a.DIVISION IN ('100','800') THEN 0 ELSE a.DISCOUNTAMOUNT END) AS Discount,
ss.EXCISEAMOUNT AS Excise,
ss.ONK2 AS Depofee,
ss.GROSSSALES AS Gross,
--Sum(CASE WHEN a.DIVISION IN ('100','300') THEN a.GROSSSALES-a.DISCOUNTAMOUNT ELSE a.GROSSSALES END) AS Gross,
ss.COSTAMOUNTLOCALCURR AS TotalCoGS,
ss.ONK3 AS AdditionalCoGS,
ss.EXTRA1 as campaign
FROM bousr.bi_sales ss
inner JOIN bousr.bi_ordertypes_v ot ON ot.division=ss.division AND ot.ordertype=ss.ordertype
inner join  bousr.BI_PRODUCT c on ss.COMPANYCODE=c.COMPANYCODE	and ss.ITEMCODE=c.ITEMCODE  
WHERE 
  invoicedate between '20240801' and '20240930' 
  AND ot.ordertypegroup='NORMAL'
  AND c.itemtype='10' 
) dta
left join ANAPLAN.MD_CUSTOMER_DETAIL_T cu ON cu.m3customercode=dta.customercode 
GROUP BY 
dta.customercode, 
dta.divi,dta.itemcode,substr(dta.invoicedate,0,6), decode(trim(to_char(dta.campaign)),'1','1',null,'0','0'),
l1_region, l2_saleschannel,l3_customergroup,l4_chain,l5_customer;


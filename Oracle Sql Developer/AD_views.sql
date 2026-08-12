 
--AD_CHARGEMODEL

 CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_CHARGEMODEL" ("CHARGEMODEL", "EXCISE", "DEPOFEE") AS 
  SELECT DISTINCT mechsy AS chargemodel, 
CASE WHEN exc.chmodel IS NULL THEN 'NO' ELSE 'YES' END AS EXCISE,
CASE WHEN depo.chmodel IS NULL THEN 'NO' ELSE 'YES' END AS DEPOFEE

FROM mvxjdta.olichm cm
left join 
          (
           SELECT DISTINCT mechsy AS chmodel 
           FROM mvxjdta.olichm WHERE mecrid IN ('1600','1650','2999','3600','3601','4999','6999','7997','7999','8800','8820')
          ) exc ON cm.mechsy=exc.chmodel
left join 
          (
            SELECT DISTINCT mechsy AS chmodel 
            FROM mvxjdta.olichm WHERE mecrid IN ('1610','1611','1612','2997','3610','3611','3612','4997','6810','7280')
          ) depo ON cm.mechsy=depo.chmodel
ORDER BY chargemodel;


  GRANT SELECT ON "ANAPLAN"."AD_CHARGEMODEL" TO "LOTMAT";
  
  
-- AD_COSTCENTER_L3CODE
 
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_COSTCENTER_L3CODE" ("DIVISION", "COSTCENTER", "L3_CODE") AS 
  select distinct division, trim(substr(l3_customergroup,1,5)) as costcenter, l3_code  from anaplan.md_customer where division in ('100','300');


  GRANT SELECT ON "ANAPLAN"."AD_COSTCENTER_L3CODE" TO "LOTMAT";
  GRANT SELECT ON "ANAPLAN"."AD_COSTCENTER_L3CODE" TO "BOUSR" WITH GRANT OPTION;
  GRANT SELECT ON "ANAPLAN"."AD_COSTCENTER_L3CODE" TO "QTCUSER" WITH GRANT OPTION;


--AD_COUNTERUNITS

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_COUNTERUNITS" ("DIVISION", "COUNTERPART", "COUNTERUNIT") AS 
  SELECT
distinct
divi AS division,cp AS counterpart,f1 AS counterunit 
FROM bousr.fpm_consolidation_structure WHERE f2='9';


  GRANT SELECT ON "ANAPLAN"."AD_COUNTERUNITS" TO "LOTMAT";
  
  
  
--AD_CURRENCYRATES

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_CURRENCYRATES" ("DIVISION", "PERIOD", "CONVERSIONCURRENCY", "RATE") AS 
  select divi as division, period, conversioncurrency, round(rate,4) as rate from bousr.prep_currencyrates
where divi not in ('400')
UNION ALL
select division, period, conversioncurrency, rate from m3sky_anaplan.ad_currencyrates
where division in ('400');


  GRANT SELECT ON "ANAPLAN"."AD_CURRENCYRATES" TO "LOTMAT";
  
  
--AD_CURRENCYRATES_LAST

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_CURRENCYRATES_LAST" ("DIVISION", "LOCALCURRENCY", "CONVERSIONCURRENCY", "RATE", "MAX_DATE") AS 
  SELECT curr.CUDIVI as division, curr.CULOCD as localcurrency, curr.CUCUCD as conversioncurrency, curr.CUARAT as rate, curr.CUCUTD as max_Date 
FROM mvxjdta.CCURRA curr
            inner join
            (
              SELECT CUCONO, CUDIVI, CULOCD, CUCUCD, Max(CUCUTD) AS CUCUTD
              FROM mvxjdta.CCURRA
              WHERE CUCONO=100 AND CUDIVI!=' ' AND cucrtp=1
              GROUP BY CUCONO, CUCUCD, CUDIVI, CULOCD
            ) max_date ON max_date.CUCONO=curr.CUCONO and max_date.CUDIVI=curr.CUDIVI AND max_date.CUCUCD=curr.CUCUCD AND max_date.CUCUTD=curr.CUCUTD
where cucrtp=1 AND curr.CUDIVI not in ('800','400')
UNION ALL
SELECT "DIVISION","LOCALCURRENCY","CONVERSIONCURRENCY",1/"RATE" as RATE,"MAX_DATE" FROM ANAPLAN.AD_CURRENCYRATES_LAST@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "DIVISION","LOCALCURRENCY","CONVERSIONCURRENCY",1/"RATE" as RATE,"MAX_DATE" FROM M3SKY_ANAPLAN.AD_CURRENCYRATES_LAST WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."AD_CURRENCYRATES_LAST" TO "LOTMAT";
  
  

--AD_EXCISEGROUPS

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_EXCISEGROUPS" ("EXCISEGROUPCODE", "EXCISEGROUPNAME") AS 
  SELECT dodoid AS excisegroupcode, dodode AS excisegroupname FROM mvxjdta.mpddoc WHERE dodoty='VV'
UNION ALL 
SELECT 'beer' AS excisegroupcode,                 'Beer' AS excisegroupname FROM dual 
UNION ALL 
SELECT 'ferm_over6' AS excisegroupcode,           'Other fermented drink over 6% alc' AS excisegroupname FROM dual 
UNION ALL 
SELECT 'ferm_till_8.5' AS excisegroupcode,        'Other fermented drink until 8.5% alc' AS excisegroupname FROM dual
UNION ALL 
SELECT 'ferm_over_8.5' AS excisegroupcode,        'Other fermented drink over 8.5% alc' AS excisegroupname FROM dual
UNION ALL 
SELECT 'ferm_till6' AS excisegroupcode,           'Other fermented drink until 6% alc' AS excisegroupname FROM dual
UNION ALL 
SELECT 'inter' AS excisegroupcode,                'Intermediate products alc' AS excisegroupname FROM dual
UNION ALL 
SELECT 'spirit' AS excisegroupcode,               'Spirit-based alcoholic drinks' AS excisegroupname FROM dual
UNION ALL 
SELECT 'soft' AS excisegroupcode,                 'Soft drinks' AS excisegroupname FROM dual
UNION ALL 
SELECT 'sugar' AS excisegroupcode,                'Containing sugar' AS excisegroupname FROM dual
UNION ALL 
SELECT 'undefined' AS excisegroupcode,            'Undefined excise group' AS excisegroupname FROM dual
UNION ALL 
SELECT 'no' AS excisegroupcode,                   'No excise' AS excisegroupname FROM dual
UNION ALL 
SELECT '800winebased' AS excisegroupcode,                   'Слабоалкогольные на винной основе' AS excisegroupname FROM dual
UNION ALL 
SELECT '800beerover7' AS excisegroupcode,                   'Пиво крепкое (>7%)' AS excisegroupname FROM dual
UNION ALL 
SELECT '800beerto7' AS excisegroupcode,                   'Пиво' AS excisegroupname FROM dual
UNION ALL 
SELECT '800cider' AS excisegroupcode,                   'Сидр' AS excisegroupname FROM dual
UNION ALL 
SELECT '800energy' AS excisegroupcode,                   'Энергетические напитки' AS excisegroupname FROM dual;


  GRANT SELECT ON "ANAPLAN"."AD_EXCISEGROUPS" TO "LOTMAT";


--AD_PRICELIST_CUSTOMER


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_PRICELIST_CUSTOMER" ("DIVISION", "CUSTOMER1", "CUSTOMER2", "CUSTOMER3", "PRICELIST_REF", "ITEMCODE", "PRICE", "STARTDATE", "ENDDATE") AS 
  SELECT 
SubStr(odprrf,0,1)||'00' AS division,
odcuno AS customer1,
'L2' /*okrasn*/ AS customer2,
'L3' /*okcucl*/ AS customer3,
odprrf||'-'||odcuno AS pricelist_ref,
oditno AS itemcode,
odsapr AS price,
20230101 as startdate,
20300629 as enddate

FROM mvxjdta.oprbas
inner join 
  (SELECT odprrf AS prrf,odcuno AS cuno,Max(odfvdt) AS fvdt,odcono AS cono 
    FROM mvxjdta.oprbas 
    WHERE odcuno!=' '  AND odlvdt>=To_Char(current_date,'YYYYMMDD') AND odfvdt<=To_Char(current_date,'YYYYMMDD') 
    GROUP BY odprrf,odcuno,odcono
  ) temp ON temp.cuno=odcuno AND temp.cono=odcono AND temp.prrf=odprrf AND odfvdt=temp.fvdt 
inner join mvxjdta.ocusma ON okcono=100 AND okcuno=odcuno
WHERE odcono=100 AND okcucl BETWEEN '900' AND '910' AND SubStr(odprrf,0,1) IN ('6','7','4') AND odprrf NOT IN ('7C1','6R1','2A0')

union all

select DECODE(SubStr(odprrf,0,1),'2','1',SubStr(odprrf,0,1))||'00' AS division,
       'L1' AS customer1,
       'L2' /*okrasn*/ AS customer2,
       l3_code /*okcucl*/ AS customer3,
       odprrf AS pricelist_ref,
       oditno AS itemcode,
       odsapr AS price, 
       odfvdt as startdate,
       ojlvdt as enddate
from mvxjdta.oprbas, mvxjdta.mbmtrd, mvxjdta.oprich, ANAPLAN.AD_COSTCENTER_L3CODE
where odcono = 100 and 
      tdcono = odcono and tddivi IN ('100','300') and tdidtr = 440 and
      odcono = tdcono and odprrf = tdmbmd and
      ojcono = odcono and ojprrf = odprrf and ojcuno = odcuno and
      ojcmno = odcmno and ojcucd = odcucd and ojfvdt = odfvdt and
      ojfvdt >= 20230101 and ojcucd = 'EUR' and ojcuno = ' ' and
      division = DECODE(SubStr(odprrf,0,1),'2','1',SubStr(odprrf,0,1))||'00' and
      costcenter = tdmvxd;


  GRANT SELECT ON "ANAPLAN"."AD_PRICELIST_CUSTOMER" TO "LOTMAT";



--AD_PRICELIST_CUSTOMER_20240125

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_PRICELIST_CUSTOMER_20240125" ("DIVISION", "CUSTOMER1", "CUSTOMER2", "CUSTOMER3", "PRICELIST_REF", "ITEMCODE", "PRICE") AS 
  SELECT 
SubStr(odprrf,0,1)||'00' AS division,
odcuno AS customer1,
'L2' /*okrasn*/ AS customer2,
'L3' /*okcucl*/ AS customer3,
odprrf||'-'||odcuno AS pricelist_ref,
oditno AS itemcode,
odsapr AS price 

FROM mvxjdta.oprbas
inner join 
  (SELECT odprrf AS prrf,odcuno AS cuno,Max(odfvdt) AS fvdt,odcono AS cono 
    FROM mvxjdta.oprbas 
    WHERE odcuno!=' '  AND odlvdt>=To_Char(current_date,'YYYYMMDD') AND odfvdt<=To_Char(current_date,'YYYYMMDD') 
    GROUP BY odprrf,odcuno,odcono
  ) temp ON temp.cuno=odcuno AND temp.cono=odcono AND temp.prrf=odprrf AND odfvdt=temp.fvdt 
inner join mvxjdta.ocusma ON okcono=100 AND okcuno=odcuno
WHERE odcono=100 AND okcucl BETWEEN '900' AND '910' AND SubStr(odprrf,0,1) IN ('6','7','4') AND odprrf NOT IN ('7C1','6R1','2A0')

ORDER BY odcuno,SubStr(odprrf,0,1);


  GRANT SELECT ON "ANAPLAN"."AD_PRICELIST_CUSTOMER_20240125" TO "LOTMAT";
  
  
--AD_PRICELIST_CUSTOMER_NEW  
  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_PRICELIST_CUSTOMER_NEW" ("DIVISION", "CUSTOMER1", "CUSTOMER2", "CUSTOMER3", "PRICELIST_REF", "ITEMCODE", "PRICE", "STARTDATE", "ENDDATE") AS 
  SELECT 
SubStr(odprrf,0,1)||'00' AS division,
odcuno AS customer1,
'L2' /*okrasn*/ AS customer2,
'L3' /*okcucl*/ AS customer3,
odprrf||'-'||odcuno AS pricelist_ref,
oditno AS itemcode,
odsapr AS price,
20230101 as startdate,
20300629 as enddate

FROM mvxjdta.oprbas
inner join 
  (SELECT odprrf AS prrf,odcuno AS cuno,Max(odfvdt) AS fvdt,odcono AS cono 
    FROM mvxjdta.oprbas 
    WHERE odcuno!=' '  AND odlvdt>=To_Char(current_date,'YYYYMMDD') AND odfvdt<=To_Char(current_date,'YYYYMMDD') 
    GROUP BY odprrf,odcuno,odcono
  ) temp ON temp.cuno=odcuno AND temp.cono=odcono AND temp.prrf=odprrf AND odfvdt=temp.fvdt 
inner join mvxjdta.ocusma ON okcono=100 AND okcuno=odcuno
WHERE odcono=100 AND okcucl BETWEEN '900' AND '910' AND SubStr(odprrf,0,1) IN ('6','7','4') AND odprrf NOT IN ('7C1','6R1','2A0')

union all

select DECODE(SubStr(odprrf,0,1),'2','1',SubStr(odprrf,0,1))||'00' AS division,
       'L1' AS customer1,
       'L2' /*okrasn*/ AS customer2,
       l3_code /*okcucl*/ AS customer3,
       odprrf AS pricelist_ref,
       oditno AS itemcode,
       odsapr AS price, 
       odfvdt as startdate,
       ojlvdt as enddate
from mvxjdta.oprbas, mvxjdta.mbmtrd, mvxjdta.oprich, ANAPLAN.AD_COSTCENTER_L3CODE
where odcono = 100 and 
      tdcono = odcono and tddivi = '100' and tdidtr = 440 and
      odcono = tdcono and odprrf = tdmbmd and
      ojcono = odcono and ojprrf = odprrf and ojcuno = odcuno and
      ojcmno = odcmno and ojcucd = odcucd and ojfvdt = odfvdt and
      ojfvdt >= 20230101 and ojcucd = 'EUR' and ojcuno = ' ' and
      division = DECODE(SubStr(odprrf,0,1),'2','1',SubStr(odprrf,0,1))||'00' and
      costcenter = tdmvxd;


  GRANT SELECT ON "ANAPLAN"."AD_PRICELIST_CUSTOMER_NEW" TO "LOTMAT";


--AD_PURCHASE_AGREEMENT_PRICES

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_PURCHASE_AGREEMENT_PRICES" ("DIVISION", "ITEMCODE", "CURENCY", "PERIOD", "PRICE_BUM") AS 
  select DIVISION, ITEMCODE, CURENCY, PERIOD, MAX(BUM_Price) as Price_BUM

from 
    ( 
    Select CONO, ITEMCODE, ITEMDESCRIPTION, Price_UM, PUR_PRICE, BUM,
    case when MUDMCF = '1' then PUR_PRICE / MUCOFA else case when MUDMCF = '2' then PUR_PRICE * MUCOFA else PUR_PRICE end  end as BUM_Price,
    DIVISION, Supplier, IDSUNM as SupplierNm, CURENCY,
    to_char(to_date(VALID_FROM,'YYYYMMDD'),'YYYYMM') as  Valid_From,
    case when Valid_until = '99999999' then to_char(sysdate+580,'YYYYMM') else to_char(to_date(Valid_until,'YYYYMMDD'),'YYYYMM') end as Valid_Until
    
      FROM       (
                SELECT MMCONO as CONO, MMITNO as ItemCode, MMFUDS as ItemDescription, MMPPUN as Price_UM, MMUNMS as BUM,
                case when itemprice.ajOBV1 = mmitno then itemprice.MWFACI else case when prgroupprice.ajOBV1 = MMPRGP then prgroupprice.MWFACI else case when groupprice.ajOBV1 = MMITGR then groupprice.MWFACI else M9FACI end end end as Division,
                case when itemprice.ajOBV1 = mmitno then itemprice.AJSUNO else case when prgroupprice.ajOBV1 = MMPRGP then prgroupprice.AJSUNO else case when groupprice.ajOBV1 = MMITGR then groupprice.AJSUNO else M9FACI end end end as Supplier, 
                case when itemprice.ajOBV1 = mmitno then itemprice.AIFVDT else case when prgroupprice.ajOBV1 = MMPRGP then prgroupprice.AIFVDT else groupprice.AIFVDT end end as Valid_from, 
                case when itemprice.ajOBV1 = mmitno then itemprice.AIUVDT else case when prgroupprice.ajOBV1 = MMPRGP then prgroupprice.AIUVDT else groupprice.AIUVDT end end as Valid_until, 
                case when itemprice.ajOBV1 = mmitno then itemprice.AJPUPR else case when prgroupprice.ajOBV1 = MMPRGP then prgroupprice.AJPUPR else groupprice.AJPUPR end end as Pur_Price,
                case when itemprice.ajOBV1 = mmitno then itemprice.AHCUCD else case when prgroupprice.ajOBV1 = MMPRGP then prgroupprice.AHCUCD else groupprice.AHCUCD end end as Curency
                
                FROM mvxjdta.MITMAS
                
                LEFT Join (
                SELECT AJCONO, AJSUNO, AJOBV1, AIFVDT, AiUVDT, AHCUCD, AJPUPR, MWFACI
                FROM mvxjdta.MPAGRP 
                Left join mvxjdta.MPAGRL
                on AICONO = AJCONO and AIOBV1 = AJOBV1 and AJSUNO = AISUNO and AJSEQN = AISEQN and AjAGNB = AIAGNB
                left join mvxjdta.MPAGRH
                ON MPAGRL.AICONO = MPAGRH.AHCONO and MPAGRL.AIAGNB = MPAGRH.AHAGNB and AHSUNO=AISUNO
                Left join mvxjdta.MITWHL on MWCONO=AHCONO and MWWHLO=AHWHLO 
                
                where AIUVDT > to_char(sysdate, 'YYYYMMDD') and AISAGL != '90' and AHPAST = '40' and ajmapr = '1' and AJPUPR > 0 and AJSUNO not in ('9900001', '9900002', '9900004','9900005', '9900006', '9900007', '9900009', '9900010', '9900011','9900069', '9900616', '9001049')
                Order by  AJOBV1 desc, AiUVDT, AJSUNO, AHCUCD, AHWHLO 
                            ) itemprice
                
                ON itemprice.AJCONO = mmcono and itemprice.ajOBV1 = mmitno 
                
                LEFT Join (
                SELECT AJCONO, AJSUNO, AJOBV1, AIFVDT, AiUVDT, AHCUCD, AJPUPR, MWFACI
                FROM mvxjdta.MPAGRP 
                Left join mvxjdta.MPAGRL
                on AIcono = AJcono and  AIOBV1 = AJOBV1 and AJSUNO = AISUNO and AJSEQN = AISEQN and AjAGNB = AIAGNB
                left join mvxjdta.MPAGRH
                ON AHcono=AIcono and MPAGRL.AIAGNB = MPAGRH.AHAGNB and AHSUNO=AISUNO
                Left join mvxjdta.MITWHL on MWWHLO=AHWHLO
                
                where AIUVDT > to_char(sysdate, 'YYYYMMDD') and AISAGL != '90' and AHPAST = '40' and ajmapr = '1' and AJPUPR > 0 and AJSUNO not in ('9900001', '9900002', '9900004','9900005', '9900006', '9900007', '9900009', '9900010', '9900011','9900069', '9900616', '9001049')
                Order by  AJOBV1 desc, AiUVDT, AJSUNO, AHCUCD, AHWHLO  
                            ) prgroupprice
                ON prgroupprice.ajcono = mmcono and prgroupprice.ajOBV1 = MMPRGP
                
                         
                LEFT Join (
                SELECT AJCONO, AJSUNO, AJOBV1, AIFVDT, AiUVDT, AHCUCD, AJPUPR, MWFACI
                FROM mvxjdta.MPAGRP 
                Left join mvxjdta.MPAGRL
                on AIcono = AJcono and  AIOBV1 = AJOBV1 and AJSUNO = AISUNO and AJSEQN = AISEQN and AjAGNB = AIAGNB
                left join mvxjdta.MPAGRH
                ON AHcono=AIcono and MPAGRL.AIAGNB = MPAGRH.AHAGNB and AHSUNO=AISUNO
                Left join mvxjdta.MITWHL on MWWHLO=AHWHLO
                
                where AIUVDT > to_char(sysdate, 'YYYYMMDD') and AISAGL != '90' and AHPAST = '40' and ajmapr = '1' and AJPUPR > 0 and AJSUNO not in ('9900001', '9900002', '9900004','9900005', '9900006', '9900007', '9900009', '9900010', '9900011','9900069', '9900616', '9001049')
                Order by  AJOBV1 desc, AiUVDT, AJSUNO, AHCUCD, AHWHLO  
                            ) groupprice
                ON groupprice.ajcono = mmcono and groupprice.ajOBV1 = MMITGR
                
                Left join mvxjdta.MITFAC on M9ITNO=mmitno
                                           
                where MMITTY in ('20', '30', '85')
                
                Order by MMITNO
            )
left join mvxjdta.CIDMAS
on cono=iDcono and Supplier=IDSUNO

left join mvxjdta.MITAUN
on cono=MUcono and MUAUTP = '2' and ITEMCODE = MUITNO and PRICE_UM = MUALUN

where pur_price > '0'
Order by supplier, itemcode, division

) tabl

left join (
SELECT
to_char( add_months ( sysdate, level - 1), 'YYYYMM') as Period
from  dual  
connect by level <= months_between (sysdate+580, sysdate) + 1
) DB_4PERIOD on DB_4PERIOD.period between tabl.Valid_From and tabl.Valid_Until

WHERE cono = '100' and division not in ('800','400')
group by division, itemcode, CURENCY, period
UNION ALL
SELECT "DIVISION","ITEMCODE","CURENCY","PERIOD","PRICE_BUM" FROM ANAPLAN.AD_PURCHASE_AGREEMENT_PRICES@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "DIVISION","ITEMCODE","CURENCY","PERIOD","PRICE_BUM" FROM M3SKY_ANAPLAN.AD_PURCHASE_AGREEMENT_PRICES WHERE DIVISION IN ('400');


  GRANT SELECT ON "ANAPLAN"."AD_PURCHASE_AGREEMENT_PRICES" TO "LOTMAT";


--AD_SALES_CHECK_CUSTOMER

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_SALES_CHECK_CUSTOMER" ("CUSTOMERCODE", "SALESVOLUME") AS 
  SELECT customercode,Sum(volume) AS salesvolume
FROM anaplan.td_sales_sum_full
WHERE period BETWEEN To_Char(Add_Months(SYSDATE,-24),'YYYY')||'01' AND  To_Char(SYSDATE,'YYYYMM')
GROUP BY customercode
HAVING Sum(volume)<>0;


  GRANT SELECT ON "ANAPLAN"."AD_SALES_CHECK_CUSTOMER" TO "LOTMAT";


--AD_SALES_CHECK_ITEM

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."AD_SALES_CHECK_ITEM" ("ITEMCODE", "SALESVOLUME") AS 
  SELECT itemcode,Sum(volume) as salesvolume
FROM anaplan.td_sales_sum_full
WHERE period BETWEEN To_Char(Add_Months(SYSDATE,-24),'YYYY')||'01' AND  To_Char(SYSDATE,'YYYYMM')
GROUP BY itemcode;


  GRANT SELECT ON "ANAPLAN"."AD_SALES_CHECK_ITEM" TO "LOTMAT";



--TD_ACCOUNT_MOVEMENTS

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_ACCOUNT_MOVEMENTS" ("PERIOD", "DIVISION", "ACCOUNT_CODE", "DIM3_CODE", "COUNTERPART_CODE", "AMOUNT_LOC") AS 
  select  acperi AS PERIOD,
        divi as DIVISION,
        ait1 AS ACCOUNT_CODE,
        SUBSTR(ait3,1,3) as DIM3_CODE,
        ait4 as COUNTERPART_CODE,
        sum(acam) as AMOUNT_LOC
from 
(select * from bousr.fpm_gl2_hst union all select * from bousr.fpm_gl2_extra) a
    inner join 
    (select distinct SUBSTR(eaaitm,1,3) as DIM3 from  mvxjdta.FCHACC where eacono=100 and eadivi=' ' and eaaitp=3 AND EAAITM BETWEEN 'A' AND 'Z') mov
    on DIM3=SUBSTR(ait3,1,3) 
where ait1 between '1000000' and '5999999' and divi not in ('800','400')
and acperi>='202201'
group by acperi,divi,ait1,SUBSTR(ait3,1,3),ait4

union all
select "PERIOD","DIVISION","ACCOUNT_CODE","DIM3_CODE","COUNTERPART_CODE","AMOUNT_LOC" from ANAPLAN.TD_ACCOUNT_MOVEMENTS@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
union all
select "PERIOD","DIVISION","ACCOUNT_CODE","DIM3_CODE","COUNTERPART_CODE","AMOUNT_LOC" from M3SKY_ANAPLAN.TD_ACCOUNT_MOVEMENTS WHERE DIVISION = '400'

--select  acperi AS PERIOD,
--        divi as DIVISION,
--        ait1 AS ACCOUNT_CODE,
--        case when SUBSTR(ait1,-1)='9' then ait5 else ait4 end as DIM3_CODE,
--        case when SUBSTR(ait1,-1)='9' then ait4 else null end as COUNTERPART_CODE,
--        sum(acam) as AMOUNT_LOC 
--from 
--(select * from bousr.fpm_gl2_hst union all select * from bousr.fpm_gl2_extra) a
--    inner join 
--       (select distinct SUBSTR(eaaitm,1,3) as DIM3 from  mvxjdta.FCHACC where eacono=100 and eadivi=' ' and eaaitp=3 AND EAAITM BETWEEN 'A' AND 'Z') mov
--    on DIM3=(case when SUBSTR(ait1,-1)='9' then ait5 else ait4 end )
--where ait1 between '1000000' and '5999999' and divi='800'
--and acperi>='202201' 
--group by acperi, divi,ait1,case when SUBSTR(ait1,-1)='9' then ait5 else ait4 end,ait4;


  GRANT SELECT ON "ANAPLAN"."TD_ACCOUNT_MOVEMENTS" TO "LOTMAT";



--TD_ACTUAL_MO_TIME

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_ACTUAL_MO_TIME" ("DIVISION", "WORKCENTER", "ITEMCODE", "PERIOD", "TOTAL_MACHINE_TIME", "TOTAL_LABOR_TIME") AS 
  select DIVI as DIVISION, 
DIVI||'_'||PRODUCTION_LINE as WORKCENTER, 
PRODUCT as ITEMCODE, 
SubStr(TRDT,0,6) AS PERIOD, 
SUM(MACHINE_TIME+MACHINE_STUP_TIME) AS TOTAL_MACHINE_TIME, 
SUM(LABOR_TIME+LABOR_SETUP_TIME) AS TOTAL_LABOR_TIME 

from (
    select DHFACI as DIVI, DHMFNO, DHPRNO as Product, DHANBR, DHMAQT, DHTRDT as TRDT, DHPLGR as production_line, DHUPIT as machine_time, DHUMAT as labor_time, DHUSET as machine_stup_time, DHUMAS as labor_setup_time
    from mvxjdta.MWOPTS
    where DHCONO=100 and DHFACI not in ('800','400') and DHTRDT >= 20220101
    
    union all
    
    select DHFACI as DIVI, DHMFNO, DHPRNO as Product, DHANBR, DHMAQT, DHTRDT as TRDT, DHPLGR as production_line, DHUPIT as machine_time, DHUMAT as labor_time, DHUSET as machine_stup_time, DHUMAS as labor_setup_time
    from mvxjdta.MWOPTS@LBM3PRD1_ANAPLAN
    where DHCONO=100 and DHFACI='800' and DHTRDT >= 20220101

)
group by DIVI,PRODUCTION_LINE,PRODUCT,SubStr(TRDT,0,6)
UNION ALL
    select "DIVISION","WORKCENTER","ITEMCODE","PERIOD","TOTAL_MACHINE_TIME","TOTAL_LABOR_TIME" 
    from m3sky_anaplan.td_actual_mo_time;


  GRANT SELECT ON "ANAPLAN"."TD_ACTUAL_MO_TIME" TO "LOTMAT";


--TD_CAMPAIGNS


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_CAMPAIGNS" ("DIVISION", "L1_REGION", "MONTH", "CHAIN", "ITEMCODE", "SELLING_IN_FROM", "CAMPAIGN_TIME_TO", "WEEK", "CAMPAIGN_LTR") AS 
  SELECT '200' AS division, '200_DOMESTIC' as L1_REGION, period as MONTH, chain, item as itemcode, selling_in_from, campaign_time_to, to_char(to_date(selling_in_from,'YYYYMMDD'),'IYYYIW')  as week, sum(campaign_volume) as CAMPAIGN_LTR 
FROM alc.campinfo200  WHERE campaign_time_to>=20230401 AND Confirmed IN ('Yes','Bron')
group by period,chain,item,selling_in_from, campaign_time_to

--UNION ALL
--
--SELECT '400' AS division, '400_DOMESTIC' as L1_REGION, period as MONTH, chain, item as itemcode, selling_in_from, campaign_time_to,  to_char(to_date(selling_in_from,'YYYYMMDD'),'IYYYIW')  as week, sum(campaign_volume*mmvol3) as CAMPAIGN_LTR 
--FROM vf.campinfo200 left join mvxjdta.mitmas on item=mmitno and mmcono=100 WHERE campaign_time_to>=20230401 and confirmed='Yes'
--group by period,chain,item,selling_in_from, campaign_time_to

UNION ALL

SELECT '600' AS division, '600_DOMESTIC' as L1_REGION, To_Char(pp.A02_campaign_begin,'YYYYMM') AS MONTH, okcfc1 AS chain, dd.A02_prod_id AS itemcode, to_NUMBER(To_Char(pp.A02_supply_begin,'YYYYMMDD')) AS selling_in_from, To_Number(To_Char(pp.A02_campaign_end,'YYYYMMDD')) AS campaign_time_to, To_Char(pw.A02_WEEK_START_DATE,'YYYYMMDD') as week, sum(pw.A02_plan_liter) AS CAMPAIGN_LTR 
FROM VE.a02v_campaign_plan_h hh 
inner JOIN VE.a02_campaign_plan_d dd on  dd.a02_plan_id=hh.plan_id 
left join VE.a02_campaign_planned pp on pp.a02_plan_id=dd.a02_plan_id and pp.a02_prod_id=dd.a02_prod_id
left join (select A02_PLAN_ID,A02_PROD_ID,A02_WEEK_START_DATE, sum(A02_PLAN_LITER) A02_PLAN_LITER
                              from VE.A02_CAMPAIGN_PLANNED_W 
                              group by A02_PLAN_ID,A02_PROD_ID,A02_WEEK_START_DATE
                              having sum(A02_PLAN_LITER)>=1) pw on pw.A02_PLAN_ID=pp.A02_PLAN_ID and  pw.A02_PROD_ID=pp.A02_PROD_ID
left JOIN mvxjdta.ocusma ok ON ok.okcuno=hh.customer_id
WHERE pw.A02_plan_liter IS NOT NULL AND pp.A02_status in ('GOING')
group by pp.A02_campaign_begin, okcfc1,dd.A02_prod_id,pp.A02_supply_begin,pp.A02_campaign_end,pw.A02_WEEK_START_DATE

union all 

select '700' AS division, '700_DOMESTIC' as L1_REGION, To_CHAR(round(cowest/100,0)) AS MONTH, cochain as chain, coitno AS itemcode, to_number(cofrdt) AS selling_in_from, To_Number(cotodt) AS campaign_time_to, to_char(to_date(cowest,'YYYYMMDD'),'IYYYIW') as week, round(sum(covol3)) AS CAMPAIGN_LTR
from CESU.CAMPINFO200 where costatus <> 9
group by cowest,cochain,coitno,cofrdt, cotodt,cowest

UNION ALL

select division, L1_REGION, MONTH, chain, itemcode, selling_in_from, campaign_time_to, week, CAMPAIGN_LTR
from M3SKY_ANAPLAN.td_campaigns where division = '400';


--TD_CAPEX

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_CAPEX" ("DIVISION", "PERIOD", "ACCOUNT_CODE", "INVESTMENT_CODE", "AMOUNT_LOC") AS 
  SELECT
    division,
    period,
    account_code,
    investment_code,
    SUM(egacam) AS amount_loc
FROM (
    SELECT
        CAST(egdivi AS VARCHAR(10)) AS division,
        CAST(SUBSTR(egacdt, 0, 6) AS VARCHAR(10)) AS period,
        CAST(egait1 AS VARCHAR(30)) AS account_code,
        CAST(CASE  WHEN egacdt < 20260101 THEN egait5 
                   WHEN egdivi = '100' THEN egait5 --Olvi and Servaali will continue to have in DIM5, others change to DIM6
                   WHEN egdivi = '300' THEN egait5  --Olvi and Servaali will continue to have in DIM5, others change to DIM6
               ELSE egait6 END AS VARCHAR(30)) AS investment_code,
        egacam
    FROM
        mvxjdta.fgledg
    WHERE
        egcono = 100
        AND egait1 BETWEEN '1000000' AND '1399999'  -- Only investment balance sheet accounts
        AND CASE
            WHEN egdivi = '800' THEN egait4 -- Lidskoe Pivo has movement code in Dim4
            ELSE egait3
        END LIKE 'FAC%' -- FAC movement -> Increase/Purchase in Anaplan
        /*AND CASE
            WHEN (egdivi = '600' AND egacqt = 1) THEN 0
            ELSE 1
        END = 1 -- Excluding Volfas negative bookings*/ -- ML this might need tweaking
)
WHERE
   investment_code <> ' ' -- No empty investment codes
   AND period BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE, -3), 'YYYYMM') AND TO_CHAR(SYSDATE, 'YYYYMM') AND -- Previous and current periods only
   division not in ('800','400')
GROUP BY
    division,
    period,
    account_code,
    investment_code
HAVING
    SUM(egacam) <> 0 -- No 0 amounts


UNION ALL

SELECT "DIVISION","PERIOD","ACCOUNT_CODE","INVESTMENT_CODE","AMOUNT_LOC" FROM ANAPLAN.TD_CAPEX@LBM3PRD1_ANAPLAN WHERE "DIVISION" = '800'
UNION ALL

SELECT "DIVISION","PERIOD","ACCOUNT_CODE","INVESTMENT_CODE","AMOUNT_LOC" FROM M3SKY_ANAPLAN.TD_CAPEX WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."TD_CAPEX" TO "BOUSR";
  
  

--TD_COGS_LATESTCOST

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_COGS_LATESTCOST" ("DIVI", "PRODUCT", "COSTCOMPONENT", "EURPERL") AS 
  select 
        divi
        ,product
        ,costcomponent
        ,round(sum(eurl),4) as EurperL
from BOUSR.M_DETAILED_COSTING_HST where period='NOW' and costcomponent not in ('A03B','A03T') and
     divi not in ('400')
--and divi='600' and product='6100131'
group by divi,product,costcomponent
union all
select divi, product, costcomponent, EurperL from m3sky_anaplan.TD_COGS_LATESTCOST where divi = '400';


  GRANT SELECT ON "ANAPLAN"."TD_COGS_LATESTCOST" TO "LOTMAT";
  


--TD_COGS_OH_COSTING

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_COGS_OH_COSTING" ("COSTINGTYPE", "DIVISION", "ITEM_CODE", "COSTING_DATE", "COMPONENT", "RATE") AS 
  select case when costing_type='8' then 'BUD' else 'ACT' end as CostingType,DIVISION,ITEM_CODE,COSTING_DATE,COMPONENT,
case when mmvol3=0 then RATE else round(RATE/mmvol3,4) end as RATE 
from (select 
                kpfaci as division,
                kpitno as item_code,
                kppcdt as costing_date,
                kppctp as costing_type,
                kpcb02,kpcb03,kpcb04,kpcb05,kpcb06,kpcb07,kpcb08,kpce01,kpce02,kpce03,kpce04,kpce05,kpce06,kpce07,kpce08
                from mvxjdta.mccoma
                where kpcono=100 and  kpstrt='100' and ((kppctp=8 and kppcdt >20230901)  or (kppctp=3 and SubStr(kppcdt,0,6)>=to_char(sysdate-1, 'YYYYMM')))
              
            ) a
    unpivot  (
        rate
        for Component
        in (
            kpcb02 as 'B02',
            kpcb03 as 'B03',
            kpcb04 as 'B04',
            kpcb05 as 'B05',
            kpcb06 as 'B06',
            kpcb07 as 'B07',
            kpcb08 as 'B08',
            kpce01 as 'E01',
            kpce02 as 'E02',
            kpce03 as 'E03',
            kpce04 as 'E04',
            kpce05 as 'E05',
            kpce06 as 'E06',
            kpce07 as 'E07',
            kpce08 as 'E08'
        ))
       inner join mvxjdta.mitmas on mmitno=item_code 
        where rate<>0 AND DIVISION not in ('800','400')
UNION ALL
SELECT "COSTINGTYPE","DIVISION","ITEM_CODE","COSTING_DATE","COMPONENT","RATE" FROM ANAPLAN.TD_COGS_OH_COSTING@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "COSTINGTYPE","DIVISION","ITEM_CODE","COSTING_DATE","COMPONENT","RATE" FROM M3SKY_ANAPLAN.TD_COGS_OH_COSTING WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."TD_COGS_OH_COSTING" TO "LOTMAT";


--TD_COGS_OPERATIONS

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_COGS_OPERATIONS" ("DIVISION", "PRODUCT_CODE", "WC_CODE", "FILL_MH_1000L", "FILL_LH_1000L", "SETUP_MH_1000L", "SETUP_LH_1000L", "ORDERQTY_L", "SETUP_TIME", "SETUP_PEOPLE") AS 
  SELECT
    division,
    product as Product_code,
    productionline AS  WC_code,
    fill_mh_1000l,
    fill_lh_1000l,
    setup_mh_1000l,
    setup_lh_1000l,
    orderqty_l,
    setup_time,
    setup_people
FROM
    bousr.bi_cogs_operations_v op
WHERE DIVISION not in ('800','400')
UNION ALL
SELECT "DIVISION","PRODUCT_CODE","WC_CODE","FILL_MH_1000L","FILL_LH_1000L","SETUP_MH_1000L","SETUP_LH_1000L","ORDERQTY_L","SETUP_TIME","SETUP_PEOPLE" FROM ANAPLAN.TD_COGS_OPERATIONS@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "DIVISION","PRODUCT_CODE","WC_CODE","FILL_MH_1000L","FILL_LH_1000L","SETUP_MH_1000L","SETUP_LH_1000L","ORDERQTY_L","SETUP_TIME","SETUP_PEOPLE" FROM M3SKY_ANAPLAN.TD_COGS_OPERATIONS WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."TD_COGS_OPERATIONS" TO "LOTMAT";



--TD_COGS_RECIPE

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_COGS_RECIPE" ("TYPE", "DIVISION", "PRODUCTCODE", "MATERIALCODE", "QTY1000L") AS 
  SELECT 
'100' as Type,
CAST((rcp."DIVI") AS VARCHAR(10)) AS division,
CAST((rcp."PRODUCT") AS VARCHAR(108)) AS productcode,
CAST((rcp."MATERIAL") AS VARCHAR(108)) AS materialcode
,case when m1. mmitty in ('10') then rcp.QTY1000 else round(rcp.QTY1000/p1.mmvol3,6) end AS qty1000L
 FROM
(
--

SELECT
pmcono AS cono, pmfaci AS divi,
root_id AS product, pmmtno AS material, Sum(FULL_QTY*1000) AS qty1000
FROM bousr.bi_full_receipe_v
inner join mvxjdta.mitfac mf ON mf.m9cono=pmcono AND mf.m9faci=pmfaci AND mf.m9itno=root_id
WHERE mf.m9vamt='1'
GROUP BY pmcono,pmfaci,root_id, pmmtno


UNION ALL

--2)ready products with purchased products in their recipe:
SELECT p1.mmcono AS cono, f1.m9faci AS divi, p1.mmitno AS product, m1.mmitno AS material, Round(1000*r1.pmcnqt,6) AS qty1000
FROM mvxjdta.mitmas p1
inner join mvxjdta.mitfac f1 ON f1.m9cono=p1.mmcono AND f1.m9itno=p1.mmitno
left JOIN mvxjdta.mpdmat r1 ON p1.mmcono=r1.pmcono AND f1.m9faci=r1.pmfaci AND r1.pmprno=p1.mmitno AND r1.pmstrt='100'
left join mvxjdta.mitmas m1 ON m1.mmcono=r1.pmcono AND m1.mmitno=r1.pmmtno and m1.mmitty!='90'
left join mvxjdta.mitfac f2 ON f2.m9cono=m1.mmcono AND f2.m9itno=m1.mmitno AND f2.m9faci=f1.m9faci
left join mvxjdta.mpdhed h2 ON h2.phcono=m1.mmcono AND h2.phprno=m1.mmitno AND h2.phfaci=f2.m9faci AND h2.phstrt='100' AND h2.phstat<='20'
left join mvxjdta.mpdmat r2 ON h2.phcono=r2.pmcono AND h2.phprno=r2.pmmtno AND h2.phstrt=r2.pmstrt
WHERE
p1.mmitty='10' AND f1.m9vamt='1' AND f2.m9vamt='2' AND m1.mmitty in ('10','40')  AND p1.mmstat<='50' AND m1.mmstat<='50' AND r2.pmmtno IS NULL
--ORDER BY cono, divi, product,material
UNION ALL

--3) purchased ITEMS without recipe:
SELECT mmcono AS cono, m9faci AS divi, mmitno AS product, mmitno AS material, Round(1000,6) AS qty1000
FROM mvxjdta.mitmas
inner join mvxjdta.mitfac ON m9cono=mmcono AND m9itno=mmitno
left JOIN mvxjdta.mpdmat ON mmcono=pmcono AND pmprno=mmitno AND pmfaci=m9faci AND pmstrt='100'
WHERE mmitty='10' AND m9vamt='2' AND mmvol3!=0 AND mmstat<='50'
AND (pmmtno IS null or m9faci in ('300','600'))
-- AND (CASE WHEN MMPROD='9900069' THEN 1 WHEN pmmtno IS NULL THEN 1 ELSE 0 END)=1

ORDER BY cono, divi,product, material

) rcp inner join mvxjdta.mitmas p1 ON p1.mmitno=rcp.product
inner join mvxjdta.mitmas m1 ON m1.mmitno=rcp.material and m1.mmitty!='90'
WHERE p1.mmstat<='50'  AND p1.mmitty IN ('10','40') and (p1.mmitno=p1.mmgrti or substr(p1.mmitno,0,1)='1' OR SubStr(p1.mmitno,0,1)='6' OR SubStr(p1.mmitno,0,1)='8'  OR SubStr(p1.mmitno,0,1)='3')  --changed from status 20 to 50 at 10.01.24 due to missing recipes 
AND rcp."DIVI" not in ('800','400') 

UNION ALL
SELECT "TYPE","DIVISION","PRODUCTCODE","MATERIALCODE","QTY1000L" FROM ANAPLAN.TD_COGS_RECIPE@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "TYPE","DIVISION","PRODUCTCODE","MATERIALCODE","QTY1000L" FROM M3SKY_ANAPLAN.TD_COGS_RECIPE WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."TD_COGS_RECIPE" TO "LOTMAT";


--TD_DELIVERY

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_DELIVERY" ("DIVISION", "PERIOD", "L1_REGION", "L2_SALESCHANNEL", "L3_CUSTOMERGROUP", "L4_CHAIN", "CUSTOMERCODE", "VOLUME", "DELIVERY", "EXT_M1", "EXT_M2", "EXT_M3", "ATTR1", "ATTR2", "ATTR3") AS 
  SELECT
CAST((dta.divi) AS VARCHAR(108)) AS division,
CAST((dta.period) AS VARCHAR(108)) AS period,
CAST((cu.division||'-'||cu.l1_region) AS VARCHAR(108)) AS L1_region,
CAST((cu.division||'-'||cu.l2_saleschannel) AS VARCHAR(108)) AS L2_saleschannel,
CAST((cu.division||'-'||cu.l2_saleschannel||'-'||cu.l3_code) AS VARCHAR(108)) AS L3_customergroup,
CAST((cu.division||'-'||cu.l2_saleschannel||'-'||cu.l3_code||'-'||cu.l4_code) AS VARCHAR(108)) AS L4_chain,
CAST((cu.division||'-'||cu.l2_saleschannel||'-'||cu.l3_code||'-'||cu.l4_code||CASE WHEN cu.l5_code=cu.l4_code THEN '' ELSE '-'||cu.l5_code END||'-'||cu.l6_code) AS VARCHAR(108)) AS customercode,
Round(Sum(dta.volume),4) AS volume,
Round(Sum(dta.delivery),4) AS delivery,
CAST((0) AS NUMBER ) AS ext_m1,
CAST((0) AS NUMBER ) AS ext_m2,
CAST((0) AS NUMBER ) AS ext_m3,
CAST(null AS varchar(108) ) AS attr1,
CAST(null AS varchar(108) ) AS attr2,
CAST(null AS varchar(108) ) AS attr3

FROM

(
--BI_SALES from OSBSTD, aggregated to month (pure M3):

SELECT divi,
To_Char(period) AS period,
customercode,
Sum(md.volume) AS volume,
0 AS delivery
FROM bousr.prep_monthlysales md
inner JOIN bousr.bi_ordertypes_v ot ON ot.division=md.divi AND ot.ordertype=md.ordertype
WHERE  md.period >= '202101'    AND ot.ordertypegroup='NORMAL' --AND DIVI <> '800'

GROUP BY divi, period,customercode


UNION ALL

--delivery allocated to customer :

SELECT dedivi AS divi,
To_Char(deperi) AS period,
CASE WHEN decuno IS NULL THEN depyno ELSE decuno END AS customercode,
0 AS volume,
Sum(dedeam) AS delivery
FROM bousr.prep_salesdelivery
WHERE deperi >= '202101' --AND DEDIVI <> '800'
GROUP BY deperi,dedivi,
CASE WHEN decuno IS NULL THEN depyno ELSE decuno END
) dta

LEFT JOIN ANAPLAN.MD_CUSTOMER_DETAIL_T cu ON cu.m3customercode=dta.customercode

GROUP BY
cu.division,l1_region,cu.l2_saleschannel,cu.l3_code,cu.l4_code,CASE WHEN cu.l5_code=cu.l4_code THEN '' ELSE '-'||cu.l5_code END,cu.l6_code,
dta.divi,dta.period
--UNION ALL
--SELECT "DIVISION","PERIOD","L1_REGION","L2_SALESCHANNEL","L3_CUSTOMERGROUP","L4_CHAIN","CUSTOMERCODE","VOLUME","DELIVERY","EXT_M1","EXT_M2","EXT_M3","ATTR1","ATTR2","ATTR3" FROM ANAPLAN.TD_DELIVERY@LBM3PRD1_ANAPLAN WHERE DIVISION = '800';


  GRANT SELECT ON "ANAPLAN"."TD_DELIVERY" TO "LOTMAT";


--TD_DEPRECIATION_PLAN


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_DEPRECIATION_PLAN" ("DIVISION", "PERIOD", "FA_TYPEID", "FA_TYPE", "COSTCENTER", "AMOUNT", "EXT_M1", "EXT_M2", "EXT_M3", "ATTR1", "ATTR2", "ATTR3") AS 
  select 
CAST((Division) AS VARCHAR(108))          AS Division,
CAST((Period) AS VARCHAR(108))            AS Period,
CAST((FA_TypeID) AS VARCHAR(108))         AS FA_TypeID,
CAST((FA_Type) AS VARCHAR(108))           AS FA_Type,
CAST((CostCenter) AS VARCHAR(108))        AS CostCenter,
Round(sum(Amount),2)                      AS Amount,
CAST((0) AS NUMBER ) AS ext_m1,
CAST((0) AS NUMBER ) AS ext_m2,
CAST((0) AS NUMBER ) AS ext_m3,
CAST(null AS varchar(108) ) AS attr1,
CAST(null AS varchar(108) ) AS attr2,
CAST(null AS varchar(108) ) AS attr3
from bousr.BI_FIXED_ASSET_V
where TransactionID in ('30') and DeprMethod<>'Not depreciated' and Status='Normal'
and period>='202301' and division not in ('400')
group by Division, CostCenter, Period, FA_TypeID, FA_Type
union all
select division, period, fa_typeid, fa_type, costcenter, amount, ext_m1, ext_m2, ext_m3, attr1, attr2, attr3 from m3sky_anaplan.TD_DEPRECIATION_PLAN;


  GRANT SELECT ON "ANAPLAN"."TD_DEPRECIATION_PLAN" TO "LOTMAT";



--TD_GL_SUM

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_GL_SUM" ("DIVISION", "PERIOD", "ACCOUNT_CODE", "COSTCENTER_CODE", "AMOUNT_LOC", "DIM3_CODE", "COUNTERPART_CODE", "AD_DIM1", "AD_DIM2", "AD_DIM3") AS 
  SELECT "DIVISION","PERIOD","ACCOUNT_CODE","COSTCENTER_CODE","AMOUNT_LOC","DIM3_CODE","COUNTERPART_CODE","AD_DIM1","AD_DIM2","AD_DIM3" 
FROM anaplan.TD_GL_SUM_FULL 
WHERE period between to_char(add_months(sysdate,-2), 'YYYYMM') and to_char(sysdate, 'YYYYMM')

--UNION ALL
--SELECT "DIVISION","PERIOD","ACCOUNT_CODE","COSTCENTER_CODE","AMOUNT_LOC","DIM3_CODE","COUNTERPART_CODE","AD_DIM1","AD_DIM2","AD_DIM3" FROM M3SKY_ANAPLAN.TD_GL_SUM;


  GRANT SELECT ON "ANAPLAN"."TD_GL_SUM" TO "LOTMAT";

--TD_GL_SUM_BACKUP_20220616


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_GL_SUM_BACKUP_20220616" ("DIVISION", "PERIOD", "ACCOUNT_CODE", "COSTCENTER_CODE", "AMOUNT_LOC", "DIM3_CODE", "COUNTERPART_CODE", "AD_DIM1", "AD_DIM2", "AD_DIM3") AS 
  SELECT division,period,account_code,costcenter_code,Sum(amount_loc) AS amount_loc,dim3_code,counterpart_code,ad_dim1, ad_dim2,ad_dim3 
FROM
(
SELECT 

CAST((divi) AS VARCHAR(10)) AS division, 
CAST((acperi) AS VARCHAR(10)) AS period,
CAST((ait1) AS VARCHAR(30) ) AS account_code,
CAST((ait2) AS VARCHAR(30) ) AS costcenter_code,
acam AS amount_loc,
CAST((ait3) AS VARCHAR(30) ) AS dim3_code,
CAST((ait4) AS VARCHAR(30) ) AS counterpart_code,
CAST((' ') AS VARCHAR(30) ) AS ad_dim1,
CAST((' ') AS VARCHAR(30) ) AS ad_dim2,
CAST((' ') AS VARCHAR(30) ) AS ad_dim3
FROM bousr.fpm_gl2_hst 
WHERE datatype='ACT'
AND acperi>='202001' AND ait1 BETWEEN '8000000' AND '9999998'
)
GROUP BY division,period,account_code,costcenter_code,dim3_code,counterpart_code,ad_dim1, ad_dim2,ad_dim3

UNION ALL

--BS accounts (cumulative):
SELECT  
CAST((divi) AS VARCHAR(10)) AS division, 
CAST((period) AS VARCHAR(10)) AS period,
CAST((ait1) AS VARCHAR(30) ) AS account_code,
CAST(('BS999') AS VARCHAR(30) ) AS costcenter_code,

cumul AS amount_loc,

CAST((ait3) AS VARCHAR(30) ) AS dim3_code,
CAST((ait4) AS VARCHAR(30) ) AS counterpart_code,
CAST((' ') AS VARCHAR(30) ) AS ad_dim1,
CAST((' ') AS VARCHAR(30) ) AS ad_dim2,
CAST((' ') AS VARCHAR(30) ) AS ad_dim3
FROM 

(
    SELECT f.*,Decode(dta.acam,NULL,0,dta.acam) AS periodsum,
    Sum(Decode(dta.acam,NULL,0,dta.acam))  over (PARTITION BY f.divi, f.ait1,f.ait3, f.ait4 ORDER BY f.period RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumul
    FROM 
    (
          SELECT ac.divi, per.period,ac.ait1,ac.ait3, ac.ait4
          FROM
          (
            SELECT divi,ait1, ait3, CASE WHEN AIT1 LIKE '%9' THEN AIT4 ELSE ' ' END AS AIT4 
            FROM bousr.fpm_gl2_hst 
            WHERE datatype='ACT' AND AIT1 BETWEEN '1000000' AND '7999999'
            GROUP BY divi, ait1, ait3,CASE WHEN AIT1 LIKE '%9' THEN AIT4 ELSE ' ' END  
            HAVING(Count(1))>0
          ) ac
          right outer join (SELECT DISTINCT SubStr(cdymd8,0,6) AS period  FROM mvxjdta.csycal WHERE  SubStr(cdymd8,0,6) BETWEEN '201712' AND To_Char(SYSDATE,'YYYYMM') ORDER BY period) per ON 1=1
    ) f
    left join 
    (
      SELECT DIVI, AIT1, AIT3,ACPERI,CASE WHEN AIT1 LIKE '%9' THEN AIT4 ELSE ' ' END  AS AIT4,Sum(ACAM) AS ACAM
      FROM bousr.fpm_gl2_hst 
      WHERE datatype='ACT'
      GROUP BY divi, ait1, ait3,CASE WHEN AIT1 LIKE '%9' THEN AIT4 ELSE ' ' END, ACPERI
    ) dta ON f.divi=dta.divi AND f.ait1=dta.ait1 AND f.ait3=dta.ait3 AND f.ait4=dta.ait4 AND dta.acperi=f.period 
)
WHERE CUMUL<>0 AND period>='202001';


  GRANT SELECT ON "ANAPLAN"."TD_GL_SUM_BACKUP_20220616" TO "LOTMAT";

--TD_GL_SUM_FULL

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_GL_SUM_FULL" ("DIVISION", "PERIOD", "ACCOUNT_CODE", "COSTCENTER_CODE", "AMOUNT_LOC", "DIM3_CODE", "COUNTERPART_CODE", "AD_DIM1", "AD_DIM2", "AD_DIM3") AS 
  SELECT division,period,account_code,costcenter_code,Sum(amount_loc) AS amount_loc,dim3_code,counterpart_code,ad_dim1, ad_dim2,ad_dim3 
FROM
(
SELECT 
CAST((divi) AS VARCHAR(10)) AS division, 
CAST((acperi) AS VARCHAR(10)) AS period,
CAST((ait1) AS VARCHAR(30) ) AS account_code,
CAST((CASE WHEN cc.l1_division IS NULL THEN '49099' ELSE ait2 END) AS VARCHAR(30) ) AS costcenter_code,
acam AS amount_loc,
CAST((ait3) AS VARCHAR(30) ) AS dim3_code,
CAST((CASE WHEN cu.counterunit IS NULL THEN ' ' ELSE cu.counterunit END) AS VARCHAR(30) ) AS counterpart_code,
CAST((' ') AS VARCHAR(30) ) AS ad_dim1,
CAST((' ') AS VARCHAR(30) ) AS ad_dim2,
CAST((' ') AS VARCHAR(30) ) AS ad_dim3
FROM bousr.fpm_gl2_hst
left join anaplan.AD_COUNTERUNITS cu ON divi=cu.division AND ait4=cu.counterpart
left join anaplan.MD_COSTCENTER cc ON cc.l1_division=divi AND cc.l2_code=ait2  
WHERE datatype='ACT'
AND acperi>='202001' AND ait1 BETWEEN '8000000' AND '9999998'

UNION ALL

SELECT 
CAST((divi) AS VARCHAR(10)) AS division, 
CAST((acperi) AS VARCHAR(10)) AS period,
CAST((ait1) AS VARCHAR(30) ) AS account_code,
CAST((CASE WHEN cc.l1_division IS NULL THEN '49099' ELSE ait2 END) AS VARCHAR(30) ) AS costcenter_code,
acam AS amount_loc,
CAST((ait3) AS VARCHAR(30) ) AS dim3_code,
CAST((CASE WHEN cu.counterunit IS NULL THEN ' ' ELSE cu.counterunit END) AS VARCHAR(30) ) AS counterpart_code,
CAST((' ') AS VARCHAR(30) ) AS ad_dim1,
CAST((' ') AS VARCHAR(30) ) AS ad_dim2,
CAST((' ') AS VARCHAR(30) ) AS ad_dim3
FROM bousr.FPM_GL2_EXTRA
left join anaplan.AD_COUNTERUNITS cu ON divi=cu.division AND ait4=cu.counterpart
left join anaplan.MD_COSTCENTER cc ON cc.l1_division=divi AND cc.l2_code=ait2  
)
GROUP BY division,period,account_code,costcenter_code,dim3_code,counterpart_code,ad_dim1, ad_dim2,ad_dim3

UNION ALL

--BS accounts (cumulative):
SELECT  
CAST((divi) AS VARCHAR(10)) AS division, 
CAST((period) AS VARCHAR(10)) AS period,
CAST((ait1) AS VARCHAR(30) ) AS account_code,
CAST(('BS999') AS VARCHAR(30) ) AS costcenter_code,

cumul AS amount_loc,

CAST((ait3) AS VARCHAR(30) ) AS dim3_code,
CAST((ait4) AS VARCHAR(30) ) AS counterpart_code,
CAST((' ') AS VARCHAR(30) ) AS ad_dim1,
CAST((' ') AS VARCHAR(30) ) AS ad_dim2,
CAST((' ') AS VARCHAR(30) ) AS ad_dim3
FROM 

(
    SELECT f.*,Decode(dta.acam,NULL,0,dta.acam) AS periodsum,
    Sum(Decode(dta.acam,NULL,0,dta.acam))  over (PARTITION BY f.divi, f.ait1,f.ait3, f.ait4 ORDER BY f.period RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumul
    FROM 
    (
          SELECT ac.divi, per.period,ac.ait1,ac.ait3, ac.ait4
          FROM
          (
            SELECT divi,ait1, ait3, CASE WHEN cu.counterunit IS NULL THEN ' ' ELSE cu.counterunit END AS AIT4 
            FROM bousr.fpm_gl2_hst 
            left join anaplan.AD_COUNTERUNITS cu ON divi=cu.division AND ait4=cu.counterpart
            WHERE datatype='ACT' AND AIT1 BETWEEN '1000000' AND '7999999'
            GROUP BY divi, ait1, ait3,cu.counterunit  
            HAVING(Count(1))>0
          ) ac
          right outer join (SELECT DISTINCT SubStr(cdymd8,0,6) AS period  FROM mvxjdta.csycal WHERE  SubStr(cdymd8,0,6) BETWEEN '201712' AND To_Char(SYSDATE,'YYYYMM') ORDER BY period) per ON 1=1
    ) f
    left join 
    (
      SELECT a.DIVI, a.AIT1, a.AIT3,a.ACPERI,CASE WHEN cu.counterunit IS NULL THEN ' ' ELSE cu.counterunit END AS AIT4,Sum(ACAM) AS ACAM
      FROM bousr.fpm_gl2_hst a
      left join anaplan.AD_COUNTERUNITS cu ON divi=cu.division AND ait4=cu.counterpart   
      WHERE datatype='ACT'
      GROUP BY divi, ait1, ait3,cu.counterunit, ACPERI
    ) dta ON f.divi=dta.divi AND f.ait1=dta.ait1 AND f.ait3=dta.ait3 AND f.ait4=dta.ait4 AND dta.acperi=f.period 
)
WHERE CUMUL<>0 AND period>='202001';


  GRANT SELECT ON "ANAPLAN"."TD_GL_SUM_FULL" TO "BOUSR" WITH GRANT OPTION;
  GRANT SELECT ON "ANAPLAN"."TD_GL_SUM_FULL" TO "QTCUSER" WITH GRANT OPTION;
  GRANT SELECT ON "ANAPLAN"."TD_GL_SUM_FULL" TO "LOTMAT";



--TD_MARKETINGMONEY


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_MARKETINGMONEY" ("DIVISION", "PERIOD", "L1_REGION", "L2_SALESCHANNEL", "L3_CODE", "L4_CODE", "L5_CODE", "AMOUNT", "ITEM_CODE") AS 
  SELECT 
CAST((bodivi) AS VARCHAR(3)) AS division,
CAST((boperi) AS VARCHAR(6)) AS Period,
CAST((bodivi||'-'||L1_Region) AS VARCHAR(108)) AS L1_region,
CAST((bodivi||'-'||l2_saleschannel) AS VARCHAR(108)) AS L2_saleschannel,
bodivi||'-'||l2_saleschannel||'-'||l3_code AS l3_code,
bodivi||'-'||l2_saleschannel||'-'||l3_code||'-'||l4_code AS l4_code,
--bodivi||'-'||l2_saleschannel||'-'||l3_code||'-'||l4_code||CASE WHEN l5_code=l4_code THEN '' ELSE '-'||l5_code END AS l5_code,
bodivi||'-'||l2_saleschannel||'-'||l3_code||'-'||l4_code||CASE WHEN l5_code=l4_code THEN '' ELSE '-'||l5_code END||'-'||l6_code AS l5_code,
        sum(boboam) as Amount, boitno as ITEM_CODE
from 
(
    SELECT bodivi,boperi, 
    CASE WHEN cv.newcustomer IS NULL THEN bocuno ELSE cv.newcustomer END AS bocuno,
    Sum(boboam) AS boboam, boitno
    FROM bousr.prep_salesadjustments 
    left join anaplan.AD_CUSTOMER_CONVERSION cv ON bodivi=cv.divi AND bocuno=cv.oldcustomer 
    WHERE botype='MARKETINGM' and bodivi not in ('800','400') 
   AND boperi>=to_char(ADD_MONTHS(SYSDATE, -1), 'YYYYMM') 
  -- AND boperi>='202301'
    GROUP BY bodivi, boperi, CASE WHEN cv.newcustomer IS NULL THEN bocuno ELSE cv.newcustomer END, boitno
) 
left join MD_CUSTOMER_DETAIL cu ON bodivi=division and bocuno=M3CUSTOMERCODE
group by bodivi,boperi,L1_Region,L2_saleschannel,l3_code,L4_Code
,L5_Code, L6_code, boitno
UNION ALL
SELECT "DIVISION","PERIOD","L1_REGION","L2_SALESCHANNEL","L3_CODE","L4_CODE","L5_CODE","AMOUNT","ITEM_CODE" FROM ANAPLAN.TD_MARKETINGMONEY@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "DIVISION","PERIOD","L1_REGION","L2_SALESCHANNEL","L3_CODE","L4_CODE","L5_CODE","AMOUNT","ITEM_CODE" FROM M3SKY_ANAPLAN.TD_MARKETINGMONEY WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."TD_MARKETINGMONEY" TO "LOTMAT";



--TD_NATUREBASED_COGS


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_NATUREBASED_COGS" ("DIVISION", "COSTCENTER", "PERIOD", "IS_LINE", "AMOUNT") AS 
  SELECT  
CAST((company) AS VARCHAR(3)) AS division, 
CAST((company) AS VARCHAR(3))||'_'||AIT2 as CostCenter,
period, 
CASE 
WHEN ait1 IN ('2001000P', '2004000P')            THEN 'Materials purchased (raw + packaging)'
WHEN ait1 IN ('2001000COI')                       THEN 'Materials purchased (raw + packaging)'
WHEN ait1 IN ('2005000P','2003000P')              THEN 'Purchased ready products for resale'
WHEN ait1 IN ('1020000M','9101020')               THEN 'Production depreciation'
WHEN ait1 IN ('5106020M')                         THEN 'Production direct salaries'
WHEN ait1 IN ('5106030M')                         THEN 'Water and waste water'
WHEN ait1 IN ('5106040M')                         THEN 'Production electricity'
WHEN ait1 IN ('5106050M')                         THEN 'Production heating'
WHEN ait1 IN ('5106060M')                         THEN 'Production repairs and spare parts'
WHEN ait1 IN ('5106090M')                         THEN 'Other production costs'
WHEN ait1 LIKE ('9002%')                          THEN 'Semi-finished costs'
WHEN ait1 LIKE ('9003%')                          THEN 'Variances'
WHEN ait1 LIKE ('9004%')                          THEN 'Variances'
WHEN source LIKE ('2.1%')                         THEN 'Other production costs'
WHEN source LIKE ('5%')                           THEN 'Other production costs'
WHEN source LIKE ('0%')                           THEN 'Balancing'
WHEN source LIKE '9%'                             THEN 'Change of inventory of WIP and fin prod'
ELSE 'Other production costs' END AS IS_LINE,
Sum(eur) AS amount

FROM bousr.fpm_VS11000_hst m 
WHERE period>='202101' AND COMPANY not in ('800','400')
AND( ait1 NOT LIKE '9001%')

GROUP BY company, period,ait2,
CASE 
WHEN ait1 IN ('2001000P', '2004000P')            THEN 'Materials purchased (raw + packaging)'
WHEN ait1 IN ('2001000COI')                       THEN 'Materials purchased (raw + packaging)'
WHEN ait1 IN ('2005000P','2003000P')              THEN 'Purchased ready products for resale'
WHEN ait1 IN ('1020000M','9101020')               THEN 'Production depreciation'
WHEN ait1 IN ('5106020M')                         THEN 'Production direct salaries'
WHEN ait1 IN ('5106030M')                         THEN 'Water and waste water'
WHEN ait1 IN ('5106040M')                         THEN 'Production electricity'
WHEN ait1 IN ('5106050M')                         THEN 'Production heating'
WHEN ait1 IN ('5106060M')                         THEN 'Production repairs and spare parts'
WHEN ait1 IN ('5106090M')                         THEN 'Other production costs'
WHEN ait1 LIKE ('9002%')                          THEN 'Semi-finished costs'
WHEN ait1 LIKE ('9003%')                          THEN 'Variances'
WHEN ait1 LIKE ('9004%')                          THEN 'Variances'
WHEN source LIKE ('2.1%')                         THEN 'Other production costs'
WHEN source LIKE ('5%')                           THEN 'Other production costs'
WHEN source LIKE ('0%')                           THEN 'Balancing'
WHEN source LIKE '9%'                             THEN 'Change of inventory of WIP and fin prod'
ELSE 'Other production costs' END
UNION ALL
SELECT "DIVISION","COSTCENTER","PERIOD","IS_LINE","AMOUNT" FROM ANAPLAN.TD_NATUREBASED_COGS@LBM3PRD1_ANAPLAN WHERE DIVISION = '800'
UNION ALL
SELECT "DIVISION","COSTCENTER","PERIOD","IS_LINE","AMOUNT" FROM M3SKY_ANAPLAN.TD_NATUREBASED_COGS WHERE DIVISION = '400';


  GRANT SELECT ON "ANAPLAN"."TD_NATUREBASED_COGS" TO "LOTMAT";


--TD_PRODUCTION_PLAN


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TD_PRODUCTION_PLAN" ("DIVISION", "WORKCENTER", "ITEMTYPE", "ITEMCODE", "PERIOD", "TYPE", "LITERS") AS 
  SELECT 
    Division,
    Division||'_'||WORKCENTER as workcenter,
    itemtype,
    itemcode,
    period,
    'PLAN' as type,
    liters
from bousr.bi_Production_plan
where WORKCENTER<>' ' and  division<>'300'
union all
SELECT 
    Division,
    Division||'_'||prod_line as workcenter,
    case when SubStr(Manuf_type,0,4)='SEMI' then '40' else '10' end as itemtype,
    productcode as itemcode,
    SubStr(manuf_date,0,6) as period,
    'ACT' as type,
    sum(manuf_vol) as liters
from bousr.bi_manufacturing 
where SubStr(manuf_date,0,6)>='202201' and division<>'300'
group by Division,prod_line,Manuf_type,productcode,SubStr(manuf_date,0,6);


  GRANT SELECT ON "ANAPLAN"."TD_PRODUCTION_PLAN" TO "LOTMAT";


--TST_CUSTOMER_DETAIL

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ANAPLAN"."TST_CUSTOMER_DETAIL" ("DIVISION", "L1_REGION", "L2_SALESCHANNEL", "L3_CUSTOMERGROUP", "L4_CHAIN", "L5_CUSTOMER", "L6_EXCISE_DEPO", "L3_CODE", "L4_CODE", "L5_CODE", "L6_CODE", "SHOP", "CHARGEMODEL", "M3CUSTOMERCODE", "M3STATUS", "EXCISE", "DEPOFEE", "PRICELIST_REF", "BONUSGROUP_REF", "DISCOUNTGROUP_REF", "DELIVERYGROUP", "DELIVERYGROUP_CODE") AS 
  SELECT
--PART2: LOCAL EXCEPTIONS
CAST((cs.divi) AS VARCHAR(108)) AS Division,

CAST((CASE
WHEN cu.OKCUCL IN ('905','907') THEN 'EXPORT'
WHEN cu.OKCUCL IN ('900','901','903') THEN 'TRAVELTRADE'
WHEN cu.OKACRF BETWEEN '4410' AND '4449' THEN 'EXPORT'
WHEN cu.OKACRF='L9000' THEN 'GROUP'
WHEN cu.OKCUCL IN ('910','176','177','178','179','180') THEN 'GROUP'
ELSE  'DOMESTIC'
END) AS VARCHAR(108)) AS L1_Region,

CAST((CASE
WHEN cu.OKCUCL IN ('182','154','155','156','250','255','211','212','213','214','215','216','217',',218','219','230','259','459') THEN 'RETAIL'   --RETAIL Customer Group's (OKCUCL)
WHEN cu.OKACRF='L9000' THEN 'GROUP'                                                                                                              --GROUP "Costcenter" LIDA (OKACRF)
WHEN cu.OKCUCL BETWEEN '400' AND '408' THEN 'RETAIL'                                                                                             --RETAIL Customer Group's (OKCUCL)
WHEN cu.okpyno IN ('20009048','20011837') THEN 'RETAIL'                                                                                          --KAUPMEES, SANITEX in RETAIL for ALC
WHEN cu.OKCUCL IN ('220','606','154','170','172','173','174','175','720','420','419') THEN 'HORECA'                                              --HORECA Customer Group's (OKCUCL)
WHEN cu.OKCUCL in ('130','140','171') AND cu.OKCFC3='SK' THEN 'HORECA'                                                                           --HORECA special OLVI
WHEN cu.OKCUCL BETWEEN '891' AND '896' THEN 'HORECA'                                                                                             --HORECA Customer Group's (OKCUCL)
WHEN cu.OKCUCL IN ('900','903','901','183') THEN 'TRAVELTRADE'                                                                                   --TRAVELTRADE Customer Group's (OKCUCL)
WHEN cu.OKCUCL IN ('905','907') THEN 'EXPORT'                                                                                                    --EXPORT Customer Group's (OKCUCL)
WHEN cu.OKACRF BETWEEN '4410' AND '4449' THEN 'EXPORT'                                                                                           --EXPORT Costcenters (OKACRF)
WHEN cu.OKCUCL IN ('910','176','177','178','179','180') THEN 'GROUP'                                                                             --GROUP Customer Group's (OKCUCL)
WHEN cu.OKCFC1 NOT IN ('7006','7010','7011','7012','7013','7014','7015','7018','7019') THEN 'RETAIL'                                             --RETAIL, excluding number of CESU chains (OKCFC1)
ELSE 'WHOLESALES'                                                                                                                                --WHOLESALE - the rest of customers
END) AS VARCHAR(108)) AS L2_SalesChannel,
CAST((CASE
WHEN cu.okrasn='800' THEN CASE WHEN cu.okfre1=' ' THEN 'NA' ELSE fr1.cttx40 END                                             --local ROP for LIDA (okfre1)
WHEN cu.okcucl BETWEEN '905' AND '909' THEN ct4.CTTX40                                                                      --SALESPERSON for EXPORT
WHEN cu.OKACRF='L9000' OR cu.okcucl='910' THEN (Upper(py.okcunm||' ('||py.okcuno||')') )                                    --PAYER for GROUP counterpart
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 END    --COSTCENTER for OLVI & SERVAALI
ELSE  CASE WHEN cu.okcucl=' ' THEN 'OTHER' ELSE ct1.CTTX40 END                                                              --CUSTOMER GROUP (OKCUCL) for the rest
END) AS VARCHAR(108)) AS L3_CustomerGroup,

CAST((CASE
WHEN  cu.okcucl='910' OR cu.OKACRF='L9000'  THEN (Upper(py.okcunm||' ('||py.okcuno||')') )                                  --PAYER for GROUP counterpart
WHEN  cu.okcucl BETWEEN '905' AND '909'  THEN ct9.cttx15                                                                    --COUNTRY for EXPORT
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 END    --COSTCENTER for OLVI & SERVAALI
WHEN cu.okrasn IN ('200','600') AND cu.OKCFC8!=' ' THEN ct10.cttx40                                                         --CHAIN GROUP for ALC, VOLFAS
WHEN cu.OKCFC1 IN (' ') THEN 'NO CHAIN'                                                                                     --if CHAIN is BLANK - then "NO CHAIN"
                        ELSE ct8.cttx40                                                                                     --else CHAIN (OKCFC1)
END) AS VARCHAR(108)) AS l4_chain,
CAST((CASE
WHEN  cu.okcucl BETWEEN '905' AND '910' OR cu.OKACRF='L9000' THEN 
  CASE WHEN py.okcunm IS NULL THEN Upper(cu.okcunm||' ('||cu.okcuno||')') else  Upper(py.okcunm||' ('||py.okcuno||')') END  --PAYER for EXPORT and GROUP (if PAYER=' ' then CUSTOMER)
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN 'OTHER' ELSE ea1.cttx40 END    --COSTCENTER for OLVI & SERVAALI
WHEN cu.okrasn IN ('200','600') AND cu.OKCFC8!=' ' THEN ct10.cttx40                                                         --CHAIN GROUP for ALC, VOLFAS
WHEN cu.OKCFC1 IN (' ') THEN 'NO CHAIN'                                                                                     --if CHAIN is BLANK - then "NO CHAIN"
                        ELSE ct8.cttx40                                                                                     --else CHAIN (OKCFC1)
END) AS VARCHAR(108)) AS L5_Customer,

CAST((  CASE WHEN cm.excise IS NULL THEN 'no excise' ELSE Decode(cm.excise,'YES','excise','NO','no excise') END
      ||'-'||
        CASE WHEN cm.depofee IS NULL THEN 'no deposit' ELSE Decode(cm.depofee,'YES','deposit','NO','no deposit') END)
AS VARCHAR(108)) AS L6_excise_depo,

CAST((CASE
WHEN cu.okrasn='800' THEN CASE WHEN cu.okfre1=' ' THEN '888' ELSE cu.okfre1 END                                             --Local ROP for LIDA
WHEN cu.okcucl BETWEEN '905' AND '909' THEN  cu.OKSMCD                                                                      --SALESPERSON for EXPORT
WHEN cu.OKACRF='L9000' OR cu.okcucl='910' THEN py.okcuno                                                                    --PAYER for GROUP counterpart
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN '9999' ELSE cu.okacrf END      --COSTCENTER for OLVI & SERVAALI
ELSE  CASE WHEN cu.okcucl=' ' THEN '999' ELSE cu.OKCUCL END                                                                 --CUSTOMER GROUP (OKCUCL) for the rest
END) AS VARCHAR(108)) AS L3_CODE,

CAST((CASE
WHEN  cu.okcucl='910' OR cu.OKACRF='L9000'  THEN py.okcuno                                                                  --PAYER for GROUP counterpart
WHEN  cu.okcucl BETWEEN '905' AND '909'   THEN cu.OKCSCD                                                                    --COUNTRY for EXPORT and GROUP
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN '9999' ELSE cu.okacrf END      --COSTCENTER for OLVI & SERVAALI
WHEN cu.okrasn IN ('200','600') AND cu.OKCFC8!=' ' THEN  cu.OKCFC8                                                          --CHAIN GROUP for ALC, VOLFAS
WHEN cu.OKCFC1 IN (' ') THEN '999'                                                                                          --if CHAIN is BLANK - then "NO CHAIN"
                        ELSE cu.OKCFC1                                                                                      --else CHAIN (OKCFC1)
END) AS VARCHAR(108)) AS L4_CODE,

CAST((CASE
WHEN  cu.okcucl BETWEEN '905' AND '910' OR cu.OKACRF='L9000'  THEN 
  CASE WHEN py.okcuno IS NULL THEN cu.okcuno ELSE py.okcuno END                                                             --PAYER for EXPORT and GROUP (if PAYER=' ' then CUSTOMER)
WHEN cu.okrasn IN ('100','300') AND cu.okcucl!='910' THEN CASE WHEN opla.eaaitm IS null THEN '9999' ELSE cu.okacrf END      --COSTCENTER for OLVI & SERVAALI
WHEN cu.okrasn IN ('200','600') AND cu.OKCFC8!=' ' THEN  cu.OKCFC8                                                          --CHAIN GROUP for ALC, VOLFAS
WHEN cu.OKCFC1 IN (' ') THEN '999'                                                                                          --if CHAIN is BLANK - then "NO CHAIN"
                        ELSE cu.OKCFC1                                                                                      --else CHAIN (OKCFC1)
END) AS VARCHAR(108)) AS L5_CODE,


CAST(( CASE
WHEN cm.excise IS NULL THEN '0' ELSE Decode(cm.excise,'YES','1','NO','0') END ||'-'|| CASE WHEN cm.depofee IS NULL THEN '0' ELSE Decode(cm.depofee,'YES','1','NO','0') END)
AS VARCHAR(108)) AS L6_code,

cast((cu.okcunm||' ('||cu.okcuno||')') as VARCHAR(108)) as SHOP,
cast((cu.OKCHSY) AS VARCHAR(108)) AS chargemodel,
cast((cu.okcuno) as VARCHAR(108)) as M3CUSTOMERCODE,
cast((cu.okstat) as VARCHAR(108)) AS M3status,
CAST((CASE WHEN cm.excise IS NULL THEN 'NO' ELSE cm.excise  END) AS VARCHAR(3)) AS     excise,
CAST((CASE WHEN cm.depofee IS NULL THEN 'NO' ELSE cm.depofee END) AS VARCHAR(3)) AS     depofee,
CAST(
(CASE
      WHEN cu.okrasn='200' AND cu.OKCUCL IN ('900','901','903') THEN 'TT-2A0'
      WHEN cu.okrasn='200' AND cu.OKCUCL<'900' THEN 'DOM-2A0'
      WHEN cu.okrasn='600' AND cu.OKCUCL<'900' THEN '6R1'
      WHEN cu.okrasn='700' AND cu.OKCUCL<'900' THEN '7C1'
      ELSE 'NA' END
) AS VARCHAR(108)) AS pricelist_ref,
CAST(('NA') AS VARCHAR(108)) AS bonusgroup_ref,
CAST(('NA') AS VARCHAR(108)) AS discountgroup_ref,
CAST((CASE WHEN cu.OKMODL='03' OR cu.OKMODL=' ' THEN 'NA' ELSE MODL.cttx15 END) AS VARCHAR(108)) AS deliverygroup,
CAST((CASE WHEN cu.OKMODL='03' OR cu.OKMODL=' ' THEN '999' ELSE cu.OKMODL END) AS VARCHAR(108)) AS deliverygroup_code
FROM (SELECT DISTINCT divi, cuno FROM (SELECT okdivi AS divi, okcuno AS cuno FROM mvxjdta.ccudiv UNION ALL SELECT okrasn AS divi,okcuno AS cuno FROM mvxjdta.ocusma) WHERE divi!=' ' ORDER BY cuno, divi ) cs     -- customer selection table, includes local exceptions!
 left join mvxjdta.OCUSMA cu ON cs.cuno=cu.okcuno
 left join mvxjdta.OCUSMA py ON cu.OKCONO=py.OKCONO AND py.OKCUNO=cu.OKPYNO
 left join mvxjdta.CSYTAB ct1 ON cu.OKCONO=ct1.CTCONO AND ct1.CTSTCO='CUCL' AND ct1.CTSTKY=cu.OKCUCL AND ct1.ctdivi=' '
 left join mvxjdta.CSYTAB ct2 ON cu.OKCONO=ct2.CTCONO AND ct2.CTSTCO='ECAR' AND ct2.CTSTKY=cu.OKECAR AND ct2.ctdivi=' '
 left join mvxjdta.CSYTAB ct3 ON cu.OKCONO=ct3.CTCONO AND ct3.CTSTCO='SDST' AND ct3.CTSTKY=cu.OKSDST AND ct3.ctdivi=' '
 left join mvxjdta.CSYTAB ct4 ON cu.OKCONO=ct4.CTCONO AND ct4.CTSTCO='SMCD' AND ct4.CTSTKY=cu.OKSMCD AND ct4.ctdivi=' '
 left join mvxjdta.CSYTAB ct5 ON cu.OKCONO=ct5.CTCONO AND ct5.CTSTCO='CDRC' AND ct5.CTSTKY=cu.OKCDRC AND ct5.ctdivi=' '
 left join mvxjdta.CSYTAB ct6 ON cu.OKCONO=ct6.CTCONO AND ct6.CTSTCO='CFC6' AND ct6.CTSTKY=cu.OKCFC6 AND ct6.ctdivi=' '
 left join mvxjdta.CSYTAB ct7 ON cu.OKCONO=ct7.CTCONO AND ct7.CTSTCO='CFC9' AND ct7.CTSTKY=cu.OKCFC9 AND ct7.ctdivi=' '
 left join mvxjdta.CSYTAB ct8 ON cu.OKCONO=ct8.CTCONO AND ct8.CTSTCO='CFC1' AND ct8.CTSTKY=cu.OKCFC1 AND ct8.ctdivi=' '
 left join mvxjdta.CSYTAB ct9 ON cu.OKCONO=ct9.CTCONO AND ct9.CTSTCO='CSCD' AND ct9.CTSTKY=cu.OKCSCD AND ct9.ctdivi=' '
 left join mvxjdta.CSYTAB ct10 ON cu.OKCONO=ct10.CTCONO AND ct10.CTSTCO='CFC8' AND ct10.CTSTKY=cu.OKCFC8 AND ct10.ctdivi=' '
 left join mvxjdta.CSYTAB ea1 ON cu.OKCONO=ea1.CTCONO AND EA1.CTSTKY=Trim(cu.OKACRF) AND ea1.ctstco='ACRF' and ea1.ctdivi=' '
 left join mvxjdta.csytab fr1 ON cu.okcono=fr1.ctcono AND fr1.ctstco='FRE1' AND fr1.ctstky=cu.okfre1
 left join anaplan.AD_CHARGEMODEL cm ON cu.OKCHSY=cm.chargemodel
 left join mvxjdta.csytab MODL on MODL.ctcono=cu.okcono AND MODL.ctstco='MODL' AND MODL.ctlncd=cu.oklhcd AND MODL.ctstky!='03' AND cu.okmodl=MODL.ctstky
 left join (SELECT eaaitm FROM mvxjdta.fchacc WHERE eacono=100 AND eadivi='100' AND eaaitp='2' AND earesp='PLANNING') opla ON cu.okacrf=opla.eaaitm
 WHERE cu.OKCONO=100 AND cu.okcutp NOT in ('8','9') and cu.okrasn||'-'||cu.okcutp not in '100-2'
ORDER BY division, m3customercode;


  GRANT SELECT ON "ANAPLAN"."TST_CUSTOMER_DETAIL" TO "LOTMAT";

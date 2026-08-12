--BOUSR	BI_COGS_OPERATIONS_V	

"SELECT DISTINCT  
pofaci as Division,
poprno as Product,
case when pofaci='400' then POPLGR ELSE m9wcln END AS productionline, 
mbeoqt AS orderqty, 
mbeoqt*MMVOL3 AS orderqty_L,
popiti AS runtime,
poctcd AS efficiency,
poprnp AS filling_people,
poseti AS setup_time,
posenp AS setup_people, 
round(CASE WHEN poctcd=0 or mmvol3=0 THEN 0 ELSE (popiti/poctcd)/mmvol3*1000 END,6) AS fill_mh_1000L, 
round(CASE WHEN poctcd=0 or mmvol3=0 THEN 0 ELSE (poprnp*popiti/poctcd)/mmvol3*1000 END,6) AS fill_lh_1000L, 
round(CASE WHEN (mbeoqt=0 OR poseti=0 or mmvol3=0) THEN 0 ELSE (poseti/mbeoqt)/mmvol3*1000 END,6) AS setup_mh_1000L,
round(CASE WHEN (mbeoqt=0 OR poseti=0 or mmvol3=0) THEN 0 ELSE (poseti*posenp/mbeoqt)/mmvol3*1000 END,6) AS setup_lh_1000L,
mmvol3 as Volume
from mvxjdta.mpdope    
inner join mvxjdta.mitmas ON mmcono=100 AND mmitno=poprno
left join mvxjdta.mitfac ON m9cono=mmcono AND m9faci=pofaci and m9itno=mmitno
left join mvxjdta.mitbal mb1 ON mbcono=m9cono AND  mb1.mbitno=mmitno AND m9rewh=mb1.mbwhlo
where PoCONO=100 and pofaci!='800' and PoSTRT in ('100','106') and POSDCD=1 and mmitty in ('10','40') and mmstat<='20'
 --added POSDCD=1 so that alternative operations would not be taken


-------------------------------------------------------------------------------------------------------------------------
union

SELECT "DIVISION","PRODUCT","PRODUCTIONLINE","ORDERQTY","ORDERQTY_L","RUNTIME","EFFICIENCY","FILLING_PEOPLE","SETUP_TIME","SETUP_PEOPLE","FILL_MH_1000L","FILL_LH_1000L","SETUP_MH_1000L","SETUP_LH_1000L","VOLUME" FROM BOUSR.BI_COGS_OPERATIONS_V@LBM3PRD1_BOUSR

union
SELECT "DIVISION","PRODUCT","PRODUCTIONLINE","ORDERQTY","ORDERQTY_L","RUNTIME","EFFICIENCY","FILLING_PEOPLE","SETUP_TIME","SETUP_PEOPLE","FILL_MH_1000L","FILL_LH_1000L","SETUP_MH_1000L","SETUP_LH_1000L","VOLUME" FROM M3SKY.BI_COGS_OPERATIONS_V"

-----------------------------------------------------------------------------------------------------------------------------------------------------

--BOUSR	BI_FIXED_ASSET_V	

"select  FMDIVI as Division,
        case FMFAST
            when 1 then 'Normal'
            when 5 then 'Preliminary'
            when 8 then 'Fully depreciated'
            when 9 then 'Sold_Disposed'
            else 'Other' end
            as Status,
        FMASID||'- '||FMSBNO as FAID,
        FMTXT1 FA_Name,
        FMFATP as FA_TypeID,
        fatp.CTTX40 as FA_Type,
        FMLOC1 as LocationID,
        faloc.CTTX40 as Location,
        FMAIT2 as CostCenter,
        FMFAQT as Quantity,
        IDSUNM as Payee,
        FMPPER as AquisitionDate,
        FMAPER as ActivationDate,
        CASE FDDPMD
            WHEN 0 THEN 'Not depreciated'
            when 1 then 'Linear'
            when 2 then 'Declining'
            else 'Other' end
        as DeprMethod, 
        FDNOMT as Lifetime_months,
        FHVATP as TransactionID,
        vatp.CTTX40 as Transaction,
        FHVPER as Period,
        FHAIT1,
        FHAIT2,
        FHAIT3,
        FHAIT5,
        FHFAVA as Amount
from mvxjdta.FFASMA
left join mvxjdta.FFAHIS on FHDIVI=FMDIVI and FHASID=FMASID and FHSBNO=FMSBNO
left join mvxjdta.CSYTAB fatp on fatp.CTDIVI=FMDIVI and fatp.CTSTKY=FMFATP and fatp.CTSTCO='FATP'
left join mvxjdta.CSYTAB faloc on faloc.CTDIVI=FMDIVI and faloc.CTSTKY=FMLOC1 and faloc.CTSTCO='PLC1'
left join mvxjdta.CIDMAS on IDSUNO=FMSPYN
left join mvxjdta.CSYTAB vatp on vatp.CTDIVI=FHDIVI and vatp.CTSTKY=FHVATP and vatp.CTSTCO='VATP'
left join mvxjdta.FFASDM dep on FDDIVI=FMDIVI and FDASID=FMASID and FDSBNO=FMSBNO
WHERE FHDIVI <> '800'
UNION ALL
SELECT "DIVISION","STATUS","FAID","FA_NAME","FA_TYPEID","FA_TYPE","LOCATIONID","LOCATION","COSTCENTER","QUANTITY","PAYEE","AQUISITIONDATE","ACTIVATIONDATE","DEPRMETHOD","LIFETIME_MONTHS","TRANSACTIONID","TRANSACTION","PERIOD","FHAIT1","FHAIT2","FHAIT3","FHAIT5","AMOUNT" FROM BOUSR.BI_FIXED_ASSET_V@LBM3PRD1_BOUSR WHERE DIVISION = '800'"


-----------------------------------------------------------------------------------------------------------------------------------------------------


--BOUSR	BI_FULL_RECEIPE_V	

"select PMCONO, PMFACI, root_id, PMPRNO, PMMTNO, PMMSEQ, PMCNQT, pmcnqt2,
CASE WHEN bum.faci IS NOT NULL THEN bum.conv_f ELSE 1 END AS unms_convertformula,      
round(bousr.receipt_multiplier('1'||formula_text_all),6)*(CASE WHEN bum.faci IS NOT NULL THEN bum.conv_f ELSE 1 END) as FULL_QTY    
,round(bousr.receipt_multiplier('1'||formula_text_all),6) as formula
from 
(select 
  unique connect_by_root PMPRNO as root_id, PMCONO, PMFACI, PMPRNO, PMMTNO, PMMSEQ, PMCNQT, pmcnqt2,   level,      sys_connect_by_path(PMCNQT,'*') formula_text_all  
  from 
    (
      select pmcono,pmfaci,pmprno,pmstrt,pmmtno,pmmseq,
      round(((CASE WHEN pmwapc!=0 THEN pmwapc WHEN mmwapc!=0 THEN mmwapc ELSE 0 END)+100)*pmcnqt*Decode(pmbypr,0,1,-1)/100/decode(PHBAQT,0,1,PHBAQT),8) AS pmcnqt, 
      round(Decode(pmbypr,0,1,-1)*pmcnqt/decode(PHBAQT,0,1,PHBAQT),8) as pmcnqt2  
      from mvxjdta.MPDMAT 
        INNER JOIN mvxjdta.mitmas ON mmcono=pmcono and mmitno=pmmtno  
        INNER JOIN mvxjdta.MPDHED ON phcono=pmcono and phfaci=pmfaci and phstrt=pmstrt and phprno=pmprno
      where PMCONO=100 AND PMFACI!='800' and PMSTRT='100' and pmmtno!='2400999'
    )  connect by NOCYCLE PRIOR PMMTNO=PMPRNO  
      order by root_id, level, pmprno, PMMSEQ) 
  inner join mvxjdta.MITMAS on MMCONO=PMCONO and MMITNO=PMMTNO and MMITTY not in ('10','40')
--retrieve conversion formula for cases, when material recipe unit of measure (pmpeun in mpdmat) is not equal to basic unit of measure (mmunms in mitmas)
left join 
(
    SELECT distinct pmfaci as faci,pmprno as prod, pmmtno as mat,pmpeun,mat.mmunms, CASE WHEN mudmcf=2 THEN 1/mucofa WHEN mudmcf=1 THEN 1*mucofa ELSE 1 END AS conv_f 
    FROM mvxjdta.mpdmat
    inner join mvxjdta.mitmas mat ON mat.mmcono=pmcono AND mat.mmitno=pmmtno
    inner join mvxjdta.mitaun ON mat.mmcono=mucono AND mat.mmitno=muitno AND muautp='1' 
    WHERE  pmfaci=100 and mat.mmitty NOT IN ('10') AND mat.mmunms!=pmpeun 
) bum ON bum.faci=pmfaci and bum.prod=pmprno and bum.mat=pmmtno


UNION ALL

SELECT "PMCONO","PMFACI","ROOT_ID","PMPRNO","PMMTNO","PMMSEQ","PMCNQT","PMCNQT2","UNMS_CONVERTFORMULA","FULL_QTY","FORMULA" FROM BOUSR.BI_FULL_RECEIPE@LBM3PRD1_BOUSR"

-----------------------------------------------------------------------------------------------------------------------------------------------------

--BOUSR	BI_MANUFACTURING	


"SELECT mtcono as COMPANYCODE, mwdivi AS DIVISION, mtwhlo AS WAREHOUSE, voplgr AS PROD_LINE, mtitno AS PRODUCTCODE, mttrdt AS MANUF_DATE, mttrtp AS MANUF_ORDERTYPE, mtridn AS ORDERNR, Sum(mttrqt) AS MANUF_QTY, Sum(mttrqt*mmvol3) AS MANUF_VOL, Avg(mttrpr) AS Trans_price,
CASE WHEN mmitty='10' AND mttrtp IN ('2PK') THEN 'MULTIPACK PACKING'
    WHEN mmitty='10' AND voplgr IN ('610','613') THEN 'MULTIPACK PACKING' 
    WHEN mmitty='10' AND mttrTp IN ('2RE','7GR','7PA','7PE','7PI','7PR','7PL','7VP','8RE','4RE','7WR','7PM','7PS') THEN 'WAREHOUSE REPAKCING'
    WHEN voplgr IN ('100','130','170','175','9000','418','419','420','450') THEN 'WAREHOUSE REPAKCING' 
    WHEN mmitty='40' THEN 'SEMI MANUFACTURING'
    ELSE 'FILLING' END AS MANUF_TYPE 
FROM mvxjdta.mittra 
left JOIN mvxjdta.mitmas ON mtcono=mmcono AND mtitno=mmitno
left join mvxjdta.mitwhl on mwcono=mtcono and mwwhlo=mtwhlo
left JOIN mvxjdta.mwoope ON mtcono=vocono AND mtridn=vomfno
WHERE mtcono=100 AND MWDIVI!='800' AND mtttid IN ('WOP','WMP') AND mmitty IN ('10','40') AND mttrtp!='171' and mtwhlo not in ('430','435')
GROUP BY mtcono, mwdivi, mtwhlo, voplgr, mtitno, mttrdt, mttrtp, mtridn, 
CASE WHEN mmitty='10' AND mttrtp IN ('2PK') THEN 'MULTIPACK PACKING'
    WHEN mmitty='10' AND voplgr IN ('610','613') THEN 'MULTIPACK PACKING' 
    WHEN mmitty='10' AND mttrTp IN ('2RE','7GR','7PA','7PE','7PI','7PR','7PL','7VP','8RE','4RE','7WR','7PM','7PS') THEN 'WAREHOUSE REPAKCING'
    WHEN voplgr IN ('100','130','170','175','9000','418','419','420','450') THEN 'WAREHOUSE REPAKCING' 
    WHEN mmitty='40' THEN 'SEMI MANUFACTURING'
    ELSE 'FILLING' END
    
    
UNION

SELECT "COMPANYCODE","DIVISION","WAREHOUSE","PROD_LINE","PRODUCTCODE","MANUF_DATE","MANUF_ORDERTYPE","ORDERNR","MANUF_QTY","MANUF_VOL","TRANS_PRICE","MANUF_TYPE" FROM BOUSR.BI_MANUFACTURING@LBM3PRD1_BOUSR

UNION

SELECT "COMPANYCODE","DIVISION","WAREHOUSE","PROD_LINE","PRODUCTCODE","MANUF_DATE","MANUF_ORDERTYPE","ORDERNR","MANUF_QTY","MANUF_VOL","TRANS_PRICE","MANUF_TYPE" FROM M3SKY.BI_MANUFACTURING"


-----------------------------------------------------------------------------------------------------------------------------------------------------
--BOUSR	BI_ORDERTYPES_V	

"SELECT 
oocono AS COMPANYCODE, 
case when ooortp like '1%' then 100
     when ooortp like '3%' then 300 
     when ooortp like '9%' then 100 
     when ooortp like '2%' then 200 
     when ooortp like '6%' then 600 
     when ooortp like '7%' then 700 
     when ooortp like '8%' then 800
     WHEN ooortp LIKE '4%' THEN 400
     end as DIVISION,
OOORTP AS ORDERTYPE, OOTX40, /*DECODE(OOORTP,'135','OWN USAGE',
                                     '113','MARKETING',
                                     '114','MARKETING',
                                     '115','MARKETING',
                                     '116','MARKETING',
                                     '117','MARKETING',
                                     '134','MARKETING',
                                     '932','MARKETING',
                                     '215','MARKETING',
                                     '216','MARKETING',
                                     '634','MARKETING',
                                     '635','MARKETING',
                                     '636','MARKETING',
                                     '771','MARKETING',
                                     '772','MARKETING',
                                     '773','MARKETING',
                                     'NORMAL') AS ORDERTYPEGROUP,*/
F1A030 as ORDERTYPEGROUP,
OOORTP||' - '||OOTX15 AS ORDERTYPELOCAL
FROM MVXJDTA.OOTYPE
left join mvxjdta.cugex1 on oocono=f1cono and ooortp=f1pk01 and f1file='OOTYPE'
where oocono=100 and ooortp not in ('KVA','KVI','KVB','448','978') and ooortp not like '8%'

union

SELECT "COMPANYCODE","DIVISION","ORDERTYPE","OOTX40","ORDERTYPEGROUP","ORDERTYPELOCAL" FROM BOUSR.BI_ORDERTYPES_V@LBM3PRD1_BOUSR"


-----------------------------------------------------------------------------------------------------------------------------------------------------

--BOUSR	BI_PRODUCTION_PLAN	



"SELECT M9FACI as DIVISION, work_center as WORKCENTER, ITEMTYPE, ITEMCODE,  PERIOD, sum(MOTRQT_VOL) as LITERS
    FROM(
            SELECT 
            mocono AS cono,
            ROWHLO AS whlo,
            ROWCLN as WORK_CENTER,
            moitno AS itemcode,
            mmitty as itemtype,
            mopldt AS transactiondate,
            to_char(to_date(mopldt,'YYYYMMDD'),'YYYYMM') as PERIOD,
            moorca AS order_category, 
            moridn AS ordernumber, 
            motrqt AS qty_BUM,
            CAST(motrqt*mmvol3 AS NUMBER(17,6)) AS motrqt_VOL   
            
            FROM mvxjdta.mitplo 
            inner join mvxjdta.MMOPLP ON mocono=ROcono AND moridn=ROplpn AND moitno=ROPRNO
            inner join mvxjdta.mitmas ON mocono=mmcono AND moitno=mmitno 
            
            WHERE mocono=100 AND ROFACI!='800' AND moorca='100' AND mmitty IN ('10','40') and MMMABU = '1'
            
       UNION all
            
            SELECT 
            mocono AS cono,
            VHWHLO as whlo,
            VHWCLN AS WORK_CENTER,
            moitno AS itemcode,
            mmitty as itemtype,
            mopldt AS transactiondate,
            to_char(to_date(mopldt,'YYYYMMDD'),'YYYYMM') as PERIOD,
            moorca AS order_category, 
            moridn AS ordernumber, 
            vhorqt as qty_bum,
            CAST(vhorqt*mmvol3 AS NUMBER(17,6)) AS motrqt_VOL
            
            FROM mvxjdta.mitplo
            inner join mvxjdta.MWOHED ON mocono=vhcono AND moridn=VHMFNO AND moitno=vhPRNO
            inner join mvxjdta.mitmas ON mocono=mmcono AND moitno=mmitno
                 
            WHERE mocono=100 AND VHFACI!='800' AND moorca='101' AND mmitty IN ('10','40') and MMMABU = '1'
        )

right join mvxjdta.MITFAC  on cono=m9cono and WHLO=M9REWH  and  M9ITNO=itemcode
where TRANSACTIONDATE > to_char(sysdate-31,'YYYYMMDD') 
group by M9FACI,WORK_CENTER, ITEMTYPE, ITEMCODE, PERIOD

UNION ALL

SELECT "DIVISION","WORKCENTER","ITEMTYPE","ITEMCODE","PERIOD","LITERS" FROM BOUSR.BI_PRODUCTION_PLAN@LBM3PRD1_BOUSR
UNION ALL

SELECT "DIVISION","WORKCENTER","ITEMTYPE","ITEMCODE","PERIOD","LITERS" FROM M3SKY.BI_PRODUCTION_PLAN"

-----------------------------------------------------------------------------------------------------------------------------------------------------

--BOUSR	FPM_ACCOUNT_STRUCTURE	

"SELECT ac.divi,
CASE WHEN lev4.s2stid='0' THEN 'L'||ac.ac ELSE ac.ac END AS ac ,
CASE WHEN lev4.s2stid='0' THEN 'Liters'||SubStr(ac.ac_name,12) ELSE ac.ac_name END AS ac_name,
ac.IN_USE,
lev1.s2aitm||' '||def1.s1tx40 AS F1,
lev2.s2aitm||' '||def2.s1tx40 AS F2,
lev3.s2aitm||' '||def3.s1tx40 AS F3,
lev4.s2aitm||' '||def4.s1tx40 AS F4,
lev4.s2stid||' '||def5.s1tx40 AS F5,
CASE WHEN ac.ac in ('5199009','8011009','8019019','8208039') then '1 Regular'  else 
 case when ac.EARECE=1 then '2 Consolidation' else
    case when ac.ac LIKE '%9' THEN '9 Intragroup' ELSE '1 Regular' END END END  AS consolidation
FROM
(
SELECT eadivi AS divi, eaaitm AS ac, eatx40 AS AC_NAME,EARECE,CASE WHEN ealccd=1 THEN 'BLOCKED' ELSE 'ACTIVE' END AS IN_USE FROM mvxjdta.fchacc WHERE eacono=100 AND eadivi=' ' AND eaaitp='1'
) ac
left join mvxjdta.fstlin lev0 ON lev0.s2cono=100 AND lev0.s2sttp='1'  AND ac.ac=lev0.s2aitm
left join mvxjdta.fstlin lev1 ON lev1.s2cono=lev0.s2cono AND lev1.s2divi=lev0.s2divi AND lev1.s2sttp=lev0.s2sttp AND lev1.s2aitm=lev0.s2stid
left join mvxjdta.fstlin lev2 ON lev2.s2cono=lev0.s2cono AND lev2.s2divi=lev0.s2divi AND lev2.s2sttp=lev0.s2sttp AND lev2.s2aitm=lev1.s2stid
left join mvxjdta.fstlin lev3 ON lev3.s2cono=lev0.s2cono AND lev3.s2divi=lev0.s2divi AND lev3.s2sttp=lev0.s2sttp AND lev3.s2aitm=lev2.s2stid
left join mvxjdta.fstlin lev4 ON lev4.s2cono=lev0.s2cono AND lev4.s2divi=lev0.s2divi AND lev4.s2sttp=lev0.s2sttp AND lev4.s2aitm=lev3.s2stid
left join mvxjdta.fstlin lev5 ON lev5.s2cono=lev0.s2cono AND lev5.s2divi=lev0.s2divi AND lev5.s2sttp=lev0.s2sttp AND lev5.s2aitm=lev4.s2stid
left join mvxjdta.fstdef def1 ON lev1.s2cono=def1.s1cono AND lev1.s2divi=def1.s1divi AND lev1.s2sttp=def1.s1sttp AND lev1.s2aitm=def1.s1stid
left join mvxjdta.fstdef def2 ON lev1.s2cono=def2.s1cono AND lev1.s2divi=def2.s1divi AND lev1.s2sttp=def2.s1sttp AND lev2.s2aitm=def2.s1stid
left join mvxjdta.fstdef def3 ON lev1.s2cono=def3.s1cono AND lev1.s2divi=def3.s1divi AND lev1.s2sttp=def3.s1sttp AND lev3.s2aitm=def3.s1stid
left join mvxjdta.fstdef def4 ON lev1.s2cono=def4.s1cono AND lev1.s2divi=def4.s1divi AND lev1.s2sttp=def4.s1sttp AND lev4.s2aitm=def4.s1stid
left join mvxjdta.fstdef def5 ON lev1.s2cono=def5.s1cono AND lev1.s2divi=def5.s1divi AND lev1.s2sttp=def5.s1sttp AND lev4.s2stid=def5.s1stid
where ac.divi not like '8%'

UNION ALL
SELECT ' ' AS divi, ac, ac_name, IN_USE, F1, F2, F3, F4, F5, CONSOLIDATION FROM M3SKY.FPM_ACCOUNT_STRUCTURE WHERE ac IN ('1006040','2103020','8001003','8001005','8011003','8011005','8012003','8012005',
'8013003','8013005','8019013', '8019015','8021003','8029003','9001003','9001005','9002033','9002073','9002083','9002093','9108121','9108122','9108250','9108260','9108270')

UNION ALL
SELECT "DIVI","AC","AC_NAME","IN_USE","F1","F2","F3","F4","F5","CONSOLIDATION" FROM BOUSR.FPM_ACCOUNT_STRUCTURE@LBM3PRD1_BOUSR WHERE divi like '8%'"

-----------------------------------------------------------------------------------------------------------------------------------------------------


--BOUSR	FPM_CONSOLIDATION_STRUCTURE	

"SELECT str.divi, str.cp,
CASE WHEN bl.eatx40 IS NULL THEN div.eatx40 ELSE bl.eatx40 END AS  cp_name,
str.F1,str.F2,str.f1_name,str.f1_shortname,str.f2_name,str.f2_namecode
FROM
(
    SELECT distinct
    --GM3:
    lev0.s2divi AS divi,cp.cp, lev1.s2aitm AS F1,lev1.s2stid AS F2 ,def1.s1tx40 AS F1_NAME, def1.s1tx15 AS F1_SHORTNAME, def2.s1tx40 AS F2_NAME,
    lev1.s2stid||' '||def2.s1tx15 AS F2_NAMECODE
    FROM
    (SELECT DISTINCT eaaitm AS CP FROM mvxjdta.fchacc WHERE eacono=100 AND eaaitp='4') cp
    left join mvxjdta.fstlin lev0 ON lev0.s2cono=100 AND lev0.s2sttp='4'  AND cp.cp=lev0.s2aitm
    left join mvxjdta.fstlin lev1 ON lev1.s2cono=lev0.s2cono AND lev1.s2sttp=lev0.s2sttp AND lev1.s2aitm=lev0.s2stid
    left join mvxjdta.fstdef def1 ON lev1.s2cono=def1.s1cono AND lev1.s2sttp=def1.s1sttp AND lev1.s2aitm=def1.s1stid
    left join mvxjdta.fstdef def2 ON lev1.s2cono=def2.s1cono AND lev1.s2sttp=def2.s1sttp AND lev1.s2stid=def2.s1stid
    WHERE lev1.s2stid IS NOT null
) str
left join mvxjdta.fchacc bl ON bl.eacono=100 AND bl.eaaitp='4' AND bl.eadivi=' ' AND str.cp=bl.eaaitm
left join mvxjdta.fchacc div ON div.eacono=100 AND div.eaaitp='4' AND div.eadivi=str.divi AND str.cp=div.eaaitm
where str.divi not like '8%'

UNION

SELECT "DIVI","CP","CP_NAME","F1","F2","F1_NAME","F1_SHORTNAME","F2_NAME","F2_NAMECODE" FROM BOUSR.FPM_CONSOLIDATION_STRUCTURE@LBM3PRD1_BOUSR WHERE divi like '8%'"

-----------------------------------------------------------------------------------------------------------------------------------------------------

--BOUSR	FPM_COSTCENTER_STRUCTURE	


"SELECT 
--GM3:
cc.divi,cc.cc ,cc.cc_name,cc.IN_USE, lev1.s2aitm AS F1,lev1.s2stid AS F2, def1.s1tx40 AS F1_NAME, def1.s1tx15 AS F1_SHORTNAME, def2.s1tx40 AS F2_NAME,
lev1.s2stid||' '||def2.s1tx15 AS F2_SHORTNAME, y.yea4 AS yea4 
FROM 
(SELECT eadivi AS divi, eaaitm AS CC, eatx40 AS CC_NAME,CASE WHEN ealccd=1 THEN 'BLOCKED' ELSE 'ACTIVE' END AS IN_USE FROM mvxjdta.fchacc WHERE eacono=100 AND eaaitp='2') cc
full outer join 
              (
               SELECT 2018 AS yea4 FROM dual UNION
               SELECT 2019 AS yea4 FROM dual UNION
               SELECT 2020 AS yea4 FROM dual UNION
               SELECT 2021 AS yea4 FROM dual UNION
               SELECT 2022 AS yea4 FROM dual UNION
               SELECT 2023 AS yea4 FROM dual UNION
               SELECT 2024 AS yea4 FROM dual UNION
               SELECT 2025 AS yea4 FROM dual UNION
               SELECT 2026 AS yea4 FROM dual
               ) y ON 1=1
left join mvxjdta.fstlin lev0 ON lev0.s2cono=100 AND lev0.s2sttp='2' AND cc.divi=lev0.s2divi AND cc.cc=lev0.s2aitm
left join mvxjdta.fstlin lev1 ON lev1.s2cono=lev0.s2cono AND lev1.s2divi=lev0.s2divi AND lev1.s2sttp=lev0.s2sttp AND lev1.s2aitm=lev0.s2stid
left join mvxjdta.fstdef def1 ON lev1.s2cono=def1.s1cono AND lev1.s2divi=def1.s1divi AND lev1.s2sttp=def1.s1sttp AND lev1.s2aitm=def1.s1stid
left join mvxjdta.fstdef def2 ON lev1.s2cono=def2.s1cono AND lev1.s2divi=def2.s1divi AND lev1.s2sttp=def2.s1sttp AND lev1.s2stid=def2.s1stid
WHERE cc.divi!='800' --divi||'_'||y.yea4 NOT IN ('800_2018','800_2019')

union 

--LIDA OLD M3:

select "DIVI","CC","CC_NAME","IN_USE","F1","F2","F1_NAME","F1_SHORTNAME","F2_NAME","F2_SHORTNAME","YEA4" FROM BOUSR.FPM_COSTCENTER_STRUCTURE@LBM3PRD1_BOUSR

ORDER BY divi,f2,f1,cc"
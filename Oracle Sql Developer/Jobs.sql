
  
BEGIN 
dbms_scheduler.create_job('"GM3_ANAPLAN_UPDATES_050000"',
job_type=>'PLSQL_BLOCK', job_action=>
'BEGIN
ANAPLAN.PROC_SALES_DAILY_SUMMARIZE();
ANAPLAN.PROC_SALES_SUMMARIZE();
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''100'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''200'',0);
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''200'',-1);
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''300'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''400'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''600'');
--DBMS_LOCK.SLEEP(60);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''700'',0);
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''700'',-1);
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''800'',0);
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM_DAILY'',''800'',-1);
--DBMS_LOCK.SLEEP(180);
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_PRODUCT'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_CUSTOMER'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_COSTCENTER'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_WORKCENTER'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_PRICELIST'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_COGS_MATERIALS'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''AD_CURRENCYRATES'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''AD_LAST_PURCH_PRICE'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_MARKETINGMONEY'');
--2021.08.21 Dina-This table nightly load can be switched off 
--ANAPLAN.SEND_DATA_NO_CHUNKS(''AD_MARKET_DATA'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_DEPRECIATION_PLAN'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_COGS_RECIPE'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_DELIVERY'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_COGS_OH_COSTING'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_CAMPAIGNS'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''AD_CURRENCYRATES_LAST'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_GL_SUM'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_SALES_SUM'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_COGS_OPERATIONS'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_NATUREBASED_COGS'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_COGS_LATESTCOST'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_DELIVERYDATE'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''OL_FIXEDDISCOUNTS'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''OL_SALESINVOICEDISCOUNTS'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_ACCOUNT_MOVEMENTS'');
--DBMS_LOCK.SLEEP(180);
ANAPLAN.SEND_DATA_NO_CHUNKS(''AD_PURCHASE_AGREEMENT_PRICES'');
--DBMS_LOCK.SLEEP(120);
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_ACCOUNT'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''MD_DELIVERYGROUPS'');
--20231012
ANAPLAN.SEND_DATA_NO_CHUNKS(''AD_COUNTERUNITS'');
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_PRODUCTION_PLAN'');
--20231108
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_ACTUAL_MO_TIME'');
--20241032
ANAPLAN.SEND_DATA_NO_CHUNKS(''AVG_PRICE_UNTIL'');
--20250401
ANAPLAN.SEND_DATA_NO_CHUNKS(''TD_CAPEX'');
END;'
, number_of_arguments=>0,
start_date=>TO_TIMESTAMP_TZ('06-JUN-2023 05.00.15.820313000 AM EUROPE/HELSINKI','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'), repeat_interval=> 
'FREQ=DAILY;BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN'
, end_date=>NULL,
job_class=>'"DEFAULT_JOB_CLASS"', enabled=>FALSE, auto_drop=>FALSE,comments=>
'GM3_ANAPLAN_UPDATES_050000'
);
sys.dbms_scheduler.set_attribute('"GM3_ANAPLAN_UPDATES_050000"','NLS_ENV','NLS_LANGUAGE=''FINNISH'' NLS_TERRITORY=''FINLAND'' NLS_CURRENCY=''€'' NLS_ISO_CURRENCY=''FINLAND'' NLS_NUMERIC_CHARACTERS='', '' NLS_CALENDAR=''GREGORIAN'' NLS_DATE_FORMAT=''DD.MM.RRRR'' NLS_DATE_LANGUAGE=''FINNISH'' NLS_SORT=''FINNISH'' NLS_TIME_FORMAT=''HH24:MI:SSXFF'' NLS_TIMESTAMP_FORMAT=''DD.MM.RRRR HH24:MI:SSXFF'' NLS_TIME_TZ_FORMAT=''HH24:MI:SSXFF TZR'' NLS_TIMESTAMP_TZ_FORMAT=''DD.MM.RRRR HH24:MI:SSXFF TZR'' NLS_DUAL_CURRENCY=''€'' NLS_COMP=''BINARY'' NLS_LENGTH_SEMANTICS=''BYTE'' NLS_NCHAR_CONV_EXCP=''FALSE''');
dbms_scheduler.enable('"GM3_ANAPLAN_UPDATES_050000"');
COMMIT; 
END; 
"
"
  
BEGIN 
dbms_scheduler.create_job('"GM3_FILL_AD_LAST_PURCH_PRICE"',
job_type=>'PLSQL_BLOCK', job_action=>
'BEGIN
delete from ANAPLAN.AD_LAST_PURCH_PRICE where division <> ''800'';
commit;
insert into ANAPLAN.AD_LAST_PURCH_PRICE 
  SELECT 
    p.division as division,
    idsunm as Supplier,
    p.itemcode as L4_CODE,
    p.currency,
    max(maxreceivingdate) as PURCHDATE,
    round(sum(orderamount)/sum(receivedquantity),4) as "PRICE_CURR", /* price per basic unit of measure in purchase currency*/
   round(sum(receivedamount-OrderAmountLocCurr)/sum(receivedquantity),4) as "Charge_LocCurr" 
  from bousr.bi_purchase_recinv_v  p
  inner join (
                           select a.division, a.itemcode, a.suppliercode, a.receivingdate as maxreceivingdate, a.ordernumber as maxordernumber, max(a.orderlinenumber)
                           from bousr.bi_purchase_recinv_v a
                           inner join 
                              (SELECT 
                                division,
                                itemcode,
                                max (receivingdate) over (partition by division,itemcode) as maxreceivingdate,
                                case when max (receivingdate) over (partition by division, itemcode) = receivingdate then ordernumber else '''' end as Maxordernumber
                           FROM
                                bousr.bi_purchase_recinv_v
                                where receivingdate>=''20220101'' 
                            /*Order by division,suppliercode, ordernumber,itemcode,currency, receivingdate,  lineamount,  OrderAmountLocCurr, receivedamount, receivedquantity*/
                          ) b on a.division=b.division and a.ordernumber=Maxordernumber and a.itemcode=b.itemcode and receivingdate=maxreceivingdate
                          group by a.division, a.itemcode, a.suppliercode, a.receivingdate, a.ordernumber
             )   m
     on m.division=p.division and m.itemcode=p.itemcode and m.Maxordernumber=p.ordernumber
    left join mvxjdta.cidmas on idsuno=p.suppliercode
     where p.division <> ''800'' 
     Group by p.division,idsunm, p.itemcode,p.currency
     having sum(receivedquantity)<>0;
commit;
delete from ANAPLAN.AD_LAST_PURCH_PRICE where division in (''800'',''400'');
insert into ANAPLAN.AD_LAST_PURCH_PRICE 
select * from ANAPLAN.AD_LAST_PURCH_PRICE@LBM3PRD1_ANAPLAN WHERE DIVISION = ''800'';
commit;
insert into ANAPLAN.AD_LAST_PURCH_PRICE 
select * from M3SKY_ANAPLAN.AD_LAST_PURCH_PRICE WHERE DIVISION = ''400'';
commit;
END;'
, number_of_arguments=>0,
start_date=>TO_TIMESTAMP_TZ('19-SEP-2022 12.46.14.423592000 PM EUROPE/HELSINKI','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'), repeat_interval=> 
'FREQ=DAILY;BYTIME=010000'
, end_date=>NULL,
job_class=>'"DEFAULT_JOB_CLASS"', enabled=>FALSE, auto_drop=>FALSE,comments=>
'GM3_FILL_AD_LAST_PURCH_PRICE'
);
sys.dbms_scheduler.set_attribute('"GM3_FILL_AD_LAST_PURCH_PRICE"','NLS_ENV','NLS_LANGUAGE=''LITHUANIAN'' NLS_TERRITORY=''LITHUANIA'' NLS_CURRENCY=''$'' NLS_ISO_CURRENCY=''AMERICA'' NLS_NUMERIC_CHARACTERS='',.'' NLS_CALENDAR=''GREGORIAN'' NLS_DATE_FORMAT=''DD-MON-RR'' NLS_DATE_LANGUAGE=''LITHUANIAN'' NLS_SORT=''BINARY'' NLS_TIME_FORMAT=''HH24:MI:SSXFF'' NLS_TIMESTAMP_FORMAT=''DD-MON-RR HH.MI.SSXFF AM'' NLS_TIME_TZ_FORMAT=''HH24:MI:SSXFF TZR'' NLS_TIMESTAMP_TZ_FORMAT=''DD-MON-RR HH.MI.SSXFF AM TZR'' NLS_DUAL_CURRENCY=''Lt'' NLS_COMP=''BINARY'' NLS_LENGTH_SEMANTICS=''BYTE'' NLS_NCHAR_CONV_EXCP=''FALSE''');
dbms_scheduler.enable('"GM3_FILL_AD_LAST_PURCH_PRICE"');
COMMIT; 
END; 
"
"
  
BEGIN 
dbms_scheduler.create_job('"REFRESH_AVG_PRICE_UNTIL"',
job_type=>'STORED_PROCEDURE', job_action=>
'ANAPLAN.PROC_REFRESH_AVG_PRICE_UNTIL'
, number_of_arguments=>0,
start_date=>TO_TIMESTAMP_TZ('22-JAN-2025 03.38.01.736809000 PM EUROPE/HELSINKI','DD-MON-RRRR HH.MI.SSXFF AM TZR','NLS_DATE_LANGUAGE=english'), repeat_interval=> 
'FREQ=DAILY;BYTIME=010000'
, end_date=>NULL,
job_class=>'"DEFAULT_JOB_CLASS"', enabled=>FALSE, auto_drop=>FALSE,comments=>
'refreshes the table with new data'
);
sys.dbms_scheduler.set_attribute('"REFRESH_AVG_PRICE_UNTIL"','NLS_ENV','NLS_LANGUAGE=''LITHUANIAN'' NLS_TERRITORY=''LITHUANIA'' NLS_CURRENCY=''€'' NLS_ISO_CURRENCY=''LITHUANIA'' NLS_NUMERIC_CHARACTERS='', '' NLS_CALENDAR=''GREGORIAN'' NLS_DATE_FORMAT=''RRRR.MM.DD'' NLS_DATE_LANGUAGE=''LITHUANIAN'' NLS_SORT=''LITHUANIAN'' NLS_TIME_FORMAT=''HH24:MI:SSXFF'' NLS_TIMESTAMP_FORMAT=''RRRR.MM.DD HH24:MI:SSXFF'' NLS_TIME_TZ_FORMAT=''HH24:MI:SSXFF TZR'' NLS_TIMESTAMP_TZ_FORMAT=''RRRR.MM.DD HH24:MI:SSXFF TZR'' NLS_DUAL_CURRENCY=''Lt'' NLS_COMP=''BINARY'' NLS_LENGTH_SEMANTICS=''BYTE'' NLS_NCHAR_CONV_EXCP=''FALSE''');
dbms_scheduler.enable('"REFRESH_AVG_PRICE_UNTIL"');
COMMIT; 
END; 
"
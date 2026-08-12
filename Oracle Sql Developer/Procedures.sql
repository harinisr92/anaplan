--GET_file

create or replace PROCEDURE                                 GET_file (model_ varchar, file_ varchar, proc_ varchar) as 

  req        utl_http.req;
  resp       utl_http.resp;
  l_response_header_name varchar2(256);
  l_response_header_value varchar2(1024);
  l_request_body clob;
  v_resp_chunked varchar2(32767);
  l_content_length NUMBER(8);
  workspace varchar2(200) := '8a868cdc877bb0da018807e8234b6307';


  v_resp   CLOB;
  
  
    PROCEDURE SEND(DATA VARCHAR2, METHOD VARCHAR2 := 'POST', iTYPE VARCHAR2 := 'application/json', urlSuffix VARCHAR2 := '') IS
    
            BEGIN


                DBMS_OUTPUT.PUT_LINE('https://10.10.100.200/anaplan/2/0/workspaces/'||workspace||'/models/'||model_||urlSuffix);

                req := utl_http.begin_request(
                        url => 'https://10.10.100.200/anaplan/2/0/workspaces/'||workspace||'/models/'||model_||urlSuffix,
                        method => METHOD,
                        http_version => 'HTTP/1.1'
                    );                    



                utl_http.set_header(req, 'Content-Type',  iTYPE);
                utl_http.set_header(req, 'Content-Length', length(DATA) );
                utl_http.write_text(req, data );

                resp := UTL_HTTP.get_response(req);
                l_content_length := 0;
                DBMS_OUTPUT.PUT_LINE(resp.STATUS_CODE);


                utl_http.end_response(resp);
                utl_http.END_REQUEST(req);

            END;
  
BEGIN
--dbms_output.put_line('https://10.10.100.200/anaplan/2/0/workspaces/'||workspace||'/models/'||model_||'/files/'||file_);

  utl_http.set_wallet(
      path => 'file:/u01/app/oracle/admin/GM3REP1/wallet',
      password => 'WalletPasswd123'
    );
    
    
    SEND('{"localeName":"en_US"}', 'POST', 'application/json', '/processes/'||proc_||'/tasks');
    
    DBMS_LOCK.SLEEP(125); --Jukka added 20231023
    
    dbms_output.put_line('https://10.10.100.200/anaplan/2/0/workspaces/'||workspace||'/models/'||model_||'/files/'||file_);

  req := utl_http.begin_request(
                      url => 'https://10.10.100.200/anaplan/2/0/workspaces/'||workspace||'/models/'||model_||'/files/'||file_,
                      method => 'GET',
                      http_version => 'HTTP/1.1'
                    );

  utl_http.set_header(req, 'Content-Type',  'application/json');
   
  resp := UTL_HTTP.get_response(req);
  
  for i in 1 .. utl_http.get_header_count(resp) loop
    utl_http.get_header(resp, i, l_response_header_name, l_response_header_value);
    dbms_output.put_line('Response Header> ' || l_response_header_name || ': ' || l_response_header_value);
  end loop;
  
   if ( DBMS_LOB.FILEEXISTS(BFILENAME('CSV_DIR',file_ || '.csv')) = 1 ) then
    utl_file.fremove('CSV_DIR',file_ || '.csv');
   end if;

   begin
            DBMS_LOB.createtemporary (v_resp, FALSE);
            loop
                utl_http.read_text(resp, v_resp_chunked, 32767);
                dbms_lob.append(v_resp, v_resp_chunked);
            end loop;
            
            exception
             when utl_http.end_of_body or UTL_HTTP.TOO_MANY_REQUESTS then
                utl_http.end_response(resp);
                dbms_output.put_line('mess:' ||SQLERRM);
                
            --20230911 no need for this, it already generated 17Gb of data here...
            --INSERT INTO anaplan.http_blob_test (id, url, data)
             --VALUES (anaplan.http_blob_test_seq.NEXTVAL, file_, v_resp);
            --clob to file
            anaplan.PRO_WRITE_CLOB_TO_FILE('CSV_DIR',file_ || '.csv',v_resp);

            DBMS_LOB.freetemporary(v_resp);            
   end;
    
  -- Process the response from the HTTP call
    IF resp.status_code = utl_http.HTTP_OK AND resp.reason_phrase = 'OK' THEN
      dbms_output.put_line ('Webservice without errors');
    ELSE
      dbms_output.put_line ('Webservice errors=' || resp.status_code || '-' || resp.reason_phrase);
    END IF;
    utl_http.end_response (resp);

 EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line ('ERROR Others=' || SQLERRM);
    utl_http.end_response (resp);
END;

--GET_FILE2


create or replace PROCEDURE           "GET_FILE2" (workspace_ varchar, model_ varchar, file_ varchar, proc_ varchar) as 

  req        utl_http.req;
  resp       utl_http.resp;
  l_response_header_name varchar2(256);
  l_response_header_value varchar2(1024);
  l_request_body clob;
  v_resp_chunked varchar2(32767);
  l_content_length NUMBER(8);

  v_resp   CLOB;
  
  
    PROCEDURE SEND(DATA VARCHAR2, METHOD VARCHAR2 := 'POST', iTYPE VARCHAR2 := 'application/json', urlSuffix VARCHAR2 := '') IS
    
            BEGIN


                DBMS_OUTPUT.PUT_LINE('https://10.10.100.200/anaplan/2/0/workspaces/'||workspace_||'/models/'||model_||urlSuffix);

                req := utl_http.begin_request(
                        url => 'https://10.10.100.200/anaplan/2/0/workspaces/'||workspace_||'/models/'||model_||urlSuffix,
                        method => METHOD,
                        http_version => 'HTTP/1.1'
                    );                    



                utl_http.set_header(req, 'Content-Type',  iTYPE);
                utl_http.set_header(req, 'Content-Length', length(DATA) );
                utl_http.write_text(req, data );

                resp := UTL_HTTP.get_response(req);
                l_content_length := 0;
                DBMS_OUTPUT.PUT_LINE(resp.STATUS_CODE);


                utl_http.end_response(resp);
                utl_http.END_REQUEST(req);

            END;
  
BEGIN
--dbms_output.put_line('https://10.10.100.200/anaplan/2/0/workspaces/'||workspace||'/models/'||model_||'/files/'||file_);

  utl_http.set_wallet(
      path => 'file:/u01/app/oracle/admin/GM3REP1/wallet',
      password => 'WalletPasswd123'
    );
    
    
    SEND('{"localeName":"en_US"}', 'POST', 'application/json', '/processes/'||proc_||'/tasks');
  
   DBMS_LOCK.SLEEP(30); -- change the parameter to 125  
    dbms_output.put_line('https://10.10.100.200/anaplan/2/0/workspaces/'||workspace_||'/models/'||model_||'/files/'||file_);

  req := utl_http.begin_request(
                      url => 'https://10.10.100.200/anaplan/2/0/workspaces/'||workspace_||'/models/'||model_||'/files/'||file_,
                      method => 'GET',
                      http_version => 'HTTP/1.1'
                    );

  utl_http.set_header(req, 'Content-Type',  'application/json');
   
  resp := UTL_HTTP.get_response(req);
  
  for i in 1 .. utl_http.get_header_count(resp) loop
    utl_http.get_header(resp, i, l_response_header_name, l_response_header_value);
    dbms_output.put_line('Response Header> ' || l_response_header_name || ': ' || l_response_header_value);
  end loop;
  
   if ( DBMS_LOB.FILEEXISTS(BFILENAME('CSV_DIR',file_ || '.csv')) = 1 ) then
    utl_file.fremove('CSV_DIR',file_ || '.csv');
   end if;

   begin
            DBMS_LOB.createtemporary (v_resp, FALSE);
            loop
                utl_http.read_text(resp, v_resp_chunked, 32767);
                dbms_lob.append(v_resp, v_resp_chunked);
            end loop;
            
            exception
             when utl_http.end_of_body or UTL_HTTP.TOO_MANY_REQUESTS then
                utl_http.end_response(resp);
                dbms_output.put_line('mess:' ||SQLERRM);
                
            --20230911 no need for this, it already generated 17Gb of data here...
            --INSERT INTO anaplan.http_blob_test (id, url, data)
            -- VALUES (anaplan.http_blob_test_seq.NEXTVAL, file_, v_resp);
            
            --clob to file
            anaplan.PRO_WRITE_CLOB_TO_FILE('CSV_DIR',file_ || '.csv',v_resp);

            DBMS_LOB.freetemporary(v_resp);            
   end;
    
  -- Process the response from the HTTP call
    IF resp.status_code = utl_http.HTTP_OK AND resp.reason_phrase = 'OK' THEN
      dbms_output.put_line ('Webservice without errors');
    ELSE
      dbms_output.put_line ('Webservice errors=' || resp.status_code || '-' || resp.reason_phrase);
    END IF;
    utl_http.end_response (resp);

 EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line ('ERROR Others=' || SQLERRM);
    utl_http.end_response (resp);
END;

--GET_METADATA

create or replace PROCEDURE           "GET_METADATA" (workspace_ varchar, model_ varchar, type_ varchar DEFAULT 'processes') as 

  req        utl_http.req;
  resp       utl_http.resp;
  l_response_header_name varchar2(256);
  l_response_header_value varchar2(1024);
  l_request_body clob;
  v_resp_chunked varchar2(32767);
  l_content_length NUMBER(8);
  url_ varchar(3000);

BEGIN

  utl_http.set_wallet(
      path => 'file:/u01/app/oracle/admin/GM3REP1/wallet',
      password => 'WalletPasswd123'
    );
    
  url_ := 'https://10.10.100.200/anaplan/2/0/workspaces/' || workspace_ || '/models/' || model_ || '/' || type_;
  dbms_output.put_line ('URL=' || url_);
    
  req := utl_http.begin_request(
                      url => url_,
                      method => 'GET',
                      http_version => 'HTTP/1.1'
                    );

  utl_http.set_header(req, 'Content-Type',  'application/json');

  resp := UTL_HTTP.get_response(req);
  
  for i in 1 .. utl_http.get_header_count(resp) loop
    utl_http.get_header(resp, i, l_response_header_name, l_response_header_value);
    dbms_output.put_line('Response Header> ' || l_response_header_name || ': ' || l_response_header_value);
  end loop;

  loop
    utl_http.read_text(resp, v_resp_chunked, 32767);
    dbms_output.put_line(v_resp_chunked);    
  end loop;

  -- Process the response from the HTTP call
    IF resp.status_code = utl_http.HTTP_OK AND resp.reason_phrase = 'OK' THEN
      dbms_output.put_line ('Webservice without errors');
    ELSE
      dbms_output.put_line ('Webservice errors=' || resp.status_code || '-' || resp.reason_phrase);
    END IF;
    utl_http.end_response (resp);

 EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line ('ERROR Others=' || SQLERRM);
    utl_http.end_response (resp);
END;

--PROC_REFRESH_AVG_PRICE_UNTIL

create or replace procedure         PROC_REFRESH_AVG_PRICE_UNTIL  as
begin
MERGE INTO anaplan.AVG_PRICE_UNTIL dest
USING 
(
WITH AVG_PRICE_UNTIL_tmp AS (
        SELECT 
            MITFAC.M9FACI AS Facility, 
            MITFAC.M9ITNO AS SKU, 
            MITMAS.MMFUDS AS Description, 
            MITFAC.M9FANO AS On_Hand_Balance, 
            MITFAC.M9APPR AS AVG_Cost, 
            dt.MOPLDT as AVG_COST_UNTIL, 
            To_Char(To_Date(dt.MOPLDT,'YYYYMMDD')-16,'YYYYMM') as AVG_UNTIL_PERIOD,
            ROW_NUMBER() OVER (PARTITION BY MITFAC.M9FACI, MITFAC.M9ITNO ORDER BY dt.MOPLDT ASC, dt.MOTIHM ASC, MORIDN ASC) AS rn
        FROM 
            MVXJDTA.MITFAC
        inner JOIN 
            mvxjdta.MITMAS ON MITFAC.M9ITNO = MITMAS.MMITNO
        LEFT JOIN (
            SELECT 
                MOITNO, 
                MWFACI, 
                MOPLDT, 
                MOTIHM, 
                MORIDN, 
                MOTRQT,  
                SUM(MOTRQT) OVER (PARTITION BY MWFACI, MOITNO ORDER BY MWFACI, MOITNO, MOPLDT ASC, MOORCA DESC, MORIDN ASC, MOTIHM ASC) AS Run_Leftovers
            FROM 
                mvxjdta.MITPLO
            inner JOIN  
                MVXJDTA.MITMAS ON MMCONO = 100 AND MOITNO = MITMAS.MMITNO
            inner JOIN  
                MVXJDTA.MITWHL ON MWWHLO = MOWHLO
            WHERE 
                mocono = '100' 
                AND MITMAS.MMITTY IN ('20', '30', '85')
                AND MOORCA IN ('110', '111')
                and mwdivi!='800' and MWFACI!='800'
            ORDER BY 
                MWFACI, MOITNO, MOPLDT, MORIDN, MOTIHM
        ) dt ON dt.MOITNO = MITFAC.M9ITNO AND dt.MWFACI = MITFAC.M9FACI 
        WHERE  
            MITFAC.M9FANO > 0 
            AND MITMAS.MMITTY IN ('20', '30', '85') 
            AND MITFAC.M9FANO + nvl(Run_Leftovers,0) <= 0
            and M9FACI!='800' 
    ),
AVG_PRICE_UNTIL2_tmp AS (
    SELECT 
        MITFAC.M9FACI AS Facility, 
        MITFAC.M9ITNO AS SKU, 
        MITMAS.MMFUDS AS Description, 
        MITFAC.M9FANO AS On_Hand_Balance, 
        MITFAC.M9APPR AS AVG_Cost, 
        dt.MOPLDT as AVG_COST_UNTIL, 
        To_Char(Add_Months(Sysdate, 17), 'YYYYMM') as AVG_UNTIL_PERIOD,
        ROW_NUMBER() OVER (PARTITION BY MITFAC.M9FACI, MITFAC.M9ITNO ORDER BY dt.MOPLDT DESC, dt.MOTIHM DESC, MORIDN DESC) AS rn
    FROM 
        MVXJDTA.MITFAC
    LEFT JOIN 
        mvxjdta.MITMAS ON MITFAC.M9ITNO = MITMAS.MMITNO
    LEFT JOIN (
        SELECT 
            MOITNO, 
            MWFACI, 
            MOPLDT, 
            MOTIHM, 
            MORIDN, 
            MOTRQT,  
            SUM(MOTRQT) OVER (PARTITION BY MWFACI, MOITNO ORDER BY MWFACI, MOITNO, MOPLDT ASC, MOORCA DESC, MORIDN ASC, MOTIHM ASC) AS Run_Leftovers
        FROM 
            mvxjdta.MITPLO
        inner JOIN  
            MVXJDTA.MITMAS ON MMCONO = 100 AND MOITNO = MITMAS.MMITNO
        inner JOIN  
            MVXJDTA.MITWHL ON MWWHLO = MOWHLO
        WHERE 
            mocono = '100' 
            AND MITMAS.MMITTY IN ('20', '30', '85')
            AND MOORCA IN ('110', '111')
            AND mwdivi != '800' 
            AND MWFACI != '800'
        --ORDER BY 
        --    MWFACI, MOITNO, MOPLDT, MORIDN, MOTIHM
    ) dt ON dt.MOITNO = MITFAC.M9ITNO AND dt.MWFACI = MITFAC.M9FACI 
    WHERE  
        MITFAC.M9FANO > 0 
        AND MITMAS.MMITTY IN ('20', '30', '85') 
        AND MITFAC.M9FANO + Run_Leftovers > 0
        AND M9FACI != '800' 
    ),
AVG_PRICE_UNTIL_tmp3 AS 
    (
            SELECT 
                MITFAC.M9FACI AS Facility, 
                MITFAC.M9ITNO AS SKU, 
                MITMAS.MMFUDS AS Description, 
                MITFAC.M9FANO AS On_Hand_Balance, 
                MITFAC.M9APPR AS AVG_Cost, 
                dt.MOPLDT as AVG_COST_UNTIL, 

                To_Char(Add_Months(Sysdate, 17), 'YYYYMM') as AVG_UNTIL_PERIOD,
                ROW_NUMBER() OVER (PARTITION BY MITFAC.M9FACI, MITFAC.M9ITNO ORDER BY dt.MOPLDT DESC, dt.MOTIHM DESC, MORIDN DESC) AS rn
            FROM 
                MVXJDTA.MITFAC
            inner JOIN 
                mvxjdta.MITMAS ON MITFAC.M9ITNO = MITMAS.MMITNO
            LEFT JOIN (
                SELECT 
                    MOITNO, 
                    MWFACI, 
                    MOPLDT, 
                    MOTIHM, 
                    MORIDN, 
                    MOTRQT,  
                    SUM(MOTRQT) OVER (PARTITION BY MWFACI, MOITNO ORDER BY MWFACI, MOITNO, MOPLDT ASC, MOORCA DESC, MORIDN ASC, MOTIHM ASC) AS Run_Leftovers            
                FROM 
                    mvxjdta.MITPLO
                inner JOIN  
                    MVXJDTA.MITMAS ON MMCONO = 100 AND MOITNO = MITMAS.MMITNO
                inner JOIN  
                    MVXJDTA.MITWHL ON MWWHLO = MOWHLO

                WHERE 
                    mocono = '100' 
                    AND MITMAS.MMITTY IN ('20', '30', '85')
                    AND MOORCA IN ('110', '111')

                    AND mwdivi != '800' 
                    AND MWFACI != '800'
                --ORDER BY 
                    --MWFACI, MOITNO, MOPLDT, MORIDN, MOTIHM
            ) dt ON dt.MOITNO = MITFAC.M9ITNO AND dt.MWFACI = MITFAC.M9FACI 

            LEFT JOIN (
                SELECT 
                    pmFACI AS Facility, 
                    pmMTNO AS SKU, 
                    COUNT(*) AS Row_Count
                FROM 
                    MVXJDTA.MPDMAT
                GROUP BY 
                    pmFACI, 
                    pmMTNO
            ) mp ON mp.Facility = MITFAC.M9FACI AND mp.SKU = MITFAC.M9ITNO

            WHERE  
                MITFAC.M9FANO > 0 
                AND MITMAS.MMITTY IN ('20', '30', '85') 
                and dt.MOPLDT is null
                AND M9FACI != '800' 
                AND mp.Row_Count IS NOT NULL               
        ),
MISSING_ROWS_TMP2 AS 
    (
    SELECT 
        AVG_PRICE_UNTIL2_tmp.*
    FROM 
        AVG_PRICE_UNTIL2_tmp
    LEFT JOIN 
        AVG_PRICE_UNTIL_tmp ON AVG_PRICE_UNTIL2_tmp.Facility = AVG_PRICE_UNTIL_tmp.Facility AND AVG_PRICE_UNTIL2_tmp.SKU = AVG_PRICE_UNTIL_tmp.SKU
    WHERE 
        AVG_PRICE_UNTIL_tmp.Facility IS NULL
    ),
MISSING_ROWS_TMP3 AS (
        SELECT 
            AVG_PRICE_UNTIL_tmp3.*
        FROM 
            AVG_PRICE_UNTIL_tmp3
        LEFT JOIN 
            AVG_PRICE_UNTIL_tmp ON AVG_PRICE_UNTIL_tmp3.Facility = AVG_PRICE_UNTIL_tmp.Facility AND AVG_PRICE_UNTIL_tmp3.SKU = AVG_PRICE_UNTIL_tmp.SKU
        WHERE 
            AVG_PRICE_UNTIL_tmp.Facility IS NULL
    ),        
AVG_PRICE_UNTIL_tmp_final as 
    (
        SELECT  Facility, SKU, Description, On_Hand_Balance, AVG_Cost, AVG_COST_UNTIL, AVG_UNTIL_PERIOD
        FROM AVG_PRICE_UNTIL_tmp 
        WHERE rn = 1

        union

        SELECT Facility, SKU, Description, On_Hand_Balance, AVG_Cost, AVG_COST_UNTIL, AVG_UNTIL_PERIOD
        FROM MISSING_ROWS_TMP3
        WHERE rn = 1    

        union

        SELECT Facility, SKU, Description, On_Hand_Balance, AVG_Cost, AVG_COST_UNTIL, AVG_UNTIL_PERIOD
        FROM MISSING_ROWS_TMP3
        WHERE rn = 1    
    )
    select coalesce(tmp.FACILITY,perm.FACILITY) FACILITY, 
           coalesce(tmp.SKU,perm.SKU) SKU, 
           coalesce(tmp.Description,perm.Description) Description, 
           coalesce(tmp.On_Hand_Balance,perm.On_Hand_Balance) On_Hand_Balance, 
           coalesce(tmp.AVG_Cost,perm.AVG_Cost) AVG_Cost, 
           coalesce(tmp.AVG_COST_UNTIL,perm.AVG_COST_UNTIL) AVG_COST_UNTIL, 
           coalesce(tmp.AVG_UNTIL_PERIOD,perm.AVG_UNTIL_PERIOD) AVG_UNTIL_PERIOD, 
       nvl(tmp.FACILITY,'Y') as TO_DEL
    from AVG_PRICE_UNTIL_tmp_final tmp 
     full outer join AVG_PRICE_UNTIL perm on tmp.FACILITY=perm.FACILITY and tmp.SKU=perm.SKU
) sourc

ON (dest.FACILITY = sourc.FACILITY and dest.SKU=sourc.SKU) 
WHEN MATCHED THEN UPDATE 
 SET
 dest.On_Hand_Balance=sourc.On_Hand_Balance,
 dest.AVG_Cost=sourc.AVG_Cost,
 dest.AVG_COST_UNTIL=sourc.AVG_COST_UNTIL,
 dest.AVG_UNTIL_PERIOD=sourc.AVG_UNTIL_PERIOD
 DELETE WHERE TO_DEL = 'Y'
WHEN NOT MATCHED THEN INSERT  
 (dest.FACILITY, dest.SKU, dest.DESCRIPTION, dest.ON_HAND_BALANCE, dest.AVG_COST, dest.AVG_COST_UNTIL, dest.AVG_UNTIL_PERIOD)
 VALUES (sourc.FACILITY, sourc.SKU, sourc.DESCRIPTION, sourc.ON_HAND_BALANCE, sourc.AVG_COST, sourc.AVG_COST_UNTIL, sourc.AVG_UNTIL_PERIOD)
;

commit;

--and add LIDSKOE data
insert into anaplan.AVG_PRICE_UNTIL 
select * from AVG_PRICE_UNTIL@LBM3PRD1_ANAPLAN;
commit;

insert into anaplan.AVG_PRICE_UNTIL 
select * from M3SKY_ANAPLAN.AVG_PRICE_UNTIL
commit;

end PROC_REFRESH_AVG_PRICE_UNTIL;


--PROC_SALES_DAILY_SUMMARIZE


create or replace PROCEDURE                                                                                                                                                                                         PROC_SALES_DAILY_SUMMARIZE AS 
     fromperiod varchar(20);
    toperiod varchar(20);

BEGIN
--declare periods to update 
fromperiod :=   
--'202301';   
--/*conventional: from previous month  */ 
to_char(add_months(sysdate,-1), 'YYYYMM'); 
toperiod :=     
--'202401'; 
--/*conventional: to current  month */    
to_char(sysdate, 'YYYYMM'); 

--materialise customer master data to table:

DELETE FROM anaplan.MD_CUSTOMER_DETAIL_T   ;
INSERT INTO anaplan.MD_CUSTOMER_DETAIL_T 
select * FROM  anaplan.MD_CUSTOMER_DETAIL  ;
commit;
--BY data nowadays is separated
--begin
    --INSERT INTO anaplan.MD_CUSTOMER_DETAIL_T 
    --select * FROM  anaplan.MD_CUSTOMER_DETAIL@LBM3PRD1_ANAPLAN  ;
    --exception when others then null;
    --commit;
--end;


--DAILY VOLUME DATA:
--delete transactional sales volumes daily data between periods selected (standard = current + previous month)
delete from anaplan.td_sales_sum_daily_full where substr(invoicedate,0,6) between fromperiod and toperiod;    --FULL TABLE
delete from anaplan.td_sales_sum_daily_full where division in ('100','300','400') and invoicedate = 0;
--insert transactional sales volumes daily data
insert into anaplan.td_sales_sum_daily_full        /*                                                            --FULL TABLE*/ 
 
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
CAST(null AS varchar(108) ) AS attr1,
CAST(null AS varchar(108) ) AS attr2,
CAST(null AS varchar(108) ) AS attr3,
CAST(decode(trim(to_char(dta.campaign)),'1','1',null,'0','0') AS VARCHAR(108)) AS campaign
FROM 
(

SELECT ss.division AS divi, To_Char(ss.invoicedate) AS invoicedate,To_Char(ss.deliverydate) AS deliverydate,ss.customercode, ss.itemcode,
ss.INVOICEQUANTITY*c.volume AS volume, ss.ORDERQUANTITY*c.volume as ORDER_VOLUME, ss.EXTRA1 as campaign
FROM bousr.bi_sales ss
inner JOIN bousr.bi_ordertypes_v ot ON ot.division=ss.division AND ot.ordertype=ss.ordertype
inner join  bousr.BI_PRODUCT c on ss.COMPANYCODE=c.COMPANYCODE	and ss.ITEMCODE=c.ITEMCODE  
WHERE 
  ((SubStr(invoicedate,0,6) between fromperiod and toperiod  OR SubStr(deliverydate,0,6) between fromperiod and toperiod) or (ss.DIVISION in ('100','300','400') and invoicedate = 0 and SubStr(deliverydate,0,6) between fromperiod and toperiod))
  AND ot.ordertypegroup='NORMAL'
  AND c.itemtype='10' 
  and (ss.IID='X' OR (ss.DIVISION in ('100','300','400')))
) dta
left join ANAPLAN.MD_CUSTOMER_DETAIL_T cu ON cu.m3customercode=dta.customercode 
GROUP BY 
cu.division||'-'||cu.l2_saleschannel||'-'||cu.l3_code||'-'||cu.l4_code||CASE WHEN cu.l5_code=cu.l4_code THEN '' ELSE '-'||cu.l5_code END||'-'||cu.l6_code, 
dta.divi,dta.itemcode,dta.invoicedate,dta.deliverydate, decode(trim(to_char(dta.campaign)),'1','1',null,'0','0');
commit;

--2.1. Copy from FULL table to Anaplan source table:

delete from anaplan.td_sales_sum_daily where (SubStr(invoicedate,0,6) between fromperiod and toperiod) OR SubStr(deliverydate,0,6) between fromperiod and toperiod or (invoicedate = 0 and SubStr(deliverydate,0,6) between fromperiod and toperiod);
insert into anaplan.td_sales_sum_daily
(
--SELECT * FROM anaplan.td_sales_sum_daily_full
SELECT DIVISION, INVOICEDATE, DELIVERYDATE, CUSTOMERCODE, ITEMCODE, REPLACE(TO_CHAR(VOLUME),'.',',') AS VOLUME,REPLACE(TO_CHAR(ORDER_VOLUME),'.',',') AS ORDER_VOLUME, DECODE(CAMPAIGN,NULL,'0',CAMPAIGN) AS CAMPAIGN FROM anaplan.td_sales_sum_daily_full 
WHERE (SubStr(invoicedate,0,6) between fromperiod and toperiod) OR SubStr(deliverydate,0,6) between fromperiod and toperiod or (invoicedate = 0 and SubStr(deliverydate,0,6) between fromperiod and toperiod)
); 

--insert into anaplan.td_sales_sum_daily 
--select * FROM m3sky_anaplan.td_sales_sum_daily
--WHERE (SubStr(invoicedate,0,6) between fromperiod and toperiod) OR SubStr(deliverydate,0,6) between fromperiod and toperiod or (invoicedate = 0 and SubStr(deliverydate,0,6) between fromperiod and toperiod);

commit;
END PROC_SALES_DAILY_SUMMARIZE;


--PROC_SALES_SUMMARIZE


create or replace PROCEDURE                                                                                                 PROC_SALES_SUMMARIZE AS 
    fromperiod varchar(20);
    toperiod varchar(20);

BEGIN
--declare periods to update 
fromperiod :=   
--'202501';
--'202301';  --/*conventional: from previous month  */ 
to_char(add_months(sysdate,-1), 'YYYYMM'); 
toperiod :=     
-- '202401'; --/*conventional: to current  month */    
to_char(sysdate, 'YYYYMM'); 

--materialise customer master data to table:

DELETE FROM anaplan.MD_CUSTOMER_DETAIL_T   ;
INSERT INTO anaplan.MD_CUSTOMER_DETAIL_T (select * FROM  anaplan.MD_CUSTOMER_DETAIL)  ;
commit;

--1 MONTHLY ALL MEASURES DATA
--delete transactional sales data between periods selected (standard = current + previous month) - FULL table
delete from anaplan.td_sales_sum_full where period between fromperiod and toperiod;
--delete from anaplan.td_sales_sum_full where period between 202001 and 202012 and division='300';
--insert transactional sales data                                                                - FULL table
insert into anaplan.td_sales_sum_full 
(
SELECT
CAST((dta.divi) AS VARCHAR(108)) AS division,
CAST((dta.period) AS VARCHAR(108)) AS period,
CAST((cu.division||'-'||cu.l2_saleschannel||'-'||cu.l3_code||'-'||cu.l4_code||CASE WHEN cu.l5_code=cu.l4_code THEN '' ELSE '-'||cu.l5_code END||'-'||cu.l6_code) AS VARCHAR(108)) AS customercode,
CAST((dta.itemcode) AS VARCHAR(108)) AS itemcode,
Round(Sum(dta.volume),4) AS volume,
Round(Sum(dta.gross),4) AS gross,
Round(Sum(dta.discount),4) AS discount,
Round(Sum(dta.excise),4) AS excise,
Round(Sum(dta.depofee),4) AS depofee,
Round(Sum(dta.salesbonus),4) AS salesbonus,
Round(Sum(dta.netsales-dta.salesbonus),4) AS netsales,
Round(Sum(dta.cogs),4) AS cogs,
Round(Sum(dta.promodiscount),4) AS promodiscount,
CAST((0) AS NUMBER ) AS ext_m1,
CAST((0) AS NUMBER ) AS ext_m2,
CAST((0) AS NUMBER ) AS ext_m3,
CAST(null AS varchar(108) ) AS attr1,
CAST(null AS varchar(108) ) AS attr2,
CAST(null AS varchar(108) ) AS attr3,
Round(Sum(dta.deliverycost),4) AS deliverycost, 
Round(Sum(dta.campaignvolume),4) AS campaignvolume

FROM

(
--BI_SALES from OSBSTD, aggregated to month (pure M3):

SELECT md.divi,
To_Char(period) AS period,
CASE WHEN cv.newcustomer IS NULL THEN md.customercode ELSE cv.newcustomer END AS customercode,
itemcode,
Sum(md.volume) AS volume,
Sum(md.netsales) AS netsales,
Sum(md.discount) AS discount,
0 AS promodiscount,
Sum(md.excise) AS excise,
Sum(md.depofee) AS depofee,
0 AS salesbonus,
Sum(md.gross) AS gross,
Sum(md.totalcogs) AS cogs,
0 AS deliverycost, 
Sum(CASE WHEN md.divi IN ('100','300') THEN 0 WHEN extra4='0' THEN 0 WHEN extra4 IS NULL THEN 0 WHEN extra4=' ' THEN 0 WHEN extra4='' THEN 0 ELSE md.volume END) AS campaignvolume
FROM bousr.prep_monthlysales md
left join anaplan.ad_customer_conversion cv ON md.divi=cv.divi AND md.customercode=cv.oldcustomer 
inner JOIN bousr.bi_ordertypes_v ot ON /* ot.division=md.divi AND */ ot.ordertype=md.ordertype
WHERE  /*md.divi!='800' and*/ md.period between fromperiod and toperiod  AND ot.ordertypegroup='NORMAL'
GROUP BY md.divi, period,CASE WHEN cv.newcustomer IS NULL THEN md.customercode ELSE cv.newcustomer END,itemcode

union all

SELECT bodivi as divi, cast(boperi as VARCHAR(108)) as period, 
CASE WHEN cv.newcustomer IS NULL THEN (case when bocuno is NULL then bopyno ELSE BOCUNO END) ELSE cv.newcustomer END AS customercode,
boitno as itemcode,
0 as volume,
0 AS netsales,
Sum(DECODE(botype,'DISCOUNT',boboam,0)) AS discount,
Sum(DECODE(botype,'PROMO',boboam,0)) AS promodiscount,
0 AS excise,
0 AS depofee,
Sum(DECODE(botype,'SALESBONUS',boboam,0)) AS salesbonus,
0 AS gross,
0 AS cogs,
0 AS deliverycost, 
0 AS campaignvolume
FROM bousr.prep_salesadjustments 
left join anaplan.AD_CUSTOMER_CONVERSION cv ON bodivi=cv.divi AND case when bocuno is NULL then bopyno ELSE BOCUNO END=cv.oldcustomer 
--WHERE ((bodivi!='800' AND botype='SALESBONUS') or (bodivi='800' AND botype in ('SALESBONUS','PROMO','DISCOUNT'))) AND boperi between fromperiod and toperiod
WHERE (botype='SALESBONUS' or (bodivi='800' AND botype in ('PROMO','DISCOUNT'))) AND boperi between fromperiod and toperiod
GROUP BY bodivi, boperi, CASE WHEN cv.newcustomer IS NULL THEN (case when bocuno is NULL then bopyno ELSE BOCUNO END) ELSE cv.newcustomer END, boitno
) dta
LEFT JOIN ANAPLAN.MD_CUSTOMER_DETAIL_T cu ON cu.m3customercode=dta.customercode and dta.divi=cu.division
GROUP BY
cu.division||'-'||cu.l2_saleschannel||'-'||cu.l3_code||'-'||cu.l4_code||CASE WHEN cu.l5_code=cu.l4_code THEN '' ELSE '-'||cu.l5_code END||'-'||cu.l6_code,dta.divi,dta.itemcode,dta.period);
commit;

delete from anaplan.td_sales_sum where period between fromperiod and toperiod;
insert into anaplan.td_sales_sum (select * from anaplan.td_sales_sum_full where period between fromperiod and toperiod);

delete from anaplan.td_sales_sum where DIVISION='400' and period between fromperiod and toperiod;
insert into anaplan.td_sales_sum (select * from m3sky_anaplan.td_sales_sum where division='400' and period between fromperiod and toperiod);
commit;
END;


--PRO_ANAPLAN_01


create or replace PROCEDURE                           "PRO_ANAPLAN_01" (INMSGN VARCHAR2) AS 
          
        f_location	    CONSTANT VARCHAR2(80) := '/jtt/oracle/xml/utlprod/ana';
        f_filename	    VARCHAR2(80);
        f_filename_new	VARCHAR2(80);
        f_fileline	    VARCHAR2(32767);
        csv_full_sql    VARCHAR2(32767);
        f_filehand	    UTL_FILE.FILE_TYPE;

        TYPE curtype IS REF CURSOR;
        l_cursor        curtype;
        l_param         number;
        l_key           number;
        l_value         number;
        l_sql           varchar2(2000);
        
        http_req utl_http.req;
        http_resp utl_http.resp;
        resp XMLType;
        
BEGIN
  --l_sql   := 'SELECT LISTROWS FROM ANAPLAN.'||INMSGN||'_TOA ORDER BY INDE';
   
  l_sql :=  'select ''' || create_dynamic_list(INMSGN,';') ||''' from dual'||
            ' union all ' ||                   
            'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'   
            from '||INMSGN;
  
        --DBMS_OUTPUT.put_line('l_sql='||l_sql);

  open l_cursor for l_sql;
  
          --DBMS_OUTPUT.put_line('cursor opened');
  
  fetch l_cursor into f_fileline;

  if l_cursor%found then
--    DBMS_OUTPUT.put_line('found');
    f_filename := INMSGN||'.csv';
    f_filehand := UTL_FILE.FOPEN(f_location, f_filename,'W');
    UTL_FILE.PUT_LINE(f_filehand,f_fileline);    
    loop
      fetch l_cursor into f_fileline;
      exit when l_cursor%notfound;
      UTL_FILE.PUT_LINE(f_filehand,f_fileline);
--      dbms_output.put_line('f_fileline = '||f_fileline);
    end loop;
    UTL_FILE.FCLOSE(f_filehand);
  end if;
  close l_cursor;

  -- load certificate from wallet
  /*
  UTL_HTTP.set_wallet('file:/u01/app/oracle/admin/GM3REP1/wallet', 'WalletPasswd123');
  
    http_req:= utl_http.begin_request
              
            ('https://10.10.100.200/anaplan/2/0/workspaces/8a868cd97dc4162b017e59e7ad353677/models/1996A82FE68C4E61BBF83C7864B5F5A3/files/' 
            , 'GET'
            , 'HTTP/1.1'
            );
  
  --UTL_HTTP.set_authentication(http_req,'jukka.tanskanen@olvi.fi','Kesaloma1#');
  --utl_http.set_header(http_req, 'Content-Type', 'text/xml'); -- since we are dealing with plain text in XML documents
  UTL_HTTP.SET_HEADER(req, 'Content-Type', 'application/json');
  utl_http.set_header(http_req, 'Content-Length', length(soap_request));
  --utl_http.set_header(http_req, 'SOAPAction', ''); -- required to specify this is a SOAP communication

  UTL_HTTP.WRITE_text(req,  l_content);
  resp := utl_http.get_response(req); 
  dbms_output.put_line('Response');
  LOOP
    utl_http.read_line(resp, l_value, TRUE);
    dbms_output.put_line('Value......'||l_value);
  END LOOP;
  utl_http.end_response(resp);
EXCEPTION
  WHEN utl_http.end_of_body THEN
    utl_http.end_response(resp);
  WHEN OTHERS THEN
    dbms_output.put_line('Error');

  i:=0;
  loop
    dbms_output.put_line(substr(soap_respond,1+ i*255,250));
    i:= i+1;
    if i*250> length(soap_respond)
    then
      exit;
    end if;
  end loop;
  
  */
END PRO_ANAPLAN_01;


--pro_write_clob_to_file


create or replace PROCEDURE         pro_write_clob_to_file
(
  in_dir_name     IN VARCHAR2,
  in_file_name    IN VARCHAR2,
  in_clob         IN CLOB
)
AS 
BEGIN
  dbms_xslprocessor.clob2file
  (
    in_clob, 
    in_dir_name, 
    in_file_name
  );
END PRO_WRITE_CLOB_TO_FILE;


--SEND_DATA


create or replace PROCEDURE                                   "SEND_DATA" (INMSGN VARCHAR2, DIVI VARCHAR2 DEFAULT '0', MONT NUMBER DEFAULT 0) AS 

--DECLARE
    
    FILID      VARCHAR2(200);
    PROID      VARCHAR2(200);
    
    req        utl_http.req;
    resp       utl_http.resp;
    l_rc_key UTL_HTTP.REQUEST_CONTEXT_KEY;
    v_content  clob;
    amount     number := 2000;
    req_length NUMBER;
    v_offset   NUMBER := 1;
    v_buffer   varchar2(4000);
    split_chunks_line  varchar2(1000);
    l_response_header_name varchar2(256);
    l_response_header_value varchar2(1024);
    l_content_length NUMBER(8);
    l_request_body clob;
    l_response_body varchar2(32767);

    TYPE curtype IS REF CURSOR;
    l_cursor        curtype;
    l_param         number;
    l_key           number;
    l_value         number;
    l_sql           varchar2(2000);
    f_fileline      VARCHAR2(32767);
    f_fileline2     VARCHAR2(32767);
    --INMSGN           varchar2(20)  := 'MD_PRODUCT';
    
    default_sleep_time number := 20;

    type t_chunk is table of varchar2(32767);

    chunks t_chunk := t_chunk();
    lastLength NUMBER;
    
    
    procedure addToChunks(data varchar2) IS
        N NUMBER;
        L NUMBER;
        BEGIN
            L := LENGTH(data);
            IF (chunks.COUNT = 0) THEN
                lastLength := 0;
                chunks.EXTEND;
                N := chunks.last;
            ELSE
                N := chunks.last;
                lastLength := length(chunks(N));
            end if;
            IF (lastLength + L >=10000) THEN
                chunks.EXTEND;
                N := chunks.LAST;
                lastLength := 0;
            end if;
            chunks(N) := chunks(N) || data;
        end;
        
        
    PROCEDURE SEND(DATA VARCHAR2, METHOD VARCHAR2 := 'POST', iTYPE VARCHAR2 := 'application/json', urlSuffix VARCHAR2 := '') IS
    
            BEGIN

/*                req := utl_http.begin_request(
                        url => 'https://10.10.100.200/anaplan/2/0/workspaces/8a868cd97dc4162b017e59e7ad353677/models/408CEFC3C84B43C19F5A3B448273DDF8'||urlSuffix,
                        method => METHOD,
                        http_version => 'HTTP/1.1'
                    );                    
*/

                req := utl_http.begin_request(
                        url => 'https://10.10.100.200/anaplan/2/0/workspaces/8a868cd97dc4162b017e59e7ad353677/models/197C1C80439046AD8BAE11CFF86C0552'||urlSuffix,
                        method => METHOD,
                        http_version => 'HTTP/1.1'
                    );                    



                utl_http.set_header(req, 'Content-Type',  iTYPE);
                utl_http.set_header(req, 'Content-Length', length(DATA) );
                --utl_http.set_header(req, 'encoding', 'UTF-8' );
                utl_http.write_text(req, data );

                resp := UTL_HTTP.get_response(req);
                l_content_length := 0;
                IF resp.STATUS_CODE <> '204' THEN
                  DBMS_OUTPUT.PUT_LINE(INMSGN||' DIVI = '||DIVI||' STATUS = '||resp.STATUS_CODE);
                END IF;
--                DBMS_OUTPUT.PUT_LINE(iTYPE);
--                DBMS_OUTPUT.PUT_LINE(length(DATA));
--                DBMS_OUTPUT.PUT_LINE(convert(data, 'UTF8', 'WE8ISO8859P1' ));

--                for i in 1 .. utl_http.get_header_count(resp) loop
--                        utl_http.get_header(resp, i, l_response_header_name, l_response_header_value);
--                        dbms_output.put_line('Response Header> ' || l_response_header_name || ': ' || l_response_header_value);
--                        if (l_response_header_name = 'Content-Length') THEN
--                            l_content_length := l_response_header_value;
--                        end if;
--                    end loop;
--                if (resp.status_code != 204) AND l_content_length = 0 THEN
--                    l_content_length := 32767;
--                end if;
--                if (l_content_length > 0) THEN
--                    utl_http.read_text(resp, l_response_body, l_content_length);
--                    dbms_output.put_line('Response body>');
--                    dbms_output.put_line(l_response_body);
--                end if;

                utl_http.end_response(resp);
                utl_http.END_REQUEST(req);

            end;
BEGIN

    FILID := '1';
    PROID := '1';
    

    IF INMSGN = 'MD_PRODUCT' THEN
            FILID := '113000000194';
            PROID := '118000000001';
            default_sleep_time := 0;

    END IF;
    IF INMSGN = 'MD_CUSTOMER' THEN
            FILID := '113000000195';
            PROID := '118000000002';
    END IF;
    IF INMSGN = 'MD_ACCOUNT' THEN
            FILID := '113000000210';
            PROID := '118000000004';
    END IF;
    IF INMSGN = 'MD_COSTCENTER' THEN
            FILID := '113000000150';
            PROID := '118000000003';
    END IF;
    IF INMSGN = 'MD_WORKCENTER' THEN
            FILID := '113000000140';
            PROID := '118000000016';
    END IF;
    IF INMSGN = 'MD_PRICELIST' THEN
            FILID := '113000000106';
            PROID := '118000000013';
    END IF;
    IF INMSGN = 'MD_COGS_MATERIALS' THEN
            FILID := '113000000125';
            PROID := '118000000010';
            default_sleep_time := 300;
    END IF;
    IF INMSGN = 'TD_GL_SUM' THEN
            FILID := '113000000087';
--            FILID := '113000000087';
            PROID := '118000000008';
    END IF;
    IF INMSGN = 'TD_SALES_SUM' THEN
--            FILID := '113000000153';
            FILID := '113000000153';
            PROID := '118000000006';
    END IF;
    IF INMSGN = 'AD_LAST_PURCH_PRICE' THEN
--            FILID := '113000000121';
            FILID := '113000000121';
            PROID := '118000000021';
    END IF;
    IF INMSGN = 'TD_MARKETINGMONEY' THEN
            FILID := '113000000168';
            PROID := '118000000020';
    END IF;
    IF INMSGN = 'AD_MARKET_DATA' THEN
            FILID := '113000000165';
            PROID := '118000000014';
    END IF;
    IF INMSGN = 'TD_DEPRECIATION_PLAN' THEN
            FILID := '113000000158';
            PROID := '118000000012';
    END IF;
    IF INMSGN = 'TD_COGS_RECIPE' THEN
            FILID := '113000000096';
            PROID := '118000000011';
    END IF;
    IF INMSGN = 'TD_DELIVERY' THEN
            FILID := '113000000089';
            PROID := '118000000007';
    END IF;
    IF INMSGN = 'TD_SALES_SUM_DAILY' THEN
            FILID := '113000000093';
            PROID := '118000000009';
    END IF;
    IF INMSGN = 'AD_CURRENCYRATES' THEN
            FILID := '113000000155';
            PROID := '118000000022';
    END IF;
    
    IF INMSGN = 'TD_COGS_OH_COSTING' THEN
--            FILID := '113000000182';
            FILID := '113000000199';
            PROID := '118000000027';
    END IF;
    
    IF INMSGN = 'TD_CAMPAIGNS' THEN
            FILID := '113000000207';
            PROID := '118000000035';
    END IF;
    
    IF INMSGN = 'AD_CURRENCYRATES_LAST' THEN
            FILID := '113000000184';
            PROID := '118000000031';
    END IF;
    
    IF INMSGN = 'TD_COGS_OPERATIONS' THEN
            FILID := '113000000139';
            PROID := '118000000017';
    END IF;

    IF INMSGN = 'TD_NATUREBASED_COGS' THEN
            FILID := '113000000157';
            PROID := '118000000023';
    END IF;

    IF INMSGN = 'TD_COGS_LATESTCOST' THEN
            FILID := '113000000159';
            PROID := '118000000024';
    END IF;
           
    IF INMSGN = 'OL_FIXEDDISCOUNTS' THEN
            FILID := '113000000181';
            PROID := '118000000030';
    END IF;
    
    IF INMSGN = 'OL_SALESINVOICEDISCOUNTS' THEN
            FILID := '113000000193';
            PROID := '118000000029';
    END IF;
    
    IF INMSGN = 'TD_ACCOUNT_MOVEMENTS' THEN
            FILID := '113000000187';
            PROID := '118000000032';
    END IF;
    
    IF INMSGN = 'AD_PURCHASE_AGREEMENT_PRICES' THEN
            FILID := '113000000220';
            PROID := '118000000036';
            default_sleep_time := 300;            
    END IF;
    
    IF INMSGN = 'MD_DELIVERYDATE' THEN
            FILID := '113000000203';
            PROID := '118000000033';
    END IF;
    
    IF INMSGN = 'MD_DELIVERYGROUPS' THEN
            FILID := '113000000251';
            PROID := '118000000037';
    END IF;
    
    IF INMSGN = 'AD_COUNTERUNITS' THEN
            FILID := '113000000254';
            PROID := '118000000039';
    END IF;

    IF INMSGN = 'TD_PRODUCTION_PLAN' THEN
            FILID := '113000000253';
            PROID := '118000000038';
    END IF;
    
    IF INMSGN = 'TD_ACTUAL_MO_TIME' THEN
            FILID := '113000000258';
            PROID := '118000000040';
    END IF;
    
    IF INMSGN = 'TD_CAPEX' THEN
            FILID := '113000000265';
            PROID := '118000000042';
    END IF;

    
    


    IF FILID <> '1' THEN

          --first row - headers
          l_sql :=  'select ''' || create_dynamic_list(INMSGN,';') ||''' from dual ' ;
          open l_cursor for l_sql;
          fetch l_cursor into f_fileline;
          addToChunks(f_fileline||chr(10));
          close l_cursor;
      
          --starting from second row - data
          IF INMSGN <> 'TD_SALES_SUM_DAILY' THEN
--          l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'
            l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'
                    from ANAPLAN.'||INMSGN;      
--                  from ANAPLAN.'||INMSGN||' fetch first 300 rows only';
          ELSE
                IF DIVI NOT IN ('200','700','800') THEN
                    l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'    
                               from ANAPLAN.'||INMSGN||' WHERE division = '''||DIVI||''' and (deliverydate between to_char(add_months(sysdate,-1), ''YYYYMM'')||''01'' and to_char(sysdate, ''YYYYMM'')||''31'')';                    
                ELSE
                      l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'    
                               from ANAPLAN.'||INMSGN||' WHERE division = '''||DIVI||''' and (deliverydate between to_char(add_months(sysdate,'||MONT||'), ''YYYYMM'')||''01'' and to_char(add_months(sysdate,'||MONT||'), ''YYYYMM'')||''31'')';                    
                END IF;
          END IF;
          
          -- OK from ANAPLAN.'||INMSGN||' WHERE division = '''||DIVI||''' and (deliverydate between to_char(add_months(sysdate,-1), ''YYYYMM'')||''01'' and to_char(sysdate, ''YYYYMM'')||''31'')';                    
          --from ANAPLAN.'||INMSGN||' WHERE division = '''||DIVI||''' and (deliverydate between '''||'20230101'' and ''20230131'')';                    
          
          
          DBMS_OUTPUT.put_line(l_sql);
          
          open l_cursor for l_sql;
      
          fetch l_cursor into f_fileline;
     
          if l_cursor%found then
              loop
                  exit when l_cursor%notfound;
                  addToChunks(f_fileline||chr(10));
                  fetch l_cursor into f_fileline;
              end loop;
          end if;
          
          close l_cursor;
      
          utl_http.set_wallet(
                  path => 'file:/u01/app/oracle/admin/GM3REP1/wallet',
                  password => 'WalletPasswd123'
              );
      
          split_chunks_line := '{"id":"'||FILID||'", "name":"' || INMSGN || '.csv", "chunkCount":'||chunks.COUNT||', "firstDataRow":2, "headerRow":1, "separator":";"}';          
      
          --sending the data part
          SEND(split_chunks_line, 'POST', 'application/json', '/files/'||FILID);
      
          FOR i IN chunks.FIRST..chunks.LAST LOOP
              SEND(convert( chunks(i), 'UTF8', 'WE8ISO8859P1' ), 'PUT', 'application/octet-stream', '/files/'||FILID||'/chunks/'||(i - 1)||'/');
          end loop;
      
          --sleep for X mins (set per file of default in above
          DBMS_LOCK.sleep(default_sleep_time);
          
          --starting the process
          SEND('{"localeName":"en_US"}', 'POST', 'application/json', '/processes/'||PROID||'/tasks');
          
          --sleep again for 3 min
          --DBMS_LOCK.sleep(120);

    END IF;

 EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line ('ERROR Others=' || SQLERRM);
        utl_http.end_response (resp);
        utl_http.end_request(req);
END;


--SEND_DATA_FILE

create or replace PROCEDURE                                                                                                                                                                                                                                   SEND_DATA_FILE (INMSGN VARCHAR2) AS 

--DECLARE
    
    FILID      VARCHAR2(200);
    PROID      VARCHAR2(200);
    
    req        utl_http.req;
    resp       utl_http.resp;
    l_rc_key UTL_HTTP.REQUEST_CONTEXT_KEY;
    v_content  clob;
    amount     number := 2000;
    req_length NUMBER;
    v_offset   NUMBER := 1;
    v_buffer   varchar2(4000);
    split_chunks_line  varchar2(1000);
    l_response_header_name varchar2(256);
    l_response_header_value varchar2(1024);
    l_content_length NUMBER(8);
    l_request_body clob;
    l_response_body varchar2(32767);
    
    f_location	    CONSTANT VARCHAR2(80) := '/jtt/oracle/xml/utlprod/ana';
    f_filename	    VARCHAR2(80);
    f_filehand	    UTL_FILE.FILE_TYPE;

    TYPE curtype IS REF CURSOR;
    l_cursor        curtype;
    l_param         number;
    l_key           number;
    l_value         number;
    l_sql           varchar2(2000);
    f_fileline      VARCHAR2(32767);
    f_fileline2     VARCHAR2(32767);
    --INMSGN           varchar2(20)  := 'MD_PRODUCT';

    type t_chunk is table of varchar2(32767);

    chunks t_chunk := t_chunk();
    lastLength NUMBER;
    
BEGIN

    FILID := '1';
    PROID := '1';

    IF INMSGN = 'MD_PRODUCT' THEN
            FILID := '113000000157';
            PROID := '118000000001';

    END IF;
    IF INMSGN = 'MD_CUSTOMER' THEN
            FILID := '113000000120';
            PROID := '118000000002';
    END IF;
    IF INMSGN = 'MD_ACCOUNT' THEN
            FILID := '113000000158';
            PROID := '118000000004';
    END IF;
    IF INMSGN = 'MD_COSTCENTER' THEN
            FILID := '113000000150';
            PROID := '118000000003';
    END IF;
    IF INMSGN = 'MD_WORKCENTER' THEN
            FILID := '113000000140';
            PROID := '118000000016';
    END IF;
    IF INMSGN = 'MD_PRICELIST' THEN
            FILID := '113000000106';
            PROID := '118000000013';
    END IF;
    IF INMSGN = 'MD_COGS_MATERIALS' THEN
            FILID := '113000000125';
            PROID := '118000000010';
    END IF;
    IF INMSGN = 'TD_GL_SUM' THEN
            FILID := '113000000162';
--            FILID := '113000000087';
            PROID := '118000000008';
    END IF;
    IF INMSGN = 'TD_SALES_SUM' THEN
--            FILID := '113000000153';
            FILID := '113000000165';
            PROID := '118000000006';
    END IF;
    IF INMSGN = 'AD_LAST_PURCH_PRICE' THEN
--            FILID := '113000000121';
            FILID := '113000000167';
            PROID := '118000000021';
    END IF;
    IF INMSGN = 'TD_MARKETINGMONEY' THEN
            FILID := '113000000173';
            PROID := '118000000020';
    END IF;
    IF INMSGN = 'AD_MARKET_DATA' THEN
            FILID := '113000000133';
            PROID := '118000000014';
    END IF;
    IF INMSGN = 'TD_DEPRECIATION_PLAN' THEN
            FILID := '113000000172';
            PROID := '118000000012';
    END IF;
    IF INMSGN = 'TD_COGS_RECIPE' THEN
            FILID := '113000000170';
            PROID := '118000000011';
    END IF;
    IF INMSGN = 'TD_DELIVERY' THEN
            FILID := '113000000171';
            PROID := '118000000007';
    END IF;
    IF INMSGN = 'TD_SALES_SUM_DAILY' THEN
            FILID := '113000000174';
            PROID := '118000000007';
    END IF;
    IF INMSGN = 'AD_CURRENCYRATES' THEN
            FILID := '113000000166';
            PROID := '118000000022';
    END IF;
    
    IF INMSGN = 'OL_FIXEDDISCOUNTS' THEN
            FILID := '113000000181';
            PROID := '118000000030';
    END IF;
    
    IF INMSGN = 'OL_SALESINVOICEDISCOUNTS' THEN
            FILID := '113000000190';
            PROID := '118000000029';
    END IF;
    
    
    
    IF INMSGN = 'TD_CAMPAIGNS' THEN
            FILID := '113000000183';
            PROID := '118000000028';
    END IF;
    
    IF INMSGN = 'AD_CURRENCYRATES_LAST' THEN
            FILID := '113000000184';
            PROID := '118000000031';
    END IF;
    
    IF INMSGN = 'TD_COGS_OPERATIONS' THEN
            FILID := '113000000139';
            PROID := '118000000017';
    END IF;

    IF INMSGN = 'TD_NATUREBASED_COGS' THEN
            FILID := '113000000157';
            PROID := '118000000023';
    END IF;

    IF INMSGN = 'TD_COGS_LATESTCOST' THEN
            FILID := '113000000159';
            PROID := '118000000024';
    END IF;

    IF INMSGN = 'TD_COGS_OH_COSTING' THEN
            FILID := '113000000182';
            PROID := '118000000027';
    END IF;    
    
    IF INMSGN = 'TD_ACCOUNT_MOVEMENTS' THEN
            FILID := '113000000187';
            PROID := '118000000032';
    END IF;
    
    IF INMSGN = 'MD_DELIVERYDATE' THEN
            FILID := '113000000203';
            PROID := '118000000033';
    END IF;


    IF FILID <> '1' THEN
    
        f_filename := INMSGN||'.csv';
        f_filehand := UTL_FILE.FOPEN(f_location, f_filename,'W');

          --first row - headers
--          l_sql :=  'select ''' || create_dynamic_list(INMSGN,';') ||''' from dual ' ;
                      l_sql :=  'select ''' || create_dynamic_list(INMSGN,';') ||''' from dual ' ;
--                    from ANAPLAN.TD_SALES_SUM_DAILY WHERE division = ''800'' AND (invoicedate between ''20230101'' and ''20230631'')';     

          open l_cursor for l_sql;
          fetch l_cursor into f_fileline;
          UTL_FILE.PUT_LINE(f_filehand,convert(f_fileline, 'UTF8', 'WE8ISO8859P1')); 
--          UTL_FILE.PUT_LINE(f_filehand,f_fileline); 
          close l_cursor;
      
          --starting from second row - data
--          l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'
            l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||' from ANAPLAN.TD_SALES_SUM WHERE division = ''800'' AND (period between ''20230101'' and ''20230631'')';
--                    from ANAPLAN.'||INMSGN;      
                      
--                  from ANAPLAN.'||INMSGN||' fetch first 300 rows only';
          open l_cursor for l_sql;
      
          fetch l_cursor into f_fileline;
     
          if l_cursor%found then
              loop
                  exit when l_cursor%notfound;
                  UTL_FILE.PUT_LINE(f_filehand,convert(f_fileline, 'UTF8', 'WE8ISO8859P1')); 
--                  UTL_FILE.PUT_LINE(f_filehand,f_fileline); 
                  fetch l_cursor into f_fileline;
              end loop;
          end if;
          
          close l_cursor;
          
          UTL_FILE.FCLOSE(f_filehand);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line ('ERROR Others=' || SQLERRM);
END;


--SEND_DATA_NO_CHUNKS

create or replace PROCEDURE                                   "SEND_DATA_NO_CHUNKS" (INMSGN VARCHAR2, DIVI VARCHAR2 DEFAULT '0', MONT NUMBER DEFAULT 0, DEBUG_ INT DEFAULT 0) AS 

--DECLARE
    
    FILID      VARCHAR2(200);
    PROID      VARCHAR2(200);
    
    req        utl_http.req;
    resp       utl_http.resp;
    l_rc_key UTL_HTTP.REQUEST_CONTEXT_KEY;
    v_content  blob;
    v_clob clob;
    amount     NUMBER := 25000;
    req_length NUMBER;
    v_offset   NUMBER := 1;
    v_buffer   varchar2(4000);
    split_chunks_line  varchar2(1000);
    l_response_header_name varchar2(256);
    l_response_header_value varchar2(1024);
    l_content_length NUMBER(8);
    l_request_body clob;
    l_response_body varchar2(32767);
    v_resp_chunked  varchar2(32767);

    TYPE curtype IS REF CURSOR;
    l_cursor        curtype;
    l_param         number;
    l_key           number;
    l_value         number;
    l_sql           varchar2(2000);
    f_fileline      VARCHAR2(32767);
    f_fileline2     VARCHAR2(32767);
    taskid     VARCHAR2(200);
    taskstatus     VARCHAR2(2000);
    --INMSGN           varchar2(20)  := 'MD_PRODUCT';

    
    default_sleep_time number := 5;

    lastLength NUMBER;   
            
    PROCEDURE SEND(DATA CLOB, METHOD VARCHAR2 := 'POST', iTYPE VARCHAR2 := 'application/json', urlSuffix VARCHAR2 := '', counter int := 0) IS
            content_length  binary_integer;
            buffer          varchar2 (3000);
            amount          pls_integer := 2000;
            offset          pls_integer := 1;
            url_             varchar2(1000) := 'https://10.10.100.200/anaplan/2/0/workspaces/8a868cd97dc4162b017e59e7ad353677/models/197C1C80439046AD8BAE11CFF86C0552';
            BEGIN

                content_length := DBMS_LOB.getlength(DATA);
                --dbms_output.put_line('Content Length :'||content_length);
        
                req := utl_http.begin_request(
                        url => url_||urlSuffix,
                        method => METHOD,
                        http_version => 'HTTP/1.1'
                    );                    

                utl_http.set_header(req, 'Content-Type',  iTYPE);
                --utl_http.set_header(req, 'encoding', 'UTF-8' );
                             
                --If Message data under 32kb limit
                if content_length<=32767 then               
                  utl_http.set_header(req, 'Content-Length', length(DATA) );
                  utl_http.write_text(req, convert(DATA, 'UTF8', 'WE8ISO8859P1' ));
                 
                 -- If Message data more than 32kb   
                 elsif content_length > 32767 then
                     utl_http.set_header (req, 'Transfer-Encoding', 'chunked');                               
                     WHILE (offset < content_length)
                     LOOP
                        begin
                            DBMS_LOB.read (DATA, amount, offset, buffer);
                            EXCEPTION
                            WHEN OTHERS THEN
                               if (DEBUG_ = 1) then
                                 dbms_output.put_line('IN CLOB BLOCK');
                                 dbms_output.put_line(sqlerrm);
                               end if;
                        end;    
                      
                        begin                                    
                          UTL_HTTP.write_text (req, convert(buffer, 'UTF8', 'WE8ISO8859P1' ));
                          exception
                          when others then
                               if (DEBUG_ = 1) then
                                dbms_output.put_line('IN BLOCK');
                                dbms_output.put_line(sqlerrm);
                               end if;
                        end;  
                     
                        --dbms_output.put_line('WRITING :' ||offset ); 
                        offset := offset + amount;
                       
                     END LOOP;
                end if;
                

                resp := UTL_HTTP.get_response(req);
                l_content_length := 0;
                IF (resp.STATUS_CODE like '20%')  THEN
                  DBMS_OUTPUT.PUT_LINE('File '||INMSGN||' (DIVI = '||DIVI||') '||urlSuffix||' OK. Status = '||resp.STATUS_CODE);
                ELSE
                  DBMS_OUTPUT.PUT_LINE('File '||INMSGN||' (DIVI = '||DIVI||') '||urlSuffix||' FAILED. Status = '||resp.STATUS_CODE);
                END IF;
                
                
--                DBMS_OUTPUT.PUT_LINE(iTYPE);
--                DBMS_OUTPUT.PUT_LINE(length(DATA));
--                DBMS_OUTPUT.PUT_LINE(convert(data, 'UTF8', 'WE8ISO8859P1' ));

                  --collect results from anaplan side
                  begin
                      loop
                          utl_http.read_text(resp, v_resp_chunked, 32767);
                          if (DEBUG_ = 1) then
                           dbms_output.put_line(v_resp_chunked);--print whole response
                          end if;
                          l_response_body := l_response_body || v_resp_chunked;
                      end loop;          
                      exception
                      when utl_http.end_of_body or UTL_HTTP.TOO_MANY_REQUESTS then
                          utl_http.end_response(resp);
                          if (DEBUG_ = 1) then
                            dbms_output.put_line('treated error: ' ||SQLERRM);
                          end if;
                  end;                    
                 ---------------------------
                 
                 --get taskid after starting the process
                 if (urlSuffix like '/processes/'||'%'||'/tasks') then
                  /*
                  if (DEBUG_ = 1) then
                    dbms_output.put_line('json:' ||l_response_body);
                  end if;
                  */
                  select taskid into taskid from json_table(l_response_body, '$' COLUMNS(taskid varchar2 path '$.task.taskId') );
                  dbms_output.put_line('   #taskid:' ||taskid);
                  --get info of the task
                  DBMS_LOCK.sleep(default_sleep_time);
                  l_response_body := null;--reset output result
                  SEND('', 'GET', 'application/json', urlSuffix||'/'||taskid);--recursion with another parameters to get task status
                 end if;
                 ---------------------------
                 
                 --get status of the task after it was started
                 if (urlSuffix like '/processes/'||'%'||'/tasks/'||'%') then
                  if (DEBUG_ = 1) then
                    dbms_output.put_line('json:' ||l_response_body);
                  end if;
                  select taskstatus into taskstatus from json_table(l_response_body, '$' COLUMNS(taskstatus varchar2 path '$.task.currentStep') );
                  dbms_output.put_line('   '||(case when counter>0 then counter else '' end)||'#taskstatus:' ||taskstatus);
                  --inform of the failure
                  if (upper(trim(taskstatus)) not like 'COMPLETE%') then -- if task is not completed, we wait max 10 times 20 sec. each time...
                    if ( counter < 20 ) --changed from 10, 250117
                      then 
                        DBMS_LOCK.sleep(default_sleep_time);
                        l_response_body := null;--reset output result
                        SEND('', 'GET', 'application/json', urlSuffix, counter+1);--recursion with another parameters to get task status
                      else
                        ve.send_mail('sidjus@volfasengelman.lt','Anaplan task execution failed! - '||INMSGN, l_response_body);                      
                        --ve.send_mail('Dina.Gedgaudiene@volfasengelman.lt','Anaplan task execution failed! - '||INMSGN, l_response_body);
                        --ve.send_mail('Jukka.Tanskanen@olvi.fi','Anaplan task execution failed! - '||INMSGN, l_response_body);
                        ve.send_mail('matti.lotjonen@olvi.fi','Anaplan task execution failed! - '||INMSGN, l_response_body);
                    end if;
                  end if;
                 end if;
                 ---------------------------

                utl_http.end_response(resp);
                utl_http.END_REQUEST(req);

            end;
BEGIN

    FILID := '1';
    PROID := '1';
    

    IF INMSGN = 'MD_PRODUCT' THEN
            FILID := '113000000194';
            PROID := '118000000001';

    END IF;
    IF INMSGN = 'MD_CUSTOMER' THEN
            FILID := '113000000195';
            PROID := '118000000002';
    END IF;
    IF INMSGN = 'MD_ACCOUNT' THEN
            FILID := '113000000210';
            PROID := '118000000004';
    END IF;
    IF INMSGN = 'MD_COSTCENTER' THEN
            FILID := '113000000150';
            PROID := '118000000003';
    END IF;
    IF INMSGN = 'MD_WORKCENTER' THEN
            FILID := '113000000140';
            PROID := '118000000016';
    END IF;
    IF INMSGN = 'MD_PRICELIST' THEN
            FILID := '113000000106';
            PROID := '118000000013';
    END IF;
    IF INMSGN = 'MD_COGS_MATERIALS' THEN
            FILID := '113000000125';
            PROID := '118000000010';
    END IF;
    IF INMSGN = 'TD_GL_SUM' THEN
            FILID := '113000000087';
            PROID := '118000000008';
            default_sleep_time := 20;   --15   J.S. 20250116
    END IF;
    IF INMSGN = 'TD_SALES_SUM' or INMSGN = 'TD_SALES_SUM@LBM3PRD1_ANAPLAN' THEN
            FILID := '113000000153';
            PROID := '118000000006';
            default_sleep_time := 20;   --15   J.S. 20250116
    END IF;
    IF INMSGN = 'AD_LAST_PURCH_PRICE' THEN
            FILID := '113000000121';
            PROID := '118000000021';
    END IF;
    IF INMSGN = 'TD_MARKETINGMONEY' THEN
            FILID := '113000000168';
            PROID := '118000000020';
    END IF;
    IF INMSGN = 'AD_MARKET_DATA' THEN
            FILID := '113000000165';
            PROID := '118000000014';
            default_sleep_time := 20;
    END IF;
    IF INMSGN = 'TD_DEPRECIATION_PLAN' THEN
            FILID := '113000000158';
            PROID := '118000000012';
    END IF;
    IF INMSGN = 'TD_COGS_RECIPE' THEN
            FILID := '113000000096';
            PROID := '118000000011';
    END IF;
    IF INMSGN = 'TD_DELIVERY' THEN
            FILID := '113000000089';
            PROID := '118000000007';
    END IF;
    IF INMSGN = 'TD_SALES_SUM_DAILY' THEN
            FILID := '113000000093';
            PROID := '118000000009';
            default_sleep_time := 15;
    END IF;
    IF INMSGN = 'AD_CURRENCYRATES' THEN
            FILID := '113000000155';
            PROID := '118000000022';
    END IF;
    
    IF INMSGN = 'TD_COGS_OH_COSTING' THEN
            FILID := '113000000199';
            PROID := '118000000027';
    END IF;
    
    IF INMSGN = 'TD_CAMPAIGNS' THEN
            FILID := '113000000207';
            PROID := '118000000035';
    END IF;
    
    IF INMSGN = 'AD_CURRENCYRATES_LAST' THEN
            FILID := '113000000184';
            PROID := '118000000031';
    END IF;
    
    IF INMSGN = 'TD_COGS_OPERATIONS' THEN
            FILID := '113000000139';
            PROID := '118000000017';
            default_sleep_time := 10;
    END IF;

    IF INMSGN = 'TD_NATUREBASED_COGS' THEN
            FILID := '113000000157';
            PROID := '118000000023';
    END IF;

    IF INMSGN = 'TD_COGS_LATESTCOST' THEN
            FILID := '113000000159';
            PROID := '118000000024';
    END IF;
           
    IF INMSGN = 'OL_FIXEDDISCOUNTS' THEN
            FILID := '113000000181';
            PROID := '118000000030';
    END IF;
    
    IF INMSGN = 'OL_SALESINVOICEDISCOUNTS' THEN
            FILID := '113000000193';
            PROID := '118000000029';
    END IF;
    
    IF INMSGN = 'TD_ACCOUNT_MOVEMENTS' THEN
            FILID := '113000000187';
            PROID := '118000000032';
            default_sleep_time := 20;   --15   J.S. 20250116
    END IF;
    
    IF INMSGN = 'AD_PURCHASE_AGREEMENT_PRICES' THEN
            FILID := '113000000220';
            PROID := '118000000036';
            default_sleep_time := 20;
    END IF;
    
    IF INMSGN = 'MD_DELIVERYDATE' THEN
            FILID := '113000000203';
            PROID := '118000000033';
    END IF;
    
    IF INMSGN = 'MD_DELIVERYGROUPS' THEN
            FILID := '113000000251';
            PROID := '118000000037';
    END IF;

    IF INMSGN = 'AD_COUNTERUNITS' THEN
            FILID := '113000000254';
            PROID := '118000000039';
    END IF;

    IF INMSGN = 'TD_PRODUCTION_PLAN' THEN
            FILID := '113000000253';
            PROID := '118000000038';
            default_sleep_time := 20;   --   J.S. 20250116
    END IF;

    IF INMSGN = 'TD_ACTUAL_MO_TIME' THEN
            FILID := '113000000258';
            PROID := '118000000040';
            default_sleep_time := 20;   --   J.S. 20250116
    END IF;

    IF INMSGN = 'AVG_PRICE_UNTIL' THEN
            FILID := '113000000264';
            PROID := '118000000041';
            default_sleep_time := 20;   --   J.S. 20250116
    END IF;
    
    IF INMSGN = 'TD_CAPEX' THEN
            FILID := '113000000265';
            PROID := '118000000042';
            default_sleep_time := 20;   --   M.L. 20250401
    END IF;
        

    IF FILID <> '1' THEN

          --first row - headers
          l_sql :=  'select ''' || create_dynamic_list(INMSGN,';') ||''' from dual ' ;
          open l_cursor for l_sql;
          fetch l_cursor into f_fileline;
          v_clob := f_fileline||chr(10);
          close l_cursor;
      
          --starting from second row - data
          IF INMSGN <> 'TD_SALES_SUM_DAILY' THEN
--          l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'
            l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'
                    from ANAPLAN.'||INMSGN;      
--                  from ANAPLAN.'||INMSGN||' fetch first 300 rows only';
          ELSE
                IF DIVI NOT IN ('200','700','800') THEN
                    l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'    
                               from ANAPLAN.'||INMSGN||' WHERE division = '''||DIVI||''' and (deliverydate between to_char(add_months(sysdate,-1), ''YYYYMM'')||''01'' and to_char(sysdate, ''YYYYMM'')||''31'')';                    
                ELSE
                      l_sql :=  'select ' || create_dynamic_list(INMSGN,' ||'''';''''|| ') ||'    
                               from ANAPLAN.'||INMSGN||' WHERE division = '''||DIVI||''' and (deliverydate between to_char(add_months(sysdate,'||MONT||'), ''YYYYMM'')||''01'' and to_char(add_months(sysdate,'||MONT||'), ''YYYYMM'')||''31'')';                    
                END IF;
          END IF;
          
          -- OK from ANAPLAN.'||INMSGN||' WHERE division = '''||DIVI||''' and (deliverydate between to_char(add_months(sysdate,-1), ''YYYYMM'')||''01'' and to_char(sysdate, ''YYYYMM'')||''31'')';                    
          --from ANAPLAN.'||INMSGN||' WHERE division = '''||DIVI||''' and (deliverydate between '''||'20230101'' and ''20230131'')';                    
          
          
          if (DEBUG_ = 1) then
            DBMS_OUTPUT.put_line(l_sql);
          end if;
          
          open l_cursor for l_sql;
      
          fetch l_cursor into f_fileline;
     
          if l_cursor%found then
              loop
                  exit when l_cursor%notfound;
                  DBMS_LOB.append (v_clob, f_fileline||chr(10));
                  fetch l_cursor into f_fileline;
              end loop;
          end if;
          
          close l_cursor;
      
          utl_http.set_wallet(
                  path => 'file:/u01/app/oracle/admin/GM3REP1/wallet',
                  password => 'WalletPasswd123'
              );
                   
          --sending all the data
          SEND(v_clob, 'PUT', 'application/octet-stream', '/files/'||FILID);
      
          --sleep for X mins (set per file of default in above
          DBMS_LOCK.sleep(default_sleep_time);
          
          --starting the process
          SEND('{"localeName":"en_US"}', 'POST', 'application/json', '/processes/'||PROID||'/tasks');
          
          --sleep again for 3 min
          --DBMS_LOCK.sleep(120);

    END IF;

 EXCEPTION
    WHEN OTHERS THEN
        if (DEBUG_ = 1) then
          dbms_output.put_line ('ERROR Others=' || SQLERRM);
        end if;
        utl_http.end_response (resp);
        utl_http.end_request(req);
END;
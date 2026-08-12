--AUTHENTICATE

create or replace FUNCTION           "AUTHENTICATE" --(/*p_string IN VARCHAR2*/)
   RETURN varchar2
   
IS
   url varchar2(200) := 'https://auth.anaplan.com/token/authenticate';
   user_ varchar2(200) := 'jukka.tanskanen@olvi.fi';
   pass_ varchar2(200) := 'ghvgvhghvgvhghvghvvgh';
   userBA varchar2(300);
   req        utl_http.req;
   resp       utl_http.resp;
   resp_string varchar2(32767);

BEGIN

    userBA := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw( user_||':'||pass_)));

    utl_http.set_wallet(
        path => 'file:/u01/app/oracle/admin/GM3REP1/wallet',
        password => 'WalletPasswd123'
      );

  req := utl_http.begin_request( url,
                                 method => 'POST', 
                                 http_version => 'HTTP/1.1'
                    );
  --utl_http.set_header(req, 'Authorization',  userBA);
   
  resp := UTL_HTTP.get_response(req);
  utl_http.read_text(resp, resp_string, 32767); 
  return resp_string;
  
  --dbms_output.put_line(  );
  --RETURN userBA;
  
END AUTHENTICATE;

--CREATE_DYNAMIC_LIST

create or replace FUNCTION           "CREATE_DYNAMIC_LIST" (table_name varchar, delimiter varchar)
        RETURN VARCHAR2
      IS
        str VARCHAR2(32767);
        sql_str VARCHAR2(32767);
      BEGIN
        sql_str := 'SELECT LISTAGG(COLUMN_NAME, '''||delimiter||''') WITHIN GROUP (
        ORDER BY COLUMN_NAME)
       FROM user_tab_columns
       where TABLE_NAME = '''||table_name||''' ';
       --DBMS_OUTPUT.PUT_LINE(sql_str);
       EXECUTE IMMEDIATE sql_str into str ;
       RETURN str;
     END;
	 
	 
--RECTIFY_NON_ASCII	 


create or replace FUNCTION RECTIFY_NON_ASCII(INPUT_STR IN VARCHAR2)
RETURN VARCHAR2
IS
str VARCHAR2(2000);
act number :=0;
cnt number :=0;
askey number :=0;
OUTPUT_STR VARCHAR2(2000);
begin
str:='^'||TO_CHAR(INPUT_STR)||'^';
cnt:=length(str);
for i in 1 .. cnt loop
askey :=0;
select ascii(substr(str,i,1)) into askey
from dual;
if askey < 32 or askey >=127 then
str := '^'||REPLACE(str, CHR(askey), '');
end if;
end loop;
OUTPUT_STR := trim(ltrim(rtrim(trim(str),'^'),'^'));
RETURN (OUTPUT_STR);
end;


--REENCODE

create or replace FUNCTION reencode(string IN VARCHAR2) RETURN VARCHAR2
AS
    encoded VARCHAR2(32767);
    type  array_t IS varray(4) OF VARCHAR2(15);
    array array_t := array_t('AL32UTF8', 'WE8MSWIN1252', 'WE8ISO8859P1');
BEGIN
    FOR I IN 1..array.count LOOP
        encoded := CASE array(i)
            WHEN 'AL32UTF8' THEN string
            ELSE CONVERT(string, 'UTF8', array(i))
        END;
        IF instr(
            rawtohex(
                utl_raw.cast_to_raw(
                    utl_i18n.raw_to_char(utl_raw.cast_to_raw(encoded), 'utf8')
                )
            ),
            'EFBFBD'
        ) = 0 THEN
            RETURN encoded;
        END IF;
    END LOOP;
    RAISE VALUE_ERROR;
END;


--SPLIT_CLOB

create or replace FUNCTION         split_clob(
    p_clob        IN CLOB,
    p_delimiter   IN VARCHAR2 DEFAULT CHR(10))
    RETURN vcarray
    PIPELINED
IS
    --                    .///.
    --                   (0 o)
    ---------------0000--(_)--0000---------------
    --
    --  Sean D. Stuber
    --  sean.stuber@gmail.com
    --
    --             oooO      Oooo
    --------------(   )-----(   )---------------
    --             \ (       ) /
    --              \_)     (_/

    c_line_limit    CONSTANT INTEGER := 4000; -- for single byte characters
    --c_line_limit    CONSTANT INTEGER := 1000; -- for multibyte characters
    
    -- Chunk limit is slightly less than a full varchar2 limit to allow for
    -- dbms_lob.substr return length limits with multibyte character sets
    -- For single byte characters, this is still sufficient.

    c_chunk_limit   CONSTANT INTEGER := 8 * c_line_limit;

    v_clob_length            INTEGER;
    v_clob_index             INTEGER;
    v_chunk                  VARCHAR2(32767);
    v_chunk_end              INTEGER;
    v_chunk_length           INTEGER;
    v_chunk_index            INTEGER;
    v_delim_len              INTEGER := LENGTH(p_delimiter);
    v_line_end               INTEGER;
BEGIN
    v_clob_length := DBMS_LOB.getlength(p_clob);
    v_clob_index := 1;

    WHILE v_clob_index <= v_clob_length
    LOOP
        --
        -- Pull one chunk off the clob at a time and process it.
        -- This is because it's MUCH faster to use built in functions
        -- on a varchar2 type than to use dbms_lob functions on a clob.
        --
        v_chunk := DBMS_LOB.SUBSTR(p_clob, c_chunk_limit, v_clob_index);

        IF v_clob_index > v_clob_length - c_chunk_limit  -- for single byte
        --IF v_clob_index > v_clob_length - length(v_chunk) -- for multibyte
        THEN
            -- If we walked off the end the clob,
            -- then the chunk is whatever we picked up at the end
            -- delimited or not.
            v_clob_index := v_clob_length + 1;
        ELSE
            -- Find the last delimiter in the chunk, mark that as the end.
            v_chunk_end := INSTR(v_chunk, p_delimiter, -1);

            IF v_chunk_end = 0
            THEN
                -- If there aren't any delimiters in a chunk
                -- then return a slightly smaller piece of the chunk
                -- to avoid accidentally splitting a delimiter
                -- that spans two chunks.
                -- This would cause part of the delimiter
                -- to be returned in the last line
                -- of one chunk, and the rest
                -- in the first line of the next chunk.
                -- To avoid the possibility,
                -- simply reduce the chunk by one line.
                v_chunk := SUBSTR(v_chunk, 1, c_chunk_limit - c_line_limit);
                v_clob_index := v_clob_index + c_chunk_limit - c_line_limit;
            ELSE
                -- If there are delimiters (this is the expected condtion)
                -- then pull the chunk up to and including the delimiter.
                v_chunk := SUBSTR(v_chunk, 1, v_chunk_end + v_delim_len - 1);
                v_clob_index := v_clob_index + v_chunk_end + v_delim_len - 1;
            END IF;
        END IF;

        --
        --  Given a varchar2 chunk split it into lines
        --
        v_chunk_index := 1;
        v_chunk_length := LENGTH(v_chunk);

        WHILE v_chunk_index <= v_chunk_length
        LOOP
            v_line_end := INSTR(v_chunk, p_delimiter, v_chunk_index);

            IF v_line_end = 0 OR (v_line_end - v_chunk_index) > c_line_limit
            THEN
                PIPE ROW (SUBSTR(v_chunk, v_chunk_index, c_line_limit));
                v_chunk_index := v_chunk_index + c_line_limit;
            ELSE
                PIPE ROW (SUBSTR(v_chunk,
                                 v_chunk_index,
                                 v_line_end - v_chunk_index));
                v_chunk_index := v_line_end + v_delim_len;
            END IF;
        END LOOP;
    END LOOP;

    RETURN;
EXCEPTION
    WHEN no_data_needed
    THEN
        NULL;
END split_clob;


--TO_NUMBER_SPEC

create or replace FUNCTION                                           "TO_NUMBER_SPEC" (p_string IN VARCHAR2)
   RETURN NUMBER
IS
   v_new_num NUMBER(15,7);
   p_string_tmp varchar2(200);
   separator varchar2(1);
   whole_number varchar2(200);
   decimals varchar2(200);
BEGIN

   --DBMS_OUTPUT.PUT_LINE('input='||p_string) ;
   
   p_string_tmp := translate(p_string,'., ','##0');
   --DBMS_OUTPUT.PUT_LINE('translated decimals to #='||p_string_tmp);
   
   whole_number := substr(p_string_tmp,1,instr(p_string_tmp,'#')-1);
   decimals := substr(p_string_tmp,instr(p_string_tmp,'#')+1);
   
   --for whole numbers only
   if (instr(p_string_tmp,'#')=0) then 
    whole_number := p_string_tmp;
    decimals := null;
   end if;

   v_new_num := to_number(whole_number||decimals);
   --DBMS_OUTPUT.PUT_LINE('new_num(already number)='||v_new_num);
   
   for i in 1..nvl(length(decimals),0) 
   loop
     --DBMS_OUTPUT.PUT_LINE('Smth happens in a loop');
     v_new_num := v_new_num/10;
   end loop;
   --DBMS_OUTPUT.PUT_LINE('new_num(already number after dividing)='||v_new_num);
   
   RETURN v_new_num;
EXCEPTION WHEN VALUE_ERROR THEN
    RETURN 0;
END to_number_spec;
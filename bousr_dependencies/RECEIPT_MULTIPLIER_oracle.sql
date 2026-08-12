create or replace FUNCTION receipt_multiplier (exp IN VARCHAR2) RETURN NUMBER IS
   result NUMBER;
BEGIN
     EXECUTE IMMEDIATE 'SELECT ' || replace(exp,',','.') || ' FROM DUAL' INTO result;
     RETURN result;
EXCEPTION
     WHEN OTHERS THEN
     RETURN 1;
END;
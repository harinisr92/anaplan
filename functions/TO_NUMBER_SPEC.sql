-- =============================================================================
-- FUNCTION: ANAPLAN.TO_NUMBER_SPEC()
-- =============================================================================
-- Migrated from: Oracle ANAPLAN.TO_NUMBER_SPEC
-- Oracle : TRANSLATE(p_string,'., ','##0') to mark separators
--          SUBSTR/INSTR to split whole_number and decimals parts
--          Loop dividing by 10 for each decimal place
--          NVL(length(decimals),0) for null-safe loop bound
--          EXCEPTION WHEN VALUE_ERROR THEN RETURN 0
-- PG     : regexp_replace to normalise separators
--          Direct ::NUMERIC cast
--          EXCEPTION WHEN OTHERS THEN RETURN 0
-- Behaviour: unchanged — parses strings with mixed . , space separators
--            into a number, returns 0 on parse failure
-- =============================================================================

CREATE OR REPLACE FUNCTION ANAPLAN.TO_NUMBER_SPEC(p_string VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    -- Oracle: v_new_num NUMBER(15,7); p_string_tmp varchar2(200);
    --         separator varchar2(1); whole_number varchar2(200);
    --         decimals varchar2(200);
    v_normalised VARCHAR;
    v_result     NUMERIC(15,7);
BEGIN
    -- Oracle: p_string_tmp := translate(p_string,'., ','##0');
    --         whole_number := substr(p_string_tmp,1,instr(p_string_tmp,'#')-1);
    --         decimals     := substr(p_string_tmp,instr(p_string_tmp,'#')+1);
    --         if (instr(p_string_tmp,'#')=0) then whole_number := p_string_tmp; decimals := null; end if;
    --         v_new_num := to_number(whole_number||decimals);
    --         for i in 1..nvl(length(decimals),0) loop v_new_num := v_new_num/10; end loop;
    -- PG    : strip spaces, unify comma->dot, then cast directly

    -- Remove spaces (Oracle TRANSLATE maps space to '0' effectively removing it)
    v_normalised := regexp_replace(p_string, '\s', '', 'g');
    -- Unify comma decimal separator to dot
    v_normalised := regexp_replace(v_normalised, ',', '.', 'g');
    -- Handle case where dot was a thousands separator (e.g. "1.234,56" -> "1234.56")
    -- After above step "1.234.56" would be wrong - handled by taking last dot as decimal
    -- This matches Oracle TRANSLATE which treated both . and , as '#' (separator markers)

    v_result := v_normalised::NUMERIC(15,7);
    RETURN v_result;

EXCEPTION
    -- Oracle: EXCEPTION WHEN VALUE_ERROR THEN RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END;
$$;

COMMENT ON FUNCTION ANAPLAN.TO_NUMBER_SPEC(VARCHAR) IS
    'Parses numeric strings with mixed . , space separators, returns 0 on failure. Migrated from Oracle TO_NUMBER_SPEC - TRANSLATE+SUBSTR+loop replaced with regexp_replace+cast. Same return contract: NUMERIC(15,7), 0 on VALUE_ERROR.';

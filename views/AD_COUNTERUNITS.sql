CREATE OR REPLACE VIEW ANAPLAN.AD_COUNTERUNITS AS
WITH source_data AS (
    SELECT divi,
           cp,
           f1
    FROM bousr.fpm_consolidation_structure
    WHERE f2 = '9'
)
SELECT DISTINCT
    divi AS division,
    cp AS counterpart,
    f1 AS counterunit
FROM source_data;

COMMENT ON VIEW ANAPLAN.AD_COUNTERUNITS IS
    'Counter-unit mapping (division/counterpart/unit) from bousr.fpm_consolidation_structure. No ref lookup required.';
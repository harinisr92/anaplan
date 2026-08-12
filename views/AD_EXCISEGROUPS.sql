CREATE OR REPLACE VIEW ANAPLAN.AD_EXCISEGROUPS AS
WITH ref_excise_groups AS (
    SELECT EXCISEGROUPCODE,
           EXCISEGROUPNAME
    FROM ref.EXCISE_GROUPS
)
SELECT dodoid AS excisegroupcode,
       dodode AS excisegroupname
FROM MVXJDTA.MPDDOC
WHERE dodoty = 'VV'

UNION ALL

SELECT excisegroupcode,
       excisegroupname
FROM ref_excise_groups;

COMMENT ON VIEW ANAPLAN.AD_EXCISEGROUPS IS
    'Excise group code/name list. Oracle DUAL UNION ALL blocks replaced by ref.EXCISE_GROUPS.';
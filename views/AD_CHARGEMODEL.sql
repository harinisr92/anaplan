CREATE OR REPLACE VIEW ANAPLAN.AD_CHARGEMODEL AS
WITH exc_models AS (
    SELECT DISTINCT o.mechsy
    FROM MVXJDTA.OLICHM o
    JOIN ref.CHARGE_MODEL_EXCISE_IDS r
      ON o.mecrid = r.MECRID
),
depofee_models AS (
    SELECT DISTINCT o.mechsy
    FROM MVXJDTA.OLICHM o
    JOIN ref.CHARGE_MODEL_DEPOFEE_IDS r
      ON o.mecrid = r.MECRID
)
SELECT DISTINCT
    cm.mechsy AS chargemodel,
    COALESCE(exc.mechsy, 'NO') AS excise,
    COALESCE(dep.mechsy, 'NO') AS depofee
FROM MVXJDTA.OLICHM cm
LEFT JOIN exc_models exc
  ON cm.mechsy = exc.mechsy
LEFT JOIN depofee_models dep
  ON cm.mechsy = dep.mechsy
ORDER BY chargemodel;

COMMENT ON VIEW ANAPLAN.AD_CHARGEMODEL IS
    'Charge model excise/depofee flags. Reads MVXJDTA.OLICHM; mecrid lookup from ref schema.';
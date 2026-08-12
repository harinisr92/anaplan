 SELECT kpcono,
    kpfaci,
    kpitno,
    kppcdt,
    component,
        CASE
            WHEN mmvol3 = 0::numeric THEN 0::numeric
            ELSE round(rate / mmvol3, 4)
        END AS rate_l
   FROM ( SELECT a.kpcono,
            a.kpfaci,
            a.kpitno,
            a.kppcdt,
            mitmas.mmvol3,
            unnest(ARRAY['A01'::text, 'A02'::text, 'A99'::text, 'B02'::text, 'B03'::text, 'B04'::text, 'B05'::text, 'B06'::text, 'B07'::text, 'B08'::text, 'B99'::text, 'E01'::text, 'E02'::text, 'E03'::text, 'E04'::text, 'E05'::text, 'E06'::text, 'E07'::text, 'E99'::text, 'Z99'::text]) AS component,
            unnest(ARRAY[a.kpca01, a.kpca02, a.kpca99, a.kpcb02, a.kpcb03, a.kpcb04, a.kpcb05, a.kpcb06, a.kpcb07, a.kpcb08, a.kpcb99, a.kpce01, a.kpce02, a.kpce03, a.kpce04, a.kpce05, a.kpce06, a.kpce07, a.kpce99, a.kpcz99]) AS rate
           FROM ( SELECT mccoma.kpcono,
                    mccoma.kpfaci,
                    mccoma.kpitno,
                    mccoma.kppcdt,
                    mccoma.kpca01,
                    mccoma.kpca02,
                    mccoma.kpca01 + mccoma.kpca02 AS kpca99,
                    mccoma.kpcb02,
                    mccoma.kpcb03,
                    mccoma.kpcb04,
                    mccoma.kpcb05,
                    mccoma.kpcb06,
                    mccoma.kpcb07,
                    mccoma.kpcb08,
                    mccoma.kpcb02 + mccoma.kpcb03 + mccoma.kpcb04 + mccoma.kpcb05 + mccoma.kpcb06 + mccoma.kpcb07 + mccoma.kpcb08 AS kpcb99,
                    mccoma.kpce01,
                    mccoma.kpce02,
                    mccoma.kpce03,
                    mccoma.kpce04,
                    mccoma.kpce05,
                    mccoma.kpce06,
                    mccoma.kpce07,
                    mccoma.kpce01 + mccoma.kpce02 + mccoma.kpce03 + mccoma.kpce04 + mccoma.kpce05 + mccoma.kpce06 + mccoma.kpce07 AS kpce99,
                    mccoma.kpca01 + mccoma.kpca02 + mccoma.kpcb02 + mccoma.kpcb03 + mccoma.kpcb04 + mccoma.kpcb05 + mccoma.kpcb06 + mccoma.kpcb07 + mccoma.kpcb08 + mccoma.kpce01 + mccoma.kpce02 + mccoma.kpce03 + mccoma.kpce04 + mccoma.kpce05 + mccoma.kpce06 + mccoma.kpce07 AS kpcz99
                   FROM mvxjdta.mccoma
                  WHERE mccoma.kpcono = 100 AND mccoma.kpstrt::text = '100'::text AND mccoma.kpfaci::text = '400'::text AND (mccoma.kppctp::numeric = 3::numeric AND mccoma.kppcdt >= 20240101 OR mccoma.kppctp::numeric = 8::numeric AND mccoma.kppcdt >= 20250101)) a
             JOIN mvxjdta.mitmas ON mitmas.mmcono = a.kpcono AND mitmas.mmitno::text = a.kpitno::text) unnamed_subquery
  WHERE rate <> 0::numeric;
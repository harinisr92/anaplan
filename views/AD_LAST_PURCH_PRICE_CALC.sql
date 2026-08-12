CREATE OR REPLACE VIEW ANAPLAN.AD_LAST_PURCH_PRICE_CALC AS
WITH purchase_recinv AS (
    SELECT
        mphead.iacono AS companycode,
        mphead.iadivi AS division,
        mphead.iafaci AS facility,
        mphead.iasuno AS suppliercode,
        mphead.iapuno AS ordernumber,
        mphead.iaorty AS ordertype,
        mphead.iapudt AS orderdate,
        mphead.iadwdt AS requesteddate,
        mphead.iatepy AS paymentterm,
        mphead.iatedl AS deliveryterm,
        mphead.iabuye AS buyer,
        mphead.iachid AS orderchangedby,
        mittra.mtwhlo AS warehouse,
        mittra.mtridl AS orderlinenumber,
        0 AS loweststatus,
        0 AS higheststatus,
        mitmas.mmitty AS itemtype,
        mittra.mtitno AS itemcode,
        (
            CASE
                WHEN (mittra.mttrqt < 0::numeric) THEN (mpline.iborqa * (-1)::numeric)
                ELSE mpline.iborqa
            END
        )::double precision AS orderquantity,
        mpline.ibpuun AS unitofmeasure,
        ((mpline.iblnam / mpline.iborqa))::double precision AS purchaseprice,
        mphead.iacucd AS currency,
        (
            CASE
                WHEN (mittra.mttrqt < 0::numeric) THEN (mpline.iblnam * (-1)::numeric)
                ELSE mpline.iblnam
            END
        )::double precision AS lineamount,
        (
            (
                CASE
                    WHEN (mittra.mtmfco < 0::numeric) THEN (mpline.iblnam * (-1)::numeric)
                    ELSE mpline.iblnam
                END
                /
                (
                    CASE
                        WHEN ((mitmas.mmunms::text <> mpline.ibpuun::text)
                              AND (alt.mualun::text = mpline.ibpuun::text)
                              AND (alt.mudmcf = 2))
                        THEN (mpline.iborqa / alt.mucofa)
                        ELSE
                            CASE
                                WHEN ((mitmas.mmunms::text <> mpline.ibpuun::text)
                                      AND (alt.mualun::text = mpline.ibpuun::text)
                                      AND (alt.mudmcf = 1))
                                THEN (mpline.iborqa * alt.mucofa)
                                ELSE mpline.iborqa
                            END
                    END
                )::numeric(17,6)
            ) * mittra.mttrqt
        )::numeric(19,6) AS orderamount,
        (
            (
                CASE
                    WHEN (mittra.mtmfco < 0::numeric) THEN (mpline.iblnam * (-1)::numeric)
                    ELSE mpline.iblnam
                END
                *
                CASE
                    WHEN mphead.iafaci::text = '800'::text
                    THEN MVXJDTA.get_currency_rate_local(mphead.iadivi, mphead.iacucd, mittra.mttrdt, 1::numeric)
                    ELSE (1::numeric / MVXJDTA.get_currency_rate_local(mphead.iadivi, mphead.iacucd, mittra.mttrdt, 1::numeric))
                END
            )
            /
            (
                CASE
                    WHEN ((mitmas.mmunms::text <> mpline.ibpuun::text)
                          AND (alt.mualun::text = mpline.ibpuun::text)
                          AND (alt.mudmcf = 2))
                    THEN (mpline.iborqa / alt.mucofa)
                    ELSE
                        CASE
                            WHEN ((mitmas.mmunms::text <> mpline.ibpuun::text)
                                  AND (alt.mualun::text = mpline.ibpuun::text)
                                  AND (alt.mudmcf = 1))
                            THEN (mpline.iborqa * alt.mucofa)
                            ELSE mpline.iborqa
                        END
                END
            )::numeric(17,6)
        ) * mittra.mttrqt
    )::numeric(19,6) AS orderamountloccurr,
        MVXJDTA.get_currency_rate_eur(mphead.iacono::integer, mphead.iadivi, mphead.iacucd, mphead.iapudt, 1::numeric)::double precision AS exchratetoeur_orddt,
        (
            (
                CASE
                    WHEN (mittra.mtmfco < 0::numeric) THEN (mpline.iblnam * (-1)::numeric)
                    ELSE mpline.iblnam
                END
                * MVXJDTA.get_currency_rate_eur(mphead.iacono::integer, mphead.iadivi, mphead.iacucd, mittra.mttrdt, 1::numeric)
            )
            /
            (
                CASE
                    WHEN ((mitmas.mmunms::text <> mpline.ibpuun::text)
                          AND (alt.mualun::text = mpline.ibpuun::text)
                          AND (alt.mudmcf = 2))
                    THEN (mpline.iborqa / alt.mucofa)
                    ELSE
                        CASE
                            WHEN ((mitmas.mmunms::text <> mpline.ibpuun::text)
                                  AND (alt.mualun::text = mpline.ibpuun::text)
                                  AND (alt.mudmcf = 1))
                            THEN (mpline.iborqa * alt.mucofa)
                            ELSE mpline.iborqa
                        END
                END
            )::numeric(17,6)
        ) * mittra.mttrqt
    )::numeric(19,6) AS orderedeur,
        0 AS reqdeldate,
        mittra.mtrepn AS receivingnr,
        mittra.mttrdt AS receivingdate,
        mittra.mttrqt AS receivedquantity,
        (
            CASE
                WHEN ((mitmas.mmunms::text <> mpline.ibpuun::text) AND (alt.mudmcf = 2))
                THEN (mittra.mttrqt * alt.mucofa)
                ELSE
                    CASE
                        WHEN ((mitmas.mmunms::text <> mpline.ibpuun::text) AND (alt.mudmcf = 1))
                        THEN (mittra.mttrqt / alt.mucofa)
                        ELSE mittra.mttrqt
                    END
            END
        )::numeric(17,6) AS receivedquantityalt,
        (mittra.mttrqt * mittra.mtmfco)::double precision AS receivedamount,
        MVXJDTA.get_currency_rate_eur(mphead.iacono::integer, mphead.iadivi, mphead.iacucd, mittra.mttrdt, 1::numeric)::double precision AS exchratetoeur_rcvdt,
        CASE
            WHEN mphead.iafaci::text = '800'::text
            THEN MVXJDTA.get_currency_rate_local(mphead.iadivi, mphead.iacucd, mittra.mttrdt, 1::numeric)
            ELSE (1::numeric / MVXJDTA.get_currency_rate_local(mphead.iadivi, mphead.iacucd, mittra.mttrdt, 1::numeric))
        END AS exchratetoloc_rcvdt,
        (
            CASE
                WHEN mphead.iadivi::text = '800'::text
                THEN (mittra.mttrqt * mittra.mtmfco) * MVXJDTA.get_currency_rate_eur(mphead.iacono::integer, mphead.iadivi, 'BYN', mittra.mttrdt, 1::numeric)
                ELSE
                    CASE
                        WHEN mphead.iadivi::text = '400'::text
                        THEN (mittra.mttrqt * mittra.mtmfco) * MVXJDTA.get_currency_rate_eur(mphead.iacono::integer, mphead.iadivi, 'DKK', mittra.mttrdt, 1::numeric)
                        ELSE (mittra.mttrqt * mittra.mtmfco)
                    END
            END
        )::numeric(19,6) AS receivedeur,
        CASE
            WHEN cugex1.f1a030 IS NOT NULL
            THEN replace(replace(cugex1.f1a030::text, ' '::text, '1'::text), '999999.999'::text, 'NLS_NUMERIC_CHARACTERS='',.'''::text')::numeric
            ELSE (mittra.mttrqt * mitmas.mmgrwe)
        END AS receivedgrweight,
        CASE
            WHEN cugex1.f1a030 IS NOT NULL
            THEN replace(replace(cugex1.f1a030::text, ' '::text, '1'::text), '999999.999'::text, 'NLS_NUMERIC_CHARACTERS='',.'''::text')::numeric
            ELSE (mittra.mttrqt * mitmas.mmnewe)
        END AS receivedntweight,
        (mittra.mttrqt * mitmas.mmvol3)::double precision AS receivedvolume,
        mpline.ibpiad AS deliverycountry,
        mittra.mtttid
    FROM MVXJDTA.MPHEAD mphead
    JOIN MVXJDTA.MPLINE mpline
      ON mphead.iacono = mpline.ibcono
     AND mphead.iapuno::text = mpline.ibpuno::text
    JOIN MVXJDTA.MITTRA mittra
      ON mittra.mtcono = mpline.ibcono
     AND mpline.ibwhlo::text = mittra.mtwhlo::text
     AND mpline.ibpuno::text = mittra.mtridn::text
     AND mittra.mtitno::text = mpline.ibitno::text
     AND mpline.ibpnli = mittra.mtridl
     AND mpline.ibpnls = mittra.mtridx
    JOIN MVXJDTA.MITMAS mitmas
      ON mitmas.mmcono = mphead.iacono
     AND mittra.mtitno::text = mitmas.mmitno::text
    JOIN MVXJDTA.CIDMAS cidmas
      ON cidmas.idcono = mphead.iacono
     AND cidmas.idsuno::text = mphead.iasuno::text
    LEFT JOIN MVXJDTA.MITAUN alt
      ON mpline.ibcono = alt.mucono
     AND mitmas.mmitno::text = alt.muitno::text
     AND alt.muautp = 1
     AND alt.muaus1 = 1
    LEFT JOIN MVXJDTA.MITAUN altprice
      ON mpline.ibcono = altprice.mucono
     AND mitmas.mmitno::text = altprice.muitno::text
     AND altprice.muautp = 2
     AND altprice.muaus5 = 1
    LEFT JOIN MVXJDTA.CUGEX1 cugex1
      ON mphead.iacono = cugex1.f1cono
     AND mphead.iapuno::text = cugex1.f1pk02::text
     AND mittra.mtitno::text = cugex1.f1pk01::text
     AND cugex1.f1pk03::text = mittra.mtridl::character varying(6)::text
     AND to_date(mittra.mttrdt::character varying, 'YYYYMMDD') = to_date(cugex1.f1pk04::text, 'DDMMRR')
     AND cugex1.f1file::text = 'PPS300'::text
    WHERE mphead.iacono = 100
      AND mphead.iafaci::text <> '800'::text
      AND mittra.mttrdt >= 20190101
      AND mittra.mtttid::text = ANY (ARRAY['PPS'::character varying, 'PPG'::character varying, 'PPC'::character varying])
      AND mittra.mtanbr <> 999999999::bigint
      AND mpline.ibpusl::text >= '20'::text
      AND (
            mitmas.mmitty::text = ANY (ARRAY['10'::character varying, '20'::character varying, '30'::character varying, '40'::character varying, '50'::character varying, '85'::character varying, '90'::character varying, '80'::character varying, '99'::character varying])
         OR (
            mphead.iafaci::text = ANY (ARRAY['700'::character varying, '707'::character varying])
            AND mitmas.mmitty::text = '99'::text
         )
)
),
max_receiving AS (
    SELECT
        division,
        itemcode,
        MAX(receivingdate) OVER (PARTITION BY division, itemcode) AS maxreceivingdate,
        CASE
            WHEN MAX(receivingdate) OVER (PARTITION BY division, itemcode) = receivingdate
            THEN ordernumber
            ELSE ''
        END AS maxordernumber
    FROM purchase_recinv
    WHERE receivingdate >= 20220101
),
max_receiving_line AS (
    SELECT
        a.division,
        a.itemcode,
        a.suppliercode,
        a.receivingdate AS maxreceivingdate,
        a.ordernumber AS maxordernumber,
        MAX(a.orderlinenumber) AS maxorderlinenumber
    FROM purchase_recinv a
    INNER JOIN max_receiving b
            ON a.division = b.division
           AND a.itemcode = b.itemcode
           AND a.ordernumber = b.maxordernumber
           AND a.receivingdate = b.maxreceivingdate
    GROUP BY a.division, a.itemcode, a.suppliercode, a.receivingdate, a.ordernumber
)
SELECT
    p.division AS division,
    cidmas.idsunm AS supplier,
    p.itemcode AS l4_code,
    p.currency AS currency,
    MAX(m.maxreceivingdate) AS purchdate,
    ROUND((SUM(p.orderamount)::numeric / NULLIF(SUM(p.receivedquantity), 0)::numeric), 4) AS price_curr,
    ROUND((SUM(p.receivedamount - p.orderamountloccurr)::numeric / NULLIF(SUM(p.receivedquantity), 0)::numeric), 4) AS charge_loccurr
FROM purchase_recinv p
INNER JOIN max_receiving_line m
        ON m.division = p.division
       AND m.itemcode = p.itemcode
       AND m.maxordernumber = p.ordernumber
LEFT JOIN MVXJDTA.CIDMAS cidmas
       ON cidmas.idsuno = p.suppliercode
WHERE p.division <> '800'
GROUP BY p.division, cidmas.idsunm, p.itemcode, p.currency
HAVING SUM(p.receivedquantity) <> 0;

COMMENT ON VIEW ANAPLAN.AD_LAST_PURCH_PRICE_CALC IS
    'Last purchase price/charge per division/item/currency from direct MVXJDTA source tables; no view-on-view dependency.';
 SELECT mphead.iacono AS companycode,
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
            WHEN (mittra.mttrqt < (0)::numeric) THEN (mpline.iborqa * ('-1'::integer)::numeric)
            ELSE mpline.iborqa
        END)::double precision AS orderquantity,
    mpline.ibpuun AS unitofmeasure,
    ((mpline.iblnam / mpline.iborqa))::double precision AS purchaseprice,
    mphead.iacucd AS currency,
    (
        CASE
            WHEN (mittra.mttrqt < (0)::numeric) THEN (mpline.iblnam * ('-1'::integer)::numeric)
            ELSE mpline.iblnam
        END)::double precision AS lineamount,
    (((
        CASE
            WHEN (mittra.mtmfco < (0)::numeric) THEN (mpline.iblnam * ('-1'::integer)::numeric)
            ELSE mpline.iblnam
        END / (
        CASE
            WHEN (((mitmas.mmunms)::text <> (mpline.ibpuun)::text) AND ((alt.mualun)::text = (mpline.ibpuun)::text) AND (alt.mudmcf = 2)) THEN (mpline.iborqa / alt.mucofa)
            ELSE
            CASE
                WHEN (((mitmas.mmunms)::text <> (mpline.ibpuun)::text) AND ((alt.mualun)::text = (mpline.ibpuun)::text) AND (alt.mudmcf = 1)) THEN (mpline.iborqa * alt.mucofa)
                ELSE
                CASE
                    WHEN ((mpline.ibpuun)::text = (mpline.ibpuun)::text) THEN mpline.iborqa
                    ELSE mpline.iborqa
                END
            END
        END)::numeric(17,6)) * mittra.mttrqt))::numeric(19,6) AS orderamount,
    ((((
        CASE
            WHEN (mittra.mtmfco < (0)::numeric) THEN (mpline.iblnam * ('-1'::integer)::numeric)
            ELSE mpline.iblnam
        END *
        CASE
            WHEN ((mphead.iafaci)::text = '800'::text) THEN bousr.get_currency_rate_local(mphead.iadivi, mphead.iacucd, mittra.mttrdt, (1)::numeric)
            ELSE ((1)::numeric / bousr.get_currency_rate_local(mphead.iadivi, mphead.iacucd, mittra.mttrdt, (1)::numeric))
        END) / (
        CASE
            WHEN (((mitmas.mmunms)::text <> (mpline.ibpuun)::text) AND ((alt.mualun)::text = (mpline.ibpuun)::text) AND (alt.mudmcf = 2)) THEN (mpline.iborqa / alt.mucofa)
            ELSE
            CASE
                WHEN (((mitmas.mmunms)::text <> (mpline.ibpuun)::text) AND ((alt.mualun)::text = (mpline.ibpuun)::text) AND (alt.mudmcf = 1)) THEN (mpline.iborqa * alt.mucofa)
                ELSE
                CASE
                    WHEN ((mpline.ibpuun)::text = (mpline.ibpuun)::text) THEN mpline.iborqa
                    ELSE mpline.iborqa
                END
            END
        END)::numeric(17,6)) * mittra.mttrqt))::numeric(19,6) AS orderamountloccurr,
    (bousr.get_currency_rate_eur((mphead.iacono)::integer, mphead.iadivi, mphead.iacucd, mphead.iapudt, ((1)::bigint)::numeric))::double precision AS exchratetoeur_orddt,
    ((((
        CASE
            WHEN (mittra.mtmfco < (0)::numeric) THEN (mpline.iblnam * ('-1'::integer)::numeric)
            ELSE mpline.iblnam
        END * bousr.get_currency_rate_eur((mphead.iacono)::integer, mphead.iadivi, mphead.iacucd, mittra.mttrdt, ((1)::bigint)::numeric)) / (
        CASE
            WHEN (((mitmas.mmunms)::text <> (mpline.ibpuun)::text) AND ((alt.mualun)::text = (mpline.ibpuun)::text) AND (alt.mudmcf = 2)) THEN (mpline.iborqa / alt.mucofa)
            ELSE
            CASE
                WHEN (((mitmas.mmunms)::text <> (mpline.ibpuun)::text) AND ((alt.mualun)::text = (mpline.ibpuun)::text) AND (alt.mudmcf = 1)) THEN (mpline.iborqa * alt.mucofa)
                ELSE
                CASE
                    WHEN ((mpline.ibpuun)::text = (mpline.ibpuun)::text) THEN mpline.iborqa
                    ELSE mpline.iborqa
                END
            END
        END)::numeric(17,6)) * mittra.mttrqt))::numeric(19,6) AS orderedeur,
    0 AS reqdeldate,
    mittra.mtrepn AS receivingnr,
    mittra.mttrdt AS receivingdate,
    mittra.mttrqt AS receivedquantity,
    (
        CASE
            WHEN (((mitmas.mmunms)::text <> (mpline.ibpuun)::text) AND (alt.mudmcf = 2)) THEN (mittra.mttrqt * alt.mucofa)
            ELSE
            CASE
                WHEN (((mitmas.mmunms)::text <> (mpline.ibpuun)::text) AND (alt.mudmcf = 1)) THEN (mittra.mttrqt / alt.mucofa)
                ELSE
                CASE
                    WHEN ((mpline.ibppun)::text = (mpline.ibpuun)::text) THEN mittra.mttrqt
                    ELSE mittra.mttrqt
                END
            END
        END)::numeric(17,6) AS receivedquantityalt,
    ((mittra.mttrqt * mittra.mtmfco))::double precision AS receivedamount,
    (bousr.get_currency_rate_eur((mphead.iacono)::integer, mphead.iadivi, mphead.iacucd, mittra.mttrdt, ((1)::bigint)::numeric))::double precision AS exchratetoeur_rcvdt,
        CASE
            WHEN ((mphead.iafaci)::text = '800'::text) THEN bousr.get_currency_rate_local(mphead.iadivi, mphead.iacucd, mittra.mttrdt, (1)::numeric)
            ELSE ((1)::numeric / bousr.get_currency_rate_local(mphead.iadivi, mphead.iacucd, mittra.mttrdt, (1)::numeric))
        END AS exchratetoloc_rcvdt,
    (
        CASE
            WHEN ((mphead.iadivi)::text = '800'::text) THEN ((mittra.mttrqt * mittra.mtmfco) * bousr.get_currency_rate_eur((mphead.iacono)::integer, mphead.iadivi, 'BYN'::character varying, mittra.mttrdt, ((1)::bigint)::numeric))
            ELSE
            CASE
                WHEN ((mphead.iadivi)::text = '400'::text) THEN ((mittra.mttrqt * mittra.mtmfco) * bousr.get_currency_rate_eur((mphead.iacono)::integer, mphead.iadivi, 'DKK'::character varying, mittra.mttrdt, ((1)::bigint)::numeric))
                ELSE (mittra.mttrqt * mittra.mtmfco)
            END
        END)::numeric(19,6) AS receivedeur,
        CASE
            WHEN (cugex1.f1a030 IS NOT NULL) THEN (replace(replace((cugex1.f1a030)::text, ' '::text, '1'::text), '999999.999'::text, 'NLS_NUMERIC_CHARACTERS='',.'''::text))::numeric
            ELSE (mittra.mttrqt * mitmas.mmgrwe)
        END AS receivedgrweight,
        CASE
            WHEN (cugex1.f1a030 IS NOT NULL) THEN (replace(replace((cugex1.f1a030)::text, ' '::text, '1'::text), '999999.999'::text, 'NLS_NUMERIC_CHARACTERS='',.'''::text))::numeric
            ELSE (mittra.mttrqt * mitmas.mmnewe)
        END AS receivedntweight,
    ((mittra.mttrqt * mitmas.mmvol3))::double precision AS receivedvolume,
    mpline.ibpiad AS deliverycountry,
    mittra.mtttid
   FROM (((((((mvxjdta.mphead
     JOIN mvxjdta.mpline ON (((mphead.iacono = mpline.ibcono) AND ((mphead.iapuno)::text = (mpline.ibpuno)::text))))
     JOIN mvxjdta.mittra ON (((mittra.mtcono = mpline.ibcono) AND ((mpline.ibwhlo)::text = (mittra.mtwhlo)::text) AND ((mpline.ibpuno)::text = (mittra.mtridn)::text) AND ((mittra.mtitno)::text = (mpline.ibitno)::text) AND (mpline.ibpnli = mittra.mtridl) AND (mpline.ibpnls = mittra.mtridx))))
     JOIN mvxjdta.mitmas ON (((mitmas.mmcono = mphead.iacono) AND ((mittra.mtitno)::text = (mitmas.mmitno)::text))))
     JOIN mvxjdta.cidmas ON (((cidmas.idcono = mphead.iacono) AND ((cidmas.idsuno)::text = (mphead.iasuno)::text))))
     LEFT JOIN mvxjdta.mitaun alt ON (((mpline.ibcono = alt.mucono) AND ((mitmas.mmitno)::text = (alt.muitno)::text) AND (alt.muautp = 1) AND (alt.muaus1 = 1))))
     LEFT JOIN mvxjdta.mitaun altprice ON (((mpline.ibcono = altprice.mucono) AND ((mitmas.mmitno)::text = (altprice.muitno)::text) AND (altprice.muautp = 2) AND (altprice.muaus5 = 1))))
     LEFT JOIN mvxjdta.cugex1 ON (((mphead.iacono = cugex1.f1cono) AND ((mphead.iapuno)::text = (cugex1.f1pk02)::text) AND ((mittra.mtitno)::text = (cugex1.f1pk01)::text) AND ((cugex1.f1pk03)::text = ((mittra.mtridl)::character varying(6))::text) AND (to_date(((mittra.mttrdt)::character varying)::text, 'YYYYMMDD'::text) = to_date((cugex1.f1pk04)::text, 'DDMMRR'::text)) AND ((cugex1.f1file)::text = 'PPS300'::text))))
  WHERE ((mphead.iacono = 100) AND ((mphead.iafaci)::text <> '800'::text) AND (mittra.mttrdt >= 20190101) AND ((mittra.mtttid)::text = ANY (ARRAY[('PPS'::character varying)::text, ('PPG'::character varying)::text, ('PPC'::character varying)::text])) AND (mittra.mtanbr <> '999999999'::bigint) AND ((mpline.ibpusl)::text >= '20'::text) AND (((mitmas.mmitty)::text = ANY (ARRAY[('10'::character varying)::text, ('20'::character varying)::text, ('30'::character varying)::text, ('40'::character varying)::text, ('50'::character varying)::text, ('85'::character varying)::text, ('90'::character varying)::text, ('80'::character varying)::text, ('99'::character varying)::text])) OR (((mphead.iafaci)::text = ANY (ARRAY[('700'::character varying)::text, ('707'::character varying)::text])) AND ((mitmas.mmitty)::text = '99'::text))));
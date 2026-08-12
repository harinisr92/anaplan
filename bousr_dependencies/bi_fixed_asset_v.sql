 SELECT ffasma.fmdivi AS division,
        CASE ffasma.fmfast
            WHEN 1 THEN 'Normal'::text
            WHEN 5 THEN 'Preliminary'::text
            WHEN 8 THEN 'Fully depreciated'::text
            WHEN 9 THEN 'Sold_Disposed'::text
            ELSE 'Other'::text
        END AS status,
    (((ffasma.fmasid)::text || '- '::text) || ffasma.fmsbno) AS faid,
    ffasma.fmtxt1 AS fa_name,
    ffasma.fmfatp AS fa_typeid,
    fatp.cttx40 AS fa_type,
    ffasma.fmloc1 AS locationid,
    faloc.cttx40 AS location,
    ffasma.fmait2 AS costcenter,
    ffasma.fmfaqt AS quantity,
    cidmas.idsunm AS payee,
    ffasma.fmpper AS aquisitiondate,
    ffasma.fmaper AS activationdate,
        CASE dep.fddpmd
            WHEN 0 THEN 'Not depreciated'::text
            WHEN 1 THEN 'Linear'::text
            WHEN 2 THEN 'Declining'::text
            ELSE 'Other'::text
        END AS deprmethod,
    dep.fdnomt AS lifetime_months,
    ffahis.fhvatp AS transactionid,
    vatp.cttx40 AS transaction,
    ffahis.fhvper AS period,
    ffahis.fhait1,
    ffahis.fhait2,
    ffahis.fhait3,
    ffahis.fhait5,
    ffahis.fhfava AS amount
   FROM ((((((mvxjdta.ffasma
     LEFT JOIN mvxjdta.ffahis ON ((((ffahis.fhdivi)::text = (ffasma.fmdivi)::text) AND ((ffahis.fhasid)::text = (ffasma.fmasid)::text) AND (ffahis.fhsbno = ffasma.fmsbno))))
     LEFT JOIN mvxjdta.csytab fatp ON ((((fatp.ctdivi)::text = (ffasma.fmdivi)::text) AND ((fatp.ctstky)::text = ((ffasma.fmfatp)::character varying)::text) AND ((fatp.ctstco)::text = 'FATP'::text))))
     LEFT JOIN mvxjdta.csytab faloc ON ((((faloc.ctdivi)::text = (ffasma.fmdivi)::text) AND ((faloc.ctstky)::text = (ffasma.fmloc1)::text) AND ((faloc.ctstco)::text = 'PLC1'::text))))
     LEFT JOIN mvxjdta.cidmas ON (((cidmas.idsuno)::text = (ffasma.fmspyn)::text)))
     LEFT JOIN mvxjdta.csytab vatp ON ((((vatp.ctdivi)::text = (ffahis.fhdivi)::text) AND ((vatp.ctstky)::text = ((ffahis.fhvatp)::character varying)::text) AND ((vatp.ctstco)::text = 'VATP'::text))))
     LEFT JOIN mvxjdta.ffasdm dep ON ((((dep.fddivi)::text = (ffasma.fmdivi)::text) AND ((dep.fdasid)::text = (ffasma.fmasid)::text) AND (dep.fdsbno = ffasma.fmsbno))))
  WHERE ((ffahis.fhdivi)::text <> '800'::text);
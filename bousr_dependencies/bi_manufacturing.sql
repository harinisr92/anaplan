 SELECT mittra.mtcono AS companycode,
    mitwhl.mwdivi AS division,
    mittra.mtwhlo AS warehouse,
    mwoope.voplgr AS prod_line,
    mittra.mtitno AS productcode,
    mittra.mttrdt AS manuf_date,
    mittra.mttrtp AS manuf_ordertype,
    mittra.mtridn AS ordernr,
    sum(mittra.mttrqt) AS manuf_qty,
    sum((mittra.mttrqt * mitmas.mmvol3)) AS manuf_vol,
    avg(mittra.mttrpr) AS trans_price,
        CASE
            WHEN (((mitmas.mmitty)::text = '10'::text) AND ((mittra.mttrtp)::text = '2PK'::text)) THEN 'MULTIPACK PACKING'::text
            WHEN (((mitmas.mmitty)::text = '10'::text) AND ((mwoope.voplgr)::text = ANY (ARRAY[('610'::character varying)::text, ('613'::character varying)::text]))) THEN 'MULTIPACK PACKING'::text
            WHEN (((mitmas.mmitty)::text = '10'::text) AND ((mittra.mttrtp)::text = ANY (ARRAY[('2RE'::character varying)::text, ('7GR'::character varying)::text, ('7PA'::character varying)::text, ('7PE'::character varying)::text, ('7PI'::character varying)::text, ('7PR'::character varying)::text, ('7PL'::character varying)::text, ('7VP'::character varying)::text, ('8RE'::character varying)::text, ('4RE'::character varying)::text, ('7WR'::character varying)::text, ('7PM'::character varying)::text, ('7PS'::character varying)::text]))) THEN 'WAREHOUSE REPAKCING'::text
            WHEN ((mwoope.voplgr)::text = ANY (ARRAY[('100'::character varying)::text, ('130'::character varying)::text, ('170'::character varying)::text, ('175'::character varying)::text, ('9000'::character varying)::text, ('418'::character varying)::text, ('419'::character varying)::text, ('420'::character varying)::text, ('450'::character varying)::text])) THEN 'WAREHOUSE REPAKCING'::text
            WHEN ((mitmas.mmitty)::text = '40'::text) THEN 'SEMI MANUFACTURING'::text
            ELSE 'FILLING'::text
        END AS manuf_type
   FROM (((mvxjdta.mittra
     LEFT JOIN mvxjdta.mitmas ON (((mittra.mtcono = mitmas.mmcono) AND ((mittra.mtitno)::text = (mitmas.mmitno)::text))))
     LEFT JOIN mvxjdta.mitwhl ON (((mitwhl.mwcono = mittra.mtcono) AND ((mitwhl.mwwhlo)::text = (mittra.mtwhlo)::text))))
     LEFT JOIN mvxjdta.mwoope ON (((mittra.mtcono = mwoope.vocono) AND ((mittra.mtridn)::text = (mwoope.vomfno)::text))))
  WHERE ((mittra.mtcono = 100) AND ((mitwhl.mwdivi)::text <> '800'::text) AND ((mittra.mtttid)::text = ANY (ARRAY[('WOP'::character varying)::text, ('WMP'::character varying)::text])) AND ((mitmas.mmitty)::text = ANY (ARRAY[('10'::character varying)::text, ('40'::character varying)::text])) AND ((mittra.mttrtp)::text <> '171'::text) AND ((mittra.mtwhlo)::text <> ALL (ARRAY[('430'::character varying)::text, ('435'::character varying)::text])))
  GROUP BY mittra.mtcono, mitwhl.mwdivi, mittra.mtwhlo, mwoope.voplgr, mittra.mtitno, mittra.mttrdt, mittra.mttrtp, mittra.mtridn,
        CASE
            WHEN (((mitmas.mmitty)::text = '10'::text) AND ((mittra.mttrtp)::text = '2PK'::text)) THEN 'MULTIPACK PACKING'::text
            WHEN (((mitmas.mmitty)::text = '10'::text) AND ((mwoope.voplgr)::text = ANY (ARRAY[('610'::character varying)::text, ('613'::character varying)::text]))) THEN 'MULTIPACK PACKING'::text
            WHEN (((mitmas.mmitty)::text = '10'::text) AND ((mittra.mttrtp)::text = ANY (ARRAY[('2RE'::character varying)::text, ('7GR'::character varying)::text, ('7PA'::character varying)::text, ('7PE'::character varying)::text, ('7PI'::character varying)::text, ('7PR'::character varying)::text, ('7PL'::character varying)::text, ('7VP'::character varying)::text, ('8RE'::character varying)::text, ('4RE'::character varying)::text, ('7WR'::character varying)::text, ('7PM'::character varying)::text, ('7PS'::character varying)::text]))) THEN 'WAREHOUSE REPAKCING'::text
            WHEN ((mwoope.voplgr)::text = ANY (ARRAY[('100'::character varying)::text, ('130'::character varying)::text, ('170'::character varying)::text, ('175'::character varying)::text, ('9000'::character varying)::text, ('418'::character varying)::text, ('419'::character varying)::text, ('420'::character varying)::text, ('450'::character varying)::text])) THEN 'WAREHOUSE REPAKCING'::text
            WHEN ((mitmas.mmitty)::text = '40'::text) THEN 'SEMI MANUFACTURING'::text
            ELSE 'FILLING'::text
        END;
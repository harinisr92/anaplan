 SELECT DISTINCT mpdope.pofaci AS division,
    mpdope.poprno AS product,
        CASE
            WHEN ((mpdope.pofaci)::text = '400'::text) THEN mpdope.poplgr
            ELSE mitfac.m9wcln
        END AS productionline,
    mb1.mbeoqt AS orderqty,
    (mb1.mbeoqt * mitmas.mmvol3) AS orderqty_l,
    mpdope.popiti AS runtime,
    mpdope.poctcd AS efficiency,
    mpdope.poprnp AS filling_people,
    mpdope.poseti AS setup_time,
    mpdope.posenp AS setup_people,
    round(
        CASE
            WHEN ((mpdope.poctcd = 0) OR (mitmas.mmvol3 = (0)::numeric)) THEN (0)::numeric
            ELSE (((mpdope.popiti / (mpdope.poctcd)::numeric) / mitmas.mmvol3) * (1000)::numeric)
        END, 6) AS fill_mh_1000l,
    round(
        CASE
            WHEN ((mpdope.poctcd = 0) OR (mitmas.mmvol3 = (0)::numeric)) THEN (0)::numeric
            ELSE ((((mpdope.poprnp * mpdope.popiti) / (mpdope.poctcd)::numeric) / mitmas.mmvol3) * (1000)::numeric)
        END, 6) AS fill_lh_1000l,
    round(
        CASE
            WHEN ((mb1.mbeoqt = (0)::numeric) OR (mpdope.poseti = (0)::numeric) OR (mitmas.mmvol3 = (0)::numeric)) THEN (0)::numeric
            ELSE (((mpdope.poseti / mb1.mbeoqt) / mitmas.mmvol3) * (1000)::numeric)
        END, 6) AS setup_mh_1000l,
    round(
        CASE
            WHEN ((mb1.mbeoqt = (0)::numeric) OR (mpdope.poseti = (0)::numeric) OR (mitmas.mmvol3 = (0)::numeric)) THEN (0)::numeric
            ELSE ((((mpdope.poseti * mpdope.posenp) / mb1.mbeoqt) / mitmas.mmvol3) * (1000)::numeric)
        END, 6) AS setup_lh_1000l,
    mitmas.mmvol3 AS volume
   FROM (((mvxjdta.mpdope
     JOIN mvxjdta.mitmas ON (((mitmas.mmcono = 100) AND ((mitmas.mmitno)::text = (mpdope.poprno)::text))))
     LEFT JOIN mvxjdta.mitfac ON (((mitfac.m9cono = mitmas.mmcono) AND ((mitfac.m9faci)::text = (mpdope.pofaci)::text) AND ((mitfac.m9itno)::text = (mitmas.mmitno)::text))))
     LEFT JOIN mvxjdta.mitbal mb1 ON (((mb1.mbcono = mitfac.m9cono) AND ((mb1.mbitno)::text = (mitmas.mmitno)::text) AND ((mitfac.m9rewh)::text = (mb1.mbwhlo)::text))))
  WHERE ((mpdope.pocono = 100) AND ((mpdope.pofaci)::text <> '800'::text) AND ((mpdope.postrt)::text = ANY (ARRAY[('100'::character varying)::text, ('106'::character varying)::text])) AND (mpdope.posdcd = 1) AND ((mitmas.mmitty)::text = ANY (ARRAY[('10'::character varying)::text, ('40'::character varying)::text])) AND ((mitmas.mmstat)::text <= '20'::text));
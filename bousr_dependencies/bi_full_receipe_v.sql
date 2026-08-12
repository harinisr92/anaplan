 SELECT unnamed_subquery.pmcono,
    unnamed_subquery.pmfaci,
    unnamed_subquery.root_id,
    unnamed_subquery.pmprno,
    unnamed_subquery.pmmtno,
    unnamed_subquery.pmmseq,
    unnamed_subquery.pmcnqt,
    unnamed_subquery.pmcnqt2,
        CASE
            WHEN (bum.faci IS NOT NULL) THEN bum.conv_f
            ELSE (1)::numeric
        END AS unms_convertformula,
    (round((bousr.receipt_multiplier(('1'::text || (unnamed_subquery.formula_text_all)::text)))::numeric, 6) *
        CASE
            WHEN (bum.faci IS NOT NULL) THEN bum.conv_f
            ELSE (1)::numeric
        END) AS full_qty,
    round((bousr.receipt_multiplier(('1'::text || (unnamed_subquery.formula_text_all)::text)))::numeric, 6) AS formula
   FROM ((( WITH RECURSIVE cte AS (
                 SELECT DISTINCT alias13.pmcono,
                    alias13.pmfaci,
                    alias13.pmprno,
                    alias13.pmprno AS root_id,
                    alias13.pmmtno,
                    alias13.pmmseq,
                    alias13.pmcnqt,
                    alias13.pmcnqt2,
                    1 AS level,
                    (alias13.pmcnqt)::character varying AS formula_text_all
                   FROM ( SELECT mpdmat.pmcono,
                            mpdmat.pmfaci,
                            mpdmat.pmprno,
                            mpdmat.pmstrt,
                            mpdmat.pmmtno,
                            mpdmat.pmmseq,
                            round((((((
                                CASE
                                    WHEN (mpdmat.pmwapc <> (0)::numeric) THEN mpdmat.pmwapc
                                    WHEN (mitmas_1.mmwapc <> (0)::numeric) THEN mitmas_1.mmwapc
                                    ELSE (0)::numeric
                                END + (100)::numeric) * mpdmat.pmcnqt) * (
                                CASE
                                    WHEN (mpdmat.pmbypr = 0) THEN 1
                                    ELSE '-1'::integer
                                END)::numeric) / (100)::numeric) /
                                CASE
                                    WHEN (mpdhed.phbaqt = (0)::numeric) THEN (1)::numeric
                                    ELSE mpdhed.phbaqt
                                END), 8) AS pmcnqt,
                            round((((
                                CASE
                                    WHEN (mpdmat.pmbypr = 0) THEN 1
                                    ELSE '-1'::integer
                                END)::numeric * mpdmat.pmcnqt) /
                                CASE
                                    WHEN (mpdhed.phbaqt = (0)::numeric) THEN (1)::numeric
                                    ELSE mpdhed.phbaqt
                                END), 8) AS pmcnqt2
                           FROM ((mvxjdta.mpdmat
                             JOIN mvxjdta.mitmas mitmas_1 ON (((mitmas_1.mmcono = mpdmat.pmcono) AND ((mitmas_1.mmitno)::text = (mpdmat.pmmtno)::text))))
                             JOIN mvxjdta.mpdhed ON (((mpdhed.phcono = mpdmat.pmcono) AND ((mpdhed.phfaci)::text = (mpdmat.pmfaci)::text) AND ((mpdhed.phstrt)::text = (mpdmat.pmstrt)::text) AND ((mpdhed.phprno)::text = (mpdmat.pmprno)::text))))
                          WHERE ((mpdmat.pmcono = 100) AND ((mpdmat.pmfaci)::text <> '800'::text) AND ((mpdmat.pmstrt)::text = '100'::text) AND ((mpdmat.pmmtno)::text <> '2400999'::text))) alias13
                UNION ALL
                 SELECT DISTINCT alias14.pmcono,
                    alias14.pmfaci,
                    alias14.pmprno,
                    c.root_id,
                    alias14.pmmtno,
                    alias14.pmmseq,
                    alias14.pmcnqt,
                    alias14.pmcnqt2,
                    (c.level + 1),
                    (((c.formula_text_all)::text || '*'::text) || ((alias14.pmcnqt)::character varying)::text) AS formula_text_all
                   FROM (( SELECT mpdmat.pmcono,
                            mpdmat.pmfaci,
                            mpdmat.pmprno,
                            mpdmat.pmstrt,
                            mpdmat.pmmtno,
                            mpdmat.pmmseq,
                            round((((((
                                CASE
                                    WHEN (mpdmat.pmwapc <> (0)::numeric) THEN mpdmat.pmwapc
                                    WHEN (mitmas_1.mmwapc <> (0)::numeric) THEN mitmas_1.mmwapc
                                    ELSE (0)::numeric
                                END + (100)::numeric) * mpdmat.pmcnqt) * (
                                CASE
                                    WHEN (mpdmat.pmbypr = 0) THEN 1
                                    ELSE '-1'::integer
                                END)::numeric) / (100)::numeric) /
                                CASE
                                    WHEN (mpdhed.phbaqt = (0)::numeric) THEN (1)::numeric
                                    ELSE mpdhed.phbaqt
                                END), 8) AS pmcnqt,
                            round((((
                                CASE
                                    WHEN (mpdmat.pmbypr = 0) THEN 1
                                    ELSE '-1'::integer
                                END)::numeric * mpdmat.pmcnqt) /
                                CASE
                                    WHEN (mpdhed.phbaqt = (0)::numeric) THEN (1)::numeric
                                    ELSE mpdhed.phbaqt
                                END), 8) AS pmcnqt2
                           FROM ((mvxjdta.mpdmat
                             JOIN mvxjdta.mitmas mitmas_1 ON (((mitmas_1.mmcono = mpdmat.pmcono) AND ((mitmas_1.mmitno)::text = (mpdmat.pmmtno)::text))))
                             JOIN mvxjdta.mpdhed ON (((mpdhed.phcono = mpdmat.pmcono) AND ((mpdhed.phfaci)::text = (mpdmat.pmfaci)::text) AND ((mpdhed.phstrt)::text = (mpdmat.pmstrt)::text) AND ((mpdhed.phprno)::text = (mpdmat.pmprno)::text))))
                          WHERE ((mpdmat.pmcono = 100) AND ((mpdmat.pmfaci)::text <> '800'::text) AND ((mpdmat.pmstrt)::text = '100'::text) AND ((mpdmat.pmmtno)::text <> '2400999'::text))) alias14
                     JOIN cte c ON (((c.pmmtno)::text = (alias14.pmprno)::text)))
                )
         SELECT cte.pmcono,
            cte.pmfaci,
            cte.pmprno,
            cte.pmmtno,
            cte.pmmseq,
            cte.pmcnqt,
            cte.pmcnqt2,
            cte.level,
            cte.formula_text_all,
            cte.root_id
           FROM cte
          WHERE (NOT ((cte.pmmtno)::text IN ( SELECT cte_1.pmprno
                   FROM cte cte_1)))
          ORDER BY cte.level, cte.pmprno, cte.pmmseq) unnamed_subquery
     JOIN mvxjdta.mitmas ON (((mitmas.mmcono = unnamed_subquery.pmcono) AND ((mitmas.mmitno)::text = (unnamed_subquery.pmmtno)::text) AND ((mitmas.mmitty)::text <> ALL (ARRAY[('10'::character varying)::text, ('40'::character varying)::text])))))
     LEFT JOIN ( SELECT DISTINCT mpdmat.pmfaci AS faci,
            mpdmat.pmprno AS prod,
            mpdmat.pmmtno AS mat,
            mpdmat.pmpeun,
            mat.mmunms,
                CASE
                    WHEN (mitaun.mudmcf = 2) THEN ((1)::numeric / mitaun.mucofa)
                    WHEN (mitaun.mudmcf = 1) THEN ((1)::numeric * mitaun.mucofa)
                    ELSE (1)::numeric
                END AS conv_f
           FROM ((mvxjdta.mpdmat
             JOIN mvxjdta.mitmas mat ON (((mat.mmcono = mpdmat.pmcono) AND ((mat.mmitno)::text = (mpdmat.pmmtno)::text))))
             JOIN mvxjdta.mitaun ON (((mat.mmcono = mitaun.mucono) AND ((mat.mmitno)::text = (mitaun.muitno)::text) AND (mitaun.muautp = '1'::smallint))))
          WHERE (((mpdmat.pmfaci)::numeric = (100)::numeric) AND ((mat.mmitty)::text <> '10'::text) AND ((mat.mmunms)::text <> (mpdmat.pmpeun)::text))) bum ON ((((bum.faci)::text = (unnamed_subquery.pmfaci)::text) AND ((bum.prod)::text = (unnamed_subquery.pmprno)::text) AND ((bum.mat)::text = (unnamed_subquery.pmmtno)::text))));
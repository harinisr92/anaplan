 SELECT ootype.oocono AS companycode,
        CASE
            WHEN ((ootype.ooortp)::text ~~ '1%'::text) THEN 100
            WHEN ((ootype.ooortp)::text ~~ '3%'::text) THEN 300
            WHEN ((ootype.ooortp)::text ~~ '9%'::text) THEN 100
            WHEN ((ootype.ooortp)::text ~~ '2%'::text) THEN 200
            WHEN ((ootype.ooortp)::text ~~ '6%'::text) THEN 600
            WHEN ((ootype.ooortp)::text ~~ '7%'::text) THEN 700
            WHEN ((ootype.ooortp)::text ~~ '8%'::text) THEN 800
            WHEN ((ootype.ooortp)::text ~~ '4%'::text) THEN 400
            ELSE NULL::integer
        END AS division,
    ootype.ooortp AS ordertype,
    ootype.ootx40,
    cugex1.f1a030 AS ordertypegroup,
    (((ootype.ooortp)::text || ' - '::text) || (ootype.ootx15)::text) AS ordertypelocal
   FROM (mvxjdta.ootype
     LEFT JOIN mvxjdta.cugex1 ON (((ootype.oocono = cugex1.f1cono) AND ((ootype.ooortp)::text = (cugex1.f1pk01)::text) AND ((cugex1.f1file)::text = 'OOTYPE'::text))))
  WHERE ((ootype.oocono = 100) AND ((ootype.ooortp)::text <> ALL (ARRAY[('KVA'::character varying)::text, ('KVI'::character varying)::text, ('KVB'::character varying)::text, ('448'::character varying)::text, ('978'::character varying)::text])) AND ((ootype.ooortp)::text !~~ '8%'::text));
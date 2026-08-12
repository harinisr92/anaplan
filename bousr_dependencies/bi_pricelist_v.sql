 SELECT unnamed_subquery.companycode,
    unnamed_subquery.division,
    unnamed_subquery.pricelist_code,
    unnamed_subquery.pricelist_region,
    unnamed_subquery.pricelist_cucl,
    unnamed_subquery.date_from,
    unnamed_subquery.date_to,
    unnamed_subquery.itemcode,
    round(max(unnamed_subquery.price), 2) AS price,
    unnamed_subquery.price_multiple,
    max(unnamed_subquery.registrydate) AS registrydate,
    max(unnamed_subquery.registrytime) AS registrytime,
    max(unnamed_subquery.lastmodifydate) AS lastmodifydate,
    max(unnamed_subquery.changedby::text) AS changed_by
   FROM ( SELECT oprbas.odcono AS companycode,
                CASE
                    WHEN oprbas.odprrf::text ~~ '2%'::text THEN 200
                    WHEN oprbas.odprrf::text ~~ '7%'::text THEN 700
                    WHEN oprbas.odprrf::text ~~ '6%'::text THEN 600
                    WHEN oprbas.odprrf::text ~~ '4%'::text THEN 400
                    ELSE NULL::integer
                END AS division,
            oprbas.odprrf AS pricelist_code,
                CASE
                    WHEN oprbas.odprrf::text = ANY (ARRAY['2A0'::character varying::text, '7C1'::character varying::text, '6R1'::character varying::text, '400'::character varying::text]) THEN 'DOMESTIC'::text
                    WHEN oprbas.odprrf::text = ANY (ARRAY['2A2'::character varying::text, '2B8'::character varying::text, '7CE'::character varying::text]) THEN 'EXPORT'::text
                    WHEN oprbas.odprrf::text = ANY (ARRAY['2B2'::character varying::text, '7CG'::character varying::text]) THEN 'GROUP'::text
                    ELSE NULL::text
                END AS pricelist_region,
            ' '::text AS pricelist_cucl,
            oprbas.odfvdt AS date_from,
            oprbas.odlvdt AS date_to,
            oprbas.oditno AS itemcode,
            oprbas.odsapr * mitaun.mucofa AS price,
            oprbas.odsacd AS price_multiple,
            oprbas.odrgdt AS registrydate,
            oprbas.odrgtm AS registrytime,
            oprbas.odlmdt AS lastmodifydate,
            oprbas.odchid AS changedby
           FROM mvxjdta.oprbas
             JOIN ( SELECT oprbas_1.odprrf AS prrf,
                    oprbas_1.odcuno AS cuno,
                    max(oprbas_1.odfvdt) AS fvdt,
                    oprbas_1.odcono AS cono
                   FROM mvxjdta.oprbas oprbas_1
                  WHERE (oprbas_1.odprrf::text = ANY (ARRAY['2A0'::character varying::text, '2A2'::character varying::text, '2B2'::character varying::text, '2B8'::character varying::text, '7C1'::character varying::text, '7CE'::character varying::text, '7CG'::character varying::text, '6R1'::character varying::text, '400'::character varying::text])) AND oprbas_1.odcuno::text = ''::text AND oprbas_1.odlvdt >= to_char(CURRENT_DATE::timestamp with time zone, 'YYYYMMDD'::text)::integer
                  GROUP BY oprbas_1.odprrf, oprbas_1.odcuno, oprbas_1.odcono) unnamed_subquery_1 ON unnamed_subquery_1.cuno::text = oprbas.odcuno::text AND unnamed_subquery_1.cono = oprbas.odcono AND unnamed_subquery_1.prrf::text = oprbas.odprrf::text AND oprbas.odfvdt = unnamed_subquery_1.fvdt
             LEFT JOIN mvxjdta.mitaun ON mitaun.mucono = oprbas.odcono AND mitaun.muitno::text = oprbas.oditno::text AND mitaun.mualun::text = 'PCS'::text AND mitaun.muautp = '2'::smallint
          WHERE oprbas.odcono = 100) unnamed_subquery
  GROUP BY unnamed_subquery.companycode, unnamed_subquery.division, unnamed_subquery.pricelist_code, unnamed_subquery.pricelist_region, unnamed_subquery.pricelist_cucl, unnamed_subquery.date_from, unnamed_subquery.date_to, unnamed_subquery.itemcode, unnamed_subquery.price_multiple
UNION
 SELECT oprbas.odcono AS companycode,
        CASE
            WHEN oprbas.odprrf::text ~~ '2%'::text THEN 200
            WHEN oprbas.odprrf::text ~~ '7%'::text THEN 700
            WHEN oprbas.odprrf::text ~~ '6%'::text THEN 600
            ELSE NULL::integer
        END AS division,
    oprbas.odprrf AS pricelist_code,
        CASE
            WHEN oprbas.odprrf::text = ANY (ARRAY['2A0'::character varying::text, '7C1'::character varying::text]) THEN 'TRAVELTRADE'::text
            ELSE NULL::text
        END AS pricelist_region,
    ' '::text AS pricelist_cucl,
    oprbas.odfvdt AS date_from,
    oprbas.odlvdt AS date_to,
    oprbas.oditno AS itemcode,
    oprbas.odsapr AS price,
    oprbas.odsacd AS price_multiple,
    oprbas.odrgdt AS registrydate,
    oprbas.odrgtm AS registrytime,
    oprbas.odlmdt AS lastmodifydate,
    oprbas.odchid AS changed_by
   FROM mvxjdta.oprbas
     JOIN ( SELECT oprbas_1.odprrf AS prrf,
            oprbas_1.odcuno AS cuno,
            max(oprbas_1.odfvdt) AS fvdt,
            oprbas_1.odcono AS cono
           FROM mvxjdta.oprbas oprbas_1
          WHERE (oprbas_1.odprrf::text = ANY (ARRAY['2A0'::character varying::text, '7C1'::character varying::text])) AND oprbas_1.odcuno::text = ' '::text AND oprbas_1.odlvdt >= to_char(CURRENT_DATE::timestamp with time zone, 'YYYYMMDD'::text)::integer
          GROUP BY oprbas_1.odprrf, oprbas_1.odcuno, oprbas_1.odcono) unnamed_subquery ON unnamed_subquery.cuno::text = oprbas.odcuno::text AND unnamed_subquery.cono = oprbas.odcono AND unnamed_subquery.prrf::text = oprbas.odprrf::text AND oprbas.odfvdt = unnamed_subquery.fvdt
  WHERE oprbas.odcono = 100;
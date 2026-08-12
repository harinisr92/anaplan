 SELECT mitmas.mmcono AS companycode,
    mitmas.mmpdln AS division,
    mitmas.mmitno AS itemcode,
    mitmas.mmitds AS itemname,
    mitmas.mmfuds AS itemname2,
    mitmas.mmitty AS itemtype,
    mitmas.mmitgr AS itemgroup,
    mitmas.mmitcl AS itemclass,
    mitmas.mmstat AS itemstatus,
    mitmas.mmresp AS responsible,
        CASE
            WHEN mitmas.mmmabu = 1 THEN '1=Manufactured'::text
            WHEN mitmas.mmmabu = 2 THEN '2=Purchased'::text
            ELSE NULL::text
        END AS manufpurchcode,
    mitmas.mmunms AS basicunitofmeasure,
    mitmas.mmprgp AS procurementgroup,
    mitmas.mmgrti AS distrgrouptech,
    mitmas.mmgrwe AS grossweight,
    mitmas.mmnewe AS netweight,
    mitmas.mmvol3 AS volume,
    mitmas.mmfcu1 AS freecapacityunits,
    mitmas.mmvtcp AS vatcodepurchase,
    mitmas.mmvtcs AS vatcodesales,
    mitmas.mmcfi1 AS userdef1,
    mitmas.mmcfi2 AS userdef2,
    mitmas.mmcfi3 AS userdef3,
    mitmas.mmcfi4 AS userdef4,
    mitmas.mmcfi5 AS userdef5,
    mitmas.mmdim1 AS measurement1,
    mitmas.mmdim2 AS measurement2,
    mitmas.mmdim3 AS measurement3,
    mitmas.mmspe1 AS specification1,
    mitmas.mmspe2 AS specification2,
    mitmas.mmspe3 AS specification3,
    mitmas.mmspe4 AS specification4,
    mitmas.mmspe5 AS specification5,
    mitmas.mmpupr AS purchaseprice,
    mitmas.mmsapr AS salesprice,
    mitmas.mmcucd AS defaultpurchasecurrency,
    mitmas.mmcucs AS defaultsalescurrency,
    NULL::character varying(90) AS eancode,
    mitmas.mmgrp1 AS sg1,
    mitmas.mmgrp2 AS sg2,
    mitmas.mmhie3 AS sg3,
    mitmas.mmgrp4 AS sg4,
    mitmas.mmgrp5 AS sg5,
        CASE
            WHEN mitmas.mmcfi2 = 0::numeric THEN 1::numeric
            ELSE mitmas.mmcfi2
        END::character varying(108) AS bottleamount,
        CASE
            WHEN mitmas.mmunms::text = 'PC'::text THEN 1::numeric
            WHEN mitmas.mmunms::text = 'PCS'::text THEN 1::numeric
            ELSE mitmas.mmcfi2
        END::character varying(108) AS bottleamount2,
        CASE
            WHEN mitmas.mmitty::text <> '10'::text THEN '0'::character varying
            WHEN mitmas.mmcfi1 IS NULL THEN '0'::character varying
            WHEN mitmas.mmcfi1::text = ' '::text THEN '0'::character varying
            ELSE mitmas.mmcfi1
        END AS alc_procent,
    (mitmas.mmitty::text || '.'::text) || itty.cttx40::text AS groupinglevel1,
    (mitmas.mmitgr::text || '.'::text) || ct1.cttx40::text AS groupinglevel2,
    hi3.hitx40 AS groupinglevel3,
        CASE
            WHEN mitmas.mmgrp4::text = ANY (ARRAY['31'::character varying::text, '36'::character varying::text]) THEN '1.GLASS'::text
            WHEN mitmas.mmgrp4::text = ANY (ARRAY['32'::character varying::text, '37'::character varying::text]) THEN '3.PET'::text
            WHEN mitmas.mmgrp4::text = '33'::text THEN '2.CAN'::text
            WHEN mitmas.mmgrp4::text = '34'::text THEN '4.KEG'::text
            WHEN mitmas.mmgrp4::text = '35'::text THEN '5.TETRA'::text
            WHEN mitmas.mmgrp4::text = '38'::text THEN '6.FOOD'::text
            WHEN mitmas.mmgrp4::text = '41'::text THEN '7.PET-KEG'::text
            WHEN mitmas.mmgrp4::text = '43'::text THEN '8.JAR'::text
            WHEN mitmas.mmgrp4::text = '40'::text THEN '9.BARREL'::text
            WHEN mitmas.mmgrp4::text = '39'::text THEN '99.TANK'::text
            ELSE '99.OTHER'::text
        END::character varying(108) AS groupinglevel4,
    TRIM(BOTH FROM
        CASE
            WHEN (mitmas.mmitty::text = ANY (ARRAY['10'::character varying::text, '40'::character varying::text])) AND mitmas.mmunms::text = 'HL'::text THEN '100'::text
            WHEN mitmas.mmitty::text = '10'::text AND (mitmas.mmpdln::text = ANY (ARRAY['600'::character varying::text, '800'::character varying::text])) THEN to_char(mitmas.mmvol3, '90.999'::text)
            ELSE to_char(mitmas.mmvol3 /
            CASE
                WHEN mitmas.mmcfi2 = 0::numeric THEN 1::numeric
                ELSE mitmas.mmcfi2
            END, '90.999'::text)
        END) AS groupinglevel5,
        CASE
            WHEN mitmas.mmitno::text ~~ '2%'::text THEN sg3.sgtx15
            WHEN ct1.cttx40 IS NULL THEN 'OTHER'::character varying
            ELSE ct1.cttx40
        END::character varying(108) AS groupinglevel6,
    sg2.sgtx40 AS groupinglevel7,
    NULL::character varying(108) AS groupinglevel8,
        CASE
            WHEN mitmas.mmpdln::text = ANY (ARRAY['100'::character varying::text, '400'::character varying::text]) THEN ((sg5.sgtx40::text || ' '::text) || sg3.sgtx40::text)::character varying
            ELSE sg5.sgtx40
        END AS groupinglevel9,
    NULL::character varying(108) AS groupinglevel10,
    (mitmas.mmitgr::text || ' '::text) || ct1.cttx40::text AS groupinglevel11,
    (((mitmas.mmhie1::text || ' '::text) || hi1.hitx40::text))::character varying(108) AS groupinglevel12,
    mp1.mppopn AS groupinglevel13,
    mitbal.mbsldy::character varying(108) AS groupinglevel14,
    NULL::character varying(108) AS groupinglevel15,
    ct3.idsunm AS groupinglevel16,
    ' '::text AS groupinglevel17,
        CASE
            WHEN mitmas.mmunms::text = ANY (ARRAY['TUH'::character varying::text, 't'::character varying::text, 'T'::character varying::text, 'KPC'::character varying::text]) THEN '1000'::text
            ELSE '1'::text
        END::character varying(108) AS groupinglevel18,
        CASE
            WHEN mitmas.mmunms::text = 'PC'::text THEN 1::numeric
            WHEN mitmas.mmgrp4::text = '33'::text AND mitmas.mmgrp5::text = '82'::text THEN 1::numeric
            ELSE mitmas.mmcfi2
        END::character varying(108) AS groupinglevel19,
    mitmas.mmfre3 AS groupinglevel20,
    mitmas.mmdigi AS groupinglevel21,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text THEN mu1.mucofa
            WHEN mitmas.mmpdln::text = '700'::text AND mp2.mppopn::text = '7EDI'::text THEN mp2.mpseqn::numeric
            ELSE mitmas.mmcfi2
        END::character varying(108) AS groupinglevel22,
    NULL::character varying(108) AS groupinglevel23,
    mitbal.mbssqt::character varying(108) AS groupinglevel24,
        CASE
            WHEN mitmas.mmitno::text = ANY (ARRAY['2002490'::character varying::text, '2060234'::character varying::text]) THEN '2005000'::text
            WHEN mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = '1'::smallint THEN '2003000'::text
            WHEN mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = '2'::smallint THEN '2005000'::text
            WHEN mitmas.mmitty::text = ANY (ARRAY['20'::character varying::text, '30'::character varying::text]) THEN '2001000'::text
            WHEN mitmas.mmgrp2::text = ANY (ARRAY['O1'::character varying::text, 'O2'::character varying::text]) THEN '2001000'::text
            WHEN mitmas.mmitty::text = '40'::text THEN '2004000'::text
            WHEN mitmas.mmitty::text = '50'::text THEN '2009020'::text
            WHEN mitmas.mmitty::text = '90'::text AND (mitmas.mmgrp2::text = ANY (ARRAY['T2'::character varying::text, 'T3'::character varying::text])) THEN '2010010'::text
            WHEN mitmas.mmitty::text = '90'::text AND mitmas.mmgrp2::text = 'T5'::text THEN '2010020'::text
            WHEN mitmas.mmitty::text = '90'::text AND mitmas.mmgrp2::text = 'T4'::text THEN '1102010'::text
            WHEN mitmas.mmitty::text = '90'::text AND mitmas.mmgrp2::text = 'T1'::text THEN '1101010'::text
            ELSE '2009090'::text
        END AS groupinglevel25,
        CASE
            WHEN unnamed_subquery.m9vamt = '0'::smallint THEN '0 - zero cost'::text
            WHEN unnamed_subquery.m9vamt = '1'::smallint THEN '1 - standard cost'::text
            WHEN unnamed_subquery.m9vamt = '2'::smallint THEN '2 - average cost'::text
            WHEN unnamed_subquery.m9vamt = '3'::smallint THEN '3 - dynamic (batch-based) cost'::text
            ELSE 'check inventory acc method'::text
        END AS groupinglevel26,
        CASE
            WHEN mitmas.mmfuds::text ~~ '%EX'::text OR mitmas.mmfuds::text ~~ '%EXP%'::text OR mitmas.mmfuds::text ~~ '%Azia'::text OR mitmas.mmfuds::text ~~ '%GB'::text OR mitmas.mmfuds::text ~~ '%RU'::text THEN 'EXPORT'::text
            WHEN mitmas.mmprod::text = '9900006'::text AND (mitmas.mmfuds::text ~~ '%EE'::text OR mitmas.mmfuds::text ~~ '%LV'::text OR mitmas.mmfuds::text ~~ 'ALEXAN%'::text OR mitmas.mmfuds::text ~~ 'KARKSI%'::text OR mitmas.mmfuds::text ~~ '%KALI%'::text) THEN 'GROUP'::text
            WHEN mitmas.mmacrf::text ~~ '303%'::text THEN 'EXPORT'::text
            ELSE 'DOMESTIC'::text
        END::character varying(108) AS groupinglevel27,
    ct4.cttx15 AS groupinglevel28,
        CASE
            WHEN mitmas.mmgrp4::text = '31'::text AND (mitmas.mmgrp5::text = ANY (ARRAY['46'::character varying::text, '49'::character varying::text, '50'::character varying::text, '72'::character varying::text, '73'::character varying::text, '74'::character varying::text, '76'::character varying::text])) THEN '1'::text
            WHEN mitmas.mmevgr::text >= '2A'::text AND mitmas.mmevgr::text <= '2E'::text THEN '1'::text
            WHEN mitmas.mmevgr::text = '2F'::text THEN '2'::text
            ELSE ' '::text
        END AS groupinglevel29,
        CASE
            WHEN mitmas.mmpdln::text = ANY (ARRAY['100'::character varying::text, '400'::character varying::text]) THEN sg3.sgtx40
            ELSE NULL::character varying
        END::character varying(108) AS groupinglevel30,
    NULL::character varying(108) AS groupinglevel31,
    NULL::character varying(108) AS groupinglevel32,
    NULL::character varying(108) AS groupinglevel33,
    NULL::character varying(108) AS groupinglevel34,
    NULL::character varying(108) AS groupinglevel35,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = 1 AND NULLIF(regexp_replace(mitmas.mmbuar::text, '\D'::text, ''::text, 'g'::text), ''::text)::numeric < 239::numeric AND (mitmas.mmgrp5::text < '72'::text OR mitmas.mmgrp5::text > '81'::text) THEN ((((hi3.hitx40::text || ' / '::text) ||
            CASE
                WHEN mitmas.mmcfi1::text <> ' '::text THEN mitmas.mmcfi1::text || '% / '::text
                ELSE NULL::text
            END) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = 1 AND NULLIF(regexp_replace(mitmas.mmbuar::text, '\D'::text, ''::text, 'g'::text), ''::text)::numeric < 239::numeric AND mitmas.mmgrp5::text >= '72'::text AND mitmas.mmgrp5::text <= '81'::text THEN ((((((hi3.hitx40::text || ' / '::text) ||
            CASE
                WHEN mitmas.mmcfi1::text <> ' '::text THEN mitmas.mmcfi1::text || '% / '::text
                ELSE NULL::text
            END) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text) || ''::text) || to_char(mitmas.mmvol3 /
            CASE
                WHEN mitmas.mmcfi2 = 0::numeric THEN 1::numeric
                ELSE mitmas.mmcfi2
            END, '0.999'::text)
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = 2 AND NULLIF(regexp_replace(mitmas.mmbuar::text, '\D'::text, ''::text, 'g'::text), ''::text)::numeric < 239::numeric AND (mitmas.mmgrp5::text < '72'::text OR mitmas.mmgrp5::text > '81'::text) THEN ((((((hi3.hitx40::text || ' / '::text) ||
            CASE
                WHEN mitmas.mmcfi1::text <> ' '::text THEN mitmas.mmcfi1::text || '% / '::text
                ELSE NULL::text
            END) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text) || ' / '::text) || 'OST'::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = 2 AND NULLIF(regexp_replace(mitmas.mmbuar::text, '\D'::text, ''::text, 'g'::text), ''::text)::numeric < 239::numeric AND mitmas.mmgrp5::text >= '72'::text AND mitmas.mmgrp5::text <= '81'::text THEN ((((((hi3.hitx40::text || ' / '::text) ||
            CASE
                WHEN mitmas.mmcfi1::text <> ' '::text THEN mitmas.mmcfi1::text || '% / '::text
                ELSE NULL::text
            END) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text) || ''::text) || to_char(mitmas.mmvol3 /
            CASE
                WHEN mitmas.mmcfi2 = 0::numeric THEN 1::numeric
                ELSE mitmas.mmcfi2
            END, '0.999'::text)
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = 1 AND NULLIF(regexp_replace(mitmas.mmbuar::text, '\D'::text, ''::text, 'g'::text), ''::text)::numeric >= 239::numeric AND (mitmas.mmgrp5::text < '72'::text OR mitmas.mmgrp5::text > '81'::text) THEN ((((((hi3.hitx40::text || ' / '::text) ||
            CASE
                WHEN mitmas.mmcfi1::text <> ' '::text THEN mitmas.mmcfi1::text || '% / '::text
                ELSE NULL::text
            END) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text) || ' / '::text) || ct4.cttx15::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = 1 AND NULLIF(regexp_replace(mitmas.mmbuar::text, '\D'::text, ''::text, 'g'::text), ''::text)::numeric >= 239::numeric AND mitmas.mmgrp5::text >= '72'::text AND mitmas.mmgrp5::text <= '81'::text THEN ((((((hi3.hitx40::text || ' / '::text) ||
            CASE
                WHEN mitmas.mmcfi1::text <> ' '::text THEN mitmas.mmcfi1::text || '% / '::text
                ELSE NULL::text
            END) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text) || ''::text) || to_char(mitmas.mmvol3 /
            CASE
                WHEN mitmas.mmcfi2 = 0::numeric THEN 1::numeric
                ELSE mitmas.mmcfi2
            END, '0.999'::text)
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = 2 AND NULLIF(regexp_replace(mitmas.mmbuar::text, '\D'::text, ''::text, 'g'::text), ''::text)::numeric >= 239::numeric AND (mitmas.mmgrp5::text < '72'::text OR mitmas.mmgrp5::text > '81'::text) THEN ((((((((hi3.hitx40::text || ' / '::text) ||
            CASE
                WHEN mitmas.mmcfi1::text <> ' '::text THEN mitmas.mmcfi1::text || '% / '::text
                ELSE NULL::text
            END) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text) || ' / '::text) || ct4.cttx15::text) || ' / '::text) || 'OST'::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = 2 AND NULLIF(regexp_replace(mitmas.mmbuar::text, '\D'::text, ''::text, 'g'::text), ''::text)::numeric >= 239::numeric AND mitmas.mmgrp5::text >= '72'::text AND mitmas.mmgrp5::text <= '81'::text THEN ((((((((((hi3.hitx40::text || ' / '::text) ||
            CASE
                WHEN mitmas.mmcfi1::text <> ' '::text THEN mitmas.mmcfi1::text || '% / '::text
                ELSE NULL::text
            END) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text) || ''::text) || to_char(mitmas.mmvol3 /
            CASE
                WHEN mitmas.mmcfi2 = 0::numeric THEN 1::numeric
                ELSE mitmas.mmcfi2
            END, '0.999'::text)) || ' / '::text) || ct4.cttx15::text) || ' / '::text) || 'OST'::text
            WHEN mitmas.mmpdln::text = '700'::text THEN mitmas.mmitds::text
            WHEN mitmas.mmitty::text = '40'::text THEN mitmas.mmitds::text
            ELSE 'ERROR'::text
        END AS uniqueitem,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND (mitmas.mmgrp5::text < '72'::text OR mitmas.mmgrp5::text > '81'::text) THEN (mitmas.mmhie3::text || mitmas.mmgrp4::text) || mitmas.mmgrp5::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmgrp5::text >= '72'::text AND mitmas.mmgrp5::text <= '81'::text THEN (((mitmas.mmhie3::text || mitmas.mmgrp4::text) || mitmas.mmgrp5::text) || '_'::text) || to_char(mitmas.mmvol3 /
            CASE
                WHEN mitmas.mmcfi2 = 0::numeric THEN 1::numeric
                ELSE mitmas.mmcfi2
            END, '0.999'::text)
            WHEN mitmas.mmpdln::text = '700'::text THEN mitmas.mmitno::text
            WHEN mitmas.mmitty::text = '40'::text THEN mitmas.mmitds::text
            ELSE 'ERROR'::text
        END AS uniqueitemcode,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND (mitmas.mmgrp5::text < '72'::text OR mitmas.mmgrp5::text > '81'::text) THEN (((hi3.hitx40::text || ' / '::text) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitty::text = '10'::text AND mitmas.mmgrp5::text >= '72'::text AND mitmas.mmgrp5::text <= '81'::text THEN (((((hi3.hitx40::text || ' / '::text) || sg4.sgtx40::text) || ' / '::text) || sg5.sgtx40::text) || ''::text) || to_char(mitmas.mmvol3 /
            CASE
                WHEN mitmas.mmcfi2 = 0::numeric THEN 1::numeric
                ELSE mitmas.mmcfi2
            END, '0.999'::text)
            WHEN mitmas.mmpdln::text = '700'::text THEN mitmas.mmitds::text
            WHEN mitmas.mmitty::text = '40'::text THEN mitmas.mmitds::text
            ELSE 'ERROR'::text
        END AS uniqueitemname,
        CASE
            WHEN mitmas.mmpdln::text = '600'::text THEN ct6.cttx40
            ELSE mitmas.mmbuar
        END AS businessarea,
        CASE
            WHEN mitmas.mmitno::text ~~ '1%'::text THEN mitmas.mmitno
            WHEN mitmas.mmitno::text ~~ '3%'::text THEN mitmas.mmitno
            WHEN mitmas.mmgrti::text = ' '::text THEN mitmas.mmitno
            ELSE mitmas.mmgrti
        END::character varying(108) AS budgetitem,
        CASE
            WHEN mitmas.mmitno::text ~~ '1%'::text THEN mitmas.mmitds
            WHEN mitmas.mmitno::text ~~ '3%'::text THEN mitmas.mmitds
            WHEN mitmas.mmgrti::text = ' '::text THEN mitmas.mmitds
            ELSE unnamed_subquery_1.itds
        END::character varying(108) AS budgetname,
    mitmas.mmgrti AS parent_item,
    bg.budgetgroup::numeric AS budgetgroup,
    bg.budgetgroupname,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text <= '237'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text <> 'CLOSE'::text THEN '1'::text
            WHEN mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND (cugex1.f1a130::text = ANY (ARRAY['1'::character varying::text, '4'::character varying::text])) THEN '1'::text
            ELSE '0'::text
        END AS io_dom,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text = '238'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 THEN '1'::text
            ELSE '0'::text
        END AS io_allh,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text = '239'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text <> 'CLOSE'::text THEN '1'::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text = '240'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text <> 'CLOSE'::text THEN '1'::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text <= '237'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text = 'E'::text THEN '1'::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text <= '237'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text <> 'CLOSE'::text AND length(mitmas.mmgrts::text) = 5 THEN '1'::text
            WHEN mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND (cugex1.f1a130::text = ANY (ARRAY['1'::character varying::text, '4'::character varying::text])) THEN '1'::text
            ELSE '0'::text
        END AS io_travel,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text = '240'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text <> 'CLOSE'::text THEN '1'::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text = 'E'::text THEN '1'::text
            WHEN mitmas.mmstat::integer < 50 AND (mitmas.mmitds::text ~~ '%EX%'::text OR mitmas.mmitds::text ~~ '%RU'::text OR mitmas.mmitds::text ~~ '%Az%'::text OR mitmas.mmitds::text ~~ '%AZ%'::text OR mitmas.mmitds::text ~~ '%GB'::text OR mitmas.mmitds::text ~~ '%CON'::text OR mitmas.mmitds::text ~~ '%SOM'::text OR mitmas.mmitds::text ~~ '%DE'::text OR mitmas.mmitds::text ~~ '%LSV'::text OR mitmas.mmitds::text ~~ '%PAR'::text OR mitmas.mmitds::text ~~ '%EN'::text OR mitmas.mmitds::text ~~ '%PL'::text OR mitmas.mmitds::text ~~ '%Exp'::text OR mitmas.mmitno::text = '6100392'::text) THEN '1'::text
            WHEN mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND ((cugex1.f1a130::text = ANY (ARRAY['3'::character varying::text, '5'::character varying::text])) OR (mitmas.mmitno::text = ANY (ARRAY['7160762'::character varying::text, '7122022'::character varying::text, '7122412'::character varying::text, '7121325'::character varying::text, '7110252'::character varying::text, '7110245'::character varying::text, '7132001'::character varying::text, '7132003'::character varying::text, '7132004'::character varying::text, '7132005'::character varying::text, '7111726'::character varying::text, '7113224'::character varying::text, '7110424'::character varying::text]))) THEN '1'::text
            WHEN mitmas.mmacrf::text ~~ '303%'::text AND mitmas.mmstat::integer < 50 THEN '1'::text
            ELSE '0'::text
        END AS io_exp,
        CASE
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text > '240'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text <> 'CLOSE'::text THEN '1'::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text <= '240'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text = 'E'::text THEN '1'::text
            WHEN mitmas.mmpdln::text = '200'::text AND mitmas.mmbuar::text <= '240'::text AND mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND mitmas.mmgrts::text <> 'CLOSE'::text AND length(mitmas.mmgrts::text) = 5 THEN '1'::text
            WHEN mitmas.mmstat::integer < 50 AND (mitmas.mmitds::text ~~ '%EE'::text OR mitmas.mmitds::text ~~ '%LV'::text OR mitmas.mmitds::text ~~ '%LIDA'::text OR mitmas.mmitds::text ~~ '%BY'::text) THEN '1'::text
            WHEN mitmas.mmitno::text = mitmas.mmgrti::text AND mitmas.mmstat::integer < 50 AND cugex1.f1a130::text = '2'::text THEN '1'::text
            ELSE '0'::text
        END AS io_grp,
        CASE
            WHEN mitmas.mmbuar::text ~~ '24%'::text THEN ' '::text
            WHEN mitmas.mmgrp1::text = '01'::text AND mitmas.mmpdln::text = '400'::text AND replace(
            CASE
                WHEN ct5.ctstky::text = ' '::text THEN '0'::character varying
                ELSE ct5.cttx40
            END::text, '.'::text, ','::text) <= '2.7'::text THEN 'beer_0'::text
            WHEN mitmas.mmgrp1::text = '01'::text THEN 'beer'::text
            WHEN (mitmas.mmgrp1::text = ANY (ARRAY['02'::character varying::text, '03'::character varying::text, '04'::character varying::text, '05'::character varying::text])) AND mitmas.mmpdln::text = '400'::text AND replace(
            CASE
                WHEN ct5.ctstky::text = ' '::text THEN '0'::character varying
                ELSE ct5.cttx40
            END::text, '.'::text, ','::text) <= '2.7'::text THEN 'ferm_0'::text
            WHEN (mitmas.mmgrp1::text = ANY (ARRAY['02'::character varying::text, '03'::character varying::text, '04'::character varying::text, '05'::character varying::text])) AND mitmas.mmitgr::text <> '2120'::text AND replace(
            CASE
                WHEN ct5.ctstky::text = ' '::text THEN '0'::character varying
                ELSE ct5.cttx40
            END::text, '.'::text, ','::text) <= '6.0'::text THEN 'ferm_till6'::text
            WHEN (mitmas.mmgrp1::text = ANY (ARRAY['02'::character varying::text, '03'::character varying::text, '04'::character varying::text, '05'::character varying::text])) AND mitmas.mmitgr::text <> '2120'::text AND replace(
            CASE
                WHEN ct5.ctstky::text = ' '::text THEN '0'::character varying
                ELSE ct5.cttx40
            END::text, '.'::text, ','::text) > '6.0'::text THEN 'ferm_over6'::text
            WHEN mitmas.mmitgr::text = '2120'::text THEN 'spirit'::text
            ELSE ' '::text
        END::character varying(10) AS excisegroup,
    mitmas.mmdigi AS alko,
    1::numeric(11,6) AS exchangeratetoeur,
        CASE
            WHEN mitmas.mmmabu = '1'::smallint AND mitmas.mmgrp4::text = '31'::text THEN '1.GLASS'::text
            WHEN mitmas.mmmabu = '1'::smallint AND mitmas.mmgrp4::text = '32'::text THEN '4.PET'::text
            WHEN mitmas.mmmabu = '1'::smallint AND mitmas.mmgrp4::text = '33'::text THEN '3.CAN'::text
            WHEN mitmas.mmmabu = '1'::smallint AND mitmas.mmgrp4::text = '34'::text THEN '2.KEG'::text
            WHEN mitmas.mmmabu = '1'::smallint AND mitmas.mmgrp4::text = '35'::text THEN '5.TETRA'::text
            WHEN mitmas.mmmabu = '2'::smallint THEN '7.PURCHASE'::text
            ELSE NULL::text
        END AS line1,
        CASE
            WHEN mitmas.mmmabu = '2'::smallint THEN (ct3.idcono || '-'::text) || ct3.idsunm::text
            ELSE (mpdwct.ppplgr::text || '-'::text) || mpdwct.ppplnm::text
        END AS line2,
    a.f3tx40 AS item_usage_region,
    b.f3tx40 AS prod_class,
    mitmas.mmitrf AS launch_period,
    mitbal.mbsttx AS ending_note,
        CASE
            WHEN mitmas.mmgrp2::text = '02'::text THEN 'PRIVATE LABEL'::character varying
            ELSE hi2.hitx40
        END AS brand2,
    hi2.hitx40 AS brand2_incl_pl,
    (mitbal.mbvtcp || '_'::text) || ct7.cttx40::text AS vat_purch,
    (mitbal.mbvtcp || '_'::text) || ct8.cttx40::text AS vat_purch_fi,
    ' '::text AS alco_group
   FROM mvxjdta.mitmas
     LEFT JOIN mvxjdta.mitsch sg1 ON sg1.sgcono = mitmas.mmcono AND sg1.sgglvl = 1 AND sg1.sgsgp0::text = mitmas.mmgrp1::text
     LEFT JOIN mvxjdta.mitsch sg2 ON sg2.sgcono = mitmas.mmcono AND sg2.sgglvl = 2 AND sg2.sgsgp0::text = mitmas.mmgrp2::text
     LEFT JOIN mvxjdta.mitsch sg3 ON sg3.sgcono = mitmas.mmcono AND sg3.sgglvl = 3 AND sg3.sgsgp0::text = mitmas.mmgrp3::text
     LEFT JOIN mvxjdta.mitsch sg4 ON sg4.sgcono = mitmas.mmcono AND sg4.sgglvl = 4 AND sg4.sgsgp0::text = mitmas.mmgrp4::text
     LEFT JOIN mvxjdta.mitsch sg5 ON sg5.sgcono = mitmas.mmcono AND sg5.sgglvl = 5 AND sg5.sgsgp0::text = mitmas.mmgrp5::text
     LEFT JOIN mvxjdta.mithry hi1 ON hi1.hicono = mitmas.mmcono AND hi1.hihlvl = 1 AND hi1.hihie0::text = mitmas.mmhie1::text
     LEFT JOIN mvxjdta.mithry hi2 ON hi2.hicono = mitmas.mmcono AND hi2.hihlvl = 2 AND hi2.hihie0::text = mitmas.mmhie2::text
     LEFT JOIN mvxjdta.mithry hi3 ON hi3.hicono = mitmas.mmcono AND hi3.hihlvl = 3 AND hi3.hihie0::text = mitmas.mmhie3::text
     LEFT JOIN mvxjdta.csytab ct1 ON ct1.ctcono = mitmas.mmcono AND ct1.ctstco::text = 'ITGR'::text AND ct1.ctstky::text = mitmas.mmitgr::text
     LEFT JOIN mvxjdta.csytab ct2 ON ct2.ctcono = mitmas.mmcono AND ct2.ctstco::text = 'ITCL'::text AND ct2.ctstky::text = mitmas.mmitcl::text
     LEFT JOIN mvxjdta.csytab ct4 ON ct4.ctcono = mitmas.mmcono AND ct4.ctstco::text = 'GRTS'::text AND ct4.ctstky::text = mitmas.mmgrts::text
     LEFT JOIN mvxjdta.cidmas ct3 ON ct3.idcono = mitmas.mmcono AND ct3.idsuno::text = mitmas.mmprod::text
     LEFT JOIN mvxjdta.csytab ct5 ON ct5.ctcono = mitmas.mmcono AND ct5.ctstco::text = 'CFI1'::text AND ct5.ctstky::text = mitmas.mmcfi1::text
     LEFT JOIN mvxjdta.csytab ct6 ON ct6.ctcono = mitmas.mmcono AND ct6.ctstco::text = 'BUAR'::text AND ct6.ctstky::text = mitmas.mmbuar::text
     LEFT JOIN mvxjdta.csytab itty ON itty.ctcono = mitmas.mmcono AND itty.ctstco::text = 'ITTY'::text AND itty.ctstky::text = mitmas.mmitty::text
     LEFT JOIN ( SELECT mitfac.m9cono,
            min(mitfac.m9faci::text) AS m9faci,
            mitfac.m9itno,
            min(mitfac.m9rewh::text) AS m9rewh,
            min(mitfac.m9vamt) AS m9vamt,
            min(mitfac.m9wcln::text) AS m9wcln
           FROM mvxjdta.mitfac
          WHERE mitfac.m9cono = 100
          GROUP BY mitfac.m9cono, mitfac.m9itno) unnamed_subquery ON unnamed_subquery.m9cono = mitmas.mmcono AND unnamed_subquery.m9itno::text = mitmas.mmitno::text
     LEFT JOIN mvxjdta.mitbal ON mitbal.mbcono = mitmas.mmcono AND mitbal.mbitno::text = mitmas.mmitno::text AND mitbal.mbwhlo::text = unnamed_subquery.m9rewh
     LEFT JOIN ( SELECT mitpop.mpcono,
            mitpop.mpitno,
            max(mitpop.mppopn::text) AS mppopn
           FROM mvxjdta.mitpop
          WHERE mitpop.mpalwt = '2'::smallint
          GROUP BY mitpop.mpcono, mitpop.mpitno) mp1 ON mp1.mpcono = mitmas.mmcono AND mp1.mpitno::text = mitmas.mmitno::text
     LEFT JOIN mvxjdta.mitaun mu1 ON mu1.mucono = mitmas.mmcono AND mu1.muitno::text = mitmas.mmitno::text AND (mu1.mualun::text = ANY (ARRAY['PAL'::character varying::text, 'XML'::character varying::text]))
     LEFT JOIN mvxjdta.mitpop mp2 ON mitmas.mmcono = mp2.mpcono AND mitmas.mmitno::text = mp2.mpitno::text AND mp2.mppopn::text = '7EDI'::text
     LEFT JOIN bousr.og_b_product_budgetgroup bg ON mitmas.mmcono = bg.cono AND mitmas.mmitno::text = bg.itemcode::text
     LEFT JOIN mvxjdta.mpdwct ON mitmas.mmcono = mpdwct.ppcono AND unnamed_subquery.m9wcln = mpdwct.ppplgr::text AND unnamed_subquery.m9faci = mpdwct.ppfaci::text
     LEFT JOIN mvxjdta.cugex1 ON mitmas.mmcono = cugex1.f1cono AND mitmas.mmitno::text = cugex1.f1pk01::text AND cugex1.f1file::text = 'MITMAS'::text
     LEFT JOIN mvxjdta.cugevm a ON cugex1.f1cono = a.f3cono AND cugex1.f1a130::text = a.f3al30::text AND a.f3cono = 100 AND a.f3file::text = 'MITMAS'::text AND a.f3fldi::text = 'F1A130'::text
     LEFT JOIN mvxjdta.cugevm b ON cugex1.f1cono = b.f3cono AND cugex1.f1a230::text = b.f3al30::text AND b.f3cono = 100 AND b.f3file::text = 'MITMAS'::text AND b.f3fldi::text = 'F1A230'::text
     LEFT JOIN ( SELECT mitmas_1.mmitno AS itno,
            mitmas_1.mmitds AS itds
           FROM mvxjdta.mitmas mitmas_1) unnamed_subquery_1 ON mitmas.mmgrti::text = unnamed_subquery_1.itno::text
     LEFT JOIN mvxjdta.csytab ct7 ON ct7.ctcono = mitmas.mmcono AND ct7.ctstco::text = 'VTCD'::text AND ct7.ctstky::text = mitbal.mbvtcp::character varying::text AND ct7.ctdivi::text = ' '::text
     LEFT JOIN mvxjdta.csytab ct8 ON ct8.ctcono = mitmas.mmcono AND ct8.ctstco::text = 'VTCD'::text AND ct8.ctstky::text = mitbal.mbvtcp::character varying::text AND ct8.ctdivi::text = '100'::text
  WHERE mitmas.mmcono = 100 AND (mitmas.mmitty::text = ANY (ARRAY['10'::character varying::text, '40'::character varying::text])) AND mitmas.mmpdln::text <> '800'::text
UNION
 SELECT mitmas.mmcono AS companycode,
    mitmas.mmpdln AS division,
    mitmas.mmitno AS itemcode,
    mitmas.mmitds AS itemname,
    mitmas.mmfuds AS itemname2,
    mitmas.mmitty AS itemtype,
    mitmas.mmitgr AS itemgroup,
    mitmas.mmitcl AS itemclass,
    mitmas.mmstat AS itemstatus,
    mitmas.mmresp AS responsible,
        CASE
            WHEN mitmas.mmmabu = 1 THEN '1=Manufactured'::text
            WHEN mitmas.mmmabu = 2 THEN '2=Purchased'::text
            ELSE NULL::text
        END AS manufpurchcode,
    mitmas.mmunms AS basicunitofmeasure,
    mitmas.mmprgp AS procurementgroup,
    mitmas.mmgrti AS distrgrouptech,
    mitmas.mmgrwe AS grossweight,
    mitmas.mmnewe AS netweight,
    mitmas.mmvol3 AS volume,
    mitmas.mmfcu1 AS freecapacityunits,
    mitmas.mmvtcp AS vatcodepurchase,
    mitmas.mmvtcs AS vatcodesales,
    mitmas.mmcfi1 AS userdef1,
    mitmas.mmcfi2 AS userdef2,
    mitmas.mmcfi3 AS userdef3,
    mitmas.mmcfi4 AS userdef4,
    mitmas.mmcfi5 AS userdef5,
    mitmas.mmdim1 AS measurement1,
    mitmas.mmdim2 AS measurement2,
    mitmas.mmdim3 AS measurement3,
    mitmas.mmspe1 AS specification1,
    mitmas.mmspe2 AS specification2,
    mitmas.mmspe1 AS specification3,
    mitmas.mmspe1 AS specification4,
    mitmas.mmspe1 AS specification5,
    mitmas.mmpupr AS purchaseprice,
    mitmas.mmsapr AS salesprice,
    mitmas.mmcucd AS defaultpurchasecurrency,
    mitmas.mmcucs AS defaultsalescurrency,
    NULL::character varying(90) AS eancode,
    mitmas.mmgrp1 AS sg1,
    mitmas.mmgrp2 AS sg2,
    mitmas.mmgrp3 AS sg3,
    mitmas.mmgrp4 AS sg4,
    mitmas.mmgrp5 AS sg5,
    NULL::character varying AS bottleamount,
    NULL::character varying AS bottleamount2,
    '0'::character varying AS alc_procent,
        CASE
            WHEN mitmas.mmitty::text = '10'::text THEN '01.FINISHED PRODUCTS'::text
            WHEN mitmas.mmitty::text = '20'::text THEN '02.RAW MATERIALS'::text
            WHEN mitmas.mmitty::text = '85'::text THEN '08.WASHING MATERIALS'::text
            WHEN mitmas.mmitty::text = '30'::text THEN '03.PACKAGING MATERIALS'::text
            WHEN mitmas.mmitty::text = '40'::text THEN '04.SEMI-FINISHED PRODUCTS'::text
            WHEN mitmas.mmitty::text = '50'::text THEN '05.ADV STUFF'::text
            WHEN mitmas.mmitty::text = '90'::text THEN '09.EMPTIES'::text
            WHEN mitmas.mmitty::text = '60'::text THEN '06.RENTAL'::text
            ELSE '99.OTHER'::text
        END::character varying(108) AS groupinglevel1,
    (mitmas.mmgrp2::text || ' '::text) || sg2.sgtx15::text AS groupinglevel2,
    (mitmas.mmgrp3::text || ' '::text) || sg3.sgtx15::text AS groupinglevel3,
    NULL::character varying(108) AS groupinglevel4,
    NULL::character varying(108) AS groupinglevel5,
    (mitmas.mmitgr::text || ' '::text) || ct1.cttx40::text AS groupinglevel6,
    NULL::character varying(108) AS groupinglevel7,
        CASE
            WHEN mitmas.mmunms::text = ANY (ARRAY['TUH'::character varying::text, 't'::character varying::text, 'T'::character varying::text, 'KPC'::character varying::text]) THEN '1000'::text
            ELSE '1'::text
        END::character varying(108) AS groupinglevel8,
    NULL::character varying(108) AS groupinglevel9,
    NULL::character varying(108) AS groupinglevel10,
    (mitmas.mmitgr::text || ' '::text) || ct1.cttx40::text AS groupinglevel11,
    (((mitmas.mmitcl::text || ' '::text) || ct2.cttx40::text))::character varying(108) AS groupinglevel12,
    NULL::character varying(108) AS groupinglevel13,
    mitbal.mbsldy::character varying(108) AS groupinglevel14,
        CASE
            WHEN mitmas.mmitty::text = '20'::text THEN (mitmas.mmgrp4::text || ' '::text) || sg4.sgtx15::text
            ELSE '  '::text
        END AS groupinglevel15,
    cidmas.idsunm AS groupinglevel16,
    ((cidmas.idsunm::text || ' ('::text) || cidmas.idsuno::text) || ')'::text AS groupinglevel17,
        CASE
            WHEN mitmas.mmunms::text = ANY (ARRAY['TUH'::character varying::text, 't'::character varying::text, 'T'::character varying::text, 'KPC'::character varying::text]) THEN '1000'::text
            ELSE '1'::text
        END::character varying(108) AS groupinglevel18,
    NULL::character varying AS groupinglevel19,
    mitmas.mmfre3 AS groupinglevel20,
    NULL::character varying(108) AS groupinglevel21,
    mu1.mucofa::character varying(108) AS groupinglevel22,
    NULL::character varying(108) AS groupinglevel23,
    mitbal.mbssqt::character varying(108) AS groupinglevel24,
        CASE
            WHEN mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = '1'::smallint THEN '2003000'::text
            WHEN mitmas.mmitty::text = '10'::text AND mitmas.mmmabu = '2'::smallint THEN '2005000'::text
            WHEN mitmas.mmitty::text = ANY (ARRAY['20'::character varying::text, '30'::character varying::text]) THEN '2001000'::text
            WHEN mitmas.mmgrp2::text = ANY (ARRAY['O1'::character varying::text, 'O2'::character varying::text]) THEN '2001000'::text
            WHEN mitmas.mmitty::text = '40'::text THEN '2004000'::text
            WHEN mitmas.mmitty::text = '50'::text THEN '2009020'::text
            WHEN mitmas.mmitty::text = '90'::text AND (mitmas.mmgrp2::text = ANY (ARRAY['T2'::character varying::text, 'T3'::character varying::text])) THEN '2010010'::text
            WHEN mitmas.mmitty::text = '90'::text AND mitmas.mmgrp2::text = 'T5'::text THEN '2010020'::text
            WHEN mitmas.mmitty::text = '90'::text AND mitmas.mmgrp2::text = 'T4'::text THEN '1102010'::text
            WHEN mitmas.mmitty::text = '90'::text AND mitmas.mmgrp2::text = 'T1'::text THEN '1101010'::text
            ELSE '2009090'::text
        END AS groupinglevel25,
        CASE
            WHEN unnamed_subquery.m9vamt = '0'::smallint THEN '0 - zero cost'::text
            WHEN unnamed_subquery.m9vamt = '1'::smallint THEN '1 - standard cost'::text
            WHEN unnamed_subquery.m9vamt = '2'::smallint THEN '2 - average cost'::text
            WHEN unnamed_subquery.m9vamt = '3'::smallint THEN '3 - dynamic (batch-based) cost'::text
            ELSE 'check inventory acc method'::text
        END AS groupinglevel26,
    ' '::character varying AS groupinglevel27,
    NULL::character varying(108) AS groupinglevel28,
    NULL::character varying(108) AS groupinglevel29,
    NULL::character varying(108) AS groupinglevel30,
    NULL::character varying(108) AS groupinglevel31,
    NULL::character varying(108) AS groupinglevel32,
    NULL::character varying(108) AS groupinglevel33,
    NULL::character varying(108) AS groupinglevel34,
    NULL::character varying(108) AS groupinglevel35,
    mitmas.mmitds AS uniqueitem,
    mitmas.mmitno AS uniqueitemcode,
    mitmas.mmitds AS uniqueitemname,
    mitmas.mmbuar AS businessarea,
    mitmas.mmgrts AS budgetitem,
    mitmas.mmitds AS budgetname,
    mitmas.mmgrti AS parent_item,
    9999 AS budgetgroup,
    'MATERIAL'::text AS budgetgroupname,
    '0'::text AS io_dom,
    '0'::text AS io_allh,
    '0'::text AS io_travel,
    '0'::text AS io_exp,
    '0'::text AS io_grp,
    ' '::character varying AS excisegroup,
    ' '::character varying AS alko,
    bousr.get_currency_rate_2(mitmas.mmcucd, mitbal.mbmpcd, '400'::character varying)::numeric(11,6) AS exchangeratetoeur,
    ' '::text AS line1,
        CASE
            WHEN mitmas.mmmabu = '2'::smallint THEN (cidmas.idsuno::text || '-'::text) || cidmas.idsunm::text
            ELSE ' '::text
        END AS line2,
    NULL::character varying AS item_usage_region,
    NULL::character varying AS prod_class,
    NULL::character varying AS launch_period,
    NULL::character varying AS ending_note,
    NULL::character varying AS brand2,
    NULL::character varying AS brand2_incl_pl,
    (mitbal.mbvtcp || '_'::text) || ct7.cttx40::text AS vat_purch,
    (mitbal.mbvtcp || '_'::text) || ct8.cttx40::text AS vat_purch_fi,
    ' '::text AS alco_group
   FROM mvxjdta.mitmas
     LEFT JOIN mvxjdta.mitsch sg1 ON sg1.sgcono = mitmas.mmcono AND sg1.sgglvl = 1 AND sg1.sgsgp0::text = mitmas.mmgrp1::text
     LEFT JOIN mvxjdta.mitsch sg2 ON sg2.sgcono = mitmas.mmcono AND sg2.sgglvl = 2 AND sg2.sgsgp0::text = mitmas.mmgrp2::text
     LEFT JOIN mvxjdta.mitsch sg3 ON sg3.sgcono = mitmas.mmcono AND sg3.sgglvl = 3 AND sg3.sgsgp0::text = mitmas.mmgrp3::text
     LEFT JOIN mvxjdta.mitsch sg4 ON sg4.sgcono = mitmas.mmcono AND sg4.sgglvl = 4 AND sg4.sgsgp0::text = mitmas.mmgrp4::text
     LEFT JOIN mvxjdta.mitsch sg5 ON sg5.sgcono = mitmas.mmcono AND sg5.sgglvl = 5 AND sg5.sgsgp0::text = mitmas.mmgrp5::text
     LEFT JOIN mvxjdta.csytab ct1 ON ct1.ctcono = mitmas.mmcono AND ct1.ctstco::text = 'ITGR'::text AND ct1.ctstky::text = mitmas.mmitgr::text
     LEFT JOIN mvxjdta.csytab ct2 ON ct2.ctcono = mitmas.mmcono AND ct2.ctstco::text = 'ITCL'::text AND ct2.ctstky::text = mitmas.mmitcl::text
     LEFT JOIN ( SELECT mitfac.m9cono,
            min(mitfac.m9faci::text) AS m9faci,
            mitfac.m9itno,
            min(mitfac.m9rewh::text) AS m9rewh,
            min(mitfac.m9vamt) AS m9vamt
           FROM mvxjdta.mitfac
          WHERE mitfac.m9cono = 100
          GROUP BY mitfac.m9cono, mitfac.m9itno) unnamed_subquery ON unnamed_subquery.m9cono = mitmas.mmcono AND unnamed_subquery.m9itno::text = mitmas.mmitno::text
     LEFT JOIN mvxjdta.mitbal ON mitbal.mbcono = mitmas.mmcono AND mitbal.mbdivi::text = unnamed_subquery.m9faci AND mitbal.mbitno::text = mitmas.mmitno::text AND mitbal.mbwhlo::text = unnamed_subquery.m9rewh
     LEFT JOIN mvxjdta.cidmas ON cidmas.idcono = mitmas.mmcono AND cidmas.idsuno::text = mitbal.mbsuno::text
     LEFT JOIN mvxjdta.mitaun mu1 ON mu1.mucono = mitmas.mmcono AND mu1.muitno::text = mitmas.mmitno::text AND (mu1.mualun::text = ANY (ARRAY['PAL'::character varying::text, 'XML'::character varying::text]))
     LEFT JOIN mvxjdta.csytab ct7 ON ct7.ctcono = mitmas.mmcono AND ct7.ctstco::text = 'VTCD'::text AND ct7.ctstky::text = mitbal.mbvtcp::character varying::text AND ct7.ctdivi::text = ' '::text
     LEFT JOIN mvxjdta.csytab ct8 ON ct8.ctcono = mitmas.mmcono AND ct8.ctstco::text = 'VTCD'::text AND ct8.ctstky::text = mitbal.mbvtcp::character varying::text AND ct8.ctdivi::text = '100'::text
  WHERE mitmas.mmcono = 100 AND mitmas.mmpdln::text <> '800'::text AND (mitmas.mmitty::text <> ALL (ARRAY['10'::character varying::text, '40'::character varying::text]));
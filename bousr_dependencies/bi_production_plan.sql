 SELECT mitfac.m9faci AS division,
    unnamed_subquery.work_center AS workcenter,
    unnamed_subquery.itemtype,
    unnamed_subquery.itemcode,
    unnamed_subquery.period,
    sum(unnamed_subquery.motrqt_vol) AS liters
   FROM (( SELECT mitplo.mocono AS cono,
            mmoplp.rowhlo AS whlo,
            mmoplp.rowcln AS work_center,
            mitplo.moitno AS itemcode,
            mitmas.mmitty AS itemtype,
            mitplo.mopldt AS transactiondate,
            to_char((to_date(((mitplo.mopldt)::character varying)::text, 'YYYYMMDD'::text))::timestamp with time zone, 'YYYYMM'::text) AS period,
            mitplo.moorca AS order_category,
            mitplo.moridn AS ordernumber,
            mitplo.motrqt AS qty_bum,
            ((mitplo.motrqt * mitmas.mmvol3))::numeric(17,6) AS motrqt_vol
           FROM ((mvxjdta.mitplo
             JOIN mvxjdta.mmoplp ON (((mitplo.mocono = mmoplp.rocono) AND ((mitplo.moridn)::text = ((mmoplp.roplpn)::character varying)::text) AND ((mitplo.moitno)::text = (mmoplp.roprno)::text))))
             JOIN mvxjdta.mitmas ON (((mitplo.mocono = mitmas.mmcono) AND ((mitplo.moitno)::text = (mitmas.mmitno)::text))))
          WHERE ((mitplo.mocono = 100) AND ((mmoplp.rofaci)::text <> '800'::text) AND ((mitplo.moorca)::text = '100'::text) AND ((mitmas.mmitty)::text = ANY (ARRAY[('10'::character varying)::text, ('40'::character varying)::text])) AND (mitmas.mmmabu = '1'::smallint))
        UNION ALL
         SELECT mitplo.mocono AS cono,
            mwohed.vhwhlo AS whlo,
            mwohed.vhwcln AS work_center,
            mitplo.moitno AS itemcode,
            mitmas.mmitty AS itemtype,
            mitplo.mopldt AS transactiondate,
            to_char((to_date(((mitplo.mopldt)::character varying)::text, 'YYYYMMDD'::text))::timestamp with time zone, 'YYYYMM'::text) AS period,
            mitplo.moorca AS order_category,
            mitplo.moridn AS ordernumber,
            mwohed.vhorqt AS qty_bum,
            ((mwohed.vhorqt * mitmas.mmvol3))::numeric(17,6) AS motrqt_vol
           FROM ((mvxjdta.mitplo
             JOIN mvxjdta.mwohed ON (((mitplo.mocono = mwohed.vhcono) AND ((mitplo.moridn)::text = (mwohed.vhmfno)::text) AND ((mitplo.moitno)::text = (mwohed.vhprno)::text))))
             JOIN mvxjdta.mitmas ON (((mitplo.mocono = mitmas.mmcono) AND ((mitplo.moitno)::text = (mitmas.mmitno)::text))))
          WHERE ((mitplo.mocono = 100) AND ((mwohed.vhfaci)::text <> '800'::text) AND ((mitplo.moorca)::text = '101'::text) AND ((mitmas.mmitty)::text = ANY (ARRAY[('10'::character varying)::text, ('40'::character varying)::text])) AND (mitmas.mmmabu = '1'::smallint))) unnamed_subquery
     RIGHT JOIN mvxjdta.mitfac ON (((unnamed_subquery.cono = mitfac.m9cono) AND ((unnamed_subquery.whlo)::text = (mitfac.m9rewh)::text) AND ((mitfac.m9itno)::text = (unnamed_subquery.itemcode)::text))))
  WHERE (unnamed_subquery.transactiondate > (to_char((now() - '31 days'::interval), 'YYYYMMDD'::text))::integer)
  GROUP BY mitfac.m9faci, unnamed_subquery.work_center, unnamed_subquery.itemtype, unnamed_subquery.itemcode, unnamed_subquery.period;
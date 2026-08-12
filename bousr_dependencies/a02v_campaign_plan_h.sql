 SELECT ph.a02_plan_id AS plan_id,
    ph.a02_plan_type AS plan_type,
    ph.a02_opt_client AS opt_client,
    ph.a02_opt_type AS opt_type,
        CASE
            WHEN ((ph.a02_opt_type)::text = ANY (ARRAY[('M'::character varying)::text, ('K'::character varying)::text])) THEN ((((cust.cust_id)::text || ' '::text) || (cust.cust_name)::text))::character varying
            ELSE ph.a02_opt_client
        END AS client_name,
    cust.sm,
    ph.a02_add_user AS add_user,
    ph.a02_add_date AS add_date,
    ph.a02_plan_date AS plan_date,
    ph.a02_status AS status,
    ph.a02_upd_user AS upd_user,
    ph.a02_upd_date AS upd_date,
    ph.a02_customer_id AS customer_id,
    ph.a02_master_id AS master_id,
    ph.a02_comment AS comment1,
    pd.confirmed AS stat_confirmed,
    pd.no_confirmed AS stat_no_confirmed,
    pd.confirmed_proc AS stat_confirmed_proc,
    pd.planned_proc AS stat_planned_proc,
    pd.going_proc AS stat_going_proc,
    pd.end_proc AS stat_end_proc,
    pd.campaign_types,
    pd.first_supply_begin,
    pd.first_campaign_begin,
    pd.last_campaign_end,
    pd.planned_prod_count
   FROM ((ve.a02_campaign_plan_h ph
     JOIN ve.a01v_customers cust ON (((cust.cust_id)::text = (ph.a02_customer_id)::text)))
     LEFT JOIN ( SELECT pd_1.a02_plan_id,
            count(
                CASE
                    WHEN ((pd_1.a02_status)::text = 'CONFIRMED'::text) THEN 1
                    ELSE NULL::integer
                END) AS confirmed,
            count(
                CASE
                    WHEN ((pd_1.a02_status)::text <> 'CONFIRMED'::text) THEN 1
                    ELSE NULL::integer
                END) AS no_confirmed,
            (((count(
                CASE
                    WHEN ((pd_1.a02_status)::text = 'CONFIRMED'::text) THEN 1
                    ELSE NULL::integer
                END))::numeric * 100.0) / (count(*))::numeric) AS confirmed_proc,
            (((count(
                CASE
                    WHEN (((to_char((pd_1.a02_campaign_end)::timestamp with time zone, 'YYYYMMDD'::text))::integer < (to_char((CURRENT_DATE)::timestamp with time zone, 'YYYYMMDD'::text))::integer) OR ((pd_1.a02_status)::text = ANY (ARRAY[('CANCELED'::character varying)::text, ('END'::character varying)::text]))) THEN 1
                    ELSE NULL::integer
                END))::numeric * 100.0) / (count(*))::numeric) AS end_proc,
            (((count(
                CASE
                    WHEN ((pd_1.a02_status)::text = ANY (ARRAY[('GOING'::character varying)::text, ('CANCELED'::character varying)::text])) THEN 1
                    ELSE NULL::integer
                END))::numeric * 100.0) / (count(*))::numeric) AS going_proc,
            (((count(
                CASE
                    WHEN ((pw.a02_prod_id IS NOT NULL) OR ((pd_1.a02_campaign_type)::text = ANY (ARRAY[('ilgalaike'::character varying)::text, ('vienkartine'::character varying)::text, ('reg_nuolaida'::character varying)::text]))) THEN 1
                    ELSE NULL::integer
                END))::numeric * 100.0) / (count(*))::numeric) AS planned_proc,
            ( SELECT string_agg((distinct_campaign_types.a02_campaign_type)::text, ','::text ORDER BY (distinct_campaign_types.a02_campaign_type)::text) AS string_agg
                   FROM ( SELECT DISTINCT pd2.a02_campaign_type
                           FROM ve.a02_campaign_planned pd2
                          WHERE (pd2.a02_plan_id = pd_1.a02_plan_id)) distinct_campaign_types) AS campaign_types,
            min(pd_1.a02_supply_begin) AS first_supply_begin,
            min(pd_1.a02_campaign_begin) AS first_campaign_begin,
            max(pd_1.a02_campaign_end) AS last_campaign_end,
            count(*) AS planned_prod_count
           FROM (ve.a02_campaign_planned pd_1
             LEFT JOIN ( SELECT a02_campaign_planned_w.a02_plan_id,
                    a02_campaign_planned_w.a02_prod_id,
                    sum(a02_campaign_planned_w.a02_percentage) AS a02_percentage
                   FROM ve.a02_campaign_planned_w
                  GROUP BY a02_campaign_planned_w.a02_plan_id, a02_campaign_planned_w.a02_prod_id
                 HAVING (sum(a02_campaign_planned_w.a02_percentage) = (100)::numeric)) pw ON (((pw.a02_plan_id = pd_1.a02_plan_id) AND ((pw.a02_prod_id)::text = (pd_1.a02_prod_id)::text))))
          GROUP BY pd_1.a02_plan_id) pd ON ((pd.a02_plan_id = ph.a02_plan_id)));
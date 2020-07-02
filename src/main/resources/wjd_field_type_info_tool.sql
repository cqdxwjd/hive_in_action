SELECT current_date(),
       substr(cast(current_date() AS string), 1, 7),
       '1',
       "数字城管",
       t2.main_type_id,
       t2.main_type_name,
       t2.sub_type_id,
       t2.sub_type_name,
       COUNT(DISTINCT CASE
                          WHEN t1.evt_status = '立案' THEN t1.human_id
                          ELSE NULL
                      END),
       COUNT(DISTINCT CASE
                          WHEN t1.evt_status = '专业部门'
                               AND t1.act_def_name = '回退' THEN t1.evt_id
                          ELSE NULL
                      END),
       COUNT(DISTINCT CASE
                          WHEN t1.evt_status = '专业部门'
                               AND t1.act_def_name = '回退' THEN t1.evt_id
                          ELSE NULL
                      END) / COUNT(DISTINCT CASE
                                                WHEN t5.dispose_num = 1 THEN t5.rec_id
                                                ELSE NULL
                                            END),
       sum(t3.dur),
       COUNT(DISTINCT CASE
                          WHEN t1.evt_status = '专业部门'
                               AND t1.act_def_name = '回退' THEN t1.act_id
                          ELSE NULL
                      END),
       COUNT(DISTINCT CASE
                          WHEN t1.evt_status = '核查' THEN t1.human_id
                          ELSE NULL
                      END),
       COUNT(DISTINCT CASE
                          WHEN t1.evt_status = '核查'
                               AND t1.act_def_name = '回退' THEN t1.evt_id
                          ELSE NULL
                      END),
       COUNT(DISTINCT CASE
                          WHEN t1.evt_status = '核查'
                               AND t1.act_def_name = '回退' THEN t1.evt_id
                          ELSE NULL
                      END) / COUNT(DISTINCT CASE
                                                WHEN t5.check_num = 1 THEN t5.rec_id
                                                ELSE NULL
                                            END),
       sum(t4.dur),
       COUNT(DISTINCT CASE
                          WHEN t1.evt_status = '核查'
                               AND t1.act_def_name = '回退' THEN t1.act_id
                          ELSE NULL
                      END)
FROM
  (SELECT *
   FROM dsep.yl_city_mgr_evt_process
   WHERE date_format(deal_time,"yyyy-MM") = "${pmonth}") t1
LEFT JOIN
  (SELECT *
   FROM dsep.yl_city_mgr_evt_info
   WHERE date_format(create_time,"yyyy-MM") = "${pmonth}") t2 --数字城管对应事件表
ON t1.evt_id = t2.rec_id
LEFT JOIN
  (SELECT t1.evt_id,
          (unix_timestamp(t2.back_time)-unix_timestamp(t1.dis_time))/3600 AS dur -- 每个事件的时间差之和

   FROM
     (-- 事件最初派遣时间
 SELECT evt_id,
        min(deal_time) dis_time
      FROM dsep.yl_city_mgr_evt_process
      WHERE trim(evt_status) = '指挥中心（派遣）'
        AND trim(act_def_name) = '办理'
        AND date_format(deal_time,"yyyy-MM") = "${pmonth}"
      GROUP BY evt_id) t1
   JOIN
     (-- 事件最后回退时间
 SELECT evt_id,
        max(deal_time) back_time
      FROM dsep.yl_city_mgr_evt_process
      WHERE trim(evt_status) = '专业部门'
        AND trim(act_def_name) = '回退'
        AND date_format(deal_time,"yyyy-MM") = "${pmonth}"
      GROUP BY evt_id) t2 ON t1.evt_id = t2.evt_id) t3 --处置返工事件耗时
 ON t1.evt_id = t3.evt_id
LEFT JOIN
  (SELECT t1.evt_id,
          (unix_timestamp(t2.back_time)-unix_timestamp(t1.dis_time))/3600 AS dur -- 每个事件的时间差之和

   FROM
     (-- 事件最初派遣时间
 SELECT evt_id,
        min(deal_time) dis_time
      FROM dsep.yl_city_mgr_evt_process
      WHERE trim(evt_status) = '指挥中心（派遣）'
        AND trim(act_def_name) = '办理'
        AND date_format(deal_time,"yyyy-MM") = "${pmonth}"
      GROUP BY evt_id) t1
   JOIN
     (-- 事件最后回退时间
 SELECT evt_id,
        max(deal_time) back_time
      FROM dsep.yl_city_mgr_evt_process
      WHERE trim(evt_status) = '核查'
        AND trim(act_def_name) = '回退'
        AND date_format(deal_time,"yyyy-MM") = "${pmonth}"
      GROUP BY evt_id) t2 ON t1.evt_id = t2.evt_id) t4 --核查返工事件耗时
 ON t1.evt_id = t4.evt_id
LEFT JOIN
  (SELECT *
   FROM dsep.yl_city_mgr_evt_stat
   WHERE date_format(create_time,"yyyy-MM")="${pmonth}") t5 --事件处置统计表
 ON t1.evt_id = t5.rec_id
GROUP BY t2.main_type_id,
         t2.main_type_name,
         t2.sub_type_id,
         t2.sub_type_name
LIMIT 1
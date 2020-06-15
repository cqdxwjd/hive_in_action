SELECT o.park_code,
       o.plate_number,
       CASE o.car_type
           WHEN 0 THEN 1
           WHEN 1 THEN 2
           WHEN 2 THEN 3
           ELSE 0
       END,
       i.entry_time,
       o.exit_time,
       o.duration,
       o.paid_money,
       CASE
           WHEN instr(o.plate_number, '渝') >= 1 THEN 1
           ELSE 0
       END
FROM
  (SELECT row_number() over(partition BY o1.plate_number
                            ORDER BY o1.exit_time DESC) out_seq,
                       o1.*
   FROM dsep.stg_parking_lot_car_exit_info o1 -- 停车场车辆出场信息

   JOIN dsep.stg_parking_lot_info p -- 停车场信息
 ON o1.park_code = p.park_code
   AND p.park_type = 1 -- 路边停车场

   WHERE substr(o1.exit_time, 1, 10) =  date_format(date_sub(current_date(),1),'yyyy-MM-dd') -- 筛选昨天离开车辆
 ) o
JOIN
  (SELECT row_number() over(partition BY i1.plate_number
                            ORDER BY i1.entry_time DESC) in_seq,
                       i1.*
   FROM dsep.stg_parking_lot_car_entry_info i1 -- 停车场车辆入场信息

   JOIN dsep.stg_parking_lot_info p -- 停车场信息
 ON i1.park_code = p.park_code
   AND p.park_type = 1 -- 路边停车场
 ) i ON o.plate_number = i.plate_number
AND o.out_seq = i.in_seq
limit 1
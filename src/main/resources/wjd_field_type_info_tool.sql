SELECT relation_id,
       media_id,
       media_name,
       media_type,
       create_human_id,
       create_time,
       concat(media_path, '/', coalesce(media_uploaded_name, media_name))
FROM dsep.stg_to_media
WHERE date_format(create_time,"yyyy-MM-dd") = "2018-08-16" -- 取昨天产生的数据
LIMIT 1
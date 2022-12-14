SELECT t1.rec_id,
       t1.act_property_id,
       t1.address,
       t1.archive_time,
       t1.cancel_time,
       t1.biz_id,
       t1.biz_name,
       t1.card_num,
       t1.cell_name cell_name1,
       t1.cell_name cell_name2,
       t1.check_msg_state_id,
       t1.check_pic_num,
       t1.check_pic_total_num,
       t1.check_video_num,
       t1.check_video_total_num,
       t1.check_wav_num,
       t1.check_wav_total_num,
       t7.region_code region_code7,
       t1.community_name,
       t1.coordinate_x,
       t1.coordinate_y,
       t1.create_time,
       t1.damage_grade_id,
       t1.damage_grade_name,
       t1.deadline_char,
       t1.deadline_time,
       t1.dispatch_opinion,
       t1.dispatch_time,
       t1.display_property,
       t1.display_style_id,
       t5.region_code region_code1,
       t1.district_name,
       t1.duration_unit,
       t1.duty_grid_id,
       t1.duty_grid_name,
       t1.event_desc,
       t1.event_grade_id,
       t1.event_grade_name,
       t1.event_level_id,
       t1.event_level_name,
       t1.event_src_id,
       t1.event_src_name,
       t1.event_type_code,
       t1.event_type_id,
       t1.event_type_name,
       t1.fifth_type_id,
       t1.fifth_type_name,
       t1.forth_type_id,
       t1.forth_type_name,
       t1.func_deadline,
       t1.func_deal_time,
       t1.func_limit_char,
       t1.func_part_id,
       t1.func_part_name,
       t1.func_time_state_id,
       t1.gather_flag,
       t1.link_field_display_value,
       t1.link_field_value,
       t3.tgt_cd_val tgt_cd_val1,
       t3.tgt_cd_desc tgt_cd_desc2,
       t1.media_check_num,
       t1.media_check_total_num,
       t1.media_lost_flag,
       t1.media_upload_num,
       t1.media_upload_state,
       t1.media_upload_total_num,
       t1.media_url,
       t1.media_verify_total_num,
       t1.mms_pic_path,
       t1.new_inst_cond_id,
       t1.new_inst_cond_name,
       t1.occur_time,
       t1.part_code,
       t1.patrol_deal_flag,
       t1.patrol_id,
       t1.patrol_name,
       t1.pos_type,
       t1.proc_ard_state_id,
       t1.proc_enq_state_id,
       t1.proc_start_time,
       t1.proc_sup_state_id,
       t1.proc_time_state_id,
       t1.rec_deadline,
       t1.rec_disp_num,
       t1.rec_remain,
       t1.rec_remain_char,
       t1.rec_type_id,
       t1.rec_type_name,
       t1.rec_used,
       t1.rec_used_char,
       t1.rec_warning,
       t1.refresh_flag,
       t1.refresh_start_time,
       t1.refresh_time,
       t1.report_id,
       t1.report_pic_num,
       t1.report_pic_total_num,
       t1.report_video_num,
       t1.report_video_total_num,
       t1.report_wav_num,
       t1.report_wav_total_num,
       t6.region_code region_code2,
       t1.street_name,
       t4.tgt_cd_val tgt_cd_val2,
       t4.tgt_cd_desc tgt_cd_desc1,
       t1.task_num,
       t1.third_type_id,
       t1.third_type_name,
       t1.time_area_id,
       t1.time_area_name,
       t1.unique_id,
       t1.urgent_flag,
       t1.urgent_memo,
       t1.verify_msg_state_id,
       t1.verify_pic_total_num,
       t1.verify_video_total_num,
       t1.verify_wav_total_num,
       t1.video_device_id,
       t1.video_param,
       t1.view_angle,
       t1.view_image_name,
       t1.view_image_x,
       t1.view_image_y,
       t1.view_pos_x,
       t1.view_pos_y,
       t1.warning_time,
       t1.sys_id,
       t1.form_id,
       t1.verify_pic_num,
       t1.verify_wav_num,
       t1.verify_video_num,
       t1.media_verify_num,
       t1.road_type_id,
       t1.road_name,
       t1.road_id,
       t1.archive_cond_id,
       t1.archive_cond,
       t1.road_type_name,
       t1.area_type_id,
       t1.equal_group_id,
       t1.regather_msg_state_id,
       t1.new_inst_advise,
       t1.event_marks,
       t1.archive_type_id,
       t1.report_time_segment_id,
       t1.enable_check_msg,
       t1.revise_opinion,
       t1.report_area_limit_id,
       t1.deduction,
       t1.attach_rec_flag,
       t1.sixth_type_id,
       t1.sixth_type_name,
       t1.seventh_type_id,
       t1.seventh_type_name,
       t1.max_event_type_id,
       t1.max_event_type_name,
       t1.occur_num,
       t1.check_send_time,
       t1.check_reply_time,
       t8.region_code region_code3,
       t1.duty_region_name,
       t1.lonlat_x,
       t1.lonlat_y,
       t1.func_bundle_deadline,
       t1.third_unique_id,
       t1.event_property_id,
       t1.event_property_name,
       t1.city_village_flag,
       t1.specify_func_id,
       t1.specify_competent_func_id,
       t1.specify_func_name,
       t1.specify_competent_func_name,
       t1.super_rec_id,
       t1.split_rec_flag,
       t1.site_num,
       t1.difficult_type_id,
       t1.event_district_grade_id,
       t1.event_district_grade_name,
       t9.region_code region_code4,
       t10.region_code region_code5,
       t11.region_code region_code6,
       t1.duty_district_name,
       t1.duty_street_name,
       t1.duty_community_name,
       t1.cus_grid_code,
       t1.accepter_id,
       t1.accepter_name,
       t1.auto_check_count,
       t1.other_task_num,
       t1.force_handle_flag,
       t1.func_part_list_id,
       t1.func_part_list_name,
       t1.custom_deadline,
       t1.act_record_id,
       t1.tell_num,
       t1.reply_opinion,
       t1.send_from_type,
       t1.func_forbid_reporter_info_flag,
       t1.property_company_id,
       t1.accept_status,
       t1.shop_name,
       t1.func_custom_limit,
       t1.squadron_id,
       t1.squadron_name,
       t1.locked_flag,
       t1.check_type_id,
       t1.no_return_visit_flag,
       t1.rec_analysis_type_id,
       t1.deal_evaluate_ids,
       t1.common_rec_type_flag,
       t1.common_rec_attr_flag,
       t1.main_rec_id,
       t1.transited_flag,
       t1.send_pub_check_task_flag,
       t1.patroltask_deadline_time,
       t1.shop_id,
       t1.spec_type_id,
       t1.spec_type_name,
       t1.law_duty_grid_id,
       t1.law_duty_grid_name,
       t1.proc_account_state_id,
       t1.first_depart_name,
       t1.second_depart_name,
       t1.self_deal_msg_state_id,
       t1.reply_intime_deadline,
       t1.reply_intime,
       t1.newinst_no_transit,
       t1.duty_grid_type_id,
       t1.deal_duty_grid_type_id,
       t1.deal_duty_grid_id,
       t1.deal_duty_grid_name,
       t1.site_id,
       t1.media_self_deal_total_num,
       t1.media_self_deal_num,
       t1.self_deal_pic_total_num,
       t1.self_deal_pic_num,
       t1.self_deal_wav_total_num,
       t1.self_deal_wav_num,
       t1.self_deal_video_total_num,
       t1.self_deal_video_num,
       t1.review_msg_state_id,
       t1.media_review_total_num,
       t1.media_review_num,
       t1.review_pic_total_num,
       t1.review_pic_num,
       t1.review_wav_total_num,
       t1.review_wav_num,
       t1.review_video_total_num,
       t1.review_video_num,
       t1.public_flag,
       t1.whistle_flag,
       t1.jx_id,
       t1.jx_jxmc,
       t1.jx_design_type,
       t1.repeat_state,
       t1.cg_area,
       t1.hw_area,
       t1.sz_area,
       t1.supervision_check_state_id,
       t1.rec_category_id,
       t1.device_guid,
       t1.proc_press_state_id,
       t2.act_def_name,
       current_timestamp()
FROM dsep.stg_to_rec t1
LEFT JOIN
  (SELECT t.*
   FROM
     (SELECT row_number() over(partition BY rec_id
                               ORDER BY act_id DESC) seq,
                          t.rec_id,
                          t.act_def_name
      FROM stg_to_rec_act t) t
   WHERE t.Seq = 1 ) t2 --??????????????????
ON t1.rec_id = t2.rec_id
LEFT JOIN dsep.dim_cd_map_src_to_tgt t3 --?????????2???????????????
ON t1.main_type_id = t3.src_cd_val
AND t3.src_tbl_en = 'stg_to_rec'
AND t3.src_col_en = 'main_type_id'
AND t3.tgt_cd_type = 'cd_evt_type'
LEFT JOIN dsep.dim_cd_map_src_to_tgt t4 --?????????3???????????????
ON t1.sub_type_id = t4.src_cd_val
AND t4.src_tbl_en = 'stg_to_rec'
AND t4.src_col_en = 'sub_type_id'
AND t4.tgt_cd_type = 'cd_evt_type'
LEFT JOIN stg_tc_region t5 ON t1.district_id = t5.region_id
LEFT JOIN stg_tc_region t6 ON t1.street_id = t6.region_id
LEFT JOIN stg_tc_region t7 ON t1.community_id = t7.region_id
LEFT JOIN stg_tc_region t8 ON t1.duty_region_id = t8.region_id
LEFT JOIN stg_tc_region t9 ON t1.duty_district_id = t9.region_id
LEFT JOIN stg_tc_region t10 ON t1.duty_street_id = t10.region_id
LEFT JOIN stg_tc_region t11 ON t1.duty_community_id = t11.region_id
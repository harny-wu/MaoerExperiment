# 契合度计算表
create table 0101_0131_danmu_involved_DY
select t1.user_id,
       t1.sound_id,
       avg(all_8_sim_1)                                                                                                                                                   as all_8_sim,  #公式(1) T = [-8,8] 结果
       avg(all_15_sim_1)                                                                                                                                                  as all_15_sim, #公式(1) T = [-15,15] 结果
       avg(0.3 * before_8_sim_1 + 0.7 * after_8_sim_1)                                                                                                                    as k_1_8s_sim,
       avg(0.5 * before_8_sim_1 + 0.5 * after_8_sim_1)                                                                                                                    as k_2_8s_sim,
       avg(0.7 * before_8_sim_1 + 0.3 * after_8_sim_1)                                                                                                                    as k_3_8s_sim,
       avg(0.3 * before_15_sim_1 + 0.7 * after_15_sim_1)                                                                                                                  as k_1_15s_sim,
       avg(0.5 * before_15_sim_1 + 0.5 * after_15_sim_1)                                                                                                                  as k_2_15s_sim,
       avg(0.7 * before_15_sim_1 + 0.3 * after_15_sim_1)                                                                                                                  as k_3_15s_sim,
       avg(0.5 * (0.3 * before_8_sim_1 + 0.7 *
                                         (danmu_num_before_8s - danmu_num_before_8s_min) /
                                         (danmu_num_before_8s_max - danmu_num_before_8s_min)) + 0.5 * (0.3 *
                                                                                                       after_8_sim_1 +
                                                                                                       0.7 *
                                                                                                       (danmu_num_after_8s - danmu_num_after_8s_min) /
                                                                                                       (danmu_num_after_8s_max - danmu_num_after_8s_min)))                as k_2_8s_sim_q_1_num,
       avg(0.5 * (0.5 * before_8_sim_1 + 0.5 * ((danmu_num_before_8s - danmu_num_before_8s_min) /
                                                (danmu_num_before_8s_max - danmu_num_before_8s_min))) + 0.5 * (0.5 *
                                                                                                               after_8_sim_1 +
                                                                                                               0.5 *
                                                                                                               ((danmu_num_after_8s - danmu_num_after_8s_min) /
                                                                                                                (danmu_num_after_8s_max - danmu_num_after_8s_min))))      as k_2_8s_sim_q_2_num,
       avg(0.5 * (0.7 * before_8_sim_1 + 0.3 * ((danmu_num_before_8s - danmu_num_before_8s_min) /
                                                (danmu_num_before_8s_max - danmu_num_before_8s_min))) + 0.5 * (0.7 *
                                                                                                               after_8_sim_1 +
                                                                                                               0.3 *
                                                                                                               ((danmu_num_after_8s - danmu_num_after_8s_min) /
                                                                                                                (danmu_num_after_8s_max - danmu_num_after_8s_min))))      as k_2_8s_sim_q_3_num,
       avg(0.5 * (0.3 * before_15_sim_1 + 0.7 * ((danmu_num_before_15s_all - danmu_num_before_15s_min) /
                                                 (danmu_num_before_15s_max - danmu_num_before_15s_min))) + 0.5 * (0.3 *
                                                                                                                  after_15_sim_1 +
                                                                                                                  0.7 *
                                                                                                                  ((danmu_num_after_15s_all - danmu_num_after_15s_min) /
                                                                                                                   (danmu_num_after_15s_max - danmu_num_after_15s_min)))) as k_2_15s_sim_q_1_num,
       avg(0.5 * (0.5 * before_15_sim_1 + 0.5 * ((danmu_num_before_15s_all - danmu_num_before_15s_min) /
                                                 (danmu_num_before_15s_max - danmu_num_before_15s_min))) + 0.5 * (0.5 *
                                                                                                                  after_15_sim_1 +
                                                                                                                  0.5 *
                                                                                                                  ((danmu_num_after_15s_all - danmu_num_after_15s_min) /
                                                                                                                   (danmu_num_after_15s_max - danmu_num_after_15s_min)))) as k_2_15s_sim_q_2_num,
       avg(0.5 * (0.5 * before_15_sim_1 + 0.5 * ((danmu_num_before_15s_all - danmu_num_before_15s_min) /
                                                 (danmu_num_before_15s_max - danmu_num_before_15s_min))) + 0.5 * (0.5 *
                                                                                                                  after_15_sim_1 +
                                                                                                                  0.5 *
                                                                                                                  ((danmu_num_after_15s_all - danmu_num_after_15s_min) /
                                                                                                                   (danmu_num_after_15s_max - danmu_num_after_15s_min)))) as k_2_15s_sim_q_3_num
from (select t2.user_id,
             t2.sound_id,
             0.5 * (case
                        when max_before_8s >= max_after_8s then max_before_8s
                        else max_after_8s
                 end) +
             0.5 *
             IFNULL((sum_before_8s + sum_after_8s) / (danmu_num_before_8s + danmu_num_after_8s), 0) as all_8_sim_1,
             0.5 * (case
                        when max_before_15s_all >= max_after_15s_all then max_before_15s_all
                        else max_after_15s_all
                 end) + 0.5 * IFNULL((sum_before_15s_all + sum_after_15s_all) /
                                     (danmu_num_before_15s_all + danmu_num_after_15s_all),
                                     0)                                                             as all_15_sim_1,
             IFNULL(0.5 * max_before_8s + 0.5 * IFNULL(sum_before_8s / danmu_num_before_8s, 0),
                    0)                                                                              as before_8_sim_1,
             IFNULL(0.5 * max_after_8s + 0.5 * IFNULL(sum_after_8s / danmu_num_after_8s, 0),
                    0)                                                                              as after_8_sim_1,
             IFNULL(0.5 * max_before_15s_all + 0.5 *
                                               IFNULL(sum_before_15s_all / danmu_num_before_15s_all, 0),
                    0)                                                                              as before_15_sim_1,
             IFNULL(0.5 * max_after_15s_all + 0.5 *
                                              IFNULL(sum_after_15s_all / danmu_num_after_15s_all, 0),
                    0)                                                                              as after_15_sim_1,
             danmu_num_before_8s,
             danmu_num_after_8s,
             danmu_num_before_15s_all,
             danmu_num_after_15s_all,
             danmu_num_before_8s_max,
             danmu_num_before_8s_min,
             danmu_num_after_8s_max,
             danmu_num_after_8s_min,
             danmu_num_before_15s_max,
             danmu_num_before_15s_min,
             danmu_num_after_15s_max,
             danmu_num_after_15s_min
      from (select t3.*,
                   t4.drama_id,
                   t4.danmu_info_date,
                   (t3.sum_before_8s + t3.sum_before_15s)             as sum_before_15s_all,
                   (t3.sum_after_8s + t3.sum_after_15s)               as sum_after_15s_all,
                   (case
                        when t3.max_before_8s >= t3.max_before_15s then t3.max_before_8s
                        else t3.max_before_15s
                       end)                                           as max_before_15s_all,
                   (case
                        when t3.max_after_8s >= t3.max_after_15s then t3.max_after_8s
                        else t3.max_after_15s
                       end)                                           as max_after_15s_all,
                   (t3.danmu_num_before_8s + t3.danmu_num_before_15s) as danmu_num_before_15s_all,
                   (t3.danmu_num_after_8s + t3.danmu_num_after_15s)   as danmu_num_after_15s_all
            from danmu_involved_activeuser_202211_202303_allinfo t3
                     join activeuser_submit_danmu_sound_with_drama_202211_202303 t4 on
                t3.danmu_id = t4.danmu_id
            where danmu_info_date >= '2023-01-01'
              and danmu_info_date <= '2023-01-31') as t2
               left join (select max(danmu_num_before_8s)                        as danmu_num_before_8s_max,
                                 min(danmu_num_before_8s)                        as danmu_num_before_8s_min,
                                 max(danmu_num_after_8s)                         as danmu_num_after_8s_max,
                                 min(danmu_num_after_8s)                         as danmu_num_after_8s_min,
                                 max(danmu_num_before_8s + danmu_num_before_15s) as danmu_num_before_15s_max,
                                 min(danmu_num_before_8s + danmu_num_before_15s) as danmu_num_before_15s_min,
                                 max(danmu_num_after_8s + danmu_num_after_15s)   as danmu_num_after_15s_max,
                                 min(danmu_num_after_8s + danmu_num_after_15s)   as danmu_num_after_15s_min
                          from danmu_involved_activeuser_202211_202303_allinfo) as t6 on
          1 = 1) as t1
group by t1.user_id,
         t1.sound_id;


# 构建付费数据集
-- 得到弹幕契合度之后根据之前的表生成新数据集
create table 0101_0131_all_feature_involved_DY as
select

t4.user_name_len,
t4.user_name_has_chinese,
t4.user_name_has_english,
t4.user_intro_len,
t4.user_intro_has_chinese,
t4.user_intro_has_english,
t4.user_icon_is_default,
t4.user_has_submit_sound_or_darma,
t4.user_grade,
t4.user_fish_num,
t4.user_follower_num,
t4.user_fans_num,
t4.user_has_organization,
t4.user_submit_sound_num,
t4.user_submit_drama_num,
t4.user_subscribe_drama_num,
t4.user_subscribe_channel_num,
t4.user_favorite_album_num,
t4.user_image_num,
t4.user_submit_danmu_drama_completed_num_now,
t4.user_submit_danmu_drama_total_view_num,
t4.user_submit_danmu_drama_max_view_num,
t4.user_submit_danmu_drama_min_view_num,
t4.user_submit_danmu_drama_avg_view_num,
t4.user_submit_danmu_drama_total_danmu_num,
t4.user_submit_danmu_drama_max_danmu_num,
t4.user_submit_danmu_drama_min_danmu_num,
t4.user_submit_danmu_drama_avg_danmu_num,
t4.user_submit_danmu_drama_total_review_num,
t4.user_submit_danmu_drama_max_review_num,
t4.user_submit_danmu_drama_min_review_num,
t4.user_submit_danmu_drama_avg_review_num,
# t4.user_submit_danmu_sound_total_view_num,
# t4.user_submit_danmu_sound_max_view_num,
# t4.user_submit_danmu_sound_min_view_num,
# t4.user_submit_danmu_sound_avg_view_num,
# t4.user_submit_danmu_sound_total_danmu_num,
# t4.user_submit_danmu_sound_max_danmu_num,
# t4.user_submit_danmu_sound_min_danmu_num,
# t4.user_submit_danmu_sound_avg_danmu_num,
# t4.user_submit_danmu_sound_total_review_num,
# t4.user_submit_danmu_sound_max_review_num,
# t4.user_submit_danmu_sound_min_review_num,
# t4.user_submit_danmu_sound_avg_review_num,
t2.user_in_sound_is_submit_review,
t2.user_in_sound_submit_review_num,
t2.user_in_sound_first_review_with_sound_publish_time_diff_days,
t2.user_in_sound_latest_review_with_sound_publish_time_diff_days,
t2.user_in_sound_review_total_len,
t2.user_in_sound_review_len_max,
t2.user_in_sound_review_len_min,
t2.user_in_sound_review_len_avg,
t2.user_in_sound_review_subreview_total_num,
t2.user_in_sound_review_subreview_max_num,
t2.user_in_sound_review_subreview_min_num,
t2.user_in_sound_review_subreview_avg_num,
t2.user_in_sound_review_like_total_num,
t2.user_in_sound_review_like_max_num,
t2.user_in_sound_review_like_min_num,
t2.user_in_sound_review_like_avg_num,
t2.user_in_sound_is_submit_danmu,
t2.user_in_sound_submit_danmu_total_len,
t2.user_in_sound_submit_danmu_max_len,
t2.user_in_sound_submit_danmu_min_len,
t2.user_in_sound_submit_danmu_avg_len,
t2.user_in_sound_submit_danmu_num,
t2.user_in_sound_danmu_around_15s_total_danmu_max_num,
t2.user_in_sound_danmu_around_15s_total_danmu_min_num,
t2.user_in_sound_danmu_around_15s_total_danmu_avg_num,
# t2.user_in_drama_total_review_num,
# t2.user_in_drama_total_danmu_num,

t3.sound_title_len,
t3.sound_intro_len,
t3.sound_tag_num,
t3.sound_type,
t3.sound_time,
t3.sound_view_num,
t3.sound_danmu_num,
t3.sound_favorite_num,
t3.sound_point_num,
t3.sound_review_not_subreview_num,
t3.sound_review_subreview_num,
t3.sound_is_allow_download,
t3.sound_submit_time_between_first_and_this,
t3.sound_position_in_total_darma_sound,
# t3.sound_view_num_in_total_darma_percent,
# t3.sound_danmu_num_in_total_darma_percent,
# t3.sound_favorite_num_in_total_darma_percent,
# t3.sound_point_num_in_total_darma_percent,
# t3.sound_review_num_in_total_darma_percent,
# t3.sound_not_subreview_num_in_total_darma_percent,
# t3.sound_subreview_num_in_total_darma_percent,
t3.sound_review_avg_len,
t3.sound_review_max_len,
t3.sound_review_min_len,
t3.sound_review_avg_like_num,
t3.sound_review_max_like_num,
t3.sound_review_min_like_num,
t3.sound_review_submit_time_between_submit_sound_time_max,
t3.sound_review_submit_time_between_submit_sound_time_min,
t3.sound_review_submit_time_between_submit_sound_time_avg,
t3.sound_review_submit_time_between_submit_sound_time_in_7days_num,
t3.sound_review_submit_time_between_submit_sound_time_in_14days_num,
t3.sound_review_submit_time_between_submit_sound_time_in_30days_num,
t3.sound_danmu_avg_len,
t3.sound_danmu_max_len,
t3.sound_danmu_min_len,
t3.sound_danmu_submit_time_between_submit_sound_time_max,
t3.sound_danmu_submit_time_between_submit_sound_time_min,
t3.sound_danmu_submit_time_between_submit_sound_time_avg,
t3.sound_danmu_submit_time_between_submit_sound_time_in_7days_num,
t3.sound_danmu_submit_time_between_submit_sound_time_in_14days_num,
t3.sound_danmu_submit_time_between_submit_sound_time_in_30days_num,
t3.sound_danmu_15s_max_traffic,
t3.sound_danmu_15s_min_traffic,
t3.sound_danmu_15s_avg_traffic,
t3.sound_danmu_15s_max_traffic_position_in_sound,
t3.sound_danmu_15s_min_traffic_position_in_sound,
t3.sound_cv_total_num,
t3.sound_cv_has_userid_num,
t3.sound_cv_total_fans_num,
t3.sound_cv_max_fans_num,
t3.sound_cv_min_fans_num,
t3.sound_cv_avg_fans_num,
t3.sound_cv_main_cv_total_fans_num,
t3.sound_cv_main_cv_max_fans_num,
t3.sound_cv_main_cv_min_fans_num,
t3.sound_cv_main_cv_avg_fans_num,
t3.sound_cv_auxiliary_cv_max_fans_num,
t3.sound_cv_auxiliary_cv_min_fans_num,
t3.sound_cv_auxiliary_cv_avg_fans_num,
t3.sound_tag_total_cite_num,
t3.sound_tag_max_cite_num,
t3.sound_tag_min_cite_num,
t3.sound_tag_avg_cite_num,

t5.drama_name_len,
t5.drama_intro_len,
t5.drama_has_author,
t5.drama_is_serialize,
t5.drama_total_sound_num,
t5.drama_total_view_num,
t5.drama_type,
t5.drama_tag_num,
t5.drama_cv_total_num,
t5.drama_cv_total_fans_num,
t5.drama_cv_max_fans_num,
t5.drama_cv_min_fans_num,
t5.drama_cv_avg_fans_num,
t5.drama_cv_main_total_fans_num,
t5.drama_cv_main_max_fans_num,
t5.drama_cv_main_min_fans_num,
t5.drama_cv_main_avg_fans_num,
t5.drama_cv_aux_max_fans_num,
t5.drama_cv_aux_min_fans_num,
t5.drama_cv_aux_avg_fans_num,
t5.drama_sound_cv_max_num,
t5.drama_sound_cv_min_num,
t5.drama_sound_cv_avg_num,
t5.drama_sound_has_max_cv_num_sound_view_num,
t5.drama_sound_has_max_cv_num_sound_danmu_num,
t5.drama_sound_has_max_cv_num_sound_favorite_num,
t5.drama_sound_has_max_cv_num_sound_point_num,
t5.drama_sound_has_max_cv_num_sound_review_num,
t5.drama_sound_has_min_cv_num_sound_view_num,
t5.drama_sound_has_min_cv_num_sound_danmu_num,
t5.drama_sound_has_min_cv_num_sound_favorite_num,
t5.drama_sound_has_min_cv_num_sound_point_num,
t5.drama_sound_has_min_cv_num_sound_review_num,
# t5.drama_total_danmu_num,
# t5.drama_max_danmu_num,
# t5.drama_min_danmu_num,
# t5.drama_avg_danmu_num,
# t5.drama_total_favorite_num,
# t5.drama_max_favorite_num,
# t5.drama_min_favorite_num,
# t5.drama_avg_favorite_num,
# t5.drama_total_point_num,
# t5.drama_max_point_num,
# t5.drama_min_point_num,
# t5.drama_avg_point_num,
# t5.drama_total_review_num,
# t5.drama_max_review_num,
# t5.drama_min_review_num,
# t5.drama_avg_review_num,
t5.drama_sound_has_max_view_num_sound_danmu_num,
t5.drama_sound_has_max_view_num_sound_favorite_num,
t5.drama_sound_has_max_view_num_sound_point_num,
t5.drama_sound_has_max_view_num_sound_review_num,
t5.drama_sound_has_max_view_num_sound_cv_num,
t5.drama_sound_has_max_view_num_sound_cv_total_fans_num,
t5.drama_sound_has_max_view_num_sound_is_pay,
t5.drama_sound_has_min_view_num_sound_danmu_num,
t5.drama_sound_has_min_view_num_sound_favorite_num,
t5.drama_sound_has_min_view_num_sound_point_num,
t5.drama_sound_has_min_view_num_sound_review_num,
t5.drama_sound_has_min_view_num_sound_cv_num,
t5.drama_sound_has_min_view_num_sound_cv_total_fans_num,
t5.drama_sound_has_min_view_num_sound_is_pay,
t5.drama_upuser_grade,
t5.drama_upuser_fish_num,
t5.drama_upuser_fans_num,
t5.drama_upuser_follower_num,
t5.drama_upuser_submit_sound_num,
t5.drama_upuser_submit_drama_num,
t5.drama_upuser_subscriptions_num,
t5.drama_upuser_channel_num,
t5.drama_upuser_submit_sound_total_view_num,
t5.drama_upuser_submit_sound_max_view_num,
t5.drama_upuser_submit_sound_min_view_num,
t5.drama_upuser_submit_sound_avg_view_num,
t5.drama_upuser_submit_sound_total_danmu_num,
t5.drama_upuser_submit_sound_max_danmu_num,
t5.drama_upuser_submit_sound_min_danmu_num,
t5.drama_upuser_submit_sound_avg_danmu_num,
t5.drama_upuser_submit_sound_total_review_num,
t5.drama_upuser_submit_sound_max_review_num,
t5.drama_upuser_submit_sound_min_review_num,
t5.drama_upuser_submit_sound_avg_review_num,
t5.drama_upuser_submit_drama_has_fans_reward,
t5.drama_sound_total_time,
t5.drama_sound_max_time,
t5.drama_sound_min_time,
t5.drama_sound_avg_time,
t5.drama_sound_max_time_sound_view_num,
t5.drama_sound_min_time_sound_view_num,
t5.drama_sound_max_time_sound_danmu_num,
t5.drama_sound_min_time_sound_danmu_num,
t5.drama_sound_max_time_sound_review_num,
t5.drama_sound_min_time_sound_review_num,
t5.drama_sound_danmu_15s_max_traffic,
t5.drama_sound_danmu_15s_min_traffic,
t5.drama_sound_danmu_15s_avg_traffic,
t5.drama_sound_max_traffic_position_in_sound_avg,
t5.drama_sound_min_traffic_position_in_sound_avg,
t5.drama_danmu_avg_len,
t5.drama_danmu_max_len,
t5.drama_danmu_min_len,
t5.drama_danmu_submit_time_between_submit_sound_time_max,
t5.drama_danmu_submit_time_between_submit_sound_time_min,
t5.drama_danmu_submit_time_between_submit_sound_time_avg,
t5.drama_danmu_time_between_sound_time_in_7days_num_max,
t5.drama_danmu_time_between_sound_time_in_7days_num_min,
t5.drama_danmu_time_between_sound_time_in_7days_num_avg,
t5.drama_danmu_time_between_sound_time_in_14days_num_max,
t5.drama_danmu_time_between_sound_time_in_14days_num_min,
t5.drama_danmu_time_between_sound_time_in_14days_num_avg,
t5.drama_danmu_time_between_sound_time_in_30days_num_max,
t5.drama_danmu_time_between_sound_time_in_30days_num_min,
t5.drama_danmu_time_between_sound_time_in_30days_num_avg,
t5.drama_sound_tag_total_cite_num,
t5.drama_sound_tag_max_cite_num,
t5.drama_sound_tag_min_cite_num,
t5.drama_sound_tag_avg_cite_num,

t7.orientation,
t7.era,
t7.type,
t7.label1,
t7.label2,
t7.label3,
t7.label4,
t7.label5,

t6.*,
t1.all_8_sim,
t1.all_15_sim,
t1.k_1_8s_sim,
t1.k_2_8s_sim,
t1.k_3_8s_sim,
t1.k_1_15s_sim,
t1.k_2_15s_sim,
t1.k_3_15s_sim,
t1.k_2_8s_sim_q_1_num,
t1.k_2_8s_sim_q_2_num,
t1.k_2_8s_sim_q_3_num,
t1.k_2_15s_sim_q_1_num,
t1.k_2_15s_sim_q_2_num,
t1.k_2_15s_sim_q_3_num,
t2.user_in_drama_is_pay_for_drama_in_next_time

from 0101_0131_danmu_involved_DY t1
left join 0101_0131_user_sound_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
left join 0101_0131_sound_feature t3 on t1.sound_id=t3.sound_id
left join 0101_0131_user_feature  t4 on t1.user_id=t4.user_id
left join 0101_0131_drama_feature t5 on t1.drama_id=t5.drama_id
left join maoer_data_analysis.feat_sound_opensmile384_new t6 on t1.sound_id=t6.sound_id
left join active_drama_gpt_final_result t7 on t1.drama_id=t7.drama_id
where t2.user_in_drama_sound_pay_type=1; # 付费
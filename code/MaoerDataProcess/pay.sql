SELECT COUNT(1)
FROM `0201_0208_user_sound_feature`;

-- 用户对于一个声音的特征 时间窗内
create table 0201_0208_user_sound_feature
select user_id, sound_id, drama_id
from activeuser_submit_danmu_sound_with_drama_202211_202303
where danmu_info_date >= '2023-02-01'
  and danmu_info_date <= '2023-02-08'
group by user_id, sound_id, drama_id;

alter table 0201_0208_user_sound_feature
    add COLUMN user_in_sound_is_submit_review                                int(1) COMMENT "用户是否提交评论",
    add COLUMN user_in_sound_submit_review_num                               int(11) COMMENT "用户提交评论数量",
    add COLUMN user_in_sound_first_review_with_sound_publish_time_diff_days  int(11),
    add COLUMN user_in_sound_latest_review_with_sound_publish_time_diff_days int(11),
    add COLUMN user_in_sound_review_total_len                                int(11),
    add COLUMN user_in_sound_review_len_max                                  int(11),
    add COLUMN user_in_sound_review_len_min                                  int(11),
    add COLUMN user_in_sound_review_len_avg                                  double,
    add COLUMN user_in_sound_review_subreview_total_num                      int(11),
    add COLUMN user_in_sound_review_subreview_max_num                        int(11),
    add COLUMN user_in_sound_review_subreview_min_num                        int(11),
    add COLUMN user_in_sound_review_subreview_avg_num                        double,
    add COLUMN user_in_sound_review_like_total_num                           int(11),
    add COLUMN user_in_sound_review_like_max_num                             int(11),
    add COLUMN user_in_sound_review_like_min_num                             int(11),
    add COLUMN user_in_sound_review_like_avg_num                             double,
    add COLUMN user_in_sound_is_submit_danmu                                 int(1) COMMENT "用户是否提交弹幕",
    add COLUMN user_in_sound_submit_danmu_total_len                          int(11) COMMENT "用户提交弹幕长度之和",
    add COLUMN user_in_sound_submit_danmu_max_len                            int(11),
    add COLUMN user_in_sound_submit_danmu_min_len                            int(11),
    add COLUMN user_in_sound_submit_danmu_avg_len                            double,
    add COLUMN user_in_sound_submit_danmu_num                                int(11) COMMENT "用户是否弹幕数量",
    add COLUMN user_in_sound_danmu_around_15s_total_danmu_max_num            int(11),
    add COLUMN user_in_sound_danmu_around_15s_total_danmu_min_num            int(11),
    add COLUMN user_in_sound_danmu_around_15s_total_danmu_avg_num            double,
    add COLUMN user_in_drama_total_review_num                                int(11),
    add COLUMN user_in_drama_total_danmu_num                                 int(11),
    add COLUMN user_in_drama_is_pay_for_drama                                int(1),
    add COLUMN user_in_drama_is_in_drama_fans_reward                         int(1),
    add COLUMN user_in_drama_fans_reward_total_coin                          int(11),
    add COLUMN user_in_drama_is_follower_upuser                              int(1),
    ADD COLUMN user_in_drama_sound_pay_type                                  INT(1),
    add COLUMN drama_info_pay_type                                           int(1) COMMENT "声音付费类型",
    add COLUMN sound_info_pay_type                                           int(1) COMMENT "声音付费类型",
    add COLUMN user_in_drama_is_pay_for_drama_in_next_time                   int(1);


UPDATE 0201_0208_user_sound_feature t1 join
    (select t3.user_id,
            t3.sound_id,
            (case when t4.review_id is null then 0 else 1 end) as user_in_sound_is_submit_review,
            sum(t4.review_id is not null)                      as user_in_sound_submit_review_num,
            min(t4.review_created_time)                        as user_in_sound_first_review_time,
            max(t4.review_created_time)                        as user_in_sound_latest_review_time,
            sum(length(t4.review_content))                     as user_in_sound_review_total_len,
            max(length(t4.review_content))                     as user_in_sound_review_len_max,
            min(length(t4.review_content))                     as user_in_sound_review_len_min,
            avg(length(t4.review_content))                     as user_in_sound_review_len_avg,
            sum(t4.review_sub_review_num)                      as user_in_sound_review_subreview_total_num,
            max(t4.review_sub_review_num)                      as user_in_sound_review_subreview_max_num,
            min(t4.review_sub_review_num)                      as user_in_sound_review_subreview_min_num,
            avg(t4.review_sub_review_num)                      as user_in_sound_review_subreview_avg_num,
            sum(t4.review_like_num)                            as user_in_sound_review_like_total_num,
            max(t4.review_like_num)                            as user_in_sound_review_like_max_num,
            min(t4.review_like_num)                            as user_in_sound_review_like_min_num,
            avg(t4.review_like_num)                            as user_in_sound_review_like_avg_num
     from (select user_id, sound_id
           from activeuser_submit_danmu_sound_with_drama_202211_202303
           where danmu_info_date >= '2023-02-01'
             and danmu_info_date <= '2023-02-08'
           group by user_id, sound_id) t3
              left join (select *
                         from maoer.review_content
                         where review_created_time >= '2023-02-01'
                           and review_created_time <= '2023-02-08') t4
                        on t3.user_id = t4.user_id and t3.sound_id = t4.subject_id
     group by t3.user_id, t3.sound_id) t2 on t1.user_id = t2.user_id and t1.sound_id = t2.sound_id
    left join (select sound_id, sound_info_created_time
               from maoer.sound_info
               group by sound_id) t5 on t2.sound_id = t5.sound_id
set t1.user_in_sound_is_submit_review                                =t2.user_in_sound_is_submit_review,           # 1
    t1.user_in_sound_submit_review_num                               =t2.user_in_sound_submit_review_num,          # 2
    t1.user_in_sound_first_review_with_sound_publish_time_diff_days  = datediff(t2.user_in_sound_first_review_time, # 3
                                                                                t5.sound_info_created_time),
    t1.user_in_sound_latest_review_with_sound_publish_time_diff_days = datediff(t2.user_in_sound_latest_review_time,
                                                                                t5.sound_info_created_time),       # 4
    t1.user_in_sound_review_total_len                                =t2.user_in_sound_review_total_len,           # 5
    t1.user_in_sound_review_len_max                                  =t2.user_in_sound_review_len_max,             # 6
    t1.user_in_sound_review_len_min                                  =t2.user_in_sound_review_len_min,             # 7
    t1.user_in_sound_review_len_avg                                  =t2.user_in_sound_review_len_avg,             # 8
    t1.user_in_sound_review_subreview_total_num                      =t2.user_in_sound_review_subreview_total_num, # 9
    t1.user_in_sound_review_subreview_max_num                        =t2.user_in_sound_review_subreview_max_num,   # 10
    t1.user_in_sound_review_subreview_min_num                        =t2.user_in_sound_review_subreview_min_num,   # 11
    t1.user_in_sound_review_subreview_avg_num                        =t2.user_in_sound_review_subreview_avg_num,   # 12
    t1.user_in_sound_review_like_total_num                           =t2.user_in_sound_review_like_total_num,      # 13
    t1.user_in_sound_review_like_max_num                             =t2.user_in_sound_review_like_max_num,        # 14
    t1.user_in_sound_review_like_min_num                             =t2.user_in_sound_review_like_min_num,        # 15
    t1.user_in_sound_review_like_avg_num                             =t2.user_in_sound_review_like_avg_num; # 16

update 0201_0208_user_sound_feature t1 join
    (select t3.user_id, t3.drama_id, sum(t3.user_in_sound_submit_review_num) as user_in_drama_total_review_num
     from 0201_0208_user_sound_feature t3
     group by t3.user_id, t3.drama_id) t2 on t1.user_id = t2.user_id and t1.drama_id = t2.drama_id
set t1.user_in_drama_total_review_num = t2.user_in_drama_total_review_num; # 17

update 0201_0208_user_sound_feature t1 join
    (select t3.user_id,
            t3.sound_id,
            count(distinct t3.danmu_id) as user_in_sound_submit_danmu_num,
            max(case
                    when CEIL(t3.danmu_info_stime_notransform / 30) = t4.30s_position_in_sound then t4.30s_num
                    else 0 end)         as user_in_sound_danmu_around_15s_total_danmu_max_num,
            min(case
                    when CEIL(t3.danmu_info_stime_notransform / 30) = t4.30s_position_in_sound then t4.30s_num
                    else 0 end)         as user_in_sound_danmu_around_15s_total_danmu_min_num,
            max(case
                    when CEIL(t3.danmu_info_stime_notransform / 30) = t4.30s_position_in_sound then t4.30s_num
                    else 0 end)         as user_in_sound_danmu_around_15s_total_danmu_avg_num
     from (select *
           from activeuser_submit_danmu_sound_with_drama_202211_202303
           where danmu_info_date >= '2023-02-01'
             and danmu_info_date <= '2023-02-08') t3
              left join (select * from temp_sound_traffic_count union select * from temp_supply_sound_traffic_count) t4
                        on t3.sound_id = t4.sound_id and
                           CEIL(t3.danmu_info_stime_notransform / 30) = t4.30s_position_in_sound
              left join (select sound_id, sound_info_duration from maoer.sound_info_update group by sound_id) t5
                        on t5.sound_id = t3.sound_id
     group by t3.user_id, t3.sound_id) t2 on t1.user_id = t2.user_id and t1.sound_id = t2.sound_id
set t1.user_in_sound_submit_danmu_num                     = t2.user_in_sound_submit_danmu_num,                     # 18
    t1.user_in_sound_danmu_around_15s_total_danmu_max_num = t2.user_in_sound_danmu_around_15s_total_danmu_max_num, # 19
    t1.user_in_sound_danmu_around_15s_total_danmu_min_num = t2.user_in_sound_danmu_around_15s_total_danmu_min_num, # 20
    t1.user_in_sound_danmu_around_15s_total_danmu_avg_num = t2.user_in_sound_danmu_around_15s_total_danmu_avg_num; # 21


update 0201_0208_user_sound_feature t1 join
    (select t3.user_id,
            t3.drama_id,
            sum(t3.user_in_sound_submit_review_num) as user_in_drama_total_review_num,
            sum(user_in_sound_submit_danmu_num)     as user_in_drama_total_danmu_num
     from 0201_0208_user_sound_feature t3
     group by t3.user_id, t3.drama_id) t2 on t1.user_id = t2.user_id and t1.drama_id = t2.drama_id
set t1.user_in_drama_total_review_num = t2.user_in_drama_total_review_num,
    t1.user_in_drama_total_danmu_num  = t2.user_in_drama_total_danmu_num;


--
update 0201_0208_user_sound_feature t1 left join
    (select drama_id, drama_info_pay_type, drama_info_need_pay
     from maoer.drama_info_update
     group by drama_id) t2 on t1.drama_id = t2.drama_id
set t1.drama_info_pay_type=t2.drama_info_pay_type;

update 0201_0208_user_sound_feature t1 left join
    (select sound_id, sound_info_pay_type from maoer.sound_info group by sound_id) t3 on t1.sound_id = t3.sound_id
set t1.sound_info_pay_type=t3.sound_info_pay_type;

update 0201_0208_user_sound_feature
set user_in_drama_sound_pay_type = (case
                                        when drama_info_pay_type = 0 then 0
                                        when drama_info_pay_type = 2 and sound_info_pay_type = 0 then 1
                                        when drama_info_pay_type = 2 and sound_info_pay_type = 2 then 2
                                        when drama_info_pay_type = 1 and sound_info_pay_type = 0 then 1
                                        when drama_info_pay_type = 1 and sound_info_pay_type = 1 then 2 end);

--
update 1101_1130_user_sound_feature t1 join (select t3.user_id,
                                                    t3.drama_id,
                                                    t3.drama_info_pay_type,
                                                    sum(case when t4.user_in_drama_sound_pay_type = 2 then 1 else 0 end) as user_in_drama_is_pay_for_drama
                                             from 1101_1130_user_sound_feature t3
                                                      left join (select user_id, drama_id, user_in_drama_sound_pay_type
                                                                 from 1101_1130_user_sound_feature
                                                                 union
                                                                 select user_id, drama_id, user_in_drama_sound_pay_type
                                                                 from 1201_1215_user_sound_feature) t4
                                                                on t3.user_id = t4.user_id and t3.drama_id = t4.drama_id
                                             group by t3.user_id, t3.drama_id) t2 on t1.user_id = t2.user_id and t1.drama_id = t2.drama_id
set t1.user_in_drama_is_pay_for_drama_in_next_time =(case
                                                         when t2.drama_info_pay_type = 0 then 0
                                                         when t2.drama_info_pay_type = 1 and t2.user_in_drama_is_pay_for_drama >= 1
                                                             then 1
                                                         when t2.drama_info_pay_type = 2 and t2.user_in_drama_is_pay_for_drama >= 1
                                                             then 1
                                                         else 2 end)

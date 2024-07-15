-- 查看活跃用户发表有弹幕的声音(count:39339)
-- select distinct sound_id
-- from maoer.danmu_info_2022
-- where danmu_info_2022.user_id in (select user_id from maoer.active_users_audience_delete_zimu_users)

-- 查看活跃用户发表有弹幕的声音(count:39339)与活跃声音(count:105462)的交集数量  result：39177  (已存表active_sound_with_activeuser2022)
-- select COUNT(DISTINCt sound_id)
-- from maoer.active_sound
-- WHERE maoer.active_sound.sound_id
-- in (SELECT sound_id
-- FROM maoer_data_analysis.activeuser_havedanmu_sound)
-- 生成上面的数据集 包含sound_id,sound_info_view_count,sound_info_pay_type
-- select DISTINCt maoer.active_sound.sound_id,viewcount.sound_info_view_count,maoer.sound_info.sound_info_pay_type
-- from maoer.active_sound join (SELECT sound_id, MAX(created_time) AS last_update_time,sound_info_view_count
-- FROM maoer.sound_info_update
-- GROUP BY sound_id ) as viewcount
-- on maoer.active_sound.sound_id=viewcount.sound_id
-- join maoer.sound_info on maoer.active_sound.sound_id=maoer.sound_info.sound_id
-- WHERE maoer.active_sound.sound_id
-- in (SELECT sound_id
-- FROM maoer_data_analysis.activeuser_havedanmu_sound)
-- order by viewcount.sound_info_view_count desc


-- 查看上面声音结果中付费类型分布  result：0不付费：30323；1单集付费：1666；2全集付费：7188
-- select COUNT(DISTINCT maoer.sound_info.sound_id)
-- from maoer.sound_info right join
-- (select DISTINCt sound_id
-- from maoer.active_sound
-- WHERE maoer.active_sound.sound_id
-- in (SELECT sound_id
-- FROM maoer_data_analysis.activeuser_havedanmu_sound)) as needsound
-- on maoer.sound_info.sound_id=needsound.sound_id
-- where maoer.sound_info.sound_info_pay_type='2'

-- SELECT COUNT(distinct sound_id)
-- from maoer.sound_info

-- 查看活跃用户在选定的活跃用户与活跃声音的声音交集(39177)中所有发表的弹幕
-- SELECT di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_time_insound,di.danmu_info_date_notransform,di.danmu_info_date,danmu_info_text
-- FROM maoer.danmu_info_2022 AS di
-- INNER JOIN maoer.active_users_audience AS auhs ON di.user_id = auhs.user_id
-- INNER JOIN active_sound_with_activeuser2022 AS aswa ON di.sound_id = aswa.sound_id;
-- select di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_text
-- from maoer.danmu_info_2022 as di
-- where di.user_id in (select user_id from maoer.active_users_audience)

-- 查找对应sound_id的活跃用户发的弹幕 result:[132033777,1005552,7235539,1720.510000,'N刷']
-- select di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_text
-- from maoer.danmu_info_2022 as di
-- where di.user_id in (select user_id from maoer.active_users_audience)
-- and di.sound_id='1005552'

-- 根据对应sound_id查找所有sound_id中的弹幕并建临时表
-- CREATE temporary TABLE Temp_danmu_sound_Table
-- AS SELECT distinct di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_text
-- FROM maoer.danmu_info as di
-- where di.sound_id='1005552'

-- 删除临时表
-- DROP TEMPORARY TABLE IF EXISTS Temp_danmu_sound_Table


-- 找到上面所有指定弹幕在所在声音中前后15s的所有弹幕
-- 方法1 danmu_info 全表查询
-- select di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_text
-- from maoer.danmu_info as di
-- where di.sound_id='1005552' and di.danmu_info_stime_notransform>1720.510000-15 and di.danmu_info_stime_notransform<1720.510000+15
-- 方法2 用新建的临时表查询 已知为同一sound_id
-- select DISTINCT di.danmu_id,di.sound_id,di.user_id,di.danmu_info_stime_notransform,di.danmu_info_text
-- from Temp_danmu_sound_Table as di
-- where di.danmu_info_stime_notransform>1720.510000-15 and di.danmu_info_stime_notransform<1720.510000+15

-- select COUNT(di.danmu_id)
-- from Temp_danmu_sound_Table as di
-- where di.danmu_info_stime_notransform>1720.510000-15 and di.danmu_info_stime_notransform<1720.510000+15
-- DROP TEMPORARY TABLE IF EXISTS Temp_danmu_sound_Table

-- 剔除字幕用户 只在一个剧集里面活跃，每集超过50，其他剧集不活跃
-- SELECT sound_id, user_id, COUNT(*) AS count
-- FROM maoer.danmu_info_2022
-- WHERE user_id = '7221179'
-- GROUP BY sound_id, user_id
-- HAVING count > 100
-- LIMIT 1;
-- 199个用户 剔除
--  SELECT user_id,danmu_count
--     FROM maoer.active_users_audience
--     WHERE danmu_count > 5000
-- 		ORDER BY danmu_count desc

-- 剔除字幕用户后的活跃用户
-- -- CREATE TABLE maoer.active_users_audience_delete_zimu_users AS
-- select *
-- from maoer.active_users_audience
-- where danmu_count < 5000

-- 新建视图
-- create view activeuser_drama_info as
-- select `asd`.`user_id` AS `user_id`,`asd`.`sound_id` AS `sound_id`,`asd`.`drama_id` AS `drama_id`,`di`.`drama_info_name` AS `drama_info_name`,`di`.`drama_info_alias` AS `drama_info_alias`,`di`.`drama_info_age` AS `drama_info_age`,`di`.`drama_info_author` AS `drama_info_author`,`di`.`drama_info_type` AS `drama_info_type`,`di`.`drama_info_catalog` AS `drama_info_catalog`,`di`.`drama_info_catalog_name` AS `drama_info_catalog_name`,`di`.`organization_id` AS `organization_id`,`di`.`drama_info_style` AS `drama_info_style`,`di`.`drama_info_abstract` AS `drama_info_abstract`,`di`.`drama_info_organization` AS `drama_info_organization`,`diu`.`drama_info_serialize` AS `drama_info_serialize`,`diu`.`drama_info_pay_type` AS `drama_info_pay_type`,`diu`.`drama_info_need_pay` AS `drama_info_need_pay`,`diu`.`drama_info_price` AS `drama_info_price`,`diu`.`drama_info_newest` AS `drama_info_newest`,`diu`.`drama_info_newst_episode_id` AS `drama_info_newst_episode_id`,`diu`.`drama_info_update_period` AS `drama_info_update_period`,`diu`.`drama_info_view_count` AS `drama_info_view_count`,`diu`.`drama_info_all_reward_num` AS `drama_info_all_reward_num`,`diu`.`drama_info_reward_week_rank` AS `drama_info_reward_week_rank` from ((`maoer_data_analysis`.`activeuser_submit_danmu_sound_with_drama` `asd` left join `maoer`.`drama_info` `di` on((`asd`.`drama_id` = `di`.`drama_id`))) left join (select `maoer`.`drama_info_update`.`drama_id` AS `drama_id`,`maoer`.`drama_info_update`.`drama_info_serialize` AS `drama_info_serialize`,`maoer`.`drama_info_update`.`drama_info_pay_type` AS `drama_info_pay_type`,`maoer`.`drama_info_update`.`drama_info_need_pay` AS `drama_info_need_pay`,`maoer`.`drama_info_update`.`drama_info_price` AS `drama_info_price`,`maoer`.`drama_info_update`.`drama_info_newest` AS `drama_info_newest`,`maoer`.`drama_info_update`.`drama_info_newst_episode_id` AS `drama_info_newst_episode_id`,`maoer`.`drama_info_update`.`drama_info_update_period` AS `drama_info_update_period`,`maoer`.`drama_info_update`.`drama_info_view_count` AS `drama_info_view_count`,`maoer`.`drama_info_update`.`drama_info_all_reward_num` AS `drama_info_all_reward_num`,`maoer`.`drama_info_update`.`drama_info_reward_week_rank` AS `drama_info_reward_week_rank`,`maoer`.`drama_info_update`.`created_time` AS `created_time`,max(`maoer`.`drama_info_update`.`created_time`) AS `max(created_time)` from `maoer`.`drama_info_update` group by `maoer`.`drama_info_update`.`drama_id`) `diu` on((`asd`.`drama_id` = `diu`.`drama_id`)))

create view activeuser_drama_and_sound_info as
-- select `asd`.`user_id` AS `user_id`,`asd`.`sound_id` AS `sound_id`,`asd`.`drama_id` AS `drama_id`,`di`.`drama_info_name` AS `drama_info_name`,`di`.`drama_info_alias` AS `drama_info_alias`,`di`.`drama_info_age` AS `drama_info_age`,`di`.`drama_info_author` AS `drama_info_author`,`di`.`drama_info_type` AS `drama_info_type`,`di`.`drama_info_catalog` AS `drama_info_catalog`,`di`.`drama_info_catalog_name` AS `drama_info_catalog_name`,`di`.`organization_id` AS `organization_id`,`di`.`drama_info_style` AS `drama_info_style`,`di`.`drama_info_abstract` AS `drama_info_abstract`,`di`.`drama_info_organization` AS `drama_info_organization`,`diu`.`drama_info_serialize` AS `drama_info_serialize`,`diu`.`drama_info_pay_type` AS `drama_info_pay_type`,`diu`.`drama_info_need_pay` AS `drama_info_need_pay`,`diu`.`drama_info_price` AS `drama_info_price`,`diu`.`drama_info_newest` AS `drama_info_newest`,`diu`.`drama_info_newst_episode_id` AS `drama_info_newst_episode_id`,`diu`.`drama_info_update_period` AS `drama_info_update_period`,`diu`.`drama_info_view_count` AS `drama_info_view_count`,`diu`.`drama_info_all_reward_num` AS `drama_info_all_reward_num`,`diu`.`drama_info_reward_week_rank` AS `drama_info_reward_week_rank` from ((`maoer_data_analysis`.`activeuser_submit_danmu_sound_with_drama` `asd` left join `maoer`.`drama_info` `di` on((`asd`.`drama_id` = `di`.`drama_id`))) left join (select `maoer`.`drama_info_update`.`drama_id` AS `drama_id`,`maoer`.`drama_info_update`.`drama_info_serialize` AS `drama_info_serialize`,`maoer`.`drama_info_update`.`drama_info_pay_type` AS `drama_info_pay_type`,`maoer`.`drama_info_update`.`drama_info_need_pay` AS `drama_info_need_pay`,`maoer`.`drama_info_update`.`drama_info_price` AS `drama_info_price`,`maoer`.`drama_info_update`.`drama_info_newest` AS `drama_info_newest`,`maoer`.`drama_info_update`.`drama_info_newst_episode_id` AS `drama_info_newst_episode_id`,`maoer`.`drama_info_update`.`drama_info_update_period` AS `drama_info_update_period`,`maoer`.`drama_info_update`.`drama_info_view_count` AS `drama_info_view_count`,`maoer`.`drama_info_update`.`drama_info_all_reward_num` AS `drama_info_all_reward_num`,`maoer`.`drama_info_update`.`drama_info_reward_week_rank` AS `drama_info_reward_week_rank`,`maoer`.`drama_info_update`.`created_time` AS `created_time`,max(`maoer`.`drama_info_update`.`created_time`) AS `max(created_time)` from `maoer`.`drama_info_update` group by `maoer`.`drama_info_update`.`drama_id`) `diu` on((`asd`.`drama_id` = `diu`.`drama_id`)))
--
-- ——————————————用户特征提取部分(用activeuser)————————————————
-- 建表-活跃用户信息表 activeuser_info
-- select ui.user_id,ui.user_name,ui.user_intro,ui.user_icon,ui.user_icon_2,ui.user_icon_top,ui.user_info_grade,ui.user_info_fish_num,ui.user_info_follower_num,ui.user_info_fans_num,ui.organization_id,ui.user_info_sound_num,ui.user_info_drama_num,ui.user_info_subscriptions_num,ui.user_info_channel,ui.user_info_album_num,ui.user_info_image_num,MAX(ui.created_time)as created_time
-- from maoer.active_users_audience as ut INNER JOIN maoer.user_info as ui
-- on ut.user_id=ui.user_id
-- GROUP BY ui.user_id

-- WHERE ut LIKE '%[A-Za-z]%' OR column_name LIKE '%[\u4e00-\u9fa5]%'
-- 建表-活跃用户发表弹幕的剧集
-- Create Table activeuser_submit_danmu_sound_with_drama as
-- select DISTINCT ud.user_id,ud.sound_id
-- from maoer.danmu_info_2022 as ud
-- where ud.user_id in (select user_id from maoer.active_users_audience)
-- group by ud.user_id,ud.sound_id

-- SHOW VARIABLES LIKE 'innodb_buffer_pool_size';

-- 建表-活跃用户发表弹幕的声音+剧集activeuser_submit_danmu_sound
-- Create Table activeuser_submit_danmu_sound_with_drama as
-- select distinct ads.user_id,ads.sound_id,de.drama_id
-- from activeuser_with_danmu_sound as ads
-- join maoer.drama_episodes as de on ads.sound_id=de.sound_id

-- 建表 活跃用户发表弹幕的声音所属剧集信息
-- Create VIEW activeuser_drama_info as
-- select asd.user_id,asd.sound_id,asd.drama_id,di.drama_info_name,di.drama_info_alias,di.drama_info_age,di.drama_info_author,di.drama_info_type,di.drama_info_catalog,di.drama_info_catalog_name,di.organization_id,di.drama_info_style,di.drama_info_abstract,di.drama_info_organization,diu.drama_info_serialize,diu.drama_info_pay_type,diu.drama_info_need_pay,diu.drama_info_price,diu.drama_info_newest,diu.drama_info_newst_episode_id,diu.drama_info_update_period,diu.drama_info_view_count,diu.drama_info_all_reward_num,diu.drama_info_reward_week_rank
-- FROM activeuser_submit_danmu_sound_with_drama as asd LEFT JOIN maoer.drama_info as di on asd.drama_id=di.drama_id
-- left join(
-- select *,max(created_time) from maoer.drama_info_update group by drama_id
-- ) as diu on asd.drama_id=diu.drama_id

-- Create VIEW activeuser_drama_and_sound_info as
-- select adi.*,
-- si.sound_info_catalog_id,si.sound_info_created_time,si.user_id as up_user_id,si.sound_info_name,si.sound_info_pay_type,si.sound_info_type,
-- siu.sound_info_last_updated_time,siu.sound_info_duration,siu.sound_info_intro,siu.sound_info_view_count,siu.sound_info_danmu_count,siu.sound_info_favorite_count,siu.sound_info_point,siu.sound_info_review_count,siu.sound_info_sub_review_count,siu.sound_info_download,siu.sound_info_all_comments_num,siu.sound_info_all_reviews_num,siu.sound_info_forbidden_comment
-- FROM activeuser_drama_info as adi
-- LEFT JOIN maoer.sound_info as si on adi.sound_id=si.sound_id
-- left join (
-- select a.*,MAX(a.created_time) from maoer.sound_info_update as a group by a.sound_id
-- ) as siu on adi.sound_id=siu.sound_id

-- select  count(1) FROM activeuser_drama_and_sound_info

-- result：1060822；544629(去重)
-- SELECT COUNT(1) from maoer.sound_info_update
-- select a.*,MAX(a.created_time) from maoer.sound_info_update as a group by a.sound_id

-- 特征提取 user
-- create table user_feature as
-- select user_id,LENGTH(user_name)as user_name_len
-- from activeuser_info

-- ALTER TABLE user_feature
-- ADD COLUMN user_name_has_chinese INT DEFAULT 0,
-- ADD COLUMN user_name_has_english INT DEFAULT 0,
-- add COLUMN user_intro_len int,
-- add COLUMN user_intro_has_chinese int DEFAULT 0,
-- add COLUMN user_intro_has_english int DEFAULT 0,
-- add COLUMN user_incon_is_default int DEFAULT 0,
-- add COLUMN user_has_submit_sound_or_drama int DEFAULT 0,
-- add COLUMN user_grade int,
-- add COLUMN user_fish_num int,
-- add COLUMN user_follower_num int,
-- add COLUMN user_fans_num int,
-- add COLUMN user_has_organization_num int,
-- add COLUMN user_submit_sound_num int,
-- add COLUMN user_submit_drama_num int,
-- add COLUMN user_subscribe_drama_num int,
-- add COLUMN user_subscribe_channel_num int,
-- add COLUMN user_favorite_album_num int,
-- add COLUMN user_image_num int,
-- add COLUMN user_major_subscribe_drama_type varchar(50),
-- add COLUMN user_minor_subscribe_drama_type varchar(50),
-- add COLUMN user_submit_danmu_drama_completed_num int,
-- add COLUMN user_submit_danmu_drama_total_view_num int,
-- add COLUMN user_submit_danmu_drama_max_view_num int,
-- add COLUMN user_submit_danmu_drama_min_view_num int,
-- add COLUMN user_submit_danmu_drama_avg_view_num int,
-- add COLUMN user_submit_danmu_drama_total_danmu_num int,
-- add COLUMN user_submit_danmu_drama_max_danmu_num int,
-- add COLUMN user_submit_danmu_drama_min_danmu_num int,
-- add COLUMN user_submit_danmu_drama_avg_danmu_num int,
-- add COLUMN user_submit_danmu_drama_total_review_num int,
-- add COLUMN user_submit_danmu_drama_max_review_num int,
-- add COLUMN user_submit_danmu_drama_min_review_num int,
-- add COLUMN user_submit_danmu_drama_avg_review_num int,
-- add COLUMN user_has_in_drama_fans_reward int,
-- add COLUMN user_has_in_drama_fans_reward_drama_type varchar(50)



-- 更新新字段的值
-- UPDATE user_feature t1
-- JOIN activeuser_info t2 ON t1.user_id = t2.user_id
-- SET t1.user_name_has_chinese = CASE WHEN t2.user_name REGEXP '[\\u4e00-\\u9fa5]' COLLATE utf8mb4_unicode_ci THEN 1 ELSE 0 END,
--     t1.user_name_has_english = CASE WHEN t2.user_name  REGEXP '[a-zA-Z]' COLLATE utf8mb4_unicode_ci THEN 1 ELSE 0 END;
-- t1.user_intro_len=LENGTH(t2.user_intro),
-- t1.user_intro_has_chinese=CASE WHEN LENGTH(t2.user_intro) != CHAR_LENGTH(t2.user_intro) THEN 1 ELSE 0 END,
-- t1.user_intro_has_english=CASE WHEN t2.user_intro COLLATE utf8mb4_unicode_ci REGEXP '[a-zA-Z]'THEN 1 ELSE 0 END,
-- t1.user_incon_is_default=CASE WHEN t2.user_icon like '%icon%' then 1 else 0 end,
-- t1.user_has_submit_sound_or_drama= case when t2.user_info_sound_num>0 or t2.user_info_drama_num>0 then 1 else 0 end,
-- t1.user_grade=t2.user_info_grade,
-- t1.user_fish_num=t2.user_info_fish_num,
-- t1.user_follower_num=t2.user_info_follower_num,
-- t1.user_fans_num=t2.user_info_fans_num,
-- t1.user_has_organization=t2.organization_id is not null,
-- t1.user_submit_sound_num=t2.user_info_sound_num,
-- t1.user_submit_drama_num=t2.user_info_drama_num,
-- t1.user_subscribe_drama_num=t2.user_info_subscriptions_num,
-- t1.user_subscribe_channel_num=t2.user_info_channel,
-- t1.user_favorite_album_num=t2.user_info_album_num,
-- t1.user_image_num=t2.user_info_image_num

-- UPDATE user_feature t1
-- JOIN activeuser_drama_info t2 ON t1.user_id = t2.user_id


-- 用户发布弹幕的剧集中已完结剧集的数量
-- UPDATE user_feature AS t1
-- JOIN (
--     SELECT a.user_id, COUNT(DISTINCT a.drama_id) AS count
--     FROM activeuser_drama_and_sound_info AS a
--     WHERE a.drama_info_serialize = '0'
--     GROUP BY a.user_id
-- ) AS t2
-- ON t1.user_id = t2.user_id
-- SET t1.user_submit_danmu_drama_completed_num = t2.count;

-- 用户发布弹幕的剧集的播放量/弹幕数量/评论量
-- UPDATE user_feature AS t1
-- JOIN (
--     SELECT a.user_id,count(distinct a.drama_id),sum(a.sound_info_view_count) as sivc_sum,max(a.sound_info_view_count) as sivc_max,min(a.sound_info_view_count) as sivc_min,avg(a.sound_info_view_count) as sivc_avg,sum(a.sound_info_danmu_count) as sidc_sum,max(a.sound_info_danmu_count) as sidc_max,min(a.sound_info_danmu_count) as sidc_min,avg(a.sound_info_danmu_count) as sidc_avg,sum(a.sound_info_review_count) as sirc_sum,max(a.sound_info_review_count) as sirc_max,min(a.sound_info_review_count) as sirc_min,avg(a.sound_info_review_count) as sirc_avg
--     FROM activeuser_drama_and_sound_info AS a
--     GROUP BY a.user_id
-- ) AS t2
-- ON t1.user_id = t2.user_id
-- SET t1.user_submit_danmu_drama_total_view_num = t2.sivc_sum,
-- t1.user_submit_danmu_drama_max_view_num = t2.sivc_max,
-- t1.user_submit_danmu_drama_min_view_num = t2.sivc_min,
-- t1.user_submit_danmu_drama_avg_view_num = t2.sivc_avg,
-- t1.user_submit_danmu_drama_total_danmu_num = t2.sidc_sum,
-- t1.user_submit_danmu_drama_max_danmu_num = t2.sidc_max,
-- t1.user_submit_danmu_drama_min_danmu_num = t2.sidc_min,
-- t1.user_submit_danmu_drama_avg_danmu_num = t2.sidc_avg,
-- t1.user_submit_danmu_drama_total_review_num = t2.sivc_sum,
-- t1.user_submit_danmu_drama_max_review_num = t2.sivc_max,
-- t1.user_submit_danmu_drama_min_review_num = t2.sivc_min,
-- t1.user_submit_danmu_drama_avg_review_num = t2.sivc_avg

-- UPDATE user_feature AS t1
-- JOIN (
-- 		SELECT a.user_id, COUNT(*) AS count,sum(drama_fans_reward_coin) as coinsum
-- 		FROM (
--     SELECT DISTINCT drama_id, user_id,drama_fans_reward_coin
--     FROM maoer.drama_fans_reward
-- 		) AS a
-- 		GROUP BY a.user_id
-- ) AS t2
-- ON t1.user_id = t2.user_id
-- SET t1.user_has_in_drama_fans_reward_num = t2.count,
-- t1.user_has_in_drama_fans_reward_total_money = t2.coinsum



-- ——————————产品-声音特征提取部分(用activeuser-with-danmu-sound)—————

-- 特征提取 sound_feature
-- create table sound_feature as
-- select distinct sound_id
-- from active_sound_with_activeuser2022

-- ALTER TABLE sound_feature
-- ADD COLUMN sound_title_len INT ,
-- ADD COLUMN sound_intro_len INT,
-- ADD COLUMN sound_tag_num INT,
-- ADD COLUMN sound_pay_type INT,
-- ADD COLUMN sound_type INT,
-- ADD COLUMN sound_time INT,
-- ADD COLUMN sound_view_num INT,
-- ADD COLUMN sound_danmu_num INT,
-- ADD COLUMN sound_favorite_num INT,
-- ADD COLUMN sound_point_num INT,
-- ADD COLUMN sound_review_not_subreview_num INT,
-- ADD COLUMN sound_review_subreview_num INT,
-- ADD COLUMN sound_is_allow_download INT,
-- ADD COLUMN sound_submit_time_between_first_and_this INT,
-- ADD COLUMN sound_position_in_total_darma_sound INT,
-- ADD COLUMN sound_view_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_danmu_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_favorite_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_point_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_review_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_not_subreview_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_subreview_num_in_total_darma_percent DOUBLE
-- ADD COLUMN sound_review_avg_len int ,
-- ADD COLUMN sound_review_max_len int ,
-- ADD COLUMN sound_review_min_len int ,
-- ADD COLUMN sound_review_avg_like_num int ,
-- ADD COLUMN sound_review_avg_max_num int,
-- ADD COLUMN sound_review_avg_min_num int ,
-- ADD COLUMN sound_review_positive_num int,
-- ADD COLUMN sound_review_negtive_num int,
-- ADD COLUMN sound_review_submit_time_between_submit_sound_time_max int,
-- ADD COLUMN sound_review_submit_time_between_submit_sound_time_min int,
-- ADD COLUMN sound_review_submit_time_between_submit_sound_time_avg int,
-- ADD COLUMN sound_review_submit_time_between_submit_sound_time_in_7days_num int,
-- ADD COLUMN sound_review_submit_time_between_submit_sound_time_in_14days_num int ,
-- ADD COLUMN sound_review_submit_time_between_submit_sound_time_in_30days_num int,
-- ADD COLUMN sound_danmu_avg_len int,
-- ADD COLUMN sound_danmu_max_len int,
-- ADD COLUMN sound_danmu_min_len int,
-- ADD COLUMN sound_danmu_positive_num int,
-- ADD COLUMN sound_danmu_negitive_num int,
-- ADD COLUMN sound_danmu_submit_time_between_submit_sound_time_max int,
-- ADD COLUMN sound_danmu_submit_time_between_submit_sound_time_min int,
-- ADD COLUMN sound_danmu_submit_time_between_submit_sound_time_avg int,
-- ADD COLUMN sound_danmu_submit_time_between_submit_sound_time_in_7days_num int,
-- ADD COLUMN sound_danmu_submit_time_between_submit_sound_time_in_14days_num int,
-- ADD COLUMN sound_danmu_submit_time_between_submit_sound_time_in_30days_num int,
-- ADD COLUMN sound_danmu_15s_max_traffic int,
-- ADD COLUMN sound_danmu_15s_min_traffic int,
-- ADD COLUMN sound_danmu_15s_avg_traffic double,
-- ADD COLUMN sound_danmu_15s_max_traffic_position_in_sound double,
-- ADD COLUMN sound_danmu_15s_min_traffic_position_in_sound double,
-- ADD COLUMN sound_danmu_15s_avg_traffic_position_in_sound double,
-- ADD COLUMN sound_cv_total_num int,
-- ADD COLUMN sound_cv_has_userid_num int,
-- ADD COLUMN sound_cv_total_fans_num int,
-- ADD COLUMN sound_cv_max_fans_num int,
-- ADD COLUMN sound_cv_min_fans_num int,
-- ADD COLUMN sound_cv_avg_fans_num double,
-- ADD COLUMN sound_cv_main_cv_total_fans_num int,
-- ADD COLUMN sound_cv_main_cv_max_fans_num int,
-- ADD COLUMN sound_cv_main_cv_min_fans_num int,
-- ADD COLUMN sound_cv_main_cv_avg_fans_num double,
-- ADD COLUMN sound_cv_auxiliary_cv_max_fans_num int,
-- ADD COLUMN sound_cv_auxiliary_cv_min_fans_num int,
-- ADD COLUMN sound_cv_auxiliary_cv_avg_fans_num double,
-- ADD COLUMN sound_tag_total_cite_num INT,
-- ADD COLUMN sound_tag_max_cite_num INT,
-- ADD COLUMN sound_tag_min_cite_num INT,
-- ADD COLUMN sound_tag_avg_cite_num INT,
-- ADD COLUMN sound_tag_has_cv_name_num INT,
-- ADD COLUMN sound_tag_has_cv_name_total_cite_num INT,
-- ADD COLUMN sound_tag_has_cv_name_max_cite_num INT,
-- ADD COLUMN sound_tag_has_cv_name_min_cite_num INT,
-- ADD COLUMN sound_tag_has_cv_name_avg_cite_num INT


-- 更新新字段的值
-- UPDATE sound_feature t1
-- JOIN maoer.sound_info t2 ON t1.sound_id = t2.sound_id
-- join maoer.sound_info_update t3 on t1.sound_id=t3.sound_id
-- join (
-- SELECT e.sound_id, COUNT(*) AS tag_num
--     FROM maoer.sound_tags AS e
--     GROUP BY e.sound_id
-- ) as t4 on t1.sound_id=t4.sound_id
-- SET
-- t1.sound_title_len =LENGTH(t2.sound_info_name),
-- t1.sound_intro_len =LENGTH(t3.sound_info_intro),
-- t1.sound_tag_num =t4.tag_num,
-- t1.sound_pay_type =t2.sound_info_pay_type,
-- t1.sound_type =t2.sound_info_type,
-- t1.sound_time =t3.sound_info_duration,
-- t1.sound_view_num =t3.sound_info_view_count,
-- t1.sound_danmu_num =t3.sound_info_danmu_count,
-- t1.sound_favorite_num =t3.sound_info_favorite_count,
-- t1.sound_point_num =t3.sound_info_point,
-- t1.sound_review_not_subreview_num =t3.sound_info_review_count,
-- t1.sound_review_subreview_num =t3.sound_info_sub_review_count,
-- t1.sound_is_allow_download =t3.sound_info_download

-- 建表drama_sound_num_count
-- create table drama_sound_num_count as
-- select e.drama_id, sum(e.sound_info_view_count) as view_num, sum(e.sound_info_danmu_count) as danmu_num, sum(e.sound_info_favorite_count) as favorite_num, sum(e.sound_info_point) as point_num, sum(e.sound_info_all_reviews_num) as allreview_num, sum(e.sound_info_review_count)as review_num, sum(e.sound_info_sub_review_count) as subreview_num
-- from (
-- select f.*
-- from activeuser_drama_and_sound_info as f
-- group by f.drama_id,f.sound_id
-- ) as e
-- GROUP BY e.drama_id

-- UPDATE sound_feature t1
-- -- JOIN activeuser_drama_and_sound_info t2 ON t1.sound_id = t2.sound_id
-- join (select * from maoer.drama_episodes ep group by ep.drama_id,ep.sound_id)as t4 on t4.sound_id=t1.sound_id
-- join drama_sound_num_count t3 on t4.drama_id=t3.drama_id
-- SET
-- t1.sound_view_num_in_total_darma_percent =t1.sound_view_num/t3.view_num,
-- t1.sound_danmu_num_in_total_darma_percent =t1.sound_danmu_num/t3.danmu_num,
-- t1.sound_favorite_num_in_total_darma_percent =t1.sound_favorite_num/t3.favorite_num,
-- t1.sound_point_num_in_total_darma_percent =t1.sound_point_num/t3.point_num,
-- t1.sound_review_num_in_total_darma_percent =(t1.sound_review_not_subreview_num+t1.sound_review_subreview_num)/t3.allreview_num,
-- t1.sound_not_subreview_num_in_total_darma_percent =t1.sound_review_not_subreview_num/t3.review_num,
-- t1.sound_subreview_num_in_total_darma_percent =t1.sound_review_subreview_num/t3.subreview_num


-- 构建sound_review_feature
-- create table sound_review_feature as(
-- select a.subject_id,avg(LENGTH(a.review_content)) as review_len_avg,max(LENGTH(a.review_content)) as review_len_max,min(LENGTH(a.review_content)) as review_len_min,avg(a.review_like_num) as review_like_avg,max(a.review_like_num) as review_like_max,min(a.review_like_num) as review_like_min,
-- max(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_max,
-- min(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_min,
-- avg(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_avg,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>7 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_7days_num,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>14 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_14days_num,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>30 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_30days_num
-- from (
-- select distinct e.review_id,e.subject_id,e.review_content,e.review_like_num,e.review_created_time
-- from maoer.review_content as e) as a
-- join (select distinct sound_id,sound_info_created_time
-- from maoer.sound_info
-- ) as f on a.subject_id=f.sound_id
-- group by a.subject_id
-- )

-- 更新字段值
-- update sound_feature t1
-- join sound_review_feature t2 on t1.sound_id=t2.subject_id
-- SET
-- t1.sound_review_avg_len = t2.review_len_avg,
-- t1.sound_review_max_len = t2.review_len_max,
-- t1.sound_review_min_len = t2.review_len_min,
-- t1.sound_review_avg_like_num = t2.review_like_avg,
-- t1.sound_review_max_like_num = t2.review_like_max,
-- t1.sound_review_min_like_num = t2.review_like_min,
-- t1.sound_review_submit_time_between_submit_sound_time_max = t2.review_create_time_max,
-- t1.sound_review_submit_time_between_submit_sound_time_min = t2.review_create_time_min,
-- t1.sound_review_submit_time_between_submit_sound_time_avg = t2.review_create_time_avg,
-- t1.sound_review_submit_time_between_submit_sound_time_in_7days_num = t2.review_submit_time_between_submit_sound_time_in_7days_num,
-- t1.sound_review_submit_time_between_submit_sound_time_in_14days_num = t2.review_submit_time_between_submit_sound_time_in_14days_num,
-- t1.sound_review_submit_time_between_submit_sound_time_in_30days_num = t2.review_submit_time_between_submit_sound_time_in_30days_num



-- 构建sound_danmu_feature
-- select a.sound_id,avg(LENGTH(a.danmu_info_text)) as danmu_len_avg,max(LENGTH(a.danmu_info_text)) as danmu_len_max,min(LENGTH(a.danmu_info_text)) as danmu_len_min,
-- max(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_max,
-- min(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_min,
-- avg(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_avg,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>7 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_7days_num,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>14 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_14days_num,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>30 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_30days_num
-- from (
-- select distinct e.danmu_id,e.sound_id,e.danmu_info_text,e.danmu_info_date
-- from maoer.danmu_info as e) as a
-- join (select distinct sound_id,sound_info_created_time
-- from maoer.sound_info
-- ) as f on a.sound_id=f.sound_id
-- group by a.sound_id

-- alter table sound_danmu_feature
-- add COLUMN danmu_submit_time_between_submit_sound_time_max int,
-- add COLUMN danmu_submit_time_between_submit_sound_time_min int,
-- add COLUMN danmu_submit_time_between_submit_sound_time_avg double

-- -- 更新字段值
-- update sound_feature t1
-- join sound_danmu_feature t2 on t1.sound_id=t2.sound_id
-- SET
-- t1.sound_danmu_avg_len = t2.danmu_len_avg,
-- t1.sound_danmu_max_len = t2.danmu_len_max,
-- t1.sound_danmu_min_len = t2.danmu_len_min,
-- t1.sound_danmu_submit_time_between_submit_sound_time_max = t2.danmu_create_time_max,
-- t1.sound_danmu_submit_time_between_submit_sound_time_min = t2.danmu_create_time_min,
-- t1.sound_danmu_submit_time_between_submit_sound_time_avg = t2.danmu_create_time_avg,
-- t1.sound_danmu_submit_time_between_submit_sound_time_in_7days_num = t2.danmu_submit_time_between_submit_sound_time_in_7days_num,
-- t1.sound_danmu_submit_time_between_submit_sound_time_in_14days_num = t2.danmu_submit_time_between_submit_sound_time_in_14days_num,
-- t1.sound_danmu_submit_time_between_submit_sound_time_in_30days_num = t2.danmu_submit_time_between_submit_sound_time_in_30days_num

-- update sound_danmu_feature t1 join sound_feature t2
-- on t1.sound_id=t2.sound_id
-- SET
-- t1.danmu_submit_time_between_submit_sound_time_max = t2.sound_danmu_submit_time_between_submit_sound_time_max,
-- t1.danmu_submit_time_between_submit_sound_time_min = t2.sound_danmu_submit_time_between_submit_sound_time_min,
-- t1.danmu_submit_time_between_submit_sound_time_avg = t2.sound_danmu_submit_time_between_submit_sound_time_avg

-- 构建sound_cv_feature
-- create table sound_cv_feature as(
-- select c.sound_id,count(c.cast_id) as total_cv_num,sum(case when c.user_id is not null then 1 else 0 end) as cv_has_userid_num,sum(a.user_info_fans_num) as cv_total_fans_num, max(a.user_info_fans_num) as cv_max_fans_num ,min(a.user_info_fans_num) as cv_min_fans_num,avg(a.user_info_fans_num) as cv_avg_fans_num,
-- sum(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_total_num,max(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_max_num,min(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_min_num,avg(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_avg_num,
-- sum(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_total_num,max(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_max_num,min(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_min_num,avg(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_avg_num
-- from maoer.user_info as a
-- right join (
-- select e.sound_id,b.cast_id,b.user_id,e.cast_drama_character_main
-- from maoer.cast_drama as e
-- join (
-- select f.cast_id,f.user_id from maoer.cast_info as f
-- )as b on e.cast_id=b.cast_id
-- ) as c on a.user_id=c.user_id
-- group by c.sound_id
-- )

-- 更新字段值
-- update sound_feature t1
-- join sound_cv_feature t2 on t1.sound_id=t2.sound_id
-- SET
-- t1.sound_cv_total_num = t2.total_cv_num,
-- t1.sound_cv_has_userid_num = t2.cv_has_userid_num,
-- t1.sound_cv_total_fans_num = t2.cv_total_fans_num,
-- t1.sound_cv_max_fans_num = t2.cv_max_fans_num,
-- t1.sound_cv_min_fans_num = t2.cv_min_fans_num,
-- t1.sound_cv_avg_fans_num = t2.cv_avg_fans_num,
-- t1.sound_cv_main_cv_total_fans_num = t2.cv_main_character_total_num,
-- t1.sound_cv_main_cv_max_fans_num = t2.cv_main_character_max_num,
-- t1.sound_cv_main_cv_min_fans_num = t2.cv_main_character_min_num,
-- t1.sound_cv_main_cv_avg_fans_num = t2.cv_main_character_avg_num,
-- t1.sound_cv_auxiliary_cv_max_fans_num = t2.cv_aux_character_max_num,
-- t1.sound_cv_auxiliary_cv_min_fans_num = t2.cv_aux_character_min_num,
-- t1.sound_cv_auxiliary_cv_avg_fans_num = t2.cv_aux_character_avg_num


-- 构建sound_tag_feature
-- create table sound_tag_feature as(
-- select x.sound_id,x.tag_total_cite_num,x.tag_max_cite_num,x.tag_min_cite_num,x.tag_avg_cite_num,z.tag_has_cv_name_num,
-- z.tag_has_cv_name_total_cite_num,z.tag_has_cv_name_max_cite_num,
-- z.tag_has_cv_name_min_cite_num,z.tag_has_cv_name_avg_cite_num
-- from(
-- select a.sound_id,sum(b.tag_count) as tag_total_cite_num,max(b.tag_count) as tag_max_cite_num,min(b.tag_count) as tag_min_cite_num,avg(b.tag_count) as tag_avg_cite_num
-- from maoer.sound_tags as a
-- join (
-- select e.tag_id,e.tag_name,count(distinct e.sound_id) as tag_count
-- from maoer.sound_tags as e
-- group by e.tag_id
-- ) as b on a.tag_id=b.tag_id
-- group by a.sound_id
-- ) as x
-- left join (
-- select a.sound_id,count(a.tag_id) as tag_has_cv_name_num,
-- sum(b.tag_count) as tag_has_cv_name_total_cite_num,
-- max(b.tag_count) as tag_has_cv_name_max_cite_num,
-- min(b.tag_count) as tag_has_cv_name_min_cite_num,
-- avg(b.tag_count) as tag_has_cv_name_avg_cite_num
-- from maoer.sound_tags as a
-- join (
-- select e.tag_id,e.tag_name,count(distinct e.sound_id) as tag_count
-- from maoer.sound_tags as e
-- where e.tag_name in (select cast_info_name from maoer.cast_info)
-- group by e.tag_id,e.tag_name
-- ) as b on a.tag_id=b.tag_id
-- group by a.sound_id
-- )as z  on x.sound_id=z.sound_id
-- )

-- 更新字段值
-- update sound_feature t1
-- join sound_tag_feature t2 on t1.sound_id=t2.sound_id
-- SET
-- t1.sound_tag_total_cite_num = t2.tag_total_cite_num,
-- t1.sound_tag_max_cite_num = t2.tag_max_cite_num,
-- t1.sound_tag_min_cite_num = t2.tag_min_cite_num,
-- t1.sound_tag_avg_cite_num = t2.tag_avg_cite_num,
-- t1.sound_tag_has_cv_name_num = t2.tag_has_cv_name_num,
-- t1.sound_tag_has_cv_name_total_cite_num = t2.tag_has_cv_name_total_cite_num,
-- t1.sound_tag_has_cv_name_max_cite_num = t2.tag_has_cv_name_max_cite_num,
-- t1.sound_tag_has_cv_name_min_cite_num = t2.tag_has_cv_name_min_cite_num,
-- t1.sound_tag_has_cv_name_avg_cite_num = t2.tag_has_cv_name_avg_cite_num


-- ——————————产品-剧集特征提取部分(用activeuser-with-danmu-sound-drama)—————

-- 特征提取建表 drama_feature
-- create table drama_feature as
-- select distinct drama_id
-- from activeuser_drama_info

-- ALTER TABLE drama_feature
-- ADD COLUMN drama_name_len INT ,
-- ADD COLUMN drama_intro_len INT ,
-- ADD COLUMN drama_has_author INT ,
-- ADD COLUMN drama_is_serialize INT ,
-- ADD COLUMN drama_total_sound_num INT ,
-- ADD COLUMN drama_total_view_num INT ,
-- ADD COLUMN drama_type INT ,
-- ADD COLUMN drama_tag_num INT ,
-- ADD COLUMN drama_pay_type INT ,
-- ADD COLUMN drama_total_pay_money INT ,
-- ADD COLUMN drama_pay_sound_percent DOUBLE,
-- ADD COLUMN drama_cv_total_num INT ,
-- ADD COLUMN drama_cv_total_fans_num INT ,
-- ADD COLUMN drama_cv_max_fans_num INT ,
-- ADD COLUMN drama_cv_min_fans_num INT ,
-- ADD COLUMN drama_cv_avg_fans_num DOUBLE,
-- ADD COLUMN drama_cv_main_total_fans_num INT ,
-- ADD COLUMN drama_cv_main_max_fans_num INT ,
-- ADD COLUMN drama_cv_main_min_fans_num INT ,
-- ADD COLUMN drama_cv_main_avg_fans_num DOUBLE,
-- ADD COLUMN drama_cv_aux_max_fans_num INT ,
-- ADD COLUMN drama_cv_aux_min_fans_num INT ,
-- ADD COLUMN drama_cv_aux_avg_fans_num DOUBLE,
-- ADD COLUMN drama_sound_cv_max_num INT ,
-- ADD COLUMN drama_sound_cv_min_num INT ,
-- ADD COLUMN drama_sound_cv_avg_num DOUBLE,
-- ADD COLUMN drama_sound_has_max_cv_num_sound_view_num INT ,
-- ADD COLUMN drama_sound_has_max_cv_num_sound_danmu_num INT ,
-- ADD COLUMN drama_sound_has_max_cv_num_sound_favorite_num INT ,
-- ADD COLUMN drama_sound_has_max_cv_num_sound_point_num INT ,
-- ADD COLUMN drama_sound_has_max_cv_num_sound_review_num INT ,
-- ADD COLUMN drama_sound_has_min_cv_num_sound_view_num INT ,
-- ADD COLUMN drama_sound_has_min_cv_num_sound_danmu_num INT ,
-- ADD COLUMN drama_sound_has_min_cv_num_sound_favorite_num INT ,
-- ADD COLUMN drama_sound_has_min_cv_num_sound_point_num INT ,
-- ADD COLUMN drama_sound_has_min_cv_num_sound_review_num INT ,
-- ADD COLUMN drama_total_danmu_num INT ,
-- ADD COLUMN drama_max_danmu_num INT ,
-- ADD COLUMN drama_min_danmu_num INT ,
-- ADD COLUMN drama_avg_danmu_num DOUBLE,
-- ADD COLUMN drama_total_favorite_num INT ,
-- ADD COLUMN drama_max_favorite_num INT ,
-- ADD COLUMN drama_min_favorite_num INT ,
-- ADD COLUMN drama_avg_favorite_num DOUBLE,
-- ADD COLUMN drama_total_point_num INT ,
-- ADD COLUMN drama_max_point_num INT ,
-- ADD COLUMN drama_min_point_num INT ,
-- ADD COLUMN drama_avg_point_num DOUBLE,
-- ADD COLUMN drama_total_review_num INT ,
-- ADD COLUMN drama_max_review_num INT ,
-- ADD COLUMN drama_min_review_num INT ,
-- ADD COLUMN drama_avg_review_num DOUBLE,
-- ADD COLUMN drama_sound_has_max_view_num_sound_danmu_num INT ,
-- ADD COLUMN drama_sound_has_max_view_num_sound_favorite_num INT ,
-- ADD COLUMN drama_sound_has_max_view_num_sound_point_num INT ,
-- ADD COLUMN drama_sound_has_max_view_num_sound_review_num INT ,
-- ADD COLUMN drama_sound_has_max_view_num_sound_cv_num INT ,
-- ADD COLUMN drama_sound_has_max_view_num_sound_cv_total_fans_num INT ,
-- ADD COLUMN drama_sound_has_max_view_num_sound_is_pay INT ,
-- ADD COLUMN drama_sound_has_min_view_num_sound_danmu_num INT ,
-- ADD COLUMN drama_sound_has_min_view_num_sound_favorite_num INT ,
-- ADD COLUMN drama_sound_has_min_view_num_sound_point_num INT ,
-- ADD COLUMN drama_sound_has_min_view_num_sound_review_num INT ,
-- ADD COLUMN drama_sound_has_min_view_num_sound_cv_num INT ,
-- ADD COLUMN drama_sound_has_min_view_num_sound_cv_total_fans_num INT ,
-- ADD COLUMN drama_sound_has_min_view_num_sound_is_pay INT ,
-- ADD COLUMN drama_reward_max_week_rank int,
-- ADD COLUMN drama_reward_max_month_rank int,
-- ADD COLUMN drama_reward_max_total_rank int,
-- ADD COLUMN drama_fans_reward_total_fans_num int,
-- ADD COLUMN drama_fans_reward_week_ranking_fans_num int,
-- ADD COLUMN drama_fans_reward_month_ranking_fans_num int,
-- ADD COLUMN drama_fans_reward_total_ranking_fans_num int,
-- ADD COLUMN drama_fans_reward_week_ranking_total_coin int,
-- ADD COLUMN drama_fans_reward_month_ranking_total_coin int,
-- ADD COLUMN drama_fans_reward_total_ranking_total_coin int,
-- ADD COLUMN drama_fans_reward_week_ranking_max_coin int,
-- ADD COLUMN drama_fans_reward_month_ranking_max_coin int,
-- ADD COLUMN drama_fans_reward_total_ranking_max_coin int,
-- ADD COLUMN drama_fans_reward_week_ranking_min_coin int,
-- ADD COLUMN drama_fans_reward_month_ranking_min_coin int,
-- ADD COLUMN drama_fans_reward_total_ranking_min_coin int,
-- ADD COLUMN drama_fans_reward_week_ranking_avg_coin double,
-- ADD COLUMN drama_fans_reward_month_ranking_avg_coin double,
-- ADD COLUMN drama_fans_reward_total_ranking_avg_coin double,
-- ADD COLUMN drama_fans_create_time_between_submit_drama_time_max int,
-- ADD COLUMN drama_fans_create_time_between_submit_drama_time_min int,
-- ADD COLUMN drama_fans_create_time_between_submit_drama_time_avg double,
-- ADD COLUMN drama_fans_create_time_between_latest_drama_time_max int,
-- ADD COLUMN drama_fans_create_time_between_latest_drama_time_min int,
-- ADD COLUMN drama_fans_create_time_between_latest_drama_time_avg double,
-- ADD COLUMN drama_fans_month_create_time_between_submit_drama_time_max int,
-- ADD COLUMN drama_fans_month_create_time_between_submit_drama_time_min int,
-- ADD COLUMN drama_fans_month_create_time_between_submit_drama_time_avg double,
-- ADD COLUMN drama_fans_month_create_time_between_latest_drama_time_max int,
-- ADD COLUMN drama_fans_month_create_time_between_latest_drama_time_min int,
-- ADD COLUMN drama_fans_month_create_time_between_latest_drama_time_avg double,
-- ADD COLUMN drama_fans_total_create_time_between_submit_drama_time_max int,
-- ADD COLUMN drama_fans_total_create_time_between_submit_drama_time_min int,
-- ADD COLUMN drama_fans_total_create_time_between_submit_drama_time_avg double,
-- ADD COLUMN drama_fans_total_create_time_between_latest_drama_time_max int,
-- ADD COLUMN drama_fans_total_create_time_between_latest_drama_time_min int,
-- ADD COLUMN drama_fans_total_create_time_between_latest_drama_time_avg double,
-- ADD COLUMN drama_upuser_grade int,
-- ADD COLUMN drama_upuser_fish_num int,
-- ADD COLUMN drama_upuser_fans_num int,
-- ADD COLUMN drama_upuser_follower_num int,
-- ADD COLUMN drama_upuser_submit_sound_num int,
-- ADD COLUMN drama_upuser_submit_drama_num int,
-- ADD COLUMN drama_upuser_subscriptions_num int,
-- ADD COLUMN drama_upuser_channel_num int,
-- ADD COLUMN drama_upuser_submit_sound_total_view_num double,
-- ADD COLUMN drama_upuser_submit_sound_max_view_num int,
-- ADD COLUMN drama_upuser_submit_sound_min_view_num int,
-- ADD COLUMN drama_upuser_submit_sound_avg_view_num double,
-- ADD COLUMN drama_upuser_submit_sound_total_danmu_num double,
-- ADD COLUMN drama_upuser_submit_sound_max_danmu_num int,
-- ADD COLUMN drama_upuser_submit_sound_min_danmu_num int,
-- ADD COLUMN drama_upuser_submit_sound_avg_danmu_num double,
-- ADD COLUMN drama_upuser_submit_sound_total_review_num double,
-- ADD COLUMN drama_upuser_submit_sound_max_review_num int,
-- ADD COLUMN drama_upuser_submit_sound_min_review_num int,
-- ADD COLUMN drama_upuser_submit_sound_avg_review_num double,
-- ADD COLUMN drama_upuser_submit_sound_max_pay_type int,
-- ADD COLUMN drama_upuser_submit_sound_pay_sound_percent double,
-- ADD COLUMN drama_upuser_submit_drama_has_fans_reward int,
-- ADD COLUMN drama_upuser_submit_drama_has_reward_week_ranking int,
-- ADD COLUMN drama_upuser_submit_drama_has_reward_month_ranking int,
-- ADD COLUMN drama_upuser_submit_drama_has_reward_total_ranking int,
-- ADD COLUMN drama_upuser_submit_drama_reward_week_max_rank int,
-- ADD COLUMN drama_upuser_submit_drama_reward_month_max_rank int,
-- ADD COLUMN drama_upuser_submit_drama_reward_total_max_rank int,
-- ADD COLUMN drama_sound_total_time bigint,
-- ADD COLUMN drama_sound_max_time int,
-- ADD COLUMN drama_sound_min_time int,
-- ADD COLUMN drama_sound_avg_time double,
-- ADD COLUMN drama_sound_max_time_sound_view_num int,
-- ADD COLUMN drama_sound_min_time_sound_view_num int,
-- ADD COLUMN drama_sound_max_time_sound_danmu_num int,
-- ADD COLUMN drama_sound_min_time_sound_danmu_num int,
-- ADD COLUMN drama_sound_max_time_sound_review_num int,
-- ADD COLUMN drama_sound_min_time_sound_review_num int,
-- ADD COLUMN drama_sound_danmu_15s_max_traffic double,
-- ADD COLUMN drama_sound_danmu_15s_min_traffic double,
-- ADD COLUMN drama_sound_danmu_15s_avg_traffic double,
-- ADD COLUMN drama_sound_max_traffic_position_in_sound_avg double,
-- ADD COLUMN drama_sound_min_traffic_position_in_sound_avg double,
-- ADD COLUMN drama_danmu_avg_len  double,
-- ADD COLUMN drama_danmu_max_len int,
-- ADD COLUMN drama_danmu_min_len int,
-- ADD COLUMN drama_danmu_positive_num int,
-- ADD COLUMN drama_danmu_negtive_num int,
-- ADD COLUMN drama_danmu_submit_time_between_submit_sound_time_max int,
-- ADD COLUMN drama_danmu_submit_time_between_submit_sound_time_min int,
-- ADD COLUMN drama_danmu_submit_time_between_submit_sound_time_avg double,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_7days_num_max int,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_7days_num_min int,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_7days_num_avg double,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_14days_num_max int,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_14days_num_min int,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_14days_num_avg double,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_30days_num_max int,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_30days_num_min int,
-- ADD COLUMN drama_danmu_time_between_sound_time_in_30days_num_avg double,
-- ADD COLUMN drama_sound_tag_total_cite_num int,
-- ADD COLUMN drama_sound_tag_max_cite_num int,
-- ADD COLUMN drama_sound_tag_min_cite_num int,
-- ADD COLUMN drama_sound_tag_avg_cite_num double,
-- ADD COLUMN drama_sound_tag_has_cv_name_num int,
-- ADD COLUMN drama_sound_tag_has_cv_name_total_cite_num int,
-- ADD COLUMN drama_sound_tag_has_cv_name_max_cite_num int,
-- ADD COLUMN drama_sound_tag_has_cv_name_min_cite_num int,
-- ADD COLUMN drama_sound_tag_has_cv_name_avg_cite_num double


-- drama_feature_basic
-- select a.drama_id,LENGTH(a.drama_info_name) as drama_name_len,
-- 		LENGTH(a.drama_info_abstract) as drama_intro_len,
-- 		(CASE WHEN (a.drama_info_author is not null and a.drama_info_author!='') then 1 else 0 end) as drama_has_author,
-- 		b.drama_info_serialize as drama_is_serialize,
-- 		a.drama_info_type as drama_type,
-- 		b.drama_info_pay_type as drama_pay_type,
-- 		b.drama_info_price as drama_total_pay_money
-- 		from maoer.drama_info as a
-- 		left join (
-- 		SELECT di.*
-- 		FROM maoer.drama_info_update di
-- 		JOIN (
-- 				SELECT drama_id, MAX(created_time) AS max_created_time
-- 				FROM maoer.drama_info_update
-- 				GROUP BY drama_id
-- 		) AS sub
-- 		ON di.drama_id = sub.drama_id AND di.created_time = sub.max_created_time
-- 		) as b on a.drama_id=b.drama_id

-- select a.drama_id,count(distinct a.sound_id) as drama_total_sound_num,
-- sum(b.sound_info_view_count)as drama_total_view_num,
-- avg(case when (c.sound_info_pay_type=1 or c.sound_info_pay_type=2) then 1 else 0 end) as drama_pay_sound_percent
-- from maoer.drama_episodes as a
-- left join(
-- 	select sound_id,sound_info_view_count
-- 	from maoer.sound_info_update
-- )as b on a.sound_id=b.sound_id
-- left join (
-- 	select sound_id,sound_info_pay_type
-- 	from maoer.sound_info
-- )as c on a.sound_id=c.sound_id
-- group by a.drama_id

-- UPDATE drama_feature t1
-- join (
-- 		select a.drama_id,LENGTH(a.drama_info_name) as drama_name_len,
-- 		LENGTH(a.drama_info_abstract) as drama_intro_len,
-- 		(CASE WHEN (a.drama_info_author is not null and a.drama_info_author!='') then 1 else 0 end) as drama_has_author,
-- 		b.drama_info_serialize as drama_is_serialize,
-- 		a.drama_info_type as drama_type,
-- 		b.drama_info_pay_type as drama_pay_type,
-- 		b.drama_info_price as drama_total_pay_money
-- 		from maoer.drama_info as a
-- 		left join (
-- 		SELECT di.*
-- 		FROM maoer.drama_info_update di
-- 		JOIN (
-- 				SELECT drama_id, MAX(created_time) AS max_created_time
-- 				FROM maoer.drama_info_update
-- 				GROUP BY drama_id
-- 		) AS sub
-- 		ON di.drama_id = sub.drama_id AND di.created_time = sub.max_created_time
-- 		) as b on a.drama_id=b.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_name_len = t2.drama_name_len,
-- t1.drama_intro_len = t2.drama_intro_len,
-- t1.drama_has_author = t2.drama_has_author,
-- t1.drama_is_serialize = t2.drama_is_serialize,
-- t1.drama_type = t2.drama_type,
-- -- t1.drama_tag_num = t2.drama_tag_num,
-- t1.drama_pay_type = t2.drama_pay_type,
-- t1.drama_total_pay_money = t2.drama_total_pay_money

-- UPDATE drama_feature t1
-- join (
-- 		select a.drama_id,count(distinct a.sound_id) as drama_total_sound_num,
-- 		sum(b.sound_info_view_count)as drama_total_view_num,
-- 		avg(case when (c.sound_info_pay_type=1 or c.sound_info_pay_type=2) then 1 else 0 end) as drama_pay_sound_percent
-- 		from maoer.drama_episodes as a
-- 		left join(
-- 			select sound_id,sound_info_view_count
-- 			from maoer.sound_info_update
-- 		)as b on a.sound_id=b.sound_id
-- 		left join (
-- 			select sound_id,sound_info_pay_type
-- 			from maoer.sound_info
-- 		)as c on a.sound_id=c.sound_id
-- 		group by a.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_total_sound_num = t2.drama_total_sound_num,
-- t1.drama_total_view_num = t2.drama_total_view_num/10000
-- t1.drama_pay_sound_percent = t2.drama_pay_sound_percent

-- UPDATE drama_feature t1
-- join (select drama_id,count(distinct tag_id) as drama_tag_num
-- from maoer.drama_tags
-- group by drama_id
-- )t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_tag_num = t2.drama_tag_num


-- 剧集CV drama_cv_feature
-- create table drama_cv_info_feature as(
-- select c.drama_id,count(c.cast_id) as total_cv_num,sum(case when c.user_id is not null then 1 else 0 end) as cv_has_userid_num,sum(a.user_info_fans_num) as cv_total_fans_num, max(a.user_info_fans_num) as cv_max_fans_num ,min(a.user_info_fans_num) as cv_min_fans_num,avg(a.user_info_fans_num) as cv_avg_fans_num,
-- sum(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_total_num,max(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_max_num,min(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_min_num,avg(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_avg_num,
-- sum(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_total_num,max(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_max_num,min(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_min_num,avg(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_avg_num
-- from maoer.user_info as a
-- right join (
-- select e.drama_id,b.cast_id,b.user_id,e.cast_drama_character_main
-- from maoer.cast_drama as e
-- join (
-- select f.cast_id,f.user_id from maoer.cast_info as f
-- )as b on e.cast_id=b.cast_id
-- ) as c on a.user_id=c.user_id
-- group by c.drama_id
-- )

-- create table drama_cv_sound_feature as (
-- select a.drama_id,
-- max(b.total_cv_num) as drama_sound_cv_max_num,
-- min(b.total_cv_num) as drama_sound_cv_min_num,
-- avg(b.total_cv_num) as drama_sound_cv_avg_num,
-- SUM(CASE WHEN b.total_cv_num = d.max_total_cv_num THEN c.sound_info_view_count ELSE 0 END) as drama_sound_has_max_cv_num_sound_view_num,
-- SUM(CASE WHEN b.total_cv_num = d.max_total_cv_num THEN c.sound_info_danmu_count ELSE 0 END) as drama_sound_has_max_cv_num_sound_danmu_num,
-- SUM(CASE WHEN b.total_cv_num = d.max_total_cv_num THEN c.sound_info_favorite_count ELSE 0 END) as drama_sound_has_max_cv_num_sound_favorite_num,
-- SUM(CASE WHEN b.total_cv_num = d.max_total_cv_num THEN c.sound_info_point ELSE 0 END) as drama_sound_has_max_cv_num_sound_point_num,
-- SUM(CASE WHEN b.total_cv_num = d.max_total_cv_num THEN c.sound_info_all_reviews_num ELSE 0 END) as drama_sound_has_max_cv_num_sound_review_num,
-- SUM(CASE WHEN b.total_cv_num = d.min_total_cv_num THEN c.sound_info_view_count ELSE 0 END) as drama_sound_has_min_cv_num_sound_view_num,
-- SUM(CASE WHEN b.total_cv_num = d.min_total_cv_num THEN c.sound_info_danmu_count ELSE 0 END) as drama_sound_has_min_cv_num_sound_danmu_num,
-- SUM(CASE WHEN b.total_cv_num = d.min_total_cv_num THEN c.sound_info_favorite_count ELSE 0 END) as drama_sound_has_min_cv_num_sound_favorite_num,
-- SUM(CASE WHEN b.total_cv_num = d.min_total_cv_num THEN c.sound_info_point ELSE 0 END) as drama_sound_has_min_cv_num_sound_point_num,
-- SUM(CASE WHEN b.total_cv_num = d.min_total_cv_num THEN c.sound_info_all_reviews_num ELSE 0 END) as drama_sound_has_min_cv_num_sound_review_num
-- from maoer.drama_episodes as a
-- left join(
--  select sound_id,total_cv_num,cv_total_fans_num
--  from sound_cv_feature
-- )as b on a.sound_id=b.sound_id
-- left join (
-- 	SELECT di.sound_id,di.sound_info_view_count,di.sound_info_danmu_count,di.sound_info_favorite_count,di.sound_info_point,di.sound_info_all_reviews_num
-- 		FROM maoer.sound_info_update di
-- 		JOIN (
-- 				SELECT sound_id, MAX(created_time) AS max_created_time
-- 				FROM maoer.sound_info_update
-- 				GROUP BY sound_id
-- 		) AS sub
-- 		ON di.sound_id = sub.sound_id AND di.created_time = sub.max_created_time
-- ) as c on a.sound_id=c.sound_id
-- left join(
-- 	SELECT a.drama_id,
--        MAX(b.total_cv_num) AS max_total_cv_num,
--        MIN(b.total_cv_num) AS min_total_cv_num
-- 	FROM maoer.drama_episodes AS a
-- 	JOIN sound_cv_feature AS b ON a.sound_id = b.sound_id
-- 	GROUP BY a.drama_id
-- )as d on a.drama_id=d.drama_id
-- group by a.drama_id
-- )


-- update drama_feature t1 join drama_sound_feature t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_sound_cv_max_num = t2.drama_sound_cv_max_num,
-- t1.drama_sound_cv_min_num = t2.drama_sound_cv_min_num,
-- t1.drama_sound_cv_avg_num = t2.drama_sound_cv_avg_num

-- UPDATE drama_feature t1
-- join drama_cv_info_feature t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_cv_total_num = t2.total_cv_num,
-- t1.drama_cv_total_fans_num = t2.cv_total_fans_num,
-- t1.drama_cv_max_fans_num = t2.cv_max_fans_num,
-- t1.drama_cv_min_fans_num = t2.cv_min_fans_num,
-- t1.drama_cv_avg_fans_num = t2.cv_avg_fans_num,
-- t1.drama_cv_main_total_fans_num = t2.cv_main_character_total_num,
-- t1.drama_cv_main_max_fans_num = t2.cv_main_character_max_num,
-- t1.drama_cv_main_min_fans_num = t2.cv_main_character_min_num,
-- t1.drama_cv_main_avg_fans_num = t2.cv_main_character_avg_num,
-- t1.drama_cv_aux_max_fans_num = t2.cv_aux_character_max_num,
-- t1.drama_cv_aux_min_fans_num = t2.cv_aux_character_min_num,
-- t1.drama_cv_aux_avg_fans_num = t2.cv_aux_character_avg_num

-- UPDATE drama_feature t1
-- join drama_cv_sound_feature t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_sound_has_max_cv_num_sound_view_num = t2.drama_sound_has_max_cv_num_sound_view_num,
-- t1.drama_sound_has_max_cv_num_sound_danmu_num = t2.drama_sound_has_max_cv_num_sound_danmu_num,
-- t1.drama_sound_has_max_cv_num_sound_favorite_num = t2.drama_sound_has_max_cv_num_sound_favorite_num,
-- t1.drama_sound_has_max_cv_num_sound_point_num = t2.drama_sound_has_max_cv_num_sound_point_num,
-- t1.drama_sound_has_max_cv_num_sound_review_num = t2.drama_sound_has_max_cv_num_sound_review_num,
-- t1.drama_sound_has_min_cv_num_sound_view_num = t2.drama_sound_has_min_cv_num_sound_view_num,
-- t1.drama_sound_has_min_cv_num_sound_danmu_num = t2.drama_sound_has_min_cv_num_sound_danmu_num,
-- t1.drama_sound_has_min_cv_num_sound_favorite_num = t2.drama_sound_has_min_cv_num_sound_favorite_num,
-- t1.drama_sound_has_min_cv_num_sound_point_num = t2.drama_sound_has_min_cv_num_sound_point_num,
-- t1.drama_sound_has_min_cv_num_sound_review_num = t2.drama_sound_has_min_cv_num_sound_review_num


-- 剧集声音 drama_sound_info_feature
-- select a.drama_id,
-- sum(b.sound_danmu_num) as drama_total_danmu_num,
-- max(b.sound_danmu_num) as drama_max_danmu_num,
-- min(b.sound_danmu_num) as drama_min_danmu_num,
-- avg(b.sound_danmu_num) as drama_avg_danmu_num,
-- sum(b.sound_favorite_num) as drama_total_favorite_num,
-- max(b.sound_favorite_num) as drama_max_favorite_num,
-- min(b.sound_favorite_num) as drama_min_favorite_num,
-- avg(b.sound_favorite_num) as drama_avg_favorite_num,
-- sum(b.sound_point_num) as drama_total_point_num,
-- max(b.sound_point_num) as drama_max_point_num,
-- min(b.sound_point_num) as drama_min_point_num,
-- avg(b.sound_point_num) as drama_avg_point_num,
-- sum(b.sound_review_not_subreview_num + b.sound_review_subreview_num) as drama_total_review_num,
-- max(b.sound_review_not_subreview_num + b.sound_review_subreview_num) as drama_max_review_num,
-- min(b.sound_review_not_subreview_num + b.sound_review_subreview_num) as drama_min_review_num,
-- avg(b.sound_review_not_subreview_num + b.sound_review_subreview_num) as drama_avg_review_num
-- from maoer.drama_episodes as a
-- join sound_feature as b on a.sound_id=b.sound_id
-- group by a.drama_id

-- create table drama_sound_feature as (
-- select a.drama_id,
-- SUM(CASE WHEN b.sound_view_num = d.max_sound_view_num THEN b.sound_danmu_num ELSE 0 END) as drama_sound_has_max_view_num_sound_danmu_num,
-- SUM(CASE WHEN b.sound_view_num = d.max_sound_view_num THEN b.sound_favorite_num ELSE 0 END) as drama_sound_has_max_view_num_sound_favorite_num,
-- SUM(CASE WHEN b.sound_view_num = d.max_sound_view_num THEN b.sound_point_num ELSE 0 END) as drama_sound_has_max_view_num_sound_point_num,
-- SUM(CASE WHEN b.sound_view_num = d.max_sound_view_num THEN b.sound_review_not_subreview_num+b.sound_review_subreview_num ELSE 0 END) as drama_sound_has_max_view_num_sound_review_num,
-- SUM(CASE WHEN b.sound_view_num = d.max_sound_view_num THEN b.sound_cv_total_num ELSE 0 END) as drama_sound_has_max_view_num_sound_cv_num,
-- SUM(CASE WHEN b.sound_view_num = d.max_sound_view_num THEN b.sound_cv_total_fans_num ELSE 0 END) as drama_sound_has_max_view_num_sound_cv_total_fans_num,
-- SUM(CASE WHEN b.sound_view_num = d.max_sound_view_num THEN b.sound_pay_type ELSE 0 END) as drama_sound_has_max_view_num_sound_is_pay,
-- SUM(CASE WHEN b.sound_view_num = d.min_sound_view_num THEN b.sound_danmu_num ELSE 0 END) as drama_sound_has_min_view_num_sound_danmu_num,
-- SUM(CASE WHEN b.sound_view_num = d.min_sound_view_num THEN b.sound_favorite_num ELSE 0 END) as drama_sound_has_min_view_num_sound_favorite_num,
-- SUM(CASE WHEN b.sound_view_num = d.min_sound_view_num THEN b.sound_point_num ELSE 0 END) as drama_sound_has_min_view_num_sound_point_num,
-- SUM(CASE WHEN b.sound_view_num = d.min_sound_view_num THEN b.sound_review_not_subreview_num+b.sound_review_subreview_num ELSE 0 END) as drama_sound_has_min_view_num_sound_review_num,
-- SUM(CASE WHEN b.sound_view_num = d.min_sound_view_num THEN b.sound_cv_total_num ELSE 0 END) as drama_sound_has_min_view_num_sound_cv_num,
-- SUM(CASE WHEN b.sound_view_num = d.min_sound_view_num THEN b.sound_cv_total_fans_num ELSE 0 END) as drama_sound_has_min_view_num_sound_cv_total_fans_num,
-- SUM(CASE WHEN b.sound_view_num = d.min_sound_view_num THEN b.sound_pay_type ELSE 0 END) as drama_sound_has_min_view_num_sound_is_pay
-- from maoer.drama_episodes as a
-- left join(
--  select sound_id,sound_view_num,sound_danmu_num,sound_favorite_num,sound_review_not_subreview_num,sound_review_subreview_num,sound_point_num,sound_cv_total_num,sound_cv_total_fans_num,sound_pay_type
--  from sound_feature
-- )as b on a.sound_id=b.sound_id
-- left join(
-- 	SELECT a.drama_id,
--        MAX(b.sound_view_num) AS max_sound_view_num,
--        MIN(b.sound_view_num) AS min_sound_view_num
-- 	FROM maoer.drama_episodes AS a
-- 	JOIN sound_feature AS b ON a.sound_id = b.sound_id
-- 	GROUP BY a.drama_id
-- )as d on a.drama_id=d.drama_id
-- group by a.drama_id
-- )

-- UPDATE drama_feature t1
-- join (
-- select a.drama_id,
-- sum(b.sound_danmu_num) as drama_total_danmu_num,
-- max(b.sound_danmu_num) as drama_max_danmu_num,
-- min(b.sound_danmu_num) as drama_min_danmu_num,
-- avg(b.sound_danmu_num) as drama_avg_danmu_num,
-- sum(b.sound_favorite_num) as drama_total_favorite_num,
-- max(b.sound_favorite_num) as drama_max_favorite_num,
-- min(b.sound_favorite_num) as drama_min_favorite_num,
-- avg(b.sound_favorite_num) as drama_avg_favorite_num,
-- sum(b.sound_point_num) as drama_total_point_num,
-- max(b.sound_point_num) as drama_max_point_num,
-- min(b.sound_point_num) as drama_min_point_num,
-- avg(b.sound_point_num) as drama_avg_point_num,
-- sum(b.sound_review_not_subreview_num + b.sound_review_subreview_num) as drama_total_review_num,
-- max(b.sound_review_not_subreview_num + b.sound_review_subreview_num) as drama_max_review_num,
-- min(b.sound_review_not_subreview_num + b.sound_review_subreview_num) as drama_min_review_num,
-- avg(b.sound_review_not_subreview_num + b.sound_review_subreview_num) as drama_avg_review_num
-- from maoer.drama_episodes as a
-- join sound_feature as b on a.sound_id=b.sound_id
-- group by a.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_total_danmu_num = t2.drama_total_danmu_num,
-- t1.drama_max_danmu_num = t2.drama_max_danmu_num,
-- t1.drama_min_danmu_num = t2.drama_min_danmu_num,
-- t1.drama_avg_danmu_num = t2.drama_avg_danmu_num,
-- t1.drama_total_favorite_num = t2.drama_total_favorite_num,
-- t1.drama_max_favorite_num = t2.drama_max_favorite_num,
-- t1.drama_min_favorite_num = t2.drama_min_favorite_num,
-- t1.drama_avg_favorite_num = t2.drama_avg_favorite_num,
-- t1.drama_total_point_num = t2.drama_total_point_num ,
-- t1.drama_max_point_num = t2.drama_max_point_num,
-- t1.drama_min_point_num = t2.drama_min_point_num ,
-- t1.drama_avg_point_num = t2.drama_avg_point_num,
-- t1.drama_total_review_num = t2.drama_total_review_num,
-- t1.drama_max_review_num = t2.drama_max_review_num,
-- t1.drama_min_review_num = t2.drama_min_review_num,
-- t1.drama_avg_review_num = t2.drama_avg_review_num

-- UPDATE drama_feature t1
-- join drama_sound_feature t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_sound_has_max_view_num_sound_danmu_num = t2.drama_sound_has_max_view_num_sound_danmu_num,
-- t1.drama_sound_has_max_view_num_sound_favorite_num = t2.drama_sound_has_max_view_num_sound_favorite_num,
-- t1.drama_sound_has_max_view_num_sound_point_num = t2.drama_sound_has_max_view_num_sound_point_num,
-- t1.drama_sound_has_max_view_num_sound_review_num = t2.drama_sound_has_max_view_num_sound_review_num,
-- t1.drama_sound_has_max_view_num_sound_cv_num = t2.drama_sound_has_max_view_num_sound_cv_num,
-- t1.drama_sound_has_max_view_num_sound_cv_total_fans_num = t2.drama_sound_has_max_view_num_sound_cv_total_fans_num,
-- t1.drama_sound_has_max_view_num_sound_is_pay = t2.drama_sound_has_max_view_num_sound_is_pay,
-- t1.drama_sound_has_min_view_num_sound_danmu_num = t2.drama_sound_has_min_view_num_sound_danmu_num,
-- t1.drama_sound_has_min_view_num_sound_favorite_num = t2.drama_sound_has_min_view_num_sound_favorite_num,
-- t1.drama_sound_has_min_view_num_sound_point_num = t2.drama_sound_has_min_view_num_sound_point_num,
-- t1.drama_sound_has_min_view_num_sound_review_num = t2.drama_sound_has_min_view_num_sound_review_num,
-- t1.drama_sound_has_min_view_num_sound_cv_num = t2.drama_sound_has_min_view_num_sound_cv_num,
-- t1.drama_sound_has_min_view_num_sound_cv_total_fans_num = t2.drama_sound_has_min_view_num_sound_cv_total_fans_num,
-- t1.drama_sound_has_min_view_num_sound_is_pay = t2.drama_sound_has_min_view_num_sound_is_pay


-- 剧集打赏 drama_reward_feature
-- update drama_feature t1 join (
-- select drama_id,
-- max(case when drama_reward_type=1 then drama_reward_rank else 0 end) as drama_reward_max_week_rank,
-- max(case when drama_reward_type=2 then drama_reward_rank else 0 end)  as drama_reward_max_month_rank,
-- max(case when drama_reward_type=3 then drama_reward_rank else 0 end)  as drama_reward_max_total_rank
-- from maoer.drama_reward
-- group by drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_reward_max_week_rank = t2.drama_reward_max_week_rank,
-- t1.drama_reward_max_month_rank = t2.drama_reward_max_month_rank,
-- t1.drama_reward_max_total_rank = t2.drama_reward_max_total_rank

--  create table drama_fans_reward_feature as(
--  select a.drama_id,
--  b.drama_info_all_reward_num as drama_fans_reward_total_fans_num, -- count(distinct user_id) as drama_fans_reward_total_fans_num,
-- sum(case when c.drama_fans_reward_type=1 then 1 else 0 end) as drama_fans_reward_week_ranking_fans_num,
-- sum(case when c.drama_fans_reward_type=2 then 1 else 0 end) as drama_fans_reward_month_ranking_fans_num,
-- sum(case when c.drama_fans_reward_type=3 then 1 else 0 end) as drama_fans_reward_total_ranking_fans_num,
-- sum(case when c.drama_fans_reward_type=1 then c.drama_fans_reward_coin else 0 end) as drama_fans_reward_week_ranking_total_coin,
-- sum(case when c.drama_fans_reward_type=2 then c.drama_fans_reward_coin else 0 end) as drama_fans_reward_month_ranking_total_coin,
-- sum(case when c.drama_fans_reward_type=3 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_total_ranking_total_coin,
-- max(case when c.drama_fans_reward_type=1 then c.drama_fans_reward_coin else 0 end) as drama_fans_reward_week_ranking_max_coin,
-- max(case when c.drama_fans_reward_type=2 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_month_ranking_max_coin,
-- max(case when c.drama_fans_reward_type=3 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_total_ranking_max_coin,
-- min(case when c.drama_fans_reward_type=1 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_week_ranking_min_coin,
-- min(case when c.drama_fans_reward_type=2 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_month_ranking_min_coin,
-- min(case when c.drama_fans_reward_type=3 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_total_ranking_min_coin,
-- avg(case when c.drama_fans_reward_type=1 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_week_ranking_avg_coin,
-- avg(case when c.drama_fans_reward_type=2 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_month_ranking_avg_coin,
-- avg(case when c.drama_fans_reward_type=3 then c.drama_fans_reward_coin else 0 end)
--  as drama_fans_reward_total_ranking_avg_coin
--  from maoer.drama_fans_reward as a
--  JOIN (
-- 	select d.drama_id,c.drama_info_all_reward_num
-- 	from maoer.drama_info_update as c join (
-- 		  SELECT drama_id, MAX(created_time) AS max_created_time
-- 			FROM maoer.drama_info_update
-- 			GROUP BY drama_id
-- 			) d on c.drama_id=d.drama_id AND c.created_time = d.max_created_time
--  )	as b on a.drama_id=b.drama_id
--  join (
-- 	 select e.* from maoer.drama_fans_reward as e join(
-- 	 select user_id ,max(created_time) max_created_time from maoer.drama_fans_reward group by user_id
-- 	 ) f on e.user_id=f.user_id and e.created_time=f.max_created_time
--  ) as c on a.drama_id=c.drama_id
-- 	group by drama_id
-- 	)
--
-- update drama_feature t1
-- join drama_fans_reward_feature t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_fans_reward_total_fans_num = t2.drama_fans_reward_total_fans_num,
-- t1.drama_fans_reward_week_ranking_fans_num = t2.drama_fans_reward_week_ranking_fans_num,
-- t1.drama_fans_reward_month_ranking_fans_num = t2.drama_fans_reward_month_ranking_fans_num,
-- t1.drama_fans_reward_total_ranking_fans_num = t2.drama_fans_reward_total_ranking_fans_num,
-- t1.drama_fans_reward_week_ranking_total_coin = t2.drama_fans_reward_week_ranking_total_coin,
-- t1.drama_fans_reward_month_ranking_total_coin = t2.drama_fans_reward_month_ranking_total_coin,
-- t1.drama_fans_reward_total_ranking_total_coin = t2.drama_fans_reward_total_ranking_total_coin,
-- t1.drama_fans_reward_week_ranking_max_coin = t2.drama_fans_reward_week_ranking_max_coin,
-- t1.drama_fans_reward_month_ranking_max_coin = t2.drama_fans_reward_month_ranking_max_coin ,
-- t1.drama_fans_reward_total_ranking_max_coin = t2.drama_fans_reward_total_ranking_max_coin ,
-- t1.drama_fans_reward_week_ranking_min_coin = t2.drama_fans_reward_week_ranking_min_coin,
-- t1.drama_fans_reward_month_ranking_min_coin = t2.drama_fans_reward_month_ranking_min_coin,
-- t1.drama_fans_reward_total_ranking_min_coin = t2.drama_fans_reward_total_ranking_min_coin,
-- t1.drama_fans_reward_week_ranking_avg_coin = t2.drama_fans_reward_week_ranking_avg_coin,
-- t1.drama_fans_reward_month_ranking_avg_coin = t2.drama_fans_reward_month_ranking_avg_coin,
-- t1.drama_fans_reward_total_ranking_avg_coin = t2.drama_fans_reward_total_ranking_avg_coin

-- -- update drama_fans_reward_feature t1 join
-- -- (
-- -- select c.drama_id,
-- -- max(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_create_time_between_submit_drama_time_max,
-- -- min(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_create_time_between_submit_drama_time_min,
-- -- avg(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_create_time_between_submit_drama_time_avg,
-- -- max(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_create_time_between_latest_drama_time_max,
-- -- min(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_create_time_between_latest_drama_time_min,
-- -- avg(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_create_time_between_latest_drama_time_avg
--
-- -- -- when c.drama_fans_reward_type=2
-- -- max(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_month_create_time_between_submit_drama_time_max,
-- -- min(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_month_create_time_between_submit_drama_time_min,
-- -- avg(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_month_create_time_between_submit_drama_time_avg,
-- -- max(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_month_create_time_between_latest_drama_time_max,
-- -- min(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_month_create_time_between_latest_drama_time_min,
-- -- avg(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_month_create_time_between_latest_drama_time_avg
--
-- -- when c.drama_fans_reward_type=3
-- max(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_total_create_time_between_submit_drama_time_max,
-- min(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_total_create_time_between_submit_drama_time_min,
-- avg(DATEDIFF(c.drama_fans_reward_created_time,d.submit_drama_time)) as drama_fans_total_create_time_between_submit_drama_time_avg,
-- max(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_total_create_time_between_latest_drama_time_max,
-- min(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_total_create_time_between_latest_drama_time_min,
-- avg(DATEDIFF(c.drama_fans_reward_created_time,d.latest_drama_time)) as drama_fans_total_create_time_between_latest_drama_time_avg
-- from maoer.drama_fans_reward c
-- join (
-- select a.drama_id,max(b.sound_created_time) as submit_drama_time,
-- min(b.sound_created_time) as latest_drama_time
-- from maoer.drama_episodes as a
-- join(
-- select sound_id,min(sound_info_created_time) sound_created_time
-- from maoer.sound_info
-- group by sound_id
-- ) b on a.sound_id=b.sound_id
-- group by a.drama_id
-- ) as d on c.drama_id=d.drama_id
-- -- where c.drama_fans_reward_type=2
-- where c.drama_fans_reward_type=3
-- group by c.drama_id
-- ) as t2 on t1.drama_id=t2.drama_id
-- SET
-- -- t1.drama_fans_create_time_between_submit_drama_time_max = t2.drama_fans_create_time_between_submit_drama_time_max,
-- -- t1.drama_fans_create_time_between_submit_drama_time_min = t2.drama_fans_create_time_between_submit_drama_time_min,
-- -- t1.drama_fans_create_time_between_submit_drama_time_avg = t2.drama_fans_create_time_between_submit_drama_time_avg,
-- -- t1.drama_fans_create_time_between_latest_drama_time_max = t2.drama_fans_create_time_between_latest_drama_time_max,
-- -- t1.drama_fans_create_time_between_latest_drama_time_min = t2.drama_fans_create_time_between_latest_drama_time_min,
-- -- t1.drama_fans_create_time_between_latest_drama_time_avg = t2.drama_fans_create_time_between_latest_drama_time_avg
--
-- -- t1.drama_fans_month_create_time_between_submit_drama_time_max = t2.drama_fans_month_create_time_between_submit_drama_time_max,
-- -- t1.drama_fans_month_create_time_between_submit_drama_time_min = t2.drama_fans_month_create_time_between_submit_drama_time_min,
-- -- t1.drama_fans_month_create_time_between_submit_drama_time_avg = t2.drama_fans_month_create_time_between_submit_drama_time_avg,
-- -- t1.drama_fans_month_create_time_between_latest_drama_time_max = t2.drama_fans_month_create_time_between_latest_drama_time_max,
-- -- t1.drama_fans_month_create_time_between_latest_drama_time_min = t2.drama_fans_month_create_time_between_latest_drama_time_min,
-- -- t1.drama_fans_month_create_time_between_latest_drama_time_avg = t2.drama_fans_month_create_time_between_latest_drama_time_avg
--
-- t1.drama_fans_total_create_time_between_submit_drama_time_max = t2.drama_fans_total_create_time_between_submit_drama_time_max,
-- t1.drama_fans_total_create_time_between_submit_drama_time_min = t2.drama_fans_total_create_time_between_submit_drama_time_min,
-- t1.drama_fans_total_create_time_between_submit_drama_time_avg = t2.drama_fans_total_create_time_between_submit_drama_time_avg,
-- t1.drama_fans_total_create_time_between_latest_drama_time_max = t2.drama_fans_total_create_time_between_latest_drama_time_max,
-- t1.drama_fans_total_create_time_between_latest_drama_time_min = t2.drama_fans_total_create_time_between_latest_drama_time_min,
-- t1.drama_fans_total_create_time_between_latest_drama_time_avg = t2.drama_fans_total_create_time_between_latest_drama_time_avg

-- 剧集up主 drama_upuser_feature
-- update drama_feature t1 join (
-- select a.drama_id,
-- e.user_info_grade as drama_upuser_grade,
-- e.user_info_fish_num as drama_upuser_fish_num,
-- e.user_info_fans_num as drama_upuser_fans_num,
-- e.user_info_follower_num as drama_upuser_follower_num,
-- e.user_info_sound_num as drama_upuser_submit_sound_num,
-- e.user_info_drama_num as drama_upuser_submit_drama_num,
-- e.user_info_subscriptions_num as drama_upuser_subscriptions_num,
-- e.user_info_channel as drama_upuser_channel_num
-- from drama_feature as a
-- join (
-- 	SELECT drama_id,user_id
-- 	from maoer.drama_info
-- ) b on a.drama_id=b.drama_id
-- join(
-- 	select c.user_id,c.user_info_grade,c.user_info_fish_num,c.user_info_fans_num,c.user_info_follower_num,c.user_info_sound_num,c.user_info_drama_num,c.user_info_subscriptions_num,c.user_info_channel
-- 	from maoer.user_info as c
-- 	join(
-- 		select user_id,max(created_time) max_created_time
-- 		from maoer.user_info
-- 		group by user_id
-- 	) as d on c.user_id=d.user_id and c.created_time=d.max_created_time
-- ) as e on e.user_id=b.user_id
-- group by a.drama_id
-- )t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_upuser_grade = t2.drama_upuser_grade,
-- t1.drama_upuser_fish_num = t2.drama_upuser_fish_num,
-- t1.drama_upuser_fans_num = t2.drama_upuser_fans_num,
-- t1.drama_upuser_follower_num = t2.drama_upuser_follower_num,
-- t1.drama_upuser_submit_sound_num = t2.drama_upuser_submit_sound_num,
-- t1.drama_upuser_submit_drama_num = t2.drama_upuser_submit_drama_num,
-- t1.drama_upuser_subscriptions_num = t2.drama_upuser_subscriptions_num,
-- t1.drama_upuser_channel_num = t2.drama_upuser_channel_num

-- update drama_feature t1 join(
-- select a.drama_id,
-- 	g.upuser_submit_sound_total_view_num as drama_upuser_submit_sound_total_view_num,
-- 	g.upuser_submit_sound_max_view_num as drama_upuser_submit_sound_max_view_num,
-- 	g.upuser_submit_sound_min_view_num as drama_upuser_submit_sound_min_view_num,
-- 	g.upuser_submit_sound_avg_view_num as drama_upuser_submit_sound_avg_view_num,
-- 	g.upuser_submit_sound_total_danmu_num as drama_upuser_submit_sound_total_danmu_num,
-- 	g.upuser_submit_sound_max_danmu_num as drama_upuser_submit_sound_max_danmu_num,
-- 	g.upuser_submit_sound_min_danmu_num as drama_upuser_submit_sound_min_danmu_num,
-- 	g.upuser_submit_sound_avg_danmu_num as drama_upuser_submit_sound_avg_danmu_num,
-- 	g.upuser_submit_sound_total_review_num as drama_upuser_submit_sound_total_review_num,
-- 	g.upuser_submit_sound_max_review_num as drama_upuser_submit_sound_max_review_num,
-- 	g.upuser_submit_sound_min_review_num as drama_upuser_submit_sound_min_review_num,
-- 	g.upuser_submit_sound_avg_review_num as drama_upuser_submit_sound_avg_review_num
-- from drama_feature as a
-- join (
-- 	SELECT drama_id,user_id
-- 	from maoer.drama_info
-- ) b on a.drama_id=b.drama_id
-- join(
-- 	select c.user_id,
-- 	sum(f.sound_info_view_count) as upuser_submit_sound_total_view_num,
-- 	max(f.sound_info_view_count) as upuser_submit_sound_max_view_num,
-- 	min(f.sound_info_view_count) as upuser_submit_sound_min_view_num,
-- 	avg(f.sound_info_view_count) as upuser_submit_sound_avg_view_num,
-- 	sum(f.sound_info_danmu_count) as upuser_submit_sound_total_danmu_num,
-- 	max(f.sound_info_danmu_count) as upuser_submit_sound_max_danmu_num,
-- 	min(f.sound_info_danmu_count) as upuser_submit_sound_min_danmu_num,
-- 	avg(f.sound_info_danmu_count) as upuser_submit_sound_avg_danmu_num,
-- 	sum(f.sound_info_all_reviews_num) as upuser_submit_sound_total_review_num,
-- 	max(f.sound_info_all_reviews_num) as upuser_submit_sound_max_review_num,
-- 	min(f.sound_info_all_reviews_num) as upuser_submit_sound_min_review_num,
-- 	avg(f.sound_info_all_reviews_num) as upuser_submit_sound_avg_review_num
-- 	from maoer.user_sound as c
-- 	join (
-- 		select d.sound_id,d.sound_info_view_count,d.sound_info_danmu_count,d.sound_info_all_reviews_num
-- 		from maoer.sound_info_update d
-- 		join(
-- 			select sound_id,max(created_time) max_created_time
-- 			from maoer.sound_info_update
-- 			group by sound_id
-- 		) e on e.sound_id=d.sound_id and d.created_time=e.max_created_time
-- 	) f on c.sound_id=f.sound_id
-- 	group by c.user_id
-- )g on b.user_id=g.user_id
-- group by a.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_upuser_submit_sound_total_view_num = t2.drama_upuser_submit_sound_total_view_num,
-- t1.drama_upuser_submit_sound_max_view_num = t2.drama_upuser_submit_sound_max_view_num,
-- t1.drama_upuser_submit_sound_min_view_num = t2.drama_upuser_submit_sound_min_view_num,
-- t1.drama_upuser_submit_sound_avg_view_num = t2.drama_upuser_submit_sound_avg_view_num,
-- t1.drama_upuser_submit_sound_total_danmu_num = t2.drama_upuser_submit_sound_total_danmu_num,
-- t1.drama_upuser_submit_sound_max_danmu_num = t2.drama_upuser_submit_sound_max_danmu_num,
-- t1.drama_upuser_submit_sound_min_danmu_num = t2.drama_upuser_submit_sound_min_danmu_num,
-- t1.drama_upuser_submit_sound_avg_danmu_num = t2.drama_upuser_submit_sound_avg_danmu_num,
-- t1.drama_upuser_submit_sound_total_review_num = t2.drama_upuser_submit_sound_total_review_num,
-- t1.drama_upuser_submit_sound_max_review_num = t2.drama_upuser_submit_sound_max_review_num,
-- t1.drama_upuser_submit_sound_min_review_num = t2.drama_upuser_submit_sound_min_review_num,
-- t1.drama_upuser_submit_sound_avg_review_num = t2.drama_upuser_submit_sound_avg_review_num

-- select a.drama_id,
-- (if g.drama_upuser_submit_drama_has_fans_reward>0 and g.drama_upuser_submit_drama_has_fans_reward is not null,1,0) as drama_upuser_submit_drama_has_fans_reward
-- (if g.drama_upuser_submit_drama_has_reward_week_ranking>0 and g.drama_upuser_submit_drama_has_reward_week_ranking is not null,1,0) as drama_upuser_submit_drama_has_reward_week_ranking,
-- (if g.drama_upuser_submit_drama_has_reward_month_ranking>0 and g.drama_upuser_submit_drama_has_reward_month_ranking is not null,1,0) as drama_upuser_submit_drama_has_reward_month_ranking,
-- (if g.drama_upuser_submit_drama_has_reward_total_ranking>0 and g.drama_upuser_submit_drama_has_reward_total_ranking is not null,1,0) as drama_upuser_submit_drama_has_reward_total_ranking,
-- g.drama_upuser_submit_drama_reward_week_max_rank,
-- g.drama_upuser_submit_drama_reward_month_max_rank,
-- g.drama_upuser_submit_drama_reward_total_max_rank
-- from drama_feature as a
-- left join (
-- 	select drama_id,user_id
-- 	from maoer.drama_info
-- 	)	h on h.drama_id=a.drama_id
-- left join (
-- select f.user_id,
-- sum(case when f.drama_fans_reward_type is not null then 1 else 0 end) as drama_upuser_submit_drama_has_fans_reward,
-- sum(case when f.drama_reward_type=1 then 1 else 0 end) as drama_upuser_submit_drama_has_reward_week_ranking,
-- sum(case when f.drama_reward_type=2 then 1 else 0 end) as drama_upuser_submit_drama_has_reward_month_ranking,
-- sum(case when f.drama_reward_type=3 then 1 else 0 end) as drama_upuser_submit_drama_has_reward_total_ranking,
-- max(case when f.drama_reward_type=1 then f.drama_reward_rank else 0 end) as drama_upuser_submit_drama_reward_week_max_rank,
-- max(case when f.drama_reward_type=2 then f.drama_reward_rank else 0 end) as drama_upuser_submit_drama_reward_month_max_rank,
-- max(case when f.drama_reward_type=3 then f.drama_reward_rank else 0 end) as drama_upuser_submit_drama_reward_total_max_rank
-- from(
-- 	SELECT e.drama_id,e.user_id,c.drama_fans_reward_type,d.drama_reward_type,d.drama_reward_rank
-- 	from maoer.drama_info e
-- 	left join (
-- 	select distinct drama_id,drama_fans_reward_type
-- 	from maoer.drama_fans_reward
-- ) c on e.drama_id=c.drama_id
-- left join(
-- 	select drama_id,drama_reward_type,drama_reward_rank
-- 	from maoer.drama_reward
-- 	group by drama_id
-- )d on e.drama_id=d.drama_id
-- ) b on a.drama_id=b.drama_id
-- )f group by f.user_id
-- ) g on h.user_id=g.user_id
-- group by a.drama_id


-- update drama_feature t1 join(
-- select a.drama_id,
-- (if(g.drama_upuser_submit_drama_has_fans_reward>0 and g.drama_upuser_submit_drama_has_fans_reward is not null,1,0)) as drama_upuser_submit_drama_has_fans_reward,
-- (if(g.drama_upuser_submit_drama_has_reward_week_ranking>0 and g.drama_upuser_submit_drama_has_reward_week_ranking is not null,1,0)) as drama_upuser_submit_drama_has_reward_week_ranking,
-- (if(g.drama_upuser_submit_drama_has_reward_month_ranking>0 and g.drama_upuser_submit_drama_has_reward_month_ranking is not null,1,0)) as drama_upuser_submit_drama_has_reward_month_ranking,
-- (if(g.drama_upuser_submit_drama_has_reward_total_ranking>0 and g.drama_upuser_submit_drama_has_reward_total_ranking is not null,1,0)) as drama_upuser_submit_drama_has_reward_total_ranking,
-- g.drama_upuser_submit_drama_reward_week_max_rank,
-- g.drama_upuser_submit_drama_reward_month_max_rank,
-- g.drama_upuser_submit_drama_reward_total_max_rank
-- from drama_feature as a
-- left join (
--     select drama_id,user_id
--     from maoer.drama_info
-- ) h on h.drama_id=a.drama_id
-- left join (
--     select f.user_id,
--     sum(case when f.drama_fans_reward_type is not null then 1 else 0 end) as drama_upuser_submit_drama_has_fans_reward,
--     sum(case when f.drama_reward_type=1 then 1 else 0 end) as drama_upuser_submit_drama_has_reward_week_ranking,
--     sum(case when f.drama_reward_type=2 then 1 else 0 end) as drama_upuser_submit_drama_has_reward_month_ranking,
--     sum(case when f.drama_reward_type=3 then 1 else 0 end) as drama_upuser_submit_drama_has_reward_total_ranking,
--     max(case when f.drama_reward_type=1 then f.drama_reward_rank else 0 end) as drama_upuser_submit_drama_reward_week_max_rank,
--     max(case when f.drama_reward_type=2 then f.drama_reward_rank else 0 end) as drama_upuser_submit_drama_reward_month_max_rank,
--     max(case when f.drama_reward_type=3 then f.drama_reward_rank else 0 end) as drama_upuser_submit_drama_reward_total_max_rank
--     from (
--         select e.drama_id,e.user_id,c.drama_fans_reward_type,d.drama_reward_type,d.drama_reward_rank
--         from maoer.drama_info e
--         left join (
--             select distinct drama_id,drama_fans_reward_type
--             from maoer.drama_fans_reward
--         ) c on e.drama_id=c.drama_id
--         left join (
--             select drama_id,drama_reward_type,drama_reward_rank
--             from maoer.drama_reward
--             group by drama_id
--         ) d on e.drama_id=d.drama_id
--     ) f
--     group by f.user_id
-- ) g on h.user_id=g.user_id
-- group by a.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_upuser_submit_drama_has_fans_reward = t2.drama_upuser_submit_drama_has_fans_reward,
-- t1.drama_upuser_submit_drama_has_reward_week_ranking = t2.drama_upuser_submit_drama_has_reward_week_ranking,
-- t1.drama_upuser_submit_drama_has_reward_month_ranking = t2.drama_upuser_submit_drama_has_reward_month_ranking,
-- t1.drama_upuser_submit_drama_has_reward_total_ranking = t2.drama_upuser_submit_drama_has_reward_total_ranking,
-- t1.drama_upuser_submit_drama_reward_week_max_rank = t2.drama_upuser_submit_drama_reward_week_max_rank,
-- t1.drama_upuser_submit_drama_reward_month_max_rank = t2.drama_upuser_submit_drama_reward_month_max_rank,
-- t1.drama_upuser_submit_drama_reward_total_max_rank = t2.drama_upuser_submit_drama_reward_total_max_rank

-- update drama_feature t1 join(
-- select a.drama_id,c.drama_upuser_submit_sound_pay_sound_percent
-- from drama_feature as a
-- left join (
--     select drama_id,user_id
--     from maoer.drama_info
-- ) b on b.drama_id=a.drama_id
-- left join (
-- 	select d.user_id,
-- 	avg(case when e.drama_info_pay_type=1 or e.drama_info_pay_type=2 then 1 else 0 end) as drama_upuser_submit_sound_pay_sound_percent
-- 	from maoer.drama_info d
-- 	join(
-- 	select drama_id,drama_info_pay_type
-- 	from maoer.drama_info_update
-- 	group by drama_id
-- 	)e on e.drama_id=d.drama_id
-- 	 group by d.user_id
-- ) c on c.user_id=b.user_id
-- ) t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_upuser_submit_sound_pay_sound_percent = t2.drama_upuser_submit_sound_pay_sound_percent

-- 剧集时长 drama_duration
-- update drama_feature t1 join(
-- 	select g.drama_id,
-- 	g.sum_duration as drama_sound_total_time,
-- 	 g.max_duration as drama_sound_max_time,
-- 	 g.min_duration as drama_sound_min_time,
-- 	 g.avg_duration as drama_sound_avg_time,
-- 	max(case when e.sound_info_duration=g.max_duration then e.sound_info_view_count else 0 end) as drama_sound_max_time_sound_view_num,
-- 	max(case when e.sound_info_duration=g.min_duration then e.sound_info_view_count else 0 end) as drama_sound_min_time_sound_view_num,
-- 	max(case when e.sound_info_duration=g.max_duration then e.sound_info_danmu_count else 0 end) as drama_sound_max_time_sound_danmu_num,
-- 	max(case when e.sound_info_duration=g.min_duration then e.sound_info_danmu_count else 0 end) as drama_sound_min_time_sound_danmu_num,
-- 	max(case when e.sound_info_duration=g.max_duration then e.sound_info_all_reviews_num else 0 end) as drama_sound_max_time_sound_review_num,
-- 	max(case when e.sound_info_duration=g.min_duration then e.sound_info_all_reviews_num else 0 end) as drama_sound_min_time_sound_review_num
-- 	from(
-- 		select sound_id,sound_info_duration,sound_info_view_count,sound_info_danmu_count,sound_info_all_reviews_num
-- 		from maoer.sound_info_update
-- 		group by sound_id
-- 	) e
-- 	join maoer.drama_episodes f on e.sound_id=f.sound_id
-- 	join (
-- 	select c.drama_id,sum(d.sound_info_duration) as sum_duration,max(d.sound_info_duration) as max_duration,min(d.sound_info_duration) as min_duration,avg(d.sound_info_duration) as avg_duration
-- 	from maoer.drama_episodes as c
-- 	join(
-- 		select sound_id,sound_info_duration
-- 		from maoer.sound_info_update
-- 		group by sound_id
-- 	) d on d.sound_id=c.sound_id
-- 	group by c.drama_id
-- 	) g on g.drama_id=f.drama_id
-- 	group by g.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_sound_total_time = t2.drama_sound_total_time,
-- t1.drama_sound_max_time = t2.drama_sound_max_time,
-- t1.drama_sound_min_time = t2.drama_sound_min_time,
-- t1.drama_sound_avg_time = t2.drama_sound_avg_time,
-- t1.drama_sound_max_time_sound_view_num = t2.drama_sound_max_time_sound_view_num ,
-- t1.drama_sound_min_time_sound_view_num = t2.drama_sound_min_time_sound_view_num,
-- t1.drama_sound_max_time_sound_danmu_num = t2.drama_sound_max_time_sound_danmu_num,
-- t1.drama_sound_min_time_sound_danmu_num = t2.drama_sound_min_time_sound_danmu_num,
-- t1.drama_sound_max_time_sound_review_num = t2.drama_sound_max_time_sound_review_num,
-- t1.drama_sound_min_time_sound_review_num = t2.drama_sound_min_time_sound_review_num

-- 剧集声音弹幕 drama_sound_danmu
-- update drama_feature t1 join(
-- select a.drama_id,
-- avg(b.danmu_len_avg) as drama_danmu_avg_len,
-- max(b.danmu_len_max) as drama_danmu_max_len,
-- min(b.danmu_len_min) as drama_danmu_min_len,
-- max(b.danmu_submit_time_between_submit_sound_time_max) as drama_danmu_submit_time_between_submit_sound_time_max,
-- min(b.danmu_submit_time_between_submit_sound_time_min) as drama_danmu_submit_time_between_submit_sound_time_min,
-- avg(b.danmu_submit_time_between_submit_sound_time_avg) as drama_danmu_submit_time_between_submit_sound_time_avg
-- max(b.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_max,
-- min(b.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_min,
-- avg(b.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_avg,
-- max(b.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_max,
-- min(b.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_min,
-- avg(b.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_avg,
-- max(b.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_max,
-- min(b.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_min,
-- avg(b.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_avg
-- from maoer.drama_episodes a
-- right join(
-- 	select *
-- 	from sound_danmu_feature
-- )b on a.sound_id=b.sound_id
-- group by a.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_danmu_avg_len = t2.drama_danmu_avg_len,
-- t1.drama_danmu_max_len = t2.drama_danmu_max_len,
-- t1.drama_danmu_min_len = t2.drama_danmu_min_len,
-- t1.drama_danmu_submit_time_between_submit_sound_time_max = t2.drama_danmu_submit_time_between_submit_sound_time_max,
-- t1.drama_danmu_submit_time_between_submit_sound_time_min = t2.drama_danmu_submit_time_between_submit_sound_time_min,
-- t1.drama_danmu_submit_time_between_submit_sound_time_avg = t2.drama_danmu_submit_time_between_submit_sound_time_avg
-- t1.drama_danmu_time_between_sound_time_in_7days_num_max = t2.drama_danmu_time_between_sound_time_in_7days_num_max ,
-- t1.drama_danmu_time_between_sound_time_in_7days_num_min = t2.drama_danmu_time_between_sound_time_in_7days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_7days_num_avg = t2.drama_danmu_time_between_sound_time_in_7days_num_avg,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_max = t2.drama_danmu_time_between_sound_time_in_14days_num_max,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_min = t2.drama_danmu_time_between_sound_time_in_14days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_avg = t2.drama_danmu_time_between_sound_time_in_14days_num_avg,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_max = t2.drama_danmu_time_between_sound_time_in_30days_num_max,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_min = t2.drama_danmu_time_between_sound_time_in_30days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_avg = t2.drama_danmu_time_between_sound_time_in_30days_num_avg

-- 构建drama_tag_feature
-- update drama_feature t1
-- join (
-- select x.drama_id,x.tag_total_cite_num,x.tag_max_cite_num,x.tag_min_cite_num,x.tag_avg_cite_num,z.tag_has_cv_name_num,
-- z.tag_has_cv_name_total_cite_num,z.tag_has_cv_name_max_cite_num,
-- z.tag_has_cv_name_min_cite_num,z.tag_has_cv_name_avg_cite_num
-- from(
-- select a.drama_id,sum(b.tag_count) as tag_total_cite_num,max(b.tag_count) as tag_max_cite_num,min(b.tag_count) as tag_min_cite_num,avg(b.tag_count) as tag_avg_cite_num
-- from maoer.drama_tags as a
-- join (
-- select e.tag_id,e.tag_name,count(distinct e.drama_id) as tag_count
-- from maoer.drama_tags as e
-- group by e.tag_id
-- ) as b on a.tag_id=b.tag_id
-- group by a.drama_id
-- ) as x
-- left join (
-- select a.drama_id,count(a.tag_id) as tag_has_cv_name_num,
-- sum(b.tag_count) as tag_has_cv_name_total_cite_num,
-- max(b.tag_count) as tag_has_cv_name_max_cite_num,
-- min(b.tag_count) as tag_has_cv_name_min_cite_num,
-- avg(b.tag_count) as tag_has_cv_name_avg_cite_num
-- from maoer.drama_tags as a
-- join (
-- select e.tag_id,e.tag_name,count(distinct e.drama_id) as tag_count
-- from maoer.drama_tags as e
-- where e.tag_name in (select cast_info_name from maoer.cast_info)
-- group by e.tag_id,e.tag_name
-- ) as b on a.tag_id=b.tag_id
-- group by a.drama_id
-- )as z  on x.drama_id=z.drama_id
-- )t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_sound_tag_total_cite_num = t2.tag_total_cite_num,
-- t1.drama_sound_tag_max_cite_num = t2.tag_max_cite_num,
-- t1.drama_sound_tag_min_cite_num = t2.tag_min_cite_num,
-- t1.drama_sound_tag_avg_cite_num = t2.tag_avg_cite_num,
-- t1.drama_sound_tag_has_cv_name_num = t2.tag_has_cv_name_num,
-- t1.drama_sound_tag_has_cv_name_total_cite_num = t2.tag_has_cv_name_total_cite_num,
-- t1.drama_sound_tag_has_cv_name_max_cite_num = t2.tag_has_cv_name_max_cite_num,
-- t1.drama_sound_tag_has_cv_name_min_cite_num = t2.tag_has_cv_name_min_cite_num,
-- t1.drama_sound_tag_has_cv_name_avg_cite_num = t2.tag_has_cv_name_avg_cite_num


-- ----------------用户声音剧集特征提取-----------------------------

-- 建表 user_sound_drama_feature
-- create table user_sound_drama_feature as
-- select user_id,sound_id,drama_id
-- from activeuser_submit_danmu_sound_with_drama
-- group by user_id,sound_id,drama_id

-- ALTER TABLE user_sound_drama_feature
-- ADD COLUMN user_in_sound_is_submit_review int,
-- ADD COLUMN user_in_sound_submit_review_num int,
-- ADD COLUMN user_in_sound_first_review_with_sound_publish_time_diff_days int,
-- ADD COLUMN user_in_sound_latest_review_with_sound_publish_time_diff_days int,
-- ADD COLUMN user_in_sound_review_total_len int,
-- ADD COLUMN user_in_sound_review_len_max int,
-- ADD COLUMN user_in_sound_review_len_min int,
-- ADD COLUMN user_in_sound_review_len_avg double,
-- ADD COLUMN user_in_sound_review_subreview_total_num int,
-- ADD COLUMN user_in_sound_review_subreview_max_num int,
-- ADD COLUMN user_in_sound_review_subreview_min_num int,
-- ADD COLUMN user_in_sound_review_subreview_avg_num double,
-- ADD COLUMN user_in_sound_review_like_total_num int,
-- ADD COLUMN user_in_sound_review_like_max_num int,
-- ADD COLUMN user_in_sound_review_like_min_num int,
-- ADD COLUMN user_in_sound_review_like_avg_num double,
-- ADD COLUMN user_in_sound_is_submit_danmu int,
-- ADD COLUMN user_in_sound_submit_danmu_total_len int,
-- ADD COLUMN user_in_sound_submit_danmu_max_len int,
-- ADD COLUMN user_in_sound_submit_danmu_min_len int,
-- ADD COLUMN user_in_sound_submit_danmu_avg_len double,
-- ADD COLUMN user_in_sound_submit_danmu_num int,
-- ADD COLUMN user_in_sound_danmu_around_15s_total_danmu_max_num int,
-- ADD COLUMN user_in_sound_danmu_around_15s_total_danmu_min_num int,
-- ADD COLUMN user_in_sound_danmu_around_15s_total_danmu_avg_num double,


-- 建表 用户声音评论 user_in_sound_review_feature
-- create table user_in_sound_review_feature as
-- select a.user_id,a.sound_id,a.drama_id,
-- d.user_in_sound_submit_review_num,
-- d.user_in_sound_first_review_with_sound_publish_time_diff_days,
-- d.user_in_sound_latest_review_with_sound_publish_time_diff_days,
-- d.user_in_sound_review_total_len,
-- d.user_in_sound_review_len_max,
-- d.user_in_sound_review_len_min,
-- d.user_in_sound_review_len_avg,
-- d.user_in_sound_review_subreview_total_num,
-- d.user_in_sound_review_subreview_max_num,
-- d.user_in_sound_review_subreview_min_num,
-- d.user_in_sound_review_subreview_avg_num,
-- d.user_in_sound_review_like_total_num,
-- d.user_in_sound_review_like_max_num,
-- d.user_in_sound_review_like_min_num,
-- d.user_in_sound_review_like_avg_num
-- from activeuser_submit_danmu_sound_with_drama a
-- left join (
-- 	select b.user_id,b.subject_id,count(distinct b.review_id)as user_in_sound_submit_review_num,
-- 	max(DATEDIFF(b.review_created_time,c.sound_info_created_time)) as user_in_sound_first_review_with_sound_publish_time_diff_days ,
-- 	min(DATEDIFF(b.review_created_time,c.sound_info_created_time)) as user_in_sound_latest_review_with_sound_publish_time_diff_days ,
-- 	sum(LENGTH(b.review_content)) as user_in_sound_review_total_len,
--  max(LENGTH(b.review_content))as user_in_sound_review_len_max,
--  min(LENGTH(b.review_content))as user_in_sound_review_len_min,
--  avg(LENGTH(b.review_content))as user_in_sound_review_len_avg,
--  sum(b.review_sub_review_num) as user_in_sound_review_subreview_total_num,
--  max(b.review_sub_review_num)as user_in_sound_review_subreview_max_num,
--  min(b.review_sub_review_num)as user_in_sound_review_subreview_min_num,
--  avg(b.review_sub_review_num)as user_in_sound_review_subreview_avg_num,
--  sum(b.review_like_num) as user_in_sound_review_like_total_num,
--  max(b.review_like_num)as user_in_sound_review_like_max_num,
--  min(b.review_like_num)as user_in_sound_review_like_min_num,
--  avg(b.review_like_num)as user_in_sound_review_like_avg_num
-- 	from maoer.review_content b join
-- 	(select sound_id,sound_info_created_time
-- 	from maoer.sound_info) c on c.sound_id=b.subject_id
-- 	group by b.user_id,b.subject_id
-- )as d on a.user_id=d.user_id and a.sound_id=d.subject_id
-- group by a.user_id,a.sound_id,a.drama_id

-- create table temp1_user_sound_drama_feature as
-- (
-- select t1.user_id,t1.sound_id,t1.drama_id,t1.user_in_sound_submit_review_num,
-- t1.user_in_sound_first_review_with_sound_publish_time_diff_days,
-- t1.user_in_sound_latest_review_with_sound_publish_time_diff_days,
-- t1.user_in_sound_review_total_len,
-- t1.user_in_sound_review_len_max,
-- t1.user_in_sound_review_len_min,
-- t1.user_in_sound_review_len_avg,
-- t1.user_in_sound_review_subreview_total_num,
-- t1.user_in_sound_review_subreview_max_num,
-- t1.user_in_sound_review_subreview_min_num,
-- t1.user_in_sound_review_subreview_avg_num,
-- t1.user_in_sound_review_like_total_num,
-- t1.user_in_sound_review_like_max_num,
-- t1.user_in_sound_review_like_min_num ,
-- t1.user_in_sound_review_like_avg_num ,
--
-- t2.user_in_sound_is_submit_danmu,
-- t2.user_in_sound_submit_danmu_total_len,
-- t2.user_in_sound_submit_danmu_max_len,
-- t2.user_in_sound_submit_danmu_min_len ,
-- t2.user_in_sound_submit_danmu_avg_len ,
-- t2.user_in_sound_submit_danmu_num ,
-- t2.user_in_sound_danmu_around_15s_total_danmu_max_num,
-- t2.user_in_sound_danmu_around_15s_total_danmu_min_num,
-- t2.user_in_sound_danmu_around_15s_total_danmu_avg_num
-- from user_in_sound_review_feature t1 left join user_in_sound_danmu_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- )

-- 已替换成上一段sql语句 1612-1639
-- update user_sound_drama_feature t1 left join
-- user_in_sound_review_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- set
-- t1.user_in_sound_submit_review_num = t2.user_in_sound_submit_review_num,
-- t1.user_in_sound_first_review_with_sound_publish_time_diff_days = t2.user_in_sound_first_review_with_sound_publish_time_diff_days,
-- t1.user_in_sound_latest_review_with_sound_publish_time_diff_days = t2.user_in_sound_latest_review_with_sound_publish_time_diff_days ,
-- t1.user_in_sound_review_total_len = t2.user_in_sound_review_total_len,
-- t1.user_in_sound_review_len_max = t2.user_in_sound_review_len_max,
-- t1.user_in_sound_review_len_min = t2.user_in_sound_review_len_min,
-- t1.user_in_sound_review_len_avg = t2.user_in_sound_review_len_avg,
-- t1.user_in_sound_review_subreview_total_num = t2.user_in_sound_review_subreview_total_num,
-- t1.user_in_sound_review_subreview_max_num = t2.user_in_sound_review_subreview_max_num,
-- t1.user_in_sound_review_subreview_min_num = t2.user_in_sound_review_subreview_min_num,
-- t1.user_in_sound_review_subreview_avg_num = t2.user_in_sound_review_subreview_avg_num,
-- t1.user_in_sound_review_like_total_num = t2.user_in_sound_review_like_total_num,
-- t1.user_in_sound_review_like_max_num = t2.user_in_sound_review_like_max_num,
-- t1.user_in_sound_review_like_min_num = t2.user_in_sound_review_like_min_num ,
-- t1.user_in_sound_review_like_avg_num = t2.user_in_sound_review_like_avg_num

-- 建表 用户声音danmu user_in_sound_danmu_feature
-- create table user_in_sound_danmu_feature as
-- select a.user_id,a.sound_id,a.drama_id,
-- d.user_in_sound_submit_danmu_total_len,
-- d.user_in_sound_submit_danmu_max_len,
-- d.user_in_sound_submit_danmu_min_len,
-- d.user_in_sound_submit_danmu_avg_len,
-- d.user_in_sound_submit_danmu_num
-- from activeuser_submit_danmu_sound_with_drama a
-- left join (
-- 	select user_id,sound_id,
-- sum(LENGTH(danmu_info_text)) as user_in_sound_submit_danmu_total_len,
-- max(LENGTH(danmu_info_text)) as user_in_sound_submit_danmu_max_len,
-- min(LENGTH(danmu_info_text)) as user_in_sound_submit_danmu_min_len,
-- avg(LENGTH(danmu_info_text)) as user_in_sound_submit_danmu_avg_len,
-- count(danmu_id) as user_in_sound_submit_danmu_num
-- 	from maoer.danmu_info_2022
-- 	group by user_id,sound_id
-- )as d on a.user_id=d.user_id and a.sound_id=d.sound_id
-- group by a.user_id,a.sound_id,a.drama_id

-- 建表 用户周围弹幕特征 user_around_danmu_feature
-- create table user_around_danmu_feature as
-- SELECT di.sound_id, k.user_id,k.danmu_id, COUNT(di.danmu_info_stime_notransform) AS around_15s_total_danmu_num
--         FROM maoer.danmu_info AS di
--         JOIN (
--             SELECT m.user_id, m.sound_id,
-- 										m.danmu_id, m.danmu_info_stime_notransform
--             FROM maoer.danmu_info m
-- 						right join activeuser_with_danmu_sound n
-- 						on m.sound_id = n.sound_id and m.user_id=n.user_id
--             GROUP BY danmu_id
--         ) k ON di.sound_id = k.sound_id
--         WHERE di.danmu_info_stime_notransform > k.danmu_info_stime_notransform - 15 AND di.danmu_info_stime_notransform < k.danmu_info_stime_notransform + 15
--         GROUP BY di.sound_id, k.user_id,k.danmu_id

-- alter table user_around_danmu_feature
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_max_num int,
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_min_num int,
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_avg_num int

-- update user_around_danmu_feature t1 join
-- (select user_id,sound_id,
-- max(around_15s_total_danmu_num) as user_in_sound_danmu_around_15s_total_danmu_max_num,
-- min(around_15s_total_danmu_num) as user_in_sound_danmu_around_15s_total_danmu_min_num,
-- avg(around_15s_total_danmu_num) as user_in_sound_danmu_around_15s_total_danmu_avg_num
-- from user_around_danmu_feature
-- group by user_id,sound_id
-- )t2  on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- set
-- t1.user_in_sound_danmu_around_15s_total_danmu_max_num = t2.user_in_sound_danmu_around_15s_total_danmu_max_num,
--     t1.user_in_sound_danmu_around_15s_total_danmu_min_num = t2.user_in_sound_danmu_around_15s_total_danmu_min_num,
--     t1.user_in_sound_danmu_around_15s_total_danmu_avg_num = t2.user_in_sound_danmu_around_15s_total_danmu_avg_num;

-- select user_id,sound_id,max(around_15s_total_danmu_num) as user_in_sound_danmu_around_15s_total_danmu_max_num,
-- min(around_15s_total_danmu_num) as user_in_sound_danmu_around_15s_total_danmu_min_num,
-- avg(around_15s_total_danmu_num) as user_in_sound_danmu_around_15s_total_danmu_avg_num
-- from user_around_danmu_feature
-- group by user_id,sound_id

-- alter table user_in_sound_danmu_feature
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_max_num int,
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_min_num int,
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_avg_num double

-- update user_in_sound_danmu_feature t1
-- join (
-- select user_id,sound_id,user_in_sound_danmu_around_15s_total_danmu_max_num,user_in_sound_danmu_around_15s_total_danmu_min_num,
-- user_in_sound_danmu_around_15s_total_danmu_avg_num
-- from user_around_danmu_feature
-- group by user_id,sound_id
-- )t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- SET
-- t1.user_in_sound_danmu_around_15s_total_danmu_max_num = t2.user_in_sound_danmu_around_15s_total_danmu_max_num,
-- t1.user_in_sound_danmu_around_15s_total_danmu_min_num = t2.user_in_sound_danmu_around_15s_total_danmu_min_num,
-- t1.user_in_sound_danmu_around_15s_total_danmu_avg_num = t2.user_in_sound_danmu_around_15s_total_danmu_avg_num

-- 已替换成前面的sql语句 1612-1639
-- update user_sound_drama_feature t1 left join
-- user_in_sound_danmu_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- set
-- t1.user_in_sound_submit_danmu_total_len = t2.user_in_sound_submit_danmu_total_len,
-- t1.user_in_sound_submit_danmu_max_len = t2.user_in_sound_submit_danmu_max_len,
-- t1.user_in_sound_submit_danmu_min_len = t2.user_in_sound_submit_danmu_min_len ,
-- t1.user_in_sound_submit_danmu_avg_len = t2.user_in_sound_submit_danmu_avg_len ,
-- t1.user_in_sound_submit_danmu_num = t2.user_in_sound_submit_danmu_num ,
-- t1.user_in_sound_danmu_around_15s_total_danmu_max_num = t2.user_in_sound_danmu_around_15s_total_danmu_max_num,
-- t1.user_in_sound_danmu_around_15s_total_danmu_min_num = t2.user_in_sound_danmu_around_15s_total_danmu_min_num,
-- t1.user_in_sound_danmu_around_15s_total_danmu_avg_num = t2.user_in_sound_danmu_around_15s_total_danmu_avg_num

-- alter table temp1_user_sound_drama_feature
-- add COLUMN user_in_sound_is_submit_review int

-- UPDATE temp1_user_sound_drama_feature
-- SET
--   user_in_sound_is_submit_review = (CASE WHEN user_in_sound_submit_review_num IS NOT NULL OR user_in_sound_submit_review_num > 0 THEN 1 ELSE 0 END)

-- update user_sound_drama_feature  t1 join
-- (
-- select user_id,drama_id,
-- sum(user_in_sound_submit_review_num) as user_in_drama_total_review_num,
-- sum(user_in_sound_submit_danmu_num) as user_in_drama_total_danmu_num
-- from user_sound_drama_feature
-- group by user_id,drama_id
-- ) t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- SET
-- t1.user_in_drama_total_review_num = t2.user_in_drama_total_review_num,
-- t1.user_in_drama_total_danmu_num = t2.user_in_drama_total_danmu_num

-- 建表 用户对剧集是否付费 user_drama_is_pay 仅限付费剧集和活跃用户
-- create table user_drama_is_pay_repeat as
-- select a.user_id,a.drama_id,d.sound_id,c.drama_pay_type,e.sound_info_pay_type
-- from activeuser_submit_danmu_sound_with_drama as a
-- inner join (select drama_id,drama_pay_type from drama_feature where drama_pay_type<>0) c
-- on a.drama_id=c.drama_id
-- left join maoer.drama_episodes d
-- on a.drama_id=d.drama_id
-- join (select sound_id,sound_info_pay_type from maoer.sound_info)e
-- on d.sound_id=e.sound_id

-- create table user_is_drama_pay as
-- select * from user_drama_is_pay_repeat group by user_id,sound_id,drama_id

show processlist
-- kill 871

-- update user_in_sound_danmu_feature t1 left join activeuser_submit_danmu_sound_with_drama t2
-- on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- set
-- t1.user_in_sound_is_submit_danmu = (case when t2.drama_id is not null then 1 else 0 end)

-- alter table user_drama_is_pay
-- add COLUMN user_has_review int ,
-- add COLUMN user_has_danmu int,
-- add COLUMN user_in_drama_is_pay_for_drama int

-- update user_drama_is_pay t1 join
-- (
-- select a.user_id,a.sound_id,a.drama_id,(case when b.user_in_sound_is_submit_review is not null then 1 else 0 end) as user_has_review,(case when b.user_in_sound_is_submit_danmu is not null then 1 else 0 end) as user_has_danmu
-- from user_drama_is_pay a
-- join user_sound_drama_feature b
-- on a.user_id=b.user_id and a.sound_id=b.sound_id
-- )t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- set
-- t1.user_has_review = t2.user_has_review,
-- t1.user_has_danmu = t2.user_has_danmu

-- update user_drama_is_pay as t1 join
-- (
-- select b.user_id,b.drama_id, (case when sum( case when b.user_pay_for_sound=1 then 1 else 0 end)>0 then 1 else -1 end) as user_in_drama_is_pay_for_drama
-- from(
-- select a.user_id,a.sound_id,a.drama_id,(case WHEN a.user_has_danmu <> 0 OR a.user_has_review <> 0 THEN 1 ELSE -1 END) as user_pay_for_sound
-- from user_drama_is_pay a
-- where a.sound_info_pay_type <> 0
-- ) b
-- group by b.user_id,b.drama_id
-- ) t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_is_pay_for_drama= t2.user_in_drama_is_pay_for_drama

-- update user_drama_is_pay as t1
-- set
-- t1.user_in_drama_is_pay_for_drama= IFNULL(t1.user_in_drama_is_pay_for_drama,0)

-- update user_drama_is_pay as t1
-- set
-- t1.user_in_drama_is_pay_for_drama= case when t1.sound_info_pay_type=0 then 0 else t1.user_in_drama_is_pay_for_drama end

-- update user_sound_drama_feature t1 join
-- user_drama_is_pay t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_is_pay_for_drama= t2.user_in_drama_is_pay_for_drama

-- update user_sound_drama_feature t1
-- set
-- t1.user_in_drama_is_pay_for_drama= case when t1.user_in_drama_is_pay_for_drama is null then -2 else t1.user_in_drama_is_pay_for_drama end

-- update user_sound_drama_feature t1 join
-- (
-- select t.drama_id,t.user_id,sum(t.drama_fans_reward_coin) as reward_coin
-- from (
-- select drama_id,user_id,drama_fans_reward_coin
-- from maoer.drama_fans_reward
-- group by drama_id,user_id,drama_fans_reward_created_time
-- ) t
-- group by drama_id,user_id
-- ) t2 on t1.drama_id=t2.drama_id and t1.user_id=t2.user_id
-- set
-- t1.user_in_drama_is_in_drama_fans_reward = (case when t2.reward_coin is not null then 1 else 0 end),
-- t1.user_in_drama_fans_reward_total_coin =(case when t2.reward_coin is not null then t2.reward_coin else 0 end)


-- update user_sound_drama_feature t1
-- left join (
-- select a.user_id,b.drama_id,c.user_follower_id
-- from user_sound_drama_feature a
-- left join maoer.drama_info b on a.drama_id=b.drama_id
-- join maoer.user_follower c on a.user_id=c.user_id and b.user_id=c.user_follower_id
-- group by a.user_id,b.drama_id,c.user_follower_id
-- ) t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_is_follower_upuser = (case when t2.user_follower_id is not null then 1 else 0 end)
--
-- select sum(user_in_drama_is_follower_upuser<>1) from user_sound_drama_feature

-- update user_sound_drama_feature
-- set
-- user_in_drama_total_review_num=case when user_in_drama_total_review_num is null then 0 else user_in_drama_total_review_num end

-- CREATE TEMPORARY TABLE sound_time AS (
--     SELECT t3.sound_id, t4.drama_id, t3.sound_info_created_time
--     FROM maoer.sound_info t3
--     JOIN (
--         SELECT t1.drama_id, t1.sound_id
--         FROM maoer.drama_episodes t1
--         JOIN (
--             SELECT sound_id, drama_id
--             FROM activeuser_submit_danmu_sound_with_drama
--             GROUP BY sound_id
--         ) t2 ON t1.drama_id = t2.drama_id
--     ) t4 ON t3.sound_id = t4.sound_id
--     GROUP BY t3.sound_id
-- );
--
-- SELECT t1.sound_id, TIMESTAMPDIFF(DAY, t3.firsttime, t2.sound_info_created_time) AS date_diff
-- FROM sound_feature t1
-- JOIN maoer.sound_info t2 ON t1.sound_id = t2.sound_id
-- JOIN (
--     SELECT drama_id, MIN(sound_info_created_time) AS firsttime
--     FROM sound_time
--     GROUP BY drama_id
-- ) t3 ON t1.sound_id = t2.sound_id;
--
-- SELECT t1.sound_id, PERCENT_RANK() over(partition by t2.drama_id order by t2.sound_info_created_time ) as rank_percent
-- FROM sound_feature t1
-- JOIN sound_time t2 ON t1.sound_id = t2.sound_id

-- 15s_time traffic
-- 先找声音总时长
-- create table sound_danmu_traffic_feature as
-- select t1.sound_id,t3.danmu_id,t2.sound_info_duration,t3.danmu_info_stime_notransform,CEIL(t3.danmu_info_stime_notransform/30) as 30s_position_in_sound,t3.danmu_info_stime_notransform/sound_info_duration as position_in_sound
-- from sound_feature t1
-- left join (select sound_id,sound_info_duration
-- from maoer.sound_info_update
-- group by sound_id) t2 on t1.sound_id=t2.sound_id
-- left join (select sound_id,danmu_id,danmu_info_stime_notransform
-- from maoer.danmu_info
-- group by sound_id,danmu_id) t3 on t3.sound_id=t1.sound_id

-- ******************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************

-- 20232011 重写
-- 命名： LY_xxx_feature_202301

-- 查找活跃声音的播放量等信息
-- select min(sound_info_view_count),avg(sound_info_view_count),max(sound_info_view_count),min(sound_info_danmu_count),avg(sound_info_danmu_count),max(sound_info_danmu_count),min(sound_info_favorite_count)
-- from maoer.active_sound

-- 重建活跃声音表——添加2023新增的声音
-- create table active_sound_add2023sound
-- select distinct a.sound_id,b.sound_info_view_count,b.sound_info_danmu_count,b.sound_info_favorite_count,b.sound_info_all_reviews_num,b.sound_info_point,e.sound_info_pay_type,d.drama_info_price,f.sound_info_created_time,b.created_time
-- from maoer.active_sound a
-- join maoer.sound_info f on a.sound_id=f.sound_id
-- join maoer.sound_info_update b on a.sound_id=b.sound_id
-- join maoer.drama_episodes c on a.sound_id=c.sound_id
-- join maoer.drama_info_update d on c.drama_id=d.drama_id
-- join maoer.sound_info e on a.sound_id=e.sound_id
--
-- INSERT INTO maoer.active_sound_add2023sound
-- select distinct a.sound_id,b.sound_info_view_count,b.sound_info_danmu_count,b.sound_info_favorite_count,b.sound_info_all_reviews_num,b.sound_info_point,e.sound_info_pay_type,d.drama_info_price,a.sound_info_created_time,b.created_time
-- from maoer.sound_info a
-- join maoer.sound_info_update b on a.sound_id=b.sound_id
-- join maoer.drama_episodes c on a.sound_id=c.sound_id
-- join maoer.drama_info_update d on c.drama_id=d.drama_id
-- join maoer.sound_info e on a.sound_id=e.sound_id
-- where a.sound_info_created_time>='2023-01-01'
-- and
-- (b.sound_info_view_count>72637 or b.sound_info_danmu_count>1525)


-- 创建活跃用户在2022年11月之后-2023年3月发表过弹幕的声音
-- select b.user_id,b.sound_id
-- from maoer.danmu_info_2022 b
-- where b.user_id in (select user_id from maoer.active_users_audience_delete_zimu_users) and  b.danmu_info_date>='2022-11-01'
create table activeuser_submit_danmu_sound_202211_202303 as
select a.user_id,b.sound_id,b.danmu_id,b.danmu_info_date
from maoer.active_users_audience_delete_zimu_users a
left join (
select danmu_id,sound_id,user_id,danmu_info_date from maoer.danmu_info_2022
where danmu_info_date>='2022-11-01'
)b on a.user_id=b.user_id


-- select distinct a.user_id,a.sound_id
-- from danmu_info_2023 a
-- inner join (select user_id from maoer.active_users_audience_delete_zimu_users) c on a.user_id=c.user_id
insert into activeuser_submit_danmu_sound_202211_202303
select a.user_id,b.sound_id,b.danmu_id,b.danmu_info_date
from maoer.active_users_audience_delete_zimu_users a
left join (
select danmu_id,sound_id,user_id,danmu_info_date from maoer_data_analysis.danmu_info_2023
)b on a.user_id=b.user_id

select DISTINCT ud.user_id,ud.sound_id,max(ud.danmu_info_date) as danmu_submit_time
from maoer_data_analysis.danmu_info_2023 as ud
where ud.user_id in (select user_id from maoer.active_users_audience)
group by ud.user_id,ud.sound_id

create table 0301_0331_sound_feature
select t1.sound_id,LENGTH(t2.sound_info_name),LENGTH(t3.sound_info_intro),t4.tag_num,t2.sound_info_pay_type,t2.sound_info_type,t3.sound_info_duration,t3.sound_info_view_count,
t3.sound_info_danmu_count,t3.sound_info_favorite_count,t3.sound_info_point,t3.sound_info_review_count,t3.sound_info_sub_review_count,t3.sound_info_download
from (select distinct sound_id from active_sound_exceed_avg) t1
left JOIN maoer.sound_info t2 ON t1.sound_id = t2.sound_id
join (select * from maoer.sound_info_update where created_time>'2023-03-01' and created_time<'2023-03-31' group by sound_id) t3 on t1.sound_id=t3.sound_id
join (
SELECT e.sound_id, COUNT(*) AS tag_num
    FROM maoer.sound_tags AS e
    GROUP BY e.sound_id
) as t4 on t1.sound_id=t4.sound_id

select * from activeuser_with_danmu_sound_add2023 where user_id='189736' and sound_id='4568690'
-- 查看上面时间窗内活跃用户发表有弹幕的声音(count:39339)与活跃声音(count:105594)的交集数量  result：39177  (已存表active_sound_with_activeuser2022add2023)
select COUNT(DISTINCt sound_id)
from maoer.active_sound_add2023sound a
inner join activeuser_havedanmu_sound_2022aad2023 b on a.sound_id=b.sound_id
-- 生成上面的数据集 包含sound_id,sound_info_view_count,sound_info_pay_type
-- select DISTINCt maoer.active_sound.sound_id,viewcount.sound_info_view_count,maoer.sound_info.sound_info_pay_type
-- from maoer.active_sound join (SELECT sound_id, MAX(created_time) AS last_update_time,sound_info_view_count
-- FROM maoer.sound_info_update
-- GROUP BY sound_id ) as viewcount
-- on maoer.active_sound.sound_id=viewcount.sound_id
-- join maoer.sound_info on maoer.active_sound.sound_id=maoer.sound_info.sound_id
-- WHERE maoer.active_sound.sound_id
-- in (SELECT sound_id
-- FROM maoer_data_analysis.activeuser_havedanmu_sound)
-- order by viewcount.sound_info_view_count desc

create table activeuser_submit_danmu_sound_with_drama_202211_202303
select *
from activeuser_submit_danmu_sound_with_drama_202211_202303_repeat
group by danmu_id

select a.sound_id,avg(LENGTH(a.danmu_info_text)) as danmu_len_avg,max(LENGTH(a.danmu_info_text)) as danmu_len_max,min(LENGTH(a.danmu_info_text)) as danmu_len_min,
max(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_max,
min(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_min,
avg(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_avg,
sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>7 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_7days_num,
sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>14 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_14days_num,
sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>30 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_30days_num
from (
select distinct e.danmu_id,e.sound_id,e.danmu_info_text,e.danmu_info_date
from maoer.danmu_info as e where e.danmu_info_date<'2022-11-30') as a
right join (
select distinct c.sound_id,b.sound_info_created_time
from maoer.sound_info b
join (
select distinct sound_id
from activeuser_with_danmu_sound_all
where danmu_submit_time>='2022-11-01' and danmu_submit_time<='2022-11-30') c on b.sound_id=c.sound_id
) as f on a.sound_id=f.sound_id
group by a.sound_id

select *
from danmu_involved_activeuser_202211_202303_allinfo where sound_id=1247973 group by sound_id

select sound_id
from lingyun_maoer_analysis_time.danmu_involved_activeuser_202211_202303_allinfo
group by sound_id
ORDER BY sound_id desc
limit 10

-- 时间窗逻辑 2022.11-2023.3用一个月信息预测半个月信息
-- 窗口1: 11月-12月     1101_1130 预测 12月  - 12.5月  1201-1215
-- 窗口2: 11.5月-12.5月 1115-1215 预测 12.5月- 1月     1216-1231
-- 窗口3: 12月-1月      1201-1231 预测 1月   - 1.5月   0101-0115
-- 窗口4: 12.5月-1.5月  1215-0115 预测 1.5月 - 2月     0116-0131
-- 窗口5: 1月-2月       0101-0131 预测 2月   - 2.5月   0201-0215
-- 窗口6: 1.5月-2.5月   0115-0215 预测 2.5月 - 3月     0216-0230
-- 窗口7: 2月-3月       0201-0230 预测 3月   - 3.5月   0301-0315








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
-- from maoer_data_analysis.sound_feature t1
-- left join (select sound_id,sound_info_duration
-- from maoer.sound_info_update
-- group by sound_id) t2 on t1.sound_id=t2.sound_id
-- left join (select sound_id,danmu_id,danmu_info_stime_notransform 
-- from maoer.danmu_info 
-- group by sound_id,danmu_id) t3 on t3.sound_id=t1.sound_id

-- create table supply_sound_danmu_traffic_feature as
-- select t1.sound_id,t3.danmu_id,t2.sound_info_duration,t3.danmu_info_stime_notransform,CEIL(t3.danmu_info_stime_notransform/30) as 30s_position_in_sound,t3.danmu_info_stime_notransform/sound_info_duration as position_in_sound
-- from supply_sound_feature t1
-- left join (select sound_id,sound_info_duration
-- from maoer.sound_info_update
-- group by sound_id) t2 on t1.sound_id=t2.sound_id
-- left join (select sound_id,danmu_id,danmu_info_stime_notransform 
-- from maoer.danmu_info 
-- group by sound_id,danmu_id) t3 on t3.sound_id=t1.sound_id

-- 统计声音30straffic的临时表
-- create table temp_sound_traffic_count as 
-- select sound_id,30s_position_in_sound,count(30s_position_in_sound) as 30s_num,position_in_sound
-- from maoer_data_analysis.sound_danmu_traffic_feature 
-- group by sound_id,30s_position_in_sound

-- update maoer_data_analysis.sound_feature t1 join 
-- (
-- select sound_id,max(30s_num) as max_30s_num,min(30s_num)as min_30s_num,avg(30s_num) as avg_30s_num
-- from temp_sound_traffic_count
-- group by sound_id
-- )t2 on t1.sound_id=t2.sound_id
-- SET
-- t1.sound_danmu_30s_max_traffic= t2.max_30s_num,
-- t1.sound_danmu_30s_min_traffic= t2.min_30s_num,
-- t1.sound_danmu_30s_avg_traffic= t2.avg_30s_num

-- update maoer_data_analysis.sound_feature t1 join 
-- (
-- select sound_id,30s_num,position_in_sound
-- from temp_sound_traffic_count
-- group by sound_id,30s_num
-- )t2 on t1.sound_id=t2.sound_id and t1.sound_danmu_30s_min_traffic=t2.30s_num
-- SET
-- -- t1.sound_danmu_30s_max_traffic_position_in_sound=t2.position_in_sound
-- t1.sound_danmu_30s_min_traffic_position_in_sound=t2.position_in_sound



-- ******************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************

-- 20232011 重写
-- 命名： LY_xxx_feature_202301

-- 查找活跃声音的播放量等信息
-- 1,72637,24665666,0,1525,1008778,0,240
-- select min(sound_info_view_count),avg(sound_info_view_count),max(sound_info_view_count),min(sound_info_danmu_count),avg(sound_info_danmu_count),max(sound_info_danmu_count),min(sound_info_favorite_count),avg(sound_info_favorite_count)
-- from maoer.active_sound

-- 查找活跃声音中满足上述avg的声音量：11291 并建表：active_sound_exceed_avg
-- create table active_sound_exceed_avg as
-- select *
-- from maoer.active_sound_add2023sound
-- where (sound_info_view_count>72637 or sound_info_danmu_count>1525) and sound_info_favorite_count>240

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
-- create table activeuser_submit_danmu_sound_202211_202303 as
-- select a.user_id,b.sound_id,b.danmu_id,b.danmu_info_date
-- from maoer.active_users_audience_delete_zimu_users a
-- left join (
-- select danmu_id,sound_id,user_id,danmu_info_date from maoer.danmu_info_2022 
-- where danmu_info_date>='2022-11-01'
-- )b on a.user_id=b.user_id


-- select distinct a.user_id,a.sound_id
-- from danmu_info_2023 a
-- inner join (select user_id from maoer.active_users_audience_delete_zimu_users) c on a.user_id=c.user_id
-- insert into activeuser_submit_danmu_sound_202211_202303
-- select a.user_id,b.sound_id,b.danmu_id,b.danmu_info_date
-- from maoer.active_users_audience_delete_zimu_users a
-- left join (
-- select danmu_id,sound_id,user_id,danmu_info_date from maoer_data_analysis.danmu_info_2023 
-- )b on a.user_id=b.user_id

-- 查看上面时间窗内活跃用户发表有弹幕的声音(count:25000+)与活跃声音_exceed_avg表(count:11291)的交集数量  result：11291  (已存表active_sound_with_activeuser2022add2023)
-- select COUNT(DISTINCt b.sound_id)
-- from maoer.active_sound_add2023sound a
-- inner join -- activeuser_submit_danmu_sound_202211_202303 b 
-- (select distinct sound_id
-- from active_sound_exceed_avg
-- ) b
-- on a.sound_id=b.sound_id

-- 建表-活跃用户发表弹幕的剧集
-- create table activeuser_submit_danmu_sound_with_drama_202211_202303 as 
-- select a.user_id,a.sound_id,b.drama_id,a.danmu_id,a.danmu_info_date
-- from activeuser_submit_danmu_sound_202211_202303 a 
-- left join maoer.drama_episodes b on a.sound_id=b.sound_id

-- ----------------用户特征提取（user_feature）------------------
-- 创建不同时间窗的用户特征表
-- 统计信息：1101_1130_user_feature:25812条记录；
-- 1115_1215:25043; 1201_1231:26057; 1215_0115:26257;
-- 0101_0131:24021; 0115_0215:23343; 0201_0230:20014
-- 预测部分：1201_1215:16624; 1216_1231:19387;
-- 0101_0115:16801; 0116_0131:16868; 0201_0215:14817;
-- 0216_0230:12693; 0301_0315:11139

-- create table 0101_0131_user_feature as
-- select b.user_id,
-- user_name_len,
-- user_name_has_chinese,
-- user_name_has_english,
-- user_intro_len,
-- user_intro_has_chinese,
-- user_intro_has_english,
-- user_icon_is_default,
-- user_has_submit_sound_or_darma,
-- user_grade,
-- user_fish_num,
-- user_follower_num,
-- user_fans_num,
-- user_has_organization,
-- user_submit_sound_num,
-- user_submit_drama_num,
-- user_subscribe_drama_num,
-- user_subscribe_channel_num,
-- user_favorite_album_num,
-- user_image_num
-- from maoer_data_analysis.user_feature 
-- join (select distinct user_id 
-- from activeuser_submit_danmu_sound_202211_202303
-- where danmu_info_date>='2023-01-01'
--   and danmu_info_date<='2023-01-31' 
-- ) b on user_feature.user_id=b.user_id
-- 
-- select count(1) from 0301_0315_user_feature

-- ALTER TABLE 0101_0131_user_feature
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

-- 用户发布弹幕的剧集中已完结剧集的数量
-- 逻辑：用户发布弹幕的剧集中当前月份已完结的剧集数量
--       找到当前月份月底之后没有再更新的剧集数量，3月直接统计是否连载值
-- 更新表 activeuser_submit_danmu_sound_with_drama_202211_202303 给出剧集是否在10月底完结，是否在11月底完结，...,是否在3月完结
-- (0是完结，1是连载)
-- create table drama_end_time_202211_202303 as
-- select c.drama_id,
-- (case when sum(case when a.sound_info_created_time>'2022-10-30' then 1 else 0 end)>0 then 1 else 0 end) as drama_not_end_in20221030,
-- (case when sum(case when a.sound_info_created_time>'2022-11-30' then 1 else 0 end)>0 then 1 else 0 end) as drama_not_end_in20221130,
-- (case when sum(case when a.sound_info_created_time>'2022-12-31' then 1 else 0 end)>0 then 1 else 0 end) as drama_not_end_in20221231,
-- (case when sum(case when a.sound_info_created_time>'2023-01-31' then 1 else 0 end)>0 then 1 else 0 end) as drama_not_end_in20230131,
-- (case when sum(case when a.sound_info_created_time>'2023-02-30' then 1 else 0 end)>0 then 1 else 0 end) as drama_not_end_in20230230
-- from maoer.sound_info a
-- join maoer.drama_episodes b on a.sound_id=b.sound_id
-- right join 
-- (select distinct drama_id
-- from maoer.drama_info) c
-- on b.drama_id=c.drama_id
-- group by c.drama_id

-- alter table drama_end_time_202211_202303
-- add COLUMN drama_not_end_in20230331 int(1)

-- UPDATE drama_end_time_202211_202303 AS t1
-- JOIN (
--     SELECT DISTINCT a.drama_id ,a.drama_info_serialize as drama_not_end_in20230331
--     from maoer.drama_info_update a
-- 		right join drama_end_time_202211_202303 c
-- 		on a.drama_id=c.drama_id
--     WHERE a.created_time>='2023-03-01'
-- 		group by c.drama_id
-- ) AS t2
-- ON t1.drama_id = t2.drama_id
-- SET t1.drama_not_end_in20230331 = t2.drama_not_end_in20230331;

-- UPDATE drama_end_time_202211_202303 AS t1
-- join (
-- select * from drama_end_time_202211_202303 where drama_not_end_in20230331 is null
-- ) t2 on t1.drama_id=t2.drama_id
-- set 
-- t1.drama_not_end_in20230331=(case when t2.drama_not_end_in20230230=0 then 0 else 1 end)

-- update 1216_1231_user_feature t1
-- join (
-- select a.user_id,sum(case when b.drama_not_end_in20221130=0 then 1 else 0 end) as count_drama
-- from maoer_data_analysis.activeuser_submit_danmu_sound_with_drama a
-- join drama_end_time_202211_202303 b on b.drama_id=a.drama_id
-- group by user_id)t2 on t1.user_id=t2.user_id
-- set
-- t1.user_submit_danmu_drama_completed_num=t2.count_drama


-- select count(1) from maoer.sound_info b 
-- join (select sound_id from maoer_data_analysis.activeuser_submit_danmu_sound_with_drama group by sound_id) a on a.sound_id=b.sound_id
-- where b.sound_info_created_time<'2022-01-01'

-- create table activeuser_with_danmu_sound_add2023
-- select DISTINCT ud.user_id,ud.sound_id,max(ud.danmu_info_date) as danmu_submit_time
-- from maoer_data_analysis.danmu_info_2023 as ud
-- where ud.user_id in (select user_id from maoer.active_users_audience)
-- group by ud.user_id,ud.sound_id
-- union 
-- select * from maoer_data_analysis.activeuser_with_danmu_sound
-- 
-- select a.*,max(b.danmu_info_date) as danmu_submit_time 
-- from maoer_data_analysis.activeuser_with_danmu_sound a 
-- join (select user_id,sound_id,danmu_info_date 
-- from maoer.danmu_info )b 
-- on a.sound_id=b.sound_id and a.user_id=b.user_id
-- group by a.user_id,a.sound_id
-- 
-- update activeuser_submit_danmu_sound_with_drama_add2023 t1
-- select ud.user_id,ud.sound_id,a.drama_id
-- from activeuser_with_danmu_sound_add2023 as ud
-- join maoer.drama_episodes a on ud.sound_id=a.sound_id
-- group by ud.user_id,ud.sound_id

-- UPDATE user_feature AS t1
-- JOIN (
--     SELECT a.user_id, COUNT(DISTINCT a.drama_id) AS count
--     FROM activeuser_drama_and_sound_info AS a
--     WHERE a.drama_info_serialize = '0'
--     GROUP BY a.user_id
-- ) AS t2
-- ON t1.user_id = t2.user_id
-- SET t1.user_submit_danmu_drama_completed_num = t2.count;

-- 用户在当前时间窗内发布弹幕的剧集的播放量/弹幕数量/评论量
-- 逻辑：在当前时间窗末之前发布过弹幕的剧集的总播放量
-- alter table activeuser_submit_danmu_sound_with_drama_add2023
-- add COLUMN danmu_info_date int(11)
-- 
-- update activeuser_submit_danmu_sound_with_drama_all t1 join (
-- select 
-- from activeuser_submit_danmu_sound_with_drama_add2023 a
-- join select maoer.danmu_info b on a.user_id=b.user_id and a.sound_id=b.sound_id
-- )

-- alter table 1216_1231_user_feature
-- add COLUMN user_submit_danmu_drama_completed_num_now int(11)

-- update 1216_1231_user_feature t1 join 
-- (
-- select t3.user_id,
-- sum(case when t5.drama_is_serialize=0 then 1 else 0 end) as user_submit_danmu_drama_completed_num_now,
-- sum(t5.drama_total_view_num) as user_submit_danmu_drama_total_view_num,
-- max(t5.drama_total_view_num) as user_submit_danmu_drama_max_view_num,
-- min(t5.drama_total_view_num) as user_submit_danmu_drama_min_view_num,
-- avg(t5.drama_total_view_num) as user_submit_danmu_drama_avg_view_num,
-- sum(t5.drama_total_danmu_num) as user_submit_danmu_drama_total_danmu_num,
-- max(t5.drama_total_danmu_num) as user_submit_danmu_drama_max_danmu_num,
-- min(t5.drama_total_danmu_num) as user_submit_danmu_drama_min_danmu_num,
-- avg(t5.drama_total_danmu_num) as user_submit_danmu_drama_avg_danmu_num,
-- sum(t5.drama_total_review_num) as user_submit_danmu_drama_total_review_num,
-- max(t5.drama_total_review_num) as user_submit_danmu_drama_max_review_num,
-- min(t5.drama_total_review_num) as user_submit_danmu_drama_min_review_num,
-- avg(t5.drama_total_review_num) as user_submit_danmu_drama_avg_review_num
-- from 1216_1231_user_feature t3 
-- left join (select user_id,drama_id from activeuser_submit_danmu_sound_with_drama_202211_202303
-- where danmu_info_date>='2022-12-16' and danmu_info_date<='2022-12-31' group by user_id,drama_id) t4 on t3.user_id=t4.user_id
-- left join 1216_1231_drama_feature t5 on t4.drama_id=t5.drama_id
-- group by t3.user_id
-- )t2 on t1.user_id=t2.user_id
-- set
-- t1.user_submit_danmu_drama_completed_num_now = t2.user_submit_danmu_drama_completed_num_now,
-- t1.user_submit_danmu_drama_total_view_num = t2.user_submit_danmu_drama_total_view_num/10000,
-- t1.user_submit_danmu_drama_max_view_num = t2.user_submit_danmu_drama_max_view_num,
-- t1.user_submit_danmu_drama_min_view_num = t2.user_submit_danmu_drama_min_view_num,
-- t1.user_submit_danmu_drama_avg_view_num = t2.user_submit_danmu_drama_avg_view_num,
-- t1.user_submit_danmu_drama_total_danmu_num = t2.user_submit_danmu_drama_total_danmu_num/10000,
-- t1.user_submit_danmu_drama_max_danmu_num = t2.user_submit_danmu_drama_max_danmu_num ,
-- t1.user_submit_danmu_drama_min_danmu_num = t2.user_submit_danmu_drama_min_danmu_num,
-- t1.user_submit_danmu_drama_avg_danmu_num = t2.user_submit_danmu_drama_avg_danmu_num,
-- t1.user_submit_danmu_drama_total_review_num = t2.user_submit_danmu_drama_total_review_num,
-- t1.user_submit_danmu_drama_max_review_num = t2.user_submit_danmu_drama_max_review_num,
-- t1.user_submit_danmu_drama_min_review_num = t2.user_submit_danmu_drama_min_review_num ,
-- t1.user_submit_danmu_drama_avg_review_num = t2.user_submit_danmu_drama_avg_review_num

-- alter table 1216_1231_user_feature
-- add COLUMN user_submit_danmu_sound_total_view_num int(11),
-- add COLUMN user_submit_danmu_sound_max_view_num int(11),
-- add COLUMN user_submit_danmu_sound_min_view_num int(11),
-- add COLUMN user_submit_danmu_sound_avg_view_num double,
-- add COLUMN user_submit_danmu_sound_total_danmu_num int(11),
-- add COLUMN user_submit_danmu_sound_max_danmu_num int(11),
-- add COLUMN user_submit_danmu_sound_min_danmu_num int(11),
-- add COLUMN user_submit_danmu_sound_avg_danmu_num double,
-- add COLUMN user_submit_danmu_sound_total_review_num int(11),
-- add COLUMN user_submit_danmu_sound_max_review_num int(11),
-- add COLUMN user_submit_danmu_sound_min_review_num int(11),
-- add COLUMN user_submit_danmu_sound_avg_review_num double

-- sound天数差值 11.30(7) 12.15(22) 12.31(38) 01.15(53) 01.31(69) 02.15(84) 02.28(97) 03.15(112) 
-- update 1216_1231_user_feature t1 join 
-- (
-- select t3.user_id,
-- sum(t5.sound_info_view_count) as user_submit_danmu_sound_total_view_num,
-- max(t5.sound_info_view_count) as user_submit_danmu_sound_max_view_num,
-- min(t5.sound_info_view_count) as user_submit_danmu_sound_min_view_num,
-- avg(t5.sound_info_view_count) as user_submit_danmu_sound_avg_view_num,
-- sum(t5.sound_info_danmu_count) as user_submit_danmu_sound_total_danmu_num,
-- max(t5.sound_info_danmu_count) as user_submit_danmu_sound_max_danmu_num,
-- min(t5.sound_info_danmu_count) as user_submit_danmu_sound_min_danmu_num,
-- avg(t5.sound_info_danmu_count) as user_submit_danmu_sound_avg_danmu_num,
-- sum(t5.sound_info_all_reviews_num) as user_submit_danmu_sound_total_review_num,
-- max(t5.sound_info_all_reviews_num) as user_submit_danmu_sound_max_review_num,
-- min(t5.sound_info_all_reviews_num) as user_submit_danmu_sound_min_review_num,
-- avg(t5.sound_info_all_reviews_num) as user_submit_danmu_sound_avg_review_num
-- from 1216_1231_user_feature t3 
-- left join (select user_id,sound_id from activeuser_submit_danmu_sound_with_drama_202211_202303
-- where danmu_info_date>='2022-12-16' and danmu_info_date<='2022-12-31' group by user_id,sound_id) t4 on t3.user_id=t4.user_id
-- left join (select sound_id,sound_info_view_count,sound_info_danmu_count,sound_info_all_reviews_num 		  from sound_feature_osl_pred_true 
-- 			where datediff_between_1123_to_updatetime = 38 group by sound_id) t5 on t4.sound_id=t5.sound_id
-- group by t3.user_id
-- )t2 on t1.user_id=t2.user_id
-- set
-- t1.user_submit_danmu_sound_total_view_num = t2.user_submit_danmu_sound_total_view_num/10000,
-- t1.user_submit_danmu_sound_max_view_num = t2.user_submit_danmu_sound_max_view_num ,
-- t1.user_submit_danmu_sound_min_view_num = t2.user_submit_danmu_sound_min_view_num ,
-- t1.user_submit_danmu_sound_avg_view_num = t2.user_submit_danmu_sound_avg_view_num,
-- t1.user_submit_danmu_sound_total_danmu_num = t2.user_submit_danmu_sound_total_danmu_num/10000,
-- t1.user_submit_danmu_sound_max_danmu_num = t2.user_submit_danmu_sound_max_danmu_num ,
-- t1.user_submit_danmu_sound_min_danmu_num = t2.user_submit_danmu_sound_min_danmu_num,
-- t1.user_submit_danmu_sound_avg_danmu_num = t2.user_submit_danmu_sound_avg_danmu_num,
-- t1.user_submit_danmu_sound_total_review_num = t2.user_submit_danmu_sound_total_review_num ,
-- t1.user_submit_danmu_sound_max_review_num = t2.user_submit_danmu_sound_max_review_num ,
-- t1.user_submit_danmu_sound_min_review_num = t2.user_submit_danmu_sound_min_review_num,
-- t1.user_submit_danmu_sound_avg_review_num = t2.user_submit_danmu_sound_avg_review_num

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

-- 用户对于一个声音的特征 时间窗内
-- create table 1216_1231_user_sound_feature
-- select user_id,sound_id,drama_id from activeuser_submit_danmu_sound_with_drama_202211_202303 where danmu_info_date>='2022-12-16' and danmu_info_date<='2022-12-31' group by user_id,sound_id

-- alter table 1216_1231_user_sound_feature
-- add COLUMN user_in_sound_is_submit_review int(1),
-- add COLUMN user_in_sound_submit_review_num int(11),
-- add COLUMN user_in_sound_first_review_with_sound_publish_time_diff_days int(11),
-- add COLUMN user_in_sound_latest_review_with_sound_publish_time_diff_days int(11),
-- add COLUMN user_in_sound_review_total_len int(11),
-- add COLUMN user_in_sound_review_len_max int(11),
-- add COLUMN user_in_sound_review_len_min int(11),
-- add COLUMN user_in_sound_review_len_avg double,
-- add COLUMN user_in_sound_review_subreview_total_num int(11),
-- add COLUMN user_in_sound_review_subreview_max_num int(11),
-- add COLUMN user_in_sound_review_subreview_min_num int(11),
-- add COLUMN user_in_sound_review_subreview_avg_num double,
-- add COLUMN user_in_sound_review_like_total_num int(11),
-- add COLUMN user_in_sound_review_like_max_num int(11),
-- add COLUMN user_in_sound_review_like_min_num int(11),
-- add COLUMN user_in_sound_review_like_avg_num double,
-- add COLUMN user_in_sound_is_submit_danmu int(1),
-- add COLUMN user_in_sound_submit_danmu_total_len int(11),
-- add COLUMN user_in_sound_submit_danmu_max_len int(11),
-- add COLUMN user_in_sound_submit_danmu_min_len int(11),
-- add COLUMN user_in_sound_submit_danmu_avg_len double,
-- add COLUMN user_in_sound_submit_danmu_num int(11),
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_max_num int(11),
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_min_num int(11),
-- add COLUMN user_in_sound_danmu_around_15s_total_danmu_avg_num double,
-- add COLUMN user_in_drama_total_review_num  int(11),
-- add COLUMN user_in_drama_total_danmu_num int(11),
-- add COLUMN user_in_drama_is_pay_for_drama int(1),
-- add COLUMN user_in_drama_is_in_drama_fans_reward int(1),
-- add COLUMN user_in_drama_fans_reward_total_coin  int(11),
-- add COLUMN user_in_drama_is_follower_upuser int(1)

-- update 0301_0315_user_sound_feature t1 join
-- (
-- select t3.user_id,t3.sound_id,
-- (case when t4.review_id is null then 0 else 1 end) as user_in_sound_is_submit_review,
-- sum(t4.review_id is not null) as user_in_sound_submit_review_num,
-- min(t4.review_created_time) as user_in_sound_first_review_time,
-- max(t4.review_created_time) as user_in_sound_latest_review_time,
-- sum(length(t4.review_content)) as user_in_sound_review_total_len,
-- max(length(t4.review_content)) as user_in_sound_review_len_max,
-- min(length(t4.review_content)) as user_in_sound_review_len_min,
-- avg(length(t4.review_content)) as user_in_sound_review_len_avg,
-- sum(t4.review_sub_review_num) as user_in_sound_review_subreview_total_num,
-- max(t4.review_sub_review_num) as user_in_sound_review_subreview_max_num,
-- min(t4.review_sub_review_num) as user_in_sound_review_subreview_min_num,
-- avg(t4.review_sub_review_num) as user_in_sound_review_subreview_avg_num,
-- sum(t4.review_like_num) as user_in_sound_review_like_total_num,
-- max(t4.review_like_num) as user_in_sound_review_like_max_num,
-- min(t4.review_like_num) as user_in_sound_review_like_min_num,
-- avg(t4.review_like_num) as user_in_sound_review_like_avg_num
-- from (
-- select user_id,sound_id from activeuser_submit_danmu_sound_with_drama_202211_202303 
-- where danmu_info_date>='2023-03-01' and danmu_info_date<='2023-03-15' 
-- group by user_id,sound_id) t3 
-- left join (select * from maoer.review_content 
-- 	where review_created_time>='2023-03-01' and review_created_time<='2023-03-15') t4 
-- 	on t3.user_id=t4.user_id and t3.sound_id=t4.subject_id 
-- group by t3.user_id,t3.sound_id
-- ) t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- left join (select sound_id,sound_info_created_time from maoer.sound_info group by sound_id) t5 on t2.sound_id=t5.sound_id
-- set
-- t1.user_in_sound_is_submit_review =t2.user_in_sound_is_submit_review,
-- t1.user_in_sound_submit_review_num =t2.user_in_sound_submit_review_num,
-- t1.user_in_sound_first_review_with_sound_publish_time_diff_days = datediff(t2.user_in_sound_first_review_time,t5.sound_info_created_time),
-- t1.user_in_sound_latest_review_with_sound_publish_time_diff_days = datediff(t2.user_in_sound_latest_review_time,t5.sound_info_created_time),
-- t1.user_in_sound_review_total_len =t2.user_in_sound_review_total_len ,
-- t1.user_in_sound_review_len_max =t2.user_in_sound_review_len_max ,
-- t1.user_in_sound_review_len_min =t2.user_in_sound_review_len_min ,
-- t1.user_in_sound_review_len_avg =t2.user_in_sound_review_len_avg ,
-- t1.user_in_sound_review_subreview_total_num =t2.user_in_sound_review_subreview_total_num ,
-- t1.user_in_sound_review_subreview_max_num =t2.user_in_sound_review_subreview_max_num,
-- t1.user_in_sound_review_subreview_min_num =t2.user_in_sound_review_subreview_min_num,
-- t1.user_in_sound_review_subreview_avg_num =t2.user_in_sound_review_subreview_avg_num ,
-- t1.user_in_sound_review_like_total_num =t2.user_in_sound_review_like_total_num,
-- t1.user_in_sound_review_like_max_num =t2.user_in_sound_review_like_max_num,
-- t1.user_in_sound_review_like_min_num =t2.user_in_sound_review_like_min_num ,
-- t1.user_in_sound_review_like_avg_num =t2.user_in_sound_review_like_avg_num

-- update 0301_0315_user_sound_feature t1 join 
-- (
-- select t3.user_id,t3.drama_id,sum(t3.user_in_sound_submit_review_num) as user_in_drama_total_review_num
-- from 0301_0315_user_sound_feature t3 
-- group by t3.user_id,t3.drama_id
-- ) t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_total_review_num = t2.user_in_drama_total_review_num

-- update 0101_0115_user_sound_feature t1 join
-- (
-- select t3.user_id,t3.sound_id,
-- -- sum(LENGTH(t3.danmu_info_text)) as user_in_sound_submit_danmu_total_len,
-- -- max(LENGTH(t3.danmu_info_text)) as user_in_sound_submit_danmu_max_len,
-- -- min(LENGTH(t3.danmu_info_text)) as user_in_sound_submit_danmu_min_len,
-- -- avg(LENGTH(t3.danmu_info_text)) as user_in_sound_submit_danmu_avg_len,
-- count(distinct t3.danmu_id) as user_in_sound_submit_danmu_num,
-- max(case when CEIL(t3.danmu_info_stime_notransform/30)=t4.30s_position_in_sound then t4.30s_num else 0 end ) as user_in_sound_danmu_around_15s_total_danmu_max_num,
-- min(case when CEIL(t3.danmu_info_stime_notransform/30)=t4.30s_position_in_sound then t4.30s_num else 0 end ) as user_in_sound_danmu_around_15s_total_danmu_min_num,
-- max(case when CEIL(t3.danmu_info_stime_notransform/30)=t4.30s_position_in_sound then t4.30s_num else 0 end ) as user_in_sound_danmu_around_15s_total_danmu_avg_num
-- from (select * from activeuser_submit_danmu_sound_with_drama_202211_202303 where danmu_info_date>='2023-01-01' and danmu_info_date<='2023-01-15') t3
-- left join (select * from temp_sound_traffic_count union select * from temp_supply_sound_traffic_count ) t4 on t3.sound_id=t4.sound_id and CEIL(t3.danmu_info_stime_notransform/30)=t4.30s_position_in_sound
-- left join (select sound_id,sound_info_duration from maoer.sound_info_update group by sound_id) t5 on t5.sound_id=t3.sound_id
-- group by t3.user_id,t3.sound_id
-- ) t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- set
-- -- t1.user_in_sound_is_submit_danmu =1 ,
-- -- t1.user_in_sound_submit_danmu_total_len = t2.user_in_sound_submit_danmu_total_len,
-- -- t1.user_in_sound_submit_danmu_max_len = t2.user_in_sound_submit_danmu_max_len ,
-- -- t1.user_in_sound_submit_danmu_min_len = t2.user_in_sound_submit_danmu_min_len,
-- -- t1.user_in_sound_submit_danmu_avg_len = t2.user_in_sound_submit_danmu_avg_len ,
-- t1.user_in_sound_submit_danmu_num = t2.user_in_sound_submit_danmu_num ,
-- t1.user_in_sound_danmu_around_15s_total_danmu_max_num = t2.user_in_sound_danmu_around_15s_total_danmu_max_num,
-- t1.user_in_sound_danmu_around_15s_total_danmu_min_num = t2.user_in_sound_danmu_around_15s_total_danmu_min_num ,
-- t1.user_in_sound_danmu_around_15s_total_danmu_avg_num = t2.user_in_sound_danmu_around_15s_total_danmu_avg_num

-- ALTER TABLE 0101_0131_user_sound_feature
-- ADD COLUMN user_in_drama_sound_pay_type INT(1)

-- update 0101_0115_user_sound_feature t1 join 
-- (
-- select t3.user_id,t3.drama_id,sum(t3.user_in_sound_submit_review_num) as user_in_drama_total_review_num,
-- sum(user_in_sound_submit_danmu_num) as user_in_drama_total_danmu_num
-- from 0101_0115_user_sound_feature t3 
-- group by t3.user_id,t3.drama_id
-- ) t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_total_review_num = t2.user_in_drama_total_review_num,
-- t1.user_in_drama_total_danmu_num = t2.user_in_drama_total_danmu_num

-- 太慢 弃用
-- update 0116_0131_user_sound_feature t4 join(
-- select user_id,sound_id,
-- 		(case when drama_info_pay_type=0 then 0 
-- 		when drama_info_pay_type=2 and sound_info_pay_type=0 then 1 
-- 		when drama_info_pay_type=2 and sound_info_pay_type=2 then 2
-- 		when drama_info_pay_type=1 and sound_info_pay_type=0 then 1 
-- 		when drama_info_pay_type=1 and sound_info_pay_type=1 then 2 end) as user_in_drama_sound_pay_type
-- from (
-- select t1.user_id,t1.sound_id,drama_info_pay_type,sound_info_pay_type
-- from 0116_0131_user_sound_feature t1 
-- join (select drama_id,drama_info_pay_type,drama_info_need_pay from maoer.drama_info_update group by drama_id) t2 on t1.drama_id=t2.drama_id
-- JOIN (select sound_id,sound_info_pay_type from maoer.sound_info group by sound_id) t3 on t1.sound_id=t3.sound_id
-- ) t
-- )t5 on t4.user_id=t5.user_id and t4.sound_id=t5.sound_id
-- set
-- t4.user_in_drama_sound_pay_type = t5.user_in_drama_sound_pay_type

-- 和上面的一起 弃用
-- update 0116_0131_user_sound_feature t1 join(
-- select t3.user_id,t3.drama_id,drama_info_pay_type,sum(case when user_in_drama_sound_pay_type=2 then 1 else 0 end) as user_in_drama_is_pay_for_drama
-- from 0116_0131_user_sound_feature t3 
-- join (select drama_id,drama_info_pay_type,drama_info_need_pay from maoer.drama_info_update group by drama_id) t2 on t3.drama_id=t2.drama_id
-- group by t3.user_id,t3.drama_id
-- )t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_is_pay_for_drama =(case when t2.drama_info_pay_type=0 then 0 when t2.drama_info_pay_type=1 and t2.user_in_drama_is_pay_for_drama>=1 then 1 when t2.drama_info_pay_type=2 and t2.user_in_drama_is_pay_for_drama>=1 then 1 else 2 end )

-- alter table 1101_1130_user_sound_feature
-- add COLUMN drama_info_pay_type int(1),
-- add COLUMN sound_info_pay_type int(1)
-- 
-- update 0116_0131_user_sound_feature t1 left join 
-- (select drama_id,drama_info_pay_type,drama_info_need_pay from maoer.drama_info_update group by drama_id) t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_info_pay_type=t2.drama_info_pay_type
-- 
-- update 0115_0215_user_sound_feature t1 left join 
-- (select sound_id,sound_info_pay_type from maoer.sound_info group by sound_id) t3 on t1.sound_id=t3.sound_id
-- set 
-- t1.sound_info_pay_type=t3.sound_info_pay_type

-- ALTER TABLE 1216_1231_user_sound_feature
-- ADD COLUMN user_in_drama_sound_pay_type INT(1)

-- update 1216_1231_user_sound_feature 
-- set
-- user_in_drama_sound_pay_type = (case when drama_info_pay_type=0 then 0 
-- 		when drama_info_pay_type=2 and sound_info_pay_type=0 then 1 
-- 		when drama_info_pay_type=2 and sound_info_pay_type=2 then 2
-- 		when drama_info_pay_type=1 and sound_info_pay_type=0 then 1 
-- 		when drama_info_pay_type=1 and sound_info_pay_type=1 then 2 end)

-- 旧
-- update 1216_1231_user_sound_feature t1 join(
-- select t3.user_id,t3.drama_id,drama_info_pay_type,sum(case when user_in_drama_sound_pay_type=2 then 1 else 0 end) as user_in_drama_is_pay_for_drama
-- from 1216_1231_user_sound_feature t3 
-- group by t3.user_id,t3.drama_id
-- )t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_is_pay_for_drama =(case when t2.drama_info_pay_type=0 then 0 when t2.drama_info_pay_type=1 and t2.user_in_drama_is_pay_for_drama>=1 then 1 when t2.drama_info_pay_type=2 and t2.user_in_drama_is_pay_for_drama>=1 then 1 else 2 end )

-- alter table 1101_1130_user_sound_feature
-- add COLUMN user_in_drama_is_pay_for_drama_in_next_time int(1)
-- 
-- update 1101_1130_user_sound_feature t1 join(
-- select t3.user_id,t3.drama_id,t3.drama_info_pay_type,sum(case when t4.user_in_drama_sound_pay_type=2 then 1 else 0 end) as user_in_drama_is_pay_for_drama
-- from 1101_1130_user_sound_feature t3
-- left join (
-- select user_id,drama_id,user_in_drama_sound_pay_type from 1101_1130_user_sound_feature union
-- select user_id,drama_id,user_in_drama_sound_pay_type from 1201_1215_user_sound_feature) t4 on t3.user_id=t4.user_id and t3.drama_id=t4.drama_id
-- group by t3.user_id,t3.drama_id
-- )t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_is_pay_for_drama_in_next_time =(case when t2.drama_info_pay_type=0 then 0 when t2.drama_info_pay_type=1 and t2.user_in_drama_is_pay_for_drama>=1 then 1 when t2.drama_info_pay_type=2 and t2.user_in_drama_is_pay_for_drama>=1 then 1 else 2 end )




-- --------------------声音特征提取sound_feature----------------------
-- 创建时间窗内的表
-- insert into 1215_0115_sound_feature(sound_id)
-- select distinct sound_id
-- from activeuser_with_danmu_sound_all 
-- where danmu_submit_time>='2022-12-15' and danmu_submit_time<='2023-01-15'

-- 活跃用户在2022-11-01到2023-03-31发布过弹幕的活跃声音的总表 count=23704
-- create table activeuser_has_danmu_activesound_until202303
-- select distinct a.sound_id,b.sound_info_created_time
-- from activeuser_with_danmu_sound_all a 
-- join maoer.active_sound_add2023sound b on a.sound_id=b.sound_id
-- where danmu_submit_time>='2022-11-01' and danmu_submit_time<='2023-03-31'

-- 检查与maoer_data_analysis.sound_feature的声音交集 count=22714  还有990个sound没有统计
-- 创建补充的声音特征表
-- create table supply_sound_feature as
-- select distinct a.sound_id
-- from activeuser_has_danmu_activesound_until202303 a 
-- left join maoer_data_analysis.sound_feature b
-- on a.sound_id=b.sound_id
-- where b.sound_id is null

-- select count(distinct a.sound_id)
-- from activeuser_with_danmu_sound_all a 
-- join maoer.active_sound_add2023sound b on a.sound_id=b.sound_id
-- where danmu_submit_time>='2022-11-01' and danmu_submit_time<='2023-03-31'

-- 在每个时窗表内添加时间
-- update 1216_1231_sound_feature t1 join 
-- maoer.sound_info t2 on t1.sound_id=t2.sound_id
-- set
-- t1.sound_info_created_time=t2.sound_info_created_time


-- 更新表
-- update 1216_1231_sound_feature t1 join 
-- -- temp_sound_feature_0101_0131 t2 on t1.sound_id=t2.sound_id
-- maoer_data_analysis.sound_feature t2 on t1.sound_id=t2.sound_id
-- -- supply_sound_feature t2 on t1.sound_id=t2.sound_id
-- set
-- t1.sound_title_len = t2.sound_title_len,
-- t1.sound_intro_len = t2.sound_intro_len,
-- t1.sound_tag_num = t2.sound_tag_num,
-- t1.sound_pay_type = t2.sound_pay_type,
-- t1.sound_type = t2.sound_type ,
-- t1.sound_time = t2.sound_time ,
-- t1.sound_view_num = t2.sound_view_num ,
-- t1.sound_danmu_num = t2.sound_danmu_num ,
-- t1.sound_favorite_num = t2.sound_favorite_num,
-- t1.sound_point_num = t2.sound_point_num,
-- t1.sound_review_not_subreview_num = t2.sound_review_not_subreview_num ,
-- t1.sound_review_subreview_num = t2.sound_review_subreview_num,
-- t1.sound_is_allow_download = t2.sound_is_allow_download ,
-- t1.sound_submit_time_between_first_and_this = t2.sound_submit_time_between_first_and_this,
-- t1.sound_position_in_total_darma_sound = t2.sound_position_in_total_darma_sound,
-- t1.sound_view_num_in_total_darma_percent = t2.sound_view_num_in_total_darma_percent,
-- t1.sound_danmu_num_in_total_darma_percent = t2.sound_danmu_num_in_total_darma_percent ,
-- t1.sound_favorite_num_in_total_darma_percent = t2.sound_favorite_num_in_total_darma_percent ,
-- t1.sound_point_num_in_total_darma_percent = t2.sound_point_num_in_total_darma_percent,
-- t1.sound_review_num_in_total_darma_percent = t2.sound_review_num_in_total_darma_percent ,
-- t1.sound_not_subreview_num_in_total_darma_percent = t2.sound_not_subreview_num_in_total_darma_percent ,
-- t1.sound_subreview_num_in_total_darma_percent = t2.sound_subreview_num_in_total_darma_percent 

-- update 1215_0115_sound_feature t1 join 
-- maoer_data_analysis.sound_feature t2 on t1.sound_id=t2.sound_id
-- -- supply_sound_feature t2 on t1.sound_id=t2.sound_id
-- set
-- -- t1.sound_danmu_15s_max_traffic = t2.sound_danmu_15s_max_traffic,
-- -- t1.sound_danmu_15s_min_traffic = t2.sound_danmu_15s_min_traffic,
-- -- t1.sound_danmu_15s_avg_traffic = t2.sound_danmu_15s_avg_traffic,
-- -- t1.sound_danmu_15s_max_traffic_position_in_sound = t2.sound_danmu_15s_max_traffic_position_in_sound,
-- -- t1.sound_danmu_15s_min_traffic_position_in_sound = t2.sound_danmu_15s_min_traffic_position_in_sound,
-- t1.sound_cv_total_num = t2.sound_cv_total_num,
-- t1.sound_cv_has_userid_num = t2.sound_cv_has_userid_num,
-- t1.sound_cv_total_fans_num = t2.sound_cv_total_fans_num,
-- t1.sound_cv_max_fans_num = t2.sound_cv_max_fans_num,
-- t1.sound_cv_min_fans_num = t2.sound_cv_min_fans_num,
-- t1.sound_cv_avg_fans_num = t2.sound_cv_avg_fans_num,
-- t1.sound_cv_main_cv_total_fans_num = t2.sound_cv_main_cv_total_fans_num,
-- t1.sound_cv_main_cv_max_fans_num = t2.sound_cv_main_cv_max_fans_num,
-- t1.sound_cv_main_cv_min_fans_num = t2.sound_cv_main_cv_min_fans_num,
-- t1.sound_cv_main_cv_avg_fans_num = t2.sound_cv_main_cv_avg_fans_num,
-- t1.sound_cv_auxiliary_cv_max_fans_num = t2.sound_cv_auxiliary_cv_max_fans_num,
-- t1.sound_cv_auxiliary_cv_min_fans_num = t2.sound_cv_auxiliary_cv_min_fans_num,
-- t1.sound_cv_auxiliary_cv_avg_fans_num = t2.sound_cv_auxiliary_cv_avg_fans_num,
-- t1.sound_tag_total_cite_num = t2.sound_tag_total_cite_num,
-- t1.sound_tag_max_cite_num = t2.sound_tag_max_cite_num,
-- t1.sound_tag_min_cite_num = t2.sound_tag_min_cite_num,
-- t1.sound_tag_avg_cite_num = t2.sound_tag_avg_cite_num,
-- t1.sound_tag_has_cv_name_num = t2.sound_tag_has_cv_name_num,
-- t1.sound_tag_has_cv_name_total_cite_num = t2.sound_tag_has_cv_name_total_cite_num,
-- t1.sound_tag_has_cv_name_max_cite_num = t2.sound_tag_has_cv_name_max_cite_num,
-- t1.sound_tag_has_cv_name_min_cite_num = t2.sound_tag_has_cv_name_min_cite_num,
-- t1.sound_tag_has_cv_name_avg_cite_num = t2.sound_tag_has_cv_name_avg_cite_num

-- 基本特征
-- create table temp_sound_feature_0101_0131
-- select t1.sound_id,LENGTH(t2.sound_info_name),LENGTH(t3.sound_info_intro),t4.tag_num,t2.sound_info_pay_type,t2.sound_info_type,t3.sound_info_duration,t3.sound_info_view_count,
-- t3.sound_info_danmu_count,t3.sound_info_favorite_count,t3.sound_info_point,t3.sound_info_review_count,t3.sound_info_sub_review_count,t3.sound_info_download
-- from (select distinct sound_id from active_sound_exceed_avg) t1
-- left JOIN maoer.sound_info t2 ON t1.sound_id = t2.sound_id
-- join (select * from maoer.sound_info_update where created_time>'2023-01-01' and created_time<'2023-01-31' group by sound_id) t3 on t1.sound_id=t3.sound_id
-- join (
-- SELECT e.sound_id, COUNT(*) AS tag_num
--     FROM maoer.sound_tags AS e
--     GROUP BY e.sound_id
-- ) as t4 on t1.sound_id=t4.sound_id

-- 声音占剧集特征的比例
-- 建表drama_sound_num_count
-- create table drama_sound_num_count as
-- select b.drama_id,sum(e.sound_view_num) as view_num, sum(e.sound_danmu_num) as danmu_num, sum(e.sound_favorite_num) as favorite_num, sum(e.sound_point_num) as point_num, sum(e.sound_review_not_subreview_num) as notsubreview_num, sum(e.sound_review_subreview_num)as subreview_num
-- from supply_sound_feature e
-- join maoer.drama_episodes b on e.sound_id=b.sound_id
-- group by b.drama_id

-- alter table 0301_0331_sound_feature
-- ADD COLUMN sound_submit_time_between_first_and_this INT,
-- ADD COLUMN sound_position_in_total_darma_sound INT,
-- ADD COLUMN sound_view_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_danmu_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_favorite_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_point_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_review_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_not_subreview_num_in_total_darma_percent DOUBLE,
-- ADD COLUMN sound_subreview_num_in_total_darma_percent DOUBLE

-- 更新字段 声音占剧集特征的比例
-- UPDATE 0301_0331_sound_feature t1
-- join (select * from maoer.drama_episodes ep group by ep.drama_id,ep.sound_id)as t4 on t4.sound_id=t1.sound_id
-- join drama_sound_num_count_0301_0331 t3 on t4.drama_id=t3.drama_id
-- SET
-- t1.sound_view_num_in_total_darma_percent =t1.sound_view_num/t3.view_num,
-- t1.sound_danmu_num_in_total_darma_percent =t1.sound_danmu_num/t3.danmu_num,
-- t1.sound_favorite_num_in_total_darma_percent =t1.sound_favorite_num/t3.favorite_num,
-- t1.sound_point_num_in_total_darma_percent =t1.sound_point_num/t3.point_num,
-- t1.sound_review_num_in_total_darma_percent =(t1.sound_review_not_subreview_num+t1.sound_review_subreview_num)/(t3.notsubreview_num+t3.subreview_num),
-- t1.sound_not_subreview_num_in_total_darma_percent =t1.sound_review_not_subreview_num/t3.notsubreview_num,
-- t1.sound_subreview_num_in_total_darma_percent =t1.sound_review_subreview_num/t3.subreview_num

-- 建表drama_sound_num_count
-- create table drama_sound_num_count as
-- select e.drama_id, sum(e.sound_info_view_count) as view_num, sum(e.sound_info_danmu_count) as danmu_num, sum(e.sound_info_favorite_count) as favorite_num, sum(e.sound_info_point) as point_num, sum(e.sound_info_all_reviews_num) as allreview_num, sum(e.sound_info_review_count)as review_num, sum(e.sound_info_sub_review_count) as subreview_num
-- from (
-- select f.*
-- from activeuser_drama_and_sound_info as f
-- group by f.drama_id,f.sound_id
-- ) as e
-- GROUP BY e.drama_id

-- 更新字段值
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

-- 更新 声音发布时间距第一集发布时间的天数差值 and 声音占剧集总发布声音的第几个
-- 建视图 drama中第一集发布时间
-- create view maoer_data_analysis.drama_min_sound_created_time as 
-- SELECT a.drama_id, MIN(b.sound_info_created_time) as min_sound_info_created_time
--     FROM maoer.drama_episodes a
--     JOIN maoer.sound_info b ON a.sound_id = b.sound_id
--     GROUP BY a.drama_id

-- 建视图 声音与剧集第一集的发布时间
-- create view sound_drama_time_feature as
-- SELECT distinct d.sound_id, c.sound_info_created_time,c.drama_id, e.min_sound_info_created_time as drama_min_sound_time
-- FROM maoer.active_sound_add2023sound d
-- left JOIN (
--     SELECT a.drama_id, a.sound_id, b.sound_info_created_time
--     FROM maoer.drama_episodes a
--     JOIN maoer.sound_info b ON a.sound_id = b.sound_id
-- ) c ON c.sound_id = d.sound_id
-- left JOIN drama_min_sound_created_time e ON e.drama_id = c.drama_id;

-- 更新字段值
update sound_feature t1 join
(
SELECT a.sound_id,
  DATEDIFF(a.sound_info_created_time,a.drama_min_sound_time) AS datediff_sound_with_first,
  COUNT(*) AS rank_num
FROM sound_drama_time_feature a
JOIN sound_drama_time_feature b 
ON a.drama_id = b.drama_id AND a.sound_info_created_time >= b.sound_info_created_time
GROUP BY a.sound_id, a.sound_info_created_time
ORDER BY a.sound_id, a.sound_info_created_time
) t2 on t1.sound_id=t2.sound_id
set 
t1.sound_submit_time_between_first_and_this=t2.datediff_sound_with_first,
t1.sound_position_in_total_darma_sound=t2.rank_num

update temp_sound_feature_0301_0331 t1 join 
maoer_data_analysis.sound_feature t2 on t1.sound_id=t2.sound_id
set
t1.sound_submit_time_between_first_and_this=t2.sound_submit_time_between_first_and_this,
t1.sound_position_in_total_darma_sound=t2.sound_position_in_total_darma_sound

-- 构建sound_review_feature
-- create table sound_review_feature_1130 as
-- select a.subject_id,avg(LENGTH(a.review_content)) as review_len_avg,max(LENGTH(a.review_content)) as review_len_max,min(LENGTH(a.review_content)) as review_len_min,avg(a.review_like_num) as review_like_avg,max(a.review_like_num) as review_like_max,min(a.review_like_num) as review_like_min,
-- max(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_max,
-- min(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_min,
-- avg(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_avg,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>7 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_7days_num,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>14 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_14days_num,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>30 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_30days_num
-- from (
-- select distinct e.review_id,e.subject_id,e.review_content,e.review_like_num,e.review_created_time
-- from maoer.review_content as e where e.subject_id='868' and e.review_created_time<'2022-11-30') as a
-- join (select sound_id,sound_info_created_time from 1101_1130_sound_feature) as f 
-- on a.subject_id=f.sound_id
-- group by a.subject_id

-- insert into supply_sound_review_feature
-- select a.subject_id,avg(LENGTH(a.review_content)) as review_len_avg,max(LENGTH(a.review_content)) as review_len_max,min(LENGTH(a.review_content)) as review_len_min,avg(a.review_like_num) as review_like_avg,max(a.review_like_num) as review_like_max,min(a.review_like_num) as review_like_min,
-- max(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_max,
-- min(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_min,
-- avg(DATEDIFF(a.review_created_time, f.sound_info_created_time)) as review_create_time_avg,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>7 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_7days_num,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>14 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_14days_num,
-- sum(case when DATEDIFF(a.review_created_time, f.sound_info_created_time)>30 then 1 else 0 end) as review_submit_time_between_submit_sound_time_in_30days_num
-- from (select sound_id,sound_info_created_time from supply_sound_feature) f 
-- join (
-- select distinct e.review_id,e.subject_id,e.review_content,e.review_created_time,e.review_like_num
-- from maoer.review_content as e where e.subject_id='22728') as a on a.subject_id=f.sound_id
-- group by f.sound_id

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
-- from maoer.danmu_info as e where e.danmu_info_date<'2022-11-30') as a
-- right join (select sound_id,sound_info_created_time from 1101_1130_sound_feature) as f 
-- on a.sound_id=f.sound_id
-- group by a.sound_id

-- insert into supply_sound_danmu_feature 
-- select f.sound_id,avg(LENGTH(a.danmu_info_text)) as danmu_len_avg,max(LENGTH(a.danmu_info_text)) as danmu_len_max,min(LENGTH(a.danmu_info_text)) as danmu_len_min,
-- max(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_max,
-- min(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_min,
-- avg(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_avg,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>7 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_7days_num,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>14 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_14days_num,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>30 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_30days_num
-- from (select sound_id,sound_info_created_time from need_deal_drama_sound_feature_sound) f 
-- join (
-- select distinct e.danmu_id,e.sound_id,e.danmu_info_text,e.danmu_info_date
-- from maoer.danmu_info as e where e.sound_id='22728') as a on a.sound_id=f.sound_id
-- group by f.sound_id

-- update 1215_0115_sound_feature t1 
-- left join maoer_data_analysis.sound_danmu_feature t2 on t1.sound_id=t2.sound_id
-- left join maoer_data_analysis.sound_review_feature t3 on t1.sound_id=t3.subject_id
-- set
-- t1.sound_danmu_avg_len = t2.danmu_len_avg ,
-- t1.sound_danmu_max_len = t2.danmu_len_max,
-- t1.sound_danmu_min_len = t2.danmu_len_min,
-- t1.sound_danmu_submit_time_between_submit_sound_time_max = t2.danmu_create_time_max,
-- t1.sound_danmu_submit_time_between_submit_sound_time_min = t2.danmu_create_time_min,
-- t1.sound_danmu_submit_time_between_submit_sound_time_avg = t2.danmu_create_time_avg,
-- t1.sound_danmu_submit_time_between_submit_sound_time_in_7days_num = t2.danmu_submit_time_between_submit_sound_time_in_7days_num,
-- t1.sound_danmu_submit_time_between_submit_sound_time_in_14days_num = t2.danmu_submit_time_between_submit_sound_time_in_14days_num ,
-- t1.sound_danmu_submit_time_between_submit_sound_time_in_30days_num = t2.danmu_submit_time_between_submit_sound_time_in_30days_num,
-- t1.sound_review_avg_len = t3.review_len_avg ,
-- t1.sound_review_max_len = t3.review_len_max,
-- t1.sound_review_min_len = t3.review_len_min, 
-- t1.sound_review_avg_like_num = t3.review_like_avg,
-- t1.sound_review_max_like_num = t3.review_like_max ,
-- t1.sound_review_min_like_num = t3.review_like_min,
-- t1.sound_review_submit_time_between_submit_sound_time_max = t3.review_create_time_max ,
-- t1.sound_review_submit_time_between_submit_sound_time_min = t3.review_create_time_min,
-- t1.sound_review_submit_time_between_submit_sound_time_avg = t3.review_create_time_avg,
-- t1.sound_review_submit_time_between_submit_sound_time_in_7days_num = t3.review_submit_time_between_submit_sound_time_in_7days_num,
-- t1.sound_review_submit_time_between_submit_sound_time_in_14days_num = t3.review_submit_time_between_submit_sound_time_in_14days_num,
-- t1.sound_review_submit_time_between_submit_sound_time_in_30days_num = t3.review_submit_time_between_submit_sound_time_in_30days_num

-- update 1215_0115_drama_feature a join 0101_0115_drama_feature b on a.drama_id=b.drama_id
-- set
-- a.drama_upuser_submit_sound_max_pay_type= b.drama_upuser_submit_sound_max_pay_type,
-- a.drama_upuser_submit_sound_pay_sound_percent = b.drama_upuser_submit_sound_pay_sound_percent

-- update 0101_0115_drama_feature t1 
-- left join (
-- select t5.drama_id,
-- avg(t3.danmu_len_avg) as drama_danmu_avg_len,
-- max(t3.danmu_len_avg) as drama_danmu_max_len,
-- min(t3.danmu_len_avg) as drama_danmu_min_len,
-- max(t3.danmu_create_time_max) as drama_danmu_submit_time_between_submit_sound_time_max,
-- min(t3.danmu_create_time_min) as drama_danmu_submit_time_between_submit_sound_time_min,
-- avg(t3.danmu_create_time_avg) as drama_danmu_submit_time_between_submit_sound_time_avg,
-- max(t3.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_max,
-- min(t3.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_min,
-- avg(t3.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_avg,
-- max(t3.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_max,
-- min(t3.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_min,
-- avg(t3.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_avg,
-- max(t3.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_max,
-- min(t3.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_min,
-- avg(t3.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_avg
-- from 0101_0115_drama_feature t5
-- left join maoer.drama_episodes t6 on t5.drama_id=t6.drama_id
-- left join (select sound_id,danmu_len_avg, danmu_create_time_max,danmu_create_time_min,danmu_create_time_avg,danmu_submit_time_between_submit_sound_time_in_7days_num,danmu_submit_time_between_submit_sound_time_in_14days_num,danmu_submit_time_between_submit_sound_time_in_30days_num
-- 					from maoer_data_analysis.sound_danmu_feature 
-- 	union select sound_id,danmu_len_avg, danmu_create_time_max,danmu_create_time_min,danmu_create_time_avg,danmu_submit_time_between_submit_sound_time_in_7days_num,danmu_submit_time_between_submit_sound_time_in_14days_num,danmu_submit_time_between_submit_sound_time_in_30days_num from supply_sound_danmu_feature) t3 on t3.sound_id=t6.sound_id
-- group by t5.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_danmu_avg_len = t2.drama_danmu_avg_len,
-- t1.drama_danmu_max_len = t2.drama_danmu_max_len,
-- t1.drama_danmu_min_len = t2.drama_danmu_min_len ,
-- t1.drama_danmu_submit_time_between_submit_sound_time_max = t2.drama_danmu_submit_time_between_submit_sound_time_max,
-- t1.drama_danmu_submit_time_between_submit_sound_time_min = t2.drama_danmu_submit_time_between_submit_sound_time_min,
-- t1.drama_danmu_submit_time_between_submit_sound_time_avg = t2.drama_danmu_submit_time_between_submit_sound_time_avg ,
-- t1.drama_danmu_time_between_sound_time_in_7days_num_max = t2.drama_danmu_time_between_sound_time_in_7days_num_max,
-- t1.drama_danmu_time_between_sound_time_in_7days_num_min = t2.drama_danmu_time_between_sound_time_in_7days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_7days_num_avg = t2.drama_danmu_time_between_sound_time_in_7days_num_avg,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_max = t2.drama_danmu_time_between_sound_time_in_14days_num_max,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_min = t2.drama_danmu_time_between_sound_time_in_14days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_avg = t2.drama_danmu_time_between_sound_time_in_14days_num_avg,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_max = t2.drama_danmu_time_between_sound_time_in_30days_num_max,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_min = t2.drama_danmu_time_between_sound_time_in_30days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_avg = t2.drama_danmu_time_between_sound_time_in_30days_num_avg


-- 统计声音30straffic的临时表
-- create table temp_supply_sound_traffic_count as 
-- select sound_id,30s_position_in_sound,count(30s_position_in_sound) as 30s_num,position_in_sound
-- from supply_sound_danmu_traffic_feature 
-- group by sound_id,30s_position_in_sound

-- 流量
-- create table need_deal_danmu_traffic_sound
-- select sound_id
-- from activeuser_with_danmu_sound_all group by sound_id

-- alter table need_deal_danmu_traffic_sound
-- add COLUMN sound_danmu_30s_max_traffic int(11),
-- add COLUMN sound_danmu_30s_min_traffic int(11),
-- add COLUMN sound_danmu_30s_avg_traffic double ,
-- add COLUMN sound_danmu_30s_max_traffic_position_in_sound double,
-- add COLUMN sound_danmu_30s_min_traffic_position_in_sound double

-- update need_deal_danmu_traffic_sound t1 join 
-- (
-- select sound_id,max(30s_num) as max_30s_num,min(30s_num)as min_30s_num,avg(30s_num) as avg_30s_num
-- from temp_supply_sound_traffic_count
-- group by sound_id
-- )t2 on t1.sound_id=t2.sound_id
-- SET
-- t1.sound_danmu_30s_max_traffic= t2.max_30s_num,
-- t1.sound_danmu_30s_min_traffic= t2.min_30s_num,
-- t1.sound_danmu_30s_avg_traffic= t2.avg_30s_num

-- update need_deal_danmu_traffic_sound t1 join 
-- (
-- select sound_id,30s_num,position_in_sound
-- from temp_sound_traffic_count
-- group by sound_id,30s_num
-- )t2 on t1.sound_id=t2.sound_id and t1.sound_danmu_30s_min_traffic=t2.30s_num
-- SET
-- -- t1.sound_danmu_30s_max_traffic_position_in_sound=t2.position_in_sound
-- t1.sound_danmu_30s_min_traffic_position_in_sound=t2.position_in_sound

-- 更新sound danmu traffic
-- update 1216_1231_sound_feature t1 left join
-- need_deal_danmu_traffic_sound t2 on t1.sound_id=t2.sound_id
-- set
-- t1.sound_danmu_15s_max_traffic = t2.sound_danmu_30s_max_traffic,
-- t1.sound_danmu_15s_min_traffic = t2.sound_danmu_30s_min_traffic,
-- t1.sound_danmu_15s_avg_traffic = t2.sound_danmu_30s_avg_traffic,
-- t1.sound_danmu_15s_max_traffic_position_in_sound = t2.sound_danmu_30s_max_traffic_position_in_sound,
-- t1.sound_danmu_15s_min_traffic_position_in_sound = t2.sound_danmu_30s_min_traffic_position_in_sound

-- update 0101_0115_drama_sound_feature t1 left join
-- (
-- select t4.drama_id,max(t3.sound_danmu_30s_max_traffic) as drama_sound_danmu_15s_max_traffic,
-- min(t3.sound_danmu_30s_min_traffic) as drama_sound_danmu_15s_min_traffic,
-- avg(t3.sound_danmu_30s_avg_traffic) as drama_sound_danmu_15s_avg_traffic,
-- avg(t3.sound_danmu_30s_max_traffic_position_in_sound) as drama_sound_max_traffic_position_in_sound_avg,
-- avg(t3.sound_danmu_30s_min_traffic_position_in_sound) as drama_sound_min_traffic_position_in_sound_avg
-- from 0101_drama_sound_feature t4
-- maoer.drama_episodes t2  on t4.drama_id=t2.drama_id
-- left join need_deal_danmu_traffic_sound t3 on t2.sound_id=t3.sound_id
-- group by t4.drama_id
-- )
-- set
-- t1.drama_sound_danmu_15s_max_traffic = t2.drama_sound_danmu_15s_max_traffic,
-- t1.drama_sound_danmu_15s_min_traffic = t2.drama_sound_danmu_15s_min_traffic,
-- t1.drama_sound_danmu_15s_avg_traffic = t2.drama_sound_danmu_15s_avg_traffic,
-- t1.drama_sound_max_traffic_position_in_sound_avg = t2.drama_sound_max_traffic_position_in_sound_avg,
-- t1.drama_sound_min_traffic_position_in_sound_avg = t2.drama_sound_min_traffic_position_in_sound_avg


-- update 0101_0131_drama_sound_feature t1 left join
-- 0101_0115_drama_sound_feature t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_sound_danmu_15s_max_traffic = t2.drama_sound_danmu_15s_max_traffic,
-- t1.drama_sound_danmu_15s_min_traffic = t2.drama_sound_danmu_15s_min_traffic,
-- t1.drama_sound_danmu_15s_avg_traffic = t2.drama_sound_danmu_15s_avg_traffic,
-- t1.drama_sound_max_traffic_position_in_sound_avg = t2.drama_sound_max_traffic_position_in_sound_avg,
-- t1.drama_sound_min_traffic_position_in_sound_avg = t2.drama_sound_min_traffic_position_in_sound_avg

-- 更新sound cv 得一个表一个表更新
-- update 0101_0131_sound_feature t1 left join 
-- sound_cv_feature t2 on t1.sound_id=t2.sound_id
-- set
-- t1.sound_cv_total_num = t2.total_cv_num ,
-- t1.sound_cv_has_userid_num = t2.cv_has_userid_num ,
-- t1.sound_cv_total_fans_num = t2.cv_total_fans_num ,
-- t1.sound_cv_max_fans_num = t2.cv_max_fans_num ,
-- t1.sound_cv_min_fans_num = t2.cv_min_fans_num ,
-- t1.sound_cv_avg_fans_num = t2.cv_avg_fans_num ,
-- t1.sound_cv_main_cv_total_fans_num = t2.cv_main_character_total_num,
-- t1.sound_cv_main_cv_max_fans_num = t2.cv_main_character_max_num,
-- t1.sound_cv_main_cv_min_fans_num = t2.cv_main_character_min_num,
-- t1.sound_cv_main_cv_avg_fans_num = t2.cv_main_character_avg_num ,
-- t1.sound_cv_auxiliary_cv_max_fans_num = t2.cv_aux_character_max_num,
-- t1.sound_cv_auxiliary_cv_min_fans_num = t2.cv_aux_character_min_num,
-- t1.sound_cv_auxiliary_cv_avg_fans_num = t2.cv_aux_character_avg_num

-- 更新sound tag 得一个表一个表更新
-- update 1216_1231_sound_feature t1
-- join (
-- select h.sound_id,
-- sum(case when h.tag_info_sound_num is not null then h.tag_info_sound_num else 0 end) as sound_tag_total_cite_num,
-- max(case when h.tag_info_sound_num is not null then h.tag_info_sound_num else 0 end) as sound_tag_max_cite_num,
-- min(case when h.tag_info_sound_num is not null then h.tag_info_sound_num else 10000000 end) as sound_tag_min_cite_num,
-- avg(case when h.tag_info_sound_num is not null then h.tag_info_sound_num else 0 end) as sound_tag_avg_cite_num
-- from (
-- select d.sound_id,a.tag_id,a.tag_info_sound_num
-- from 1216_1231_sound_feature d 
-- left join maoer.sound_tags s on s.sound_id=d.sound_id 
-- left join (select tag_id,tag_info_sound_num from maoer.tag_info_update group by tag_id) a on a.tag_id=s.tag_id
-- group by d.sound_id,a.tag_id) h
-- group by h.sound_id
-- )t2 on t1.sound_id=t2.sound_id
-- SET
-- t1.sound_tag_total_cite_num = t2.sound_tag_total_cite_num,
-- t1.sound_tag_max_cite_num = t2.sound_tag_max_cite_num,
-- t1.sound_tag_min_cite_num = t2.sound_tag_min_cite_num,
-- t1.sound_tag_avg_cite_num = t2.sound_tag_avg_cite_num


-- -------------------------------剧集特征 drama_feature------------------------------------
-- drama_feature_basic
-- create table 0101_0115_drama_feature as 
-- select e.drama_id,LENGTH(a.drama_info_name) as drama_name_len,
-- 		LENGTH(a.drama_info_abstract) as drama_intro_len,
-- 		(CASE WHEN (a.drama_info_author is not null and a.drama_info_author!='') then 1 else 0 end) as drama_has_author,
-- 		a.drama_info_type as drama_type,
-- 		b.drama_info_pay_type as drama_pay_type,
-- 		b.drama_info_price as drama_total_pay_money
-- 		from activeuser_submit_danmu_sound_with_drama_202211_202303 as e
-- 		left join maoer.drama_info as a on e.drama_id=a.drama_id 
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
-- 		group by e.drama_id

-- ALTER TABLE 0101_0115_drama_feature
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

-- 更新是否连载
-- update 1216_1231_drama_feature t1 join 
-- drama_end_time_202211_202303 t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_is_serialize = t2.drama_not_end_in20221130

-- 更新 在时间窗内剧集的总声音数
-- create table drama_time_sound_count as 
-- select t4.drama_id,
-- sum(case when(t3.sound_info_created_time<'2022-11-01') then 1 else 0 end) as drama_total_sound_num_20221031,
-- sum(case when(t3.sound_info_created_time<'2022-11-16') then 1 else 0 end) as drama_total_sound_num_20221115,
-- sum(case when(t3.sound_info_created_time<'2022-12-01') then 1 else 0 end) as drama_total_sound_num_20221130,
-- sum(case when(t3.sound_info_created_time<'2022-12-16') then 1 else 0 end) as drama_total_sound_num_20221215,
-- sum(case when(t3.sound_info_created_time<'2023-01-01') then 1 else 0 end) as drama_total_sound_num_20221231,
-- sum(case when(t3.sound_info_created_time<'2023-01-16') then 1 else 0 end) as drama_total_sound_num_20230115,
-- sum(case when(t3.sound_info_created_time<'2023-02-01') then 1 else 0 end) as drama_total_sound_num_20230131,
-- sum(case when(t3.sound_info_created_time<'2023-02-16') then 1 else 0 end) as drama_total_sound_num_20230215,
-- sum(case when(t3.sound_info_created_time<'2023-03-01') then 1 else 0 end) as drama_total_sound_num_20230230,
-- sum(case when(t3.sound_info_created_time<'2023-03-16') then 1 else 0 end) as drama_total_sound_num_20230315,
-- sum(case when(t3.sound_info_created_time<'2022-11-01' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20221031,
-- sum(case when(t3.sound_info_created_time<'2022-11-16' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20221115,
-- sum(case when(t3.sound_info_created_time<'2022-12-01' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20221130,
-- sum(case when(t3.sound_info_created_time<'2022-12-16' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20221215,
-- sum(case when(t3.sound_info_created_time<'2023-01-01' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20221231,
-- sum(case when(t3.sound_info_created_time<'2023-01-16' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20230115,
-- sum(case when(t3.sound_info_created_time<'2023-02-01' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20230131,
-- sum(case when(t3.sound_info_created_time<'2023-02-16' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20230215,
-- sum(case when(t3.sound_info_created_time<'2023-03-01' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20230230,
-- sum(case when(t3.sound_info_created_time<'2023-03-16' and t3.sound_info_pay_type<>0) then 1 else 0 end) as drama_pay_sound_num_20230315
-- from 0101_0115_drama_feature t4 left join (
-- select t1.drama_id,t2.sound_id,t2.sound_info_created_time,t2.sound_info_pay_type
-- from maoer.drama_episodes t1 right join 
-- maoer.sound_info t2 on t1.sound_id=t2.sound_id
-- group by t2.sound_id) t3 on t4.drama_id=t3.drama_id
-- group by t3.drama_id

-- 更新 剧集标签数量
-- select t1.drama_id,count(distinct t2.tag_id) as tag_num
-- from 0101_0115_drama_feature t1 left join 
-- maoer.drama_tags t2 on t1.drama_id=t2.drama_id
-- group by t1.drama_id

-- update 1216_1231_drama_feature t1 join 
-- drama_time_sound_count t2 on t1.drama_id=t2.drama_id
-- join (
-- select t1.drama_id,count(distinct t2.tag_id) as tag_num
-- from 0101_0115_drama_feature t1 left join 
-- maoer.drama_tags t2 on t1.drama_id=t2.drama_id
-- group by t1.drama_id
-- ) t3 on t1.drama_id=t3.drama_id
-- set
-- t1.drama_total_sound_num=t2.drama_total_sound_num_20221215,
-- t1.drama_tag_num=t3.tag_num,
-- t1.drama_pay_sound_percent=t2.drama_pay_sound_num_20221215/t2.drama_total_sound_num_20221215

-- 更新 时间窗内剧集的总播放量
-- 11.30(7) 12.15(22) 12.31(38) 01.15(53) 01.31(69) 02.15(84) 02.28(97) 03.15(112) 
-- update 1216_1231_drama_feature t5 join (
-- select t4.drama_id,sum(t3.sound_info_view_count) as drama_total_view_num,
-- sum(t3.sound_info_danmu_count) as drama_total_danmu_num,
-- max(t3.sound_info_danmu_count) as drama_max_danmu_num,
-- min(t3.sound_info_danmu_count) as drama_min_danmu_num,
-- avg(t3.sound_info_danmu_count) as drama_avg_danmu_num,
-- sum(t3.sound_info_favorite_count) as drama_total_favorite_num,
-- max(t3.sound_info_favorite_count) as drama_max_favorite_num,
-- min(t3.sound_info_favorite_count) as drama_min_favorite_num,
-- avg(t3.sound_info_favorite_count) as drama_avg_favorite_num,
-- sum(t3.sound_info_point) as drama_total_point_num,
-- max(t3.sound_info_point) as drama_max_point_num,
-- min(t3.sound_info_point) as drama_min_point_num,
-- avg(t3.sound_info_point) as drama_avg_point_num,
-- sum(t3.sound_info_all_reviews_num) as drama_total_review_num,
-- max(t3.sound_info_all_reviews_num) as drama_max_review_num,
-- min(t3.sound_info_all_reviews_num) as drama_min_review_num,
-- avg(t3.sound_info_all_reviews_num) as drama_avg_review_num
-- from 0101_0115_drama_feature t4 left join (
-- select t1.drama_id,t2.sound_id,t2.sound_info_created_time,t2.sound_info_view_count,t2.sound_info_danmu_count,t2.sound_info_favorite_count,t2.sound_info_all_reviews_num,t2.sound_info_point
-- from maoer.drama_episodes t1 left join 
-- sound_feature_osl_pred_true t2 on t1.sound_id=t2.sound_id
-- where t2.datediff_between_1123_to_updatetime = 38
-- ) t3 on t4.drama_id=t3.drama_id
-- where t4.drama_id not in (select drama_id from need_delete_active_drama_id)
-- group by t3.drama_id) t6 on t5.drama_id=t6.drama_id
-- set
-- t5.drama_total_view_num = t6.drama_total_view_num,
-- t5.drama_total_danmu_num = t6.drama_total_danmu_num,
-- t5.drama_max_danmu_num = t6.drama_max_danmu_num,
-- t5.drama_min_danmu_num = t6.drama_min_danmu_num ,
-- t5.drama_avg_danmu_num = t6.drama_avg_danmu_num ,
-- t5.drama_total_favorite_num = t6.drama_total_favorite_num,
-- t5.drama_max_favorite_num = t6.drama_max_favorite_num,
-- t5.drama_min_favorite_num = t6.drama_min_favorite_num ,
-- t5.drama_avg_favorite_num = t6.drama_avg_favorite_num,
-- t5.drama_total_point_num = t6.drama_total_point_num ,
-- t5.drama_max_point_num = t6.drama_max_point_num,
-- t5.drama_min_point_num = t6.drama_min_point_num ,
-- t5.drama_avg_point_num = t6.drama_avg_point_num,
-- t5.drama_total_review_num = t6.drama_total_review_num,
-- t5.drama_max_review_num = t6.drama_max_review_num ,
-- t5.drama_min_review_num = t6.drama_min_review_num ,
-- t5.drama_avg_review_num = t6.drama_avg_review_num

-- 更新 剧集up主 drama_upuser_feature ,drama_tag_feature
-- UPDATE 1216_1231_drama_feature t1
-- left join 0101_0115_drama_feature t2 on t1.drama_id=t2.drama_id 
-- SET
-- t1.drama_cv_total_num = t2.drama_cv_total_num,
-- t1.drama_cv_total_fans_num = t2.drama_cv_total_fans_num,
-- t1.drama_cv_max_fans_num = t2.drama_cv_max_fans_num,
-- t1.drama_cv_min_fans_num = t2.drama_cv_min_fans_num,
-- t1.drama_cv_avg_fans_num = t2.drama_cv_avg_fans_num,
-- t1.drama_cv_main_total_fans_num = t2.drama_cv_main_total_fans_num,
-- t1.drama_cv_main_max_fans_num = t2.drama_cv_main_max_fans_num,
-- t1.drama_cv_main_min_fans_num = t2.drama_cv_main_min_fans_num,
-- t1.drama_cv_main_avg_fans_num = t2.drama_cv_main_avg_fans_num,
-- t1.drama_cv_aux_max_fans_num = t2.drama_cv_aux_max_fans_num,
-- t1.drama_cv_aux_min_fans_num = t2.drama_cv_aux_min_fans_num,
-- t1.drama_cv_aux_avg_fans_num = t2.drama_cv_aux_avg_fans_num,
-- t1.drama_sound_cv_max_num = t2.drama_sound_cv_max_num,
-- t1.drama_sound_cv_min_num = t2.drama_sound_cv_min_num,
-- t1.drama_sound_cv_avg_num = t2.drama_sound_cv_avg_num,
-- t1.drama_upuser_grade = t2.drama_upuser_grade,
-- t1.drama_upuser_fish_num = t2.drama_upuser_fish_num,
-- t1.drama_upuser_fans_num = t2.drama_upuser_fans_num,
-- t1.drama_upuser_follower_num = t2.drama_upuser_follower_num,
-- t1.drama_upuser_submit_sound_num = t2.drama_upuser_submit_sound_num,
-- t1.drama_upuser_submit_drama_num = t2.drama_upuser_submit_drama_num,
-- t1.drama_upuser_subscriptions_num = t2.drama_upuser_subscriptions_num,
-- t1.drama_upuser_channel_num = t2.drama_upuser_channel_num,
-- t1.drama_sound_tag_total_cite_num = t2.drama_sound_tag_total_cite_num,
-- t1.drama_sound_tag_max_cite_num = t2.drama_sound_tag_max_cite_num,
-- t1.drama_sound_tag_min_cite_num = t2.drama_sound_tag_min_cite_num,
-- t1.drama_sound_tag_avg_cite_num = t2.drama_sound_tag_avg_cite_num,
-- t1.drama_sound_tag_has_cv_name_num = t2.drama_sound_tag_has_cv_name_num,
-- t1.drama_sound_tag_has_cv_name_total_cite_num = t2.drama_sound_tag_has_cv_name_total_cite_num,
-- t1.drama_sound_tag_has_cv_name_max_cite_num = t2.drama_sound_tag_has_cv_name_max_cite_num,
-- t1.drama_sound_tag_has_cv_name_min_cite_num = t2.drama_sound_tag_has_cv_name_min_cite_num,
-- t1.drama_sound_tag_has_cv_name_avg_cite_num = t2.drama_sound_tag_has_cv_name_avg_cite_num

-- 建表 sound_cv_feature
-- create table sound_cv_feature as(
-- select c.sound_id,count(c.cast_id) as total_cv_num,sum(case when c.user_id is not null then 1 else 0 end) as cv_has_userid_num,sum(a.user_info_fans_num) as cv_total_fans_num, max(a.user_info_fans_num) as cv_max_fans_num ,min(a.user_info_fans_num) as cv_min_fans_num,avg(a.user_info_fans_num) as cv_avg_fans_num, 
-- sum(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_total_num,max(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_max_num,min(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_min_num,avg(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_avg_num,
-- sum(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_total_num,max(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_max_num,min(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_min_num,avg(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_avg_num
-- from (select * from maoer.user_info group by user_id) as a
-- right join (
-- select t1.sound_id,b.cast_id,b.user_id,e.cast_drama_character_main
-- from (select sound_id from sound_feature_osl_pred_true  group by sound_id) t1 
-- left join maoer.cast_drama as e on t1.sound_id=e.sound_id
-- left join (select f.cast_id,f.user_id from maoer.cast_info as f group by f.cast_id)as b on e.cast_id=b.cast_id
-- group by t1.sound_id,b.cast_id
-- ) as c on a.user_id=c.user_id
-- group by c.sound_id
-- )

-- create table supply_sound_cv_feature as(
-- select t1.sound_id,count(c.cast_id) as total_cv_num,sum(case when a.user_id is not null then 1 else 0 end) as cv_has_userid_num,sum(a.user_info_fans_num) as cv_total_fans_num, max(a.user_info_fans_num) as cv_max_fans_num ,min(a.user_info_fans_num) as cv_min_fans_num,avg(a.user_info_fans_num) as cv_avg_fans_num, 
-- sum(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_total_num,max(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_max_num,min(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_min_num,avg(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_avg_num,
-- sum(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_total_num,max(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_max_num,min(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_min_num,avg(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_avg_num
-- from (select sound_id from sound_feature_osl_pred_true group by sound_id) t1 
-- left join maoer.cast_drama as c on t1.sound_id=c.sound_id
-- left join (select f.cast_id,f.user_id from maoer.cast_info as f group by f.cast_id)as b on c.cast_id=b.cast_id
-- left join (select * from maoer.user_info group by user_id) a on b.user_id=a.user_id
-- group by t1.sound_id
-- )

-- update sound_feature_osl_pred_true t1 join 
-- sound_cv_feature t2 on t1.sound_id=t2.sound_id
-- set
-- t1.sound_cv_total_num =t2.total_cv_num,
-- t1.sound_cv_total_fans_num =t2.cv_total_fans_num

-- create table supply_drama_cv_sound_feature as (
-- select c.drama_id,
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
-- from (
-- 	SELECT di.sound_id,di.drama_id,di.sound_info_view_count,di.sound_info_danmu_count,di.sound_info_favorite_count,di.sound_info_point,di.sound_info_all_reviews_num
-- 		FROM sound_feature_osl_pred_true di
-- 		JOIN (
-- 				SELECT sound_id, MAX(datediff_between_1123_to_updatetime) AS max_time
-- 				FROM sound_feature_osl_pred_true
-- 				GROUP BY sound_id
-- 		) AS sub
-- 		ON di.sound_id = sub.sound_id AND di.datediff_between_1123_to_updatetime = sub.max_time
-- ) as c 
-- left join(
--  select sound_id,total_cv_num,cv_total_fans_num
--  from sound_cv_feature 
-- )as b on c.sound_id=b.sound_id
-- left join(
-- 	SELECT a.drama_id,  
--        MAX(b.total_cv_num) AS max_total_cv_num,  
--        MIN(b.total_cv_num) AS min_total_cv_num  
-- 	FROM maoer.drama_episodes AS a  
-- 	JOIN sound_cv_feature AS b ON a.sound_id = b.sound_id  
-- 	GROUP BY a.drama_id
-- )as d on c.drama_id=d.drama_id
-- group by c.drama_id
-- )

-- 剧集CV drama_cv_feature
-- create table drama_cv_info_feature as(
-- select c.drama_id,count(c.cast_id) as total_cv_num,sum(case when c.user_id is not null then 1 else 0 end) as cv_has_userid_num,sum(a.user_info_fans_num) as cv_total_fans_num, max(a.user_info_fans_num) as cv_max_fans_num ,min(a.user_info_fans_num) as cv_min_fans_num,avg(a.user_info_fans_num) as cv_avg_fans_num, 
-- sum(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_total_num,max(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_max_num,min(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_min_num,avg(case when c.cast_drama_character_main=1 then a.user_info_fans_num else 0 end) as cv_main_character_avg_num,
-- sum(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_total_num,max(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_max_num,min(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_min_num,avg(case when c.cast_drama_character_main=2 then a.user_info_fans_num else 0 end) as cv_aux_character_avg_num
-- from (select * from maoer.user_info group by user_id )as a
-- right join (
-- select e.drama_id,b.cast_id,b.user_id,e.cast_drama_character_main
-- from maoer.cast_drama as e 
-- join (
-- select f.cast_id,f.user_id from maoer.cast_info as f group by f.cast_id
-- )as b on e.cast_id=b.cast_id
-- group by e.drama_id,b.cast_id
-- ) as c on a.user_id=c.user_id
-- group by c.drama_id
-- )


-- update 1216_1231_drama_feature t1 
-- -- left join drama_cv_sound_feature t2 on t1.drama_id=t2.drama_id
-- -- left join drama_cv_info_feature t3 on t1.drama_id=t3.drama_id
-- left join 0101_0115_drama_feature t4 on t1.drama_id=t4.drama_id
-- set
-- t1.drama_cv_total_num = t4.drama_cv_total_num ,
-- t1.drama_cv_total_fans_num = t4.drama_cv_total_fans_num,
-- t1.drama_cv_max_fans_num = t4.drama_cv_max_fans_num ,
-- t1.drama_cv_min_fans_num = t4.drama_cv_min_fans_num ,
-- t1.drama_cv_avg_fans_num = t4.drama_cv_avg_fans_num , 
-- t1.drama_cv_main_total_fans_num = t4.drama_cv_main_total_fans_num,
-- t1.drama_cv_main_max_fans_num = t4.drama_cv_main_max_fans_num ,
-- t1.drama_cv_main_min_fans_num = t4.drama_cv_main_min_fans_num,
-- t1.drama_cv_main_avg_fans_num = t4.drama_cv_main_avg_fans_num ,
-- t1.drama_cv_aux_max_fans_num = t4.drama_cv_aux_max_fans_num,
-- t1.drama_cv_aux_min_fans_num = t4.drama_cv_aux_min_fans_num,
-- t1.drama_cv_aux_avg_fans_num = t4.drama_cv_aux_avg_fans_num,
-- t1.drama_sound_cv_max_num = t4.drama_sound_cv_max_num,
-- t1.drama_sound_cv_min_num = t4.drama_sound_cv_min_num ,
-- t1.drama_sound_cv_avg_num = t4.drama_sound_cv_avg_num,
-- t1.drama_upuser_grade = t4.drama_upuser_grade,
-- t1.drama_upuser_fish_num = t4.drama_upuser_fish_num,
-- t1.drama_upuser_fans_num = t4.drama_upuser_fans_num,
-- t1.drama_upuser_follower_num = t4.drama_upuser_follower_num,
-- t1.drama_upuser_submit_sound_num = t4.drama_upuser_submit_sound_num,
-- t1.drama_upuser_submit_drama_num = t4.drama_upuser_submit_drama_num,
-- t1.drama_upuser_subscriptions_num = t4.drama_upuser_subscriptions_num,
-- t1.drama_upuser_channel_num = t4.drama_upuser_channel_num,
-- t1.drama_upuser_submit_drama_has_fans_reward = t4.drama_upuser_submit_drama_has_fans_reward,
-- t1.drama_upuser_submit_drama_has_reward_week_ranking = t4.drama_upuser_submit_drama_has_reward_week_ranking,
-- t1.drama_upuser_submit_drama_has_reward_month_ranking = t4.drama_upuser_submit_drama_has_reward_month_ranking,
-- t1.drama_upuser_submit_drama_has_reward_total_ranking = t4.drama_upuser_submit_drama_has_reward_total_ranking,
-- t1.drama_upuser_submit_drama_reward_week_max_rank = t4.drama_upuser_submit_drama_reward_week_max_rank,
-- t1.drama_upuser_submit_drama_reward_month_max_rank = t4.drama_upuser_submit_drama_reward_month_max_rank,
-- t1.drama_upuser_submit_drama_reward_total_max_rank = t4.drama_upuser_submit_drama_reward_total_max_rank 



-- update 1215_0115_drama_feature t1 left join
-- (select t3.drama_id,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_max_num then t5.sound_info_view_count else 0 end) as
-- drama_sound_has_max_cv_num_sound_view_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_max_num then t5.sound_info_danmu_count else 0 end) as
-- drama_sound_has_max_cv_num_sound_danmu_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_max_num then t5.sound_info_favorite_count else 0 end) as drama_sound_has_max_cv_num_sound_favorite_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_max_num then t5.sound_info_point else 0 end) as
-- drama_sound_has_max_cv_num_sound_point_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_max_num then t5.sound_info_all_reviews_num else 0 end) as drama_sound_has_max_cv_num_sound_review_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_min_num then t5.sound_info_view_count else 0 end) as
-- drama_sound_has_min_cv_num_sound_view_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_min_num then t5.sound_info_danmu_count else 0 end) as
-- drama_sound_has_min_cv_num_sound_danmu_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_min_num then t5.sound_info_favorite_count else 0 end) as drama_sound_has_min_cv_num_sound_favorite_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_min_num then t5.sound_info_point else 0 end) as
-- drama_sound_has_min_cv_num_sound_point_num,
-- sum(case when t6.total_cv_num=t4.drama_sound_cv_min_num then t5.sound_info_all_reviews_num else 0 end) as drama_sound_has_min_cv_num_sound_review_num
-- from 0101_0115_drama_feature t3 
-- left join
-- (select drama_id,drama_sound_cv_max_num,drama_sound_cv_min_num from 0101_0115_drama_feature) t4 on t3.drama_id=t4.drama_id
-- left join (
-- 	select * from sound_feature_osl_pred_true 
-- 	where datediff_between_1123_to_updatetime = 53 
-- ) t5 on t3.drama_id=t5.drama_id
-- left join sound_cv_feature t6 on t6.sound_id=t5.sound_id
-- group by t3.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_sound_has_max_cv_num_sound_view_num = t2.drama_sound_has_max_cv_num_sound_view_num,
-- t1.drama_sound_has_max_cv_num_sound_danmu_num = t2.drama_sound_has_max_cv_num_sound_danmu_num,
-- t1.drama_sound_has_max_cv_num_sound_favorite_num = t2.drama_sound_has_max_cv_num_sound_favorite_num ,
-- t1.drama_sound_has_max_cv_num_sound_point_num = t2.drama_sound_has_max_cv_num_sound_point_num ,
-- t1.drama_sound_has_max_cv_num_sound_review_num = t2.drama_sound_has_max_cv_num_sound_review_num,
-- t1.drama_sound_has_min_cv_num_sound_view_num = t2.drama_sound_has_min_cv_num_sound_view_num,
-- t1.drama_sound_has_min_cv_num_sound_danmu_num = t2.drama_sound_has_min_cv_num_sound_danmu_num ,
-- t1.drama_sound_has_min_cv_num_sound_favorite_num = t2.drama_sound_has_min_cv_num_sound_favorite_num ,
-- t1.drama_sound_has_min_cv_num_sound_point_num = t2.drama_sound_has_min_cv_num_sound_point_num ,
-- t1.drama_sound_has_min_cv_num_sound_review_num = t2.drama_sound_has_min_cv_num_sound_review_num

-- 更新 drama_sound
-- sound天数差值 11.30(7) 12.15(22) 12.31(38) 01.15(53) 01.31(69) 02.15(84) 02.28(97) 03.15(112) 
-- update 1216_1231_drama_feature t1 join(
-- select a.drama_id,
-- SUM(CASE WHEN b.sound_info_view_count = d.max_sound_view_num THEN b.sound_danmu_num ELSE 0 END) as drama_sound_has_max_view_num_sound_danmu_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.max_sound_view_num THEN b.sound_favorite_num ELSE 0 END) as drama_sound_has_max_view_num_sound_favorite_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.max_sound_view_num THEN b.sound_point_num ELSE 0 END) as drama_sound_has_max_view_num_sound_point_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.max_sound_view_num THEN b.sound_info_all_reviews_num ELSE 0 END) as drama_sound_has_max_view_num_sound_review_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.max_sound_view_num THEN b.sound_cv_total_num ELSE 0 END) as drama_sound_has_max_view_num_sound_cv_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.max_sound_view_num THEN b.sound_cv_total_fans_num ELSE 0 END) as drama_sound_has_max_view_num_sound_cv_total_fans_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.max_sound_view_num THEN b.sound_pay_type ELSE 0 END) as drama_sound_has_max_view_num_sound_is_pay,
-- SUM(CASE WHEN b.sound_info_view_count = d.min_sound_view_num THEN b.sound_danmu_num ELSE 0 END) as drama_sound_has_min_view_num_sound_danmu_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.min_sound_view_num THEN b.sound_favorite_num ELSE 0 END) as drama_sound_has_min_view_num_sound_favorite_num,
-- SUM(CASE WHEN b.sound_info_view_count= d.min_sound_view_num THEN b.sound_point_num ELSE 0 END) as drama_sound_has_min_view_num_sound_point_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.min_sound_view_num THEN b.sound_info_all_reviews_num ELSE 0 END) as drama_sound_has_min_view_num_sound_review_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.min_sound_view_num THEN b.sound_cv_total_num ELSE 0 END) as drama_sound_has_min_view_num_sound_cv_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.min_sound_view_num THEN b.sound_cv_total_fans_num ELSE 0 END) as drama_sound_has_min_view_num_sound_cv_total_fans_num,
-- SUM(CASE WHEN b.sound_info_view_count = d.min_sound_view_num THEN b.sound_pay_type ELSE 0 END) as drama_sound_has_min_view_num_sound_is_pay
-- from 0101_0115_drama_feature as a
-- left join(
--  select sound_id,drama_id,sound_info_view_count,sound_info_danmu_count as sound_danmu_num,sound_info_favorite_count as sound_favorite_num,sound_info_all_reviews_num,sound_info_point as sound_point_num,sound_cv_total_num,sound_cv_total_fans_num,sound_info_pay_type as sound_pay_type
--  from  sound_feature_osl_pred_true
--  where datediff_between_1123_to_updatetime = 38 
--  group by sound_id
-- )as b on a.drama_id=b.drama_id
-- left join(
-- 	SELECT a.drama_id,  
--        MAX(t.sound_info_view_count) AS max_sound_view_num,  
--        MIN(t.sound_info_view_count) AS min_sound_view_num  
-- 	FROM 0101_0115_drama_feature AS a  
-- 	JOIN sound_feature_osl_pred_true AS t ON a.drama_id = t.drama_id  
-- 	where datediff_between_1123_to_updatetime = 38
-- 	GROUP BY a.drama_id
-- )as d on a.drama_id=d.drama_id
-- group by a.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_sound_has_max_view_num_sound_danmu_num = t2.drama_sound_has_max_view_num_sound_danmu_num,
-- t1.drama_sound_has_max_view_num_sound_favorite_num = t2.drama_sound_has_max_view_num_sound_favorite_num ,
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

-- create table temp_drama_duration as
-- select t1.drama_id,sum(t3.sound_info_duration) as sound_duration_sum,
-- max(t3.sound_info_duration) as sound_duration_max,
-- min(t3.sound_info_duration) as sound_duration_min,
-- avg(t3.sound_info_duration) as sound_duration_avg
-- from 0101_0115_drama_feature t1 
-- left join maoer.drama_episodes t2 on t1.drama_id=t2.drama_id
-- left join 
-- (select sound_id,sound_info_duration from maoer.sound_info_update group by sound_id) t3
-- on t2.sound_id=t3.sound_id 
-- group by t1.drama_id

-- 更新drama的sound——druation的特征
-- sound天数差值 11.30(7) 12.15(22) 12.31(38) 01.15(53) 01.31(69) 02.15(84) 02.28(97) 03.15(112) 
-- update 1216_1231_drama_feature t left join
-- (select t1.drama_id,
-- t2.sound_duration_sum as drama_sound_total_time,
-- t2.sound_duration_max as drama_sound_max_time,
-- t2.sound_duration_min as drama_sound_min_time,
-- t2.sound_duration_avg as drama_sound_avg_time,
-- SUM(CASE WHEN t4.sound_info_duration = t2.sound_duration_max THEN t3.sound_info_view_count ELSE 0 END) as drama_sound_max_time_sound_view_num,
-- SUM(CASE WHEN t4.sound_info_duration = t2.sound_duration_min THEN t3.sound_info_view_count ELSE 0 END) as drama_sound_min_time_sound_view_num,
-- SUM(CASE WHEN t4.sound_info_duration = t2.sound_duration_max THEN t3.sound_info_danmu_count ELSE 0 END) as drama_sound_max_time_sound_danmu_num,
-- SUM(CASE WHEN t4.sound_info_duration = t2.sound_duration_min THEN t3.sound_info_danmu_count ELSE 0 END) as drama_sound_min_time_sound_danmu_num,
-- SUM(CASE WHEN t4.sound_info_duration = t2.sound_duration_max THEN t3.sound_info_all_reviews_num ELSE 0 END) as drama_sound_max_time_sound_review_num,
-- SUM(CASE WHEN t4.sound_info_duration = t2.sound_duration_min THEN t3.sound_info_all_reviews_num ELSE 0 END) as drama_sound_min_time_sound_review_num
-- from 0101_0115_drama_feature t1
-- join temp_drama_duration t2 on t1.drama_id=t2.drama_id
-- left join (select *
-- from sound_feature_osl_pred_true 
-- where datediff_between_1123_to_updatetime = 38
-- group by sound_id) t3 on t3.drama_id=t1.drama_id
-- left join (select sound_id,sound_info_duration from maoer.sound_info_update group by sound_id) t4
-- on t4.sound_id=t3.sound_id 
-- group by t1.drama_id
-- )z on t.drama_id=z.drama_id
-- set
-- t.drama_sound_total_time = z.drama_sound_total_time ,
-- t.drama_sound_max_time = z.drama_sound_max_time,
-- t.drama_sound_min_time = z.drama_sound_min_time,
-- t.drama_sound_avg_time = z.drama_sound_avg_time,
-- t.drama_sound_max_time_sound_view_num = z.drama_sound_max_time_sound_view_num,
-- t.drama_sound_min_time_sound_view_num = z.drama_sound_min_time_sound_view_num,
-- t.drama_sound_max_time_sound_danmu_num = z.drama_sound_max_time_sound_danmu_num,
-- t.drama_sound_min_time_sound_danmu_num = z.drama_sound_min_time_sound_danmu_num,
-- t.drama_sound_max_time_sound_review_num = z.drama_sound_max_time_sound_review_num,
-- t.drama_sound_min_time_sound_review_num = z.drama_sound_min_time_sound_review_num

-- 更新 剧集up主相关特征
-- 剧集up主 drama_upuser_feature
-- update 0101_0115_drama_feature t1 join (
-- select a.drama_id,
-- e.user_info_grade as drama_upuser_grade,
-- e.user_info_fish_num as drama_upuser_fish_num,
-- e.user_info_fans_num as drama_upuser_fans_num,
-- e.user_info_follower_num as drama_upuser_follower_num,
-- e.user_info_sound_num as drama_upuser_submit_sound_num,
-- e.user_info_drama_num as drama_upuser_submit_drama_num,
-- e.user_info_subscriptions_num as drama_upuser_subscriptions_num,
-- e.user_info_channel as drama_upuser_channel_num
-- from 0101_0115_drama_feature as a
-- left join (
-- 	SELECT drama_id,user_id
-- 	from maoer.drama_info
-- 	group by drama_id
-- ) b on a.drama_id=b.drama_id
-- left join(
-- 	select c.user_id,c.user_info_grade,c.user_info_fish_num,c.user_info_fans_num,c.user_info_follower_num,c.user_info_sound_num,c.user_info_drama_num,c.user_info_subscriptions_num,c.user_info_channel
-- 	from maoer.user_info as c
-- 	join(
-- 		select user_id,min(created_time) min_created_time
-- 		from maoer.user_info
-- 		group by user_id
-- 	) as d on c.user_id=d.user_id and c.created_time=d.min_created_time
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

-- insert into need_deal_drama_upuser_sound (sound_id,sound_info_view_count,sound_info_danmu_count,sound_info_favorite_count,sound_info_all_reviews_num,sound_info_point,created_time,datediff_between_1123_to_updatetime)
-- select t8.sound_id,t7.sound_info_view_count,t7.sound_info_danmu_count,t7.sound_info_favorite_count,t7.sound_info_all_reviews_num,t7.sound_info_point,t7.created_time,DATEDIFF(t7.created_time,'2022-11-23') as datediff_between_1123_to_updatetime
-- from (select t6.sound_id,t5.drama_id
-- from (
-- select distinct t4.drama_id
-- from (
-- select distinct t2.cast_id
-- from 0101_0115_drama_feature t1 
-- left join maoer.cast_drama t2 on t1.drama_id=t2.drama_id
-- ) t3 
-- left join maoer.cast_drama t4 on t3.cast_id=t4.cast_id
-- where t4.drama_id not in (select drama_id from 0101_0115_drama_feature)
-- ) t5 
-- left join maoer.drama_episodes t6 on t5.drama_id=t6.drama_id
-- where t6.sound_id not in (select sound_id from sound_feature_osl_pred_true group by sound_id)
-- group by t6.sound_id
-- )t8
-- left join maoer.sound_info_update t7 on t7.sound_id=t8.sound_id

-- insert into drama_upuser_sound_feature
-- select c.user_id,
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
-- 	avg(f.sound_info_all_reviews_num) as upuser_submit_sound_avg_review_num,
-- 	112 as datediff_between_1123_to_updatetime 
-- 	from (
-- 	select distinct user_id
-- 	from 0101_0115_drama_feature k 
-- 	left join (SELECT drama_id,user_id 
-- 						from maoer.drama_info group by drama_id) m on m.drama_id=k.drama_id
-- 	) c left join maoer.drama_info k on c.user_id=k.user_id
-- 	left join maoer.drama_episodes n on  k.drama_id=n.drama_id
-- 	left join (
-- 	select * from drama_upuser_sound_feature_osl_pred_true 
-- 							where datediff_between_1123_to_updatetime = 112
-- 							group by sound_id
-- 							union select * from sound_feature_osl_pred_true 
-- 							where datediff_between_1123_to_updatetime = 112
-- 							group by sound_id
-- 	) f on f.sound_id=n.sound_id
-- 	group by c.user_id

-- sound天数差值 11.30(7) 12.15(22) 12.31(38) 01.15(53) 01.31(69) 02.15(84) 02.28(97) 03.15(112) 
-- update 0101_0115_drama_feature t1 join(
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
-- from 0101_0115_drama_feature as a
-- left join (
-- 	SELECT drama_id,user_id
-- 	from maoer.drama_info
-- 	group by drama_id
-- ) b on a.drama_id=b.drama_id
-- left join (select * from drama_upuser_sound_feature 
-- 					where datediff_between_1123_to_updatetime =53) g on b.user_id=g.user_id
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

-- update 0101_0115_drama_feature t1 join(
-- select a.drama_id,
-- (if(g.drama_upuser_submit_drama_has_fans_reward>0 and g.drama_upuser_submit_drama_has_fans_reward is not null,1,0)) as drama_upuser_submit_drama_has_fans_reward,
-- (if(g.drama_upuser_submit_drama_has_reward_week_ranking>0 and g.drama_upuser_submit_drama_has_reward_week_ranking is not null,1,0)) as drama_upuser_submit_drama_has_reward_week_ranking,
-- (if(g.drama_upuser_submit_drama_has_reward_month_ranking>0 and g.drama_upuser_submit_drama_has_reward_month_ranking is not null,1,0)) as drama_upuser_submit_drama_has_reward_month_ranking,
-- (if(g.drama_upuser_submit_drama_has_reward_total_ranking>0 and g.drama_upuser_submit_drama_has_reward_total_ranking is not null,1,0)) as drama_upuser_submit_drama_has_reward_total_ranking,
-- g.drama_upuser_submit_drama_reward_week_max_rank,
-- g.drama_upuser_submit_drama_reward_month_max_rank,
-- g.drama_upuser_submit_drama_reward_total_max_rank
-- from 0101_0115_drama_feature as a
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

-- 更新 drama_upuser_submit_sound_max_pay_type 付费类型 0:不付费，1：单集付费，2:全集付费, drama_upuser_submit_sound_pay_sound_percent
-- update 0101_0115_drama_feature a
-- join (
-- select drama_id,
-- CASE WHEN pay_type_sum_0 = GREATEST(pay_type_sum_0, pay_type_sum_1, pay_type_sum_2) THEN 0
--         WHEN pay_type_sum_1 = GREATEST(pay_type_sum_0, pay_type_sum_1, pay_type_sum_2) THEN 1
--         ELSE 2 END AS drama_upuser_submit_sound_max_pay_type,
--  IFNULL((pay_type_sum_1 + pay_type_sum_2) / NULLIF((pay_type_sum_0 + pay_type_sum_1 + pay_type_sum_2), 0), 0) AS drama_upuser_submit_sound_pay_sound_percent
-- from (
-- select t1.drama_id,
-- sum(case when t2.sound_info_pay_type=0 then 1 else 0 end) as pay_type_sum_0,
-- sum(case when t2.sound_info_pay_type=1 then 1 else 0 end) as pay_type_sum_1,
-- sum(case when t2.sound_info_pay_type=2 then 1 else 0 end) as pay_type_sum_2
-- from 0101_0115_drama_feature t1 
-- left join (select drama_id,user_id from maoer.drama_info group by drama_id) t3 
-- on t1.drama_id=t3.drama_id
-- join (select sound_id,user_id,sound_info_pay_type from maoer.sound_info group by sound_id) t2 
-- on t2.user_id=t3.user_id
-- group by t1.drama_id) t
-- ) b on a.drama_id=b.drama_id
-- set
-- a.drama_upuser_submit_sound_max_pay_type= b.drama_upuser_submit_sound_max_pay_type,
-- a.drama_upuser_submit_sound_pay_sound_percent = b.drama_upuser_submit_sound_pay_sound_percent

-- 更新drama sound danmu feature
-- update 0101_0115_drama_feature t1 
-- left join (
-- select t5.drama_id,
-- avg(t3.danmu_len_avg) as drama_danmu_avg_len,
-- max(t3.danmu_len_avg) as drama_danmu_max_len,
-- min(t3.danmu_len_avg) as drama_danmu_min_len,
-- max(t3.danmu_create_time_max) as drama_danmu_submit_time_between_submit_sound_time_max,
-- min(t3.danmu_create_time_min) as drama_danmu_submit_time_between_submit_sound_time_min,
-- avg(t3.danmu_create_time_avg) as drama_danmu_submit_time_between_submit_sound_time_avg,
-- max(t3.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_max,
-- min(t3.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_min,
-- avg(t3.danmu_submit_time_between_submit_sound_time_in_7days_num) as drama_danmu_time_between_sound_time_in_7days_num_avg,
-- max(t3.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_max,
-- min(t3.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_min,
-- avg(t3.danmu_submit_time_between_submit_sound_time_in_14days_num) as drama_danmu_time_between_sound_time_in_14days_num_avg,
-- max(t3.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_max,
-- min(t3.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_min,
-- avg(t3.danmu_submit_time_between_submit_sound_time_in_30days_num) as drama_danmu_time_between_sound_time_in_30days_num_avg
-- from 0101_0115_drama_feature t5
-- left join maoer.drama_episodes t6 on t5.drama_id=t6.drama_id
-- left join (select sound_id,danmu_len_avg, danmu_create_time_max,danmu_create_time_min,danmu_create_time_avg,danmu_submit_time_between_submit_sound_time_in_7days_num,danmu_submit_time_between_submit_sound_time_in_14days_num,danmu_submit_time_between_submit_sound_time_in_30days_num
-- 					from maoer_data_analysis.sound_danmu_feature 
-- 	union select sound_id,danmu_len_avg, danmu_create_time_max,danmu_create_time_min,danmu_create_time_avg,danmu_submit_time_between_submit_sound_time_in_7days_num,danmu_submit_time_between_submit_sound_time_in_14days_num,danmu_submit_time_between_submit_sound_time_in_30days_num from supply_sound_danmu_feature) t3 on t3.sound_id=t6.sound_id
-- group by t5.drama_id
-- ) t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_danmu_avg_len = t2.drama_danmu_avg_len,
-- t1.drama_danmu_max_len = t2.drama_danmu_max_len,
-- t1.drama_danmu_min_len = t2.drama_danmu_min_len ,
-- t1.drama_danmu_submit_time_between_submit_sound_time_max = t2.drama_danmu_submit_time_between_submit_sound_time_max,
-- t1.drama_danmu_submit_time_between_submit_sound_time_min = t2.drama_danmu_submit_time_between_submit_sound_time_min,
-- t1.drama_danmu_submit_time_between_submit_sound_time_avg = t2.drama_danmu_submit_time_between_submit_sound_time_avg ,
-- t1.drama_danmu_time_between_sound_time_in_7days_num_max = t2.drama_danmu_time_between_sound_time_in_7days_num_max,
-- t1.drama_danmu_time_between_sound_time_in_7days_num_min = t2.drama_danmu_time_between_sound_time_in_7days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_7days_num_avg = t2.drama_danmu_time_between_sound_time_in_7days_num_avg,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_max = t2.drama_danmu_time_between_sound_time_in_14days_num_max,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_min = t2.drama_danmu_time_between_sound_time_in_14days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_14days_num_avg = t2.drama_danmu_time_between_sound_time_in_14days_num_avg,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_max = t2.drama_danmu_time_between_sound_time_in_30days_num_max,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_min = t2.drama_danmu_time_between_sound_time_in_30days_num_min,
-- t1.drama_danmu_time_between_sound_time_in_30days_num_avg = t2.drama_danmu_time_between_sound_time_in_30days_num_avg


-- 构建drama_tag_feature
-- update 0101_0115_drama_feature t1
-- join (
-- select h.drama_id,
-- sum(case when h.tag_info_sound_num is not null then h.tag_info_sound_num else 0 end) as drama_sound_tag_total_cite_num,
-- max(case when h.tag_info_sound_num is not null then h.tag_info_sound_num else 0 end) as drama_sound_tag_max_cite_num,
-- min(case when h.tag_info_sound_num is not null then h.tag_info_sound_num else 10000000 end) as drama_sound_tag_min_cite_num,
-- avg(case when h.tag_info_sound_num is not null then h.tag_info_sound_num else 0 end) as drama_sound_tag_avg_cite_num
-- from (
-- select d.drama_id,a.tag_id,a.tag_info_sound_num
-- from 0101_0115_drama_feature z 
-- left join (select drama_id,sound_id from maoer.drama_episodes group by drama_id,sound_id) d on z.drama_id=d.drama_id
-- left join maoer.sound_tags s on s.sound_id=d.sound_id 
-- left join (select tag_id,tag_info_sound_num from maoer.tag_info_update group by tag_id) a on a.tag_id=s.tag_id
-- group by d.drama_id,a.tag_id) h
-- group by h.drama_id
-- )t2 on t1.drama_id=t2.drama_id
-- SET
-- t1.drama_sound_tag_total_cite_num = t2.drama_sound_tag_total_cite_num,
-- t1.drama_sound_tag_max_cite_num = t2.drama_sound_tag_max_cite_num,
-- t1.drama_sound_tag_min_cite_num = t2.drama_sound_tag_min_cite_num,
-- t1.drama_sound_tag_avg_cite_num = t2.drama_sound_tag_avg_cite_num

-- update 1216_1231_drama_feature t1 join 
-- 0101_0115_drama_feature t2 on t1.drama_id=t2.drama_id
-- set
-- t1.drama_sound_tag_total_cite_num = t2.drama_sound_tag_total_cite_num,
-- t1.drama_sound_tag_max_cite_num = t2.drama_sound_tag_max_cite_num,
-- t1.drama_sound_tag_min_cite_num = t2.drama_sound_tag_min_cite_num,
-- t1.drama_sound_tag_avg_cite_num = t2.drama_sound_tag_avg_cite_num

-- update 0201_0230_drama_feature t1
-- join maoer_data_analysis.drama_fans_reward_feature t2 on t1.drama_id=t2.drama_id
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
-- t1.drama_fans_reward_total_ranking_avg_coin = t2.drama_fans_reward_total_ranking_avg_coin,
-- t1.drama_fans_create_time_between_submit_drama_time_max = t2.drama_fans_create_time_between_submit_drama_time_max,
-- t1.drama_fans_create_time_between_submit_drama_time_min = t2.drama_fans_create_time_between_submit_drama_time_min,
-- t1.drama_fans_create_time_between_submit_drama_time_avg = t2.drama_fans_create_time_between_submit_drama_time_avg,
-- t1.drama_fans_create_time_between_latest_drama_time_max = t2.drama_fans_create_time_between_latest_drama_time_max,
-- t1.drama_fans_create_time_between_latest_drama_time_min = t2.drama_fans_create_time_between_latest_drama_time_min,
-- t1.drama_fans_create_time_between_latest_drama_time_avg = t2.drama_fans_create_time_between_latest_drama_time_avg,
-- 
-- t1.drama_fans_month_create_time_between_submit_drama_time_max = t2.drama_fans_month_create_time_between_submit_drama_time_max,
-- t1.drama_fans_month_create_time_between_submit_drama_time_min = t2.drama_fans_month_create_time_between_submit_drama_time_min,
-- t1.drama_fans_month_create_time_between_submit_drama_time_avg = t2.drama_fans_month_create_time_between_submit_drama_time_avg,
-- t1.drama_fans_month_create_time_between_latest_drama_time_max = t2.drama_fans_month_create_time_between_latest_drama_time_max,
-- t1.drama_fans_month_create_time_between_latest_drama_time_min = t2.drama_fans_month_create_time_between_latest_drama_time_min,
-- t1.drama_fans_month_create_time_between_latest_drama_time_avg = t2.drama_fans_month_create_time_between_latest_drama_time_avg,
-- 
-- t1.drama_fans_total_create_time_between_submit_drama_time_max = t2.drama_fans_total_create_time_between_submit_drama_time_max,
-- t1.drama_fans_total_create_time_between_submit_drama_time_min = t2.drama_fans_total_create_time_between_submit_drama_time_min,
-- t1.drama_fans_total_create_time_between_submit_drama_time_avg = t2.drama_fans_total_create_time_between_submit_drama_time_avg,
-- t1.drama_fans_total_create_time_between_latest_drama_time_max = t2.drama_fans_total_create_time_between_latest_drama_time_max,
-- t1.drama_fans_total_create_time_between_latest_drama_time_min = t2.drama_fans_total_create_time_between_latest_drama_time_min,
-- t1.drama_fans_total_create_time_between_latest_drama_time_avg = t2.drama_fans_total_create_time_between_latest_drama_time_avg



-- -----------------------声音的动态特征最小二乘估计---------------------------------
-- 2022-11-23 22:31:34
-- select min(created_time) from active_sound_exceed_avg

-- 活跃声音中 有668个声音只有1条记录，10623有大于1条记录  
-- select sum(case when (sound_count>1) then 1 else 0 end)
-- from (select count(1)as sound_count from active_sound_exceed_avg group by sound_id) as a

-- 更新声音更新时间距离最小created_time的天数差值
-- update active_sound_exceed_avg 
-- set
-- datediff_between_1123_to_updatetime = DATEDIFF(created_time,'2022-11-23')
-- select count(distinct sound_id)
-- from active_sound_exceed_avg

-- 7 22 38 53 69 84 97 112  最终完成第11241个声音的pred 共10622个声音
-- select sound_id,sound_info_view_count,sound_info_danmu_count,sound_info_favorite_count,sound_info_all_reviews_num,sound_info_point,datediff_between_1123_to_updatetime
-- from active_sound_exceed_avg
-- 
-- select distinct t2.sound_id from 0101_0115_drama_feature t1 left join maoer.drama_episodes t2 on t1.drama_id=t2.drama_id
-- 
-- select count(distinct sound_id) from maoer.sound_info_update where sound_id='3461421' created_time='2023-11-10'

-- need_deal_active_sound_osl
-- create table need_delete_active_drama_id
-- select distinct t1.drama_id
-- from maoer.drama_episodes t1 right join (
-- select distinct a.sound_id
-- from (
-- select sound_id,count(1) as sound_count 
-- from active_sound_exceed_avg group by sound_id
-- ) a
-- where a.sound_count<=1) t2 on t1.sound_id=t2.sound_id

-- insert into active_sound_exceed_avg (sound_id,sound_info_view_count,sound_info_danmu_count,sound_info_favorite_count,sound_info_all_reviews_num,sound_info_point,sound_info_pay_type,sound_info_created_time,created_time,datediff_between_1123_to_updatetime)
-- select t1.sound_id,t2.sound_info_view_count,t2.sound_info_danmu_count,t2.sound_info_favorite_count,(t2.sound_info_review_count + t2.sound_info_sub_review_count) as sound_info_all_reviews_num,t2.sound_info_point,t3.sound_info_pay_type,t3.sound_info_created_time,t2.created_time,
-- DATEDIFF(t2.created_time,'2022-11-23') as datediff_between_1123_to_updatetime
-- from need_deal_active_sound_osl t1 
-- left join maoer.sound_info_update t2 on t1.sound_id=t2.sound_id
-- left join maoer.sound_info t3 on t1.sound_id=t3.sound_id
-- where t2.created_time>'2023-11-01'

-- update active_sound_exceed_avg t1 left join 
-- maoer.drama_episodes t2 on t1.sound_id=t2.sound_id
-- left join maoer.drama_info_update t3 on t2.drama_id=t3.drama_id 
-- set
-- t1.drama_info_price = t3.drama_info_price


-- update sound_feature_osl_pred t2 left join
-- (
-- select sound_id,sound_info_pay_type,sound_info_created_time,drama_info_price
-- from active_sound_exceed_avg 
-- group by sound_id
-- ) t1 on t1.sound_id=t2.sound_id
-- set
-- t2.sound_info_pay_type= t1.sound_info_pay_type,
-- t2.sound_info_created_time = t1.sound_info_created_time,
-- t2.drama_info_price = t1.drama_info_price

-- sound_feature_osl_pred_true
-- delete from sound_feature_osl_pred_true where DATEDIFF(sound_info_created_time,'2022-11-23')>datediff_between_1123_to_updatetime

-- create table temp_need_deal_drama_sound
-- select distinct t5.sound_id
-- from (
-- select t3.sound_id,count(1) as sound_count
-- from maoer.sound_info_update t3 right join (
-- select distinct sound_id
-- from 0101_0115_drama_feature t1 
-- left join maoer.drama_episodes t2 on t1.drama_id=t2.drama_id
-- where sound_id not in (select sound_id from active_sound_exceed_avg group by sound_id)
-- ) t4 on t3.sound_id=t4.sound_id
-- group by t3.sound_id) t5
-- where t5.sound_count=1

-- create table need_deal_drama_sound_repeat
-- select t1.sound_id,t2.sound_info_view_count,t2.sound_info_danmu_count,t2.sound_info_favorite_count,(t2.sound_info_review_count+ t2.sound_info_sub_review_count)as sound_info_all_reviews_num,t2.sound_info_point,t5.sound_info_pay_type,t4.drama_info_price,t5.sound_info_created_time,t2.created_time,DATEDIFF(t2.created_time,'2022-11-23') as datediff_between_1123_to_updatetime
-- from (select distinct sound_id
-- from 0101_0115_drama_feature t7 
-- left join maoer.drama_episodes t8 on t7.drama_id=t8.drama_id
-- where sound_id not in (select sound_id from active_sound_exceed_avg group by sound_id)) t1 
-- left join maoer.sound_info t5 on t1.sound_id=t5.sound_id
-- left join maoer.sound_info_update t2 on t2.sound_id=t1.sound_id
-- left join maoer.drama_episodes t3 on t3.sound_id=t1.sound_id
-- left join maoer.drama_info_update t4 on t3.drama_id=t4.drama_id

-- create table need_deal_drama_sound
-- select *
-- from need_deal_drama_sound_repeat
-- group by sound_id,datediff_between_1123_to_updatetime

-- sound_feature_osl_pred_true
-- delete from sound_feature_osl_pred_true where DATEDIFF(sound_info_created_time,'2022-11-23')>datediff_between_1123_to_updatetime

-- update sound_feature_osl_pred t1 join 
-- (
-- select * from need_deal_drama_sound group by sound_id
-- ) t2 on t1.sound_id=t2.sound_id
-- set
-- t1.sound_info_pay_type=t2.sound_info_pay_type,
-- t1.drama_info_price =  t2.drama_info_price,
-- t1.sound_info_created_time=t2.sound_info_created_time,
-- t1.is_pred=1
-- ----------------------------------------------------------------------------------------
-- insert into  supply_sound_danmu_traffic_feature
-- select t1.sound_id,t3.danmu_id,t1.sound_info_duration,t3.danmu_info_stime_notransform,CEIL(t3.danmu_info_stime_notransform/30) as 30s_position_in_sound,t3.danmu_info_stime_notransform/sound_info_duration as position_in_sound
-- from supply_sound_feature t1
-- join (select sound_id,danmu_id,danmu_info_stime_notransform 
-- from maoer.danmu_info 
-- where sound_id=27308
-- group by sound_id,danmu_id) t3 on t3.sound_id=t1.sound_id

-- create table need_deal_drama_sound_feature_drama as 
-- select distinct t1.drama_id from 0101_0115_drama_feature t1 left join maoer.drama_episodes t3 on t1.drama_id=t3.drama_id join (select sound_id from maoer.sound_info where sound_info_created_time <'2023-03-15' group by sound_id) t4 on t4.sound_id=t3.sound_id
-- -- join maoer_data_analysis.sound_danmu_feature t2 on t3.sound_id=t2.sound_id
-- where t1.drama_id not in (
-- select distinct t1.drama_id from 0101_0115_drama_feature t1 left join maoer.drama_episodes t3 on t1.drama_id=t3.drama_id join (select sound_id from maoer.sound_info where sound_info_created_time <'2023-03-15' group by sound_id) t4 on t4.sound_id=t3.sound_id
-- join
-- maoer_data_analysis.sound_danmu_feature t2 on t3.sound_id=t2.sound_id
-- )

-- create table need_deal_drama_sound_feature_sound as 
-- select distinct t4.sound_id,t4.sound_info_created_time
-- from need_deal_drama_sound_feature_drama t1 left join maoer.drama_episodes t3 on t1.drama_id=t3.drama_id join (select sound_id,sound_info_created_time from maoer.sound_info where sound_info_created_time <'2023-03-15' group by sound_id) t4 on t4.sound_id=t3.sound_id

-- 构建sound_danmu_feature
-- create table supply_sound_danmu_feature as 
-- select f.sound_id,avg(LENGTH(a.danmu_info_text)) as danmu_len_avg,max(LENGTH(a.danmu_info_text)) as danmu_len_max,min(LENGTH(a.danmu_info_text)) as danmu_len_min,
-- max(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_max,
-- min(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_min,
-- avg(DATEDIFF(a.danmu_info_date, f.sound_info_created_time)) as danmu_create_time_avg,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>7 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_7days_num,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>14 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_14days_num,
-- sum(case when DATEDIFF(a.danmu_info_date, f.sound_info_created_time)>30 then 1 else 0 end) as danmu_submit_time_between_submit_sound_time_in_30days_num
-- from need_deal_drama_sound_feature_sound f 
-- left join (
-- select distinct e.danmu_id,e.sound_id,e.danmu_info_text,e.danmu_info_date
-- from maoer.danmu_info as e) as a on a.sound_id=f.sound_id
-- group by f.sound_id

-- alter table supply_sound_danmu_feature
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

-- update supply_sound_danmu_feature t1 join sound_feature t2
-- on t1.sound_id=t2.sound_id
-- SET
-- t1.danmu_submit_time_between_submit_sound_time_max = t2.sound_danmu_submit_time_between_submit_sound_time_max,
-- t1.danmu_submit_time_between_submit_sound_time_min = t2.sound_danmu_submit_time_between_submit_sound_time_min,
-- t1.danmu_submit_time_between_submit_sound_time_avg = t2.sound_danmu_submit_time_between_submit_sound_time_avg

-- insert into need_delete_active_drama_id
-- select drama_id from 0101_0115_drama_feature where drama_total_review_num is null and  drama_id not in(select drama_id from need_delete_active_drama_id)
-- 
-- insert into need_delete_active_drama_id
-- select distinct t3.sound_id from need_delete_active_drama_id t1 
-- left join maoer.drama_episodes t2 on t1.drama_id=t2.drama_id
-- left join maoer.sound_info t3 on t2.sound_id=t3.sound_id
-- where t3.sound_id not in(select sound_id from need_delete_active_sound_id)

-- insert into need_delete_active_drama_id
-- select drama_id from 0101_0115_drama_feature where drama_total_review_num is null and  drama_id not in(select drama_id from need_delete_active_drama_id)
-- 
-- insert into need_delete_active_drama_id
-- select distinct t3.sound_id from need_delete_active_drama_id t1 
-- left join maoer.drama_episodes t2 on t1.drama_id=t2.drama_id
-- left join maoer.sound_info t3 on t2.sound_id=t3.sound_id
-- where t3.sound_id not in(select sound_id from need_delete_active_sound_id)

-- ------------------------------整合----------------------------------------------------------
-- select t1.sound_id
-- from (
-- select t1.sound_id
-- from lingyun_maoer_analysis_time.activeuser_submit_danmu_sound_with_drama_202211_202303 t1
-- join (select distinct sound_id from active_sound_exceed_avg) t2 on t1.sound_id=t2.sound_id
-- where t1.sound_id<='1005552' group by t1.sound_id
-- ) t1 
-- left join (select sound_id from supply_danmu_involved_activeuser_202211_202303
-- group by sound_id) t2 on t1.sound_id=t2.sound_id
-- where t2.sound_id is null

-- 查看现有契合度的和user_sound的形成的数据集的数量
select count(1)
from (
select user_id,sound_id from danmu_involved_activeuser_202211_202303 group by user_id,sound_id union
select user_id,sound_id from supply_danmu_involved_activeuser_202211_202303 group by user_id,sound_id
)t1 join (select user_id,sound_id from 0101_0131_user_sound_feature group by user_id,sound_id) t2 on t1.sound_id=t2.sound_id and t1.user_id=t2.user_id

select count(1)
from (
select user_id,sound_id from danmu_involved_activeuser_202211_202303 group by user_id,sound_id union
select user_id,sound_id from supply_danmu_involved_activeuser_202211_202303 group by user_id,sound_id
)t1 join (select t1.user_id,t1.sound_id from activeuser_submit_danmu_sound_with_drama_202211_202303 t1 join active_sound_exceed_avg t2 on t1.sound_id=t2.sound_id group by t1.user_id,t1.sound_id) t2 on t1.sound_id=t2.sound_id and t1.user_id=t2.user_id

-- select count(distinct t1.user_id,t1.sound_id) from activeuser_submit_danmu_sound_with_drama_202211_202303 t1 join active_sound_exceed_avg t2 on t1.sound_id=t2.sound_id

-- 计算总的用户截止至时间窗是否对剧集有购买
-- alter table  0301_0315_user_sound_feature
-- add COLUMN user_in_drama_is_pay_for_drama_until_timewindows int(1)

-- update  0301_0315_user_sound_feature t1 join(
-- select t3.user_id,t3.drama_id,t3.user_in_drama_is_pay_for_drama,sum(case when user_in_drama_is_pay_for_drama=1 then 1 else 0 end) as user_in_drama_is_pay_for_drama_until_timewindows
-- from (select user_id,drama_id,user_in_drama_is_pay_for_drama from 1101_1130_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 1115_1215_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 1201_1215_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 1201_1231_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 1215_0115_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 1216_1231_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 0101_0115_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 0101_0131_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 0115_0215_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 0116_0131_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 0201_0215_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 0201_0230_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 0216_0230_user_sound_feature union
-- select user_id,drama_id,user_in_drama_is_pay_for_drama from 0301_0315_user_sound_feature 
-- ) t3 
-- group by t3.user_id,t3.drama_id
-- )t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
-- set
-- t1.user_in_drama_is_pay_for_drama_until_timewindows =(case when t2.user_in_drama_is_pay_for_drama_until_timewindows>=1 then 1 when t2.user_in_drama_is_pay_for_drama_until_timewindows=0  then t2.user_in_drama_is_pay_for_drama end )

-- 查看现有音频特征的覆盖范围
-- select count(1) from maoer_data_analysis.feat_sound_opensmile384_new t1 join (select sound_id from activeuser_submit_danmu_sound_with_drama_202211_202303 group by sound_id) t2 on t1.sound_id=t2.sound_id

-- 用户对声音付费的比例
-- select count(distinct t2.sound_id) from activeuser_submit_danmu_sound_with_drama_202211_202303 t2
-- join (select sound_id,sound_info_pay_type from maoer.sound_info group by sound_id) t3 on t2.sound_id=t3.sound_id  where t3.sound_info_pay_type=0

-- 输出文档
-- create table final_active_userandsound_list as 
-- select distinct t1.user_id,t1.sound_id,t1.drama_id from activeuser_submit_danmu_sound_with_drama_202211_202303 t1 join active_sound_exceed_avg t2 on t1.sound_id=t2.sound_id

-- 输出文档测试
-- select *
-- from (select * from final_active_userandsound_list where sound_id=6787582) t1 
-- join (select * from 0101_0115_user_sound_feature where sound_id=6787582) t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 
-- left join (select *from 0101_0115_sound_feature where sound_id=6787582) t3 on t1.sound_id=t3.sound_id
-- left join 0101_0115_user_feature  t4 on t1.user_id=t4.user_id
-- left join 0101_0115_drama_feature t5 on t1.drama_id=t5.drama_id
-- left join (select * from maoer_data_analysis.feat_sound_opensmile384_new where sound_id=6787582) t6 on t1.sound_id=t6.sound_id
-- where t1.sound_id=6787582

-- 输出文档
create table 0301_0315_all_feature_involved as 
select t1.user_id,t1.sound_id as sound_id_id,t1.drama_id,
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
-- t4.user_submit_danmu_drama_completed_num_all,
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
t4.user_submit_danmu_sound_total_view_num,
t4.user_submit_danmu_sound_max_view_num,
t4.user_submit_danmu_sound_min_view_num,
t4.user_submit_danmu_sound_avg_view_num,
t4.user_submit_danmu_sound_total_danmu_num,
t4.user_submit_danmu_sound_max_danmu_num,
t4.user_submit_danmu_sound_min_danmu_num,
t4.user_submit_danmu_sound_avg_danmu_num,
t4.user_submit_danmu_sound_total_review_num,
t4.user_submit_danmu_sound_max_review_num,
t4.user_submit_danmu_sound_min_review_num,
t4.user_submit_danmu_sound_avg_review_num,
-- t4.user_has_in_drama_fans_reward_num,
-- t4.user_has_in_drama_fans_reward_total_money,
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
t2.user_in_drama_total_review_num,
t2.user_in_drama_total_danmu_num,

t3.sound_title_len,
t3.sound_intro_len,
t3.sound_tag_num,
-- t3.sound_pay_type,
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
t3.sound_view_num_in_total_darma_percent,
t3.sound_danmu_num_in_total_darma_percent,
t3.sound_favorite_num_in_total_darma_percent,
t3.sound_point_num_in_total_darma_percent,
t3.sound_review_num_in_total_darma_percent,
t3.sound_not_subreview_num_in_total_darma_percent,
t3.sound_subreview_num_in_total_darma_percent,
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
-- t5.drama_pay_type,
-- t5.drama_total_pay_money,
-- t5.drama_pay_sound_percent,
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
t5.drama_total_danmu_num,
t5.drama_max_danmu_num,
t5.drama_min_danmu_num,
t5.drama_avg_danmu_num,
t5.drama_total_favorite_num,
t5.drama_max_favorite_num,
t5.drama_min_favorite_num,
t5.drama_avg_favorite_num,
t5.drama_total_point_num,
t5.drama_max_point_num,
t5.drama_min_point_num,
t5.drama_avg_point_num,
t5.drama_total_review_num,
t5.drama_max_review_num,
t5.drama_min_review_num,
t5.drama_avg_review_num,
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
-- t5.drama_upuser_submit_drama_has_reward_week_ranking,
-- t5.drama_upuser_submit_drama_has_reward_month_ranking,
-- t5.drama_upuser_submit_drama_has_reward_total_ranking,
-- t5.drama_upuser_submit_drama_reward_week_max_rank,
-- t5.drama_upuser_submit_drama_reward_month_max_rank,
-- t5.drama_upuser_submit_drama_reward_total_max_rank,
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

t6.*,
t2.user_in_drama_is_pay_for_drama,
t2.user_in_drama_sound_pay_type,
t2.user_in_drama_is_pay_for_drama_until_timewindows,
t1.0301_0315_sim_1,
t1.0301_0315_sim_max,
t1.0301_0315_sim_min,
t1.0301_0315_sim_avg

-- from final_active_userandsoun_list t1   -- 这是筛过活跃声音的allfeature基础
from final_active_userandsound_involved_list t1 -- 这是基于所有契合度的allfeature基础
join 0301_0315_user_sound_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 
left join 0301_0315_sound_feature t3 on t1.sound_id=t3.sound_id
left join 0301_0315_user_feature  t4 on t1.user_id=t4.user_id
left join 0301_0315_drama_feature t5 on t1.drama_id=t5.drama_id
left join maoer_data_analysis.feat_sound_opensmile384_new t6 on t1.sound_id=t6.sound_id


-- 创建契合度的表
-- 首先将suply契合度表全部插入danmu_involved_activeuser_202211_202303表
-- insert into danmu_involved_activeuser_202211_202303
-- select t1.*
-- from supply_danmu_involved_activeuser_202211_202303 t1 left join danmu_involved_activeuser_202211_202303 t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- where t2.danmu_id is null

-- 创建新最终契合度的用户+声音+剧集表 final_active_userandsound_involved_list
-- 弃用 换成下面的生成新表
-- create table final_active_userandsound_involved_list
-- select t1.user_id,t1.sound_id,t2.drama_id -- ,sim_1,sim_max,sim_min,sim_avg
-- from 
-- (select * from danmu_involved_activeuser_202211_202303_allinfo group by user_id,sound_id) t1
-- left join (select sound_id,drama_id from activeuser_submit_danmu_sound_with_drama_202211_202303 group by sound_id)t2 on t1.sound_id=t2.sound_id

-- 弃用 换成下面的生成新表
-- alter table final_active_userandsound_involved_list
-- add COLUMN 0101_0115_sim_1 DECIMAL(24,6),
-- add COLUMN 0101_0115_sim_max DECIMAL(24,6),
-- add COLUMN 0101_0115_sim_min DECIMAL(24,6),
-- add COLUMN 0101_0115_sim_avg DECIMAL(24,6),
-- add COLUMN 0101_0131_sim_1 DECIMAL(24,6),
-- add COLUMN 0101_0131_sim_max DECIMAL(24,6),
-- add COLUMN 0101_0131_sim_min DECIMAL(24,6),
-- add COLUMN 0101_0131_sim_avg DECIMAL(24,6),
-- add COLUMN 0115_0215_sim_1 DECIMAL(24,6),
-- add COLUMN 0115_0215_sim_max DECIMAL(24,6),
-- add COLUMN 0115_0215_sim_min DECIMAL(24,6),
-- add COLUMN 0115_0215_sim_avg DECIMAL(24,6),
-- add COLUMN 0116_0131_sim_1 DECIMAL(24,6),
-- add COLUMN 0116_0131_sim_max DECIMAL(24,6),
-- add COLUMN 0116_0131_sim_min DECIMAL(24,6),
-- add COLUMN 0116_0131_sim_avg DECIMAL(24,6),
-- add COLUMN 0201_0215_sim_1 DECIMAL(24,6),
-- add COLUMN 0201_0215_sim_max DECIMAL(24,6),
-- add COLUMN 0201_0215_sim_min DECIMAL(24,6),
-- add COLUMN 0201_0215_sim_avg DECIMAL(24,6),
-- add COLUMN 0201_0230_sim_1 DECIMAL(24,6),
-- add COLUMN 0201_0230_sim_max DECIMAL(24,6),
-- add COLUMN 0201_0230_sim_min DECIMAL(24,6),
-- add COLUMN 0201_0230_sim_avg DECIMAL(24,6),
-- add COLUMN 0216_0230_sim_1 DECIMAL(24,6),
-- add COLUMN 0216_0230_sim_max DECIMAL(24,6),
-- add COLUMN 0216_0230_sim_min DECIMAL(24,6),
-- add COLUMN 0216_0230_sim_avg DECIMAL(24,6),
-- add COLUMN 0301_0315_sim_1 DECIMAL(24,6),
-- add COLUMN 0301_0315_sim_max DECIMAL(24,6),
-- add COLUMN 0301_0315_sim_min DECIMAL(24,6),
-- add COLUMN 0301_0315_sim_avg DECIMAL(24,6),
-- add COLUMN 1101_1130_sim_1 DECIMAL(24,6),
-- add COLUMN 1101_1130_sim_max DECIMAL(24,6),
-- add COLUMN 1101_1130_sim_min DECIMAL(24,6),
-- add COLUMN 1101_1130_sim_avg DECIMAL(24,6),
-- add COLUMN 1115_1215_sim_1 DECIMAL(24,6),
-- add COLUMN 1115_1215_sim_max DECIMAL(24,6),
-- add COLUMN 1115_1215_sim_min DECIMAL(24,6),
-- add COLUMN 1115_1215_sim_avg DECIMAL(24,6),
-- add COLUMN 1201_1215_sim_1 DECIMAL(24,6),
-- add COLUMN 1201_1215_sim_max DECIMAL(24,6),
-- add COLUMN 1201_1215_sim_min DECIMAL(24,6),
-- add COLUMN 1201_1215_sim_avg DECIMAL(24,6),
-- add COLUMN 1201_1231_sim_1 DECIMAL(24,6),
-- add COLUMN 1201_1231_sim_max DECIMAL(24,6),
-- add COLUMN 1201_1231_sim_min DECIMAL(24,6),
-- add COLUMN 1201_1231_sim_avg DECIMAL(24,6),
-- add COLUMN 1215_0115_sim_1 DECIMAL(24,6),
-- add COLUMN 1215_0115_sim_max DECIMAL(24,6),
-- add COLUMN 1215_0115_sim_min DECIMAL(24,6),
-- add COLUMN 1215_0115_sim_avg DECIMAL(24,6),
-- add COLUMN 1216_1231_sim_1 DECIMAL(24,6),
-- add COLUMN 1216_1231_sim_max DECIMAL(24,6),
-- add COLUMN 1216_1231_sim_min DECIMAL(24,6),
-- add COLUMN 1216_1231_sim_avg DECIMAL(24,6)

-- 生成新的弹幕契合度表 这里计算有很多新的值
-- 1.更新新的user_in_drama_is_pay_for_drama_in_next_time
-- 2.生成0101_0131_danmu_involved新表  3.关联旧表生成新的输出表
-- k*(q*当前弹幕前8s的契合度+(1-q)*当前归一化后前8s弹幕数量)+(1-k)*(q*当前弹幕后8s的契合度+(1-q)*当前归一化后后8s弹幕数量) 
-- k_1/2/3表示k=0.3,0.5,0.7,q_1/2/3表示q=0.3,0.5,0.7
create table 0101_0131_danmu_involved
select t1.user_id,t1.sound_id,t1.drama_id,avg(all_8_sim_1) as all_8_sim,avg(all_15_sim_1)as all_15_sim,
avg(0.3*before_8_sim_1+0.7*after_8_sim_1) as k_1_8s_sim,
avg(0.5*before_8_sim_1+0.5*after_8_sim_1) as k_2_8s_sim,
avg(0.7*before_8_sim_1+0.3*after_8_sim_1) as k_3_8s_sim,
avg(0.3*before_15_sim_1+0.7*after_15_sim_1) as k_1_15s_sim,
avg(0.5*before_15_sim_1+0.5*after_15_sim_1) as k_2_15s_sim,
avg(0.7*before_15_sim_1+0.3*after_15_sim_1) as k_3_15s_sim,
avg(0.5*(0.3*before_8_sim_1+0.7*((danmu_num_before_8s-danmu_num_before_8s_min)/(danmu_num_before_8s_max-danmu_num_before_8s_min)))+0.5*(0.3*after_8_sim_1+0.7*((danmu_num_after_8s-danmu_num_after_8s_min)/(danmu_num_after_8s_max-danmu_num_after_8s_min)))) as k_2_8s_sim_q_1_num,
avg(0.5*(0.5*before_8_sim_1+0.5*((danmu_num_before_8s-danmu_num_before_8s_min)/(danmu_num_before_8s_max-danmu_num_before_8s_min)))+0.5*(0.5*after_8_sim_1+0.5*((danmu_num_after_8s-danmu_num_after_8s_min)/(danmu_num_after_8s_max-danmu_num_after_8s_min)))) as k_2_8s_sim_q_2_num,
avg(0.5*(0.7*before_8_sim_1+0.3*((danmu_num_before_8s-danmu_num_before_8s_min)/(danmu_num_before_8s_max-danmu_num_before_8s_min)))+0.5*(0.7*after_8_sim_1+0.3*((danmu_num_after_8s-danmu_num_after_8s_min)/(danmu_num_after_8s_max-danmu_num_after_8s_min)))) as k_2_8s_sim_q_3_num,
avg(0.5*(0.3*before_15_sim_1+0.7*((danmu_num_before_15s_all-danmu_num_before_15s_min)/(danmu_num_before_15s_max-danmu_num_before_15s_min)))+0.5*(0.3*after_15_sim_1+0.7*((danmu_num_after_15s_all-danmu_num_after_15s_min)/(danmu_num_after_15s_max-danmu_num_after_15s_min)))) as k_2_15s_sim_q_1_num,
avg(0.5*(0.5*before_15_sim_1+0.5*((danmu_num_before_15s_all-danmu_num_before_15s_min)/(danmu_num_before_15s_max-danmu_num_before_15s_min)))+0.5*(0.5*after_15_sim_1+0.5*((danmu_num_after_15s_all-danmu_num_after_15s_min)/(danmu_num_after_15s_max-danmu_num_after_15s_min)))) as k_2_15s_sim_q_2_num,
avg(0.5*(0.5*before_15_sim_1+0.5*((danmu_num_before_15s_all-danmu_num_before_15s_min)/(danmu_num_before_15s_max-danmu_num_before_15s_min)))+0.5*(0.5*after_15_sim_1+0.5*((danmu_num_after_15s_all-danmu_num_after_15s_min)/(danmu_num_after_15s_max-danmu_num_after_15s_min)))) as k_2_15s_sim_q_3_num
from (
select t2.user_id,t2.sound_id,t2.drama_id,
0.5*(case when danmu_num_before_8s>=danmu_num_after_8s then danmu_num_before_8s else danmu_num_after_8s end)+0.5*((sum_before_8s+sum_after_8s)/(danmu_num_before_8s+danmu_num_after_8s)) as all_8_sim_1,
0.5*(case when danmu_num_before_15s_all>=danmu_num_after_15s_all then danmu_num_before_15s_all else danmu_num_after_15s_all end)+0.5*((sum_before_15s_all+sum_after_15s_all)/(danmu_num_before_15s_all+danmu_num_after_15s_all)) as all_15_sim_1,
0.5*max_before_8s+0.5*(sum_before_8s/danmu_num_before_8s) as before_8_sim_1, 
0.5*max_after_8s+0.5*(sum_after_8s/danmu_num_after_8s) as after_8_sim_1, 
0.5*max_before_15s_all+0.5*(sum_before_15s_all/danmu_num_before_15s_all) as before_15_sim_1, 
0.5*max_after_15s_all+0.5*(sum_after_15s_all/danmu_num_after_15s_all) as after_15_sim_1, 
danmu_num_before_8s,danmu_num_after_8s,danmu_num_before_15s_all,danmu_num_after_15s_all,
danmu_num_before_8s_max,danmu_num_before_8s_min,danmu_num_after_8s_max,danmu_num_after_8s_min,
danmu_num_before_15s_max,danmu_num_before_15s_min,danmu_num_after_15s_max,danmu_num_after_15s_min
from (
select t3.*,t4.drama_id,t4.danmu_info_date,
(t3.sum_before_8s+t3.sum_before_15s)as sum_before_15s_all,
(t3.sum_after_8s+t3.sum_after_15s)as sum_after_15s_all,
(case when t3.max_before_8s>=t3.max_before_15s then t3.max_before_8s else t3.max_before_15s end) as max_before_15s_all,
(case when t3.max_after_8s>=t3.max_after_15s then t3.max_after_8s else t3.max_after_15s end) as max_after_15s_all,
(t3.danmu_num_before_8s+t3.danmu_num_before_15s)as danmu_num_before_15s_all,
(t3.danmu_num_after_8s+t3.danmu_num_after_15s)as danmu_num_after_15s_all
from danmu_involved_activeuser_202211_202303_allinfo t3 
join activeuser_submit_danmu_sound_with_drama_202211_202303 t4 on t3.danmu_id=t4.danmu_id
where danmu_info_date>='2023-01-01' and danmu_info_date<='2023-01-31') as t2
left join (
select max(danmu_num_before_8s) as danmu_num_before_8s_max,
min(danmu_num_before_8s) as danmu_num_before_8s_min,
max(danmu_num_after_8s) as danmu_num_after_8s_max,
min(danmu_num_after_8s) as danmu_num_after_8s_min,
max(danmu_num_before_8s+danmu_num_before_15s) as danmu_num_before_15s_max,
min(danmu_num_before_8s+danmu_num_before_15s) as danmu_num_before_15s_min,
max(danmu_num_after_8s+danmu_num_after_15s) as danmu_num_after_15s_max,
min(danmu_num_after_8s+danmu_num_after_15s) as danmu_num_after_15s_min
from danmu_involved_activeuser_202211_202303_allinfo
) as t6 on 1=1
) as t1
group by t1.user_id,t1.sound_id

-- 得到弹幕契合度之后根据之前的表生成新数据集
create table 0101_0131_all_feature_involved_test as 
select t1.user_id,t1.sound_id as sound_id_id,t1.drama_id,
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
-- t4.user_submit_danmu_drama_completed_num_all,
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
t4.user_submit_danmu_sound_total_view_num,
t4.user_submit_danmu_sound_max_view_num,
t4.user_submit_danmu_sound_min_view_num,
t4.user_submit_danmu_sound_avg_view_num,
t4.user_submit_danmu_sound_total_danmu_num,
t4.user_submit_danmu_sound_max_danmu_num,
t4.user_submit_danmu_sound_min_danmu_num,
t4.user_submit_danmu_sound_avg_danmu_num,
t4.user_submit_danmu_sound_total_review_num,
t4.user_submit_danmu_sound_max_review_num,
t4.user_submit_danmu_sound_min_review_num,
t4.user_submit_danmu_sound_avg_review_num,
-- t4.user_has_in_drama_fans_reward_num,
-- t4.user_has_in_drama_fans_reward_total_money,
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
t2.user_in_drama_total_review_num,
t2.user_in_drama_total_danmu_num,

t3.sound_title_len,
t3.sound_intro_len,
t3.sound_tag_num,
-- t3.sound_pay_type,
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
t3.sound_view_num_in_total_darma_percent,
t3.sound_danmu_num_in_total_darma_percent,
t3.sound_favorite_num_in_total_darma_percent,
t3.sound_point_num_in_total_darma_percent,
t3.sound_review_num_in_total_darma_percent,
t3.sound_not_subreview_num_in_total_darma_percent,
t3.sound_subreview_num_in_total_darma_percent,
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
-- t5.drama_pay_type,
-- t5.drama_total_pay_money,
-- t5.drama_pay_sound_percent,
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
t5.drama_total_danmu_num,
t5.drama_max_danmu_num,
t5.drama_min_danmu_num,
t5.drama_avg_danmu_num,
t5.drama_total_favorite_num,
t5.drama_max_favorite_num,
t5.drama_min_favorite_num,
t5.drama_avg_favorite_num,
t5.drama_total_point_num,
t5.drama_max_point_num,
t5.drama_min_point_num,
t5.drama_avg_point_num,
t5.drama_total_review_num,
t5.drama_max_review_num,
t5.drama_min_review_num,
t5.drama_avg_review_num,
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
-- t5.drama_upuser_submit_drama_has_reward_week_ranking,
-- t5.drama_upuser_submit_drama_has_reward_month_ranking,
-- t5.drama_upuser_submit_drama_has_reward_total_ranking,
-- t5.drama_upuser_submit_drama_reward_week_max_rank,
-- t5.drama_upuser_submit_drama_reward_month_max_rank,
-- t5.drama_upuser_submit_drama_reward_total_max_rank,
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

t6.*,
t2.user_in_drama_is_pay_for_drama_in_next_time,
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
t1.k_2_15s_sim_q_3_num

-- from final_active_userandsoun_list t1   -- 这是筛过活跃声音的allfeature基础
-- from final_active_userandsound_involved_list t1 -- 这是基于所有契合度的allfeature基础
from 0101_0131_danmu_involved t1
left join 0101_0131_user_sound_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 
left join 0101_0131_sound_feature t3 on t1.sound_id=t3.sound_id
left join 0101_0131_user_feature  t4 on t1.user_id=t4.user_id
left join 0101_0131_drama_feature t5 on t1.drama_id=t5.drama_id
left join maoer_data_analysis.feat_sound_opensmile384_new t6 on t1.sound_id=t6.sound_id
where t2.user_in_drama_sound_pay_type=1; # 付费




-- update final_active_userandsound_involved_list t1 join (
-- select t3.user_id,t3.sound_id,avg(sim_1) as sim_1,max(sim_max) as sim_max,min(sim_min) as sim_min,avg(sim_avg) as sim_avg
-- from 
-- (select * from danmu_involved_activeuser_202211_202303 group by user_id,sound_id) t3
-- join (select danmu_id,danmu_info_date from activeuser_submit_danmu_sound_with_drama_202211_202303 where danmu_info_date>='2023-01-01' and danmu_info_date<='2023-01-31') t4 on t3.danmu_id=t4.danmu_id
-- group by t3.user_id,t3.sound_id
-- ) t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 
-- set
-- t1.0101_0131_sim_1 = t2.sim_1,
-- t1.0101_0131_sim_max = t2.sim_max,
-- t1.0101_0131_sim_min = t2.sim_min,
-- t1.0101_0131_sim_avg = t2.sim_avg

-- 检查
-- select t1.user_id,t1.sound_id from 0101_0131_user_sound_feature t1 join (select user_id,sound_id from danmu_involved_activeuser_202211_202303 group by user_id,sound_id) t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 

-- select t1.user_id,t1.sound_id from 0101_0131_user_sound_feature t1 join final_active_userandsound_involved_list t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 


-- select count(1) from 0101_0131_user_sound_feature t1 join 0101_0115_all_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id
-- select count(1) from 0101_0115_all_feature
-- select avg(drama_reward_max_week_rank is null) ,avg(drama_fans_reward_total_fans_num is null)from 0116_0131_drama_feature

-- insert into final_active_userandsound_involved_list(user_id,sound_id,drama_id)
-- select t4.user_id,t4.sound_id,t4.drama_id
-- from final_active_userandsound_involved_list t3 right join (
-- select t1.user_id,t1.sound_id,t2.drama_id -- ,sim_1,sim_max,sim_min,sim_avg
-- from 
-- (select * from danmu_involved_activeuser_202211_202303 group by user_id,sound_id) t1
-- left join (select sound_id,drama_id from activeuser_submit_danmu_sound_with_drama_202211_202303 group by sound_id)t2 on t1.sound_id=t2.sound_id) t4 on t3.user_id=t4.user_id and t3.sound_id=t4.sound_id
-- where t3.user_id is null and t3.sound_id is null

-- 时间窗逻辑 2022.11-2023.3用一个月信息预测半个月信息
-- 窗口1: 11月-12月     1101_1130 预测 12月  - 12.5月  1201_1215
-- 窗口2: 11.5月-12.5月 1115_1215 预测 12.5月- 1月     1216_1231
-- 窗口3: 12月-1月      1201_1231 预测 1月   - 1.5月   0101_0115
-- 窗口4: 12.5月-1.5月  1215_0115 预测 1.5月 - 2月     0116_0131
-- 窗口5: 1月-2月       0101_0131 预测 2月   - 2.5月   0201_0215
-- 窗口6: 1.5月-2.5月   0115_0215 预测 2.5月 - 3月     0216_0230
-- 窗口7: 2月-3月       0201_0230 预测 3月   - 3.5月   0301_0315
-- sound天数差值 11.30(7) 12.15(22) 12.31(38) 01.15(53) 01.31(69) 02.15(84) 02.28(97) 03.15(112) 

-- show processlist
-- -- kill 448
-- FLUSH TABLES WITH READ LOCK;
-- UNLOCK TABLES;
-- SHOW ENGINE INNODB STATUS
-- 
-- show variables like "%_buffer%";
-- SET GLOBAL innodb_buffer_pool_size=1073741824
-- 
-- 生成新的弹幕契合度表 这里计算有很多新的值
-- 1.更新新的user_in_drama_is_pay_for_drama_in_next_time
-- 2.生成0101_0131_danmu_involved新表  3.关联旧表生成新的输出表

-- 0101_0131 还没重跑！！！！！！！！！！！！ 


update 0101_0131_user_sound_feature t1 join(
select t3.user_id,t3.drama_id,t3.drama_info_pay_type,sum(case when t4.user_in_drama_sound_pay_type=2 then 1 else 0 end) as user_in_drama_is_pay_for_drama
from 0101_0131_user_sound_feature t3
left join (
select user_id,drama_id,user_in_drama_sound_pay_type from 0101_0131_user_sound_feature union
select user_id,drama_id,user_in_drama_sound_pay_type from 0201_0215_user_sound_feature) t4 on t3.user_id=t4.user_id and t3.drama_id=t4.drama_id
group by t3.user_id,t3.drama_id
)t2 on t1.user_id=t2.user_id and t1.drama_id=t2.drama_id
set
t1.user_in_drama_is_pay_for_drama_in_next_time =(case when t2.drama_info_pay_type=0 then 0 when t2.drama_info_pay_type=1 and t2.user_in_drama_is_pay_for_drama>=1 then 1 when t2.drama_info_pay_type=2 and t2.user_in_drama_is_pay_for_drama>=1 then 1 else 2 end );

-- k*(q*当前弹幕前8s的契合度+(1-q)*当前归一化后前8s弹幕数量)+(1-k)*(q*当前弹幕后8s的契合度+(1-q)*当前归一化后后8s弹幕数量) 
-- k_1/2/3表示k=0.3,0.5,0.7,q_1/2/3表示q=0.3,0.5,0.7
create table 0101_0131_danmu_involved
select t1.user_id,t1.sound_id,t1.drama_id,
      avg(all_8_sim_1) as all_8_sim,
      avg(all_15_sim_1)as all_15_sim,
      avg(0.3*before_8_sim_1+0.7*after_8_sim_1) as k_1_8s_sim,
      avg(0.5*before_8_sim_1+0.5*after_8_sim_1) as k_2_8s_sim,
      avg(0.7*before_8_sim_1+0.3*after_8_sim_1) as k_3_8s_sim,
      avg(0.3*before_15_sim_1+0.7*after_15_sim_1) as k_1_15s_sim,
      avg(0.5*before_15_sim_1+0.5*after_15_sim_1) as k_2_15s_sim,
      avg(0.7*before_15_sim_1+0.3*after_15_sim_1) as k_3_15s_sim,
      avg(0.5*(0.3*before_8_sim_1+0.7*((danmu_num_before_8s-danmu_num_before_8s_min)/(danmu_num_before_8s_max-danmu_num_before_8s_min)))+0.5*(0.3*after_8_sim_1+0.7*((danmu_num_after_8s-danmu_num_after_8s_min)/(danmu_num_after_8s_max-danmu_num_after_8s_min)))) as k_2_8s_sim_q_1_num,
      avg(0.5*(0.5*before_8_sim_1+0.5*((danmu_num_before_8s-danmu_num_before_8s_min)/(danmu_num_before_8s_max-danmu_num_before_8s_min)))+0.5*(0.5*after_8_sim_1+0.5*((danmu_num_after_8s-danmu_num_after_8s_min)/(danmu_num_after_8s_max-danmu_num_after_8s_min)))) as k_2_8s_sim_q_2_num,
      avg(0.5*(0.7*before_8_sim_1+0.3*((danmu_num_before_8s-danmu_num_before_8s_min)/(danmu_num_before_8s_max-danmu_num_before_8s_min)))+0.5*(0.7*after_8_sim_1+0.3*((danmu_num_after_8s-danmu_num_after_8s_min)/(danmu_num_after_8s_max-danmu_num_after_8s_min)))) as k_2_8s_sim_q_3_num,
      avg(0.5*(0.3*before_15_sim_1+0.7*((danmu_num_before_15s_all-danmu_num_before_15s_min)/(danmu_num_before_15s_max-danmu_num_before_15s_min)))+0.5*(0.3*after_15_sim_1+0.7*((danmu_num_after_15s_all-danmu_num_after_15s_min)/(danmu_num_after_15s_max-danmu_num_after_15s_min)))) as k_2_15s_sim_q_1_num,
      avg(0.5*(0.5*before_15_sim_1+0.5*((danmu_num_before_15s_all-danmu_num_before_15s_min)/(danmu_num_before_15s_max-danmu_num_before_15s_min)))+0.5*(0.5*after_15_sim_1+0.5*((danmu_num_after_15s_all-danmu_num_after_15s_min)/(danmu_num_after_15s_max-danmu_num_after_15s_min)))) as k_2_15s_sim_q_2_num,
      avg(0.5*(0.5*before_15_sim_1+0.5*((danmu_num_before_15s_all-danmu_num_before_15s_min)/(danmu_num_before_15s_max-danmu_num_before_15s_min)))+0.5*(0.5*after_15_sim_1+0.5*((danmu_num_after_15s_all-danmu_num_after_15s_min)/(danmu_num_after_15s_max-danmu_num_after_15s_min)))) as k_2_15s_sim_q_3_num
from (
select t2.user_id,t2.sound_id,t2.drama_id,
    0.5*(case when danmu_num_before_8s>=danmu_num_after_8s then danmu_num_before_8s else danmu_num_after_8s end)+0.5*((sum_before_8s+sum_after_8s)/(danmu_num_before_8s+danmu_num_after_8s)) as all_8_sim_1,
    0.5*(case when danmu_num_before_15s_all>=danmu_num_after_15s_all then danmu_num_before_15s_all else danmu_num_after_15s_all end)+0.5*((sum_before_15s_all+sum_after_15s_all)/(danmu_num_before_15s_all+danmu_num_after_15s_all)) as all_15_sim_1,
    0.5*max_before_8s+0.5*(sum_before_8s/danmu_num_before_8s) as before_8_sim_1, 
    0.5*max_after_8s+0.5*(sum_after_8s/danmu_num_after_8s) as after_8_sim_1, 
    0.5*max_before_15s_all+0.5*(sum_before_15s_all/danmu_num_before_15s_all) as before_15_sim_1, 
    0.5*max_after_15s_all+0.5*(sum_after_15s_all/danmu_num_after_15s_all) as after_15_sim_1, 
    danmu_num_before_8s,danmu_num_after_8s,danmu_num_before_15s_all,danmu_num_after_15s_all,
    danmu_num_before_8s_max,danmu_num_before_8s_min,danmu_num_after_8s_max,danmu_num_after_8s_min,
    danmu_num_before_15s_max,danmu_num_before_15s_min,danmu_num_after_15s_max,danmu_num_after_15s_min
from (
  select t3.*,t4.drama_id,t4.danmu_info_date,
      (t3.sum_before_8s+t3.sum_before_15s)as sum_before_15s_all,
      (t3.sum_after_8s+t3.sum_after_15s)as sum_after_15s_all,
      (case when t3.max_before_8s>=t3.max_before_15s then t3.max_before_8s else t3.max_before_15s end) as max_before_15s_all,
      (case when t3.max_after_8s>=t3.max_after_15s then t3.max_after_8s else t3.max_after_15s end) as max_after_15s_all,
      (t3.danmu_num_before_8s+t3.danmu_num_before_15s)as danmu_num_before_15s_all,
      (t3.danmu_num_after_8s+t3.danmu_num_after_15s)as danmu_num_after_15s_all
  from danmu_involved_activeuser_202211_202303_allinfo t3 
  join activeuser_submit_danmu_sound_with_drama_202211_202303 t4 
  on t3.danmu_id=t4.danmu_id
  where danmu_info_date>='2023-01-01' and danmu_info_date<='2023-01-31') as t2
  left join (
  select max(danmu_num_before_8s) as danmu_num_before_8s_max,
        min(danmu_num_before_8s) as danmu_num_before_8s_min,
        max(danmu_num_after_8s) as danmu_num_after_8s_max,
        min(danmu_num_after_8s) as danmu_num_after_8s_min,
        max(danmu_num_before_8s+danmu_num_before_15s) as danmu_num_before_15s_max,
        min(danmu_num_before_8s+danmu_num_before_15s) as danmu_num_before_15s_min,
        max(danmu_num_after_8s+danmu_num_after_15s) as danmu_num_after_15s_max,
        min(danmu_num_after_8s+danmu_num_after_15s) as danmu_num_after_15s_min
  from danmu_involved_activeuser_202211_202303_allinfo
) as t6 on 1=1
) as t1
group by t1.user_id,t1.sound_id;

-- 得到弹幕契合度之后根据之前的表生成新数据集
create table 0101_0131_all_feature_involved_new as 
select t1.user_id,t1.sound_id as sound_id_id,t1.drama_id,
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
-- t4.user_submit_danmu_drama_completed_num_all,
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
t4.user_submit_danmu_sound_total_view_num,
t4.user_submit_danmu_sound_max_view_num,
t4.user_submit_danmu_sound_min_view_num,
t4.user_submit_danmu_sound_avg_view_num,
t4.user_submit_danmu_sound_total_danmu_num,
t4.user_submit_danmu_sound_max_danmu_num,
t4.user_submit_danmu_sound_min_danmu_num,
t4.user_submit_danmu_sound_avg_danmu_num,
t4.user_submit_danmu_sound_total_review_num,
t4.user_submit_danmu_sound_max_review_num,
t4.user_submit_danmu_sound_min_review_num,
t4.user_submit_danmu_sound_avg_review_num,
-- t4.user_has_in_drama_fans_reward_num,
-- t4.user_has_in_drama_fans_reward_total_money,
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
t2.user_in_drama_total_review_num,
t2.user_in_drama_total_danmu_num,

t3.sound_title_len,
t3.sound_intro_len,
t3.sound_tag_num,
-- t3.sound_pay_type,
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
t3.sound_view_num_in_total_darma_percent,
t3.sound_danmu_num_in_total_darma_percent,
t3.sound_favorite_num_in_total_darma_percent,
t3.sound_point_num_in_total_darma_percent,
t3.sound_review_num_in_total_darma_percent,
t3.sound_not_subreview_num_in_total_darma_percent,
t3.sound_subreview_num_in_total_darma_percent,
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
-- t5.drama_pay_type,
-- t5.drama_total_pay_money,
-- t5.drama_pay_sound_percent,
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
t5.drama_total_danmu_num,
t5.drama_max_danmu_num,
t5.drama_min_danmu_num,
t5.drama_avg_danmu_num,
t5.drama_total_favorite_num,
t5.drama_max_favorite_num,
t5.drama_min_favorite_num,
t5.drama_avg_favorite_num,
t5.drama_total_point_num,
t5.drama_max_point_num,
t5.drama_min_point_num,
t5.drama_avg_point_num,
t5.drama_total_review_num,
t5.drama_max_review_num,
t5.drama_min_review_num,
t5.drama_avg_review_num,
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
-- t5.drama_upuser_submit_drama_has_reward_week_ranking,
-- t5.drama_upuser_submit_drama_has_reward_month_ranking,
-- t5.drama_upuser_submit_drama_has_reward_total_ranking,
-- t5.drama_upuser_submit_drama_reward_week_max_rank,
-- t5.drama_upuser_submit_drama_reward_month_max_rank,
-- t5.drama_upuser_submit_drama_reward_total_max_rank,
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

-- from final_active_userandsoun_list t1   -- 这是筛过活跃声音的allfeature基础
-- from final_active_userandsound_involved_list t1 -- 这是基于所有契合度的allfeature基础
from 0101_0131_danmu_involved t1
left join 0101_0131_user_sound_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 
left join 0101_0131_sound_feature t3 on t1.sound_id=t3.sound_id
left join 0101_0131_user_feature  t4 on t1.user_id=t4.user_id
left join 0101_0131_drama_feature t5 on t1.drama_id=t5.drama_id
left join maoer_data_analysis.feat_sound_opensmile384_new t6 on t1.sound_id=t6.sound_id
left join active_drama_gpt_final_result t7 on t1.drama_id=t7.drama_id
where t2.user_in_drama_sound_pay_type=1; # 付费


-- -- 生成用户消费预测数据集
-- CREATE TEMPORARY TABLE lingshi_user_table as
-- select user_id,count(1) as num
-- from (
-- select user_id,user_in_drama_is_pay_for_drama_in_next_time,user_in_drama_sound_pay_type
-- from 0115_0215_user_sound_feature
-- where user_in_drama_sound_pay_type=1
-- group by user_id,user_in_drama_is_pay_for_drama_in_next_time,user_in_drama_sound_pay_type
-- ) t
-- group by user_id
-- having num>1

-- 旧 弃用
-- create table 0101_0131_user_pay_pred_feature
-- select t1.user_id,t1.sound_id,
-- user_name_len, 
-- user_name_has_chinese, 
-- user_intro_len, 
-- user_intro_has_chinese, 
-- user_intro_has_english, 
-- user_fish_num, 
-- user_follower_num, 
-- user_subscribe_drama_num, 
-- user_submit_danmu_drama_completed_num_now, 
-- user_submit_danmu_drama_total_view_num, 
-- user_submit_danmu_drama_max_view_num, 
-- user_submit_danmu_drama_avg_view_num, 
-- user_submit_danmu_drama_total_danmu_num, 
-- user_submit_danmu_drama_max_danmu_num, 
-- user_submit_danmu_drama_min_danmu_num, 
-- user_submit_danmu_drama_avg_danmu_num, 
-- user_submit_danmu_drama_min_review_num, 
-- user_in_sound_submit_danmu_max_len, 
-- user_in_sound_submit_danmu_min_len, 
-- user_in_sound_submit_danmu_avg_len, 
-- user_in_sound_danmu_around_15s_total_danmu_max_num, 
-- user_in_sound_danmu_around_15s_total_danmu_min_num, 
-- user_in_sound_danmu_around_15s_total_danmu_avg_num, 
-- sound_title_len, sound_intro_len, 
-- sound_danmu_15s_max_traffic_position_in_sound, 
-- drama_upuser_submit_sound_avg_danmu_num, 
-- t6.`pcm_fftMag_mfcc_sma[5]_maxPos numeric`, 
-- t6.`pcm_fftMag_mfcc_sma_de[10]_minPos numeric`,
-- user_name_has_english, user_in_sound_is_submit_review, user_in_sound_submit_review_num,
--  user_in_sound_submit_danmu_total_len, sound_view_num, sound_danmu_num, sound_review_avg_len,
--  drama_total_sound_num, drama_sound_has_max_cv_num_sound_point_num,
--  drama_upuser_submit_sound_max_view_num, drama_sound_min_time_sound_view_num,
--  drama_danmu_time_between_sound_time_in_7days_num_min, `pcm_RMSenergy_sma_range numeric`,  `pcm_fftMag_mfcc_sma[1]_maxPos numeric`, `pcm_fftMag_mfcc_sma[2]_max numeric`,  `pcm_fftMag_mfcc_sma[5]_min numeric`, `pcm_fftMag_mfcc_sma[8]_maxPos numeric`,
--  `pcm_fftMag_mfcc_sma[10]_max numeric`, `voiceProb_sma_stddev numeric`, `F0_sma_stddev numeric`,  `pcm_fftMag_mfcc_sma_de[4]_min numeric`, `pcm_fftMag_mfcc_sma_de[6]_maxPos numeric`,
--  `pcm_fftMag_mfcc_sma_de[8]_kurtosis numeric`,
--  `pcm_fftMag_mfcc_sma_de[9]_min numeric`, `pcm_fftMag_mfcc_sma_de[10]_linregc1 numeric`,
--  user_submit_danmu_drama_min_view_num, user_submit_danmu_drama_max_review_num,
--  user_submit_danmu_drama_avg_review_num, drama_intro_len,
--  drama_sound_has_min_view_num_sound_favorite_num, drama_upuser_subscriptions_num,
--  drama_sound_max_time_sound_view_num, drama_sound_max_traffic_position_in_sound_avg,
--  drama_sound_min_traffic_position_in_sound_avg, label1, `pcm_fftMag_mfcc_sma[1]_range numeric`,
--  `pcm_fftMag_mfcc_sma[1]_minPos numeric`, `pcm_fftMag_mfcc_sma[2]_min numeric`,
--  `pcm_fftMag_mfcc_sma[2]_skewness numeric`, `pcm_fftMag_mfcc_sma[5]_range numeric`,
--  `pcm_fftMag_mfcc_sma[6]_linregc1 numeric`, `pcm_fftMag_mfcc_sma[11]_kurtosis numeric`,
--  `pcm_RMSenergy_sma_de_minPos numeric`, `pcm_fftMag_mfcc_sma_de[2]_max numeric`,
--  `pcm_fftMag_mfcc_sma_de[4]_stddev numeric`, `pcm_fftMag_mfcc_sma_de[4]_skewness numeric`,
--  `pcm_fftMag_mfcc_sma_de[5]_linregc1 numeric`, `pcm_fftMag_mfcc_sma_de[8]_amean numeric`,
--  `pcm_fftMag_mfcc_sma_de[8]_skewness numeric`, `pcm_fftMag_mfcc_sma_de[9]_max numeric`,
--  `pcm_fftMag_mfcc_sma_de[10]_linregerrQ numeric`, `pcm_fftMag_mfcc_sma_de[11]_maxPos numeric`,
--  `voiceProb_sma_de_max numeric`, `F0_sma_de_linregerrQ numeric`,
-- 
-- t1.max_date,
-- t2.user_in_drama_is_pay_for_drama_in_next_time
-- from 
-- (
-- select a.user_id,b.sound_id,b.drama_id,max(b.danmu_info_date) as max_date
-- from lingshi_user_table a left join 
-- activeuser_submit_danmu_sound_with_drama_202211_202303 b on a.user_id=b.user_id 
-- where danmu_info_date>='2023-01-01' and danmu_info_date<='2023-01-31'
-- group by a.user_id,b.sound_id,b.drama_id
-- ) t1 
-- left join 0101_0131_user_sound_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 
-- left join 0101_0131_sound_feature t3 on t1.sound_id=t3.sound_id
-- left join 0101_0131_user_feature  t4 on t1.user_id=t4.user_id
-- left join 0101_0131_drama_feature t5 on t1.drama_id=t5.drama_id
-- left join maoer_data_analysis.feat_sound_opensmile384_new t6 on t1.sound_id=t6.sound_id
-- left join active_drama_gpt_final_result t7 on t1.drama_id=t7.drama_id
-- where t2.user_in_drama_sound_pay_type=1 # 付费 
-- order by t1.user_id,t1.max_date


-- 生成用户消费预测数据集
CREATE TEMPORARY TABLE 1215_0115_lingshi_user_table as
select user_id,count(1) as num
from (
select user_id,user_in_drama_is_pay_for_drama_in_next_time,user_in_drama_sound_pay_type
from 1215_0115_user_sound_feature
where user_in_drama_sound_pay_type=1
group by user_id,user_in_drama_is_pay_for_drama_in_next_time,user_in_drama_sound_pay_type
) t
group by user_id
having num>1;

create table 1215_0115_user_pay_pred_feature
select t1.user_id,t1.sound_id as sound_id_id,t1.drama_id,
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
-- t4.user_submit_danmu_drama_completed_num_all,
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
t4.user_submit_danmu_sound_total_view_num,
t4.user_submit_danmu_sound_max_view_num,
t4.user_submit_danmu_sound_min_view_num,
t4.user_submit_danmu_sound_avg_view_num,
t4.user_submit_danmu_sound_total_danmu_num,
t4.user_submit_danmu_sound_max_danmu_num,
t4.user_submit_danmu_sound_min_danmu_num,
t4.user_submit_danmu_sound_avg_danmu_num,
t4.user_submit_danmu_sound_total_review_num,
t4.user_submit_danmu_sound_max_review_num,
t4.user_submit_danmu_sound_min_review_num,
t4.user_submit_danmu_sound_avg_review_num,
-- t4.user_has_in_drama_fans_reward_num,
-- t4.user_has_in_drama_fans_reward_total_money,
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
t2.user_in_drama_total_review_num,
t2.user_in_drama_total_danmu_num,

t3.sound_title_len,
t3.sound_intro_len,
t3.sound_tag_num,
-- t3.sound_pay_type,
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
t3.sound_view_num_in_total_darma_percent,
t3.sound_danmu_num_in_total_darma_percent,
t3.sound_favorite_num_in_total_darma_percent,
t3.sound_point_num_in_total_darma_percent,
t3.sound_review_num_in_total_darma_percent,
t3.sound_not_subreview_num_in_total_darma_percent,
t3.sound_subreview_num_in_total_darma_percent,
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
-- t5.drama_pay_type,
-- t5.drama_total_pay_money,
-- t5.drama_pay_sound_percent,
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
t5.drama_total_danmu_num,
t5.drama_max_danmu_num,
t5.drama_min_danmu_num,
t5.drama_avg_danmu_num,
t5.drama_total_favorite_num,
t5.drama_max_favorite_num,
t5.drama_min_favorite_num,
t5.drama_avg_favorite_num,
t5.drama_total_point_num,
t5.drama_max_point_num,
t5.drama_min_point_num,
t5.drama_avg_point_num,
t5.drama_total_review_num,
t5.drama_max_review_num,
t5.drama_min_review_num,
t5.drama_avg_review_num,
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
-- t5.drama_upuser_submit_drama_has_reward_week_ranking,
-- t5.drama_upuser_submit_drama_has_reward_month_ranking,
-- t5.drama_upuser_submit_drama_has_reward_total_ranking,
-- t5.drama_upuser_submit_drama_reward_week_max_rank,
-- t5.drama_upuser_submit_drama_reward_month_max_rank,
-- t5.drama_upuser_submit_drama_reward_total_max_rank,
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
t1.max_date,
t2.user_in_drama_is_pay_for_drama_in_next_time
from 
(
select a.user_id,b.sound_id,b.drama_id,max(b.danmu_info_date) as max_date
from 1215_0115_lingshi_user_table a left join 
activeuser_submit_danmu_sound_with_drama_202211_202303 b on a.user_id=b.user_id 
where danmu_info_date>='2022-12-15' and danmu_info_date<='2023-01-15'
group by a.user_id,b.sound_id,b.drama_id
) t1 
left join 1215_0115_user_sound_feature t2 on t1.user_id=t2.user_id and t1.sound_id=t2.sound_id 
left join 1215_0115_sound_feature t3 on t1.sound_id=t3.sound_id
left join 1215_0115_user_feature  t4 on t1.user_id=t4.user_id
left join 1215_0115_drama_feature t5 on t1.drama_id=t5.drama_id
left join maoer_data_analysis.feat_sound_opensmile384_new t6 on t1.sound_id=t6.sound_id
left join active_drama_gpt_final_result t7 on t1.drama_id=t7.drama_id
where t2.user_in_drama_sound_pay_type=1 # 付费 
order by t1.user_id,t1.max_date;


# 查看有多少既有付费又有非付费的用户数量
select count(1)
from (
select user_id,count(1) as num
from (
select user_id,user_in_drama_is_pay_for_drama_in_next_time
from 0101_0131_user_pay_pred_feature
group by user_id,user_in_drama_is_pay_for_drama_in_next_time
) t
group by user_id
having num>1) k

select count(1)
from 0101_0131_user_pay_pred_feature


select count(1)
from (
select user_id,count(1) as num
from (
select user_id,user_in_drama_is_pay_for_drama_in_next_time
from 0101_0131_user_sound_feature
group by user_id,user_in_drama_is_pay_for_drama_in_next_time
) t
group by user_id
having num>1) k


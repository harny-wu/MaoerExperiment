/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 50722
 Source Host           : localhost:3306
 Source Schema         : maoer_data_analysis

 Target Server Type    : MySQL
 Target Server Version : 50722
 File Encoding         : 65001

 Date: 16/07/2024 00:10:40
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for active_sound_exceed_avg
-- ----------------------------
DROP TABLE IF EXISTS `active_sound_exceed_avg`;
CREATE TABLE `active_sound_exceed_avg`  (
  `sound_id` int(11) NOT NULL,
  `sound_info_view_count` int(11) NULL DEFAULT NULL COMMENT '声音播放量',
  `sound_info_danmu_count` int(11) NULL DEFAULT NULL COMMENT '弹幕数量;（comment_count）',
  `sound_info_favorite_count` int(11) NULL DEFAULT NULL COMMENT '喜欢数量',
  `sound_info_all_reviews_num` int(11) NULL DEFAULT NULL COMMENT '总评论数量;comments_num',
  `sound_info_point` int(11) NULL DEFAULT NULL COMMENT '投食数量',
  `sound_info_pay_type` int(11) NULL DEFAULT NULL COMMENT '付费类型 0:不付费，1：单集付费，2:全集付费',
  `drama_info_price` int(11) NULL DEFAULT NULL COMMENT '剧集价格',
  `sound_info_created_time` datetime(0) NULL DEFAULT NULL COMMENT '声音创建时间',
  `created_time` datetime(0) NOT NULL COMMENT '记录时间',
  INDEX `sound`(`sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for active_sound_with_activeuser2022
-- ----------------------------
DROP TABLE IF EXISTS `active_sound_with_activeuser2022`;
CREATE TABLE `active_sound_with_activeuser2022`  (
  `sound_id` int(11) NULL DEFAULT NULL,
  `sound_info_view_count` int(11) NULL DEFAULT NULL,
  `sound_info_pay_type` int(11) NULL DEFAULT NULL,
  INDEX `sound_id`(`sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for active_users_audience_delete_zimu_users
-- ----------------------------
DROP TABLE IF EXISTS `active_users_audience_delete_zimu_users`;
CREATE TABLE `active_users_audience_delete_zimu_users`  (
  `user_id` int(11) NULL DEFAULT NULL,
  `user_info_grade` int(11) NULL DEFAULT NULL,
  `user_info_fish_num` int(11) NULL DEFAULT NULL,
  `user_info_follower_num` int(11) NULL DEFAULT NULL,
  `user_info_fans_num` int(11) NULL DEFAULT NULL,
  `user_info_sound_num` int(11) NULL DEFAULT NULL,
  `user_info_drama_num` int(11) NULL DEFAULT NULL,
  `user_info_subscriptions_num` int(11) NULL DEFAULT NULL,
  `user_info_channel` int(11) NULL DEFAULT NULL,
  `comment_count` int(11) NULL DEFAULT NULL,
  `danmu_count` int(11) NULL DEFAULT NULL,
  `sound_pay` double(11, 2) NULL DEFAULT NULL,
  `fans_reward` int(11) NULL DEFAULT NULL,
  INDEX `user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for activeuser_havedanmu_sound
-- ----------------------------
DROP TABLE IF EXISTS `activeuser_havedanmu_sound`;
CREATE TABLE `activeuser_havedanmu_sound`  (
  `sound_id` int(11) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for activeuser_info
-- ----------------------------
DROP TABLE IF EXISTS `activeuser_info`;
CREATE TABLE `activeuser_info`  (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_intro` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_icon_2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_icon_top` int(11) NULL DEFAULT NULL,
  `user_info_grade` int(11) NULL DEFAULT NULL,
  `user_info_fish_num` int(11) NULL DEFAULT NULL,
  `user_info_follower_num` int(11) NULL DEFAULT NULL,
  `user_info_fans_num` int(11) NULL DEFAULT NULL,
  `organization_id` int(11) NULL DEFAULT NULL,
  `user_info_sound_num` int(11) NULL DEFAULT NULL,
  `user_info_drama_num` int(11) NULL DEFAULT NULL,
  `user_info_subscriptions_num` int(11) NULL DEFAULT NULL,
  `user_info_channel` int(11) NULL DEFAULT NULL,
  `user_info_album_num` int(11) NULL DEFAULT NULL,
  `user_info_image_num` int(11) NULL DEFAULT NULL,
  `created_time` datetime(0) NOT NULL,
  PRIMARY KEY (`user_id`, `created_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for activeuser_submit_danmu_sound_with_drama
-- ----------------------------
DROP TABLE IF EXISTS `activeuser_submit_danmu_sound_with_drama`;
CREATE TABLE `activeuser_submit_danmu_sound_with_drama`  (
  `user_id` int(11) NOT NULL,
  `sound_id` int(11) NOT NULL,
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  INDEX `sound`(`sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for activeuser_with_danmu_sound
-- ----------------------------
DROP TABLE IF EXISTS `activeuser_with_danmu_sound`;
CREATE TABLE `activeuser_with_danmu_sound`  (
  `user_id` int(11) NOT NULL,
  `sound_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`, `sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for danmu_info_202211_202303
-- ----------------------------
DROP TABLE IF EXISTS `danmu_info_202211_202303`;
CREATE TABLE `danmu_info_202211_202303`  (
  `danmu_id` int(11) NOT NULL COMMENT '弹幕id',
  `sound_id` int(11) NOT NULL COMMENT '声音id',
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `danmu_info_stime_notransform` decimal(24, 6) NULL DEFAULT NULL COMMENT '弹幕音频时间（未定）',
  `danmu_info_time_insound` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '弹幕音频时间位置;弹幕在列表中显示的音频所在时间',
  `danmu_info_date_notransform` int(11) NULL DEFAULT NULL COMMENT '弹幕日期（代码中未确定日期转换前）',
  `danmu_info_date` datetime(0) NULL DEFAULT NULL COMMENT '弹幕日期;弹幕在列表中显示的日期',
  `danmu_info_size` int(11) NULL DEFAULT NULL COMMENT '弹幕大小',
  `danmu_info_color` int(11) NULL DEFAULT NULL COMMENT '弹幕颜色',
  `danmu_info_class` int(11) NULL DEFAULT NULL COMMENT '（未定）',
  `danmu_info_text` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '弹幕内容',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '记录时间',
  INDEX `danmu_id`(`user_id`, `danmu_id`) USING BTREE,
  INDEX `sound_id_danmu_id`(`sound_id`, `danmu_id`) USING BTREE,
  INDEX `sound_id`(`sound_id`, `user_id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  INDEX `danmu_text`(`danmu_id`, `sound_id`, `user_id`, `danmu_info_stime_notransform`) USING BTREE,
  INDEX `activeuser_danmu`(`danmu_id`, `sound_id`, `user_id`, `danmu_info_date`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for danmu_info_202211_202303_copy1
-- ----------------------------
DROP TABLE IF EXISTS `danmu_info_202211_202303_copy1`;
CREATE TABLE `danmu_info_202211_202303_copy1`  (
  `danmu_id` int(11) NOT NULL COMMENT '弹幕id',
  `sound_id` int(11) NOT NULL COMMENT '声音id',
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `danmu_info_stime_notransform` decimal(24, 6) NULL DEFAULT NULL COMMENT '弹幕音频时间（未定）',
  `danmu_info_time_insound` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '弹幕音频时间位置;弹幕在列表中显示的音频所在时间',
  `danmu_info_date_notransform` int(11) NULL DEFAULT NULL COMMENT '弹幕日期（代码中未确定日期转换前）',
  `danmu_info_date` datetime(0) NULL DEFAULT NULL COMMENT '弹幕日期;弹幕在列表中显示的日期',
  `danmu_info_size` int(11) NULL DEFAULT NULL COMMENT '弹幕大小',
  `danmu_info_color` int(11) NULL DEFAULT NULL COMMENT '弹幕颜色',
  `danmu_info_class` int(11) NULL DEFAULT NULL COMMENT '（未定）',
  `danmu_info_text` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '弹幕内容',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '记录时间',
  INDEX `danmu_id`(`user_id`, `danmu_id`) USING BTREE,
  INDEX `sound_id_danmu_id`(`sound_id`, `danmu_id`) USING BTREE,
  INDEX `sound_id`(`sound_id`, `user_id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  INDEX `danmu_text`(`danmu_id`, `sound_id`, `user_id`, `danmu_info_stime_notransform`) USING BTREE,
  INDEX `activeuser_danmu`(`danmu_id`, `sound_id`, `user_id`, `danmu_info_date`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for danmu_info_2023
-- ----------------------------
DROP TABLE IF EXISTS `danmu_info_2023`;
CREATE TABLE `danmu_info_2023`  (
  `danmu_id` int(11) NOT NULL COMMENT '弹幕id',
  `sound_id` int(11) NOT NULL COMMENT '声音id',
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `danmu_info_stime_notransform` decimal(24, 6) NULL DEFAULT NULL COMMENT '弹幕音频时间（未定）',
  `danmu_info_time_insound` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '弹幕音频时间位置;弹幕在列表中显示的音频所在时间',
  `danmu_info_date_notransform` int(11) NULL DEFAULT NULL COMMENT '弹幕日期（代码中未确定日期转换前）',
  `danmu_info_date` datetime(0) NULL DEFAULT NULL COMMENT '弹幕日期;弹幕在列表中显示的日期',
  `danmu_info_size` int(11) NULL DEFAULT NULL COMMENT '弹幕大小',
  `danmu_info_color` int(11) NULL DEFAULT NULL COMMENT '弹幕颜色',
  `danmu_info_class` int(11) NULL DEFAULT NULL COMMENT '（未定）',
  `danmu_info_text` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '弹幕内容',
  `created_time` datetime(0) NOT NULL COMMENT '记录时间',
  INDEX `user_sound_id`(`sound_id`, `user_id`) USING BTREE,
  INDEX `danmu_sound_id`(`danmu_id`, `sound_id`) USING BTREE,
  INDEX `user_id`(`user_id`) USING BTREE,
  INDEX `danmu`(`danmu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for drama_cv_info_feature
-- ----------------------------
DROP TABLE IF EXISTS `drama_cv_info_feature`;
CREATE TABLE `drama_cv_info_feature`  (
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `total_cv_num` bigint(21) NOT NULL DEFAULT 0,
  `cv_has_userid_num` decimal(23, 0) NULL DEFAULT NULL,
  `cv_total_fans_num` decimal(32, 0) NULL DEFAULT NULL,
  `cv_max_fans_num` int(11) NULL DEFAULT NULL COMMENT '用户粉丝数量',
  `cv_min_fans_num` int(11) NULL DEFAULT NULL COMMENT '用户粉丝数量',
  `cv_avg_fans_num` decimal(14, 4) NULL DEFAULT NULL,
  `cv_main_character_total_num` decimal(32, 0) NULL DEFAULT NULL,
  `cv_main_character_max_num` bigint(11) NULL DEFAULT NULL,
  `cv_main_character_min_num` bigint(11) NULL DEFAULT NULL,
  `cv_main_character_avg_num` decimal(14, 4) NULL DEFAULT NULL,
  `cv_aux_character_total_num` decimal(32, 0) NULL DEFAULT NULL,
  `cv_aux_character_max_num` bigint(11) NULL DEFAULT NULL,
  `cv_aux_character_min_num` bigint(11) NULL DEFAULT NULL,
  `cv_aux_character_avg_num` decimal(14, 4) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for drama_cv_sound_feature
-- ----------------------------
DROP TABLE IF EXISTS `drama_cv_sound_feature`;
CREATE TABLE `drama_cv_sound_feature`  (
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `drama_sound_cv_max_num` bigint(21) NULL DEFAULT NULL,
  `drama_sound_cv_min_num` bigint(21) NULL DEFAULT NULL,
  `drama_sound_cv_avg_num` decimal(24, 4) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_view_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_danmu_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_favorite_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_point_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_review_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_view_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_danmu_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_favorite_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_point_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_review_num` decimal(32, 0) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for drama_fans_reward_feature
-- ----------------------------
DROP TABLE IF EXISTS `drama_fans_reward_feature`;
CREATE TABLE `drama_fans_reward_feature`  (
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `drama_fans_reward_total_fans_num` int(11) NULL DEFAULT NULL COMMENT '剧集总打赏人数',
  `drama_fans_reward_week_ranking_fans_num` decimal(23, 0) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_fans_num` decimal(23, 0) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_fans_num` decimal(23, 0) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_total_coin` decimal(32, 0) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_total_coin` decimal(32, 0) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_total_coin` decimal(32, 0) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_max_coin` bigint(11) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_max_coin` bigint(11) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_max_coin` bigint(11) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_min_coin` bigint(11) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_min_coin` bigint(11) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_min_coin` bigint(11) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_avg_coin` decimal(14, 4) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_avg_coin` decimal(14, 4) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_avg_coin` decimal(14, 4) NULL DEFAULT NULL,
  `drama_fans_create_time_between_submit_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_create_time_between_submit_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_create_time_between_submit_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_create_time_between_latest_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_create_time_between_latest_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_create_time_between_latest_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_submit_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_submit_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_submit_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_latest_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_latest_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_latest_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_submit_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_submit_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_submit_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_latest_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_latest_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_latest_drama_time_avg` double NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for drama_feature
-- ----------------------------
DROP TABLE IF EXISTS `drama_feature`;
CREATE TABLE `drama_feature`  (
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `drama_name_len` int(11) NULL DEFAULT NULL,
  `drama_intro_len` int(11) NULL DEFAULT NULL,
  `drama_has_author` int(11) NULL DEFAULT NULL,
  `drama_is_serialize` int(11) NULL DEFAULT NULL,
  `drama_total_sound_num` int(11) NULL DEFAULT NULL,
  `drama_total_view_num` double NULL DEFAULT NULL,
  `drama_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `drama_tag_num` int(11) NULL DEFAULT NULL,
  `drama_pay_type` int(11) NULL DEFAULT NULL,
  `drama_total_pay_money` int(11) NULL DEFAULT NULL,
  `drama_pay_sound_percent` double NULL DEFAULT NULL,
  `drama_cv_total_num` int(11) NULL DEFAULT NULL,
  `drama_cv_total_fans_num` int(11) NULL DEFAULT NULL,
  `drama_cv_max_fans_num` int(11) NULL DEFAULT NULL,
  `drama_cv_min_fans_num` int(11) NULL DEFAULT NULL,
  `drama_cv_avg_fans_num` double NULL DEFAULT NULL,
  `drama_cv_main_total_fans_num` int(11) NULL DEFAULT NULL,
  `drama_cv_main_max_fans_num` int(11) NULL DEFAULT NULL,
  `drama_cv_main_min_fans_num` int(11) NULL DEFAULT NULL,
  `drama_cv_main_avg_fans_num` double NULL DEFAULT NULL,
  `drama_cv_aux_max_fans_num` int(11) NULL DEFAULT NULL,
  `drama_cv_aux_min_fans_num` int(11) NULL DEFAULT NULL,
  `drama_cv_aux_avg_fans_num` double NULL DEFAULT NULL,
  `drama_sound_cv_max_num` int(11) NULL DEFAULT NULL,
  `drama_sound_cv_min_num` int(11) NULL DEFAULT NULL,
  `drama_sound_cv_avg_num` double NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_view_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_favorite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_point_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_cv_num_sound_review_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_view_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_favorite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_point_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_cv_num_sound_review_num` int(11) NULL DEFAULT NULL,
  `drama_total_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_max_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_min_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_avg_danmu_num` double NULL DEFAULT NULL,
  `drama_total_favorite_num` int(11) NULL DEFAULT NULL,
  `drama_max_favorite_num` int(11) NULL DEFAULT NULL,
  `drama_min_favorite_num` int(11) NULL DEFAULT NULL,
  `drama_avg_favorite_num` double NULL DEFAULT NULL,
  `drama_total_point_num` int(11) NULL DEFAULT NULL,
  `drama_max_point_num` int(11) NULL DEFAULT NULL,
  `drama_min_point_num` int(11) NULL DEFAULT NULL,
  `drama_avg_point_num` double NULL DEFAULT NULL,
  `drama_total_review_num` int(11) NULL DEFAULT NULL,
  `drama_max_review_num` int(11) NULL DEFAULT NULL,
  `drama_min_review_num` int(11) NULL DEFAULT NULL,
  `drama_avg_review_num` double NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_favorite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_point_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_review_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_cv_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_cv_total_fans_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_is_pay` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_favorite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_point_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_review_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_cv_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_cv_total_fans_num` int(11) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_is_pay` int(11) NULL DEFAULT NULL,
  `drama_reward_max_week_rank` int(11) NULL DEFAULT NULL,
  `drama_reward_max_month_rank` int(11) NULL DEFAULT NULL,
  `drama_reward_max_total_rank` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_total_fans_num` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_fans_num` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_fans_num` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_fans_num` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_total_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_total_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_total_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_max_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_max_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_max_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_min_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_min_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_min_coin` int(11) NULL DEFAULT NULL,
  `drama_fans_reward_week_ranking_avg_coin` double NULL DEFAULT NULL,
  `drama_fans_reward_month_ranking_avg_coin` double NULL DEFAULT NULL,
  `drama_fans_reward_total_ranking_avg_coin` double NULL DEFAULT NULL,
  `drama_fans_create_time_between_submit_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_create_time_between_submit_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_create_time_between_submit_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_create_time_between_latest_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_create_time_between_latest_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_create_time_between_latest_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_submit_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_submit_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_submit_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_latest_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_latest_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_month_create_time_between_latest_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_submit_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_submit_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_submit_drama_time_avg` double NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_latest_drama_time_max` int(11) NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_latest_drama_time_min` int(11) NULL DEFAULT NULL,
  `drama_fans_total_create_time_between_latest_drama_time_avg` double NULL DEFAULT NULL,
  `drama_upuser_grade` int(11) NULL DEFAULT NULL,
  `drama_upuser_fish_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_fans_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_follower_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_drama_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_subscriptions_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_channel_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_total_view_num` double NULL DEFAULT NULL,
  `drama_upuser_submit_sound_max_view_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_min_view_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_avg_view_num` double NULL DEFAULT NULL,
  `drama_upuser_submit_sound_total_danmu_num` double NULL DEFAULT NULL,
  `drama_upuser_submit_sound_max_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_min_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_avg_danmu_num` double NULL DEFAULT NULL,
  `drama_upuser_submit_sound_total_review_num` double NULL DEFAULT NULL,
  `drama_upuser_submit_sound_max_review_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_min_review_num` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_avg_review_num` double NULL DEFAULT NULL,
  `drama_upuser_submit_sound_max_pay_type` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_sound_pay_sound_percent` double NULL DEFAULT NULL,
  `drama_upuser_submit_drama_has_fans_reward` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_drama_has_reward_week_ranking` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_drama_has_reward_month_ranking` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_drama_has_reward_total_ranking` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_drama_reward_week_max_rank` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_drama_reward_month_max_rank` int(11) NULL DEFAULT NULL,
  `drama_upuser_submit_drama_reward_total_max_rank` int(11) NULL DEFAULT NULL,
  `drama_sound_total_time` bigint(20) NULL DEFAULT NULL,
  `drama_sound_max_time` int(11) NULL DEFAULT NULL,
  `drama_sound_min_time` int(11) NULL DEFAULT NULL,
  `drama_sound_avg_time` double NULL DEFAULT NULL,
  `drama_sound_max_time_sound_view_num` int(11) NULL DEFAULT NULL,
  `drama_sound_min_time_sound_view_num` int(11) NULL DEFAULT NULL,
  `drama_sound_max_time_sound_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_sound_min_time_sound_danmu_num` int(11) NULL DEFAULT NULL,
  `drama_sound_max_time_sound_review_num` int(11) NULL DEFAULT NULL,
  `drama_sound_min_time_sound_review_num` int(11) NULL DEFAULT NULL,
  `drama_sound_danmu_15s_max_traffic` double NULL DEFAULT NULL,
  `drama_sound_danmu_15s_min_traffic` double NULL DEFAULT NULL,
  `drama_sound_danmu_15s_avg_traffic` double NULL DEFAULT NULL,
  `drama_sound_max_traffic_position_in_sound_avg` double NULL DEFAULT NULL,
  `drama_sound_min_traffic_position_in_sound_avg` double NULL DEFAULT NULL,
  `drama_danmu_avg_len` double NULL DEFAULT NULL,
  `drama_danmu_max_len` int(11) NULL DEFAULT NULL,
  `drama_danmu_min_len` int(11) NULL DEFAULT NULL,
  `drama_danmu_positive_num` int(11) NULL DEFAULT NULL,
  `drama_danmu_negtive_num` int(11) NULL DEFAULT NULL,
  `drama_danmu_submit_time_between_submit_sound_time_max` int(11) NULL DEFAULT NULL,
  `drama_danmu_submit_time_between_submit_sound_time_min` int(11) NULL DEFAULT NULL,
  `drama_danmu_submit_time_between_submit_sound_time_avg` double NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_7days_num_max` int(11) NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_7days_num_min` int(11) NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_7days_num_avg` double NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_14days_num_max` int(11) NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_14days_num_min` int(11) NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_14days_num_avg` double NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_30days_num_max` int(11) NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_30days_num_min` int(11) NULL DEFAULT NULL,
  `drama_danmu_time_between_sound_time_in_30days_num_avg` double NULL DEFAULT NULL,
  `drama_sound_tag_total_cite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_tag_max_cite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_tag_min_cite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_tag_avg_cite_num` double NULL DEFAULT NULL,
  `drama_sound_tag_has_cv_name_num` int(11) NULL DEFAULT NULL,
  `drama_sound_tag_has_cv_name_total_cite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_tag_has_cv_name_max_cite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_tag_has_cv_name_min_cite_num` int(11) NULL DEFAULT NULL,
  `drama_sound_tag_has_cv_name_avg_cite_num` double NULL DEFAULT NULL,
  PRIMARY KEY (`drama_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for drama_sound_feature
-- ----------------------------
DROP TABLE IF EXISTS `drama_sound_feature`;
CREATE TABLE `drama_sound_feature`  (
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `drama_sound_has_max_view_num_sound_danmu_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_favorite_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_point_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_review_num` decimal(33, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_cv_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_cv_total_fans_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_max_view_num_sound_is_pay` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_danmu_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_favorite_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_point_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_review_num` decimal(33, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_cv_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_cv_total_fans_num` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_has_min_view_num_sound_is_pay` decimal(32, 0) NULL DEFAULT NULL,
  `drama_sound_cv_max_num` int(11) NULL DEFAULT NULL,
  `drama_sound_cv_min_num` int(11) NULL DEFAULT NULL,
  `drama_sound_cv_avg_num` double NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for drama_sound_num_count
-- ----------------------------
DROP TABLE IF EXISTS `drama_sound_num_count`;
CREATE TABLE `drama_sound_num_count`  (
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `view_num` decimal(32, 0) NULL DEFAULT NULL,
  `danmu_num` decimal(32, 0) NULL DEFAULT NULL,
  `favorite_num` decimal(32, 0) NULL DEFAULT NULL,
  `point_num` decimal(32, 0) NULL DEFAULT NULL,
  `allreview_num` decimal(32, 0) NULL DEFAULT NULL,
  `review_num` decimal(32, 0) NULL DEFAULT NULL,
  `subreview_num` decimal(32, 0) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for external_tag
-- ----------------------------
DROP TABLE IF EXISTS `external_tag`;
CREATE TABLE `external_tag`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_tag_id` int(11) NULL DEFAULT NULL COMMENT '父标签id',
  `tag_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标签名',
  `created_at` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `from` tinyint(1) NOT NULL DEFAULT 1 COMMENT '来源，1：晋江',
  `tag_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT ' 对标签的描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 307 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for feat_sound_opensmile384_new
-- ----------------------------
DROP TABLE IF EXISTS `feat_sound_opensmile384_new`;
CREATE TABLE `feat_sound_opensmile384_new`  (
  `sound_id` int(11) NOT NULL,
  `pcm_RMSenergy_sma_max numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_min numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_range numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_minPos numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_amean numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_stddev numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_skewness numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[1]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[2]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[3]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[4]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[5]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[6]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[7]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[8]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[9]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[10]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[11]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma[12]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_max numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_min numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_range numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_minPos numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_amean numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_stddev numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_skewness numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_kurtosis numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_max numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_min numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_range numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_maxPos numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_minPos numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_amean numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_linregc1 numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_linregc2 numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_linregerrQ numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_stddev numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_skewness numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_kurtosis numeric` double NULL DEFAULT NULL,
  `F0_sma_max numeric` double NULL DEFAULT NULL,
  `F0_sma_min numeric` double NULL DEFAULT NULL,
  `F0_sma_range numeric` double NULL DEFAULT NULL,
  `F0_sma_maxPos numeric` double NULL DEFAULT NULL,
  `F0_sma_minPos numeric` double NULL DEFAULT NULL,
  `F0_sma_amean numeric` double NULL DEFAULT NULL,
  `F0_sma_linregc1 numeric` double NULL DEFAULT NULL,
  `F0_sma_linregc2 numeric` double NULL DEFAULT NULL,
  `F0_sma_linregerrQ numeric` double NULL DEFAULT NULL,
  `F0_sma_stddev numeric` double NULL DEFAULT NULL,
  `F0_sma_skewness numeric` double NULL DEFAULT NULL,
  `F0_sma_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_max numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_min numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_range numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_minPos numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_amean numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_stddev numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_skewness numeric` double NULL DEFAULT NULL,
  `pcm_RMSenergy_sma_de_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[1]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[2]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[3]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[4]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[5]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[6]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[7]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[8]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[9]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[10]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[11]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_max numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_min numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_range numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_minPos numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_amean numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_stddev numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_skewness numeric` double NULL DEFAULT NULL,
  `pcm_fftMag_mfcc_sma_de[12]_kurtosis numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_max numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_min numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_range numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_maxPos numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_minPos numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_amean numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_linregc1 numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_linregc2 numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_linregerrQ numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_stddev numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_skewness numeric` double NULL DEFAULT NULL,
  `pcm_zcr_sma_de_kurtosis numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_max numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_min numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_range numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_maxPos numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_minPos numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_amean numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_linregc1 numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_linregc2 numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_linregerrQ numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_stddev numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_skewness numeric` double NULL DEFAULT NULL,
  `voiceProb_sma_de_kurtosis numeric` double NULL DEFAULT NULL,
  `F0_sma_de_max numeric` double NULL DEFAULT NULL,
  `F0_sma_de_min numeric` double NULL DEFAULT NULL,
  `F0_sma_de_range numeric` double NULL DEFAULT NULL,
  `F0_sma_de_maxPos numeric` double NULL DEFAULT NULL,
  `F0_sma_de_minPos numeric` double NULL DEFAULT NULL,
  `F0_sma_de_amean numeric` double NULL DEFAULT NULL,
  `F0_sma_de_linregc1 numeric` double NULL DEFAULT NULL,
  `F0_sma_de_linregc2 numeric` double NULL DEFAULT NULL,
  `F0_sma_de_linregerrQ numeric` double NULL DEFAULT NULL,
  `F0_sma_de_stddev numeric` double NULL DEFAULT NULL,
  `F0_sma_de_skewness numeric` double NULL DEFAULT NULL,
  `F0_sma_de_kurtosis numeric` double NULL DEFAULT NULL,
  PRIMARY KEY (`sound_id`) USING BTREE,
  INDEX `sound`(`sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for feature_num_user_basic
-- ----------------------------
DROP TABLE IF EXISTS `feature_num_user_basic`;
CREATE TABLE `feature_num_user_basic`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '自增主键id',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户id',
  `user_icon_is_default` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户头像是否是默认头像。0：没有，1：有',
  `user_has_submit_sound_or_darma` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户是否发表过声音/剧集。0：没有，1：有',
  `user_grade` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户等级',
  `user_fish_num` int(11) NULL DEFAULT NULL COMMENT '用户小鱼干数量',
  `user_follower_num` int(11) NULL DEFAULT NULL COMMENT '用户关注数量',
  `user_fans_num` int(11) NULL DEFAULT NULL COMMENT '用户粉丝数量',
  `user_has_organization` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户是否有所属社团。0：没有，1：有',
  `user_submit_sound_num` int(11) NULL DEFAULT NULL COMMENT '用户发表声音数量',
  `user_submit_drama_num` int(11) NULL DEFAULT NULL COMMENT '用户发表剧集数量',
  `user_subscribe_drama_num` int(11) NULL DEFAULT NULL COMMENT '用户剧集订阅数量',
  `user_subscribe_channel_num` int(11) NULL DEFAULT NULL COMMENT '用户频道订阅数量',
  `user_favorite_album_num` int(11) NULL DEFAULT NULL COMMENT '用户收藏音频数量',
  `user_image_num` int(11) NULL DEFAULT NULL COMMENT '用户图片数量',
  `ct` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间;创建时间',
  `dt` datetime(0) NULL DEFAULT NULL COMMENT '删除时间;删除时间',
  `ut` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间;更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 2482614 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户特征-基础部分' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for feature_num_user_introduction
-- ----------------------------
DROP TABLE IF EXISTS `feature_num_user_introduction`;
CREATE TABLE `feature_num_user_introduction`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '租户号;唯一表示',
  `user_intro_len` int(11) NULL DEFAULT NULL COMMENT '用户自我介绍长度',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'user_id;用户ID',
  `user_intro_has_chinese` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户自我介绍是否有中文。0：没有，1：有',
  `user_intro_has_english` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户自我介绍是否有英文。0：没有，1：有',
  `ct` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间;创建时间',
  `dt` datetime(0) NULL DEFAULT NULL COMMENT '删除时间;删除时间',
  `ut` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间;更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户特征-介绍部分' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for feature_num_user_nickname
-- ----------------------------
DROP TABLE IF EXISTS `feature_num_user_nickname`;
CREATE TABLE `feature_num_user_nickname`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '租户号;唯一表示',
  `user_name_len` int(11) NULL DEFAULT NULL COMMENT 'user_name_len;用户昵称长度',
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'user_id;用户ID',
  `user_name_has_chinese` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'user_name_has_chinese;用户昵称是否有中文。0：没有，1：有',
  `user_name_has_english` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'user_name_has_english;用户昵称是否有英文。0：没有，1：有',
  `ct` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间;创建时间',
  `dt` datetime(0) NULL DEFAULT NULL COMMENT '删除时间;删除时间',
  `ut` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间;更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1947484 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户特征-昵称部分' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for old_user_sound_drama_feature
-- ----------------------------
DROP TABLE IF EXISTS `old_user_sound_drama_feature`;
CREATE TABLE `old_user_sound_drama_feature`  (
  `user_id` int(11) NOT NULL,
  `sound_id` int(11) NOT NULL,
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `user_in_sound_is_submit_review` int(11) NULL DEFAULT NULL,
  `user_in_sound_submit_review_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_first_review_with_sound_publish_time_diff_days` int(11) NULL DEFAULT NULL,
  `user_in_sound_latest_review_with_sound_publish_time_diff_days` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_total_len` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_len_max` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_len_min` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_len_avg` double NULL DEFAULT NULL,
  `user_in_sound_review_subreview_total_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_subreview_max_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_subreview_min_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_subreview_avg_num` double NULL DEFAULT NULL,
  `user_in_sound_review_like_total_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_like_max_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_like_min_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_review_like_avg_num` double NULL DEFAULT NULL,
  `user_in_sound_is_submit_danmu` int(11) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_total_len` int(11) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_max_len` int(11) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_min_len` int(11) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_avg_len` double NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_max_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_min_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_avg_num` double NULL DEFAULT NULL,
  `user_in_drama_total_review_num` int(11) NULL DEFAULT NULL,
  `user_in_drama_total_danmu_num` int(11) NULL DEFAULT NULL,
  `user_in_drama_is_pay_for_drama` int(11) NULL DEFAULT NULL,
  `user_in_drama_is_in_drama_fans_reward` int(11) NULL DEFAULT NULL,
  `user_in_drama_fans_reward_total_coin` int(11) NULL DEFAULT NULL,
  `user_in_drama_is_follower_upuser` int(11) NULL DEFAULT NULL,
  INDEX `user_sound_id`(`user_id`, `sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for review_content_2023
-- ----------------------------
DROP TABLE IF EXISTS `review_content_2023`;
CREATE TABLE `review_content_2023`  (
  `review_id` int(11) NOT NULL COMMENT '评论id',
  `subject_id` int(11) NULL DEFAULT NULL COMMENT '主体id（音单id/声音id）',
  `subject_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主体类型；1：声音，2：音单',
  `user_id` int(11) NULL DEFAULT NULL COMMENT '用户id',
  `review_content` varchar(10000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '评论内容',
  `review_created_time` datetime(0) NULL DEFAULT NULL COMMENT '评论发送时间',
  `review_is_sub_review` tinyint(1) NULL DEFAULT NULL COMMENT '是否是子评论',
  `review_sub_review_num` int(11) NULL DEFAULT NULL COMMENT '子评论数量',
  `review_like_num` int(11) NULL DEFAULT NULL COMMENT '点赞数量',
  `review_element_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '（未定）',
  `review_checked` int(11) NULL DEFAULT NULL COMMENT '检查（未定）',
  `review_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ip',
  `review_ip_detail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ip地理地址',
  `review_ip_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'ip地址_省',
  `review_score_ratio` decimal(24, 6) NULL DEFAULT NULL COMMENT '（未定）',
  `review_score_dislike_proportion_ratio` decimal(24, 6) NULL DEFAULT NULL COMMENT '（未定）',
  `review_acore_blacklist_ratio` decimal(24, 6) NULL DEFAULT NULL COMMENT '（未定）',
  `review_score` decimal(24, 6) NULL DEFAULT NULL COMMENT '（未定）',
  `review_authenticated` int(11) NULL DEFAULT NULL COMMENT '（未定）',
  `created_time` datetime(0) NOT NULL COMMENT '记录时间',
  INDEX `review_user_sound_id`(`review_id`, `subject_id`, `user_id`) USING BTREE,
  INDEX `sound_user_id`(`subject_id`, `user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sound_cv_feature
-- ----------------------------
DROP TABLE IF EXISTS `sound_cv_feature`;
CREATE TABLE `sound_cv_feature`  (
  `sound_id` int(11) NOT NULL COMMENT '声音id',
  `total_cv_num` bigint(21) NOT NULL DEFAULT 0,
  `cv_has_userid_num` decimal(23, 0) NULL DEFAULT NULL,
  `cv_total_fans_num` decimal(32, 0) NULL DEFAULT NULL,
  `cv_max_fans_num` int(11) NULL DEFAULT NULL COMMENT '用户粉丝数量',
  `cv_min_fans_num` int(11) NULL DEFAULT NULL COMMENT '用户粉丝数量',
  `cv_avg_fans_num` decimal(14, 4) NULL DEFAULT NULL,
  `cv_main_character_total_num` decimal(32, 0) NULL DEFAULT NULL,
  `cv_main_character_max_num` bigint(11) NULL DEFAULT NULL,
  `cv_main_character_min_num` bigint(11) NULL DEFAULT NULL,
  `cv_main_character_avg_num` decimal(14, 4) NULL DEFAULT NULL,
  `cv_aux_character_total_num` decimal(32, 0) NULL DEFAULT NULL,
  `cv_aux_character_max_num` bigint(11) NULL DEFAULT NULL,
  `cv_aux_character_min_num` bigint(11) NULL DEFAULT NULL,
  `cv_aux_character_avg_num` decimal(14, 4) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sound_danmu_feature
-- ----------------------------
DROP TABLE IF EXISTS `sound_danmu_feature`;
CREATE TABLE `sound_danmu_feature`  (
  `sound_id` int(11) NOT NULL,
  `danmu_len_avg` double NULL DEFAULT NULL,
  `danmu_len_max` int(11) NULL DEFAULT NULL,
  `danmu_len_min` int(11) NULL DEFAULT NULL,
  `danmu_create_time_max` int(11) NULL DEFAULT NULL,
  `danmu_create_time_min` int(11) NULL DEFAULT NULL,
  `danmu_create_time_avg` double NULL DEFAULT NULL,
  `danmu_submit_time_between_submit_sound_time_in_7days_num` int(11) NULL DEFAULT NULL,
  `danmu_submit_time_between_submit_sound_time_in_14days_num` int(11) NULL DEFAULT NULL,
  `danmu_submit_time_between_submit_sound_time_in_30days_num` int(11) NULL DEFAULT NULL,
  `danmu_submit_time_between_submit_sound_time_max` int(11) NULL DEFAULT NULL,
  `danmu_submit_time_between_submit_sound_time_min` int(11) NULL DEFAULT NULL,
  `danmu_submit_time_between_submit_sound_time_avg` double NULL DEFAULT NULL,
  PRIMARY KEY (`sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sound_danmu_traffic_feature
-- ----------------------------
DROP TABLE IF EXISTS `sound_danmu_traffic_feature`;
CREATE TABLE `sound_danmu_traffic_feature`  (
  `sound_id` int(11) NOT NULL,
  `danmu_id` int(11) NULL DEFAULT NULL COMMENT '弹幕id',
  `sound_info_duration` int(11) NULL DEFAULT NULL COMMENT '声音时长（毫秒）',
  `danmu_info_stime_notransform` decimal(24, 6) NULL DEFAULT NULL COMMENT '弹幕音频时间（未定）',
  `30s_position_in_sound` decimal(16, 0) NULL DEFAULT NULL COMMENT '弹幕在声音的第几个30s时间窗内',
  `position_in_sound` decimal(28, 10) NULL DEFAULT NULL COMMENT '弹幕在声音的哪个位置',
  INDEX `sound_time`(`sound_id`, `30s_position_in_sound`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sound_feature
-- ----------------------------
DROP TABLE IF EXISTS `sound_feature`;
CREATE TABLE `sound_feature`  (
  `sound_id` int(11) NOT NULL,
  `sound_title_len` int(11) NULL DEFAULT NULL,
  `sound_intro_len` int(11) NULL DEFAULT NULL,
  `sound_tag_num` int(11) NULL DEFAULT NULL,
  `sound_pay_type` int(11) NULL DEFAULT NULL,
  `sound_type` int(11) NULL DEFAULT NULL,
  `sound_time` int(11) NULL DEFAULT NULL,
  `sound_view_num` int(11) NULL DEFAULT NULL,
  `sound_danmu_num` int(11) NULL DEFAULT NULL,
  `sound_favorite_num` int(11) NULL DEFAULT NULL,
  `sound_point_num` int(11) NULL DEFAULT NULL,
  `sound_review_not_subreview_num` int(11) NULL DEFAULT NULL,
  `sound_review_subreview_num` int(11) NULL DEFAULT NULL,
  `sound_is_allow_download` int(11) NULL DEFAULT NULL,
  `sound_submit_time_between_first_and_this` int(11) NULL DEFAULT NULL,
  `sound_position_in_total_darma_sound` int(11) NULL DEFAULT NULL,
  `sound_view_num_in_total_darma_percent` double NULL DEFAULT NULL,
  `sound_danmu_num_in_total_darma_percent` double NULL DEFAULT NULL,
  `sound_favorite_num_in_total_darma_percent` double NULL DEFAULT NULL,
  `sound_point_num_in_total_darma_percent` double NULL DEFAULT NULL,
  `sound_review_num_in_total_darma_percent` double NULL DEFAULT NULL,
  `sound_not_subreview_num_in_total_darma_percent` double NULL DEFAULT NULL,
  `sound_subreview_num_in_total_darma_percent` double NULL DEFAULT NULL,
  `sound_review_avg_len` int(11) NULL DEFAULT NULL,
  `sound_review_max_len` int(11) NULL DEFAULT NULL,
  `sound_review_min_len` int(11) NULL DEFAULT NULL,
  `sound_review_avg_like_num` int(11) NULL DEFAULT NULL,
  `sound_review_max_like_num` int(11) NULL DEFAULT NULL,
  `sound_review_min_like_num` int(11) NULL DEFAULT NULL,
  `sound_review_positive_num` int(11) NULL DEFAULT NULL,
  `sound_review_negtive_num` int(11) NULL DEFAULT NULL,
  `sound_review_submit_time_between_submit_sound_time_max` int(11) NULL DEFAULT NULL,
  `sound_review_submit_time_between_submit_sound_time_min` int(11) NULL DEFAULT NULL,
  `sound_review_submit_time_between_submit_sound_time_avg` int(11) NULL DEFAULT NULL,
  `sound_review_submit_time_between_submit_sound_time_in_7days_num` int(11) NULL DEFAULT NULL,
  `sound_review_submit_time_between_submit_sound_time_in_14days_num` int(11) NULL DEFAULT NULL,
  `sound_review_submit_time_between_submit_sound_time_in_30days_num` int(11) NULL DEFAULT NULL,
  `sound_danmu_avg_len` int(11) NULL DEFAULT NULL,
  `sound_danmu_max_len` int(11) NULL DEFAULT NULL,
  `sound_danmu_min_len` int(11) NULL DEFAULT NULL,
  `sound_danmu_positive_num` int(11) NULL DEFAULT NULL,
  `sound_danmu_negitive_num` int(11) NULL DEFAULT NULL,
  `sound_danmu_submit_time_between_submit_sound_time_max` int(11) NULL DEFAULT NULL,
  `sound_danmu_submit_time_between_submit_sound_time_min` int(11) NULL DEFAULT NULL,
  `sound_danmu_submit_time_between_submit_sound_time_avg` int(11) NULL DEFAULT NULL,
  `sound_danmu_submit_time_between_submit_sound_time_in_7days_num` int(11) NULL DEFAULT NULL,
  `sound_danmu_submit_time_between_submit_sound_time_in_14days_num` int(11) NULL DEFAULT NULL,
  `sound_danmu_submit_time_between_submit_sound_time_in_30days_num` int(11) NULL DEFAULT NULL,
  `sound_danmu_30s_max_traffic` int(11) NULL DEFAULT NULL,
  `sound_danmu_30s_min_traffic` int(11) NULL DEFAULT NULL,
  `sound_danmu_30s_avg_traffic` double NULL DEFAULT NULL,
  `sound_danmu_30s_max_traffic_position_in_sound` double NULL DEFAULT NULL,
  `sound_danmu_30s_min_traffic_position_in_sound` double NULL DEFAULT NULL,
  `sound_cv_total_num` int(11) NULL DEFAULT NULL,
  `sound_cv_has_userid_num` int(11) NULL DEFAULT NULL,
  `sound_cv_total_fans_num` int(11) NULL DEFAULT NULL,
  `sound_cv_max_fans_num` int(11) NULL DEFAULT NULL,
  `sound_cv_min_fans_num` int(11) NULL DEFAULT NULL,
  `sound_cv_avg_fans_num` double NULL DEFAULT NULL,
  `sound_cv_main_cv_total_fans_num` int(11) NULL DEFAULT NULL,
  `sound_cv_main_cv_max_fans_num` int(11) NULL DEFAULT NULL,
  `sound_cv_main_cv_min_fans_num` int(11) NULL DEFAULT NULL,
  `sound_cv_main_cv_avg_fans_num` double NULL DEFAULT NULL,
  `sound_cv_auxiliary_cv_max_fans_num` int(11) NULL DEFAULT NULL,
  `sound_cv_auxiliary_cv_min_fans_num` int(11) NULL DEFAULT NULL,
  `sound_cv_auxiliary_cv_avg_fans_num` double NULL DEFAULT NULL,
  `sound_tag_total_cite_num` int(11) NULL DEFAULT NULL,
  `sound_tag_max_cite_num` int(11) NULL DEFAULT NULL,
  `sound_tag_min_cite_num` int(11) NULL DEFAULT NULL,
  `sound_tag_avg_cite_num` int(11) NULL DEFAULT NULL,
  `sound_tag_has_cv_name_num` int(11) NULL DEFAULT NULL,
  `sound_tag_has_cv_name_total_cite_num` int(11) NULL DEFAULT NULL,
  `sound_tag_has_cv_name_max_cite_num` int(11) NULL DEFAULT NULL,
  `sound_tag_has_cv_name_min_cite_num` int(11) NULL DEFAULT NULL,
  `sound_tag_has_cv_name_avg_cite_num` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sound_review_feature
-- ----------------------------
DROP TABLE IF EXISTS `sound_review_feature`;
CREATE TABLE `sound_review_feature`  (
  `subject_id` int(11) NULL DEFAULT NULL COMMENT '主体id（音单id/声音id）',
  `review_len_avg` decimal(13, 4) NULL DEFAULT NULL,
  `review_len_max` bigint(10) NULL DEFAULT NULL,
  `review_len_min` bigint(10) NULL DEFAULT NULL,
  `review_like_avg` decimal(14, 4) NULL DEFAULT NULL,
  `review_like_max` int(11) NULL DEFAULT NULL COMMENT '点赞数量',
  `review_like_min` int(11) NULL DEFAULT NULL COMMENT '点赞数量',
  `review_create_time_max` bigint(7) NULL DEFAULT NULL,
  `review_create_time_min` bigint(7) NULL DEFAULT NULL,
  `review_create_time_avg` decimal(10, 4) NULL DEFAULT NULL,
  `review_submit_time_between_submit_sound_time_in_7days_num` decimal(23, 0) NULL DEFAULT NULL,
  `review_submit_time_between_submit_sound_time_in_14days_num` decimal(23, 0) NULL DEFAULT NULL,
  `review_submit_time_between_submit_sound_time_in_30days_num` decimal(23, 0) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sound_subtitles
-- ----------------------------
DROP TABLE IF EXISTS `sound_subtitles`;
CREATE TABLE `sound_subtitles`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sound_id` int(11) NULL DEFAULT NULL COMMENT '声音ID',
  `begin_time` datetime(0) NULL DEFAULT NULL COMMENT '字幕开始时间',
  `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间开始时间',
  `seq` int(11) NULL DEFAULT NULL,
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP,
  `model_id` int(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sound_tag_feature
-- ----------------------------
DROP TABLE IF EXISTS `sound_tag_feature`;
CREATE TABLE `sound_tag_feature`  (
  `sound_id` int(11) NOT NULL COMMENT '声音id',
  `tag_total_cite_num` decimal(42, 0) NULL DEFAULT NULL,
  `tag_max_cite_num` bigint(21) NULL DEFAULT NULL,
  `tag_min_cite_num` bigint(21) NULL DEFAULT NULL,
  `tag_avg_cite_num` decimal(24, 4) NULL DEFAULT NULL,
  `tag_has_cv_name_num` bigint(21) NULL DEFAULT 0,
  `tag_has_cv_name_total_cite_num` decimal(42, 0) NULL DEFAULT NULL,
  `tag_has_cv_name_max_cite_num` bigint(21) NULL DEFAULT NULL,
  `tag_has_cv_name_min_cite_num` bigint(21) NULL DEFAULT NULL,
  `tag_has_cv_name_avg_cite_num` decimal(24, 4) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_around_danmu_feature
-- ----------------------------
DROP TABLE IF EXISTS `user_around_danmu_feature`;
CREATE TABLE `user_around_danmu_feature`  (
  `sound_id` int(11) NOT NULL COMMENT '声音id',
  `user_id` int(11) NULL DEFAULT NULL COMMENT '用户id',
  `danmu_id` int(11) NULL DEFAULT NULL COMMENT '弹幕id',
  `around_15s_total_danmu_num` bigint(21) NOT NULL DEFAULT 0,
  `user_in_sound_danmu_around_15s_total_danmu_max_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_min_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_avg_num` int(11) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_drama_is_pay
-- ----------------------------
DROP TABLE IF EXISTS `user_drama_is_pay`;
CREATE TABLE `user_drama_is_pay`  (
  `user_id` int(11) NOT NULL,
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `sound_id` int(11) NULL DEFAULT NULL COMMENT '声音id',
  `drama_pay_type` int(11) NULL DEFAULT NULL,
  `sound_info_pay_type` int(11) NULL DEFAULT NULL COMMENT '付费类型 0:不付费，1：单集付费，2:全集付费',
  `user_has_review` int(11) NULL DEFAULT NULL,
  `user_has_danmu` int(11) NULL DEFAULT NULL,
  `user_in_drama_is_pay_for_drama` int(11) NULL DEFAULT NULL,
  INDEX `user_sound_id`(`user_id`, `sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_drama_is_pay_repeat
-- ----------------------------
DROP TABLE IF EXISTS `user_drama_is_pay_repeat`;
CREATE TABLE `user_drama_is_pay_repeat`  (
  `user_id` int(11) NOT NULL,
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `sound_id` int(11) NULL DEFAULT NULL COMMENT '声音id',
  `drama_pay_type` int(11) NULL DEFAULT NULL,
  `sound_info_pay_type` int(11) NULL DEFAULT NULL COMMENT '付费类型 0:不付费，1：单集付费，2:全集付费'
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_feature
-- ----------------------------
DROP TABLE IF EXISTS `user_feature`;
CREATE TABLE `user_feature`  (
  `user_id` int(11) NOT NULL,
  `user_name_len` int(10) NULL DEFAULT NULL,
  `user_name_has_chinese` int(11) NULL DEFAULT 0,
  `user_name_has_english` int(11) NULL DEFAULT 0,
  `user_intro_len` int(11) NULL DEFAULT NULL,
  `user_intro_has_chinese` int(11) NULL DEFAULT 0,
  `user_intro_has_english` int(11) NULL DEFAULT 0,
  `user_icon_is_default` int(11) NULL DEFAULT 0,
  `user_has_submit_sound_or_darma` int(11) NULL DEFAULT 0,
  `user_grade` int(11) NULL DEFAULT NULL,
  `user_fish_num` int(11) NULL DEFAULT NULL,
  `user_follower_num` int(11) NULL DEFAULT NULL,
  `user_fans_num` int(11) NULL DEFAULT NULL,
  `user_has_organization` int(11) NULL DEFAULT NULL,
  `user_submit_sound_num` int(11) NULL DEFAULT NULL,
  `user_submit_drama_num` int(11) NULL DEFAULT NULL,
  `user_subscribe_drama_num` int(11) NULL DEFAULT NULL,
  `user_subscribe_channel_num` int(11) NULL DEFAULT NULL,
  `user_favorite_album_num` int(11) NULL DEFAULT NULL,
  `user_image_num` int(11) NULL DEFAULT NULL,
  `user_major_subscribe_drama_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_minor_subscribe_drama_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_submit_danmu_drama_completed_num` int(11) NULL DEFAULT NULL,
  `user_submit_danmu_drama_total_view_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_max_view_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_min_view_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_avg_view_num` double NULL DEFAULT NULL,
  `user_submit_danmu_drama_total_danmu_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_max_danmu_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_min_danmu_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_avg_danmu_num` double NULL DEFAULT NULL,
  `user_submit_danmu_drama_total_review_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_max_review_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_min_review_num` bigint(20) NULL DEFAULT NULL,
  `user_submit_danmu_drama_avg_review_num` double NULL DEFAULT NULL,
  `user_has_in_drama_fans_reward_num` int(11) NULL DEFAULT 0,
  `user_has_in_drama_fans_reward_total_money` int(11) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_in_sound_danmu_feature
-- ----------------------------
DROP TABLE IF EXISTS `user_in_sound_danmu_feature`;
CREATE TABLE `user_in_sound_danmu_feature`  (
  `user_id` int(11) NOT NULL,
  `sound_id` int(11) NOT NULL,
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `user_in_sound_submit_danmu_total_len` decimal(31, 0) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_max_len` bigint(10) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_min_len` bigint(10) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_avg_len` decimal(13, 4) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_num` bigint(21) NULL DEFAULT 0,
  `user_in_sound_is_submit_danmu` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_max_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_min_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_avg_num` double NULL DEFAULT NULL,
  INDEX `user_sound_id`(`user_id`, `sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_in_sound_review_feature
-- ----------------------------
DROP TABLE IF EXISTS `user_in_sound_review_feature`;
CREATE TABLE `user_in_sound_review_feature`  (
  `user_id` int(11) NOT NULL,
  `sound_id` int(11) NOT NULL,
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `user_in_sound_submit_review_num` bigint(21) NULL DEFAULT 0,
  `user_in_sound_first_review_with_sound_publish_time_diff_days` bigint(7) NULL DEFAULT NULL,
  `user_in_sound_latest_review_with_sound_publish_time_diff_days` bigint(7) NULL DEFAULT NULL,
  `user_in_sound_review_total_len` decimal(31, 0) NULL DEFAULT NULL,
  `user_in_sound_review_len_max` bigint(10) NULL DEFAULT NULL,
  `user_in_sound_review_len_min` bigint(10) NULL DEFAULT NULL,
  `user_in_sound_review_len_avg` decimal(13, 4) NULL DEFAULT NULL,
  `user_in_sound_review_subreview_total_num` decimal(32, 0) NULL DEFAULT NULL,
  `user_in_sound_review_subreview_max_num` int(11) NULL DEFAULT NULL COMMENT '子评论数量',
  `user_in_sound_review_subreview_min_num` int(11) NULL DEFAULT NULL COMMENT '子评论数量',
  `user_in_sound_review_subreview_avg_num` decimal(14, 4) NULL DEFAULT NULL,
  `user_in_sound_review_like_total_num` decimal(32, 0) NULL DEFAULT NULL,
  `user_in_sound_review_like_max_num` int(11) NULL DEFAULT NULL COMMENT '点赞数量',
  `user_in_sound_review_like_min_num` int(11) NULL DEFAULT NULL COMMENT '点赞数量',
  `user_in_sound_review_like_avg_num` decimal(14, 4) NULL DEFAULT NULL,
  INDEX `user_sound_id`(`user_id`, `sound_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_sound_drama_feature
-- ----------------------------
DROP TABLE IF EXISTS `user_sound_drama_feature`;
CREATE TABLE `user_sound_drama_feature`  (
  `user_id` int(11) NOT NULL,
  `sound_id` int(11) NOT NULL,
  `drama_id` int(11) NOT NULL COMMENT '剧集id',
  `user_in_sound_is_submit_review` int(11) NULL DEFAULT NULL,
  `user_in_sound_submit_review_num` bigint(21) NULL DEFAULT 0,
  `user_in_sound_first_review_with_sound_publish_time_diff_days` bigint(7) NULL DEFAULT NULL,
  `user_in_sound_latest_review_with_sound_publish_time_diff_days` bigint(7) NULL DEFAULT NULL,
  `user_in_sound_review_total_len` decimal(31, 0) NULL DEFAULT NULL,
  `user_in_sound_review_len_max` bigint(10) NULL DEFAULT NULL,
  `user_in_sound_review_len_min` bigint(10) NULL DEFAULT NULL,
  `user_in_sound_review_len_avg` decimal(13, 4) NULL DEFAULT NULL,
  `user_in_sound_review_subreview_total_num` decimal(32, 0) NULL DEFAULT NULL,
  `user_in_sound_review_subreview_max_num` int(11) NULL DEFAULT NULL COMMENT '子评论数量',
  `user_in_sound_review_subreview_min_num` int(11) NULL DEFAULT NULL COMMENT '子评论数量',
  `user_in_sound_review_subreview_avg_num` decimal(14, 4) NULL DEFAULT NULL,
  `user_in_sound_review_like_total_num` decimal(32, 0) NULL DEFAULT NULL,
  `user_in_sound_review_like_max_num` int(11) NULL DEFAULT NULL COMMENT '点赞数量',
  `user_in_sound_review_like_min_num` int(11) NULL DEFAULT NULL COMMENT '点赞数量',
  `user_in_sound_review_like_avg_num` decimal(14, 4) NULL DEFAULT NULL,
  `user_in_sound_is_submit_danmu` int(11) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_total_len` decimal(31, 0) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_max_len` bigint(10) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_min_len` bigint(10) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_avg_len` decimal(13, 4) NULL DEFAULT NULL,
  `user_in_sound_submit_danmu_num` bigint(21) NULL DEFAULT 0,
  `user_in_sound_danmu_around_15s_total_danmu_max_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_min_num` int(11) NULL DEFAULT NULL,
  `user_in_sound_danmu_around_15s_total_danmu_avg_num` double NULL DEFAULT NULL,
  `user_in_drama_total_review_num` int(11) NULL DEFAULT NULL,
  `user_in_drama_total_danmu_num` int(11) NULL DEFAULT NULL,
  `user_in_drama_is_pay_for_drama` int(11) NULL DEFAULT NULL,
  `user_in_drama_is_in_drama_fans_reward` int(11) NULL DEFAULT NULL,
  `user_in_drama_fans_reward_total_coin` int(11) NULL DEFAULT NULL,
  `user_in_drama_is_follower_upuser` int(11) NULL DEFAULT NULL,
  INDEX `user_sound_id`(`user_id`, `sound_id`) USING BTREE,
  INDEX `user_drama_id`(`user_id`, `drama_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- View structure for activeuser_drama_and_sound_info
-- ----------------------------
DROP VIEW IF EXISTS `activeuser_drama_and_sound_info`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `activeuser_drama_and_sound_info` AS select `adi`.`user_id` AS `user_id`,`adi`.`sound_id` AS `sound_id`,`adi`.`drama_id` AS `drama_id`,`adi`.`drama_info_name` AS `drama_info_name`,`adi`.`drama_info_alias` AS `drama_info_alias`,`adi`.`drama_info_age` AS `drama_info_age`,`adi`.`drama_info_author` AS `drama_info_author`,`adi`.`drama_info_type` AS `drama_info_type`,`adi`.`drama_info_catalog` AS `drama_info_catalog`,`adi`.`drama_info_catalog_name` AS `drama_info_catalog_name`,`adi`.`organization_id` AS `organization_id`,`adi`.`drama_info_style` AS `drama_info_style`,`adi`.`drama_info_abstract` AS `drama_info_abstract`,`adi`.`drama_info_organization` AS `drama_info_organization`,`adi`.`drama_info_serialize` AS `drama_info_serialize`,`adi`.`drama_info_pay_type` AS `drama_info_pay_type`,`adi`.`drama_info_need_pay` AS `drama_info_need_pay`,`adi`.`drama_info_price` AS `drama_info_price`,`adi`.`drama_info_newest` AS `drama_info_newest`,`adi`.`drama_info_newst_episode_id` AS `drama_info_newst_episode_id`,`adi`.`drama_info_update_period` AS `drama_info_update_period`,`adi`.`drama_info_view_count` AS `drama_info_view_count`,`adi`.`drama_info_all_reward_num` AS `drama_info_all_reward_num`,`adi`.`drama_info_reward_week_rank` AS `drama_info_reward_week_rank`,`si`.`sound_info_catalog_id` AS `sound_info_catalog_id`,`si`.`sound_info_created_time` AS `sound_info_created_time`,`si`.`user_id` AS `up_user_id`,`si`.`sound_info_name` AS `sound_info_name`,`si`.`sound_info_pay_type` AS `sound_info_pay_type`,`si`.`sound_info_type` AS `sound_info_type`,`siu`.`sound_info_last_updated_time` AS `sound_info_last_updated_time`,`siu`.`sound_info_duration` AS `sound_info_duration`,`siu`.`sound_info_intro` AS `sound_info_intro`,`siu`.`sound_info_view_count` AS `sound_info_view_count`,`siu`.`sound_info_danmu_count` AS `sound_info_danmu_count`,`siu`.`sound_info_favorite_count` AS `sound_info_favorite_count`,`siu`.`sound_info_point` AS `sound_info_point`,`siu`.`sound_info_review_count` AS `sound_info_review_count`,`siu`.`sound_info_sub_review_count` AS `sound_info_sub_review_count`,`siu`.`sound_info_download` AS `sound_info_download`,`siu`.`sound_info_all_comments_num` AS `sound_info_all_comments_num`,`siu`.`sound_info_all_reviews_num` AS `sound_info_all_reviews_num`,`siu`.`sound_info_forbidden_comment` AS `sound_info_forbidden_comment` from ((`maoer_data_analysis`.`activeuser_drama_info` `adi` left join `maoer`.`sound_info` `si` on((`adi`.`sound_id` = `si`.`sound_id`))) left join (select `a`.`sound_id` AS `sound_id`,`a`.`sound_info_last_updated_time` AS `sound_info_last_updated_time`,`a`.`sound_info_duration` AS `sound_info_duration`,`a`.`sound_info_cover` AS `sound_info_cover`,`a`.`sound_info_intro` AS `sound_info_intro`,`a`.`sound_info_soundurl` AS `sound_info_soundurl`,`a`.`sound_info_soundurl_128k` AS `sound_info_soundurl_128k`,`a`.`sound_info_downtimes` AS `sound_info_downtimes`,`a`.`sound_info_uptimes` AS `sound_info_uptimes`,`a`.`sound_info_view_count` AS `sound_info_view_count`,`a`.`sound_info_danmu_count` AS `sound_info_danmu_count`,`a`.`sound_info_favorite_count` AS `sound_info_favorite_count`,`a`.`sound_info_point` AS `sound_info_point`,`a`.`sound_info_push` AS `sound_info_push`,`a`.`sound_info_refined` AS `sound_info_refined`,`a`.`sound_info_review_count` AS `sound_info_review_count`,`a`.`sound_info_sub_review_count` AS `sound_info_sub_review_count`,`a`.`sound_info_download` AS `sound_info_download`,`a`.`sound_info_front_cover` AS `sound_info_front_cover`,`a`.`sound_info_all_comments_num` AS `sound_info_all_comments_num`,`a`.`sound_info_all_reviews_num` AS `sound_info_all_reviews_num`,`a`.`sound_info_video_url` AS `sound_info_video_url`,`a`.`sound_info_forbidden_comment` AS `sound_info_forbidden_comment`,`a`.`sound_info_mosaic_url` AS `sound_info_mosaic_url`,`a`.`sound_info_breadcrumb` AS `sound_info_breadcrumb`,`a`.`sound_info_subtitle_url` AS `sound_info_subtitle_url`,`a`.`created_time` AS `created_time`,max(`a`.`created_time`) AS `MAX(a.created_time)` from `maoer`.`sound_info_update` `a` group by `a`.`sound_id`) `siu` on((`adi`.`sound_id` = `siu`.`sound_id`)));

-- ----------------------------
-- View structure for activeuser_drama_info
-- ----------------------------
DROP VIEW IF EXISTS `activeuser_drama_info`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `activeuser_drama_info` AS select `asd`.`user_id` AS `user_id`,`asd`.`sound_id` AS `sound_id`,`asd`.`drama_id` AS `drama_id`,`di`.`drama_info_name` AS `drama_info_name`,`di`.`drama_info_alias` AS `drama_info_alias`,`di`.`drama_info_age` AS `drama_info_age`,`di`.`drama_info_author` AS `drama_info_author`,`di`.`drama_info_type` AS `drama_info_type`,`di`.`drama_info_catalog` AS `drama_info_catalog`,`di`.`drama_info_catalog_name` AS `drama_info_catalog_name`,`di`.`organization_id` AS `organization_id`,`di`.`drama_info_style` AS `drama_info_style`,`di`.`drama_info_abstract` AS `drama_info_abstract`,`di`.`drama_info_organization` AS `drama_info_organization`,`diu`.`drama_info_serialize` AS `drama_info_serialize`,`diu`.`drama_info_pay_type` AS `drama_info_pay_type`,`diu`.`drama_info_need_pay` AS `drama_info_need_pay`,`diu`.`drama_info_price` AS `drama_info_price`,`diu`.`drama_info_newest` AS `drama_info_newest`,`diu`.`drama_info_newst_episode_id` AS `drama_info_newst_episode_id`,`diu`.`drama_info_update_period` AS `drama_info_update_period`,`diu`.`drama_info_view_count` AS `drama_info_view_count`,`diu`.`drama_info_all_reward_num` AS `drama_info_all_reward_num`,`diu`.`drama_info_reward_week_rank` AS `drama_info_reward_week_rank` from ((`maoer_data_analysis`.`activeuser_submit_danmu_sound_with_drama` `asd` left join `maoer`.`drama_info` `di` on((`asd`.`drama_id` = `di`.`drama_id`))) left join (select `maoer`.`drama_info_update`.`drama_id` AS `drama_id`,`maoer`.`drama_info_update`.`drama_info_serialize` AS `drama_info_serialize`,`maoer`.`drama_info_update`.`drama_info_pay_type` AS `drama_info_pay_type`,`maoer`.`drama_info_update`.`drama_info_need_pay` AS `drama_info_need_pay`,`maoer`.`drama_info_update`.`drama_info_price` AS `drama_info_price`,`maoer`.`drama_info_update`.`drama_info_newest` AS `drama_info_newest`,`maoer`.`drama_info_update`.`drama_info_newst_episode_id` AS `drama_info_newst_episode_id`,`maoer`.`drama_info_update`.`drama_info_update_period` AS `drama_info_update_period`,`maoer`.`drama_info_update`.`drama_info_view_count` AS `drama_info_view_count`,`maoer`.`drama_info_update`.`drama_info_all_reward_num` AS `drama_info_all_reward_num`,`maoer`.`drama_info_update`.`drama_info_reward_week_rank` AS `drama_info_reward_week_rank`,`maoer`.`drama_info_update`.`created_time` AS `created_time`,max(`maoer`.`drama_info_update`.`created_time`) AS `max(created_time)` from `maoer`.`drama_info_update` group by `maoer`.`drama_info_update`.`drama_id`) `diu` on((`asd`.`drama_id` = `diu`.`drama_id`)));

-- ----------------------------
-- View structure for drama_min_sound_created_time
-- ----------------------------
DROP VIEW IF EXISTS `drama_min_sound_created_time`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `drama_min_sound_created_time` AS select `a`.`drama_id` AS `drama_id`,min(`b`.`sound_info_created_time`) AS `min_sound_info_created_time` from (`maoer`.`drama_episodes` `a` join `maoer`.`sound_info` `b` on((`a`.`sound_id` = `b`.`sound_id`))) group by `a`.`drama_id`;

-- ----------------------------
-- View structure for sound_drama_time_feature
-- ----------------------------
DROP VIEW IF EXISTS `sound_drama_time_feature`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `sound_drama_time_feature` AS select distinct `d`.`sound_id` AS `sound_id`,`c`.`sound_info_created_time` AS `sound_info_created_time`,`c`.`drama_id` AS `drama_id`,`e`.`min_sound_info_created_time` AS `drama_min_sound_time` from ((`maoer_data_analysis`.`sound_feature` `d` join (select `a`.`drama_id` AS `drama_id`,`a`.`sound_id` AS `sound_id`,`b`.`sound_info_created_time` AS `sound_info_created_time` from (`maoer`.`drama_episodes` `a` join `maoer`.`sound_info` `b` on((`a`.`sound_id` = `b`.`sound_id`)))) `c` on((`c`.`sound_id` = `d`.`sound_id`))) join `lingyun_maoer_analysis_time`.`drama_min_sound_created_time` `e` on((`e`.`drama_id` = `c`.`drama_id`)));

SET FOREIGN_KEY_CHECKS = 1;

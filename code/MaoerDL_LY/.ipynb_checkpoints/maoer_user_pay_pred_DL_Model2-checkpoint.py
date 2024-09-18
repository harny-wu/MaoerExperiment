# 修改为对抗学习
# maoer_data深度学习模型 双层注意力机制
import math
import os
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from sklearn.metrics import roc_auc_score
from torch.utils.data import Dataset, DataLoader, TensorDataset


# 划分数据集 给定输出后固定结果 输出形式定为存储user_id 形成train_dataset,val_dataset,test_dataset
def split_data_unique(input_file, output_file, train_ratio, val_ratio, test_ratio):
    df = pd.read_csv(input_file)
    data = df[df.columns[0]].unique()  # 提取第一列数据并去重
    np.random.shuffle(data)  # 随机打乱数据
    # 划分数据
    total_len = len(data)
    x_end = int(total_len * train_ratio)
    y_end = x_end + int(total_len * val_ratio)
    train_data = data[:x_end]
    val_data = data[x_end:y_end]
    test_data = data[y_end:]
    # 存储结果是去重的user_id
    # result = {
    #     'Train': train_data,
    #     'Val': val_data,
    #     'Test': test_data
    # }
    # 创建DataFrame，每个子集一列
    df_subsets = pd.DataFrame({
        'Train': train_data,
        'Val': val_data,
        'Test': test_data
    })
    # 创建每个子集的DataFrame
    train_df = pd.DataFrame(train_data, columns=['Train'])
    val_df = pd.DataFrame(val_data, columns=['Val'])
    test_df = pd.DataFrame(test_data, columns=['Test'])
    # 将每个DataFrame转换为一列Series
    train_series = train_df.iloc[:, 0]
    val_series = val_df.iloc[:, 0]
    test_series = test_df.iloc[:, 0]
    # 为了确保所有Series有相同的长度，我们需要找到最大长度并截断较短的Series
    max_len = max(len(train_series), len(val_series), len(test_series))
    train_series = train_series.reindex(range(max_len)).fillna(value=pd.NA)
    val_series = val_series.reindex(range(max_len)).fillna(value=pd.NA)
    test_series = test_series.reindex(range(max_len)).fillna(value=pd.NA)
    # 创建一个新的DataFrame，将Series作为列
    combined_df = pd.DataFrame({
        'Train': train_series,
        'Val': val_series,
        'Test': test_series
    })
    # 写入CSV文件，不包含索引和列名
    combined_df.to_csv(output_file, index=False)
    print('已输出划分数据集结果')

# 数据预处理 将连续特征变离散特征 分桶 不处理user_id、sound_id、drama_id、time
def data_pre_deal(input_path,continue_feature_list):
    df = pd.read_csv(input_path)
    deal_data_df = [] # 待修改********
    # # 获取离散特征的类别数量，并存储为字典
    # category_counts = {}
    # for column in deal_data_df.columns:
    #     unique_values = deal_data_df[column].nunique()  # 获取列的唯一值数量
    #     category_counts[column] = unique_values
    print('数据预处理结束')
    return df

# 根据划分好的数据集中user_id 找到对应csv文件中对应user_id的所有行数据取出，即包含了历史数据（付费+非付费）+目标数据（最后一次行为）
# def find_data_by_list(user_list, intput_data_df, data_hash):
#     df = intput_data_df
#     # result_list = []
#     # 遍历列表中的值，在CSV文件中找到所有匹配的行数据并加入结果列表
#     for user_id in user_list:
#         result_df = df[df[df.columns[0]] == user_id]
#         # result_list.append(result_df)
#         if user_id in data_hash:
#             data_hash[user_id].update({col: result_df for col in df.columns})  # 使用列名作为键
#         else:
#             data_hash[user_id] = {col: result_df for col in df.columns}
#     #result = pd.concat(result_list)  # 合并所有匹配的行数据
#     return data_hash
def find_data_by_list(user_list, intput_data_df, data_hash):
    # 遍历列表中的值，在DataFrame中找到所有匹配的行数据并加入data_hash
    for user_id in user_list:
        result_df = intput_data_df[intput_data_df[intput_data_df.columns[0]] == user_id]
        data_hash[user_id] = result_df  # 直接存储DataFrame对象
    return data_hash

# 总的特征输入，生成划分后数据集及其输入
def data_input(data_time_windows, path, spilt_outpath, train_ratio, val_ratio, test_ratio, total_continue_feature):
    dataset_path = path  # 待修改********
    dataset_spilt_path = spilt_outpath  # 待修改********
    if os.path.exists(dataset_spilt_path):  # 划分训练、验证、测试集
        print("划分文件已存在，不再进行数据划分")
    else:
        split_data_unique(dataset_path, dataset_spilt_path, train_ratio, val_ratio, test_ratio)
    deal_data_df = data_pre_deal(dataset_path, total_continue_feature)  # 数据预处理
    # 获取离散特征的类别数量，并存储为字典
    feature_category_num_dict = {}
    for column in deal_data_df.columns:
        unique_values_len = deal_data_df[column].nunique()  # 获取列的唯一值数量
        feature_category_num_dict[column] = unique_values_len
    # 读取划分文件的结果
    spilt_data_df = pd.read_csv(dataset_spilt_path)
    # 输出每一列数据为列表
    train_list = spilt_data_df['Train'].tolist()
    val_list = spilt_data_df['Val'].tolist()
    test_list = spilt_data_df['Test'].tolist()
    # 根据划分好的生成以user_id为key的hash（特征集合）将最后一行看做目标数据
    data_hash = {}  # 存成一个hash形式
    find_data_by_list(train_list, deal_data_df, data_hash)
    find_data_by_list(val_list, deal_data_df, data_hash)
    find_data_by_list(test_list, deal_data_df, data_hash)
    return train_list, val_list, test_list, data_hash, feature_category_num_dict

# data input
data_time_windows = '0101_0131'
path = './Dataset/' + data_time_windows + '_user_pay_pred_feature_deal.csv'
dataset_spilt_path = './Dataset/' + data_time_windows + '_user_pay_pred_feature_spilt.csv'
# user feature
# CHONGHE
# ['user_name_len', 'user_name_has_chinese', 'user_intro_len', 'user_intro_has_chinese',
#  'user_intro_has_english', 'user_fish_num', 'user_follower_num', 'user_subscribe_drama_num',
#  'user_submit_danmu_drama_completed_num_now', 'user_submit_danmu_drama_total_view_num',
#  'user_submit_danmu_drama_max_view_num', 'user_submit_danmu_drama_avg_view_num',
#  'user_submit_danmu_drama_total_danmu_num', 'user_submit_danmu_drama_max_danmu_num',
#  'user_submit_danmu_drama_min_danmu_num', 'user_submit_danmu_drama_avg_danmu_num',
#  'user_submit_danmu_drama_min_review_num', 'user_in_sound_submit_danmu_max_len',
#  'user_in_sound_submit_danmu_min_len', 'user_in_sound_submit_danmu_avg_len',
#  'user_in_sound_danmu_around_15s_total_danmu_max_num', 'user_in_sound_danmu_around_15s_total_danmu_min_num',
#  'user_in_sound_danmu_around_15s_total_danmu_avg_num', 'sound_title_len', 'sound_intro_len',
#  'sound_danmu_15s_max_traffic_position_in_sound', 'drama_upuser_submit_sound_avg_danmu_num',
#  'pcm_fftMag_mfcc_sma[5]_maxPos numeric', 'pcm_fftMag_mfcc_sma_de[10]_minPos numeric']
# QOE
# ['user_name_has_english', 'user_in_sound_is_submit_review', 'user_in_sound_submit_review_num',
#  'user_in_sound_submit_danmu_total_len', 'sound_view_num', 'sound_danmu_num', 'sound_review_avg_len',
#  'drama_total_sound_num', 'drama_sound_has_max_cv_num_sound_point_num',
#  'drama_upuser_submit_sound_max_view_num', 'drama_sound_min_time_sound_view_num',
#  'drama_danmu_time_between_sound_time_in_7days_num_min', 'pcm_RMSenergy_sma_range numeric',
#  'pcm_fftMag_mfcc_sma[1]_maxPos numeric', 'pcm_fftMag_mfcc_sma[2]_max numeric',
#  'pcm_fftMag_mfcc_sma[5]_min numeric', 'pcm_fftMag_mfcc_sma[8]_maxPos numeric',
#  'pcm_fftMag_mfcc_sma[10]_max numeric', 'voiceProb_sma_stddev numeric', 'F0_sma_stddev numeric',
#  'pcm_fftMag_mfcc_sma_de[4]_min numeric', 'pcm_fftMag_mfcc_sma_de[6]_maxPos numeric',
#  'pcm_fftMag_mfcc_sma_de[8]_kurtosis numeric',
#  'pcm_fftMag_mfcc_sma_de[9]_min numeric', 'pcm_fftMag_mfcc_sma_de[10]_linregc1 numeric']
# # FUFEI
# [user_submit_danmu_drama_min_view_num, user_submit_danmu_drama_max_review_num,
#  user_submit_danmu_drama_avg_review_num, drama_intro_len,
#  drama_sound_has_min_view_num_sound_favorite_num, drama_upuser_subscriptions_num,
#  drama_sound_max_time_sound_view_num, drama_sound_max_traffic_position_in_sound_avg,
#  drama_sound_min_traffic_position_in_sound_avg, label1, `pcm_fftMag_mfcc_sma[1]_range numeric`,
#  `pcm_fftMag_mfcc_sma[1]_minPos numeric`, `pcm_fftMag_mfcc_sma[2]_min numeric`,
#  `pcm_fftMag_mfcc_sma[2]_skewness numeric`, `pcm_fftMag_mfcc_sma[5]_range numeric`,
#  `pcm_fftMag_mfcc_sma[6]_linregc1 numeric`, `pcm_fftMag_mfcc_sma[11]_kurtosis numeric`,
#  `pcm_RMSenergy_sma_de_minPos numeric`, `pcm_fftMag_mfcc_sma_de[2]_max numeric`,
#  `pcm_fftMag_mfcc_sma_de[4]_st[user_submit_danmu_drama_min_view_num, user_submit_danmu_drama_max_review_num,
# #  user_submit_danmu_drama_avg_review_num, drama_intro_len,
# #  drama_sound_has_min_view_num_sound_favorite_num, drama_upuser_subscriptions_num,
# #  drama_sound_max_time_sound_view_num, drama_sound_max_traffic_position_in_sound_avg,
# #  drama_sound_min_traffic_position_in_sound_avg, label1, `pcm_fftMag_mfcc_sma[1]_range numeric`,
# #  `pcm_fftMag_mfcc_sma[1]_minPos numeric`, `pcm_fftMag_mfcc_sma[2]_min numeric`,
# #  `pcm_fftMag_mfcc_sma[2]_skewness numeric`, `pcm_fftMag_mfcc_sma[5]_range numeric`,
# #  `pcm_fftMag_mfcc_sma[6]_linregc1 numeric`, `pcm_fftMag_mfcc_sma[11]_kurtosis numeric`,
# #  `pcm_RMSenergy_sma_de_minPos numeric`, `pcm_fftMag_mfcc_sma_de[2]_max numeric`,
# #  `pcm_fftMag_mfcc_sma_de[4]_stddev numeric`, `pcm_fftMag_mfcc_sma_de[4]_skewness numeric`,
# #  `pcm_fftMag_mfcc_sma_de[5]_linregc1 numeric`, `pcm_fftMag_mfcc_sma_de[8]_amean numeric`,
# #  `pcm_fftMag_mfcc_sma_de[8]_skewness numeric`, `pcm_fftMag_mfcc_sma_de[9]_max numeric`,
# #  `pcm_fftMag_mfcc_sma_de[10]_linregerrQ numeric`, `pcm_fftMag_mfcc_sma_de[11]_maxPos numeric`,
# #  `voiceProb_sma_de_max numeric`, `F0_sma_de_linregerrQ numeric`]ddev numeric`, `pcm_fftMag_mfcc_sma_de[4]_skewness numeric`,
#  `pcm_fftMag_mfcc_sma_de[5]_linregc1 numeric`, `pcm_fftMag_mfcc_sma_de[8]_amean numeric`,
#  `pcm_fftMag_mfcc_sma_de[8]_skewness numeric`, `pcm_fftMag_mfcc_sma_de[9]_max numeric`,
#  `pcm_fftMag_mfcc_sma_de[10]_linregerrQ numeric`, `pcm_fftMag_mfcc_sma_de[11]_maxPos numeric`,
#  `voiceProb_sma_de_max numeric`, `F0_sma_de_linregerrQ numeric`]
user_feature_continue_column = []
user_feature_discrete_column = []
# user history bav
user_history_pay_QOE_continue_column = ['user_in_sound_submit_review_num','user_in_sound_submit_danmu_total_len','sound_view_num','sound_danmu_num','sound_review_avg_len','drama_total_sound_num','drama_sound_has_max_cv_num_sound_point_num','drama_upuser_submit_sound_max_view_num','drama_sound_min_time_sound_view_num','pcm_RMSenergy_sma_range numeric','pcm_fftMag_mfcc_sma[1]_maxPos numeric','pcm_fftMag_mfcc_sma[2]_max numeric','pcm_fftMag_mfcc_sma[5]_min numeric','pcm_fftMag_mfcc_sma[8]_maxPos numeric','pcm_fftMag_mfcc_sma[10]_max numeric','voiceProb_sma_stddev numeric','F0_sma_stddev numeric','pcm_fftMag_mfcc_sma_de[4]_min numeric','pcm_fftMag_mfcc_sma_de[6]_maxPos numeric','pcm_fftMag_mfcc_sma_de[8]_kurtosis numeric','pcm_fftMag_mfcc_sma_de[9]_min numeric','pcm_fftMag_mfcc_sma_de[10]_linregc1 numeric']
user_history_pay_CHONGHE_continue_column = ['user_name_len','user_intro_len','user_fish_num','user_follower_num','user_subscribe_drama_num','user_submit_danmu_drama_total_view_num','user_submit_danmu_drama_max_view_num','user_submit_danmu_drama_avg_view_num','user_submit_danmu_drama_total_danmu_num','user_submit_danmu_drama_max_danmu_num','user_submit_danmu_drama_min_danmu_num','user_submit_danmu_drama_avg_danmu_num','user_submit_danmu_drama_min_review_num','user_in_sound_submit_danmu_max_len','user_in_sound_submit_danmu_min_len','user_in_sound_submit_danmu_avg_len','user_in_sound_danmu_around_15s_total_danmu_max_num','user_in_sound_danmu_around_15s_total_danmu_min_num','user_in_sound_danmu_around_15s_total_danmu_avg_num','drama_upuser_submit_sound_avg_danmu_num','pcm_fftMag_mfcc_sma[5]_maxPos numeric','pcm_fftMag_mfcc_sma_de[10]_minPos numeric']
user_history_pay_FUFEI_continue_column = ['user_submit_danmu_drama_min_view_num','user_submit_danmu_drama_max_review_num','user_submit_danmu_drama_avg_review_num','drama_sound_has_min_view_num_sound_favorite_num','drama_sound_max_time_sound_view_num','drama_sound_min_traffic_position_in_sound_avg','pcm_fftMag_mfcc_sma[1]_range numeric','pcm_fftMag_mfcc_sma[1]_minPos numeric','pcm_fftMag_mfcc_sma[2]_min numeric','pcm_fftMag_mfcc_sma[2]_skewness numeric','pcm_fftMag_mfcc_sma[5]_range numeric','pcm_fftMag_mfcc_sma[6]_linregc1 numeric','pcm_fftMag_mfcc_sma[11]_kurtosis numeric','pcm_RMSenergy_sma_de_minPos numeric','pcm_fftMag_mfcc_sma_de[2]_max numeric','pcm_fftMag_mfcc_sma_de[4]_stddev numeric','pcm_fftMag_mfcc_sma_de[4]_skewness numeric','pcm_fftMag_mfcc_sma_de[5]_linregc1 numeric','pcm_fftMag_mfcc_sma_de[8]_amean numeric','pcm_fftMag_mfcc_sma_de[8]_skewness numeric','pcm_fftMag_mfcc_sma_de[9]_max numeric','pcm_fftMag_mfcc_sma_de[10]_linregerrQ numeric','pcm_fftMag_mfcc_sma_de[11]_maxPos numeric','voiceProb_sma_de_max numeric','F0_sma_de_linregerrQ numer']
user_history_pay_QOE_discrete_column = ['user_name_has_english','user_in_sound_is_submit_review','drama_danmu_time_between_sound_time_in_7days_num_min']
user_history_pay_CHONGHE_discrete_column = ['user_name_has_chinese','user_intro_has_chinese','user_intro_has_english','user_submit_danmu_drama_completed_num_now','sound_title_len','sound_intro_len','sound_danmu_15s_max_traffic_position_in_sound']
user_history_pay_FUFEI_discrete_column = ['drama_intro_len','drama_upuser_subscriptions_num,drama_sound_max_traffic_position_in_sound_avg,label1']
# total continue feature
total_continue_feature = user_feature_continue_column+user_history_pay_QOE_continue_column+user_history_pay_CHONGHE_continue_column+user_history_pay_FUFEI_continue_column


# 形成对应需要的特征名称列表
feature_column_dict = {
    'user_info_continue': user_feature_continue_column,
    'user_info_discrete': user_feature_discrete_column,
    'history_QOE_continue': user_history_pay_QOE_continue_column,
    'history_QOE_discrete': user_history_pay_QOE_discrete_column,
    'history_CHONGHE_continue': user_history_pay_CHONGHE_continue_column,
    'history_CHONGHE_discrete': user_history_pay_CHONGHE_discrete_column,
    'history_FUFEI_continue': user_history_pay_FUFEI_continue_column,
    'history_FUFEI_discrete': user_history_pay_FUFEI_discrete_column
}


# 参数设置
train_ratio = 0.6
val_ratio = 0.2
test_ratio = 0.2
num_heads = 10
feature_dim = 200
max_history_len = 20
num_experts = 3
num_tasks = 2
# 设置嵌入维度
continue_embedding_dim = 200
discrete_embedding_dim = 200
lr = 0.0001
batch_size = 128


# mask 对用户历史行为长度的固定
# 转换 history 列为长度为max_history_len的数组
def process_history(history, max_history_len):
    if len(history) >= max_history_len:
        processed_history = history[-max_history_len:]
    else:
        processed_history = [-1] * (max_history_len - len(history)) + history
    return processed_history
# 将填充-1的位置标记为True
def create_mask(history):
    mask = [True if item == -1 else False for item in history]
    return mask
# 将历史行为记录处理为固定长度并进行mask
def history_feature_mask(user_history_feature_index, data_matrix_user_history, max_history_len):
    mask_history_feature_matrix = []
    origin_history_feature_matrix = []
    for feature_index in range(len(user_history_feature_index)):
        feature_data = [data_row[feature_index] for data_row in data_matrix_user_history]  # 获取一列特征值
        processed_feature_data = process_history(feature_data, max_history_len)  # 处理为固定长度 max_history_len
        origin_history_feature_matrix.append(processed_feature_data)
        mask_feature_data = create_mask(processed_feature_data)  # 将空的mask
        mask_history_feature_matrix.append(mask_feature_data)
    # print('mask',len(origin_history_feature_matrix),len(origin_history_feature_matrix[0]))
    return origin_history_feature_matrix, mask_history_feature_matrix


# 将输入形成的data_hash和连续、离散特征列名,按照划分的训练或测试的user_id的列表，提取用户特征形成张量矩阵存储到data_tensor_hash中，以user_id为key，多个张量矩阵为value
def get_feature_to_matrix(train_or_val_or_test_list, data_hash, feature_column_dict):
    # 存储新的张量hash
    data_tensor_hash = {}
    # 存储历史记录的掩码矩阵
    data_tensor_history_mask_hash = {}

    for user_id in train_or_val_or_test_list:
        user_data = data_hash[user_id]
        # 创建空的二维矩阵
        # data_matrix_user_info_continue = []
        # data_matrix_user_info_discrete = []
        data_matrix_pay_QOE_continue = []
        data_matrix_pay_QOE_discrete = []
        data_matrix_pay_CHONGHE_continue = []
        data_matrix_pay_CHONGHE_discrete = []
        data_matrix_pay_FUFEI_continue = []
        data_matrix_pay_FUFEI_discrete = []
        data_matrix_target_QOE_continue = []
        data_matrix_target_CHONGHE_continue = []
        data_matrix_target_FUFEI_continue = []
        data_matrix_target_QOE_discrete = []
        data_matrix_target_CHONGHE_discrete = []
        data_matrix_target_FUFEI_discrete = []
        target_label = []  # 预测目标值的标签
        # 提取特征列对应的索引
        # user_feature_continue_index = [user_data.columns.get_loc(col) for col in feature_column_dict['user_info_continue'] if col in user_data.columns]
        # user_feature_discrete_index = [user_data.columns.get_loc(col) for col in feature_column_dict['user_info_discrete'] if
        #                                col in user_data.columns]
        user_history_QOE_continue_index = [user_data.columns.get_loc(col) for col in feature_column_dict['history_QOE_continue'] if
                                       col in user_data.columns]
        user_history_QOE_discrete_index = [user_data.columns.get_loc(col) for col in feature_column_dict['history_QOE_discrete'] if
                                       col in user_data.columns]
        user_history_CHONGHE_continue_index = [user_data.columns.get_loc(col) for col in
                                           feature_column_dict['history_CHONGHE_continue'] if
                                           col in user_data.columns]
        user_history_CHONGHE_discrete_index = [user_data.columns.get_loc(col) for col in
                                           feature_column_dict['history_CHONGHE_discrete'] if
                                           col in user_data.columns]
        user_history_FUFEI_continue_index = [user_data.columns.get_loc(col) for col in
                                           feature_column_dict['history_FUFEI_continue'] if
                                           col in user_data.columns]
        user_history_FUFEI_discrete_index = [user_data.columns.get_loc(col) for col in
                                           feature_column_dict['history_FUFEI_discrete'] if
                                           col in user_data.columns]
        # 填充数据矩阵
        for i in range(len(user_data)):
            if i != len(user_data) - 1:  # 除最后一行即所有历史记录，不包括目标记录
                    data_matrix_pay_QOE_continue.append(
                        [user_data.iloc[i, col] for col in user_history_QOE_continue_index])  # 用户历史QOE连续特征
                    data_matrix_pay_QOE_discrete.append(
                        [user_data.iloc[i, col] for col in user_history_QOE_discrete_index])  # 用户历史QOE离散特征
                    data_matrix_pay_CHONGHE_continue.append(
                        [user_data.iloc[i, col] for col in user_history_CHONGHE_continue_index])  # 用户历史CHONGHE连续特征
                    data_matrix_pay_CHONGHE_discrete.append(
                        [user_data.iloc[i, col] for col in user_history_CHONGHE_discrete_index])  # 用户历史CHONGHE离散特征
                    data_matrix_pay_FUFEI_continue.append(
                        [user_data.iloc[i, col] for col in user_history_FUFEI_continue_index])  # 用户历史FUFEI连续特征
                    data_matrix_pay_FUFEI_discrete.append(
                        [user_data.iloc[i, col] for col in user_history_FUFEI_discrete_index])  # 用户历史FUFEI离散特征
            else:   # 目标记录
                # data_matrix_user_info_continue.append([user_data.iloc[i, col] for col in user_feature_continue_index])  # 用户连续特征
                # data_matrix_user_info_discrete.append([user_data.iloc[i, col] for col in user_feature_discrete_index])  # 用户离散特征
                target_label.append(user_data.iloc[i, -1])  # 预测目标的y值
                data_matrix_target_QOE_continue.append([user_data.iloc[i, col] for col in user_history_QOE_continue_index])  # 目标QOE连续特征
                data_matrix_target_QOE_discrete.append([user_data.iloc[i, col] for col in user_history_QOE_discrete_index])  # 目标QOE离散特征
                data_matrix_target_CHONGHE_continue.append([user_data.iloc[i, col] for col in user_history_CHONGHE_continue_index])  # 目标CHONGHE连续特征
                data_matrix_target_CHONGHE_discrete.append([user_data.iloc[i, col] for col in user_history_CHONGHE_discrete_index])  # 目标CHONGHE离散特征
                data_matrix_target_FUFEI_continue.append([user_data.iloc[i, col] for col in user_history_FUFEI_continue_index])  # 目标FUFEI连续特征
                data_matrix_target_FUFEI_discrete.append([user_data.iloc[i, col] for col in user_history_FUFEI_discrete_index])  # 目标FUFEI离散特征

        # 将历史行为记录处理为固定长度并进行mask
        data_matrix_pay_QOE_continue,data_matrix_pay_QOE_continue_mask = history_feature_mask(user_history_QOE_continue_index, data_matrix_pay_QOE_continue, max_history_len)
        data_matrix_pay_QOE_discrete,data_matrix_pay_QOE_discrete_mask = history_feature_mask(user_history_QOE_discrete_index, data_matrix_pay_QOE_discrete, max_history_len)
        data_matrix_pay_CHONGHE_continue,data_matrix_pay_CHONGHE_continue_mask = history_feature_mask(user_history_CHONGHE_continue_index, data_matrix_pay_CHONGHE_continue,max_history_len)
        data_matrix_pay_CHONGHE_discrete,data_matrix_pay_CHONGHE_discrete_mask = history_feature_mask(user_history_CHONGHE_discrete_index, data_matrix_pay_CHONGHE_discrete,max_history_len)
        data_matrix_pay_FUFEI_continue,data_matrix_pay_FUFEI_continue_mask = history_feature_mask(user_history_FUFEI_continue_index, data_matrix_pay_FUFEI_continue,max_history_len)
        data_matrix_pay_FUFEI_discrete,data_matrix_pay_FUFEI_discrete_mask = history_feature_mask(user_history_FUFEI_discrete_index, data_matrix_pay_FUFEI_discrete,max_history_len)
        # 将numpy数组转换为PyTorch张量
        # history
        data_tensor_pay_QOE_continue = torch.tensor(np.array(data_matrix_pay_QOE_continue), dtype=torch.float32)
        data_tensor_pay_QOE_discrete = torch.tensor(np.array(data_matrix_pay_QOE_discrete), dtype=torch.float32)
        data_tensor_pay_CHONGHE_continue = torch.tensor(np.array(data_matrix_pay_CHONGHE_continue), dtype=torch.float32)
        data_tensor_pay_CHONGHE_discrete = torch.tensor(np.array(data_matrix_pay_CHONGHE_discrete), dtype=torch.float32)
        data_tensor_pay_FUFEI_continue = torch.tensor(np.array(data_matrix_pay_FUFEI_continue), dtype=torch.float32)
        data_tensor_pay_FUFEI_discrete = torch.tensor(np.array(data_matrix_pay_FUFEI_discrete), dtype=torch.float32)
        #  mask矩阵
        data_tensor_pay_QOE_continue_mask = torch.tensor(np.array(data_matrix_pay_QOE_continue_mask), dtype=torch.float32)
        data_tensor_pay_QOE_discrete_mask = torch.tensor(np.array(data_matrix_pay_QOE_discrete_mask), dtype=torch.float32)
        data_tensor_pay_CHONGHE_continue_mask = torch.tensor(np.array(data_matrix_pay_CHONGHE_continue_mask), dtype=torch.float32)
        data_tensor_pay_CHONGHE_discrete_mask = torch.tensor(np.array(data_matrix_pay_CHONGHE_discrete_mask), dtype=torch.float32)
        data_tensor_pay_FUFEI_continue_mask = torch.tensor(np.array(data_matrix_pay_FUFEI_continue_mask), dtype=torch.float32)
        data_tensor_pay_FUFEI_discrete_mask = torch.tensor(np.array(data_matrix_pay_FUFEI_discrete_mask), dtype=torch.float32)
        # user + target
        # data_tensor_user_info_continue = torch.tensor(np.array(data_matrix_user_info_continue), dtype=torch.float32)
        # data_tensor_user_info_discrete = torch.tensor(np.array(data_matrix_user_info_discrete), dtype=torch.float32)
        data_tensor_target_QOE_continue = torch.tensor(np.array(data_matrix_target_QOE_continue), dtype=torch.float32)
        data_tensor_target_QOE_discrete = torch.tensor(np.array(data_matrix_target_QOE_discrete), dtype=torch.float32)
        data_tensor_target_CHONGHE_continue = torch.tensor(np.array(data_matrix_target_CHONGHE_continue),dtype=torch.float32)
        data_tensor_target_CHONGHE_discrete = torch.tensor(np.array(data_matrix_target_CHONGHE_discrete),dtype=torch.float32)
        data_tensor_target_FUFEI_continue = torch.tensor(np.array(data_matrix_target_FUFEI_continue), dtype=torch.float32)
        data_tensor_target_FUFEI_discrete = torch.tensor(np.array(data_matrix_target_FUFEI_discrete), dtype=torch.float32)

        # 生成hash值，按user_id为key存储成hash
        tensor_hash_value = {
            'pay_QOE_continue': data_tensor_pay_QOE_continue,
            'pay_QOE_discrete': data_tensor_pay_QOE_discrete,
            'pay_CHONGHE_continue': data_tensor_pay_CHONGHE_continue,
            'pay_CHONGHE_discrete': data_tensor_pay_CHONGHE_discrete,
            'pay_FUFEI_continue': data_tensor_pay_FUFEI_continue,
            'pay_FUFEI_discrete': data_tensor_pay_FUFEI_discrete,
            'target_QOE_continue': data_tensor_target_QOE_continue,
            'target_QOE_discrete': data_tensor_target_QOE_discrete,
            'target_CHONGHE_continue': data_tensor_target_CHONGHE_continue,
            'target_CHONGHE_discrete': data_tensor_target_CHONGHE_discrete,
            'target_FUFEI_continue': data_tensor_target_FUFEI_continue,
            'target_FUFEI_discrete': data_tensor_target_FUFEI_discrete
        }
        tensor_hash_value_history_mask = {
            'pay_QOE_continue': data_tensor_pay_QOE_continue_mask,
            'pay_QOE_discrete': data_tensor_pay_QOE_discrete_mask,
            'pay_CHONGHE_continue': data_tensor_pay_CHONGHE_continue_mask,
            'pay_CHONGHE_discrete': data_tensor_pay_CHONGHE_discrete_mask,
            'pay_FUFEI_continue': data_tensor_pay_FUFEI_continue_mask,
            'pay_FUFEI_discrete': data_tensor_pay_FUFEI_discrete_mask,
        }
        if user_id in data_tensor_hash:
            data_tensor_hash[user_id].update(tensor_hash_value)
            data_tensor_history_mask_hash[user_id].update(tensor_hash_value_history_mask)
        else:
            data_tensor_hash[user_id] = tensor_hash_value
            data_tensor_history_mask_hash[user_id] = tensor_hash_value_history_mask

    # 如果需要合并成一个张量，可以使用torch.cat方法
    # combined_tensor = torch.cat((data_matrix_1_tensor, data_matrix_2_tensor), dim=1)
    return data_tensor_hash, target_label, tensor_hash_value_history_mask

# 张量矩阵添加一个batch维度，并在用户特征与目标特征的张量中再添加一维使其与用户历史行为张量对齐， 形成两种：
# 原数据为：1.用户特征与目标特征都为：（feature_num）; 2.用户历史行为特征为（max_history_len(固定长度的历史记录数),feature_num）
# 新数据为：1.用户特征与目标特征都为：（batch,1,feature_num; 2.用户历史行为特征为（batch,max_history_len(固定长度的历史记录数),feature_num）
# 形成batch维度的特征
def generate_batch_feature(data_tensor_hash, feature_category):  # 例:feature_category = 'user_info_continue' 就是上面生成的tensor_hash_value字典的键
    tensor_list = []
    for key in data_tensor_hash.keys():  # 遍历data_tensor_hash的所有key (user_id)
        if feature_category in data_tensor_hash[key]:
            tensor = data_tensor_hash[key][feature_category]  # 获取feature_category对应的张量
            tensor_list.append(tensor)  # 添加到tensor_list中
    batch_feature_tensor = torch.stack(tensor_list, dim=0)  # 在第一个维度上合并所有张量(其实相当于生成一个新维度)
    return batch_feature_tensor
# 生成batch再添加维度对齐张量（三个维度）
def generate_user_feature_alignment_tensor(data_tensor_hash):
    # 用户历史行为矩阵（max_history_len(固定长度的历史记录数),feature_num）->（batch,max_history_len(固定长度的历史记录数),feature_num）
    pay_QOE_continue_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'pay_QOE_continue')
    pay_QOE_discrete_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'pay_QOE_discrete')
    pay_CHONGHE_continue_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'pay_CHONGHE_continue')
    pay_CHONGHE_discrete_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'pay_CHONGHE_discrete')
    pay_FUFEI_continue_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'pay_FUFEI_continue')
    pay_FUFEI_discrete_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'pay_FUFEI_discrete')
    # 看是否是掩码矩阵，不是则xxx，是则没有user+target
    if 'target_QOE_continue' in data_tensor_hash:
        # 用户矩阵 (feature_num) ->(batch,feature_num)
        # user_info_continue_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'user_info_continue')
        # user_info_discrete_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'user_info_discrete')
        # 目标矩阵 (feature_num) ->(batch,feature_num)
        target_QOE_continue_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'target_QOE_continue')
        target_QOE_discrete_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'target_QOE_discrete')
        target_CHONGHE_continue_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'target_CHONGHE_continue')
        target_CHONGHE_discrete_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'target_CHONGHE_discrete')
        target_FUFEI_continue_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'target_FUFEI_continue')
        target_FUFEI_discrete_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'target_FUFEI_discrete')

        # 假设原始张量矩阵为 tensor，形状为 (batch_size, feature_num)将其加一个维度变为 (batch_size, 1, feature_num)
        # user_info_continue_batch_feature_tensor = torch.unsqueeze(user_info_continue_batch_feature_tensor, dim=1)
        # user_info_discrete_batch_feature_tensor = torch.unsqueeze(user_info_discrete_batch_feature_tensor, dim=1)
        target_QOE_continue_batch_feature_tensor = torch.unsqueeze(target_QOE_continue_batch_feature_tensor, dim=1)
        target_QOE_discrete_batch_feature_tensor = torch.unsqueeze(target_QOE_discrete_batch_feature_tensor, dim=1)
        target_CHONGHE_continue_batch_feature_tensor = torch.unsqueeze(target_CHONGHE_continue_batch_feature_tensor, dim=1)
        target_CHONGHE_discrete_batch_feature_tensor = torch.unsqueeze(target_CHONGHE_discrete_batch_feature_tensor, dim=1)
        target_FUFEI_continue_batch_feature_tensor = torch.unsqueeze(target_FUFEI_continue_batch_feature_tensor, dim=1)
        target_FUFEI_discrete_batch_feature_tensor = torch.unsqueeze(target_FUFEI_discrete_batch_feature_tensor, dim=1)

        batch_feature_tensor_dict = {
            'pay_QOE_continue': pay_QOE_continue_batch_feature_tensor,
            'pay_QOE_discrete': pay_QOE_discrete_batch_feature_tensor,
            'pay_CHONGHE_continue': pay_CHONGHE_continue_batch_feature_tensor,
            'pay_CHONGHE_discrete': pay_CHONGHE_discrete_batch_feature_tensor,
            'pay_FUFEI_continue': pay_FUFEI_continue_batch_feature_tensor,
            'pay_FUFEI_discrete': pay_FUFEI_discrete_batch_feature_tensor,
            'target_QOE_continue': target_QOE_continue_batch_feature_tensor,
            'target_QOE_discrete': target_QOE_discrete_batch_feature_tensor,
            'target_CHONGHE_continue': target_CHONGHE_continue_batch_feature_tensor,
            'target_CHONGHE_discrete': target_CHONGHE_discrete_batch_feature_tensor,
            'target_FUFEI_continue': target_FUFEI_continue_batch_feature_tensor,
            'target_FUFEI_discrete': target_FUFEI_discrete_batch_feature_tensor
        }
    else:
        batch_feature_tensor_dict = {
            'pay_QOE_continue': pay_QOE_continue_batch_feature_tensor,
            'pay_QOE_discrete': pay_QOE_discrete_batch_feature_tensor,
            'pay_CHONGHE_continue': pay_CHONGHE_continue_batch_feature_tensor,
            'pay_CHONGHE_discrete': pay_CHONGHE_discrete_batch_feature_tensor,
            'pay_FUFEI_continue': pay_FUFEI_continue_batch_feature_tensor,
            'pay_FUFEI_discrete': pay_FUFEI_discrete_batch_feature_tensor,
        }
    return batch_feature_tensor_dict  # 这里张量输出的全是三维 (batch_size, 1 or max_history_len, feature_num)


# 构建离散特征的embedding
def discrete_embedding(feature_category_num_dict, feature_column_name_list, embedding_dim): # 输入特征数,特征取值大小的集合,维度
    # 创建一个列表来存储每个嵌入层
    embeddings = []
    for i in range(0, len(feature_column_name_list)):
        embedding_layer1 = nn.Embedding(feature_category_num_dict[feature_column_name_list[i]], embedding_dim)
        embeddings.append(embedding_layer1)
    return embeddings

# 全连接层 MLP
def dense_layer(in_features, out_features):
    # in_features=hidden_size,out_features=1
    return nn.Sequential(
        nn.Linear(in_features, out_features, bias=True),
        nn.ReLU())

# 根据全特征数量表及类别，得到类别下的对应特征数量  feature_column_name_list = feature_column_dict['user_info_continue']
def category_feature_num(feature_category_num_dict, feature_column_name_list):
    category_feature_num_list = []
    for i in range(0, len(feature_column_name_list)):
        category_feature_num_list.append(feature_category_num_dict[feature_column_name_list[i]])
    return category_feature_num_list

# SE 通道注意力机制
# class SELayer(nn.Module):
#     def __init__(self, in_channel, reduction=16):
#         super(SELayer, self).__init__()
#         self.pool = nn.AdaptiveAvgPool2d(output_size=1)
#         self.fc = nn.Sequential(
#             nn.Linear(in_features=in_channel, out_features=in_channel//reduction, bias=False),
#             nn.ReLU(),
#             nn.Linear(in_features=in_channel//reduction, out_features=in_channel, bias=False),
#             nn.Sigmoid()
#         )
#
#     def forward(self, x):
#         b, c, _, _ = x.size()
#         y = self.avg_pool(x).view(b, c)
#         y = self.fc(y).view(b, c, 1, 1)
#         return x * y.expand_as(x)
class SELayer(nn.Module):
    def __init__(self, feature_dim, feature_num, reduction=16):
        super(SELayer, self).__init__()
        self.pool = nn.AdaptiveAvgPool2d(1)
        self.fc = nn.Sequential(
            nn.Linear(in_features=feature_dim, out_features=feature_dim // reduction, bias=False),
            nn.ReLU(inplace=True),
            nn.Linear(in_features=feature_dim // reduction, out_features=feature_num, bias=False),
            nn.Sigmoid()
        )

    def forward(self, x):
        # Apply average pooling along the feature_dim dimension  x(batch, feature_dim, feature_num)
        b, c, h, w = x.size()
        y = self.pool(x).view(b, c, -1)  # (batch, feature_dim, 1, 1)
        # Generate attention weights for each feature
        attention_weights = self.fc(y).view(b, h * w, -1)  # 权重batch, 1, 1, feature_num)
        # Apply attention weights to the original input
        weighted_x = x.view(b, c, -1) * attention_weights
        # 输出的是一个形状为(batch, feature_dim, 1, feature_num)的张量。
        # 这个张量是对原始输入x进行加权后的结果，其中每个特征都被相应的注意力权重所乘。
        weighted_x = weighted_x.view(b, c, h, w)

        # Sum over the feature_num dimension to get (batch, feature_dim, 1)
        # weighted_sum = torch.sum(weighted_x, dim=2, keepdim=True)的具体意思是沿着feature_num维度
        # （即第三个维度，索引为2）对weighted_x进行求和。由于keepdim=True，求和后的结果保持了一个额外的维度，
        # 形状为(batch, feature_dim, 1)。这一步实现了对每个样本的所有特征进行加权求和，得到一个新的特征表示。
        weighted_sum = torch.sum(weighted_x, dim=2, keepdim=True)
        # 转置最后两维
        weighted_sum = torch.transpose(weighted_sum, -2, -1)

        return attention_weights, weighted_sum, weighted_x
    # 多头自注意力
class MultiHeadSelfAttention(nn.Module):
    def __init__(self, num_heads, feature_dim):
        super(MultiHeadSelfAttention, self).__init__()
        self.num_heads = num_heads
        self.feature_dim = feature_dim
        self.head_dim = feature_dim // num_heads

        # 线性变换的权重
        self.wq = nn.Parameter(torch.Tensor(feature_dim, self.num_heads * self.head_dim))
        self.wk = nn.Parameter(torch.Tensor(feature_dim, self.num_heads * self.head_dim))
        self.wv = nn.Parameter(torch.Tensor(feature_dim, self.num_heads * self.head_dim))

        # 初始化权重
        nn.init.normal_(self.wq, std=0.02)
        nn.init.normal_(self.wk, std=0.02)
        nn.init.normal_(self.wv, std=0.02)

    def forward(self, history_embedding_vec, mask=None):
        batch_size, history_len, feature_num, feature_dim = history_embedding_vec.size()
        # 将feature_num和batch_size合并
        x = history_embedding_vec.view(batch_size * feature_num, history_len, feature_dim)
        # 线性变换
        q = torch.matmul(x, self.wq).view(batch_size * feature_num, history_len, self.num_heads,self.head_dim).transpose(1, 2)
        k = torch.matmul(x, self.wk).view(batch_size * feature_num, history_len, self.num_heads,self.head_dim).transpose(1, 2)
        v = torch.matmul(x, self.wv).view(batch_size * feature_num, history_len, self.num_heads,self.head_dim).transpose(1, 2)
        # 缩放点积注意力
        scores = torch.matmul(q, k.transpose(-1, -2)) / torch.sqrt(torch.tensor(self.head_dim, dtype=torch.float32))
        if mask is not None:
            scores = scores.masked_fill(mask.unsqueeze(1).unsqueeze(2), float('-inf'))
        attention_weights = nn.Softmax(dim=-1)(scores)
        out = torch.matmul(attention_weights, v).transpose(1, 2).contiguous().view(batch_size, feature_num, history_len,self.num_heads * self.head_dim)
        # 合并多头
        out = torch.matmul(out, self.wq.view(self.num_heads * self.head_dim, feature_dim)).view(batch_size, feature_num,history_len,feature_dim)
        # 恢复到原始形状
        out = out.view(batch_size, feature_num, history_len, feature_dim)
        return attention_weights, out

# 注意力机制 关于用
class MultiHeadHistory_TargetAttention(nn.Module):
    def __init__(self, num_heads, feature_dim):
        super(MultiHeadHistory_TargetAttention, self).__init__()
        self.feature_dim = feature_dim
        self.num_heads = num_heads
        self.head_dim = feature_dim // num_heads

        assert (
                self.head_dim * num_heads == feature_dim
        ), "Embedding dimension must be divisible by num_heads."

        self.values = nn.Linear(self.head_dim, self.head_dim, bias=False)
        self.keys = nn.Linear(self.head_dim, self.head_dim, bias=False)
        self.queries = nn.Linear(self.head_dim, self.head_dim, bias=False)
        # 其他部分保持不变

    def forward(self, student_embeddings, unit_embeddings, mask=None):
        batch_size = student_embeddings.size(0)

        # Split the embedding into self.num_heads different pieces
        student_values = student_embeddings.view(batch_size, -1, self.num_heads, self.head_dim)
        student_keys = student_embeddings.view(batch_size, -1, self.num_heads, self.head_dim)
        student_queries = student_embeddings.view(batch_size, -1, self.num_heads, self.head_dim)

        unit_values = unit_embeddings.view(batch_size, -1, self.num_heads, self.head_dim)
        unit_keys = unit_embeddings.view(batch_size, -1, self.num_heads, self.head_dim)

        # Compute the attention weights
        energy = torch.matmul(student_queries, unit_keys.transpose(-2, -1)) / torch.sqrt(
            torch.tensor(self.head_dim, dtype=torch.float32))
        if mask is not None:
            scores = energy.masked_fill(mask.unsqueeze(1).unsqueeze(2), float('-inf'))
        attention_weights = torch.softmax(energy, dim=-1)

        # Apply attention weights to the values
        out = torch.matmul(attention_weights, unit_values)

        # Concatenate the outputs of the different heads
        out = out.view(batch_size, -1, self.num_heads * self.head_dim)

        # Finally, apply a linear layer to get the final output
        out = self.values(out)

        return attention_weights, out

# Embedding
# user_info_feature
class UserInfoEmbedding(nn.Module):
    def __init__(self, continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict):
        super(UserInfoEmbedding, self).__init__()
        self.feature_category_num_dict = feature_category_num_dict
        # 离散embedding
        self.user_info_discrete_embeddings = discrete_embedding(self.feature_category_num_dict, feature_column_dict['user_info_discrete'],
                                                                discrete_embedding_dim)
        # MLP  连续embedding
        self.user_info_continue_dense_layer = dense_layer(feature_category_num_dict['user_info_continue'].shape[2], continue_embedding_dim)

    def forward(self, batch_feature_tensor_dict):
        # user_info Embedding
        # user_info_continue_features_embedding (batch, 1, continue_feature_num, continue_embedding_dim)
        # user_info_discrete_features_embedding (batch, 1, discrete_feature_num, discrete_embedding_dim)
        # concate -> (batch, 1, user_info_feature_num, embedding_dim)
        # 注：torch.stack(...,dim=-1)和torch.cat(...,dim=-1)不一样 前者是堆叠，引入一个新维度，后者是拼接，直接在已有的最后一维上拓展大小
        user_info_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_dict['user_info_discrete'][:, :, i]) for i, embedding_layer in
             enumerate(self.user_info_discrete_embeddings)], dim=-2)
        user_info_continue_features_embedding = torch.stack(self.user_info_continue_dense_layer(
            batch_feature_tensor_dict['user_info_continue']), dim=-2)
        user_info_vec = torch.cat(
            [user_info_discrete_features_embedding, user_info_continue_features_embedding], dim=2) # 特征级合并
        return user_info_vec

# user_history_feature 对于一个user的多个历史行为，将其拼接成一维向量 要先经过一层通道注意力机制得到最后结果
# (样本数,history,20,200) ->多头 ->(样本数,20,200)->转置->(样本数,200,20) ->SE->特征权重->(样本数,200,20) ->转置-> 加权->(样本数,1，200)
# user_pay_history_feature 加上batch的
# 用户历史
class UserPayHistoryEmbedding(nn.Module):
    def __init__(self, continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict):
        super(UserPayHistoryEmbedding, self).__init__()
        # 连续特征
        # 离散特征
        self.feature_category_num_dict = feature_category_num_dict
        # 离散embedding
        self.user_pay_history_QOE_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                feature_column_dict['history_QOE_discrete'],
                                                                discrete_embedding_dim)
        self.user_pay_history_CHONGHE_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                           feature_column_dict['history_CHONGHE_discrete'],
                                                                           discrete_embedding_dim)
        self.user_pay_history_FUFEI_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                           feature_column_dict['history_FUFEI_discrete'],
                                                                           discrete_embedding_dim)
        # MLP  连续embedding
        self.user_pay_history_QOE_continue_dense_layer = dense_layer(feature_category_num_dict['history_QOE_continue'].shape[2], continue_embedding_dim)
        self.user_pay_history_CHONGHE_continue_dense_layer = dense_layer(feature_category_num_dict['history_CHONGHE_continue'].shape[2], continue_embedding_dim)
        self.user_pay_history_FUFEI_continue_dense_layer = dense_layer(feature_category_num_dict['history_FUFEI_continue'].shape[2], continue_embedding_dim)

    def forward(self, batch_feature_tensor_dict):
        # user_history Embedding
        # user_history_continue_features_embedding 得到(batch, 1, continue_feature_num, continue_embedding_dim)
        # user_history_discrete_features_embedding 得到(batch, 1, discrete_feature_num, discrete_embedding_dim)
        # history中有三种：QOE/CHONGHE/FUFEI,将其分别转化为embedding然后合并
        user_history_pay_QOE_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_dict['pay_QOE_discrete'][:, :, i]) for i, embedding_layer in
             enumerate(self.user_pay_history_QOE_discrete_embeddings)], dim=-2)
        user_history_pay_QOE_continue_column_discrete_features_embedding = torch.stack(self.user_pay_history_QOE_continue_dense_layer(
            batch_feature_tensor_dict['pay_QOE_continue']), dim=-2)
        user_history_pay_QOE_vec = torch.cat(
            [user_history_pay_QOE_discrete_column_discrete_features_embedding, user_history_pay_QOE_continue_column_discrete_features_embedding], dim=2)  # 特征级合并
        user_history_pay_CHONGHE_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_dict['pay_CHONGHE_discrete'][:, :, i]) for i, embedding_layer in
             enumerate(self.user_pay_history_CHONGHE_discrete_embeddings)], dim=-2)
        user_history_pay_CHONGHE_continue_column_discrete_features_embedding = torch.stack(
            self.user_pay_history_CHONGHE_continue_dense_layer(
                batch_feature_tensor_dict['pay_CHONGHE_continue']), dim=-2)
        user_history_pay_CHONGHE_vec = torch.cat(
            [user_history_pay_CHONGHE_discrete_column_discrete_features_embedding,
             user_history_pay_CHONGHE_continue_column_discrete_features_embedding], dim=2)  # 特征级合并
        user_history_pay_FUFEI_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_dict['pay_FUFEI_discrete'][:, :, i]) for i, embedding_layer in
             enumerate(self.user_pay_history_FUFEI_discrete_embeddings)], dim=-2)
        user_history_pay_FUFEI_continue_column_discrete_features_embedding = torch.stack(
            self.user_pay_history_FUFEI_continue_dense_layer(
                batch_feature_tensor_dict['pay_FUFEI_continue']), dim=-2)
        user_history_pay_FUFEI_vec = torch.cat(
            [user_history_pay_FUFEI_discrete_column_discrete_features_embedding,
             user_history_pay_FUFEI_continue_column_discrete_features_embedding], dim=2)  # 特征级合并

        return user_history_pay_QOE_vec, user_history_pay_CHONGHE_vec, user_history_pay_FUFEI_vec

# target_feature
class TargetEmbedding(nn.Module):
    def __init__(self, continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict):
        super(TargetEmbedding, self).__init__()
        # 连续特征  与付费、非付费共享一套特征
        # 离散特征  与付费、非付费共享一套特征
        self.feature_category_num_dict = feature_category_num_dict
        # 离散embedding
        self.target_QOE_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,feature_column_dict['history_QOE_discrete'],discrete_embedding_dim)
        self.target_CHONGHE_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,feature_column_dict['history_CHONGHE_discrete'],discrete_embedding_dim)
        self.target_FUFEI_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,feature_column_dict['history_FUFEI_discrete'],discrete_embedding_dim)
        # MLP  连续embedding
        self.target_QOE_continue_dense_layer = dense_layer(feature_category_num_dict['history_QOE_continue'].shape[2], continue_embedding_dim)
        self.target_CHONGHE_continue_dense_layer = dense_layer(feature_category_num_dict['history_CHONGHE_continue'].shape[2], continue_embedding_dim)
        self.target_FUFEI_continue_dense_layer = dense_layer(feature_category_num_dict['history_FUFEI_continue'].shape[2], continue_embedding_dim)

    def forward(self, batch_feature_tensor_dict):
        # target Embedding
        # target_continue_features_embedding 得到(batch, 1, continue_feature_num, continue_embedding_dim)
        # target_discrete_features_embedding 得到(batch, 1, discrete_feature_num, discrete_embedding_dim)
        # 有三种：QOE/CHONGHE/FUFEI,将其分别转化为embedding然后合并
        target_QOE_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_dict['target_QOE_discrete'][:, :, i]) for i, embedding_layer in
             enumerate(self.target_QOE_discrete_embeddings)], dim=-2)
        target_QOE_continue_column_discrete_features_embedding = torch.stack(self.target_QOE_continue_dense_layer(
            batch_feature_tensor_dict['target_QOE_continue']), dim=-2)
        target_QOE_vec = torch.cat(
            [target_QOE_discrete_column_discrete_features_embedding, target_QOE_continue_column_discrete_features_embedding], dim=2)  # 特征级合并
        target_CHONGHE_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_dict['target_CHONGHE_discrete'][:, :, i]) for i, embedding_layer in
             enumerate(self.target_CHONGHE_discrete_embeddings)], dim=-2)
        target_CHONGHE_continue_column_discrete_features_embedding = torch.stack(
            self.target_CHONGHE_continue_dense_layer(
                batch_feature_tensor_dict['target_CHONGHE_continue']), dim=-2)
        target_CHONGHE_vec = torch.cat(
            [target_CHONGHE_discrete_column_discrete_features_embedding,
             target_CHONGHE_continue_column_discrete_features_embedding], dim=2)  # 特征级合并
        target_FUFEI_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_dict['target_FUFEI_discrete'][:, :, i]) for i, embedding_layer in
             enumerate(self.target_FUFEI_discrete_embeddings)], dim=-2)
        target_FUFEI_continue_column_discrete_features_embedding = torch.stack(
            self.target_FUFEI_continue_dense_layer(
                batch_feature_tensor_dict['target_FUFEI_continue']), dim=-2)
        target_FUFEI_vec = torch.cat(
            [target_FUFEI_discrete_column_discrete_features_embedding,
             target_FUFEI_continue_column_discrete_features_embedding], dim=2)  # 特征级合并

        return target_QOE_vec, target_CHONGHE_vec, target_FUFEI_vec

# 用户历史embedding 多头+SE  (batch, history, feature_num, feature_dim)->(batch, 1，feature_dim)
class HistoryDimScalingLayer(nn.Module):
    def __init__(self, num_heads, feature_dim, feature_category_num_dict, max_history_len):
        super(HistoryDimScalingLayer, self).__init__()
        # 多头注意力
        self.multi_head_attention = MultiHeadSelfAttention(num_heads, feature_dim, max_history_len)
        # SE注意力
        self.se_attention_QOE = SELayer(feature_dim, len(feature_category_num_dict['history_QOE_continue'])+len(feature_category_num_dict['history_QOE_discrete']))
        self.se_attention_CHONGHE = SELayer(feature_dim, len(feature_category_num_dict['history_CHONGHE_continue']) + len(feature_category_num_dict['history_CHONGHE_discrete']))
        self.se_attention_FUFEI = SELayer(feature_dim, len(feature_category_num_dict['history_FUFEI_continue']) + len(feature_category_num_dict['history_FUFEI_discrete']))

    def forward(self, user_history_QOE_vec,  user_history_CHONGHE_vec, user_history_FUFEI_vec, mask=None):
        # (batch, history, feature_num, feature_dim) ->多头 ->(batch, feature_num, feature_dim)->转置->(batch, feature_dim, feature_num) ->SE->特征权重->(batch, feature_dim, feature_num) ->转置-> 加权->(batch, 1，feature_dim)
        # 多头注意力  例(batch, history, 20, 200) ->多头 ->(batch, 20, 200)
        mutli_QOE_weight, multi_user_history_QOE_vec = self.multi_head_attention(user_history_QOE_vec, mask)
        mutli_CHONGHE_weight, multi_user_history_CHONGHE_vec = self.multi_head_attention(user_history_CHONGHE_vec, mask)
        mutli_FUFEI_weight, multi_user_history_FUFEI_vec = self.multi_head_attention(user_history_FUFEI_vec, mask)

        # 转置 交换最后两个维度 (20 和 200)
        multi_user_history_QOE_vec = torch.transpose(multi_user_history_QOE_vec, 1, 2)
        multi_user_history_CHONGHE_vec = torch.transpose(multi_user_history_CHONGHE_vec, 1, 2)
        multi_user_history_FUFEI_vec = torch.transpose(multi_user_history_FUFEI_vec, 1, 2)

        # SE注意力  (batch, feature_dim, feature_num) ->SE->特征权重->(batch, feature_dim, feature_num)->转置-> 加权->(batch, 1，feature_dim)
        se_QOE_weight, se_user_history_QOE_vec, se_user_history_QOE_vec_origin = self.se_attention_QOE(multi_user_history_QOE_vec)
        se_CHONGHE_weight, se_user_history_CHONGHE_vec, se_user_history_CHONGHE_vec_origin = self.se_attention_CHONGHE(multi_user_history_CHONGHE_vec)
        se_FUFEI_weight, se_user_history_FUFEI_vec, se_user_history_FUFEI_vec_origin = self.se_attention_FUFEI(multi_user_history_FUFEI_vec)

        HistoryDimScaling_Weight_Result = {
            'mutli_QOE_weight': mutli_QOE_weight,
            'mutli_CHONGHE_weight': mutli_CHONGHE_weight,
            'mutli_FUFEI_weight': mutli_FUFEI_weight,
            'se_QOE_weight': se_QOE_weight,
            'se_CHONGHE_weight': se_CHONGHE_weight,
            'se_FUFEI_weight': se_FUFEI_weight
        }
        return HistoryDimScaling_Weight_Result, se_user_history_QOE_vec, se_user_history_CHONGHE_vec, se_user_history_FUFEI_vec

# 目标产品embedding SE  (batch, 1, feature_num, feature_dim)->(batch, 1，feature_dim)
class TargetDimScalingLayer(nn.Module):
    def __init__(self, feature_dim, feature_category_num_dict):
        super(TargetDimScalingLayer, self).__init__()
        # SE注意力
        self.se_attention_QOE = SELayer(feature_dim, len(feature_category_num_dict['target_QOE_continue'])+len(feature_category_num_dict['target_QOE_discrete']))
        self.se_attention_CHONGHE = SELayer(feature_dim, len(feature_category_num_dict['target_CHONGHE_continue']) + len(feature_category_num_dict['target_CHONGHE_discrete']))
        self.se_attention_FUFEI = SELayer(feature_dim, len(feature_category_num_dict['target_FUFEI_continue']) + len(feature_category_num_dict['target_FUFEI_discrete']))

    def forward(self, target_QOE_vec,  target_CHONGHE_vec, target_FUFEI_vec, mask=None):
        # (batch, 1, feature_num, feature_dim) (batch, feature_num, feature_dim)->转置->(batch, feature_dim, feature_num) ->SE->特征权重->(batch, feature_dim, feature_num) ->转置-> 加权->(batch, 1，feature_dim)
        target_QOE_vec = target_QOE_vec.squeeze(1)  # 使用 squeeze 函数移除大小为 1 的维度
        target_CHONGHE_vec = target_CHONGHE_vec.squeeze(1)  # 使用 squeeze 函数移除大小为 1 的维度
        target_FUFEI_vec = target_FUFEI_vec.squeeze(1)  # 使用 squeeze 函数移除大小为 1 的维度
        # 转置 交换最后两个维度 (20 和 200)
        target_QOE_vec = torch.transpose(target_QOE_vec, -2, -1)
        target_CHONGHE_vec = torch.transpose(target_CHONGHE_vec, -2, -1)
        target_FUFEI_vec = torch.transpose(target_FUFEI_vec, -2, -1)

        # SE注意力  (batch, feature_dim, feature_num) ->SE->特征权重->(batch, feature_dim, feature_num)->转置-> 加权->(batch, 1，feature_dim)
        # 结果为权重，合并后向量，合并前向量
        se_QOE_weight, se_target_QOE_vec, se_target_QOE_vec_origin = self.se_attention_QOE(target_QOE_vec)
        se_CHONGHE_weight, se_target_CHONGHE_vec, se_target_CHONGHE_vec_origin = self.se_attention_CHONGHE(target_CHONGHE_vec)
        se_FUFEI_weight, se_target_FUFEI_vec, se_target_FUFEI_vec_origin = self.se_attention_FUFEI(target_FUFEI_vec)

        TargetDimScaling_Weight_Result = {
            'se_QOE_weight': se_QOE_weight,
            'se_CHONGHE_weight': se_CHONGHE_weight,
            'se_FUFEI_weight': se_FUFEI_weight
        }
        return TargetDimScaling_Weight_Result, se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec

# 用户历史与目标记录的attention层
class History_Target_AttentionLayer(nn.Module):
    def __init__(self, num_heads, feature_dim):
        super(History_Target_AttentionLayer, self).__init__()
        self.target_history_pay_feature_pianhao_layer = MultiHeadHistory_TargetAttention(num_heads, feature_dim)
        self.target_history_not_pay_feature_pianhao_layer = MultiHeadHistory_TargetAttention(num_heads, feature_dim)

    def forward(self, se_user_history_pay_QOE_vec, se_user_history_pay_CHONGHE_vec, se_user_history_pay_FUFEI_vec, se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec, mask=None):
        # 将QOE、CHONGHE、FUFEI叠加，形成三个特征的向量  (batch, 1，feature_dim)->(batch, 3，feature_dim)
        user_history_pay_vec = torch.cat(se_user_history_pay_QOE_vec, se_user_history_pay_CHONGHE_vec, se_user_history_pay_FUFEI_vec, dim=1)
        target_vec = torch.cat(se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec, dim=1)
        # 对目标特征求对历史特征的偏好   (batch, 3，feature_dim)输出
        target_history_pay_attention_weight, target_history_pay_attention_vec = self.target_history_pay_feature_pianhao_layer(target_vec, user_history_pay_vec, mask)

        return target_history_pay_attention_weight, target_history_pay_attention_vec

# (batch,600)经过网络变成200 +(batch,featuer_user*200)经过网络变成200 -> (batch,200)
# (batch,200) ->MLP ->(batch，1) ->sigmoid -> (batch,1)

# 整合层
class MatchingModel(nn.Module):
    def __init__(self, feature_category_num_dict, feature_column_dict, continue_embedding_dim,
                 discrete_embedding_dim,num_heads, feature_dim, max_history_len):
        super(MatchingModel, self).__init__()
        # Embedding层
        # self.user_info_embedding_layer = UserInfoEmbedding(continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict)
        self.user_history_pay_embedding_layer = UserPayHistoryEmbedding(continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict)
        self.target_embedding_layer = TargetEmbedding(continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict)

        # User History & Target Attention层
        self.history_pay_attention_layer = HistoryDimScalingLayer(num_heads, feature_dim, feature_category_num_dict, max_history_len)
        self.target_attention_layer = TargetDimScalingLayer(feature_dim, feature_category_num_dict)

        # Target History Attention层
        self.target_history_attention_layer = History_Target_AttentionLayer(num_heads, feature_dim)

        # 维度转换层
        self.target_dim_change = dense_layer(600, 200)  # (batch,3,200)->(batch,600)->(batch,200)
        # user_info_feature_num = feature_category_num_dict['user_info_continue'].shape[2] + feature_category_num_dict['user_info_discrete'].shape[2]
        # self.user_info_dim_change = dense_layer(user_info_feature_num, 200)  # (batch,user_info_feature,200)->(batch,user_info_feature*200)->(batch,200)
        # MLP
        final_dim = 200
        self.pay_vec_MLP_layer = dense_layer(final_dim, 1)


    def forward(self, batch_feature_tensor_dict, mask):
        # Embedding层
        user_history_pay_QOE_vec, user_history_pay_CHONGHE_vec, user_history_pay_FUFEI_vec = self.user_history_pay_embedding_layer(batch_feature_tensor_dict)
        target_QOE_vec, target_CHONGHE_vec, target_FUFEI_vec = self.target_embedding_layer(batch_feature_tensor_dict)

        # User History & Target Attention层
        HistoryDimScaling_Weight_Result, se_user_history_pay_QOE_vec, se_user_history_pay_CHONGHE_vec, se_user_history_pay_FUFEI_vec = self.history_pay_attention_layer(user_history_pay_QOE_vec,  user_history_pay_CHONGHE_vec, user_history_pay_FUFEI_vec, mask)
        TargetDimScaling_Weight_Result, se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec = self.target_attention_layer(target_QOE_vec, target_CHONGHE_vec, target_FUFEI_vec, mask)

        # Target with History Attention层
        target_history_pay_attention_weight, target_history_pay_attention_vec = self.target_history_attention_layer(
            se_user_history_pay_QOE_vec, se_user_history_pay_CHONGHE_vec, se_user_history_pay_FUFEI_vec,
            se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec, mask
        )

        # # 拼接user_info_vec与target_history_pay_attention_vec等
        # user_info_vec = user_info_vec.squeeze(1)  # 使用 squeeze 函数移除大小为 1 的维度
        # FUFEI:(batch,3,200)->(batch,3*200)经过网络->(batch,200) + uer_info:(batch,featuer_user*200)经过网络->(batch,200) 叠加后-> (batch,400)
        # 维度转换 (batch,3,200)->(batch,feature*200)经过网络->(batch,200)
        target_history_pay_attention_vec = target_history_pay_attention_vec.view(batch_size, -1)   # 将张量 x 重塑为 (batch, 3*200)  使用 -1 作为自动计算的维度
        target_history_pay_attention_vec = self.target_dim_change(target_history_pay_attention_vec)

        # MLP
        # (batch,200) ->MLP ->(batch，1) ->sigmoid -> (batch,1)
        out_vec = self.pay_vec_MLP_layer(target_history_pay_attention_vec)
        # 使用softmax函数将logits转换为概率分布
        score = F.softmax(out_vec, dim=1)  # 在类别维度（dim=1）上应用softmax

        return score, HistoryDimScaling_Weight_Result, TargetDimScaling_Weight_Result, target_history_pay_attention_weight

# 损失函数
class LossFunction(nn.Module):
    def __init__(self):
        super(LossFunction, self).__init__()

    def forward(self, pred, target_label):
        # pred是未经处理过的原值，target_label是0、1标签
        # 计算第一个任务的二元交叉熵损失
        loss = F.binary_cross_entropy_with_logits(pred, target_label, reduction='none')
        return loss

# 模型训练
def model_training(model,train_loader,val_loader, lossfunction,optimizer,EPOCH,device):
    # 定义早停策略的参数
    best_val_loss = float('inf')  # 初始化最佳验证损失为正无穷
    patience = 3  # 容忍多少个epoch没有验证性能提升
    early_stopping_counter = 0  # 初始化计数器
    for epoch in range(EPOCH):
        model.train()  # 设置模型为训练模式
        total_classfier_loss = 0.0
        total_pay_loss = 0.0
        total_not_pay_loss = 0.0
        total_loss = 0.0
        for batch in train_loader:
            batch = [data.to(device) for data in batch]
            xxx, label, mask = batch  # 待修改
            for param in model.parameters():
                param.requires_grad = True
            optimizer.zero_grad()
            score, HistoryDimScaling_Weight_Result, TargetDimScaling_Weight_Result, \
                target_history_pay_attention_weight = model(xxx, label, mask)  # 待修改

            scores = score[:, 0]  # (样本数，1)
            scores = scores.unsqueeze(-1)
            loss = lossfunction(scores, label)
            loss.backward()
            optimizer.step()
            # 损失
            total_loss += loss.item()
            # 平均损失
            average_loss = total_loss / len(train_loader)

            if (epoch + 1) % 5 == 0:
                print(
                    f"Epoch {epoch + 1},loss:{average_loss}")

                # 验证集评估
                model.eval()  # 将模型切换为评估模式
                with torch.no_grad():  # 在评估模式下不计算梯度
                    total_loss_val = 0.0
                    total_auc_val = 0.0
                    for batch_val in val_loader:  # 假设你有一个名为 val_loader 的验证集数据加载器
                        batch_val = [data.to(device) for data in batch_val]
                        xxx_val, label_val, mask_val = batch_val  # 待修改
                        score_val, HistoryDimScaling_Weight_Result_val, TargetDimScaling_Weight_Result_val, \
                            target_history_pay_attention_weight_val = model(xxx_val, label_val, mask_val)  # 待修改待修改

                        scores_val = score_val[:, 0]  # (样本数，1)
                        scores_val =scores_val.unsqueeze(-1)
                        loss_val = lossfunction(scores_val, label_val)
                        # 损失
                        total_loss_val += loss_val.item()
                        # 计算验证集上的AUC   待修改
                        correct_val = loss_val.sum().item()
                        total_auc_val += roc_auc_score(label_val, scores_val)
                        # 平均损失
                        average_loss_val = total_loss_val / len(val_loader)
                        average_auc_val = total_auc_val / len(val_loader)
                        print(f"Validation Loss: {average_loss_val},AUC: {average_auc_val}")

                        if average_loss_val < best_val_loss:
                            best_val_loss = average_loss_val
                            early_stopping_counter = 0
                        else:
                            early_stopping_counter += 1
                        if early_stopping_counter >= patience:
                            print(f"早停策略触发，停止训练在第 {epoch} 个epoch.")
                            break

def test_model(model, test_loader):
    model.eval()  # 设置模型为评估模式
    with torch.no_grad():  # 在评估模式下不计算梯度
        total_loss_test = 0.0
        total_auc_test = 0.0
        results = []  # 用于保存结果的列表
        for batch_test in test_loader:  # 假设你有一个名为 val_loader 的验证集数据加载器
            batch_test = [data.to(device) for data in batch_test]
            user_info, xxx, label_test, mask_test = batch_test  # 待修改
            score_test, HistoryDimScaling_Weight_Result_test, TargetDimScaling_Weight_Result_test, \
                target_history_pay_attention_weight_test = model(xxx_test, label_test, mask_test )  # 待修改


            scores_test = score_test[:, 0]  # (样本数，1)
            scores_test = scores_test.unsqueeze(-1)
            loss_test = lossfunction(scores_test, label_test)
            # 损失
            total_loss_test += loss_test.item()
            # 计算验证集上的AUC   待修改
            correct_test = loss_test.sum().item()
            total_auc_test += roc_auc_score(loss_test, label_test)
            # 平均损失
            average_loss_test = total_loss_test / len(test_loader)
            average_auc_test = total_auc_test / len(test_loader)
            print(
                f"Test Loss: {average_loss_test},AUC: {average_auc_test}")
            return average_loss_test, average_auc_test


# 创建一个空的DataFrame来存储结果
test_auc_df = pd.DataFrame(columns=['实验数', '测试集总损失', 'AUC', 'pay损失', 'not_pay损失'])
for i in range(5):
    torch.autograd.set_detect_anomaly(True)
    print(f"i=:{i+1}")
    n = i
    # 数据集 train、val、test划分及总数据hash表(以user_id为key的存储对应对应行的hash表)及不同类特征数存储的字典
    train_list, val_list, test_list, data_hash, feature_category_num_dict = data_input(data_time_windows, path, dataset_spilt_path, train_ratio, val_ratio, test_ratio, total_continue_feature)
    # 获取训练、验证、测试集对应的数据形成的向量hash存储及label
    train_data_tensor_hash, train_label, train_data_tensor_hash_history_mask = get_feature_to_matrix(train_list, data_hash, feature_column_dict)
    val_data_tensor_hash, val_label, val_data_tensor_hash_history_mask = get_feature_to_matrix(val_list, data_hash, feature_column_dict)
    test_data_tensor_hash, test_label, test_data_tensor_hash_history_mask = get_feature_to_matrix(test_list, data_hash, feature_column_dict)
    # 生成batch再添加维度对齐张量（三个维度）这里张量输出的全是三维 (batch_size, 1 or max_history_len, feature_num)
    train_batch_feature_tensor_dict = generate_user_feature_alignment_tensor(train_data_tensor_hash)
    val_batch_feature_tensor_dict = generate_user_feature_alignment_tensor(val_data_tensor_hash)
    test_batch_feature_tensor_dict = generate_user_feature_alignment_tensor(test_data_tensor_hash)
    # mask矩阵的字典
    train_batch_feature_tensor_history_mask_dict = generate_user_feature_alignment_tensor(train_data_tensor_hash_history_mask, is_mask=True)
    val_batch_feature_tensor_history_mask_dict = generate_user_feature_alignment_tensor(val_data_tensor_hash_history_mask, is_mask=True)
    test_batch_feature_tensor_history_mask_dict = generate_user_feature_alignment_tensor(test_data_tensor_hash_history_mask, is_mask=True)

    # 训练集
    train_dataset = TensorDataset(train_batch_feature_tensor_dict,
                                  train_label, train_batch_feature_tensor_history_mask_dict)
    val_dataset = TensorDataset(val_batch_feature_tensor_dict,
                                  val_label, val_batch_feature_tensor_history_mask_dict)
    # 创建数据加载器
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False)

    # 确保您的计算机上有CUDA支持的GPU
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    # 创建大模型的实例
    model = MatchingModel(feature_category_num_dict, feature_column_dict, continue_embedding_dim,
                 discrete_embedding_dim, num_heads, feature_dim, max_history_len)

    model.to(device)
    # 进一步处理 列表转移到GPU
    for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_QOE_discrete_embeddings)):
        model.user_history_pay_embedding_layer.user_pay_history_QOE_discrete_embeddings[i] = \
        model.user_history_pay_embedding_layer.user_pay_history_QOE_discrete_embeddings[i].to(device)
    for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_discrete_embeddings)):
        model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_discrete_embeddings[i] = \
        model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_discrete_embeddings[i].to(device)
    for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_FUFEI_discrete_embeddings)):
        model.user_history_pay_embedding_layer.user_pay_history_FUFEI_discrete_embeddings[i] = \
        model.user_history_pay_embedding_layer.user_pay_history_FUFEI_discrete_embeddings[i].to(device)

    lossfunction = LossFunction()
    optimizer = optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), lr=lr)

    # 训练
    model_training(model, train_loader, val_loader, lossfunction, optimizer, 500, device)
    # 测试
    test_dataset = TensorDataset(test_batch_feature_tensor_dict,
                                  test_label, test_batch_feature_tensor_history_mask_dict)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)
    average_loss_test, average_auc_test = test_model(model, test_loader)
    # 测试的每个样本结果保存到csv
    # 将本次训练的结果添加到DataFrame中
    test_auc_df = test_auc_df.append(
        {'实验数': i + 1, '测试集总损失': average_loss_test, 'AUC': average_auc_test}, ignore_index=True)
# 将结果保存到CSV文件中
test_auc_df.to_csv('maoerDL_result.csv', index=False)


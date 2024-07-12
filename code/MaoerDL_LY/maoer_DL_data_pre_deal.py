# 针对猫耳用户预测模型的数据预处理
# 要求：对缺失值填充，离散处理、数据标准化
import os

import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from collections import Counter

# 获取时间窗内连续与离散特征名的列表
def get_continue_discrete_feature_namelist(time_windows, datapath):
    data = pd.read_csv(datapath)
    time_windows_data = data[(data['DataSet'] == time_windows)]
    user_history_pay_QOE_continue_column = eval([time_windows_data['QOE_continue'].values.tolist()][0][0])
    user_history_pay_CHONGHE_continue_column = eval([time_windows_data['CHONGHE_continue'].values.tolist()][0][0])
    user_history_pay_FUFEI_continue_column = eval([time_windows_data['FUFEI_continue'].values.tolist()][0][0])
    user_history_pay_QOE_discrete_column = eval([time_windows_data['QOE_discrete'].values.tolist()][0][0])
    user_history_pay_CHONGHE_discrete_column = eval([time_windows_data['CHONGHE_discrete'].values.tolist()][0][0])
    user_history_pay_FUFEI_discrete_column = eval([time_windows_data['FUFEI_discrete'].values.tolist()][0][0])
    # print(user_history_pay_QOE_continue_column)

    return user_history_pay_QOE_continue_column, user_history_pay_CHONGHE_continue_column,user_history_pay_FUFEI_continue_column,\
            user_history_pay_QOE_discrete_column,user_history_pay_CHONGHE_discrete_column,user_history_pay_FUFEI_discrete_column

# 取出指定列sound_not_null_feature_name不为空的所有行，统计其中user_id值出现次数大于1的个数
def get_user_excd_once_soundFeatureNotNull_data(data, sound_not_null_feature_name):
    # 取指定列 'k1' 不为空的所有行
    # sound_not_null_feature_name = 'voiceProb_sma_de_max numeric'
    filtered_data = data[data[sound_not_null_feature_name].notnull()]

    # 统计第一列中值出现次数大于1的个数
    count = filtered_data['user_id'].value_counts()
    # print(count.sum())
    count_greater_than_1 = (count > 1).sum()
    # 获取索引
    count_greater_than_1_rows = count[count > 1]
    # 取出count>1的所有行
    filtered_data_greater_than_1 = filtered_data[filtered_data['user_id'].isin(count_greater_than_1_rows.index)]

    # 找出这些 user_id 对应的行中 最后一列 同时存在 1 和 2
    result_df = filtered_data[(filtered_data['user_id'].isin(count_greater_than_1_rows.index)) &
                            (filtered_data.groupby('user_id')['user_in_drama_is_pay_for_drama_in_next_time'].transform(lambda x: set(x) == {1, 2}))]

    datadf = filtered_data_greater_than_1   # result_df
    # datadf = pd.DataFrame(filtered_data_greater_than_1)
    # print("筛选", sound_not_null_feature_name, "列不为空后user值出现次数大于1的个数为:", count_greater_than_1, '，去重后user_id数据共：', len(result_df.groupby('user_id')))
    print("筛选", sound_not_null_feature_name, "列不为空后user值出现次数大于1的个数为:", count_greater_than_1,
          '，去重后user_id数据共：', len(datadf.groupby('user_id')))

    return datadf

# 读取CSV文件数据
datasetNamelist = [
                   # '0101_0131'
                   '0115_0215'
                   # '0201_0230',
                   # '1101_1130'
                   # '1115_1215'
                   # '1201_1231',
                   # '1215_0115'
                   ]
datapath = './Dataset/maoer_timewindows_continue_discrete_feature_column.csv'    # 连续与离散划分表
for dataset_time in datasetNamelist:
    user_history_pay_QOE_continue_column, user_history_pay_CHONGHE_continue_column, \
        user_history_pay_FUFEI_continue_column, user_history_pay_QOE_discrete_column,\
        user_history_pay_CHONGHE_discrete_column, user_history_pay_FUFEI_discrete_column = get_continue_discrete_feature_namelist(dataset_time, datapath)
    others = ['user_id', 'sound_id', 'user_in_drama_is_pay_for_drama_in_next_time']
    discrete_list = user_history_pay_QOE_discrete_column+user_history_pay_CHONGHE_discrete_column+user_history_pay_FUFEI_discrete_column
    continue_list = user_history_pay_QOE_continue_column + user_history_pay_CHONGHE_continue_column + user_history_pay_FUFEI_continue_column
    feature_list = discrete_list + continue_list +others
    # print(len(feature_list), feature_list)

    dataset = './Dataset/' + dataset_time + '_user_pay_pred_feature.csv'
    output_path = './Dataset/' + dataset_time + '_user_pay_pred_feature_deal.csv'
    df = pd.read_csv(dataset, header=0)
    # 取出指定列sound_not_null_feature_name不为空的所有行，统计其中user_id值出现次数大于1的个数
    # df = get_user_excd_once_soundFeatureNotNull_data(df, 'voiceProb_sma_de_max numeric')
    cols_to_fill = [col for col in df.columns if col in feature_list]

    new_df = df[cols_to_fill]
    continue_cols_to_fill = [col for col in new_df.columns if col in continue_list]
    discrete_cols_to_fill = [col for col in new_df.columns if col in discrete_list]
    # 离散值 使用出现次数最多的非空值填充空值
    # most_common_values = new_df[discrete_cols_to_fill].mode().iloc[0]
    # new_df[discrete_cols_to_fill] = new_df[discrete_cols_to_fill].fillna(most_common_values)
    # 连续值 均值填充
    new_df[continue_cols_to_fill] = new_df[continue_cols_to_fill].fillna(new_df[continue_cols_to_fill].mean())
    # print(len(discrete_cols_to_fill)+len(continue_cols_to_fill))
    # 初始化标准化器
    scaler = StandardScaler()
    # 对所有填充完缺失值的列进行标准化
    new_df[continue_cols_to_fill] = scaler.fit_transform(new_df[continue_cols_to_fill])
    # print(len(new_df.columns), new_df.columns)
    # print([col for col in feature_list if col not in new_df.columns])
    new_df.to_csv(output_path, index=False)
    print(dataset_time, '时间窗已完成')



    # print(cols_to_fill)
    # numeric_cols = df[cols_to_fill].iloc[:, :].select_dtypes(include=[np.number]).columns  # 第1、2、最后一列没有处理

    # df[numeric_cols] = df[numeric_cols].fillna(df[numeric_cols].mean())
    # # 初始化标准化器
    # scaler = StandardScaler()
    # # 对所有填充完缺失值的列进行标准化
    # df[numeric_cols] = scaler.fit_transform(df[numeric_cols])
    # df[numeric_cols].to_csv(output_path, index=False)
    # print(dataset_time, '时间窗已完成')



    # cols_to_fill = [col for col in df.columns if col in feature_list]
    # # print(cols_to_fill)
    # numeric_cols = df[cols_to_fill].iloc[:, :].select_dtypes(include=[np.number]).columns  # 第1、2、最后一列没有处理
    # # 将csv中数据值为oldword的改写为newword
    # new_data = []
    # for index, col in df[numeric_cols].items():
    #     # 从每列随机选取中一个值
    #     # ranValue=random.choice(col)
    #     # 选取一列中出现次数最多的值  离散型
    #     # newcol = list(col)
    #     # count = Counter(newcol).most_common(2)
    #     # if count[0][0] == -1 or count[0][0] is None:
    #     #     ranValue = count[1][0]
    #     # else:
    #     #     ranValue = count[0][0]
    #     # ranValue=max(set(newcol), key= newcol.count)
    #     # 选取一列中的平均值 连续型
    #     # meanvalue = np.array(col)
    #     # ranValue = np.mean(meanvalue)
    #     rep = [ranValue if x is None or x == "" else x for x in col]
    #     new_data.append(rep)
    #
    # newdf = pd.DataFrame(new_data)
    # newdf = newdf.T
    # # 初始化标准化器
    # scaler = StandardScaler()
    # # 对所有填充完缺失值的列进行标准化
    # newdf = scaler.fit_transform(newdf)
    # newdf = pd.DataFrame(newdf)
    # newdf.columns = cols_to_fill
    # newdf.to_csv(output_path, index=False)
    # print(dataset_time, '时间窗已完成')




    # user_history_pay_QOE_discrete_column = ['user_name_has_english','user_in_sound_is_submit_review','drama_danmu_time_between_sound_time_in_7days_num_min']
    # user_history_pay_CHONGHE_discrete_column = ['user_name_has_chinese','user_intro_has_chinese','user_intro_has_english','user_submit_danmu_drama_completed_num_now','sound_title_len','sound_intro_len','sound_danmu_15s_max_traffic_position_in_sound']
    # user_history_pay_FUFEI_discrete_column = ['drama_intro_len','drama_upuser_subscriptions_num','drama_sound_max_traffic_position_in_sound_avg','label1']



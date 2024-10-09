import math
import os

import numpy as np
import pandas as pd


class DataTool(object):

    # 获取时间窗内连续与离散特征名的列表
    @staticmethod
    def get_continue_discrete_feature_namelist(time_windows, datapath):
        data = pd.read_csv(datapath)
        time_windows_data = data[(data['DataSet'] == time_windows)]
        user_history_pay_QOE_continue_column = eval([time_windows_data['QOE_continue'].values.tolist()][0][0])
        user_history_pay_CHONGHE_continue_column = eval([time_windows_data['CHONGHE_continue'].values.tolist()][0][0])
        user_history_pay_FUFEI_continue_column = eval([time_windows_data['FUFEI_continue'].values.tolist()][0][0])
        user_history_pay_QOE_discrete_column = eval([time_windows_data['QOE_discrete'].values.tolist()][0][0])
        user_history_pay_CHONGHE_discrete_column = eval([time_windows_data['CHONGHE_discrete'].values.tolist()][0][0])
        user_history_pay_FUFEI_discrete_column = eval([time_windows_data['FUFEI_discrete'].values.tolist()][0][0])

        return user_history_pay_QOE_continue_column, user_history_pay_CHONGHE_continue_column, user_history_pay_FUFEI_continue_column, \
            user_history_pay_QOE_discrete_column, user_history_pay_CHONGHE_discrete_column, user_history_pay_FUFEI_discrete_column


    # 数据预处理 将连续特征变离散特征 分桶 不处理user_id、sound_id、drama_id、time
    @staticmethod
    def data_pre_deal(input_path, continue_feature_list):
        df = pd.read_csv(input_path)
        deal_data_df = []  # 待修改********
        # # 获取离散特征的类别数量，并存储为字典
        # category_counts = {}
        # for column in deal_data_df.columns:
        #     unique_values = deal_data_df[column].nunique()  # 获取列的唯一值数量
        #     category_counts[column] = unique_values
        print('数据预处理结束')
        return df

    @staticmethod
    def find_data_by_list(user_list, intput_data_df, data_hash):
        # 遍历列表中的值，在DataFrame中找到所有匹配的行数据并加入data_hash
        for user_id in user_list:
            result_df = intput_data_df[intput_data_df[intput_data_df.columns[0]] == user_id]
            data_hash[user_id] = result_df  # 直接存储DataFrame对象
        return data_hash

    # 获取列唯一值数量表，并对离散特征的值转化为从0开始的索引
    @staticmethod
    def get_unique_feature_num_and_discrete_valueChange(data_df, discrete_feature_column_list):
        # 获取离散特征的类别数量，并存储为字典
        feature_category_num_dict = {}
        for column in data_df.columns:
            unique_values_len = data_df[column].nunique()  # 获取列的唯一值数量
            feature_category_num_dict[column] = unique_values_len
            if column in discrete_feature_column_list:
                unique_values = data_df[column].unique()
                value_mapping_dict = {value: index for index, value in enumerate(unique_values) if
                                      value != -1 and value != '' and value is not None}
                data_df[column] = data_df[column].map(value_mapping_dict)
        return feature_category_num_dict, data_df

    
    @staticmethod
    def data_input(data_time_windows, train_path, test_path, spilt_outpath, val_ratio, test_ratio, total_continue_feature,total_discrete_feature):
        """总的特征输入，生成划分后数据集及其输入

        Args:
            data_time_windows (_type_): _description_
            train_path (_type_): _description_
            test_path (_type_): _description_
            spilt_outpath (_type_): 0101_0131_user_pay_pred_feature_spilt.csv
            val_ratio (_type_): _description_
            test_ratio (_type_): _description_
            total_continue_feature (_type_): _description_
            total_discrete_feature (_type_): _description_

        Returns:
            _type_: _description_
        """
        train_dataset_path = train_path  # 待修改********
        test_dataset_path = test_path
        dataset_spilt_path = spilt_outpath  # 待修改********
        if os.path.exists(dataset_spilt_path):  # 划分训练、验证、测试集
            print("划分文件已存在，不再进行数据划分")
        else:
            DataTool.split_data_unique(train_dataset_path, test_dataset_path, dataset_spilt_path, val_ratio, test_ratio)
        train_deal_data_df = DataTool.data_pre_deal(train_dataset_path, total_continue_feature)  # 数据预处理
        test_deal_data_df = DataTool.data_pre_deal(test_dataset_path, total_continue_feature)  # 数据预处理
        # 获取离散特征的类别数量，并存储为字典
        _, train_deal_data_df = DataTool.get_unique_feature_num_and_discrete_valueChange(
            train_deal_data_df,
            total_discrete_feature)

        _, test_deal_data_df = DataTool.get_unique_feature_num_and_discrete_valueChange(
            test_deal_data_df,
            total_discrete_feature)

        feature_category_num_dict, _ = DataTool.get_unique_feature_num_and_discrete_valueChange(
            pd.concat([train_deal_data_df, test_deal_data_df]),
            total_discrete_feature
        )
        # 读取划分文件的结果
        spilt_data_df = pd.read_csv(dataset_spilt_path)
        # 输出每一列数据为列表
        train_list = spilt_data_df['Train'].tolist()
        val_list = spilt_data_df['Val'].tolist()
        test_list = spilt_data_df['Test'].tolist()
        train_list = [x for x in train_list if not math.isnan(x)]
        val_list = [x for x in val_list if not math.isnan(x)]
        test_list = [x for x in test_list if not math.isnan(x)]
        # print('训练集、验证集、测试集大小=', len(train_list),len(val_list),len(test_list))
        # 根据划分好的生成以user_id为key的hash（特征集合）将最后一行看做目标数据
        train_data_hash = {}
        data_hash = {}  # 存成一个hash形式
        DataTool.find_data_by_list(train_list, train_deal_data_df, train_data_hash)
        DataTool.find_data_by_list(val_list, test_deal_data_df, data_hash)
        DataTool.find_data_by_list(test_list, test_deal_data_df, data_hash)
        print('数据划分完成')
        # print(feature_category_num_dict)
        return train_list, val_list, test_list, train_data_hash, data_hash, feature_category_num_dict
    
    @staticmethod
    def find_data_by_list(user_list, intput_data_df, data_hash):
        # 遍历列表中的值，在DataFrame中找到所有匹配的行数据并加入data_hash  
        for user_id in user_list:
            result_df = intput_data_df[intput_data_df[intput_data_df.columns[0]] == user_id]
            data_hash[user_id] = result_df  # 直接存储DataFrame对象  
        return data_hash

    @staticmethod
    # 划分数据集 给定输出后固定结果 输出形式定为存储user_id 形成train_dataset,val_dataset,test_dataset
    def split_data_unique(input_train_file, input_test_file, output_file, val_ratio, test_ratio):
        train_df = pd.read_csv(input_train_file)
        test_df = pd.read_csv(input_test_file)
        train_data = train_df[train_df.columns[0]].unique()  # 提取第一列数据并去重{user_id}
        test_data = test_df[test_df.columns[0]].unique()
        np.random.shuffle(train_data)  # 随机打乱训练数据

        test_df_0 = test_df[test_df['pay_DL'] == 0]
        test_df_1 = test_df[test_df['pay_DL'] == 1]

        len_0 = len(test_df_0)
        len_1 = len(test_df_1)

        val_df_0_sample = test_df_0.sample(n=round(len_0*(val_ratio/(val_ratio+test_ratio))))
        val_df_1_sample = test_df_1.sample(n=round(len_1*(val_ratio/(val_ratio+test_ratio))))

        val_df = pd.concat([val_df_0_sample, val_df_1_sample])
        val_data = val_df[val_df.columns[0]].unique()
        test_df = pd.concat([test_df_0.drop(val_df_0_sample.index), test_df_1.drop(val_df_1_sample.index)])
        test_data = test_df[test_df.columns[0]].unique()

        for _ in range(10):
            np.random.shuffle(test_data)
            np.random.shuffle(val_data)

        # 存储结果是去重的user_id
        result = {
            'Train': train_data,
            'Val': val_data,
            'Test': test_data
        } 
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
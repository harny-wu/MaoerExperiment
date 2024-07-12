# 猫耳 因果特征选择结果 根据重合特征的序号下标查找对应时间窗下的重合特征名

import pandas as pd
import numpy as np
import os

datasetNamelist = ['0101_0131_all_feature',
                   '0115_0215_all_feature',
                   '0201_0230_all_feature',
                   '1101_1130_all_feature',
                   '1115_1215_all_feature',
                   '1201_1231_all_feature',
                   '1215_0115_all_feature']

chonghe_feature_inpaths = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/maoer_FS_chonghe_ResultCount.csv'
causal_result_paths = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/Causal_FS_ProcessingResult.csv'
chonghe_feature_df = pd.read_csv(chonghe_feature_inpaths)
causal_result_df = pd.read_csv(causal_result_paths)

feature_hash ={}
for datasetname in datasetNamelist:
    dataset = datasetname
    # 重合特征
    # 查找 '数据集名称' 在第一列出现的最后一次的索引
    chonghe_last_index = chonghe_feature_df.iloc[::-1][chonghe_feature_df.columns[0]].tolist().index(dataset)
    chonghe_last_index = len(chonghe_feature_df) - chonghe_last_index - 1  # 将倒数的索引转换为正数
    # 根据索引查找对应行的数据
    chonghe_result_row = chonghe_feature_df.iloc[chonghe_last_index]
    # 因果结果
    # 查找 '数据集名称' 在第一列出现的最后一次的索引
    data = '/'+dataset
    causal_last_index = causal_result_df.iloc[::-1][causal_result_df.columns[0]].tolist().index(data)
    causal_last_index = len(causal_result_df) - causal_last_index - 1  # 将倒数的索引转换为正数
    # 根据索引查找对应行的数据
    causal_result_row = causal_result_df.iloc[causal_last_index]

    # 取出 '列1' 和 '列2' 的值, 使用 eval() 函数将字符串转换为列表
    CHONGHE_value = eval(chonghe_result_row['重合_对应列名'])
    causal_value_P = eval(causal_result_row['PofTarget'])
    causal_value_C = eval(causal_result_row['CofTarget'])
    causal_value_R = eval(causal_result_row['RelationofT'])
    PofT_feature_list = [CHONGHE_value[idx] for idx in causal_value_P]
    CofT_feature_list = [CHONGHE_value[idx] for idx in causal_value_C]
    RofT_feature_list = [CHONGHE_value[idx] for idx in causal_value_R]
    feature_dict = {
        'PofT_feature_list': PofT_feature_list,
        'CofT_feature_list': CofT_feature_list,
        'RofT_feature_list': RofT_feature_list
    }
    feature_hash[dataset] = feature_dict

# 查找去重后的特征输出结果
# 遍历字典去重每个值中的列表值
unique_P_list = []
unique_C_list = []
unique_R_list = []
for key, value in feature_hash.items():
    unique_P_list.extend(value['PofT_feature_list'])
    unique_C_list.extend(value['CofT_feature_list'])
    unique_R_list.extend(value['RofT_feature_list'])
unique_P_values = list(set(unique_P_list))  # 使用set去重，再转换为列表
unique_C_values = list(set(unique_C_list))  # 使用set去重，再转换为列表
unique_R_values = list(set(unique_R_list))  # 使用set去重，再转换为列表

# 去除 list3 中存在于 list1 或 list2 的元素
unique_R_values = [x for x in unique_R_values if x not in unique_P_values and x not in unique_C_values]
# 去除 list2 中存在于 list1 的元素
unique_C_values = [x for x in unique_C_values if x not in unique_P_values]


print('长度：', len(unique_P_values), '去重后的PofTarget：', unique_P_values)
print('长度：', len(unique_C_values), '去重后的CofTarget：', unique_C_values)
print('长度：', len(unique_R_values), '去重后的RofTarget：', unique_R_values)
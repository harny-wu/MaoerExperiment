# maoer深度学习模型 model3.1所得权重结果分析
# 数据:./Dataset/maoer_timewindows_continue_discrete_feature_column.csv   划分的连续与离散列名
# ./Dataset/maoerDL_result_maoer_pay_pred_weight_model3_1.csv  权重结果
# 找对应model、时间窗及Type最后出现的5次结果中 target_history_pay_attention_QOE_weight对应se_user_pay_QOE_weight,  CHONGHE/FUFEI类似
import csv
import os

import numpy as np


import pandas as pd
import ast

datasetNamelist = [
                   '0101_0131',
                   '0115_0215',
                   '0201_0230',
                   '1101_1130',
                   '1115_1215',
                   '1201_1231',
                   '1215_0115'
                   ]
# 假设这是两个CSV文件路径
file1_path = './Dataset/maoerDL_result_maoer_pay_pred_weight_model3_1.csv'
file2_path = './Dataset/maoer_timewindows_continue_discrete_feature_column.csv'
outpath = './Dataset/maoerDL_result_weight.csv'
Type = 'Origin'
model = 'model3.1'

# 读取文件1
df1 = pd.read_csv(file1_path)
# 读取文件2
df2 = pd.read_csv(file2_path)

for datasetname in datasetNamelist:
        # 找到符合条件的最后5行
        filtered_df1 = df1[(df1['model'] == model) & (df1['Type'] == Type) & (df1['dataset'] == datasetname)].tail(5)
        # 提取'target'权重列并解析为浮点数
        target_QOE = filtered_df1['target_history_pay_attention_QOE_weight'].apply(
                lambda x: float(x.replace("tensor(", "").replace(")", "")))
        target_CHONGHE = filtered_df1['target_history_pay_attention_CHONGHE_weight'].apply(
                lambda x: float(x.replace("tensor(", "").replace(")", "")))
        target_FUFEI = filtered_df1['target_history_pay_attention_FUFEI_weight'].apply(
                lambda x: float(x.replace("tensor(", "").replace(")", "")))

        # 提取'se'权重列并解析为列表    切片x[7:-1]去除两端的'tensor(['和'])'
        se_QOE = filtered_df1['se_user_pay_QOE_weight'].apply(lambda x: ast.literal_eval(x[7:-1]))
        se_CHONGHE = filtered_df1['se_user_pay_CHONGHE_weight'].apply(lambda x: ast.literal_eval(x[7:-1]))
        se_FUFEI = filtered_df1['se_user_pay_FUFEI_weight'].apply(lambda x: ast.literal_eval(x[7:-1]))

        # 直接取se权重
        QOE_lists = np.mean([np.array(se_list) for se_list in  se_QOE], axis=0)
        CHONGHE_lists = np.mean([np.array(se_list) for se_list in  se_CHONGHE], axis=0)
        FUFEI_lists = np.mean([np.array(se_list)for se_list in  se_FUFEI], axis=0)
        # 将'target'列的值与'se'列的每个值相乘得到新列表  对列取平均
        # QOE_lists = np.mean([np.array(se_list) * target_value for target_value, se_list in zip(target_QOE, se_QOE)], axis=0)
        # CHONGHE_lists = np.mean([np.array(se_list) * target_value for target_value, se_list in zip(target_CHONGHE, se_CHONGHE)], axis=0)
        # FUFEI_lists = np.mean([np.array(se_list) * target_value for target_value, se_list in zip(target_FUFEI, se_FUFEI)], axis=0)

        # 类型的平均权重
        target_QOE_avg = np.mean(target_QOE, axis=0)
        target_CHONGHE_avg = np.mean(target_CHONGHE, axis=0)
        target_FUFEI_avg = np.mean(target_FUFEI, axis=0)

        # 查找对应列名
        # 查找 '数据集名称' 在DataSet出现的最后一次的索引
        last_index = df2.iloc[::-1]['DataSet'].tolist().index(datasetname)
        last_index = len(df2) - last_index - 1  # 将倒数的索引转换为正数
        # 根据索引查找对应行的数据
        QOE, CHONGHE, FUFEI = [], [], []
        result_row = df2.iloc[last_index]
        QOE.extend(eval(result_row['QOE_discrete']))
        QOE.extend(eval(result_row['QOE_continue']))
        CHONGHE.extend(eval(result_row['CHONGHE_discrete']))
        CHONGHE.extend(eval(result_row['CHONGHE_continue']))
        CHONGHE.extend(['is_pay'])  # 最终结果中有标签:是否付费放在了CHONGHE最后 这里添加上
        FUFEI.extend(eval(result_row['FUFEI_discrete']))
        FUFEI.extend(eval(result_row['FUFEI_continue']))

        # 输出最终结果
        result_columns = [model, Type, datasetname, len(QOE), len(CHONGHE), len(FUFEI)]
        result_columns.extend(QOE)
        result_columns.extend(CHONGHE)
        result_columns.extend(FUFEI)
        result_weight = [model, Type, datasetname, target_QOE_avg, target_CHONGHE_avg, target_FUFEI_avg]
        result_weight.extend(QOE_lists)
        result_weight.extend(CHONGHE_lists)
        result_weight.extend(FUFEI_lists)


        if not os.path.exists(outpath):
                # os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
                with open(outpath, 'a', newline='') as f:
                        writer = csv.writer(f)
                        writer.writerow(['Model', 'Type', 'DataSet', 'QOE长度/平均权重', 'CHONGHE长度/平均权重', 'FUFEI长度/平均权重'])
        with open(outpath, 'a', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(result_columns)
                writer.writerow(result_weight)



# 找到符合条件的行
# filtered_df2 = df2[(df2['DataSet'] == '0101_0131')]
# 提取'hh'和'gg'列的键值对
# hh_gg_pairs = filtered_df2[['QOE_discrete', 'QOE_continue']].values[0][0][0]  # 获取最内层列表
#
# # 提取键值对并创建新的列表
# hh_gg_values = [pair.split("'")[1] for pair in hh_gg_pairs.split(',')]
# print(hh_gg_values)
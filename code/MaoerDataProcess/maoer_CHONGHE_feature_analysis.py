# 对于猫耳用户瞬时体验质量的特征选择结果与用户付费的特征选择结果的重合特征及独有特征的出现次数分析
# 因为有多个时间窗所以统计多个时间窗中重合特征及独有特征的出现次数，再分析

from collections import Counter
import csv
import pandas as pd
import numpy as np

datasetNamelist = ['0101_0131_all_feature_involved',
                   # '0115_0215_all_feature',
                   # '0201_0230_all_feature',
                   # '1101_1130_all_feature',
                   # '1115_1215_all_feature',
                   # '1201_1231_all_feature',
                   # '1215_0115_all_feature'
                   ]
# 获取所有时间窗的重合特征
datapaths = '/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/ProcessingResult/maoer_FS_ResultCount.csv'
all_commonset_feature = []
QOE_unique_feature = []
FUFEI_unique_feature = []
for dataset in datasetNamelist:
    df = pd.read_csv(datapaths, header=0)
    # 查找 '数据集名称' 在第一列出现的最后一次的索引
    last_index = df.iloc[::-1][df.columns[0]].tolist().index(dataset)
    last_index = len(df) - last_index - 1  # 将倒数的索引转换为正数
    # 根据索引查找对应行的数据
    result_row = df.iloc[last_index]
    # 取出 '列1' 和 '列2' 的值, 使用 eval() 函数将字符串转换为列表
    CHONGHE_value = eval(result_row['重合_对应列名'])
    QOE_value = eval(result_row['契合度独有_对应列名'])
    FUFEI_value = eval(result_row['付费独有_对应列名'])
    all_commonset_feature.extend(CHONGHE_value)
    QOE_unique_feature.extend(QOE_value)
    FUFEI_unique_feature.extend(FUFEI_value)


# 使用 Counter 统计元素出现次数
CHONGHE_feature_counts = Counter(all_commonset_feature)
QOE_unique_feature_counts = Counter(QOE_unique_feature)
FUFEI_unique_feature_counts = Counter(FUFEI_unique_feature)

print('重合特征长度', len(CHONGHE_feature_counts))
print('QOE独有特征长度', len(QOE_unique_feature_counts))
print('付费独有特征长度', len(FUFEI_unique_feature_counts))

# 打印重合特征中每个元素出现的次数
# for element, count in CHONGHE_feature_counts.items():
#     print(f"{element},{count}")

# 打印重合+QOE独有特征中每个元素出现的次数
# 合并两个 Counter 对象
combined_counts = CHONGHE_feature_counts + QOE_unique_feature_counts
# 获取每个元素出现在两个集合结合在一起后的次数
print('重合+QOE独有特特征长度', len(combined_counts))
for element, count in combined_counts.items():
    print(f"{element},{count}")
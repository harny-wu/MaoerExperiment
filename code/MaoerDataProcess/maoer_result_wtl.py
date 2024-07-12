# 计算maoer_FS_chonghe_ACC_ResultCount结果w/t/l  这个结果都是针对用户付费行为的预测 区别是选取特征集合的不同
# 对比QOE与CHONGHE_PAY跟FUFEI的差异

import csv
import os

import numpy as np
import pandas as pd
from scipy import stats

def cal_acc(array1, array2):
    array1 = np.array(array1, dtype=np.float64)
    array2 = np.array(array2, dtype=np.float64)
    diff = array1 - array2
    # print(diff)
    t_statistic, p_value = stats.ttest_rel(array1, array2)

    count_positive = sum(x > 0 for x in diff)
    if count_positive > len(diff) / 2 and p_value < 0.05:
        return 'w'
    elif count_positive < len(diff) / 2 and p_value < 0.05:
        return 'l'
    else:
        return 't'

def judge_acc(own, other):
    w = 0
    t = 0
    loss = 0
    for i in range(len(own)):
        # print(own[0][i])
        result = cal_acc(own[i], other[i])
        if result == 'w':
            w += 1
        elif result == 't':
            t += 1
        else:
            loss += 1
    # print(w, t, loss)
    return w, t, loss

# 数据集
data_time_windows = ['0101_0131_all_feature',
                   '0115_0215_all_feature',
                   '0201_0230_all_feature',
                   '1101_1130_all_feature',
                   '1115_1215_all_feature',
                   '1201_1231_all_feature',
                   '1215_0115_all_feature']
data_type = ['FUFEI', 'QOE', 'CHONGHE_PAY']
Classifier_list = ['SVM', 'C4.5', 'NB', 'KNN']
inpath_origin = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/maoer_FS_chonghe_ACC_ResultCount.csv'
outpath = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/maoer_FS_chonghe_ACC_ResultCount_wtl_result.csv'

# 获取对比数据
result_QOE = []
result_CHONGHE = []
df = pd.read_csv(inpath_origin)
for data_time in data_time_windows:
    for classifier in Classifier_list:
        # 指定需要计算w/t/l的列范围
        columns_to_calculate = df.columns[4:14]  # 假设第4列到第14列需要计算

        # 筛选满足条件的数据
        fufei_data = df[(df['MissingRatio'] == 'FUFEI') & (df['DataSet'] == data_time) & (df['Classifier'] == classifier)]
        QOE_data = df[(df['MissingRatio'] == 'QOE') & (df['DataSet'] == data_time) & (df['Classifier'] == classifier)]
        CHONGHE_data = df[(df['MissingRatio'] == 'CHONGHE_PAY') & (df['DataSet'] == data_time) & (df['Classifier'] == classifier)]
        FUFEI = fufei_data[columns_to_calculate].values.tolist()
        QOE = QOE_data[columns_to_calculate].values.tolist()
        CHONGHE = CHONGHE_data[columns_to_calculate].values.tolist()

        w_QOE, t_QOE, loss_QOE = judge_acc(QOE, FUFEI)
        w_CHONGHE, t_CHONGHE, loss_CHONGHE = judge_acc(CHONGHE, FUFEI)
        result_QOE.append([data_time, 'QOE_PAY', classifier, w_QOE, t_QOE, loss_QOE])
        result_CHONGHE.append([data_time, 'CHONGHE_PAY', classifier, w_CHONGHE, t_CHONGHE, loss_CHONGHE])
if not os.path.exists(outpath):
    # os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
    with open(outpath, 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['Dataset', 'Data_type', 'Classifier', 'w', 't', 'l'])
with open(outpath, 'a', newline='') as file:
    writer = csv.writer(file)
    for i in range(len(data_time_windows)*len(Classifier_list)):
        writer.writerow(result_QOE[i])
        writer.writerow(result_CHONGHE[i])
print('完成')

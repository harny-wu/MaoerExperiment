# maoer深度学习模型对比算法 -机器学习SVM&RF

import os
import pandas as pd
import numpy as np
import math
import copy
import datetime
from sklearn.metrics import roc_auc_score, f1_score, accuracy_score, recall_score, precision_score, roc_curve, confusion_matrix
from _collections import OrderedDict  # 导入 OrderedDict 来保持字典中键值对的顺序

print('||--------开始时间：', datetime.datetime.now(), '-------------')
data_time_windows_list = ['0101_0131', '0115_0215', '0201_0230',
                          '1101_1130', '1115_1215', '1201_1231', '1215_0115']



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


    return user_history_pay_QOE_continue_column, user_history_pay_CHONGHE_continue_column,user_history_pay_FUFEI_continue_column,\
            user_history_pay_QOE_discrete_column,user_history_pay_CHONGHE_discrete_column,user_history_pay_FUFEI_discrete_column







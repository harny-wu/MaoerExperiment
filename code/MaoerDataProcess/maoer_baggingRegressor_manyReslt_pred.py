# 针对猫耳数据，计算在用户契合度得到的约简集合将最后一列替换为连续值后的回归结果
# 数据要求：获取用户契合度得到的结果集作为C，获取每个对应原始数据集的那一列（连续值）作为D，计算回归的结果
# 十倍交叉验证 SVM KNN C4.5 NB
import csv

# 需求：读取文件夹下reduce中文件训练求ACC
import pandas as pd
import numpy as np
import os
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score
from sklearn.metrics import roc_curve, auc
# import matplotlib.pylab as plt
from sklearn import datasets
from sklearn import svm
from natsort import natsorted
from sklearn.model_selection import KFold
import random
from collections import Counter
from sklearn.ensemble import BaggingRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn import tree
from sklearn.naive_bayes import MultinomialNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, accuracy_score, mean_absolute_error, r2_score, explained_variance_score

#归一化
def normalize(data):
    min_val = min(data)
    max_val = max(data)
    normalized_data = [(x - min_val) / (max_val - min_val) for x in data]
    return normalized_data

# 数据读取
filenum = '15%'
Type = 'Incremental'
missingValue = -1
algorithmNamelist = ['INEC2_threepart_simu']
datasetNamelist = ["all_8_sim", "all_15_sim", "k_1_8s_sim","k_2_8s_sim", "k_3_8s_sim", "k_1_15s_sim", "k_2_15s_sim", "k_3_15s_sim", "k_2_8s_sim_q_1_num", "k_2_8s_sim_q_2_num",
                   "k_2_8s_sim_q_3_num", "k_2_15s_sim_q_1_num", "k_2_15s_sim_q_2_num",
                   "k_2_15s_sim_q_3_num"] #
# inpath_origin = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'
inpath_origin = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/'
continue_file = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/0101_0131_all_feature_involved_origin.csv'
continue_data = pd.read_csv(continue_file)

for m in datasetNamelist:
    datasetname = m
    inpaths = inpath_origin + datasetname + '/allDataReduce/'
    outpath = inpath_origin + datasetname + '/' + datasetname + '_Reduce_Acc.csv'
    originaldatapath = inpath_origin + datasetname + '/' + datasetname + '.csv'
    continue_datadf = pd.DataFrame(continue_data)
    continue_column = continue_datadf[datasetname]    # 找到对应列名的数值
    norm_continue_column = normalize(continue_column)    # 归一化
    for k in range(0, len(algorithmNamelist)):
        acclist = [[], [], [], []]
        mse_list, rmse_list, mae_list, r2_list, evs_list = [], [], [], [], []
        algorithmName = algorithmNamelist[k]
        for i in range(0, 10):
            mse_avg, rmse_avg, mae_avg, r2_avg, evs_avg = [], [], [], [], []
            datapaths = inpaths + datasetname + '_' + algorithmName + '_' + str(i) + '_IncrementalReduce.csv'
            datadf = pd.read_csv(datapaths, header=0)
            # print(datadf.shape)
            # 将csv中数据值为oldword的改写为newword
            new_data = []
            for index, col in datadf.items():
                # 从每列随机选取中一个值
                # ranValue=random.choice(col)
                # 选取一列中出现次数最多的值  离散型
                newcol = list(col)
                count = Counter(newcol).most_common(2)
                if count[0][0] == 100000 or count[0][0] == -1 or count[0][0] is None:
                    ranValue = count[1][0]
                else:
                    ranValue = count[0][0]
                # ranValue=max(set(newcol), key = newcol.count)
                # 选取一列中的平均值 连续型
                # meanvalue = np.array(col)
                # ranValue=np.mean(meanvalue)
                rep = [ranValue if x == 100000 or x == -1 else x for x in col]
                new_data.append(rep)
            datadf = pd.DataFrame(new_data)
            datadf = datadf.T
            last_column_name = datadf.columns[-1]
            datadf[last_column_name] = norm_continue_column   # 将最后一列替换为连续值归一化后的数据
            # print(norm_continue_column[0])

            kf = KFold(n_splits=10, shuffle=True)  # 初始化KFold
            train_files = []  # 存放10折的训练集划分
            test_files = []  # # 存放10折的测试集集划分

            for k, (Trindex, Tsindex) in enumerate(kf.split(datadf)):
                train_files.append(np.array(datadf)[Trindex].tolist())
                test_files.append(np.array(datadf)[Tsindex].tolist())

            for i in range(0, 10):
                train = pd.DataFrame(data=train_files[i])
                test = pd.DataFrame(data=test_files[i])
                train_features = train.iloc[:, 0:-1].values
                train_labels = train.iloc[:, -1].values
                test_features = test.iloc[:, 0:-1].values
                test_labels = test.iloc[:, -1].values

                # 创建基本回归模型 bagging
                base_model = DecisionTreeRegressor()
                # 创建 BaggingRegressor 模型，并指定基本模型数量为10
                bagging_model = BaggingRegressor(estimator=base_model, n_estimators=10, random_state=42)
                # 拟合模型
                bagging_model.fit(train_features, train_labels)
                # 预测
                y_pred = bagging_model.predict(test_features)
                # 计算均方误差 越小越好
                mse = mean_squared_error(test_labels, y_pred)
                # 计算 RMSE 越小越好
                rmse = mean_squared_error(test_labels, y_pred, squared=False)
                # 计算 MAE 越小越好
                mae = mean_absolute_error(test_labels, y_pred)
                # 计算 R平方 取值范围[0-1]越接近于1越好
                r2 = r2_score(test_labels, y_pred)
                # 计算解释方差分数 取值范围[0-1]越接近于1越好
                evs = explained_variance_score(test_labels, y_pred)
                # print("均方误差 (MSE):", mse)

                mse_avg.append(mse)
                rmse_avg.append(rmse)
                mae_avg.append(mae)
                r2_avg.append(r2)
                evs_avg.append(evs)
            mse_list.append(np.mean(mse_avg))
            rmse_list.append(np.mean(rmse_avg))
            mae_list.append(np.mean(mae_avg))
            r2_list.append(np.mean(r2_avg))
            evs_list.append(np.mean(evs_avg))
            # print("均方误差 (MSE):", mse_list, 'RMSE:', rmse_list, 'MAE:', mae_list, 'R^:2', r2_list, '解释方差分数：', evs_list)

        with open(outpath, 'a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(
                ['DataSet', 'MissingRatio', 'Algorithm', 'Regressor', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                 '10', 'avg'])
            writer.writerow(
                [datasetname, filenum, algorithmName, 'MSE', mse_list[0], mse_list[1], mse_list[2], mse_list[3],
                 mse_list[4], mse_list[5], mse_list[6], mse_list[7], mse_list[8], mse_list[9], sum(mse_list) / 10])
            writer.writerow(
                [datasetname, filenum, algorithmName, 'RMSE', rmse_list[0], rmse_list[1], rmse_list[2], rmse_list[3],
                 rmse_list[4], rmse_list[5], rmse_list[6], rmse_list[7], rmse_list[8], rmse_list[9], sum(rmse_list) / 10])
            writer.writerow(
                [datasetname, filenum, algorithmName, 'MAE', mae_list[0], mae_list[1], mae_list[2], mae_list[3],
                 mae_list[4], mae_list[5], mae_list[6], mae_list[7], mae_list[8], mae_list[9], sum(mae_list) / 10])
            writer.writerow(
                [datasetname, filenum, algorithmName, 'R2', r2_list[0], r2_list[1], r2_list[2], r2_list[3],
                 r2_list[4], r2_list[5], r2_list[6], r2_list[7], r2_list[8], r2_list[9], sum(r2_list) / 10])
            writer.writerow(
                [datasetname, filenum, algorithmName, 'EVS', evs_list[0], evs_list[1], evs_list[2], evs_list[3],
                 evs_list[4], evs_list[5], evs_list[6], evs_list[7], evs_list[8], evs_list[9], sum(evs_list) / 10])
    print(datasetname, "_reduce_Regressor完成")
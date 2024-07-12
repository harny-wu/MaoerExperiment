# 标准bagging 回归+输出
import csv
import os

from sklearn import svm
from sklearn.ensemble import BaggingRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn import tree
from sklearn.naive_bayes import MultinomialNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, accuracy_score, mean_absolute_error, r2_score, explained_variance_score
from sklearn.model_selection import KFold
from collections import Counter
import pandas as pd
import numpy as np

# 加载数据集
filenum = '15%'
algorithmName = ''
datasetname = 'user_pay_5'
outpath = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/'+datasetname+'/'+datasetname+'_Reduce_Acc.csv'
#datapaths = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/'+datasetname+'/'+datasetname+'.csv'
datapaths = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/user_pay_5/allDataReduce/user_pay_5_INEC2_threepart_simu_0_IncrementalReduce.csv'
datadf = pd.read_csv(datapaths, header=0)

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
    rep = [ranValue if x == 100000 or x == -1 or x is None else x for x in col]
    new_data.append(rep)
datadf = pd.DataFrame(new_data)
datadf = datadf.T

# 划分训练集和测试集
# X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
kf = KFold(n_splits=10, shuffle=True)  # 初始化KFold
train_files = []   # 存放10折的训练集划分
test_files = []     # # 存放10折的测试集集划分
acclist = [[], [], [], []]
#mse_list, rmse_list, mae_list, r2_list, evs_list = [], [], [], [], []
mse_avg, rmse_avg, mae_avg, r2_avg, evs_avg = [], [], [], [], []
for k, (Trindex, Tsindex) in enumerate(kf.split(datadf)):
    train_files.append(np.array(datadf)[Trindex].tolist())
    test_files.append(np.array(datadf)[Tsindex].tolist())

for i in range(0, 10):
    #mse_avg, rmse_avg, mae_avg, r2_avg, evs_avg = [], [], [], [], []
    train=pd.DataFrame(data=train_files[i])
    test=pd.DataFrame(data=test_files[i])
    train_features=train.iloc[:,0:-1].values
    train_labels=train.iloc[:,-1].values
    test_features=test.iloc[:,0:-1].values
    test_labels=test.iloc[:,-1].values

    # 创建基本回归模型 bagging
    base_model = DecisionTreeRegressor()
    # 创建 BaggingRegressor 模型，并指定基本模型数量为10
    bagging_model = BaggingRegressor(base_estimator=base_model, n_estimators=10, random_state=42)
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
    print("均方误差 (MSE):", mse, 'RMSE:', rmse, 'MAE:', mae, 'R^:2', r2, '解释方差分数：', evs)

    # 创建 BaggingRegressor 模型，并使用 DecisionTreeRegressor 作为基础模型
    base_model = DecisionTreeRegressor()
    bagging_model = BaggingRegressor(base_estimator=base_model, n_estimators=10, random_state=42)

    threshold = 0.5
    # 拟合模型
    bagging_model.fit(train_features, train_labels)
    # 预测
    y_pred = bagging_model.predict(test_features)
    # 将预测结果转化为二元分类结果
    y_pred_binary = [1 if value > threshold else 0 for value in y_pred]
    # 计算准确率
    accuracy = accuracy_score(test_labels,y_pred_binary)
    print(f"Accuracy: {accuracy}")

    mse_avg.append(mse)
    rmse_avg.append(rmse)
    mae_avg.append(mae)
    r2_avg.append(r2)
    evs_avg.append(evs)
# mse_list.append(np.mean(mse_avg))
# rmse_list.append(np.mean(rmse_avg))
# mae_list.append(np.mean(mae_avg))
# r2_list.append(np.mean(r2_avg))
# evs_list.append(np.mean(evs_avg))
# print("均方误差 (MSE):", mse_list, 'RMSE:', rmse_list, 'MAE:', mae_list, 'R^:2', r2_list, '解释方差分数：', evs_list)

with open(outpath, 'a', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(
        ['DataSet', 'MissingRatio', 'Algorithm', 'Regressor', '1', '2', '3', '4', '5', '6', '7', '8', '9',
         '10', 'avg'])
    writer.writerow(
        [datasetname, filenum, algorithmName, 'MSE', mse_avg[0], mse_avg[1], mse_avg[2], mse_avg[3],
         mse_avg[4], mse_avg[5], mse_avg[6], mse_avg[7], mse_avg[8], mse_avg[9], sum(mse_avg) / 10])
    writer.writerow(
        [datasetname, filenum, algorithmName, 'RMSE', rmse_avg[0], rmse_avg[1], rmse_avg[2], rmse_avg[3],
         rmse_avg[4], rmse_avg[5], rmse_avg[6], rmse_avg[7], rmse_avg[8], rmse_avg[9], sum(rmse_avg) / 10])
    writer.writerow(
        [datasetname, filenum, algorithmName, 'MAE', mae_avg[0], mae_avg[1], mae_avg[2], mae_avg[3],
         mae_avg[4], mae_avg[5], mae_avg[6], mae_avg[7], mae_avg[8], mae_avg[9], sum(mae_avg) / 10])
    writer.writerow(
        [datasetname, filenum, algorithmName, 'R2', r2_avg[0], r2_avg[1], r2_avg[2], r2_avg[3],
         r2_avg[4], r2_avg[5], r2_avg[6], r2_avg[7], r2_avg[8], r2_avg[9], sum(r2_avg) / 10])
    writer.writerow(
        [datasetname, filenum, algorithmName, 'EVS', evs_avg[0], evs_avg[1], evs_avg[2], evs_avg[3],
         evs_avg[4], evs_avg[5], evs_avg[6], evs_avg[7], evs_avg[8], evs_avg[9], sum(evs_avg) / 10])
print(datasetname, "_reduce_Regressor完成")

# from sklearn.ensemble import BaggingRegressor
# from sklearn.tree import DecisionTreeRegressor
# from sklearn.model_selection import train_test_split
# from sklearn.metrics import accuracy_score
#
# # 假设我们有一些特征 X 和对应的目标值 y
# X = [[1], [2], [3], [4], [5]]
# y = [0, 0, 1, 1, 0]
#
# # 将回归问题转化为二元分类问题
# threshold = 0.5
# y_binary = [1 if value > threshold else 0 for value in y]
#
# # 划分训练集和测试集
# X_train, X_test, y_train, y_test = train_test_split(X, y_binary, test_size=0.2, random_state=42)
#
# # 创建 BaggingRegressor 模型，并使用 DecisionTreeRegressor 作为基础模型
# base_model = DecisionTreeRegressor()
# bagging_model = BaggingRegressor(base_estimator=base_model, n_estimators=10, random_state=42)
#
# # 拟合模型
# bagging_model.fit(X_train, y_train)
#
# # 预测
# y_pred = bagging_model.predict(X_test)
#
# # 将预测结果转化为二元分类结果
# y_pred_binary = [1 if value > threshold else 0 for value in y_pred]
#
# # 计算准确率
# accuracy = accuracy_score(y_test, y_pred_binary)
# print(f"Accuracy: {accuracy}")
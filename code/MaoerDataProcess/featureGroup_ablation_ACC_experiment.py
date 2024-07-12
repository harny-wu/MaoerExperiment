# 对一组特征的消融实验ACC测试
# 数据文件要求：第一行为数字的列名代表特征编号，如[0, 3 9,24,56]最后一列为决策值，其中有缺失值表示可能为100000，-1，None
# 给定一组特征或直接按顺序选取特定列构成新数据集求ACC
import ast
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

def change_last_column_for_involved_continue(origin_df, new_input_path):
    # 记录原最后一列的列名
    column_name = origin_df.columns.tolist()
    origin_column_name = column_name[-1]
    # 读取另一个CSV文件，并获取其最后一列
    replacement_df = pd.read_csv(new_input_path)
    replacement_column = replacement_df.iloc[:, -1]  # 获取最后一列

    # 确保两个DataFrame有相同的行数
    if origin_df.shape[0] != replacement_df.shape[0]:
        raise ValueError("两个CSV文件的行数不匹配!")

        # 替换原始DataFrame的最后一列，并保持其他列的名称不变
    origin_df = origin_df.iloc[:, :-1].join(replacement_column.rename(origin_column_name))  # 将新列命名为'new_column_name'
    return origin_df
# 加载数据集
datasetNamelist = ['0101_0131_all_feature', '0101_0131_all_feature_involved',
                   '0115_0215_all_feature', '0115_0215_all_feature_involved',
                   '0201_0230_all_feature', '0201_0230_all_feature_involved',
                   '1101_1130_all_feature', '1101_1130_all_feature_involved',
                   '1115_1215_all_feature', '1115_1215_all_feature_involved',
                   '1201_1231_all_feature', '1201_1231_all_feature_involved',
                   '1215_0115_all_feature', '1215_0115_all_feature_involved']

# 获取所有时间窗的重合特征
commonset_input = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/maoer_FS_chonghe_ResultCount.csv'
all_commonset_data = []
# 初始化一个字典用于记录每个名称最后一次出现的行号
last_row_num = {}
with open(commonset_input, 'r') as f:
    reader = csv.reader(f)
    # 读取 CSV 文件的第一行作为列名
    headers = next(reader)
    for row in reader:
        name = row[0]
        # 如果名称在列表中，则更新该名称最后一次出现的行号
        if name in last_row_num:
            last_row_num[name] = row
        else:
            last_row_num[name] = row
    for name in last_row_num:
        all_commonset_data.append([name, ast.literal_eval(last_row_num[name][1])])   # 第二列为重合特征

for m in datasetNamelist:
    datasetname = m
    inpaths = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+datasetname+'/allDataReduce/'
    originaldatapath ='/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+datasetname+'/'+datasetname+'.csv'
    originaldatapath_continue = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/' + datasetname + '/' + datasetname + '_hasname_continue.csv'
    output_result = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/maoer_FS_chonghe_AblationResult.csv'
    # 自定义要同时消除的集合 多属性 即在删除该集合的基础上再看删除单特征的影响
    if 'involved' in datasetname:
        new_string = datasetname
        new_string = new_string.replace('_involved', '')
        zidinyi_ablation_featureset = ast.literal_eval(last_row_num[new_string][1])
    else:
        zidinyi_ablation_featureset = ast.literal_eval(last_row_num[datasetname][1])

    for i in range(0, 10):
        datapaths = inpaths + datasetname + '_INEC2_threepart_simu_' + str(i) + '_IncrementalReduce.csv'
        df = pd.read_csv(datapaths, header=0)
        column_name = df.columns.tolist() # 列名
        # 自定义消融的特征 单属性
        zidinyi_ablation_feature_list = [] # 要包含最后一列
        not_exist_commonset_feature = []
        if len(zidinyi_ablation_featureset)!=0:
            for column in zidinyi_ablation_featureset:
                if str(column) in df.columns:
                        df = df.drop(str(column), axis=1)
                else:
                    #print(f"Column '{column}' does not exist.")
                    not_exist_commonset_feature.append(column)
        # if 'involved' in datasetname:
        #     df = change_last_column_for_involved_continue(df, originaldatapath_continue) #替换最后一列为连续值
        column_name = df.columns.tolist() # 列名
        print("剩余特征：", column_name, ',长度,', len(column_name),'，不存在的特征：', not_exist_commonset_feature, ',长度,', len(not_exist_commonset_feature))

        if len(column_name) <= 2:
            print('该数据集剩余特征只剩一个：', datapaths)
            continue

        ablation_feature_list = []
        if len(zidinyi_ablation_feature_list)==0:
            ablation_feature_list = [str(num) for num in column_name]
        else:
            ablation_feature_list = [str(num) for num in zidinyi_ablation_feature_list]

        # 单个消除
        for n in range(-1, len(ablation_feature_list)-1):  # -1开始代表剩余特征全集
            delete_feature = -1 #删除的特征
            if n!=-1:
                datadf = df.drop(ablation_feature_list[n], axis=1)
                delete_feature = ablation_feature_list[n]
            else:    # 第一个 先计算取出好重合特征的结果
                datadf = df
            reminder_feature = datadf.columns.tolist()

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
            acc1_list, acc2_list, acc3_list, acc4_list = [], [], [], []
            mse_list, rmse_list, mae_list, r2_list, evs_list = [], [], [], [], []
            for k, (Trindex, Tsindex) in enumerate(kf.split(datadf)):
                train_files.append(np.array(datadf)[Trindex].tolist())
                test_files.append(np.array(datadf)[Tsindex].tolist())

            for i in range(0, 10):
                train=pd.DataFrame(data=train_files[i])
                test=pd.DataFrame(data=test_files[i])
                train_features=train.iloc[:,0:-1].values
                train_labels=train.iloc[:,-1].values
                test_features=test.iloc[:,0:-1].values
                test_labels=test.iloc[:,-1].values

                # if 'involved' in datasetname:
                #     # 创建基本回归模型 bagging
                #     base_model = DecisionTreeRegressor()
                #     # 创建 BaggingRegressor 模型，并指定基本模型数量为10
                #     bagging_model = BaggingRegressor(base_estimator=base_model, n_estimators=10, random_state=42)
                #     # 拟合模型
                #     bagging_model.fit(train_features, train_labels)
                #     # 预测
                #     y_pred = bagging_model.predict(test_features)
                #     # 计算均方误差 越小越好
                #     mse = mean_squared_error(test_labels, y_pred)
                #     # 计算 RMSE 越小越好
                #     rmse = mean_squared_error(test_labels, y_pred, squared=False)
                #     # 计算 MAE 越小越好
                #     mae = mean_absolute_error(test_labels, y_pred)
                #     # 计算 R平方 取值范围[0-1]越接近于1越好
                #     r2 = r2_score(test_labels, y_pred)
                #     # 计算解释方差分数 取值范围[0-1]越接近于1越好
                #     evs = explained_variance_score(test_labels, y_pred)
                #     # print("均方误差 (MSE):", mse)
                #     mse_list.append(mse), rmse_list.append(rmse), mae_list.append(mae), r2_list.append(r2), evs_list.append(evs)
                #     # print("删除第", n + 1, "个特征的结果：")
                #     # print("均方误差 (MSE):", mse, 'RMSE:', rmse, 'MAE:', mae, 'R^:2', r2, '解释方差分数：', evs)
                # else:
                # SVM
                clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                acc1 = accuracy_score(y_hat, test_labels)
                acc1_list.append(acc1)
                # C4.5
                clf = tree.DecisionTreeClassifier()  # CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                acc2 = accuracy_score(y_hat, test_labels)
                acc2_list.append(acc2)
                # NB
                clf = MultinomialNB(alpha=2.0, fit_prior=True, class_prior=None)  # clf=GaussianNB()
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                acc3 = accuracy_score(y_hat, test_labels)
                acc3_list.append(acc3)
                # KNN K=3
                clf = KNeighborsClassifier(n_neighbors=3)
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                acc4 = accuracy_score(y_hat, test_labels)
                acc4_list.append(acc4)
                # print("删除第", n+1, "个特征的结果：")
                # print('SVM_ACC:', acc1_list, ' ,avg=', sum(acc1_list)/len(acc1_list))
                # print('C4.5_ACC:', acc2_list, ' ,avg=', sum(acc2_list)/len(acc2_list))
                # print('NB_ACC:', acc3_list, ' ,avg=', sum(acc3_list)/len(acc3_list))
                # print('KNN_ACC:', acc4_list, ' ,avg=', sum(acc4_list)/len(acc4_list))
                # print('SVM_ACC_avg=', sum(acc1_list) / len(acc1_list), ',C4.5_ACC_avg=', sum(acc2_list) / len(acc2_list), ',NB_ACC_avg=', sum(acc3_list) / len(acc3_list), ',KNN_ACC_avg=', sum(acc4_list) / len(acc4_list))
            print("删除第", n + 1, "个特征的结果(第0个结果代表剩余特征全集)：")
            # if 'involved' in datasetname:
            #     print('MSE_avg=', sum(mse_list) / len(mse_list), ',RMSE_avg=', sum(rmse_list) / len(rmse_list), ',MAE_avg=', sum(mae_list) / len(mae_list), ',r2_avg=', sum(r2_list) / len(r2_list), ',EVS_avg=', sum(evs_list) / len(evs_list) )
            #     with open(output_result, 'a', newline='') as file:
            #         writer = csv.writer(file)
            #         writer.writerow(['DataSet', '去重重合部分后删除的特征', '剩余特征', 'MSE', 'RMSE', 'MAE', 'r2', 'EVS'])
            #         writer.writerow(
            #             [datapaths, delete_feature, datadf.columns.tolist(), sum(mse_list) / len(mse_list),
            #              sum(rmse_list) / len(rmse_list), sum(mae_list) / len(mae_list),
            #              sum(r2_list) / len(r2_list), sum(evs_list) / len(evs_list)])
            # else:
            print('SVM_ACC_avg=', sum(acc1_list) / len(acc1_list), ',C4.5_ACC_avg=', sum(acc2_list) / len(acc2_list), ',NB_ACC_avg=', sum(acc3_list) / len(acc3_list), ',KNN_ACC_avg=', sum(acc4_list) / len(acc4_list))
            with open(output_result, 'a', newline='') as file:
                writer = csv.writer(file)
                writer.writerow(['DataSet', '去重重合部分后删除的特征', '剩余特征', 'SVM', 'C4.5', 'NB', 'KNN'])
                writer.writerow(
                    [datapaths, delete_feature, reminder_feature, sum(acc1_list) / len(acc1_list),
                     sum(acc2_list) / len(acc2_list), sum(acc3_list) / len(acc3_list),
                     sum(acc4_list) / len(acc4_list)])
        print('****************完成数据集：', datapaths)
            # 输出
            # if not os.path.exists(output_result):
            #     # os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
            #     with open(output_result, 'a', newline='') as file:
            #         writer = csv.writer(file)
            #         writer.writerow(['DataSet', '去重重合部分后删除的特征', '剩余特征', 'SVM', 'C4.5', 'NB', 'KNN'])
            # with open(output_result, 'a', newline='') as file:
            #     writer = csv.writer(file)
            #     writer.writerow(['DataSet', '去重重合部分后删除的特征', '剩余特征', 'SVM', 'C4.5', 'NB', 'KNN'])
            #     writer.writerow([datapaths, delete_feature, datadf.columns.tolist(), sum(acc1_list) / len(acc1_list),
            #                      sum(acc2_list) / len(acc2_list), sum(acc3_list) / len(acc3_list), sum(acc4_list) / len(acc4_list)])
# 集合消除
# datadf = df.drop(ablation_feature_list[:-1], axis=1)
# # 将csv中数据值为oldword的改写为newword
# new_data = []
# for index, col in datadf.items():
#     # 从每列随机选取中一个值
#     # ranValue=random.choice(col)
#     # 选取一列中出现次数最多的值  离散型
#     newcol = list(col)
#     count = Counter(newcol).most_common(2)
#     if (count[0][0] == 100000 or count[0][0] == -1 or count[0][0] is None):
#         ranValue = count[1][0]
#     else:
#         ranValue = count[0][0]
#     # ranValue=max(set(newcol), key = newcol.count)
#     # 选取一列中的平均值 连续型
#     # meanvalue = np.array(col)
#     # ranValue=np.mean(meanvalue)
#     rep = [ranValue if x == 100000 or x == -1 or x is None else x for x in col]
#     new_data.append(rep)
# datadf = pd.DataFrame(new_data)
# datadf = datadf.T
#
# # 划分训练集和测试集
# # X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
# kf = KFold(n_splits=10, shuffle=True)  # 初始化KFold
# train_files = []   # 存放10折的训练集划分
# test_files = []     # # 存放10折的测试集集划分
# acc1_list = []
# acc2_list = []
# acc3_list = []
# acc4_list = []
# for k, (Trindex, Tsindex) in enumerate(kf.split(datadf)):
#     train_files.append(np.array(datadf)[Trindex].tolist())
#     test_files.append(np.array(datadf)[Tsindex].tolist())
#
# for i in range(0, 10):
#     train=pd.DataFrame(data=train_files[i])
#     test=pd.DataFrame(data=test_files[i])
#     train_features=train.iloc[:,0:-1].values
#     train_labels=train.iloc[:,-1].values
#     test_features=test.iloc[:,0:-1].values
#     test_labels=test.iloc[:,-1].values
#
#     # # 创建基本回归模型 bagging
#     # base_model = DecisionTreeRegressor()
#     # # 创建 BaggingRegressor 模型，并指定基本模型数量为10
#     # bagging_model = BaggingRegressor(base_estimator=base_model, n_estimators=10, random_state=42)
#     # # 拟合模型
#     # bagging_model.fit(train_features, train_labels)
#     # # 预测
#     # y_pred = bagging_model.predict(test_features)
#     # # 计算均方误差 越小越好
#     # mse = mean_squared_error(test_labels, y_pred)
#     # # 计算 RMSE 越小越好
#     # rmse = mean_squared_error(test_labels, y_pred, squared=False)
#     # # 计算 MAE 越小越好
#     # mae = mean_absolute_error(test_labels, y_pred)
#     # # 计算 R平方 取值范围[0-1]越接近于1越好
#     # r2 = r2_score(test_labels, y_pred)
#     # # 计算解释方差分数 取值范围[0-1]越接近于1越好
#     # evs = explained_variance_score(test_labels, y_pred)
#     # # print("均方误差 (MSE):", mse)
#     # print("均方误差 (MSE):", mse, 'RMSE:', rmse, 'MAE:', mae, 'R^:2', r2, '解释方差分数：', evs)
#
#     # SVM
#     clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
#     clf.fit(train_features, train_labels)
#     y_hat = clf.predict(test_features)
#     acc1 = accuracy_score(y_hat, test_labels)
#     acc1_list.append(acc1)
#     # C4.5
#     clf = tree.DecisionTreeClassifier()  # CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
#     clf.fit(train_features, train_labels)
#     y_hat = clf.predict(test_features)
#     acc2 = accuracy_score(y_hat, test_labels)
#     acc2_list.append(acc2)
#     # NB
#     clf = MultinomialNB(alpha=2.0, fit_prior=True, class_prior=None)  # clf=GaussianNB()
#     clf.fit(train_features, train_labels)
#     y_hat = clf.predict(test_features)
#     acc3 = accuracy_score(y_hat, test_labels)
#     acc3_list.append(acc3)
#     # KNN K=3
#     clf = KNeighborsClassifier(n_neighbors=3)
#     clf.fit(train_features, train_labels)
#     y_hat = clf.predict(test_features)
#     acc4 = accuracy_score(y_hat, test_labels)
#     acc4_list.append(acc4)
# print("删除这些特征后的结果：", ablation_feature_list)
# print('SVM_ACC:', acc1_list, ' ,avg=', sum(acc1_list)/len(acc1_list))
# print('C4.5_ACC:', acc2_list, ' ,avg=', sum(acc2_list)/len(acc2_list))
# print('NB_ACC:', acc3_list, ' ,avg=', sum(acc3_list)/len(acc3_list))
# print('KNN_ACC:', acc4_list, ' ,avg=', sum(acc4_list)/len(acc4_list))
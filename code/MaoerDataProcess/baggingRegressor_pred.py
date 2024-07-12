# bagging 回归 也包含SVM C4.5 NB KNN分类 （可选）
import csv
import os

from sklearn import svm
from sklearn.ensemble import BaggingRegressor
from sklearn.tree import DecisionTreeRegressor
from sklearn import tree
from sklearn.naive_bayes import MultinomialNB, GaussianNB
from sklearn.neighbors import KNeighborsClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, accuracy_score, mean_absolute_error, r2_score, explained_variance_score
from sklearn.model_selection import KFold
from collections import Counter
import pandas as pd
import numpy as np
from sklearn.metrics import roc_auc_score, f1_score, accuracy_score, recall_score, precision_score, roc_curve, confusion_matrix
from _collections import OrderedDict  # 导入 OrderedDict 来保持字典中键值对的顺序

# 自动评估阈值，计算ACC 、 Precision 等评估指标
def evaluate(y_true, y_pred, digits=4, cutoff='auto'):
    '''
    Args:
        y_true: list, labels, y_pred: list, predictions, digits: The number of decimals to use when rounding the number. Default is 4（保留小数后几位）
        cutoff: float or 'auto'
    Returns:
        evaluation: dict
    '''
    # 根据预测概率值y_pred计算最佳的切分阈值
    if cutoff == 'auto':
        fpr, tpr, thresholds = roc_curve(y_true, y_pred)
        youden = tpr-fpr
        cutoff = thresholds[np.argmax(youden)]
    y_pred_t = [1 if i > cutoff else 0 for i in y_pred]

    evaluation = OrderedDict()
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred_t).ravel()
    evaluation['auc'] = round(roc_auc_score(y_true, y_pred), digits)
    evaluation['acc'] = round(accuracy_score(y_true, y_pred_t), digits)
    evaluation['recall'] = round(recall_score(y_true, y_pred_t), digits)
    evaluation['precision'] = round(precision_score(y_true, y_pred_t), digits)
    evaluation['specificity'] = round(tn / (tn + fp), digits)
    evaluation['F1'] = round(f1_score(y_true, y_pred_t), digits)
    evaluation['cutoff'] = cutoff

    return evaluation

# 加载数据集
datasetname = '0101_0131_all_feature'
inpaths = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+datasetname+'/allDataReduce/'
# outpath = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+datasetname+'/'+datasetname+'_Reduce_Acc.csv'
# datapaths = inpaths+datasetname+'_INEC2_threepart_simu_1_IncrementalReduce.csv'
# datapaths =  '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+datasetname+'/'+datasetname+'.csv'
# datapaths =  '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+datasetname+'/0101_0131_all_feature_involved.csv'
# datapaths = "/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/"+datasetname+"/"+"calculate_repeat_feature_Reduce.csv"
# datapaths = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/0101_0131_all_feature/calculate_repeat_feature_Reduce.csv'
# datapaths = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/user_pay_5/allDataReduce/user_pay_5_INEC2_threepart_simu_0_IncrementalReduce.csv'
datapaths = '/Users/ly/Desktop/工作/大论文/数据/maoer_feature_deal_code/Interpretable_DL_Model/Dataset/0101_0131_user_pay_pred_feature_deal.csv'
datadf = pd.read_csv(datapaths, header=0)

# 将csv中数据值为oldword的改写为newword
# new_data = []
# for index, col in datadf.items():
#     # 从每列随机选取中一个值
#     # ranValue=random.choice(col)
#     # 选取一列中出现次数最多的值  离散型
#     newcol = list(col)
#     count = Counter(newcol).most_common(2)
#     if count[0][0] == 100000 or count[0][0] == -1 or count[0][0] is None:
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

# 另外找空值的方法
# 找到具有缺失值的列并返回列名
columns_with_missing_values = datadf.columns[datadf.isnull().any()].tolist()
# 离散值 使用出现次数最多的非空值填充空值
most_common_values = datadf[columns_with_missing_values].mode().iloc[0]
datadf[columns_with_missing_values] = datadf[columns_with_missing_values].fillna(most_common_values)

# 连续值 均值填充
# datadf[columns_with_missing_values] = datadf[columns_with_missing_values].fillna(datadf[columns_with_missing_values].mean())

# 划分训练集和测试集
# X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
kf = KFold(n_splits=10, shuffle=True)  # 初始化KFold
train_files = []   # 存放10折的训练集划分
test_files = []     # # 存放10折的测试集集划分
acc1_list, acc2_list, acc3_list, acc4_list = [], [], [], []
f11_list, f12_list, f13_list, f14_list = [], [], [], []
auc1_list, auc2_list, auc3_list, auc4_list = [], [], [], []
recall1_list, recall2_list, recall3_list, recall4_list = [], [], [], []
precision1_list, precision2_list, precision3_list, precision4_list = [], [], [], []
for k, (Trindex, Tsindex) in enumerate(kf.split(datadf)):
    train_files.append(np.array(datadf)[Trindex].tolist())
    test_files.append(np.array(datadf)[Tsindex].tolist())

for i in range(0, 10):
    train = pd.DataFrame(data=train_files[i])
    test = pd.DataFrame(data=test_files[i])
    train_features = train.iloc[:, 0:-2].values
    train_labels = train.iloc[:, -1].values
    test_features = test.iloc[:, 0:-2].values
    test_labels = test.iloc[:, -1].values
    # 将 y_true 中的 2 替换为 1，将 1 替换为 0
    train_labels = np.where(train_labels == 2, 1, 0)
    test_labels = np.where(test_labels == 2, 1, 0)

    # # 创建基本回归模型 bagging
    # base_model = DecisionTreeRegressor()
    # # 创建 BaggingRegressor 模型，并指定基本模型数量为10
    # bagging_model = BaggingRegressor(base_estimator=base_model, n_estimators=10, random_state=42)
    # # 拟合模型
    # bagging_model.fit(train_features, train_labels)
    # # 预测
    # y_pred = bagging_model.predict(test_features)
    # # 计算均方误差 越小越好
    # mse = mean_squared_error(test_labels, y_pred)
    # # 计算 RMSE 越小越好
    # rmse = mean_squared_error(test_labels, y_pred, squared=False)
    # # 计算 MAE 越小越好
    # mae = mean_absolute_error(test_labels, y_pred)
    # # 计算 R平方 取值范围[0-1]越接近于1越好
    # r2 = r2_score(test_labels, y_pred)
    # # 计算解释方差分数 取值范围[0-1]越接近于1越好
    # evs = explained_variance_score(test_labels, y_pred)
    # # print("均方误差 (MSE):", mse)
    # print("均方误差 (MSE):", mse, 'RMSE:', rmse, 'MAE:', mae, 'R^:2', r2, '解释方差分数：', evs)

    # SVM
    clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr', probability=True)
    clf.fit(train_features, train_labels)
    y_hat = clf.predict(test_features)
    # acc1 = accuracy_score(y_hat, test_labels)
    # acc1_list.append(acc1)
    # 自动评估阈值计算ACC等值
    y_pro = clf.predict_proba(test_features)
    y_pro = y_pro[:, 0]
    evaluate_dict = evaluate(test_labels, y_pro)
    acc1_list.append(evaluate_dict['acc'])
    auc1_list.append(evaluate_dict['auc'])
    f11_list.append(evaluate_dict['F1'])
    recall1_list.append(evaluate_dict['recall'])
    precision1_list.append(evaluate_dict['precision'])

    # C4.5
    clf = tree.DecisionTreeClassifier()  # CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
    clf.fit(train_features, train_labels)
    y_hat = clf.predict(test_features)
    # acc2 = accuracy_score(y_hat, test_labels)
    # acc2_list.append(acc2)
    # 自动评估阈值计算ACC等值
    y_pro = clf.predict_proba(test_features)
    y_pro = y_pro[:, 0]
    evaluate_dict = evaluate(test_labels, y_pro)
    acc2_list.append(evaluate_dict['acc'])
    auc2_list.append(evaluate_dict['auc'])
    f12_list.append(evaluate_dict['F1'])
    recall2_list.append(evaluate_dict['recall'])
    precision2_list.append(evaluate_dict['precision'])

    # NB
    clf = GaussianNB(var_smoothing=1e-9)  # clf=GaussianNB()
    clf.fit(train_features, train_labels)
    y_hat = clf.predict(test_features)
    # acc3 = accuracy_score(y_hat, test_labels)
    # acc3_list.append(acc3)
    # 自动评估阈值计算ACC等值
    y_pro = clf.predict_proba(test_features)
    y_pro = y_pro[:, 0]
    evaluate_dict = evaluate(test_labels, y_pro)
    acc3_list.append(evaluate_dict['acc'])
    auc3_list.append(evaluate_dict['auc'])
    f13_list.append(evaluate_dict['F1'])
    recall3_list.append(evaluate_dict['recall'])
    precision3_list.append(evaluate_dict['precision'])
    # KNN K=3
    clf = KNeighborsClassifier(n_neighbors=3)
    clf.fit(train_features, train_labels)
    y_hat = clf.predict(test_features)
    # acc4 = accuracy_score(y_hat, test_labels)
    # acc4_list.append(acc4)
    # 自动评估阈值计算ACC等值
    y_pro = clf.predict_proba(test_features)
    y_pro = y_pro[:, 0]
    evaluate_dict = evaluate(test_labels, y_pro)
    acc4_list.append(evaluate_dict['acc'])
    auc4_list.append(evaluate_dict['auc'])
    f14_list.append(evaluate_dict['F1'])
    recall4_list.append(evaluate_dict['recall'])
    precision4_list.append(evaluate_dict['precision'])
# print('SVM_ACC:', acc1_list, ' ,avg=', sum(acc1_list)/len(acc1_list))
# print('C4.5_ACC:', acc2_list, ' ,avg=', sum(acc2_list)/len(acc2_list))
# print('NB_ACC:', acc3_list, ' ,avg=', sum(acc3_list)/len(acc3_list))
# print('KNN_ACC:', acc4_list, ' ,avg=', sum(acc4_list)/len(acc4_list))
print('SVM---ACC:', sum(acc1_list)/len(acc1_list), ',AUC:', sum(auc1_list)/len(auc1_list), ',F1:', sum(f11_list)/len(f11_list), ',Recall:', sum(recall1_list)/len(recall1_list), ',Precision:', sum(precision1_list)/len(precision1_list))
print('C4.5---ACC:', sum(acc2_list)/len(acc2_list), ',AUC:', sum(auc2_list)/len(auc2_list), ',F1:', sum(f12_list)/len(f12_list), ',Recall:', sum(recall2_list)/len(recall2_list), ',Precision:', sum(precision2_list)/len(precision2_list))
print('NB---ACC:', sum(acc3_list)/len(acc3_list), ',AUC:', sum(auc3_list)/len(auc3_list), ',F1:', sum(f13_list)/len(f13_list), ',Recall:', sum(recall3_list)/len(recall3_list), ',Precision:', sum(precision3_list)/len(precision3_list))
print('KNN---ACC:', sum(acc4_list)/len(acc4_list), ',AUC:', sum(auc4_list)/len(auc4_list), ',F1:', sum(f14_list)/len(f14_list), ',Recall:', sum(recall4_list)/len(recall4_list), ',Precision:', sum(precision4_list)/len(precision4_list))



#     acc1 = accuracy_score(y_pred, test_labels)
#     acc1_list.append(acc1)
# acc1_list.append(np.mean(acc1_list))
# print([datasetname, 'baggingRegressor', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3],acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8],acc1_list[9], sum(acc1_list) / 10])

# 输出
# if not os.path.exists(outpath):
#     # os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
#     with open(outpath, 'a', newline='') as file:
#         writer = csv.writer(file)
#         writer.writerow(
#             ['DataSet', 'MissingRatio', 'Algorithm', 'Classifier', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10','avg_acc'])
# with open(outpath, 'a', newline='') as file:
#     writer = csv.writer(file)
#     writer.writerow([datasetname, '15%', 'IncrementalReduce', 'baggingRegressor', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3],acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8],acc1_list[9], sum(acc1_list) / 10])
# print(datasetname, "baggingRegressor_reduce_Acc完成")

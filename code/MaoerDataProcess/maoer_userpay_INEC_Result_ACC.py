# 针对猫耳数据，计算在用户契合度得到的约简集合将最后一列替换为用户付费的ACC结果
# 数据要求：获取用户契合度得到的结果集作为C，获取总数据集中用户付费的那一列作为D，计算ACC
# 十倍交叉验证 SVM KNN C4.5 NB

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
from sklearn import preprocessing
from sklearn import tree
from sklearn.naive_bayes import GaussianNB
from sklearn.naive_bayes import MultinomialNB
from sklearn.neighbors import RadiusNeighborsClassifier
from sklearn.neighbors import KNeighborsClassifier
import random
from collections import Counter
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader, TensorDataset

# 数据读取
# 读取文件夹下所有csv文件进行SVM
# 数据说明：各个算法进行5次的特征选择得到一个reduce文件 例 AR10P_INEC2_0_Reduce.csv
import os
import csv

# 自定义数据集类
class CustomDataset(Dataset):
    def __init__(self, data, labels):
        self.data = data
        self.labels = labels
        self.num_classes = len(set(labels))  # 计算标签的类型数

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        sample = {
            'data': self.data[idx],
            'label': self.labels[idx],
            'num_classes': self.num_classes,  # 返回标签的类型数
            'feature_dim': len(self.data[idx])  # 返回特征维度
        }
        return sample
# 自定义数据加载器
class DynamicDataLoader(DataLoader):
    def __init__(self, dataset, batch_size):
        super().__init__(dataset, batch_size, shuffle=True)

    def __iter__(self):
        for batch in super().__iter__():
            yield batch
            # yield [{key: sample[key] for key in sample} for sample in batch]

# 定义 DNN 模型
class DNN(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim):
        super(DNN, self).__init__()
        self.fc1 = nn.Linear(input_dim, hidden_dim)
        self.fc2 = nn.Linear(hidden_dim, output_dim)

    def forward(self, x):
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return F.log_softmax(x, dim=1)

# 标签值映射到从0开始的整数上
def map_labels_to_int(labels):
    label_map = {}  # 创建空字典用于存储标签值到整数的映射关系
    mapped_labels = []  # 存储映射后的整数标签列表
    count = 0  # 用于生成从 0 开始的整数

    for label in labels:
        if label not in label_map:
            label_map[label] = count
            count += 1
        mapped_labels.append(label_map[label])

    return mapped_labels, label_map  # 映射后的整数标签列表，标签映射关系

# DNN预测 输入：训练数据、训练label，测试数据，特征维度
def DNNPred(train_data, train_label, test_data, origin_batch_size):
    # 构建 PyTorch 的数据集和数据加载器
    mapped_labels, _ = map_labels_to_int(train_label)
    dataset = CustomDataset(train_data, mapped_labels)
    hidden_dim = 128  # 隐藏层维度
    input_dim = dataset[0]['feature_dim']  # 输入特征维度
    output_dim = dataset[0]['num_classes']   # 输出类别数
    dynamic_loader = DynamicDataLoader(dataset, origin_batch_size)  # 动态形成 batchSize
    model = DNN(input_dim, hidden_dim, output_dim)
    # 定义损失函数和优化器
    criterion = nn.NLLLoss()  # 负对数似然损失函数
    optimizer = optim.Adam(model.parameters(), lr=0.001)

    # 训练模型
    epochs = 10
    for epoch in range(epochs):
        model.train()

        # 使用动态数据加载器进行训练
        for batch in dynamic_loader:
            # inputs = torch.tensor([sample['data'] for sample in batch])  # 提取数据部分并转换为张量
            # targets = torch.tensor([sample['label'] for sample in batch])  # 提取标签部分并转换为张量
            inputs = torch.tensor(np.array(batch['data']), dtype=torch.float)  # 提取数据部分并转换为张量
            targets = batch['label'].clone().detach()  # 提取标签部分并转换为张量


            optimizer.zero_grad()
            outputs = model(inputs)
            # print(inputs, targets, outputs)
            loss = criterion(outputs, targets)
            loss.backward()
            optimizer.step()

        # 使用训练好的模型进行预测
        # 假设有测试数据 test_data
        # test_data 的形状为 (样本数, 特征维度)
        with torch.no_grad():
            model.eval()
            predictions = model(torch.Tensor(test_data))
            predicted_classes = torch.argmax(predictions, dim=1)
        return predicted_classes


filenum = '15%'
Type = 'Incremental'
missingValue = -1
algorithmNamelist = ['INEC2_threepart_simu']
# 特征选择实验
datasetNamelist = ['0101_0131_all_feature',
                   '0115_0215_all_feature',
                   '0201_0230_all_feature',
                   '1101_1130_all_feature',
                   '1115_1215_all_feature',
                   '1201_1231_all_feature',
                   '1215_0115_all_feature']
inpath_origin = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'

# 量化方法实验
# datasetNamelist = ["all_8_sim", "all_15_sim", "k_2_8s_sim", "k_2_15s_sim", "k_1_8s_sim", "k_3_8s_sim", "k_1_15s_sim",
#                    "k_3_15s_sim", "k_2_8s_sim_q_1_num", "k_2_8s_sim_q_2_num", "k_2_8s_sim_q_3_num",
#                    "k_2_15s_sim_q_1_num", "k_2_15s_sim_q_2_num",
#                    "k_2_15s_sim_q_3_num"]
# inpath_origin = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/'
# user_pay_file = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/0101_0131_all_feature_involved/0101_0131_all_feature_involved_hasname_all.csv'
user_pay_file = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/user_pay/user_pay.csv'
user_pay_data = pd.read_csv(user_pay_file)
user_pay = user_pay_data.iloc[:, -1]

for m in datasetNamelist:
    datasetname = m

    # 特征选择实验
    # inpaths = inpath_origin + datasetname + '_involved/allDataReduce/'
    # outpath = inpath_origin + datasetname + '_involved/' + datasetname + '_involved_Reduce_Acc.csv'
    # originaldatapath = inpath_origin + datasetname + '_involved/' + datasetname + '_involved.csv'
    # user_pay_file = inpath_origin + datasetname + '/' + datasetname + '.csv'
    # user_pay_data = pd.read_csv(user_pay_file)
    # user_pay = user_pay_data.iloc[:, -1]

    # 量化方法实验
    inpaths = inpath_origin + datasetname + '/allDataReduce/'
    outpath = inpath_origin + datasetname + '/' + datasetname + '_Reduce_Acc.csv'
    originaldatapath = inpath_origin + datasetname + '/' + datasetname + '.csv'

    for k in range(0, len(algorithmNamelist)):
        acclist = [[], [], [], []]
        acc1_list = []
        acc2_list = []
        acc3_list = []
        acc4_list = []
        acc5_list = []
        algorithmName = algorithmNamelist[k]
        for i in range(0, 10):
            acc1_list_avg = []
            acc2_list_avg = []
            acc3_list_avg = []
            acc4_list_avg = []
            acc5_list_avg = []
            # 特征选择实验
            #datapaths = inpaths + datasetname + '_involved_' + algorithmName + '_' + str(i) + '_IncrementalReduce.csv'
            # 量化方法实验
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
            datadf[last_column_name] = user_pay   #将最后一列替换为user_pay数据

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

                # SVM
                clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                acc1 = accuracy_score(y_hat, test_labels)
                acc1_list_avg.append(acc1)
                # C4.5
                clf = tree.DecisionTreeClassifier()  # CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                acc2 = accuracy_score(y_hat, test_labels)
                acc2_list_avg.append(acc2)
                # NB
                clf = MultinomialNB(alpha=2.0, fit_prior=True, class_prior=None)  # clf=GaussianNB()
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                acc3 = accuracy_score(y_hat, test_labels)
                acc3_list_avg.append(acc3)
                # KNN K=3
                clf = KNeighborsClassifier(n_neighbors=3)
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                acc4 = accuracy_score(y_hat, test_labels)
                acc4_list_avg.append(acc4)
                # DNN
                # y_hat = DNNPred(train_features, train_labels, test_features, 128)
                # acc5 = accuracy_score(y_hat, test_labels)
                # acc5_list_avg.append(acc5)

                # print(algorithmName,',SVM,',acc1,',C4.5,',acc2,',NB,',acc3,',KNN,',acc4)
            acc1_list.append(np.mean(acc1_list_avg))
            acc2_list.append(np.mean(acc2_list_avg))
            acc3_list.append(np.mean(acc3_list_avg))
            acc4_list.append(np.mean(acc4_list_avg))
            # acc5_list.append(np.mean(acc5_list_avg))
            # print(acc5_list)

        if not os.path.exists(outpath):
            # os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
            with open(outpath, 'a', newline='') as file:
                writer = csv.writer(file)
                writer.writerow(
                    ['DataSet', 'MissingRatio', 'Algorithm', 'Classifier', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                     '10', 'avg_acc'])
        with open(outpath, 'a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(
                [datasetname, 'change_user_pay', algorithmName, 'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3],
                 acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8], acc1_list[9],
                 sum(acc1_list) / 10])
            writer.writerow(
                [datasetname, 'change_user_pay', algorithmName, 'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3],
                 acc2_list[4], acc2_list[5], acc2_list[6], acc2_list[7], acc2_list[8], acc2_list[9],
                 sum(acc2_list) / 10])
            writer.writerow(
                [datasetname, 'change_user_pay', algorithmName, 'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3],
                 acc3_list[4], acc3_list[5], acc3_list[6], acc3_list[7], acc3_list[8], acc3_list[9],
                 sum(acc3_list) / 10])
            writer.writerow(
                [datasetname, 'change_user_pay', algorithmName, 'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3],
                 acc4_list[4], acc4_list[5], acc4_list[6], acc4_list[7], acc4_list[8], acc4_list[9],
                 sum(acc4_list) / 10])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3],acc1_list[4],sum(acc1_list)/5])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3],acc2_list[4], sum(acc2_list)/5])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3],acc3_list[4], sum(acc3_list)/5])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3],acc4_list[4], sum(acc4_list)/5])
    print(datasetname, "_reduce_Acc完成")



#INEC实验ACC
#十倍交叉验证
# SVM KNN C4.5 NB

#需求：读取文件夹下reduce中文件训练求ACC
import pandas as pd
import numpy as np
import os

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, roc_auc_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score
from sklearn.metrics import roc_curve, auc
# import matplotlib.pylab as plt
from sklearn import datasets
from sklearn import svm

from sklearn.model_selection import KFold
from sklearn import preprocessing
from sklearn import tree
from sklearn.naive_bayes import GaussianNB
from sklearn.naive_bayes import MultinomialNB
from sklearn.neighbors import RadiusNeighborsClassifier 
from sklearn.neighbors import KNeighborsClassifier 
import random
from collections import Counter

#数据读取
#读取文件夹下所有csv文件进行SVM
#数据说明：各个算法进行5次的特征选择得到一个reduce文件 例 AR10P_INEC2_0_Reduce.csv
import os
from glob import glob
import csv
filenum = '15%'
Type = 'Incremental'
missingValue = -1
algorithmNamelist = ['INEC2_threepart_simu']
datasetNamelist =["51_long_feature_201706_201708"]
# datasetNamelist = ['0101_0131_all_feature', '0101_0131_all_feature_involved',
#                    '0115_0215_all_feature', '0115_0215_all_feature_involved',
#                    '0201_0230_all_feature', '0201_0230_all_feature_involved',
#                    '1101_1130_all_feature', '1101_1130_all_feature_involved',
#                    '1115_1215_all_feature', '1115_1215_all_feature_involved',
#                    '1201_1231_all_feature', '1201_1231_all_feature_involved',
#                    '1215_0115_all_feature', '1215_0115_all_feature_involved']
# datasetNamelist = ["all_8_sim","all_15_sim","k_2_8s_sim","k_2_15s_sim","k_1_8s_sim","k_3_8s_sim","k_1_15s_sim","k_3_15s_sim","k_2_8s_sim_q_1_num","k_2_8s_sim_q_2_num","k_2_8s_sim_q_3_num","k_2_15s_sim_q_1_num","k_2_15s_sim_q_2_num","k_2_15s_sim_q_3_num"]     # '1215_0115_all_feature', '1215_0115_all_feature_involved'
inpath_origin = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'
#inpath_origin = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/'

for m in datasetNamelist:
    datasetname = m
    inpaths = inpath_origin + datasetname+'/allDataReduce/'
    outpath = inpath_origin + datasetname+'/'+datasetname+'_Reduce_Acc.csv'
    originaldatapath=inpath_origin + datasetname+'/'+datasetname+'.csv'
    for k in range(0,len(algorithmNamelist)):
        # acclist=[[],[],[],[]]
        acc1_list, acc2_list, acc3_list, acc4_list = [], [], [], []
        pre1_list, pre2_list, pre3_list, pre4_list = [], [], [], []
        recall1_list, recall2_list, recall3_list, recall4_list = [], [], [], []
        f11_list, f12_list, f13_list, f14_list = [], [], [], []
        auc1_list, auc2_list, auc3_list, auc4_list = [], [], [], []
        algorithmName = algorithmNamelist[k]
        for i in range(0,10):
            acc1_list_avg,acc2_list_avg,acc3_list_avg,acc4_list_avg=[],[],[],[]
            pre1_list_avg, pre2_list_avg, pre3_list_avg, pre4_list_avg = [], [], [], []
            recall1_list_avg,recall2_list_avg,recall3_list_avg,recall4_list_avg=[],[],[],[]
            f11_list_avg,f12_list_avg,f13_list_avg,f14_list_avg=[],[],[],[]
            auc1_list_avg, auc2_list_avg, auc3_list_avg, auc4_list_avg = [], [], [], []
            datapaths =inpaths+datasetname+'_'+algorithmName+'_'+str(i)+'_IncrementalReduce.csv'
            datadf = pd.read_csv(datapaths,header=0)
            #print(datadf.shape)
            #将csv中数据值为oldword的改写为newword    
            new_data=[]       
            for index, col in datadf.items():
                #从每列随机选取中一个值 
                 #ranValue=random.choice(col)   
                #选取一列中出现次数最多的值  离散型        
                newcol=list(col)
                count=Counter(newcol).most_common(2)
                if count[0][0]==100000 or count[0][0] == -1 or count[0][0] is None:
                    ranValue=count[1][0]
                else:
                    ranValue=count[0][0]
                #ranValue=max(set(newcol), key = newcol.count)     
                #选取一列中的平均值 连续型             
                #meanvalue = np.array(col) 
                #ranValue=np.mean(meanvalue)
                rep = [ranValue if x==100000 or x==-1 else x for x in col]
                new_data.append(rep) 
            datadf=pd.DataFrame(new_data)
            datadf=datadf.T
            #train_df.to_csv("C:\\Users\\Administrator\\Desktop\\test.csv")
        
            kf = KFold(n_splits=10,shuffle=True)  # 初始化KFold
            train_files = []   # 存放10折的训练集划分
            test_files = []     # # 存放10折的测试集集划分
            for k, (Trindex, Tsindex) in enumerate(kf.split(datadf)):
                train_files.append(np.array(datadf)[Trindex].tolist())
                test_files.append(np.array(datadf)[Tsindex].tolist())
            for i in range(0,10):
                train=pd.DataFrame(data=train_files[i])
                test=pd.DataFrame(data=test_files[i])
                train_features=train.iloc[:,0:-1].values
                train_labels=train.iloc[:,-1].values
                test_features=test.iloc[:,0:-1].values
                test_labels=test.iloc[:,-1].values

                # SVM
                clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, probability=True,  decision_function_shape='ovr')
                clf.fit(train_features, train_labels)
                y_hat = clf.predict(test_features)
                y_prob = clf.predict_proba(test_features)
                acc1=accuracy_score(test_labels, y_hat)
                acc1_list_avg.append(acc1)
                precision = precision_score(test_labels, y_hat, average='macro')
                recall = recall_score(test_labels, y_hat, average='macro')
                f1 = f1_score(test_labels, y_hat, average='macro')
                pre1_list_avg.append(precision)
                recall1_list_avg.append(recall)
                f11_list_avg.append(f1)
                # # 计算AUC
                # auc_list = []
                # # 循环每个类别计算AUC
                # for i in range(y_prob.shape[1]):
                #     # 提取当前类别的概率预测和真实标签
                #     y_prob_class = y_prob[:, i]
                #     y_true_class = test_labels == i
                #     auc = roc_auc_score(y_true_class, y_prob_class)
                #     auc_list.append(auc)
                # auc = sum(auc_list) / len(auc_list)
                # auc1_list_avg.append(auc)
                # print('SVM: precision=', precision, ', recall=', recall,'f1=', f1)
                # C4.5
                clf=tree.DecisionTreeClassifier()  #CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
                clf.fit(train_features,train_labels)
                y_hat = clf.predict( test_features)
                y_prob = clf.predict_proba(test_features)  # 不准
                acc2=accuracy_score(y_hat, test_labels)
                acc2_list_avg.append(acc2)
                precision = precision_score(test_labels, y_hat, average='macro')
                recall = recall_score(test_labels, y_hat, average='macro')
                f1 = f1_score(test_labels, y_hat, average='macro')
                pre2_list_avg.append(precision)
                recall2_list_avg.append(recall)
                f12_list_avg.append(f1)
                # # 计算AUC
                # auc_list = []
                # # 循环每个类别计算AUC
                # for i in range(y_prob.shape[1]):
                #     # 提取当前类别的概率预测和真实标签
                #     y_prob_class = y_prob[:, i]
                #     y_true_class = test_labels == i
                #     auc = roc_auc_score(y_true_class, y_prob_class)
                #     auc_list.append(auc)
                # auc = sum(auc_list) / len(auc_list)
                # auc2_list_avg.append(auc)
                # print('C4.5: precision=', precision, ', recall=', recall, 'f1=', f1)
                # NB
                clf = MultinomialNB(alpha=2.0,fit_prior=True,class_prior=None) #clf=GaussianNB()
                clf.fit(train_features,train_labels)
                y_hat = clf.predict( test_features)
                y_prob = clf.predict_proba(test_features)
                acc3=accuracy_score(y_hat, test_labels)
                acc3_list_avg.append(acc3)
                precision = precision_score(test_labels, y_hat, average='macro')
                recall = recall_score(test_labels, y_hat, average='macro')
                f1 = f1_score(test_labels, y_hat, average='macro')
                pre3_list_avg.append(precision)
                recall3_list_avg.append(recall)
                f13_list_avg.append(f1)
                # # 计算AUC
                # auc_list = []
                # # 循环每个类别计算AUC
                # for i in range(y_prob.shape[1]):
                #     # 提取当前类别的概率预测和真实标签
                #     y_prob_class = y_prob[:, i]
                #     y_true_class = test_labels == i
                #     auc = roc_auc_score(y_true_class, y_prob_class)
                #     auc_list.append(auc)
                # auc = sum(auc_list) / len(auc_list)
                # auc3_list_avg.append(auc)
                # print('NB: precision=', precision, ', recall=', recall, 'f1=', f1)
                # KNN K=3
                clf=KNeighborsClassifier(n_neighbors=3)
                clf.fit(train_features,train_labels)
                y_hat = clf.predict( test_features)
                y_prob = clf.predict_proba(test_features)  # 不准
                acc4=accuracy_score(y_hat, test_labels)
                acc4_list_avg.append(acc4)
                precision = precision_score(test_labels, y_hat, average='macro')
                recall = recall_score(test_labels, y_hat, average='macro')
                f1 = f1_score(test_labels, y_hat, average='macro')
                pre4_list_avg.append(precision)
                recall4_list_avg.append(recall)
                f14_list_avg.append(f1)
                # # 计算AUC
                # auc_list = []
                # # 循环每个类别计算AUC
                # for i in range(y_prob.shape[1]):
                #     # 提取当前类别的概率预测和真实标签
                #     y_prob_class = y_prob[:, i]
                #     y_true_class = test_labels == i
                #     auc = roc_auc_score(y_true_class, y_prob_class)
                #     auc_list.append(auc)
                # auc = sum(auc_list) / len(auc_list)
                # auc4_list_avg.append(auc)
                # print('KNN: precision=', precision, ', recall=', recall, 'f1=', f1)

                #print(algorithmName,',SVM,',acc1,',C4.5,',acc2,',NB,',acc3,',KNN,',acc4)
            acc1_list.append(np.mean(acc1_list_avg))
            acc2_list.append(np.mean(acc2_list_avg))
            acc3_list.append(np.mean(acc3_list_avg))
            acc4_list.append(np.mean(acc4_list_avg))
            pre1_list.append(np.mean(pre1_list_avg))
            pre2_list.append(np.mean(pre2_list_avg))
            pre3_list.append(np.mean(pre3_list_avg))
            pre4_list.append(np.mean(pre4_list_avg))
            recall1_list.append(np.mean(recall1_list_avg))
            recall2_list.append(np.mean(recall2_list_avg))
            recall3_list.append(np.mean(recall3_list_avg))
            recall4_list.append(np.mean(recall4_list_avg))
            f11_list.append(np.mean(f11_list_avg))
            f12_list.append(np.mean(f12_list_avg))
            f13_list.append(np.mean(f13_list_avg))
            f14_list.append(np.mean(f14_list_avg))
            # auc1_list.append(np.mean(auc1_list_avg))
            # auc2_list.append(np.mean(auc2_list_avg))
            # auc3_list.append(np.mean(auc3_list_avg))
            # auc4_list.append(np.mean(auc4_list_avg))

        if not os.path.exists(outpath):
             #os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
             with open(outpath, 'a', newline='') as file:
                writer = csv.writer(file)
                writer.writerow(['DataSet','MissingRatio','Algorithm','Classifier','1','2','3','4','5','6','7','8','9','10','avg_acc','1','2','3','4','5','6','7','8','9','10','avg_precision','1','2','3','4','5','6','7','8','9','10','avg_recall','1','2','3','4','5','6','7','8','9','10','avg_f1'])
        with open(outpath, 'a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow([datasetname,filenum, algorithmName,'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3], acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8], acc1_list[9],sum(acc1_list)/10,pre1_list[0], pre1_list[1], pre1_list[2], pre1_list[3], pre1_list[4], pre1_list[5], pre1_list[6], pre1_list[7], pre1_list[8], pre1_list[9],sum(pre1_list)/10,recall1_list[0], recall1_list[1], recall1_list[2], recall1_list[3], recall1_list[4], recall1_list[5], recall1_list[6], recall1_list[7], recall1_list[8], recall1_list[9],sum(recall1_list)/10,f11_list[0], f11_list[1], f11_list[2], f11_list[3], f11_list[4], f11_list[5], f11_list[6], f11_list[7], f11_list[8], f11_list[9],sum(f11_list)/10])  # ,auc1_list[0], auc1_list[1], auc1_list[2], auc1_list[3], auc1_list[4], auc1_list[5], auc1_list[6], auc1_list[7], auc1_list[8], auc1_list[9],sum(auc1_list)/10])
            writer.writerow([datasetname,filenum, algorithmName,'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3], acc2_list[4], acc2_list[5], acc2_list[6], acc2_list[7], acc2_list[8], acc2_list[9],sum(acc2_list)/10,pre2_list[0], pre2_list[1], pre2_list[2], pre2_list[3], pre2_list[4], pre2_list[5], pre2_list[6], pre2_list[7], pre2_list[8], pre2_list[9],sum(pre2_list)/10,recall2_list[0], recall2_list[1], recall2_list[2], recall2_list[3], recall2_list[4], recall2_list[5], recall2_list[6], recall2_list[7], recall2_list[8], recall2_list[9],sum(recall2_list)/10,f12_list[0], f12_list[1], f12_list[2], f12_list[3], f12_list[4], f12_list[5], f12_list[6], f12_list[7], f12_list[8], f12_list[9],sum(f12_list)/10])  #,auc2_list[0], auc2_list[1], auc2_list[2], auc2_list[3], auc2_list[4], auc2_list[5], auc2_list[6], auc2_list[7], auc2_list[8], auc2_list[9],sum(auc2_list)/10])
            writer.writerow([datasetname,filenum, algorithmName,'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3], acc3_list[4], acc3_list[5], acc3_list[6], acc3_list[7], acc3_list[8], acc3_list[9],sum(acc3_list)/10,pre3_list[0], pre3_list[1], pre3_list[2], pre3_list[3], pre3_list[4], pre3_list[5], pre3_list[6], pre3_list[7], pre3_list[8], pre3_list[9],sum(pre3_list)/10,recall3_list[0], recall3_list[1], recall3_list[2], recall3_list[3], recall3_list[4], recall3_list[5], recall3_list[6], recall3_list[7], recall3_list[8], recall3_list[9],sum(recall3_list)/10,f13_list[0], f13_list[1], f13_list[2], f13_list[3], f13_list[4], f13_list[5], f13_list[6], f13_list[7], f13_list[8], f13_list[9],sum(f13_list)/10])  #, auc3_list[0], auc3_list[1], auc3_list[2], auc3_list[3], auc3_list[4], auc3_list[5], auc3_list[6], auc3_list[7], auc3_list[8], auc3_list[9],sum(auc3_list)/10])
            writer.writerow([datasetname,filenum, algorithmName,'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3], acc4_list[4], acc4_list[5], acc4_list[6], acc4_list[7], acc4_list[8], acc4_list[9],sum(acc4_list)/10,pre4_list[0], pre4_list[1], pre4_list[2], pre4_list[3], pre4_list[4], pre4_list[5], pre4_list[6], pre4_list[7], pre4_list[8], pre4_list[9],sum(pre4_list)/10,recall4_list[0], recall4_list[1], recall4_list[2], recall4_list[3], recall4_list[4], recall4_list[5], recall4_list[6], recall4_list[7], recall4_list[8], recall4_list[9],sum(recall4_list)/10,f14_list[0], f14_list[1], f14_list[2], f14_list[3], f14_list[4], f14_list[5], f14_list[6], f14_list[7], f14_list[8], f14_list[9],sum(f14_list)/10])  #,auc4_list[0], auc4_list[1], auc4_list[2], auc4_list[3], auc4_list[4], auc4_list[5], auc4_list[6], auc4_list[7], auc4_list[8], auc4_list[9],sum(auc4_list)/10])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3],acc1_list[4],sum(acc1_list)/5])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3],acc2_list[4], sum(acc2_list)/5])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3],acc3_list[4], sum(acc3_list)/5])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3],acc4_list[4], sum(acc4_list)/5])
    print(datasetname, "_reduce_Acc完成")
    #原始数据
    
    original_df = pd.read_csv(originaldatapath,header=0)
    original_df = pd.DataFrame(original_df.iloc[:,1:-1].values) #删除第一列和最后一列 这里最后一列多了一个逗号导致最后一列的值都为NaN是多的因此删去
    #将csv中数据值为oldword的改写为newword
    new_data=[]
    for index, col in original_df.items():
        #从每列随机选取中一个值
        #ranValue=random.choice(col)
        #选取一列中出现次数最多的值  离散型
        newcol=list(col)
        count=Counter(newcol).most_common(2)
        if(count[0][0]==-1):
            if(len(count)<=1):
                ranValue=0
            else:
                ranValue=count[1][0]
        else:
            ranValue=count[0][0]
        #ranValue=max(set(newcol), key = newcol.count)
        #选取一列中的平均值 连续型
        #meanvalue = np.array(col)
        #ranValue=np.mean(meanvalue)
        rep = [ranValue if x==-1 else x for x in col]
        new_data.append(rep)
    original_df=pd.DataFrame(new_data)
    original_df=original_df.T
    #original_df.to_csv("C:\\Users\\Administrator\\Desktop\\test.csv",index=False, header=True)
    kf = KFold(n_splits=10,shuffle=True)  # 初始化KFold
    train_files = []   # 存放5折的训练集划分
    test_files = []     # # 存放5折的测试集集划分
    acccount=0
    acc1_list, acc2_list, acc3_list, acc4_list = [], [], [], []
    pre1_list, pre2_list, pre3_list, pre4_list = [], [], [], []
    recall1_list, recall2_list, recall3_list, recall4_list = [], [], [], []
    f11_list, f12_list, f13_list, f14_list = [], [], [], []
    auc1_list, auc2_list, auc3_list, auc4_list = [], [], [], []
    for k, (Trindex, Tsindex) in enumerate(kf.split(original_df)):
        train_files.append(np.array(original_df)[Trindex].tolist())
        test_files.append(np.array(original_df)[Tsindex].tolist())
    for i in range(0,10):
        train=pd.DataFrame(data=train_files[i])
        test=pd.DataFrame(data=test_files[i])
        train_features=train.iloc[:,0:-1].values
        train_labels=train.iloc[:,-1].values
        test_features=test.iloc[:,0:-1].values
        test_labels=test.iloc[:,-1].values

        # SVM
        clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039,probability=True, decision_function_shape='ovr')
        clf.fit(train_features,train_labels)
        y_hat = clf.predict( test_features)
        y_prob = clf.predict_proba(test_features)
        acc1=accuracy_score(y_hat, test_labels)
        acc1_list.append(acc1)
        precision = precision_score(test_labels, y_hat, average='macro', zero_division=0)
        recall = recall_score(test_labels, y_hat, average='macro')
        f1 = f1_score(test_labels, y_hat, average='macro')
        pre1_list.append(precision)
        recall1_list.append(recall)
        f11_list.append(f1)
        # # 计算AUC
        # auc_list = []
        # # 循环每个类别计算AUC
        # for i in range(y_prob.shape[1]):
        #     # 提取当前类别的概率预测和真实标签
        #     y_prob_class = y_prob[:, i]
        #     y_true_class = test_labels == i
        #     auc = roc_auc_score(y_true_class, y_prob_class)
        #     auc_list.append(auc)
        # auc = sum(auc_list) / len(auc_list)
        # auc1_list.append(auc)
        # print('SVM: precision=', precision, ', recall=', recall, 'f1=', f1)
        # C4.5
        clf=tree.DecisionTreeClassifier()  #CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
        clf.fit(train_features,train_labels)
        y_hat = clf.predict( test_features)
        y_prob = clf.predict_proba(test_features)
        acc2=accuracy_score(y_hat, test_labels)
        acc2_list.append(acc2)
        precision = precision_score(test_labels, y_hat, average='macro', zero_division=0)
        recall = recall_score(test_labels, y_hat, average='macro')
        f1 = f1_score(test_labels, y_hat, average='macro')
        pre2_list.append(precision)
        recall2_list.append(recall)
        f12_list.append(f1)
        # # 计算AUC
        # auc_list = []
        # # 循环每个类别计算AUC
        # for i in range(y_prob.shape[1]):
        #     # 提取当前类别的概率预测和真实标签
        #     y_prob_class = y_prob[:, i]
        #     y_true_class = test_labels == i
        #     auc = roc_auc_score(y_true_class, y_prob_class)
        #     auc_list.append(auc)
        # auc = sum(auc_list) / len(auc_list)
        # auc2_list.append(auc)
        # print('C4.5: precision=', precision, ', recall=', recall, 'f1=', f1)
        # NB
        clf = MultinomialNB(alpha=2.0,fit_prior=True,class_prior=None) #clf=GaussianNB()
        clf.fit(train_features,train_labels)
        y_hat = clf.predict( test_features)
        y_prob = clf.predict_proba(test_features)
        acc3=accuracy_score(y_hat, test_labels)
        acc3_list.append(acc3)
        precision = precision_score(test_labels, y_hat, average='macro', zero_division=0)
        recall = recall_score(test_labels, y_hat, average='macro')
        f1 = f1_score(test_labels, y_hat, average='macro')
        pre3_list.append(precision)
        recall3_list.append(recall)
        f13_list.append(f1)
        # # 计算AUC
        # auc_list = []
        # # 循环每个类别计算AUC
        # for i in range(y_prob.shape[1]):
        #     # 提取当前类别的概率预测和真实标签
        #     y_prob_class = y_prob[:, i]
        #     y_true_class = test_labels == i
        #     auc = roc_auc_score(y_true_class, y_prob_class)
        #     auc_list.append(auc)
        # auc = sum(auc_list) / len(auc_list)
        # auc3_list.append(auc)
        # print('NB: precision=', precision, ', recall=', recall, 'f1=', f1)
        # KNN K=3
        clf=KNeighborsClassifier(n_neighbors=3)
        clf.fit(train_features,train_labels)
        y_hat = clf.predict( test_features)
        y_prob = clf.predict_proba(test_features)
        acc4=accuracy_score(y_hat, test_labels)
        acc4_list.append(acc4)
        precision = precision_score(test_labels, y_hat, average='macro', zero_division=0)
        recall = recall_score(test_labels, y_hat, average='macro')
        f1 = f1_score(test_labels, y_hat, average='macro')
        pre4_list.append(precision)
        recall4_list.append(recall)
        f14_list.append(f1)
        # # 计算AUC
        # auc_list = []
        # # 循环每个类别计算AUC
        # for i in range(y_prob.shape[1]):
        #     # 提取当前类别的概率预测和真实标签
        #     y_prob_class = y_prob[:, i]
        #     y_true_class = test_labels == i
        #     auc = roc_auc_score(y_true_class, y_prob_class)
        #     auc_list.append(auc)
        # auc = sum(auc_list) / len(auc_list)
        # auc4_list.append(auc)
        # print('KNN: precision=', precision, ', recall=', recall, 'f1=', f1)
    with open(outpath, 'a', newline='') as file:
        writer = csv.writer(file)
        writer = csv.writer(file)
        writer.writerow(
            [datasetname, filenum, "originData", 'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3],
             acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8], acc1_list[9], sum(acc1_list) / 10,
             pre1_list[0], pre1_list[1], pre1_list[2], pre1_list[3], pre1_list[4], pre1_list[5], pre1_list[6],
             pre1_list[7], pre1_list[8], pre1_list[9], sum(pre1_list) / 10, recall1_list[0], recall1_list[1],
             recall1_list[2], recall1_list[3], recall1_list[4], recall1_list[5], recall1_list[6], recall1_list[7],
             recall1_list[8], recall1_list[9], sum(recall1_list) / 10, f11_list[0], f11_list[1], f11_list[2],
             f11_list[3], f11_list[4], f11_list[5], f11_list[6], f11_list[7], f11_list[8], f11_list[9],
             sum(f11_list) / 10])
             #, auc1_list[0], auc1_list[1], auc1_list[2],
             # auc1_list[3], auc1_list[4], auc1_list[5], auc1_list[6], auc1_list[7], auc1_list[8], auc1_list[9],
             # sum(auc1_list) / 10])
        writer.writerow(
            [datasetname, filenum, "originData", 'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3],
             acc2_list[4], acc2_list[5], acc2_list[6], acc2_list[7], acc2_list[8], acc2_list[9], sum(acc2_list) / 10,
             pre2_list[0], pre2_list[1], pre2_list[2], pre2_list[3], pre2_list[4], pre2_list[5], pre2_list[6],
             pre2_list[7], pre2_list[8], pre2_list[9], sum(pre2_list) / 10, recall2_list[0], recall2_list[1],
             recall2_list[2], recall2_list[3], recall2_list[4], recall2_list[5], recall2_list[6], recall2_list[7],
             recall2_list[8], recall2_list[9], sum(recall2_list) / 10, f12_list[0], f12_list[1], f12_list[2],
             f12_list[3], f12_list[4], f12_list[5], f12_list[6], f12_list[7], f12_list[8], f12_list[9],
             sum(f12_list) / 10])\
            # , auc2_list[0], auc2_list[1], auc2_list[2],
            #  auc2_list[3], auc2_list[4], auc2_list[5], auc2_list[6], auc2_list[7], auc2_list[8], auc2_list[9],
            #  sum(auc2_list) / 10])
        writer.writerow(
            [datasetname, filenum, "originData", 'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3],
             acc3_list[4], acc3_list[5], acc3_list[6], acc3_list[7], acc3_list[8], acc3_list[9], sum(acc3_list) / 10,
             pre3_list[0], pre3_list[1], pre3_list[2], pre3_list[3], pre3_list[4], pre3_list[5], pre3_list[6],
             pre3_list[7], pre3_list[8], pre3_list[9], sum(pre3_list) / 10, recall3_list[0], recall3_list[1],
             recall3_list[2], recall3_list[3], recall3_list[4], recall3_list[5], recall3_list[6], recall3_list[7],
             recall3_list[8], recall3_list[9], sum(recall3_list) / 10, f13_list[0], f13_list[1], f13_list[2],
             f13_list[3], f13_list[4], f13_list[5], f13_list[6], f13_list[7], f13_list[8], f13_list[9],
             sum(f13_list) / 10])\
            # , auc3_list[0], auc3_list[1], auc3_list[2],
            #  auc3_list[3], auc3_list[4], auc3_list[5], auc3_list[6], auc3_list[7], auc3_list[8], auc3_list[9],
            #  sum(auc3_list) / 10])
        writer.writerow(
            [datasetname, filenum, "originData", 'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3],
             acc4_list[4], acc4_list[5], acc4_list[6], acc4_list[7], acc4_list[8], acc4_list[9], sum(acc4_list) / 10,
             pre4_list[0], pre4_list[1], pre4_list[2], pre4_list[3], pre4_list[4], pre4_list[5], pre4_list[6],
             pre4_list[7], pre4_list[8], pre4_list[9], sum(pre4_list) / 10, recall4_list[0], recall4_list[1],
             recall4_list[2], recall4_list[3], recall4_list[4], recall4_list[5], recall4_list[6], recall4_list[7],
             recall4_list[8], recall4_list[9], sum(recall4_list) / 10, f14_list[0], f14_list[1], f14_list[2],
             f14_list[3], f14_list[4], f14_list[5], f14_list[6], f14_list[7], f14_list[8], f14_list[9],
             sum(f14_list) / 10])\
            # , auc4_list[0], auc4_list[1], auc4_list[2],
            #  auc4_list[3], auc4_list[4], auc4_list[5], auc4_list[6], auc4_list[7], auc4_list[8], auc4_list[9],
            #  sum(auc4_list) / 10])
        # writer.writerow([datasetname,filenum, "originData",'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3], acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8], acc1_list[9],sum(acc1_list)/10])
        # writer.writerow([datasetname,filenum, "originData",'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3], acc2_list[4], acc2_list[5], acc2_list[6], acc2_list[7], acc2_list[8], acc2_list[9],sum(acc2_list)/10])
        # writer.writerow([datasetname,filenum, "originData",'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3], acc3_list[4], acc3_list[5], acc3_list[6], acc3_list[7], acc3_list[8], acc3_list[9],sum(acc3_list)/10])
        # writer.writerow([datasetname,filenum, "originData",'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3], acc4_list[4], acc4_list[5], acc4_list[6], acc4_list[7], acc4_list[8], acc4_list[9],sum(acc4_list)/10])
        # writer.writerow([datasetname,filenum, "originData", 'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3],acc1_list[4], sum(acc1_list) / 5])
        # writer.writerow([datasetname, filenum, "originData", 'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3],acc2_list[4], sum(acc2_list) / 5])
        # writer.writerow([datasetname, filenum, "originData", 'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3],acc3_list[4], sum(acc3_list) / 5])
        # writer.writerow([datasetname, filenum, "originData", 'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3],acc4_list[4], sum(acc4_list) / 5])

    print("originaldata_Acc完成")

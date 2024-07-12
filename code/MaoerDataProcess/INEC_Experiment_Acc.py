#INEC实验ACC
#十倍交叉验证
# SVM KNN C4.5 NB

print("hello")
#需求：读取文件夹下reduce中所有train文件和test文件训练求ACC
import pandas as pd
import numpy as np
import os 
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score
from sklearn.metrics import roc_curve, auc
import matplotlib.pylab as plt
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

#数据读取
#读取文件夹下所有csv文件进行SVM
#数据说明：各个算法进行10次的特征选择得到10次train+test文件 例GLI_85_IFSICE_0_Reduce_test.csv
import os
from glob import glob
import csv
filenum = '15%'
missingValue=-1
algorithmNamelist=['INEC2_threepart_simu','IFSICE']
datasetNamelist=["bank-marketing","letter","nomao","eeg-eye-state","PhishingWebsites"]  #"GLI_85", "BASEHOCK", "car", "Isolet", "leukemia", "madelon", "nci9", "nursery","orlraws10P", "PCMAC", "qsar_androgen_receptor", "gisette"
#"AR10P","Dexter","gisette_MDLP","lung","optdigits-orig","pd_speech_features","PIE10P","Prostate_GE","orlraws10P_MDLP"
#datasetnamelist=['GLI_85']
for m in datasetNamelist:
    datasetname=m
    inpaths = 'C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\'+filenum+'_MissingValue\\'+datasetname+'\\allDataReduce\\'
    outpath = 'C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\ProcessingResult\\'+datasetname+'_Reduce_Acc.csv'
    originaldatapath='C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\'+filenum+'_MissingValue\\'+datasetname+'\\'+datasetname+'.csv'
    for k in range(0,len(algorithmNamelist)):
        acclist=[[],[],[],[]]
        acc1_list=[]
        acc2_list=[]
        acc3_list=[]
        acc4_list=[]
        algorithmName = algorithmNamelist[k]
        for i in range(0,5):
            trainpaths =inpaths+datasetname+'_'+algorithmName+'_'+str(i)+'_Reduce_train.csv'
            testpaths = inpaths+datasetname+'_'+algorithmName+'_'+str(i)+'_Reduce_test.csv'   
            train_df = pd.read_csv(trainpaths,header=0)
            test_df = pd.read_csv(testpaths,header=0)

            #将csv中数据值为oldword的改写为newword    
            new_data=[]       
            for index, col in train_df.iteritems():
                #从每列随机选取中一个值 
                #ranValue=random.choice(col)   
                #选取一列中出现次数最多的值  离散型             
                newcol=list(col)
                count=Counter(newcol).most_common(2)
                if(count[0][0]==-1):
                    ranValue=count[1][0]
                else:
                    ranValue=count[0][0]
                #ranValue=max(set(newcol), key = newcol.count)     
                #选取一列中的平均值 连续型             
                #meanvalue = np.array(col) 
                #ranValue=np.mean(meanvalue)
                rep = [ranValue if x==100000 else x for x in col]
                new_data.append(rep) 
            train_df=pd.DataFrame(new_data)
            train_df=train_df.T
            #train_df.to_csv("C:\\Users\\Administrator\\Desktop\\test.csv")
            new_data2=[]
            for index, col in test_df.iteritems():
                #从每列随机选取中一个值 
                #ranValue=random.choice(col)   
                #选取一列中出现次数最多的值  离散型             
                newcol=list(col)
                count=Counter(newcol).most_common(2)
                if(count[0][0]==-1):
                    ranValue=count[1][0]
                else:
                    ranValue=count[0][0]
                #ranValue=max(set(newcol), key = newcol.count)     
                #选取一列中的平均值 连续型             
                #meanvalue = np.array(col) 
                #ranValue=np.mean(meanvalue)
                rep = [ranValue if x==100000 else x for x in col]
                new_data2.append(rep) 
            test_df=pd.DataFrame(new_data2)
            test_df=test_df.T
            #train data
            
            train_labels=list(train_df.columns.values)
            train_featureNames =train_labels
            train_feature=train_df.iloc[:, 0:-1].values
            train_label=train_df.iloc[:, -1].values
            train_labelsValue=list(set(train_df.iloc[:, -1].values))
            #test data
            
            test_labels=list(test_df.columns.values)
            test_featureNames =test_labels
            test_feature=test_df.iloc[:, 0:-1].values
            test_label=test_df.iloc[:, -1].values
            test_labelsValue=list(set(test_df.iloc[:, -1].values))

            train_features=train_feature
            train_labels=train_label
            test_features=test_feature
            test_labels=test_label

            # SVM
            clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
            clf.fit(train_features,train_labels)
            y_hat = clf.predict( test_features) 
            acc1=accuracy_score(y_hat, test_labels)
            acc1_list.append(acc1)
            # C4.5
            clf=tree.DecisionTreeClassifier()  #CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
            clf.fit(train_features,train_labels)
            y_hat = clf.predict( test_features)
            acc2=accuracy_score(y_hat, test_labels)
            acc2_list.append(acc2)
            # NB
            clf = MultinomialNB(alpha=2.0,fit_prior=True,class_prior=None) #clf=GaussianNB()
            clf.fit(train_features,train_labels)
            y_hat = clf.predict( test_features)
            acc3=accuracy_score(y_hat, test_labels)
            acc3_list.append(acc3)
            # KNN K=3
            clf=KNeighborsClassifier(n_neighbors=3)
            clf.fit(train_features,train_labels)
            y_hat = clf.predict( test_features)
            acc4=accuracy_score(y_hat, test_labels)
            acc4_list.append(acc4)

                #print(algorithmName,',SVM,',acc1,',C4.5,',acc2,',NB,',acc3,',KNN,',acc4)
        
        if not os.path.exists(outpath):
             #os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
             with open(outpath, 'a', newline='') as file:
                writer = csv.writer(file)
                writer.writerow(['DataSet','MissingRatio','Algorithm','Classifier','1','2','3','4','5','6','7','8','9','10','avg_acc'])
        with open(outpath, 'a', newline='') as file:
            writer = csv.writer(file)
            # writer.writerow([datasetname,filenum+Type, algorithmName,'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3], acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8], acc1_list[9],sum(acc1_list)/10])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3], acc2_list[4], acc2_list[5], acc2_list[6], acc2_list[7], acc2_list[8], acc2_list[9],sum(acc2_list)/10])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3], acc3_list[4], acc3_list[5], acc3_list[6], acc3_list[7], acc3_list[8], acc3_list[9],sum(acc3_list)/10])
            # writer.writerow([datasetname,filenum+Type, algorithmName,'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3], acc4_list[4], acc4_list[5], acc4_list[6], acc4_list[7], acc4_list[8], acc4_list[9],sum(acc4_list)/10])
            writer.writerow([datasetname, algorithmName,'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3], acc1_list[4],sum(acc1_list)/5])
            writer.writerow([datasetname, algorithmName,'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3], acc2_list[4], sum(acc2_list)/5])
            writer.writerow([datasetname, algorithmName,'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3], acc3_list[4], sum(acc3_list)/5])
            writer.writerow([datasetname, algorithmName,'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3], acc4_list[4],sum(acc4_list)/5])
    print(datasetname,"_reduce_Acc完成")
    #原始数据
    
    original_df = pd.read_csv(originaldatapath,header=0) 
    original_df= pd.DataFrame(original_df.iloc[:,1:-1].values) #删除第一列和最后一列 这里最后一列多了一个逗号导致最后一列的值都为NaN是多的因此删去
    #将csv中数据值为oldword的改写为newword    
    new_data=[]       
    for index, col in original_df.iteritems():
        #从每列随机选取中一个值 
        #ranValue=random.choice(col)   
        #选取一列中出现次数最多的值  离散型             
        newcol=list(col)
        count=Counter(newcol).most_common(2)
        if(count[0][0]==-1):
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
    acc1_list=[]
    acc2_list=[]
    acc3_list=[]
    acc4_list=[]
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
        clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
        clf.fit(train_features,train_labels)
        y_hat = clf.predict( test_features) 
        acc1=accuracy_score(y_hat, test_labels)
        acc1_list.append(acc1)
        # C4.5
        clf=tree.DecisionTreeClassifier()  #CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
        clf.fit(train_features,train_labels)
        y_hat = clf.predict( test_features)
        acc2=accuracy_score(y_hat, test_labels)
        acc2_list.append(acc2)
        # NB
        clf = MultinomialNB(alpha=2.0,fit_prior=True,class_prior=None) #clf=GaussianNB()
        clf.fit(train_features,train_labels)
        y_hat = clf.predict( test_features)
        acc3=accuracy_score(y_hat, test_labels)
        acc3_list.append(acc3)
        # KNN K=3
        clf=KNeighborsClassifier(n_neighbors=3)
        clf.fit(train_features,train_labels)
        y_hat = clf.predict( test_features)
        acc4=accuracy_score(y_hat, test_labels)
        acc4_list.append(acc4)
    with open(outpath, 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([datasetname,filenum, "originData",'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3], acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8], acc1_list[9],sum(acc1_list)/10])
        writer.writerow([datasetname,filenum, "originData",'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3], acc2_list[4], acc2_list[5], acc2_list[6], acc2_list[7], acc2_list[8], acc2_list[9],sum(acc2_list)/10])
        writer.writerow([datasetname,filenum, "originData",'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3], acc3_list[4], acc3_list[5], acc3_list[6], acc3_list[7], acc3_list[8], acc3_list[9],sum(acc3_list)/10])
        writer.writerow([datasetname,filenum, "originData",'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3], acc4_list[4], acc4_list[5], acc4_list[6], acc4_list[7], acc4_list[8], acc4_list[9],sum(acc4_list)/10])
    print("originaldata_Acc完成")


# import os
# from glob import glob
# import csv
# filenum = '15%'
# datasetname='GLI_85'
# inpaths = 'C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\'+filenum+'_MissingValue\\'+datasetname+'\\reduce\\'
# outpath = 'C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\'+filenum+'_MissingValue\\Reduce_Acc.csv'
# algorithmNamelist=['INEC2','IFSICE']
# for i in range(0,10):
#     trainpaths = glob(r'C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\'+filenum+'_MissingValue\\'+datasetname+'\\reduce\\'+datasetname+'_*_['+str(i)+']_Reduce_train.csv')
#     testpaths = glob(r'C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\'+filenum+'_MissingValue\\'+datasetname+'\\reduce\\'+datasetname+'_*_['+str(i)+']_Reduce_test.csv')    
#     train_filelist = []
#     test_filelist = []
#     for path in trainpaths :
#         train_file = os.path.basename(path)  #返回文件名
#         train_filelist.append(train_file)
#         #print(train_file)
#     for path in testpaths :
#         test_file = os.path.basename(path)  #返回文件名
#         test_filelist.append(test_file)
#         #print(test_file)
#     print(train_filelist)
#     print(test_filelist)

#     for k in range(0,len(train_filelist)):
#         str2=train_filelist[k][len(datasetname)+1:]
#         algorithmName = str2[:str2.index("_")]
#         #train data
#         train_df = pd.read_csv(inpaths+train_filelist[k],header=0)
#         train_labels=list(train_df.columns.values)
#         train_featureNames =train_labels
#         train_feature=train_df.iloc[:, 0:-1].values
#         train_label=train_df.iloc[:, -1].values
#         train_labelsValue=list(set(train_df.iloc[:, -1].values))
#         #test data
#         test_df = pd.read_csv(inpaths+test_filelist[k],header=0)
#         test_labels=list(test_df.columns.values)
#         test_featureNames =test_labels
#         test_feature=test_df.iloc[:, 0:-1].values
#         test_label=test_df.iloc[:, -1].values
#         test_labelsValue=list(set(test_df.iloc[:, -1].values))

#         train_features=train_feature
#         train_labels=train_label
#         test_features=test_feature
#         test_labels=test_label

#         # SVM
#         clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
#         clf.fit(train_features,train_labels)
#         y_hat = clf.predict( test_features) 
#         acc1=accuracy_score(y_hat, test_labels)
#         # C4.5
#         clf=tree.DecisionTreeClassifier()  #CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
#         clf.fit(train_features,train_labels)
#         y_hat = clf.predict( test_features)
#         acc2=accuracy_score(y_hat, test_labels)
#         # NB
#         clf = MultinomialNB(alpha=2.0,fit_prior=True,class_prior=None) #clf=GaussianNB()
#         clf.fit(train_features,train_labels)
#         y_hat = clf.predict( test_features)
#         acc3=accuracy_score(y_hat, test_labels)
#         # KNN K=3
#         clf=KNeighborsClassifier(n_neighbors=3)
#         clf.fit(train_features,train_labels)
#         y_hat = clf.predict( test_features)
#         acc4=accuracy_score(y_hat, test_labels)

#         print(algorithmName,',SVM,',acc1,',C4.5,',acc2,',NB,',acc3,',KNN,',acc4)
#         if i==0:
#             if not os.path.exists(outpath):
#                 os.system(r"touch {}".format(path))#调用系统命令行来创建文件
#                 with open(outpath, 'a', newline='') as file:
#                     writer = csv.writer(file)
#                     writer.writerow(['dataSet','Algorithm','SVM_acc','C4.5_acc','NB_acc','KNN_acc'])
#         with open(outpath, 'a', newline='') as file:
#             writer = csv.writer(file)
#             writer.writerow([datasetname, algorithmName, acc1, acc2, acc3, acc4])



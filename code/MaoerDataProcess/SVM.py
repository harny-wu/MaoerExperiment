import time
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score
from sklearn.preprocessing import label_binarize
from sklearn.multiclass import OneVsOneClassifier, OneVsRestClassifier
#from sklearn.metrics import decision_function
from sklearn.metrics import roc_curve,roc_auc_score, auc
# import matplotlib.pylab as plt
from sklearn import datasets
from sklearn import svm
from sklearn.model_selection import KFold
from sklearn import metrics
from collections import Counter


url = "/Users/ly/Desktop/rec_L_S_us.csv"
#df = pd.read_csv(url,error_bad_lines=0)
df = pd.read_csv(url, header=0)
new_data=[]
for index, col in df.items():
	# 从每列随机选取中一个值
	# ranValue=random.choice(col)
	# 选取一列中出现次数最多的值  离散型
	newcol = list(col)
	count = Counter(newcol).most_common(2)
	if (count[0][0] == -1):
		ranValue = count[1][0]
	else:
		ranValue = count[0][0]
	# ranValue=max(set(newcol), key = newcol.count)
	# 选取一列中的平均值 连续型
	# meanvalue = np.array(col)
	# ranValue=np.mean(meanvalue)
	rep = [ranValue if x == 100000 else x for x in col]
	new_data.append(rep)
df=pd.DataFrame(new_data)
df=df.T
#df = pd.read_csv(url, encoding='utf-8')
labels=list(df.columns.values)
featureNames =labels
feature=df.iloc[:, 0:-1].values
label=df.iloc[:, -1].values
labelsValue=list(set(df.iloc[:, -1].values))
#print(labelsValue)
#print(df)
train_features, test_features, train_labels, test_labels = train_test_split(feature, label, test_size=0.10, random_state=1)
#print(len(train_features))
clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
clf.fit(train_features,train_labels)
#print(set(test_labels))

#计算精确度
print ('训练集精度：',clf.score(train_features, train_labels)) # 精度
y_hat = clf.predict(train_features)
print ('训练集准确度：',accuracy_score(train_labels, y_hat))
print ('测试集精度：',clf.score( test_features, test_labels))
y_hat = clf.predict( test_features)
print ('测试集准确度：',accuracy_score(y_hat, test_labels))
#print (metrics.classification_report(test_labels, y_hat))
acc=accuracy_score(y_hat, test_labels)
#二分类
# precision=precision_score(y_hat,test_labels)  
# recall=recall_score(y_hat,test_labels)
# f1=f1_score(y_hat,test_labels)
# y_score = clf.decision_function(test_features)
# #print(y_score)
# # 为每个类别计算ROC曲线和AUC
# roc_auc = dict()
# fpr, tpr, threshold = roc_curve(test_labels,y_score,pos_label=2)
# roc_auc = auc(fpr, tpr)
# #print('AUC:',roc_auc)
# print (acc,',',precision,',',recall,',',f1,',',roc_auc)

#多分类
# precision=precision_score(y_hat,test_labels,labels=labelsValue,average='macro')  #micro macro weighted samples
# recall=recall_score(y_hat,test_labels,labels=labelsValue,average='macro')
# f1=f1_score(y_hat,test_labels,labels=labelsValue,average='macro')
# fig, axes = plt.subplots(2, 2, figsize=(8, 8))
# colors = ["r", "g", "b", "k"]
# markers = ["o", "^", "v", "+"]
# n_classes=len(labelsValue)
# y_test = label_binarize(test_labels, classes=clf.classes_)
# print(y_test.shape)
# for i in range(n_classes):# 计算每个类别的FPR, TPR 
# 	fpr, tpr, thr = roc_curve(y_test[:, i], y_score[:, i])
# 	#print("classes_{}, fpr: {}, tpr: {}, threshold: {}".format(i, fpr, tpr, thr))
#    	# 绘制ROC曲线，并计算AUC值
# 	axes[int(i / 2), i % 2].plot(fpr, tpr, color=colors[i], marker=markers[i], label="AUC: {:.2f}".format(auc(fpr, tpr)))
# 	axes[int(i / 2), i % 2].set_xlabel("FPR")
# 	axes[int(i / 2), i % 2].set_ylabel("TPR")
# 	axes[int(i / 2), i % 2].set_title("Class_{}".format(clf.classes_[i]))
# 	axes[int(i / 2), i % 2].legend(loc="lower right")
# print("AUC:", roc_auc_score(y_test , clf.decision_function(test_features), multi_class="ovr", average=None))
# plt.figure()
# lw = 3
# plt.plot(fpr, tpr, color='darkorange',lw=lw, label='ROC curve (area = %0.2f)' % roc_auc)
# plt.plot([0, 1], [0, 1], color='navy', lw=lw, linestyle='--')
# plt.xlim([0.0, 1.0])
# plt.ylim([0.0, 1.05])
# plt.xlabel('False Positive Rate')
# plt.ylabel('True Positive Rate')
# plt.title('Receiver operating characteristic example')
# plt.legend(loc="lower right")
# plt.show()
# 利用ROC曲线找出最佳阀值
# maxindex = (tpr - fpr).tolist().index(max(tpr - fpr))
# print(threshold[maxindex])




#5折交叉验证SVM
#print('5折交叉验证')
# data1 = []   # 存放5折的训练集划分
# data2 = []
# str1=int(df.iat[0,-1])
# for j in range(df.shape[0]):
# 	if int(df.iat[j,-1])==1:
# 		data1.append(df.iloc[j,:])
# 	elif int(df.iat[j,-1])==2:	
# 		data2.append(df.iloc[j,:])
# data_class1=pd.DataFrame(data=data1)
# data_class2=pd.DataFrame(data=data2)
# kf = KFold(n_splits=5,shuffle=False)  # 初始化KFold
# train_files = []   # 存放5折的训练集划分
# test_files = []     # # 存放5折的测试集集划分
# for k, (Trindex, Tsindex) in enumerate(kf.split(data_class1)):
#     train_files.append(np.array(data_class1)[Trindex].tolist())
#     test_files.append(np.array(data_class1)[Tsindex].tolist())
# for k, (Trindex, Tsindex) in enumerate(kf.split(data_class2)):
#     train_files.append(np.array(data_class2)[Trindex].tolist())
#     test_files.append(np.array(data_class2)[Tsindex].tolist())
# avg_acc=0
# for i in range(0,5):
# 	train=pd.DataFrame(data=train_files[i]+train_files[i+5])
# 	test=pd.DataFrame(data=test_files[i]+test_files[i+5])
# 	train_features=train.iloc[:,0:-1].values
# 	train_labels=train.iloc[:,-1].values
# 	test_features=test.iloc[:,0:-1].values
# 	test_labels=test.iloc[:,-1].values
# 	clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
# 	clf.fit(train_features,train_labels)
# 	y_hat = clf.predict( test_features)
# 	acc=accuracy_score(y_hat, test_labels)	
# 	avg_acc+=acc
# 	print ('精确度',i,',',acc)
# print('五折平均精确度：',avg_acc/5)


#10折交叉验证SVM
print('10折交叉验证')
data1 = []   # 存放5折的训练集划分
data2 = []
str1=int(df.iat[0,-1])
for j in range(df.shape[0]):
	if int(df.iat[j,-1])==0:
		data1.append(df.iloc[j,:])
	elif int(df.iat[j,-1])==1:
		data2.append(df.iloc[j,:])
data_class1=pd.DataFrame(data=data1)
data_class2=pd.DataFrame(data=data2)
kf = KFold(n_splits=10,shuffle=False)  # 初始化KFold
train_files = []   # 存放10折的训练集划分
test_files = []     # # 存放10折的测试集集划分
for k, (Trindex, Tsindex) in enumerate(kf.split(data_class1)):
    train_files.append(np.array(data_class1)[Trindex].tolist())
    test_files.append(np.array(data_class1)[Tsindex].tolist())
for k, (Trindex, Tsindex) in enumerate(kf.split(data_class2)):
    train_files.append(np.array(data_class2)[Trindex].tolist())
    test_files.append(np.array(data_class2)[Tsindex].tolist())
avg_acc=0
for i in range(0,10):
	train=pd.DataFrame(data=train_files[i]+train_files[i+10])
	test=pd.DataFrame(data=test_files[i]+test_files[i+10])
	train_features=train.iloc[:,0:-1].values
	train_labels=train.iloc[:,-1].values
	test_features=test.iloc[:,0:-1].values
	test_labels=test.iloc[:,-1].values
	# clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
	clf = svm.SVC(C=0.6442234848484849, kernel='rbf', gamma=0.00390625)
	clf.fit(train_features,train_labels)
	y_hat = clf.predict( test_features)
	acc=accuracy_score(y_hat, test_labels)	
	avg_acc+=acc
	print ('精确度',i,',',acc)
print('十折平均精确度：',avg_acc/10)

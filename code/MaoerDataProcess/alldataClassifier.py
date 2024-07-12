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

url = "/Users/ly/Desktop/rec_L_S_us.csv"
#url = "C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\nci9\\nci9.csv"
df = pd.read_csv(url,header=0)
# new_data=[]
# for index, col in df.items():
#     #从每列随机选取中一个值
#     #ranValue=random.choice(col)
#     #选取一列中出现次数最多的值  离散型
#     newcol=list(col)
#     ranValue=max(set(newcol), key = newcol.count)
#     #选取一列中的平均值 连续型
#     #meanvalue = np.array(col)
#     #ranValue=np.mean(meanvalue)
#     rep = [ranValue if x==100000 else x for x in col]
#     new_data.append(rep)
#     df=pd.DataFrame(new_data)
#     df=df.T
#df = pd.read_csv(url, encoding='utf-8')
labels=list(df.columns.values)
featureNames =labels
feature=df.iloc[:, 0:-1].values
label=df.iloc[:, -1].values
labelsValue=list(set(df.iloc[:, -1].values))
train_features, test_features, train_labels, test_labels = train_test_split(feature, label, test_size=0.10, random_state=1)

print("SVM:")
# clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, decision_function_shape='ovr')
clf = svm.SVC(C=0.6442234848484849, kernel='rbf', gamma=0.00390625)
clf.fit(train_features,train_labels)
y_hat = clf.predict(train_features)
print ('训练集准确度：',accuracy_score(train_labels, y_hat))
y_hat = clf.predict( test_features)
print ('测试集准确度：',accuracy_score(y_hat, test_labels))

print("C4.5:")
clf=tree.DecisionTreeClassifier()  #CART算法
clf.fit(train_features,train_labels)
y_hat = clf.predict(train_features)
print ('训练集准确度：',accuracy_score(train_labels, y_hat))
y_hat = clf.predict( test_features)
print ('测试集准确度：',accuracy_score(y_hat, test_labels))

print("NB:")
clf = MultinomialNB(alpha=2.0,fit_prior=True,class_prior=None)
clf.fit(train_features,train_labels)
y_hat = clf.predict(train_features)
print ('训练集准确度：',accuracy_score(train_labels, y_hat))
y_hat = clf.predict( test_features)
print ('测试集准确度：',accuracy_score(y_hat, test_labels))

print("KNN:")
clf=KNeighborsClassifier(n_neighbors=3)
clf.fit(train_features,train_labels)
y_hat = clf.predict(train_features)
print ('训练集准确度：',accuracy_score(train_labels, y_hat))
y_hat = clf.predict( test_features)
print ('测试集准确度：',accuracy_score(y_hat, test_labels))

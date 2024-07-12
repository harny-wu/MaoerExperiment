import time
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn import datasets
from sklearn import svm

url = "C:\\Users\\jiang\\Desktop\\2class_SVM\\总\\2class_评论.csv"
df = pd.read_csv(url)
labels=list(df.columns.values)
featureNames =labels
feature=df.iloc[:, 0:-1].values
label=df.iloc[:, -1].values

train_features, test_features, train_labels, test_labels = train_test_split(feature, label, test_size=0.24, random_state=1)
clf = svm.SVC(C=188.49712377786636, kernel='rbf', gamma=0.00390625, decision_function_shape='ovr')
clf.fit(train_features,train_labels)
#计算精确度
print ('训练集精度：',clf.score(train_features, train_labels)) # 精度
y_hat = clf.predict(train_features)
print ('训练集准确度：',accuracy_score(train_labels, y_hat))
print ('测试集精度：',clf.score( test_features, test_labels))
y_hat = clf.predict( test_features)
print ('测试集准确度：',accuracy_score(y_hat, test_labels))
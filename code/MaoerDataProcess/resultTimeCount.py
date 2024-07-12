#INEC实验结果统计 times&ReduceSize


#需求：读取文件夹下文件中时间和约简长度整理成表
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
#读取文件夹下所有csv文件
#数据说明：
import os
from glob import glob
import csv

filenum = ['25%','30%','35%']#'5%','10%','15%','20%','25%','30%','35%','40%'
algorithmNamelist=['INEC2','INEC2_threepart_simu','INEC2_threepart_turn','IFSICE']
ExecCategory='IncrementalReduce' #'StaticReduce'
datasetNamelist=["AR10P","Dexter", "lung", "optdigits-orig","orlraws10P_MDLP","madelon","PIE10P","Prostate_GE","qsar_androgen_receptor","pd_speech_features","gisette_MDLP"]  #"GLI_85", "BASEHOCK", "car", "Isolet", "leukemia", "madelon", "nci9", "nursery","orlraws10P", "PCMAC", "qsar_androgen_receptor", "gisette"
#"advertisements_MDLP","breast-cancer-wisconsin","horse-colic","mushroom"
#"AR10P","Dexter", "lung", "optdigits-orig","orlraws10P_MDLP","madelon","PIE10P","Prostate_GE","qsar_androgen_receptor","pd_speech_features","gisette_MDLP"
#"nomao","bank-marketing","eeg-eye-state","letter","PhishingWebsites"
for m in datasetNamelist:
	datasetname=m
	inpaths = 'C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\ProcessingResult\\'+datasetname+'_ProcessingResult.csv'  
	#datadf = pd.read_csv(inpaths,header=0)
	f = open(inpaths,"r") 
	outpathnum=''
	lines = f.readlines()      #读取全部内容 ，并以列表方式返回
	row=[]
	for line in lines:
		row.append(line.split(','))
	
	for num in filenum:
		outdict={'INEC2':[[]],'INEC2_threepart_simu':[[]],'INEC2_threepart_turn':[[]],'IFSICE':[[]]}
		partraw=[]
		# outtimeraw=[]
		# outreducesizeraw=[]
		z=0
		alltimes=0
		for i in range(0,len(row)):
			if (row[i][0]!='Time')&(row[i][3]==num)&(row[i][4]==ExecCategory):
				alltimes+=float(row[i][6])
				if i!=(len(row)-1):
					if row[i+1][0]=='Time': #一轮结束
						#partraw.append([alltimes,row[i][8]])
						outdict[row[i][1]].append([alltimes,float(row[i][8])])
				else:
					outdict[row[i][1]].append([alltimes,float(row[i][8])])
			else:
				alltimes=0
		outpath = 'C:\\Users\\Administrator\\Desktop\\dataset\\测试数据_INEC\\ProcessingResult\\'+num+'_ResultCount.csv'
		outtimes=[]
		outreducesize=[]
		outtimes.append("Times")
		outtimes.append(ExecCategory)
		outtimes.append(m)		
		outtimes.append(num)
		outreducesize.append("ReductSize")
		outreducesize.append(ExecCategory)
		outreducesize.append(m)
		outreducesize.append(num)
		for key in algorithmNamelist:
			if len(outdict[key])>1: #该算法结果不为空
				k=0
				value=outdict[key]
				if len(value)>=10:
					k=10
				else:
					k=5
				timescount=0
				reducesizecount=0
				for i in range(len(value)-1,len(value)-(k+1),-1):
					timescount+=value[i][0]
					outtimes.append(value[i][0])
					reducesizecount+=value[i][1]
					outreducesize.append(value[i][1])			
				if k==5:
					for n in range(0,5):
						outtimes.append(0)
						outreducesize.append(0)
				outtimes.append(timescount/k)
				outreducesize.append(reducesizecount/k)
			else: 
				for n in range(0,11):
					outtimes.append(0)
					outreducesize.append(0)
		# print(outtimes)
		# print(outreducesize)
		if not os.path.exists(outpath):
			#os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
			with open(outpath, 'a', newline='') as file:
				writer = csv.writer(file)
				writer.writerow(['Type','ExecCategory','DataSet','MissingRatio','1','2','3','4','5','6','7','8','9','10','avg_times','1','2','3','4','5','6','7','8','9','10','avg_times','1','2','3','4','5','6','7','8','9','10','avg_times','1','2','3','4','5','6','7','8','9','10','avg_times'])
		with open(outpath, 'a', newline='') as file:
			writer = csv.writer(file)
			writer.writerow(outtimes)
			writer.writerow(outreducesize)
		print(m,"_",num,"_统计完成")







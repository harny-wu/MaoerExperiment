#INEC实验结果统计 每一part的平均时间times


#需求：读取文件夹下文件中每一part的平均时间times整理成表
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

filenum = ['5%','10%','15%','20%']#'5%','10%','15%','20%','25%','30%','35%','40%'
algorithmNamelist=['INEC2','INEC2_threepart_simu']
ExecCategory='IncrementalReduce' #'StaticReduce','IncrementalReduce'
datasetNamelist=["horse-colic_MDLP_missingFill","breast-cancer-wisconsin_missingFill","AR10P"]  #"GLI_85", "BASEHOCK", "car", "Isolet", "leukemia", "madelon", "nci9", "nursery","orlraws10P", "PCMAC", "qsar_androgen_receptor", "gisette"
#"advertisements_MDLP","breast-cancer-wisconsin","horse-colic","mushroom"
#"leukemia","pd_speech_features","tic-tac-toe","madelon","chess","orlraws10P_MDLP","Prostate_GE","AR10P","lung","PIE10P","Dexter","qsar_androgen_receptor","optdigits-orig","gisette_MDLP"
#"nomao","bank-marketing","eeg-eye-state","letter","PhishingWebsites"
for m in datasetNamelist:
	datasetname=m
	inpaths = 'C:\\Users\\凌Y\\Desktop\\工作\\INEC小论文\\实验\\ProcessingResult\\'+datasetname+'_ProcessingResult.csv'  
	#datadf = pd.read_csv(inpaths,header=0)
	f = open(inpaths,"r") 
	outpathnum=''
	lines = f.readlines()      #读取全部内容 ，并以列表方式返回
	row=[]
	for line in lines:
		row.append(line.split(','))
	
	for num in filenum:
		outdict={'INEC2':[[]],'INEC2_threepart_simu':[[]],'INEC2_threepart_turn':[[]],'IFSICE':[[]],'DIDS':[[]],'FSMV':[[]],'FSSNC':[[]]}
		partraw=[]
		# outtimeraw=[]
		# outreducesizeraw=[]
		z=0
		alltimes=0
		parttime=[]
		for i in range(0,len(row)):
			if (row[i][0]!='Time')&(row[i][3]==num)&(row[i][4]==ExecCategory):
				parttime.append(float(row[i][6]))
				alltimes+=float(row[i][6])
				if i!=(len(row)-1):
					if row[i+1][0]=='Time': #一轮结束
						#partraw.append([alltimes,row[i][8]])
						outdict[row[i][1]].append([alltimes,float(row[i][8]),parttime])
						parttime=[]
				else:
					outdict[row[i][1]].append([alltimes,float(row[i][8]),parttime])
			else:
				alltimes=0
				parttime=[]
		outpath = 'C:\\Users\\凌Y\\Desktop\\工作\\INEC小论文\\实验\\ProcessingResult\\'+num+'_ResultCount.csv'
		parttimes=[]
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
		parttimes.append("PartTimes")
		parttimes.append(ExecCategory)
		parttimes.append(m)		
		parttimes.append(num)	
		for key in algorithmNamelist:
			part=[0,0,0,0,0,0,0,0,0,0]
			if len(outdict[key])>1: #该算法结果不为空
				k=0
				value=outdict[key]
				if len(value)>=10:
					k=10
				elif len(value)<5:
					k=1
				else:
					k=5
				timescount=0
				reducesizecount=0
				for i in range(len(value)-1,len(value)-(k+1),-1):
					timescount+=value[i][0]
					outtimes.append(value[i][0])
					for j in range(0,10):
						part[j]+=value[i][2][j]
				for j in range(0,10):
						parttimes.append(part[j]/k)
				parttimes.append("end")
			else: 
				for n in range(0,11):
					parttimes.append(0)
		# print(outtimes)
		# print(outreducesize)
		if not os.path.exists(outpath):
			#os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
			with open(outpath, 'a', newline='') as file:
				writer = csv.writer(file)
				writer.writerow(['Type','ExecCategory','DataSet','MissingRatio','1','2','3','4','5','6','7','8','9','10','avg_times','1','2','3','4','5','6','7','8','9','10','avg_times','1','2','3','4','5','6','7','8','9','10','avg_times','1','2','3','4','5','6','7','8','9','10','avg_times'])
		with open(outpath, 'a', newline='') as file:
			writer = csv.writer(file)
			#writer.writerow(outtimes)
			writer.writerow(parttimes)
		print(m,"_",num,"_统计完成")







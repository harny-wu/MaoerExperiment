# maoer实验结果统计 获取特征选择结果的多次最终约简结果
# 需求：读取文件夹下文件中约简结果整理成表

# 数据读取
# 读取文件夹下所有csv文件
# 数据说明：
import os
from glob import glob
import csv
import re

algorithmNamelist = ['INEC2_threepart_simu']
ExecCategory = 'IncrementalReduce'  # 'StaticReduce'
datasetNamelist = ['0101_0131_all_feature', '0101_0131_all_feature_involved',
                   '0115_0215_all_feature', '0115_0215_all_feature_involved',
                   '0201_0230_all_feature', '0201_0230_all_feature_involved',
                   '1101_1130_all_feature', '1101_1130_all_feature_involved',
                   '1115_1215_all_feature', '1115_1215_all_feature_involved',
                   '1201_1231_all_feature', '1201_1231_all_feature_involved',
                   '1215_0115_all_feature', '1215_0115_all_feature_involved']

for m in datasetNamelist:
    datasetname = m
    inpaths = '/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/ProcessingResult/(Seq) 0101_0131_all_feature_involved_all_deal(D=kmean3)_ProcessingResult.csv'
    outpath = '/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/ProcessingResult/maoer_FS_ResultCount.csv'
    # datadf = pd.read_csv(inpaths,header=0)
    f = open(inpaths, "r")
    outpathnum = ''
    lines = f.readlines()  # 读取全部内容 ，并以列表方式返回
    row = []
    for line in lines:
        row.append(line.split(','))

    outdict = []
    outformat = []
    z = 0
    for i in range(0, len(row)):
        if (row[i][0] != 'Time') & (row[i][3] == '10%') & (row[i][4] == ExecCategory):

            if i != (len(row) - 1):
                if row[i + 1][0] == 'Time':  # 一轮结束
                    numbers = re.findall(r'\d+', row[i][7])
                    reductlist = list(map(int, numbers))
                    outdict.append(reductlist)
            else:
                numbers = re.findall(r'\d+', row[i][7])
                reductlist = list(map(int, numbers))
                outdict.append(reductlist)
    for i in range(-10, 0):
        outformat.append(outdict[i])

    if not os.path.exists(outpath):
        # os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
        with open(outpath, 'a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(
                ['DataSet', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'all_FS'])
    with open(outpath, 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow([datasetname, outformat[0], outformat[1],  outformat[2], outformat[3], outformat[4], outformat[5], outformat[6], outformat[7], outformat[8], outformat[9],outformat])
print("统计完成")

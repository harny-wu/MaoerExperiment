# 输入一个包含列名的数据文件 输出替换列名的新文件
# 输入文件要求：第一行为列名且无索引的csv文件

import pandas as pd

def replace_column_names(input_file, output_file):
    # 读取CSV文件，第一行作为列名
    df = pd.read_csv(input_file, header=0)
    # 添加索引列，并将第一列名设置为 'name'
    df.insert(0, 'name', range(1, len(df) + 1))
    # 将从第二列开始的原列名替换为从0开始递增的数字
    df.columns = ['name'] + list(range(len(df.columns) - 1))
    # 保存结果到新的CSV文件
    df.to_csv(output_file, index=False)


# 输入文件路径
# dataname = '1215_0115'
# input_csv = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature/'+dataname+'_all_feature_hasname.csv'
# input_csv2 = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature_involved/'+dataname+'_all_feature_involved_hasname.csv'
#
# # 输出文件路径
# output_csv = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature/'+dataname+'_all_feature.csv'
# output_csv2 = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature_involved/'+dataname+'_all_feature_involved.csv'

input_csv = "/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/kmean/0101_0131_all_feature_involved_all_deal(D=kmean3).csv"
output_csv = "/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/kmean/(Seq) 0101_0131_all_feature_involved_all_deal(D=kmean3).csv"

# 调用函数进行替换和保存
replace_column_names(input_csv, output_csv)
# replace_column_names(input_csv2, output_csv2)
# print('完成', dataname, '文件列名修改')
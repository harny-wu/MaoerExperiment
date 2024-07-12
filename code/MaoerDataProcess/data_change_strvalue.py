# 将指定列的所有字符型取值映射成数字
# 数据文件要求：包含列，指定第几列
import pandas as pd


def replace_values(input_file, output_file, column_name):
    # 读取CSV文件
    df = pd.read_csv(input_file)

    # 获取指定列的所有唯一值
    unique_values = df[column_name].unique()

    # 创建值映射字典
    # value_mapping_dict = {value: index for index, value in enumerate(unique_values)}
    # 如果存在-1和为空的情况，先排除再添加自定义的映射
    value_mapping_dict = {value: index for index, value in enumerate(unique_values) if
                          value != -1 and value != '' and value is not None}

    # 如果需要将-1和空值映射到-1，可以再添加一个条件
    value_mapping_dict.update({-1: -1, '': -1, None: -1})

    # 将指定列的字符串值替换为数字
    df[column_name] = df[column_name].map(value_mapping_dict)

    # 保存结果到新的CSV文件
    df.to_csv(output_file, index=False)


# 文件路径
dataname = '0101_0131'
input_csv = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature/'+dataname+'_all_feature_hasname.csv'
input_csv2 = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature_involved/'+dataname+'_all_feature_involved_hasname.csv'
input_csv3 = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature_involved/'+dataname+'_all_feature_involved_hasname_continue.csv'
# output_csv = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature/'+dataname+'_all_feature_hasname_test.csv'
# input_csv_t = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/0101_0131_all_feature_involved_kmeans3.csv'

# 指定的列名
column_to_replace = '138'  # drama_type, user_in_sound_review_like_avg_num, user_in_sound_review_subreview_avg_num
#column_to_replace = 'user_in_sound_review_subreview_avg_num'

# 调用函数进行替换和保存
# replace_values(input_csv, input_csv, column_to_replace)
# replace_values(input_csv2, input_csv2, column_to_replace)
# replace_values(input_csv3, input_csv3, column_to_replace)
# replace_values(input_csv_t, input_csv_t, column_to_replace)
# print('完成', column_to_replace, '替换')

# 是否同时完成替换列名操作****************
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

input_csv = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature/'+dataname+'_all_feature_hasname.csv'
input_csv2 = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature_involved/'+dataname+'_all_feature_involved_hasname.csv'

# 输出文件路径
output_csv = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature/'+dataname+'_all_feature.csv'
output_csv2 = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/'+dataname+'_all_feature_involved/'+dataname+'_all_feature_involved.csv'

# 调用函数进行替换和保存
# replace_column_names(input_csv, output_csv)
# replace_column_names(input_csv2, output_csv2)
print('完成', dataname, '文件列名修改')


input_csv_x = "/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/kmean/(Seq) 0101_0131_all_feature_involved_all_deal(D=kmean3).csv"
replace_values(input_csv_x,input_csv_x,column_to_replace)
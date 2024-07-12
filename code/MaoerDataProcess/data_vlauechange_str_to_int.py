# 将数据中每一列判断是否为str类型，替换为int类型
# 数据要求：第一行为列名
import pandas as pd

# 读取 CSV 文件
inputpath = '/Users/ly/Desktop/数据挖掘学习/测试数据/BNLearn/mildew/'
data = pd.read_csv(inputpath+'mildew_500.csv')
outpath = inputpath+'data_column_strtoint.csv'

# 获取列名
columns = data.columns

# 遍历每一列
for column in columns:
    unique_values = data[column].unique()  # 获取列的不重复取值

    # 如果列的数据类型不是int，则进行替换操作
    if data[column].dtype != 'int64':
        replacement_dict = {value: i for i, value in enumerate(unique_values)}
        data[column] = data[column].replace(replacement_dict)
data.to_csv(outpath, index=False)
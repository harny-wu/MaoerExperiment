# 读取csv文件并对每一列计算缺失值，返回每一列的对应列名及其缺失比例
import pandas as pd

# 读取 CSV 文件
df = pd.read_csv('/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/0101_0115_all_feature_MDLP.csv')

# # 计算每一列的缺失比例
# missing_values = df.isnull().sum() / len(df) * 100
#
# # 输出每一列的列名及对应的缺失比例
# for column, missing_percentage in zip(df.columns, missing_values):
#     print(f"Column: {column}, Missing Percentage: {missing_percentage}%")

# 计算缺失值比例和零值比例
result = []
for column in df.columns:
    column_data = df[column]
    missing_count = column_data.isnull().sum()
    zero_count = (column_data == 0).sum()
    missing_ratio = missing_count / len(column_data)
    zero_ratio = zero_count / len(column_data)
    result.append({'Column': column, 'Missing Ratio': missing_ratio, 'Zero Ratio': zero_ratio})

# 打印结果
for item in result:
    print(f"Column: {item['Column']}", f"Missing Ratio: {item['Missing Ratio']*100:.2f}%", f"Zero Ratio: {item['Zero Ratio']*100:.2f}%")
    # print(f"Missing Ratio: {item['Missing Ratio']*100:.2f}%")
    # print(f"Zero Ratio: {item['Zero Ratio']*100:.2f}%")
    # print()
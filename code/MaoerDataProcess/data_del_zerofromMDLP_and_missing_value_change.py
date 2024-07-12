#读取MDLP离散化后的csv文件，删除全为零及缺失值的列，并将所有列的缺失值替换为-1，对于string类型，将所有取值替换为数字
import pandas as pd

def process_csv(input_file, output_file):
    # 读取CSV文件
    df = pd.read_csv(input_file)

    # 判断每一列的取值是否只有空值或零值两种
    empty_zero_cols = []
    for col in df.columns:
        if all(pd.isnull(df[col]) | (df[col] == 0)):
            empty_zero_cols.append(col)

    # 删除全部为空值或零值的列，并记录删除的列的编号和列名
    deleted_cols = []
    for col in empty_zero_cols:
        deleted_cols.append((df.columns.get_loc(col), col))
        del df[col]

    # 替换缺失值为-1
    replaced_cols = []
    for col in df.columns:
        if df[col].isnull().any():
            replaced_ratio = df[col].isnull().sum() / len(df[col])
            df[col].fillna(-1, inplace=True)
            replaced_cols.append((df.columns.get_loc(col), col, replaced_ratio))

    # 保存处理后的DataFrame到新的CSV文件
    df.to_csv(output_file, index=False)

    return deleted_cols, replaced_cols

# 调用函数进行处理
input_file = '/Users/daidaiwu/学校/大论文/data/FS/(Math3-KMeans++ discreted, k=5) 0101_0131_all_feature_involved_all_k_2_15s_sim_q_1.csv'  # 输入CSV文件路径
output_file = '/Users/daidaiwu/学校/大论文/data/FS/(Math3-KMeans++ discreted, k=5) 0101_0131_all_feature_involved_all_k_2_15s_sim_q_1_deal.csv'  # 输出CSV文件路径
deleted_cols, replaced_cols = process_csv(input_file, output_file)

# 打印删除的列 编号从0开始
print("Deleted columns:")
for col in deleted_cols:
    print("Column {}: {}".format(col[0], col[1]))

# 打印替换的列 编号从0开始
print("Replaced columns:")
for col in replaced_cols:
    print("Column {}: {}, Replaced Ratio: {:.2f}%".format(col[0], col[1], col[2] * 100))

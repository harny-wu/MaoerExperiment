# 数据集前置操作
import json
import os

import chardet
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.impute import SimpleImputer

dataset_path = '../../../data/'
data_name = "0101_0131_all_feature_involved.csv"
goal_encoding = 'utf-8'


def detect_file_encoding(file_path):
    with open(file_path, "rb") as file:
        # 读取文件的前 N 个字节（默认为 4096）
        raw_data = file.read(40960)

    # 使用 chardet.detect() 函数检测编码
    result = chardet.detect(raw_data)
    return result["encoding"]


encoding = detect_file_encoding(dataset_path + data_name)
print(f"The detected encoding of {dataset_path + data_name} is: {encoding}")

no_need_col = [
    "sound_id", "user_id", "drama_id", "user_in_drama_is_pay_for_drama_in_next_time"
]

# 决策属性
D = ["all_8_sim", "all_15_sim",
     "k_1_8s_sim", "k_2_8s_sim", "k_3_8s_sim", "k_1_15s_sim", "k_2_15s_sim", "k_3_15s_sim",
     "k_2_8s_sim_q_1_num", "k_2_8s_sim_q_2_num", "k_2_8s_sim_q_3_num", "k_2_15s_sim_q_1_num", "k_2_15s_sim_q_2_num",
     "k_2_15s_sim_q_3_num",
     "pay_FS", "pay_DL"]


# 判断列是否是连续
def is_continuous(series):
    return any('.' in str(value) for value in series.dropna())


# 划分数据类型，连续与离散,并写入文件
def col_type_divide():
    df = pd.read_csv(dataset_path + data_name, na_values=['NULL', 'NaN', 'N/A', 'NA', ''], encoding=encoding)
    col_map = {
        "discrete": [],
        "continues": []
    }
    new_col_name_map = {}
    for col in df.columns:
        if col in no_need_col:
            df.drop(col, axis=1, inplace=True)
            continue
        if col in D:
            continue
        if is_continuous(df[col]):
            col_map["continues"].append(col)
            new_col_name_map[col] = "continues_" + col
        else:
            col_map["discrete"].append(col)
            new_col_name_map[col] = "discrete_" + col
    d_l, c_l = len(col_map.get("discrete")), len(col_map.get("continues"))
    print(f"discrete : {d_l}, continuous: {c_l}")
    json_str = json.dumps(col_map, indent=4)
    with open('column_type_json.json', 'w') as json_file:
        json_file.write(json_str)

    df_rename = df.rename(columns=new_col_name_map)
    new_full_path = dataset_path + data_name.replace(".csv", "_divideType.csv")
    df_rename.to_csv(new_full_path, index=False, encoding=goal_encoding)
    print(f"col_type_divide success: {new_full_path}")


# 按照决策属性构造数据集，删除其他列
def gen_dataset(d_list):
    data_divide_type_name = data_name.replace(".csv", "_divideType.csv")
    for d in d_list:
        df = pd.read_csv(dataset_path + data_divide_type_name, na_values=['NULL', 'NaN', 'N/A', 'NA', ''])
        save_path = dataset_path + data_name.split('.')[0]

        if d not in ["pay_FS", "pay_DL"]:
            kmeans = KMeans(n_clusters=3, random_state=0)
            df[d] = kmeans.fit_predict(df[[d]])

        for col in df.columns:
            # 删除不必要的列
            if col in no_need_col:
                df.drop(col, axis=1, inplace=True)
            # 删除其他决策值
            if col in D:
                if col != d:
                    df.drop(col, axis=1, inplace=True)
            if not os.path.exists(save_path):
                os.mkdir(save_path)
        # 决策值移到最后
        col_b = df.pop(d)
        df[d] = col_b

        new_data_full_path_name = save_path + "/" + data_divide_type_name.replace(".csv", "_" + d + ".csv")
        df.to_csv(new_data_full_path_name, index=False, encoding=goal_encoding)
        print(df.head())
        print(f" D : {d} save to {new_data_full_path_name}")


# 特征选择前的预处理
def fs_dataset_pre_process(dlist):
    for d in dlist:
        dataset_fs_path = dataset_path + data_name.replace(".csv", "") + "/"
        data_fs_name = "(Math3-KMeans++ discreted, k=5) " + data_name.replace(".csv", "_divideType_" + d + ".csv")

        df = pd.read_csv(dataset_fs_path + data_fs_name)
        # 添加索引列，并将第一列名设置为 'name'
        df.insert(0, 'name', range(1, len(df) + 1))
        # 将从第二列开始的原列名替换为从0开始递增的数字
        df.columns = ['name'] + list(range(len(df.columns) - 1))
        # 将空字符串替换为 NaN
        df.replace('', np.nan, inplace=True)
        # 使用 fillna() 方法将 NaN 替换为 -1
        df.fillna(-1, inplace=True)
        # 遍历每一列
        for column in df.columns:
            unique_values = df[column].unique()  # 获取列的不重复取值

            # 如果列的数据类型不是int，则进行替换操作
            if df[column].dtype != 'int64':
                value_mapping_dict = {value: index for index, value in enumerate(unique_values) if
                                      value != -1 and value != '' and value is not None}

                # 如果需要将-1和空值映射到-1，可以再添加一个条件
                value_mapping_dict.update({-1: -1, '': -1, None: -1})
                # 将指定列的字符串值替换为数字
                df[column] = df[column].map(value_mapping_dict)
        # 保存结果到新的CSV文件
        df.to_csv(dataset_fs_path + "FS-" + data_fs_name, index=False, encoding=goal_encoding)
        print("fs_dataset_pre_process sucess")


if __name__ == '__main__':
    # 需要进行划分的决策属性
    d_list = [ "k_2_15s_sim_q_1_num"]
    # col_type_divide()
    gen_dataset(d_list)
    # fs_dataset_pre_process(["pay_FS"])

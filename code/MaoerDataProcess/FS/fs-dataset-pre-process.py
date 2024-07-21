# 数据集前置操作
import json
import os

import chardet
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans

from common import base_path, goal_encoding, no_need_col, D, is_continuous, data_name


# 划分数据类型，连续与离散,并写入文件
def col_type_divide():
    df = pd.read_csv(base_path + data_name, na_values=['NULL', 'NaN', 'N/A', 'NA', ''], encoding=encoding)
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
    new_full_path = base_path + data_name.replace(".csv", "_divideType.csv")
    df_rename.to_csv(new_full_path, index=False, encoding=goal_encoding)
    print(f"col_type_divide success: {new_full_path}")


# 按照决策属性构造数据集，删除其他列
def gen_dataset(d_list):
    data_divide_type_name = data_name.replace(".csv", "_divideType.csv")
    for d in d_list:
        df = pd.read_csv(base_path + data_divide_type_name, na_values=['NULL', 'NaN', 'N/A', 'NA', ''])
        save_path = base_path + data_name.split('.')[0]

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
        dataset_fs_path = base_path + data_name.replace(".csv", "") + "/"
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
    d_list = ["pay_DL"]
    # 区分数据集连续和离散字段
    # col_type_divide()
    # 生成不同决策属性的数据集
    gen_dataset(d_list)
    # 特征选择前的预处理，在这之前要用离散工具手动离散数据集
    # fs_dataset_pre_process(d_list)

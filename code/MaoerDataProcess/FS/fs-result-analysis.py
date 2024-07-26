import csv
import json
import os
import re
from collections import Counter

import pandas as pd

from common import base_path, ExecCategory

time_windows = ["0101_0131"]
dList = ["pay_FS"]


def get_fs_result(time_window, d):
    # data/ProcessingResult/FS-(Math3-KMeans++ discreted, k=5) 0101_0131_all_feature_involved_divideType_pay_FS_ProcessingResult.csv
    input_path = f"{base_path}ProcessingResult/FS-(Math3-KMeans++ discreted k=5) {time_window}_all_feature_divideType_{d}_ProcessingResult.csv"
    f = open(input_path, "r")
    output_path = f"{base_path}/FS-result.csv"
    lines = f.readlines()  # 读取全部内容 ，并以列表方式返回
    row = []
    for line in lines:
        row.append(line.split(','))
    out_dict = []
    outformat = []
    all_fs_set = set()
    for i in range(0, len(row)):
        if (row[i][0] != 'Time') & (row[i][3] == '10%') & (row[i][4] == ExecCategory):
            if i != (len(row) - 1):
                if row[i + 1][0] == 'Time':  # 一轮结束
                    numbers = re.findall(r'\d+', row[i][7])
                    reductlist = list(map(int, numbers))
                    out_dict.append(reductlist)
            else:
                numbers = re.findall(r'\d+', row[i][7])
                reductlist = list(map(int, numbers))
                out_dict.append(reductlist)
    for i in range(-10, 0):
        outformat.append(out_dict[i])

    for out in outformat:
        for v in out:
            all_fs_set.add(v)
    if not os.path.exists(output_path):
        with open(output_path, 'a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(
                ['DataSet', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'all_FS'])
    with open(output_path, 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            [f"{time_window}_{d}_fs", outformat[0], outformat[1], outformat[2], outformat[3], outformat[4],
             outformat[5],
             outformat[6], outformat[7], outformat[8], outformat[9], list(all_fs_set)])

    print(len(all_fs_set))
    print("统计完成")


def fs_analysis():
    all_commonset_feature = []
    QOE_unique_feature = []
    FUFEI_unique_feature = []
    df = pd.read_csv(
        "/data/FS-result.csv",
        header=0)
    # 查找 '数据集名称' 在第一列出现的最后一次的索引
    last_index = df.iloc[::-1][df.columns[0]].tolist().index("0101_0131_pay_FS_fs")
    last_index = len(df) - last_index - 1  # 将倒数的索引转换为正数
    # 根据索引查找对应行的数据
    result_row = df.iloc[last_index]
    # 取出 '列1' 和 '列2' 的值, 使用 eval() 函数将字符串转换为列表
    CHONGHE_value = eval(result_row['重合_对应列名'])
    QOE_value = eval(result_row['契合度独有_对应列名'])
    FUFEI_value = eval(result_row['付费独有_对应列名'])
    all_commonset_feature.extend(CHONGHE_value)
    QOE_unique_feature.extend(QOE_value)
    FUFEI_unique_feature.extend(FUFEI_value)

    # 使用 Counter 统计元素出现次数
    CHONGHE_feature_counts = Counter(all_commonset_feature)
    QOE_unique_feature_counts = Counter(QOE_unique_feature)
    FUFEI_unique_feature_counts = Counter(FUFEI_unique_feature)

    print('重合特征长度', len(CHONGHE_feature_counts))
    print('QOE独有特征长度', len(QOE_unique_feature_counts))
    print('付费独有特征长度', len(FUFEI_unique_feature_counts))

    # 打印重合特征中每个元素出现的次数
    # for element, count in CHONGHE_feature_counts.items():
    #     print(f"{element},{count}")

    # 打印重合+QOE独有特征中每个元素出现的次数
    # 合并两个 Counter 对象
    combined_counts = CHONGHE_feature_counts + QOE_unique_feature_counts
    # 获取每个元素出现在两个集合结合在一起后的次数
    print('重合+QOE独有特特征长度', len(combined_counts))
    for element, count in combined_counts.items():
        print(f"{element},{count}")


def fs_result_to_txt():
    output_path = "DL_windows_fs.csv"
    with open('idx_to_col.json', 'r', encoding='utf-8') as file:
        idx_to_col_map = json.load(file)
    print(idx_to_col_map)
    dataset_fs_path = base_path + "FS-result.csv"
    df = pd.read_csv(dataset_fs_path)

    # 创建一个字典来存储每个DataSet的特征集合
    feature_sets = {}
    for idx, row in df.iterrows():
        features = eval(row['all_FS'])
        feature_set = set(idx_to_col_map[str(feature)] for feature in features)
        feature_sets[row['DataSet']] = feature_set
        print(f"{row['DataSet']},{row['all_FS']}")

    # 找到交叉项目和独有项目
    common_features = set.intersection(*feature_sets.values())
    unique_features = {data_set: feature_set - common_features for data_set, feature_set in feature_sets.items()}

    QoE = []
    CHONGHE = []
    FUFEI = []
    QOE_continue = []
    QOE_discrete = []
    CHONGHE_continue = []
    CHONGHE_discrete = []
    FUFEI_continue = []
    FUFEI_discrete = []
    # 打印结果
    print("\n交叉项目：")
    for feature in common_features:
        print(feature)
        CHONGHE.append(feature)
        if "discrete" in feature:
            CHONGHE_discrete.append(feature)
        else:
            CHONGHE_continue.append(feature)

    print("\nQoE独有项目：")
    for feature in unique_features.get("0101_0131_k_2_15s_sim_q_1_num_fs"):

        QoE.append(feature)
        if "discrete" in feature:
            QOE_discrete.append(feature)
        else:
            QOE_continue.append(feature)

    print("\npay独有项目：")
    for feature in unique_features.get("0101_0131_pay_FS_fs"):

        if "discrete" in feature:
            FUFEI_discrete.append(feature)
        else:
            FUFEI_continue.append(feature)

    if not os.path.exists(output_path):
        with open(output_path, 'a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(
                ['DataSet','QoE,CHONGHE', 'FUFEI,QOE_continue', 'QOE_discrete', 'CHONGHE_continue', 'CHONGHE_discrete',
                 'FUFEI_continue', 'FUFEI_discrete'])
    with open(output_path, 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            ['0101_0131',QoE, CHONGHE, FUFEI, QOE_continue, QOE_discrete, CHONGHE_continue, CHONGHE_discrete, FUFEI_continue,
             FUFEI_discrete])


def fs_to_dl():
    return


if __name__ == '__main__':
    # get_fs_result("0101_0131", "k_2_15s_sim_q_1_num")
    # get_fs_result("0101_0131", "pay_FS")

    # fs_analysis()
    fs_result_to_txt()

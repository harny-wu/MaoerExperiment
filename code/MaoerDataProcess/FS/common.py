import json

import chardet

algorithmNamelist = ['INEC2_threepart_simu']
ExecCategory = 'IncrementalReduce'  # 'StaticReduce'
base_path = "../../../data/"
goal_encoding = "utf-8"
data_name = "0101_0131_all_feature_FS.csv"

no_need_col = [
    "sound_id", "user_id", "drama_id", "user_in_drama_is_pay_for_drama_in_next_time","first_pay","pay_Random"
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


def detect_file_encoding(file_path):
    with open(file_path, "rb") as file:
        # 读取文件的前 N 个字节（默认为 4096）
        raw_data = file.read(40960)

    # 使用 chardet.detect() 函数检测编码
    result = chardet.detect(raw_data)
    print(f"The detected  of {base_path + data_name} is: {result}")

    return result["encoding"]


def get_col_to_idx_map():
    with open('col_to_idx.json', 'r', encoding='utf-8') as file:
        col_to_idx = json.load(file)
    return col_to_idx


encoding = detect_file_encoding(base_path + data_name)

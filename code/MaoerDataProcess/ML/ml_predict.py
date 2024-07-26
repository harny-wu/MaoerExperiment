import random

import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score, accuracy_score, precision_score, f1_score
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier

base_path = "../../../data/"
goal_encoding = "utf-8"
time_window = "0101_0131"

fs_result_fs = pd.read_csv(base_path + "FS-result.csv")

fs_result_map = {}

for idx, row in fs_result_fs.iterrows():
    fs_result_map[row["DataSet"]] = eval(row["all_FS"])


def read_data():
    data = pd.read_csv(f"{base_path}{time_window}_all_feature/{time_window}_all_feature_divideType_pay_DL.csv",
                       na_values=['NULL', 'NaN', 'N/A', 'NA', ''])
    data.replace('', np.nan, inplace=True)
    data = data.replace([np.inf, -np.inf], np.nan)  # 将无穷大值替换为 NaN
    # 处理缺失值（这里以填充众数为例）
    for col in data.columns:
        if 'mode' in locals() and not data[col].empty:  # 检查列是否存在且不为空
            mode = data[col].mode().iloc[0]
            data[col].fillna(mode, inplace=True)

    unique_values = data["discrete_drama_type"].unique()  # 获取列的不重复取值
    replacement_dict = {value: i for i, value in enumerate(unique_values)}
    data["discrete_drama_type"] = data["discrete_drama_type"].replace(replacement_dict)

    # 识别数值型特征和类别型特征
    numeric_features = []
    categorical_features = []

    for col in data.columns[0:-1]:
        data[col] = pd.to_numeric(data[col], errors='coerce')
        if any('.' in str(value) for value in data[col].dropna()):
            data[col] = pd.to_numeric(data[col], errors='coerce')
            categorical_features.append(col)
            data[col] = data[col].fillna(data[col].mode()[0]).astype(int)
        else:
            numeric_features.append(col)
            data[col] = data[col].fillna(data[col].median())

    print(f"len numeric_features: {len(numeric_features)} , {numeric_features}")
    print(f"len categorical_features: {len(categorical_features)} , {categorical_features}")

    data.to_csv('curr_ml_predict.csv', encoding='utf-8', index=False)
    find_null(data)
    # 预处理数据
    X = data.iloc[:, :-1]  # 假设最后一列是目标变量列
    y = data.iloc[:, -1]
    return X, y


def find_null(df):
    # 使用 isnull() 和 any() 函数找到存在空值的行和列
    rows_with_nulls = df.isnull().any(axis=1)
    cols_with_nulls = df.isnull().any(axis=0)

    print("Rows with null values:")
    print(df[rows_with_nulls])

    print("\nColumns with null values:")
    print(cols_with_nulls[cols_with_nulls].index.tolist())


def get_qoe_red_data(data):
    red = fs_result_map[time_window + "_k_2_15s_sim_q_1_num_fs"]
    return data.iloc[:, red]


def get_pay_red_data(data):
    red = fs_result_map[time_window + "_pay_FS_fs"]
    print(red)
    return data.iloc[:, red]


def get_pay_only_red_data(data):
    difference_list = [item for item in fs_result_map[time_window + "_pay_FS_fs"] if
                       item not in fs_result_map[time_window + "_k_2_15s_sim_q_1_num_fs"]]
    return data.iloc[:, difference_list]


def get_qoe_only_red_data(data):
    difference_list = [item for item in fs_result_map[time_window + "_k_2_15s_sim_q_1_num_fs"] if
                       item not in fs_result_map[time_window + "_pay_FS_fs"]]
    return data.iloc[:, difference_list]


def get_pay_qoe_intersection_red_data(data):
    intersection_list = list(
        set(fs_result_map[time_window + "_k_2_15s_sim_q_1_num_fs"]) & set(fs_result_map[time_window + "_pay_FS_fs"]))

    return data.iloc[:, intersection_list]


def get_pay_qoe_union_red_data(data):
    union_list = list(
        set(fs_result_map[time_window + "_k_2_15s_sim_q_1_num_fs"]) | set(fs_result_map[time_window + "_pay_FS_fs"]))
    return data.iloc[:, union_list]


# QoE + Pay - Cross
def get_not_cross_data(data):
    union_list = set(fs_result_map[time_window + "_k_2_15s_sim_q_1_num_fs"]) | set(
        fs_result_map[time_window + "_pay_FS_fs"])
    intersection_list = set(fs_result_map[time_window + "_k_2_15s_sim_q_1_num_fs"]) & set(
        fs_result_map[time_window + "_pay_FS_fs"])
    return data.iloc[:, list(union_list - intersection_list)]


def get_random_data(data, k):
    # 生成一个包含0到608范围内所有整数的列表
    numbers = list(range(0, 609))
    # 从列表中随机选取20个不同的数
    random_numbers = random.sample(numbers, k)
    print(f"red: {random_numbers}")
    return data.iloc[:, random_numbers]


def evaluate(y_test, y_pred):
    acc = accuracy_score(y_test, y_pred)
    auc = roc_auc_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='macro')
    f1 = f1_score(y_test, y_pred, average='macro')
    return acc, auc, precision, f1


def train_predict(X, y, model_list, test_size=0.2, random_state=42):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)
    print(
        f"X_train shape: {X_train.shape}, X_test shape: {X_test.shape}, y_train shape: {y_train.shape}, y_test: {y_test.shape}")
    results = []
    for model_type in model_list:
        if model_type == 'svm':
            model = SVC()
        elif model_type == 'knn':
            model = KNeighborsClassifier()
        elif model_type == 'dt':
            model = DecisionTreeClassifier()
        elif model_type == "lr":
            model = LogisticRegression()
        else:
            raise ValueError("Invalid model type. Choose from 'svm', 'knn', or 'dt'.")

        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        acc, auc, precision, f1 = evaluate(y_test, y_pred)
        print(f"{model_type} : acc : {acc}, auc :{auc}, f1:{f1}, precision:{precision}")
        results.append((model_type, acc, auc, precision, f1))

    return results


def export_results(results_dict):
    df = pd.DataFrame(results_dict)
    df.to_csv("final_results.csv", index=False, mode='a')


if __name__ == '__main__':
    X, y = read_data()
    print(f"process finish , X shape : {X.shape}, Y_shape: {y.shape}")

    model_type_list = ['dt', 'lr', 'svm']  # Change model type to 'knn' or 'dt' if needed

    results = []

    # # 全特征
    # for model_type, acc, auc, precision, f1 in train_predict(X.values, y.values.reshape(-1), model_type_list,
    #                                                          random_state=42):
    #     results.append({
    #         "特征类型": "全特征",
    #         "模型类型": model_type,
    #         "accuracy": acc,
    #         "auc": auc,
    #         "precision": precision,
    #         "f1": f1
    #     })
    #
    # # pay特征
    # X_pay = get_pay_red_data(X)
    # print(f"process finish , X_pay shape : {X_pay.shape}, Y_shape: {y.shape}")
    #
    # for model_type, acc, auc, precision, f1 in train_predict(X_pay.values, y.values.reshape(-1), model_type_list,
    #                                                          random_state=42):
    #     results.append({
    #         "特征类型": "Pay",
    #         "模型类型": model_type,
    #         "accuracy": acc,
    #         "auc": auc,
    #         "precision": precision,
    #         "f1": f1
    #     })
    #
    # # QoE特征
    # X_qoe = get_qoe_red_data(X)
    # print(f"process finish , X_qoe shape : {X_qoe.shape}, Y_shape: {y.shape}")
    #
    # for model_type, acc, auc, precision, f1 in train_predict(X_qoe.values, y.values.reshape(-1), model_type_list,
    #                                                          random_state=42):
    #     results.append({
    #         "特征类型": "QOE",
    #         "模型类型": model_type,
    #         "accuracy": acc,
    #         "auc": auc,
    #         "precision": precision,
    #         "f1": f1
    #     })
    #

    # # QoE only
    # X_qoe_only = get_qoe_only_red_data(X)
    # for model_type, acc, auc, precision, f1 in train_predict(X_qoe_only.values, y.values.reshape(-1),
    #                                                          model_type_list,
    #                                                          random_state=42):
    #     results.append({
    #         "特征类型": "QoE only",
    #         "模型类型": model_type,
    #         "accuracy": acc,
    #         "auc": auc,
    #         "precision": precision,
    #         "f1": f1
    #     })
    #
    # # pay only
    # X_pay_only = get_pay_only_red_data(X)
    # for model_type, acc, auc, precision, f1 in train_predict(X_pay_only.values, y.values.reshape(-1),
    #                                                          model_type_list,
    #                                                          random_state=42):
    #     results.append({
    #         "特征类型": "pay only",
    #         "模型类型": model_type,
    #         "accuracy": acc,
    #         "auc": auc,
    #         "precision": precision,
    #         "f1": f1
    #     })
    #
    # # cross
    # X_cross = get_pay_qoe_intersection_red_data(X)
    # for model_type, acc, auc, precision, f1 in train_predict(X_cross.values, y.values.reshape(-1), model_type_list,
    #                                                          random_state=42):
    #     results.append({
    #         "特征类型": "cross",
    #         "模型类型": model_type,
    #         "accuracy": acc,
    #         "auc": auc,
    #         "precision": precision,
    #         "f1": f1
    #     })
    # export_results(results)

    # X_union = get_pay_qoe_union_red_data(X)
    # for model_type, acc, auc, precision, f1 in train_predict(X_union.values, y.values.reshape(-1), model_type_list,
    #                                                          random_state=42):
    #     results.append({
    #         "特征类型": "union",
    #         "模型类型": model_type,
    #         "accuracy": acc,
    #         "auc": auc,
    #         "precision": precision,
    #         "f1": f1
    #     })
    # export_results(results)

    # X_not_cross = get_not_cross_data(X)
    # for model_type, acc, auc, precision, f1 in train_predict(X_not_cross.values, y.values.reshape(-1), model_type_list,
    #                                                          random_state=42):
    #     results.append({
    #         "特征类型": "not cross",
    #         "模型类型": model_type,
    #         "accuracy": acc,
    #         "auc": auc,
    #         "precision": precision,
    #         "f1": f1
    #     })
    # export_results(results)

    # 初始化一个空列表来存储所有迭代的结果
    all_results = []

    # 运行10次
    for _ in range(10):
        # 从数据集中随机选择20个特征
        X_random_20 = get_random_data(X, 20)

        # 训练模型并获取结果
        for model_type, acc, auc, precision, f1 in train_predict(X_random_20.values, y.values.reshape(-1),
                                                                 model_type_list,
                                                                 random_state=42):
            # 将结果追加到列表中
            all_results.append({
                "特征类型": "random_20",
                "模型类型": model_type,
                "accuracy": acc,
                "auc": auc,
                "precision": precision,
                "f1": f1
            })

    # 计算各项指标的平均值
    average_results = {
        "特征类型": "random_20",
        "模型类型": "average",
        "accuracy": np.mean([result["accuracy"] for result in all_results]),
        "auc": np.mean([result["auc"] for result in all_results]),
        "precision": np.mean([result["precision"] for result in all_results]),
        "f1": np.mean([result["f1"] for result in all_results])
    }
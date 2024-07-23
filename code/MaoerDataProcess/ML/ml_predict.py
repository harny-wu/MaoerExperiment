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


def read_qoe_red_data(data):
    red = fs_result_map[time_window + "_k_2_15s_sim_q_1_num_fs"]
    return data.iloc[:,red]


def read_pay_red(data):
    red = fs_result_map[time_window + "_pay_FS_fs"]
    print(red)
    return data.iloc[:,red]


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
    df.to_csv("final_results.csv", index=False)


if __name__ == '__main__':
    X, y = read_data()
    print(f"process finish , X shape : {X.shape}, Y_shape: {y.shape}")

    model_type_list = ['dt', 'lr', 'svm']  # Change model type to 'knn' or 'dt' if needed

    results = []

    # 全特征
    for model_type, acc, auc, precision, f1 in train_predict(X.values, y.values.reshape(-1), model_type_list,
                                                             random_state=42):
        results.append({
            "特征类型": "全特征",
            "模型类型": model_type,
            "accuracy": acc,
            "auc": auc,
            "precision": precision,
            "f1": f1
        })

    # pay特征
    X_pay = read_pay_red(X)
    print(f"process finish , X_pay shape : {X_pay.shape}, Y_shape: {y.shape}")

    find_null(X_pay)
    for model_type, acc, auc, precision, f1 in train_predict(X_pay.values, y.values.reshape(-1), model_type_list,
                                                             random_state=42):
        results.append({
            "特征类型": "Pay",
            "模型类型": model_type,
            "accuracy": acc,
            "auc": auc,
            "precision": precision,
            "f1": f1
        })

    # QoE特征
    X_qoe = read_qoe_red_data(X)
    print(f"process finish , X_qoe shape : {X_qoe.shape}, Y_shape: {y.shape}")

    find_null(X_qoe)

    for model_type, acc, auc, precision, f1 in train_predict(X_qoe.values, y.values.reshape(-1), model_type_list,
                                                             random_state=42):
        results.append({
            "特征类型": "QOE",
            "模型类型": model_type,
            "accuracy": acc,
            "auc": auc,
            "precision": precision,
            "f1": f1
        })

    export_results(results)

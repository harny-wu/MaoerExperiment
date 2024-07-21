import numpy as np
import pandas as pd
from pandas.core import series
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import roc_auc_score, accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier

base_path = "../../../data/"
goal_encoding = "utf-8"
time_window = "0101_0131"

fs_result_fs = pd.read_csv(base_path + "FS-result.csv")

fs_result_map = {}

for idx, row in fs_result_fs.iterrows():
    fs_result_map[row["DataSet"]] = row["all_FS"]


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

    # 创建预处理器

    data.to_csv('curr_ml_predict.csv', encoding='utf-8', index=False)
    # 预处理数据
    X = data.iloc[:, :-1]  # 假设最后一列是目标变量列
    y = data.iloc[:, -1]
    return X.values, y.values.reshape(-1)


def read_qoe_red():
    return


def read_pay_red():
    return fs_result_map[time_window + "_pay_FS_fs"]


def train_predict(X, y, model_type='svm', test_size=0.2, random_state=42):
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)
    print(f"X_train shape: {X_train.shape}, X_test shape: {X_test.shape}, y_train shape: {y_train.shape}, y_test: {y_test.shape}")
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
    return y_pred, model


def evaluate(y_test, y_pred):
    acc = accuracy_score(y_test, y_pred)
    auc = roc_auc_score(y_test, y_pred)
    return acc, auc


if __name__ == '__main__':
    X, y = read_data()
    print(f"process finish , X shape : {X.shape}, Y_shape: {y.shape}")

    model_type = 'dt'  # Change model type to 'knn' or 'dt' if needed
    y_pred, model = train_predict(X, y, model_type)
    acc, auc = evaluate(y, y_pred)

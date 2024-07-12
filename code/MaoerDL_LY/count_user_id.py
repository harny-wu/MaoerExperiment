# 读取一个csv文件，取指定列‘k1‘不为空的所有行，统计其中第一列中值出现次数大于1的个数
import pandas as pd

# 读取 CSV 文件
data = pd.read_csv('./Dataset/0101_0131_user_pay_pred_feature.csv')

def get_user_excd_once_soundFeatureNotNull_data(data, sound_not_null_feature_name):
    # 取指定列 'k1' 不为空的所有行
    sound_not_null_feature_name = 'voiceProb_sma_de_max numeric'
    filtered_data = data[data[sound_not_null_feature_name].notnull()]

    # 统计第一列中值出现次数大于1的个数
    count = filtered_data['user_id'].value_counts()
    print(count.sum())
    count_greater_than_1 = (count > 1).sum()
    # 获取索引
    count_greater_than_1_rows = count[count > 1]
    # 取出count>1的所有行
    filtered_data_greater_than_1 = filtered_data[filtered_data['user_id'].isin(count_greater_than_1_rows.index)]

    print("筛选", sound_not_null_feature_name, "列不为空后user值出现次数大于1的个数为:", count_greater_than_1)
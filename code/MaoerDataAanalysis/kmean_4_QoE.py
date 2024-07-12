import pandas as pd
from sklearn.cluster import KMeans

inputPath = "/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/kmean/0101_0131_all_feature_involved_all_deal.csv"
outputPath = "/Users/daidaiwu/学校/大论文/MaoerExperiment/data/FS/0101-1031/k_2_15s_sim_q_1_num/kmean/0101_0131_all_feature_involved_all_deal(D=kmean3).csv"

# 读取数据集
data = pd.read_csv(inputPath, encoding='gbk')

# 获取数据集中最后一列的数据
last_column = data.iloc[:, -1]

# 使用KMeans对最后一列进行聚类
kmeans = KMeans(n_clusters=3, random_state=0)  # 您可以根据需要更改聚类数量
kmeans.fit(last_column.values.reshape(-1, 1))

# 将聚类标签替换原始数据集中的最后一列
data.iloc[:, -1] = kmeans.labels_

# 保存更改后的数据集
data.to_csv(outputPath, index=False)
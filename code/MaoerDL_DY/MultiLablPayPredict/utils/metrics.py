# top-n
import numpy as np


def top_evaluation(df_results, n):
    # 初始化结果列表
    ndcg_list = []
    hr_list = []

    for user_id, user_group in df_results.groupby('pos_comment_id'):
        user_group = user_group.sort_values(by='sum_score', ascending=False)  # 按分数降序排序
        top_items = user_group.head(n)['label'].tolist()  # 选取前n个的标签
        true_labels = user_group['label'].tolist()  # 用户所有候选物品的真实标签

        # 计算NDCG
        idcg = sorted(true_labels, reverse=True)[:n]  # 理想情况下的DCG
        dcg = sum(rel / np.log(i + 2) for i, rel in enumerate(top_items))  # 计算DCG
        ndcg = dcg / sum(rel / np.log(i + 2) for i, rel in enumerate(idcg))  # 计算NDCG
        ndcg_list.append(ndcg)
        # 计算HR@N
        hit_rate = 1 if any(label == 1 for label in top_items) else 0  # 若Top N中有真实正样本，HR@N为1，否则为0
        hr_list.append(hit_rate)

    # 计算平均值
    average_ndcg = np.mean(ndcg_list)
    average_hr = np.mean(hr_list)

    return average_ndcg, average_hr

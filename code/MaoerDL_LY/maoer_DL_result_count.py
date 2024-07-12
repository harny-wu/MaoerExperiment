# 猫耳深度学习模型结果统计 输入表：Dataset中的最终结果表
# 找到符合条件的最后5次出现的行，计算对应的AUC、ACC、F1、Precision、Recall的平均值

import pandas as pd

# 读取CSV表
df = pd.read_csv('./Dataset/maoerDL_result_maoer_pay_pred_model3_1.csv')

# 给定的列表
model_list = ['model3.1', 'BiLSTM', 'DNN']
type_list = ['Origin', 'Abb_QOE', 'Abb_FUFEI', 'Abb_QOE&FUFEI']
dataset_list = ['1101_1130', '1115_1215', '1201_1231',  '1215_0115', '0101_0131', '0115_0215', '0201_0230']

# 创建空的DataFrame来存储结果
result_df = pd.DataFrame(columns=['Type', 'dataset', 'model', 'AUC', 'ACC', 'F1', 'Precision', 'Recall'])

# 标准的数据输出 仅均值
# 遍历model、type、dataset列表
# for type_val in type_list:
#     for dataset in dataset_list:
#         for model in model_list:
#             # 获取对应条件的行索引
#             indices = df[(df['model'] == model) & (df['Type'] == type_val) & (df['dataset'] == dataset)].index[-5:]
#             if not indices.empty:
#                 # 取出对应行数据并计算均值
#                 selected_rows = df.loc[indices]
#                 numeric_selected_rows = selected_rows[['AUC', 'ACC', 'F1', 'Precision', 'Recall']].apply(pd.to_numeric, errors='coerce')
#                 avg_values = numeric_selected_rows.mean()
#                 # result_df.loc[f"{model}_{type_val}_{dataset}"] = avg_values
#                 new_row = pd.DataFrame([[type_val, dataset, model, avg_values['AUC'], avg_values['ACC'],
#                                          avg_values['F1'], avg_values['Precision'], avg_values['Recall']], ],
#                                        columns=['Type', 'dataset', 'model', 'AUC', 'ACC', 'F1', 'Precision', 'Recall'])
#                 result_df = result_df._append(new_row, ignore_index=True)
# # 将结果保存到新的CSV文件
# result_df.to_csv('maoer_result_count_output.csv', index_label='Model_Type_Dataset')


# 新 数据输出 格式为：均值±标准差  （乘以100后取两位小数）
# 初始化一个新列用于存储均值±标准差的格式数据
result_df['AUC_std'] = ''
result_df['ACC_std'] = ''
result_df['F1_std'] = ''
result_df['Precision_std'] = ''
result_df['Recall_std'] = ''

for type_val in type_list:
    for dataset in dataset_list:
        for model in model_list:
            # 获取对应条件的行索引
            indices = df[(df['model'] == model) & (df['Type'] == type_val) & (df['dataset'] == dataset)].index[-5:]
            if not indices.empty:
                # 取出对应行数据并转换为数值类型，计算均值和标准差
                selected_rows = df.loc[indices]
                numeric_selected_rows = selected_rows[['AUC', 'ACC', 'F1', 'Precision', 'Recall']].apply(pd.to_numeric, errors='coerce')
                avg_values = numeric_selected_rows.mean()*100
                std_values = numeric_selected_rows.std()*100

                # 将均值和标准差以均值±标准差的形式组合
                auc_value = f"{avg_values['AUC']:.2f}±{std_values['AUC']:.2f}"
                acc_value = f"{avg_values['ACC']:.2f}±{std_values['ACC']:.2f}"
                f1_value = f"{avg_values['F1']:.2f}±{std_values['F1']:.2f}"
                precision_value = f"{avg_values['Precision']:.2f}±{std_values['Precision']:.2f}"
                recall_value = f"{avg_values['Recall']:.2f}±{std_values['Recall']:.2f}"

                new_row = pd.DataFrame([[type_val, dataset, model, auc_value, acc_value,
                                         f1_value, precision_value, recall_value]],
                                       columns=['Type', 'dataset', 'model', 'AUC', 'ACC', 'F1', 'Precision', 'Recall'])

                # 使用pd.concat()追加新的行
                result_df = pd.concat([result_df, new_row], ignore_index=True)

# 将结果保存到新的CSV文件
result_df.to_csv('maoer_result_count_output_add_std.csv', index_label='Model_Type_Dataset')


# 计算重复的特征
# 数据要求：给出两边的几组特征选择结果[0 2 23 43]等等，计算两边的共同特征与非共同特征
import ast
import copy
import csv
import pandas as pd
import numpy as np
import os
from sklearn.metrics import accuracy_score, roc_auc_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score
from sklearn import svm
from sklearn.model_selection import KFold
from sklearn import tree
from sklearn.naive_bayes import MultinomialNB
from sklearn.neighbors import KNeighborsClassifier
from collections import Counter

def find_common_and_unique(list1, list2):
    set1 = set(list1)
    set2 = set(list2)
    # 计算两个列表的交集
    common = sorted(set1.intersection(set2))
    # 计算第一个列表中独有的元素，并按照从小到大排序
    unique_list1 = sorted(set1.difference(set2))
    # 计算第二个列表中独有的元素，并按照从小到大排序
    unique_list2 = sorted(set2.difference(set1))
    return common, unique_list1, unique_list2

def get_commonset_feature_tocsv(input_file, output_file, common_set):
    with open(input_file, "r", newline="") as file:
        reader = csv.reader(file)
        header = next(reader)  # 跳过第一行列名

        # selected_columns = [header[i+1] for i in common_set]  # 获取index_list对应的列名
        # selected_columns.append(header[-1])  # 添加最后一列列名
        selected_columns = []
        selected_columns = copy.deepcopy(common_set)  # 获取index_list对应的列名
        selected_columns.append(len(header)-1)  # 添加最后一列列名

        rows = []
        for row in reader:
            selected_values = [row[i+1] for i in common_set]  # 获取index_list对应的值
            selected_values.append(row[-1])  # 添加最后一列的值
            rows.append(selected_values)

    with open(output_file, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(selected_columns)
        writer.writerows(rows)

# 是否同时完成替换列名操作****************
def replace_column_names(input_file, output_file):
    # 读取CSV文件，第一行作为列名
    df = pd.read_csv(input_file, header=0)
    # 添加索引列，并将第一列名设置为 'name'
    df.insert(0, 'name', range(1, len(df) + 1))
    # 将从第二列开始的原列名替换为从0开始递增的数字
    df.columns = ['name'] + list(range(len(df.columns) - 1))
    # 保存结果到新的CSV文件
    df.to_csv(output_file, index=False)

# 生成对应特征集合index在原数据文件中的对应列+最后一列形成数据集并输出
def generate_output_featureSet(feature_index_set, input_data_path, output_path):
    # 获取数据集
    df = pd.read_csv(input_data_path, header=0)
    # 获取指定列的数据
    selected_columns = df.iloc[:, feature_index_set + [-1]]  # 选择指定列和最后一列
    selected_columns.to_csv(output_path, index=False)  # 将选中的列保存到新的文件中
    replace_column_names(output_path, output_path)   # 替换列名
    return selected_columns
#  获取分类结果并输出
def classifier_run(data, output_path, datasetname, type):
    outpath = output_path

    acc1_list, acc2_list, acc3_list, acc4_list = [], [], [], []
    pre1_list, pre2_list, pre3_list, pre4_list = [], [], [], []
    recall1_list, recall2_list, recall3_list, recall4_list = [], [], [], []
    f11_list, f12_list, f13_list, f14_list = [], [], [], []
    algorithmName = ''
    datadf = data
    # print(datadf.shape)
    # 将csv中数据值为oldword的改写为newword
    new_data = []
    for index, col in datadf.items():
        # 从每列随机选取中一个值
        # ranValue=random.choice(col)
        # 选取一列中出现次数最多的值  离散型
        newcol = list(col)
        count = Counter(newcol).most_common(2)
        if count[0][0] == 100000 or count[0][0] == -1 or count[0][0] is None:
            ranValue = count[1][0]
        else:
            ranValue = count[0][0]
        # ranValue=max(set(newcol), key = newcol.count)
        # 选取一列中的平均值 连续型
        # meanvalue = np.array(col)
        # ranValue=np.mean(meanvalue)
        rep = [ranValue if x == 100000 or x == -1 else x for x in col]
        new_data.append(rep)
    datadf = pd.DataFrame(new_data)
    datadf = datadf.T
    # train_df.to_csv("C:\\Users\\Administrator\\Desktop\\test.csv")

    kf = KFold(n_splits=10, shuffle=True)  # 初始化KFold
    train_files = []  # 存放10折的训练集划分
    test_files = []  # # 存放10折的测试集集划分
    for k, (Trindex, Tsindex) in enumerate(kf.split(datadf)):
        train_files.append(np.array(datadf)[Trindex].tolist())
        test_files.append(np.array(datadf)[Tsindex].tolist())

    for i in range(0, 10):
        train = pd.DataFrame(data=train_files[i])
        test = pd.DataFrame(data=test_files[i])
        train_features = train.iloc[:, 0:-1].values
        train_labels = train.iloc[:, -1].values
        test_features = test.iloc[:, 0:-1].values
        test_labels = test.iloc[:, -1].values

        # SVM
        clf = svm.SVC(C=6.37, kernel='rbf', gamma=0.0039, probability=True, decision_function_shape='ovr')
        clf.fit(train_features, train_labels)
        y_hat = clf.predict(test_features)
        y_prob = clf.predict_proba(test_features)
        acc1 = accuracy_score(test_labels, y_hat)
        acc1_list.append(acc1)
        precision = precision_score(test_labels, y_hat, average='macro')
        recall = recall_score(test_labels, y_hat, average='macro')
        f1 = f1_score(test_labels, y_hat, average='macro')
        pre1_list.append(precision)
        recall1_list.append(recall)
        f11_list.append(f1)
        # C4.5
        clf = tree.DecisionTreeClassifier()  # CART算法 #clf=tree.DecisionTreeClassifier(criterion='entropy')  #ID3算法
        clf.fit(train_features, train_labels)
        y_hat = clf.predict(test_features)
        y_prob = clf.predict_proba(test_features)  # 不准
        acc2 = accuracy_score(y_hat, test_labels)
        acc2_list.append(acc2)
        precision = precision_score(test_labels, y_hat, average='macro')
        recall = recall_score(test_labels, y_hat, average='macro')
        f1 = f1_score(test_labels, y_hat, average='macro')
        pre2_list.append(precision)
        recall2_list.append(recall)
        f12_list.append(f1)
        # NB
        clf = MultinomialNB(alpha=2.0, fit_prior=True, class_prior=None)  # clf=GaussianNB()
        clf.fit(train_features, train_labels)
        y_hat = clf.predict(test_features)
        y_prob = clf.predict_proba(test_features)
        acc3 = accuracy_score(y_hat, test_labels)
        acc3_list.append(acc3)
        precision = precision_score(test_labels, y_hat, average='macro')
        recall = recall_score(test_labels, y_hat, average='macro')
        f1 = f1_score(test_labels, y_hat, average='macro')
        pre3_list.append(precision)
        recall3_list.append(recall)
        f13_list.append(f1)
        # KNN K=3
        clf = KNeighborsClassifier(n_neighbors=3)
        clf.fit(train_features, train_labels)
        y_hat = clf.predict(test_features)
        y_prob = clf.predict_proba(test_features)  # 不准
        acc4 = accuracy_score(y_hat, test_labels)
        acc4_list.append(acc4)
        precision = precision_score(test_labels, y_hat, average='macro')
        recall = recall_score(test_labels, y_hat, average='macro')
        f1 = f1_score(test_labels, y_hat, average='macro')
        pre4_list.append(precision)
        recall4_list.append(recall)
        f14_list.append(f1)

    if not os.path.exists(outpath):
        # os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
        with open(outpath, 'a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(
                ['DataSet', 'MissingRatio', 'Algorithm', 'Classifier', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                 '10', 'avg_acc', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'avg_precision', '1', '2', '3',
                 '4', '5', '6', '7', '8', '9', '10', 'avg_recall', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                 '10', 'avg_f1'])
    with open(outpath, 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(
            [datasetname, type, algorithmName, 'SVM', acc1_list[0], acc1_list[1], acc1_list[2], acc1_list[3],
             acc1_list[4], acc1_list[5], acc1_list[6], acc1_list[7], acc1_list[8], acc1_list[9],
             sum(acc1_list) / 10, pre1_list[0], pre1_list[1], pre1_list[2], pre1_list[3], pre1_list[4],
             pre1_list[5], pre1_list[6], pre1_list[7], pre1_list[8], pre1_list[9], sum(pre1_list) / 10,
             recall1_list[0], recall1_list[1], recall1_list[2], recall1_list[3], recall1_list[4], recall1_list[5],
             recall1_list[6], recall1_list[7], recall1_list[8], recall1_list[9], sum(recall1_list) / 10,
             f11_list[0], f11_list[1], f11_list[2], f11_list[3], f11_list[4], f11_list[5], f11_list[6], f11_list[7],
             f11_list[8], f11_list[9],
             sum(f11_list) / 10])  # ,auc1_list[0], auc1_list[1], auc1_list[2], auc1_list[3], auc1_list[4], auc1_list[5], auc1_list[6], auc1_list[7], auc1_list[8], auc1_list[9],sum(auc1_list)/10])
        writer.writerow(
            [datasetname, type, algorithmName, 'C4.5', acc2_list[0], acc2_list[1], acc2_list[2], acc2_list[3],
             acc2_list[4], acc2_list[5], acc2_list[6], acc2_list[7], acc2_list[8], acc2_list[9],
             sum(acc2_list) / 10, pre2_list[0], pre2_list[1], pre2_list[2], pre2_list[3], pre2_list[4],
             pre2_list[5], pre2_list[6], pre2_list[7], pre2_list[8], pre2_list[9], sum(pre2_list) / 10,
             recall2_list[0], recall2_list[1], recall2_list[2], recall2_list[3], recall2_list[4], recall2_list[5],
             recall2_list[6], recall2_list[7], recall2_list[8], recall2_list[9], sum(recall2_list) / 10,
             f12_list[0], f12_list[1], f12_list[2], f12_list[3], f12_list[4], f12_list[5], f12_list[6], f12_list[7],
             f12_list[8], f12_list[9],
             sum(f12_list) / 10])  # ,auc2_list[0], auc2_list[1], auc2_list[2], auc2_list[3], auc2_list[4], auc2_list[5], auc2_list[6], auc2_list[7], auc2_list[8], auc2_list[9],sum(auc2_list)/10])
        writer.writerow(
            [datasetname, type, algorithmName, 'NB', acc3_list[0], acc3_list[1], acc3_list[2], acc3_list[3],
             acc3_list[4], acc3_list[5], acc3_list[6], acc3_list[7], acc3_list[8], acc3_list[9],
             sum(acc3_list) / 10, pre3_list[0], pre3_list[1], pre3_list[2], pre3_list[3], pre3_list[4],
             pre3_list[5], pre3_list[6], pre3_list[7], pre3_list[8], pre3_list[9], sum(pre3_list) / 10,
             recall3_list[0], recall3_list[1], recall3_list[2], recall3_list[3], recall3_list[4], recall3_list[5],
             recall3_list[6], recall3_list[7], recall3_list[8], recall3_list[9], sum(recall3_list) / 10,
             f13_list[0], f13_list[1], f13_list[2], f13_list[3], f13_list[4], f13_list[5], f13_list[6], f13_list[7],
             f13_list[8], f13_list[9],
             sum(f13_list) / 10])  # , auc3_list[0], auc3_list[1], auc3_list[2], auc3_list[3], auc3_list[4], auc3_list[5], auc3_list[6], auc3_list[7], auc3_list[8], auc3_list[9],sum(auc3_list)/10])
        writer.writerow(
            [datasetname, type, algorithmName, 'KNN', acc4_list[0], acc4_list[1], acc4_list[2], acc4_list[3],
             acc4_list[4], acc4_list[5], acc4_list[6], acc4_list[7], acc4_list[8], acc4_list[9],
             sum(acc4_list) / 10, pre4_list[0], pre4_list[1], pre4_list[2], pre4_list[3], pre4_list[4],
             pre4_list[5], pre4_list[6], pre4_list[7], pre4_list[8], pre4_list[9], sum(pre4_list) / 10,
             recall4_list[0], recall4_list[1], recall4_list[2], recall4_list[3], recall4_list[4], recall4_list[5],
             recall4_list[6], recall4_list[7], recall4_list[8], recall4_list[9], sum(recall4_list) / 10,
             f14_list[0], f14_list[1], f14_list[2], f14_list[3], f14_list[4], f14_list[5], f14_list[6], f14_list[7],
             f14_list[8], f14_list[9],
             sum(f14_list) / 10])
        print(datasetname, "_reduce_Acc完成")




# 输入数据
datasetNamelist = ['0101_0131_all_feature',
                   '0115_0215_all_feature',
                   '0201_0230_all_feature',
                   '1101_1130_all_feature',
                   '1115_1215_all_feature',
                   '1201_1231_all_feature',
                   '1215_0115_all_feature']

inpaths = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/maoer_FS_ResultCount.csv'
all_data = []
with open(inpaths, 'r') as f:
    reader = csv.reader(f)
    # 读取 CSV 文件的第一行作为列名
    headers = next(reader)
    # 初始化一个字典用于记录每个名称最后一次出现的行号
    last_row_num = {}
    for row in reader:
        name = row[0]
        # 如果名称在列表中，则更新该名称最后一次出现的行号
        if name in last_row_num:
            last_row_num[name] = row[0]
        else:
            last_row_num[name] = row
    # 根据名称列表遍历，找到对应最后一次出现的名称的行，并返回该行的最后一列的值
    # for name in last_row_num:
    #     print(name, last_row_num[name][-1])
    #     # 使用ast.literal_eval将字符串转换为一个Python对象
    #     list_data = ast.literal_eval(last_row_num[name][-1])
    #     print(list_data)

for m in datasetNamelist:
    datasetname = m
    datasetname_involved = datasetname+'_involved'
    list_involved_result = ast.literal_eval(last_row_num[datasetname_involved][-1])
    list_pay_result = ast.literal_eval(last_row_num[datasetname][-1])

    # list_involved_result = [[0,1,2,3,4,9,23,24,32,34,44,62,63,64,66,67,68,72,84,93,105,116,118,188,240,248],
    #                         [0,1,2,4,9,19,20,23,26,30,32,33,34,44,61,62,64,66,67,68,69,72,73,84,105,107,115,116,118,120,135],
    #                         [0,1,4,9,15,20,27,32,44,62,63,64,66,68,69,72,75,83,84,91,93,109,116,118,203,235],
    #                         [0,1,4,9,21,27,32,34,44,61,62,63,64,66,67,68,71,72,86,92,93,104,105,110,116,118,136,229],
    #                         [0,1,3,4,9,20,22,35,41,44,62,63,64,66,67,68,69,72,73,84,85,87,93,109,116,118,128,135,248]]
    # list_pay_result = [[0,1,3,4,9,25,32,33,37,39,66,84,116,125,220,233,236],
    #                    [0,1,2,3,4,9,10,19,21,22,23,24,25,35,37,64,66,84,91,177,195,236],
    #                    [0,1,3,4,9,23,26,29,33,37,64,66,84,116,190,201,241],
    #                    [0,2,4,9,15,21,22,23,28,33,64,66,79,84,188,236,241],
    #                    [0,1,3,4,9,15,19,22,23,29,37,61,66,77,84,86,119,130,195,236]]
    # column_name = "user_name_len,user_name_has_chinese,user_name_has_english,user_intro_len,user_intro_has_chinese,user_intro_has_english,user_icon_is_default,user_has_submit_sound_or_darma,user_grade,user_fish_num,user_follower_num,user_fans_num,user_has_organization,user_submit_sound_num,user_submit_drama_num,user_subscribe_drama_num,user_subscribe_channel_num,user_favorite_album_num,user_image_num,user_submit_danmu_drama_completed_num_now,user_submit_danmu_drama_total_view_num,user_submit_danmu_drama_max_view_num,user_submit_danmu_drama_min_view_num,user_submit_danmu_drama_avg_view_num,user_submit_danmu_drama_total_danmu_num,user_submit_danmu_drama_max_danmu_num,user_submit_danmu_drama_min_danmu_num,user_submit_danmu_drama_avg_danmu_num,user_submit_danmu_drama_total_review_num,user_submit_danmu_drama_max_review_num,user_submit_danmu_drama_min_review_num,user_submit_danmu_drama_avg_review_num,user_submit_danmu_sound_total_view_num,user_submit_danmu_sound_max_view_num,user_submit_danmu_sound_min_view_num,user_submit_danmu_sound_avg_view_num,user_submit_danmu_sound_total_danmu_num,user_submit_danmu_sound_max_danmu_num,user_submit_danmu_sound_min_danmu_num,user_submit_danmu_sound_avg_danmu_num,user_submit_danmu_sound_total_review_num,user_submit_danmu_sound_max_review_num,user_submit_danmu_sound_min_review_num,user_submit_danmu_sound_avg_review_num,user_in_sound_is_submit_review,user_in_sound_submit_review_num,user_in_sound_first_review_with_sound_publish_time_diff_days,user_in_sound_latest_review_with_sound_publish_time_diff_days,user_in_sound_review_total_len,user_in_sound_review_len_max,user_in_sound_review_len_min,user_in_sound_review_len_avg,user_in_sound_review_subreview_total_num,user_in_sound_review_subreview_max_num,user_in_sound_review_subreview_min_num,user_in_sound_review_subreview_avg_num,user_in_sound_review_like_total_num,user_in_sound_review_like_max_num,user_in_sound_review_like_min_num,user_in_sound_review_like_avg_num,user_in_sound_is_submit_danmu,user_in_sound_submit_danmu_total_len,user_in_sound_submit_danmu_max_len,user_in_sound_submit_danmu_min_len,user_in_sound_submit_danmu_avg_len,user_in_sound_submit_danmu_num,user_in_sound_danmu_around_15s_total_danmu_max_num,user_in_sound_danmu_around_15s_total_danmu_min_num,user_in_sound_danmu_around_15s_total_danmu_avg_num,user_in_drama_total_review_num,user_in_drama_total_danmu_num,sound_title_len,sound_intro_len,sound_tag_num,sound_type,sound_time,sound_view_num,sound_danmu_num,sound_favorite_num,sound_point_num,sound_review_not_subreview_num,sound_review_subreview_num,sound_is_allow_download,sound_submit_time_between_first_and_this,sound_position_in_total_darma_sound,sound_view_num_in_total_darma_percent,sound_danmu_num_in_total_darma_percent,sound_favorite_num_in_total_darma_percent,sound_point_num_in_total_darma_percent,sound_review_num_in_total_darma_percent,sound_not_subreview_num_in_total_darma_percent,sound_subreview_num_in_total_darma_percent,sound_review_avg_len,sound_review_max_len,sound_review_min_len,sound_review_avg_like_num,sound_review_max_like_num,sound_review_min_like_num,sound_review_submit_time_between_submit_sound_time_max,sound_review_submit_time_between_submit_sound_time_min,sound_review_submit_time_between_submit_sound_time_avg,sound_review_submit_time_between_submit_sound_time_in_7days_num,sound_review_submit_time_between_submit_sound_time_in_14days_num,sound_review_submit_time_between_submit_sound_time_in_30days_num,sound_danmu_avg_len,sound_danmu_max_len,sound_danmu_min_len,sound_danmu_submit_time_between_submit_sound_time_max,sound_danmu_submit_time_between_submit_sound_time_min,sound_danmu_submit_time_between_submit_sound_time_avg,sound_danmu_submit_time_between_submit_sound_time_in_7days_num,sound_danmu_submit_time_between_submit_sound_time_in_14days_num,sound_danmu_submit_time_between_submit_sound_time_in_30days_num,sound_danmu_15s_max_traffic,sound_danmu_15s_min_traffic,sound_danmu_15s_avg_traffic,sound_danmu_15s_max_traffic_position_in_sound,sound_danmu_15s_min_traffic_position_in_sound,sound_cv_total_num,sound_cv_has_userid_num,sound_cv_total_fans_num,sound_cv_max_fans_num,sound_cv_min_fans_num,sound_cv_avg_fans_num,sound_cv_main_cv_total_fans_num,sound_cv_main_cv_max_fans_num,sound_cv_main_cv_min_fans_num,sound_cv_main_cv_avg_fans_num,sound_cv_auxiliary_cv_max_fans_num,sound_cv_auxiliary_cv_min_fans_num,sound_cv_auxiliary_cv_avg_fans_num,sound_tag_total_cite_num,sound_tag_max_cite_num,sound_tag_min_cite_num,sound_tag_avg_cite_num,drama_name_len,drama_intro_len,drama_has_author,drama_is_serialize,drama_total_sound_num,drama_total_view_num,drama_type,drama_tag_num,drama_cv_total_num,drama_cv_total_fans_num,drama_cv_max_fans_num,drama_cv_min_fans_num,drama_cv_avg_fans_num,drama_cv_main_total_fans_num,drama_cv_main_max_fans_num,drama_cv_main_min_fans_num,drama_cv_main_avg_fans_num,drama_cv_aux_max_fans_num,drama_cv_aux_min_fans_num,drama_cv_aux_avg_fans_num,drama_sound_cv_max_num,drama_sound_cv_min_num,drama_sound_cv_avg_num,drama_sound_has_max_cv_num_sound_view_num,drama_sound_has_max_cv_num_sound_danmu_num,drama_sound_has_max_cv_num_sound_favorite_num,drama_sound_has_max_cv_num_sound_point_num,drama_sound_has_max_cv_num_sound_review_num,drama_sound_has_min_cv_num_sound_view_num,drama_sound_has_min_cv_num_sound_danmu_num,drama_sound_has_min_cv_num_sound_favorite_num,drama_sound_has_min_cv_num_sound_point_num,drama_sound_has_min_cv_num_sound_review_num,drama_total_danmu_num,drama_max_danmu_num,drama_min_danmu_num,drama_avg_danmu_num,drama_total_favorite_num,drama_max_favorite_num,drama_min_favorite_num,drama_avg_favorite_num,drama_total_point_num,drama_max_point_num,drama_min_point_num,drama_avg_point_num,drama_total_review_num,drama_max_review_num,drama_min_review_num,drama_avg_review_num,drama_sound_has_max_view_num_sound_danmu_num,drama_sound_has_max_view_num_sound_favorite_num,drama_sound_has_max_view_num_sound_point_num,drama_sound_has_max_view_num_sound_review_num,drama_sound_has_max_view_num_sound_cv_num,drama_sound_has_max_view_num_sound_cv_total_fans_num,drama_sound_has_max_view_num_sound_is_pay,drama_sound_has_min_view_num_sound_danmu_num,drama_sound_has_min_view_num_sound_favorite_num,drama_sound_has_min_view_num_sound_point_num,drama_sound_has_min_view_num_sound_review_num,drama_sound_has_min_view_num_sound_cv_num,drama_sound_has_min_view_num_sound_cv_total_fans_num,drama_sound_has_min_view_num_sound_is_pay,drama_upuser_grade,drama_upuser_fish_num,drama_upuser_fans_num,drama_upuser_follower_num,drama_upuser_submit_sound_num,drama_upuser_submit_drama_num,drama_upuser_subscriptions_num,drama_upuser_channel_num,drama_upuser_submit_sound_total_view_num,drama_upuser_submit_sound_max_view_num,drama_upuser_submit_sound_min_view_num,drama_upuser_submit_sound_avg_view_num,drama_upuser_submit_sound_total_danmu_num,drama_upuser_submit_sound_max_danmu_num,drama_upuser_submit_sound_min_danmu_num,drama_upuser_submit_sound_avg_danmu_num,drama_upuser_submit_sound_total_review_num,drama_upuser_submit_sound_max_review_num,drama_upuser_submit_sound_min_review_num,drama_upuser_submit_sound_avg_review_num,drama_sound_total_time,drama_sound_max_time,drama_sound_min_time,drama_sound_avg_time,drama_sound_max_time_sound_view_num,drama_sound_min_time_sound_view_num,drama_sound_max_time_sound_danmu_num,drama_sound_min_time_sound_danmu_num,drama_sound_max_time_sound_review_num,drama_sound_min_time_sound_review_num,drama_sound_danmu_15s_max_traffic,drama_sound_danmu_15s_min_traffic,drama_sound_danmu_15s_avg_traffic,drama_sound_max_traffic_position_in_sound_avg,drama_sound_min_traffic_position_in_sound_avg,drama_danmu_avg_len,drama_danmu_max_len,drama_danmu_min_len,drama_danmu_submit_time_between_submit_sound_time_max,drama_danmu_submit_time_between_submit_sound_time_min,drama_danmu_submit_time_between_submit_sound_time_avg,drama_danmu_time_between_sound_time_in_7days_num_max,drama_danmu_time_between_sound_time_in_7days_num_min,drama_danmu_time_between_sound_time_in_7days_num_avg,drama_danmu_time_between_sound_time_in_14days_num_max,drama_danmu_time_between_sound_time_in_14days_num_min,drama_danmu_time_between_sound_time_in_14days_num_avg,drama_danmu_time_between_sound_time_in_30days_num_max,drama_danmu_time_between_sound_time_in_30days_num_min,drama_danmu_time_between_sound_time_in_30days_num_avg,drama_sound_tag_total_cite_num,drama_sound_tag_max_cite_num,drama_sound_tag_min_cite_num,drama_sound_tag_avg_cite_num,pcm_RMSenergy_sma_max_numeric,pcm_RMSenergy_sma_min_numeric,pcm_RMSenergy_sma_range_numeric,pcm_RMSenergy_sma_maxPos_numeric,pcm_RMSenergy_sma_minPos_numeric,pcm_RMSenergy_sma_amean_numeric,pcm_RMSenergy_sma_linregc1_numeric,pcm_RMSenergy_sma_linregc2_numeric,pcm_RMSenergy_sma_linregerrQ_numeric,pcm_RMSenergy_sma_stddev_numeric,pcm_RMSenergy_sma_skewness_numeric,pcm_RMSenergy_sma_kurtosis_numeric,pcm_fftMag_mfcc_sma[1]_max_numeric,pcm_fftMag_mfcc_sma[1]_min_numeric,pcm_fftMag_mfcc_sma[1]_range_numeric,pcm_fftMag_mfcc_sma[1]_maxPos_numeric,pcm_fftMag_mfcc_sma[1]_minPos_numeric,pcm_fftMag_mfcc_sma[1]_amean_numeric,pcm_fftMag_mfcc_sma[1]_linregc1_numeric,pcm_fftMag_mfcc_sma[1]_linregc2_numeric,pcm_fftMag_mfcc_sma[1]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[1]_stddev_numeric,pcm_fftMag_mfcc_sma[1]_skewness_numeric,pcm_fftMag_mfcc_sma[1]_kurtosis_numeric,pcm_fftMag_mfcc_sma[2]_max_numeric,pcm_fftMag_mfcc_sma[2]_min_numeric,pcm_fftMag_mfcc_sma[2]_range_numeric,pcm_fftMag_mfcc_sma[2]_maxPos_numeric,pcm_fftMag_mfcc_sma[2]_minPos_numeric,pcm_fftMag_mfcc_sma[2]_amean_numeric,pcm_fftMag_mfcc_sma[2]_linregc1_numeric,pcm_fftMag_mfcc_sma[2]_linregc2_numeric,pcm_fftMag_mfcc_sma[2]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[2]_stddev_numeric,pcm_fftMag_mfcc_sma[2]_skewness_numeric,pcm_fftMag_mfcc_sma[2]_kurtosis_numeric,pcm_fftMag_mfcc_sma[3]_max_numeric,pcm_fftMag_mfcc_sma[3]_min_numeric,pcm_fftMag_mfcc_sma[3]_range_numeric,pcm_fftMag_mfcc_sma[3]_maxPos_numeric,pcm_fftMag_mfcc_sma[3]_minPos_numeric,pcm_fftMag_mfcc_sma[3]_amean_numeric,pcm_fftMag_mfcc_sma[3]_linregc1_numeric,pcm_fftMag_mfcc_sma[3]_linregc2_numeric,pcm_fftMag_mfcc_sma[3]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[3]_stddev_numeric,pcm_fftMag_mfcc_sma[3]_skewness_numeric,pcm_fftMag_mfcc_sma[3]_kurtosis_numeric,pcm_fftMag_mfcc_sma[4]_max_numeric,pcm_fftMag_mfcc_sma[4]_min_numeric,pcm_fftMag_mfcc_sma[4]_range_numeric,pcm_fftMag_mfcc_sma[4]_maxPos_numeric,pcm_fftMag_mfcc_sma[4]_minPos_numeric,pcm_fftMag_mfcc_sma[4]_amean_numeric,pcm_fftMag_mfcc_sma[4]_linregc1_numeric,pcm_fftMag_mfcc_sma[4]_linregc2_numeric,pcm_fftMag_mfcc_sma[4]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[4]_stddev_numeric,pcm_fftMag_mfcc_sma[4]_skewness_numeric,pcm_fftMag_mfcc_sma[4]_kurtosis_numeric,pcm_fftMag_mfcc_sma[5]_max_numeric,pcm_fftMag_mfcc_sma[5]_min_numeric,pcm_fftMag_mfcc_sma[5]_range_numeric,pcm_fftMag_mfcc_sma[5]_maxPos_numeric,pcm_fftMag_mfcc_sma[5]_minPos_numeric,pcm_fftMag_mfcc_sma[5]_amean_numeric,pcm_fftMag_mfcc_sma[5]_linregc1_numeric,pcm_fftMag_mfcc_sma[5]_linregc2_numeric,pcm_fftMag_mfcc_sma[5]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[5]_stddev_numeric,pcm_fftMag_mfcc_sma[5]_skewness_numeric,pcm_fftMag_mfcc_sma[5]_kurtosis_numeric,pcm_fftMag_mfcc_sma[6]_max_numeric,pcm_fftMag_mfcc_sma[6]_min_numeric,pcm_fftMag_mfcc_sma[6]_range_numeric,pcm_fftMag_mfcc_sma[6]_maxPos_numeric,pcm_fftMag_mfcc_sma[6]_minPos_numeric,pcm_fftMag_mfcc_sma[6]_amean_numeric,pcm_fftMag_mfcc_sma[6]_linregc1_numeric,pcm_fftMag_mfcc_sma[6]_linregc2_numeric,pcm_fftMag_mfcc_sma[6]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[6]_stddev_numeric,pcm_fftMag_mfcc_sma[6]_skewness_numeric,pcm_fftMag_mfcc_sma[6]_kurtosis_numeric,pcm_fftMag_mfcc_sma[7]_max_numeric,pcm_fftMag_mfcc_sma[7]_min_numeric,pcm_fftMag_mfcc_sma[7]_range_numeric,pcm_fftMag_mfcc_sma[7]_maxPos_numeric,pcm_fftMag_mfcc_sma[7]_minPos_numeric,pcm_fftMag_mfcc_sma[7]_amean_numeric,pcm_fftMag_mfcc_sma[7]_linregc1_numeric,pcm_fftMag_mfcc_sma[7]_linregc2_numeric,pcm_fftMag_mfcc_sma[7]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[7]_stddev_numeric,pcm_fftMag_mfcc_sma[7]_skewness_numeric,pcm_fftMag_mfcc_sma[7]_kurtosis_numeric,pcm_fftMag_mfcc_sma[8]_max_numeric,pcm_fftMag_mfcc_sma[8]_min_numeric,pcm_fftMag_mfcc_sma[8]_range_numeric,pcm_fftMag_mfcc_sma[8]_maxPos_numeric,pcm_fftMag_mfcc_sma[8]_minPos_numeric,pcm_fftMag_mfcc_sma[8]_amean_numeric,pcm_fftMag_mfcc_sma[8]_linregc1_numeric,pcm_fftMag_mfcc_sma[8]_linregc2_numeric,pcm_fftMag_mfcc_sma[8]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[8]_stddev_numeric,pcm_fftMag_mfcc_sma[8]_skewness_numeric,pcm_fftMag_mfcc_sma[8]_kurtosis_numeric,pcm_fftMag_mfcc_sma[9]_max_numeric,pcm_fftMag_mfcc_sma[9]_min_numeric,pcm_fftMag_mfcc_sma[9]_range_numeric,pcm_fftMag_mfcc_sma[9]_maxPos_numeric,pcm_fftMag_mfcc_sma[9]_minPos_numeric,pcm_fftMag_mfcc_sma[9]_amean_numeric,pcm_fftMag_mfcc_sma[9]_linregc1_numeric,pcm_fftMag_mfcc_sma[9]_linregc2_numeric,pcm_fftMag_mfcc_sma[9]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[9]_stddev_numeric,pcm_fftMag_mfcc_sma[9]_skewness_numeric,pcm_fftMag_mfcc_sma[9]_kurtosis_numeric,pcm_fftMag_mfcc_sma[10]_max_numeric,pcm_fftMag_mfcc_sma[10]_min_numeric,pcm_fftMag_mfcc_sma[10]_range_numeric,pcm_fftMag_mfcc_sma[10]_maxPos_numeric,pcm_fftMag_mfcc_sma[10]_minPos_numeric,pcm_fftMag_mfcc_sma[10]_amean_numeric,pcm_fftMag_mfcc_sma[10]_linregc1_numeric,pcm_fftMag_mfcc_sma[10]_linregc2_numeric,pcm_fftMag_mfcc_sma[10]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[10]_stddev_numeric,pcm_fftMag_mfcc_sma[10]_skewness_numeric,pcm_fftMag_mfcc_sma[10]_kurtosis_numeric,pcm_fftMag_mfcc_sma[11]_max_numeric,pcm_fftMag_mfcc_sma[11]_min_numeric,pcm_fftMag_mfcc_sma[11]_range_numeric,pcm_fftMag_mfcc_sma[11]_maxPos_numeric,pcm_fftMag_mfcc_sma[11]_minPos_numeric,pcm_fftMag_mfcc_sma[11]_amean_numeric,pcm_fftMag_mfcc_sma[11]_linregc1_numeric,pcm_fftMag_mfcc_sma[11]_linregc2_numeric,pcm_fftMag_mfcc_sma[11]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[11]_stddev_numeric,pcm_fftMag_mfcc_sma[11]_skewness_numeric,pcm_fftMag_mfcc_sma[11]_kurtosis_numeric,pcm_fftMag_mfcc_sma[12]_max_numeric,pcm_fftMag_mfcc_sma[12]_min_numeric,pcm_fftMag_mfcc_sma[12]_range_numeric,pcm_fftMag_mfcc_sma[12]_maxPos_numeric,pcm_fftMag_mfcc_sma[12]_minPos_numeric,pcm_fftMag_mfcc_sma[12]_amean_numeric,pcm_fftMag_mfcc_sma[12]_linregc1_numeric,pcm_fftMag_mfcc_sma[12]_linregc2_numeric,pcm_fftMag_mfcc_sma[12]_linregerrQ_numeric,pcm_fftMag_mfcc_sma[12]_stddev_numeric,pcm_fftMag_mfcc_sma[12]_skewness_numeric,pcm_fftMag_mfcc_sma[12]_kurtosis_numeric,pcm_zcr_sma_max_numeric,pcm_zcr_sma_min_numeric,pcm_zcr_sma_range_numeric,pcm_zcr_sma_maxPos_numeric,pcm_zcr_sma_minPos_numeric,pcm_zcr_sma_amean_numeric,pcm_zcr_sma_linregc1_numeric,pcm_zcr_sma_linregc2_numeric,pcm_zcr_sma_linregerrQ_numeric,pcm_zcr_sma_stddev_numeric,pcm_zcr_sma_skewness_numeric,pcm_zcr_sma_kurtosis_numeric,voiceProb_sma_max_numeric,voiceProb_sma_min_numeric,voiceProb_sma_range_numeric,voiceProb_sma_maxPos_numeric,voiceProb_sma_minPos_numeric,voiceProb_sma_amean_numeric,voiceProb_sma_linregc1_numeric,voiceProb_sma_linregc2_numeric,voiceProb_sma_linregerrQ_numeric,voiceProb_sma_stddev_numeric,voiceProb_sma_skewness_numeric,voiceProb_sma_kurtosis_numeric,F0_sma_max_numeric,F0_sma_min_numeric,F0_sma_range_numeric,F0_sma_maxPos_numeric,F0_sma_minPos_numeric,F0_sma_amean_numeric,F0_sma_linregc1_numeric,F0_sma_linregc2_numeric,F0_sma_linregerrQ_numeric,F0_sma_stddev_numeric,F0_sma_skewness_numeric,F0_sma_kurtosis_numeric,pcm_RMSenergy_sma_de_max_numeric,pcm_RMSenergy_sma_de_min_numeric,pcm_RMSenergy_sma_de_range_numeric,pcm_RMSenergy_sma_de_maxPos_numeric,pcm_RMSenergy_sma_de_minPos_numeric,pcm_RMSenergy_sma_de_amean_numeric,pcm_RMSenergy_sma_de_linregc1_numeric,pcm_RMSenergy_sma_de_linregc2_numeric,pcm_RMSenergy_sma_de_linregerrQ_numeric,pcm_RMSenergy_sma_de_stddev_numeric,pcm_RMSenergy_sma_de_skewness_numeric,pcm_RMSenergy_sma_de_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[1]_max_numeric,pcm_fftMag_mfcc_sma_de[1]_min_numeric,pcm_fftMag_mfcc_sma_de[1]_range_numeric,pcm_fftMag_mfcc_sma_de[1]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[1]_minPos_numeric,pcm_fftMag_mfcc_sma_de[1]_amean_numeric,pcm_fftMag_mfcc_sma_de[1]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[1]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[1]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[1]_stddev_numeric,pcm_fftMag_mfcc_sma_de[1]_skewness_numeric,pcm_fftMag_mfcc_sma_de[1]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[2]_max_numeric,pcm_fftMag_mfcc_sma_de[2]_min_numeric,pcm_fftMag_mfcc_sma_de[2]_range_numeric,pcm_fftMag_mfcc_sma_de[2]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[2]_minPos_numeric,pcm_fftMag_mfcc_sma_de[2]_amean_numeric,pcm_fftMag_mfcc_sma_de[2]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[2]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[2]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[2]_stddev_numeric,pcm_fftMag_mfcc_sma_de[2]_skewness_numeric,pcm_fftMag_mfcc_sma_de[2]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[3]_max_numeric,pcm_fftMag_mfcc_sma_de[3]_min_numeric,pcm_fftMag_mfcc_sma_de[3]_range_numeric,pcm_fftMag_mfcc_sma_de[3]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[3]_minPos_numeric,pcm_fftMag_mfcc_sma_de[3]_amean_numeric,pcm_fftMag_mfcc_sma_de[3]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[3]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[3]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[3]_stddev_numeric,pcm_fftMag_mfcc_sma_de[3]_skewness_numeric,pcm_fftMag_mfcc_sma_de[3]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[4]_max_numeric,pcm_fftMag_mfcc_sma_de[4]_min_numeric,pcm_fftMag_mfcc_sma_de[4]_range_numeric,pcm_fftMag_mfcc_sma_de[4]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[4]_minPos_numeric,pcm_fftMag_mfcc_sma_de[4]_amean_numeric,pcm_fftMag_mfcc_sma_de[4]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[4]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[4]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[4]_stddev_numeric,pcm_fftMag_mfcc_sma_de[4]_skewness_numeric,pcm_fftMag_mfcc_sma_de[4]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[5]_max_numeric,pcm_fftMag_mfcc_sma_de[5]_min_numeric,pcm_fftMag_mfcc_sma_de[5]_range_numeric,pcm_fftMag_mfcc_sma_de[5]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[5]_minPos_numeric,pcm_fftMag_mfcc_sma_de[5]_amean_numeric,pcm_fftMag_mfcc_sma_de[5]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[5]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[5]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[5]_stddev_numeric,pcm_fftMag_mfcc_sma_de[5]_skewness_numeric,pcm_fftMag_mfcc_sma_de[5]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[6]_max_numeric,pcm_fftMag_mfcc_sma_de[6]_min_numeric,pcm_fftMag_mfcc_sma_de[6]_range_numeric,pcm_fftMag_mfcc_sma_de[6]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[6]_minPos_numeric,pcm_fftMag_mfcc_sma_de[6]_amean_numeric,pcm_fftMag_mfcc_sma_de[6]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[6]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[6]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[6]_stddev_numeric,pcm_fftMag_mfcc_sma_de[6]_skewness_numeric,pcm_fftMag_mfcc_sma_de[6]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[7]_max_numeric,pcm_fftMag_mfcc_sma_de[7]_min_numeric,pcm_fftMag_mfcc_sma_de[7]_range_numeric,pcm_fftMag_mfcc_sma_de[7]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[7]_minPos_numeric,pcm_fftMag_mfcc_sma_de[7]_amean_numeric,pcm_fftMag_mfcc_sma_de[7]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[7]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[7]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[7]_stddev_numeric,pcm_fftMag_mfcc_sma_de[7]_skewness_numeric,pcm_fftMag_mfcc_sma_de[7]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[8]_max_numeric,pcm_fftMag_mfcc_sma_de[8]_min_numeric,pcm_fftMag_mfcc_sma_de[8]_range_numeric,pcm_fftMag_mfcc_sma_de[8]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[8]_minPos_numeric,pcm_fftMag_mfcc_sma_de[8]_amean_numeric,pcm_fftMag_mfcc_sma_de[8]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[8]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[8]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[8]_stddev_numeric,pcm_fftMag_mfcc_sma_de[8]_skewness_numeric,pcm_fftMag_mfcc_sma_de[8]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[9]_max_numeric,pcm_fftMag_mfcc_sma_de[9]_min_numeric,pcm_fftMag_mfcc_sma_de[9]_range_numeric,pcm_fftMag_mfcc_sma_de[9]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[9]_minPos_numeric,pcm_fftMag_mfcc_sma_de[9]_amean_numeric,pcm_fftMag_mfcc_sma_de[9]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[9]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[9]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[9]_stddev_numeric,pcm_fftMag_mfcc_sma_de[9]_skewness_numeric,pcm_fftMag_mfcc_sma_de[9]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[10]_max_numeric,pcm_fftMag_mfcc_sma_de[10]_min_numeric,pcm_fftMag_mfcc_sma_de[10]_range_numeric,pcm_fftMag_mfcc_sma_de[10]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[10]_minPos_numeric,pcm_fftMag_mfcc_sma_de[10]_amean_numeric,pcm_fftMag_mfcc_sma_de[10]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[10]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[10]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[10]_stddev_numeric,pcm_fftMag_mfcc_sma_de[10]_skewness_numeric,pcm_fftMag_mfcc_sma_de[10]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[11]_max_numeric,pcm_fftMag_mfcc_sma_de[11]_min_numeric,pcm_fftMag_mfcc_sma_de[11]_range_numeric,pcm_fftMag_mfcc_sma_de[11]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[11]_minPos_numeric,pcm_fftMag_mfcc_sma_de[11]_amean_numeric,pcm_fftMag_mfcc_sma_de[11]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[11]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[11]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[11]_stddev_numeric,pcm_fftMag_mfcc_sma_de[11]_skewness_numeric,pcm_fftMag_mfcc_sma_de[11]_kurtosis_numeric,pcm_fftMag_mfcc_sma_de[12]_max_numeric,pcm_fftMag_mfcc_sma_de[12]_min_numeric,pcm_fftMag_mfcc_sma_de[12]_range_numeric,pcm_fftMag_mfcc_sma_de[12]_maxPos_numeric,pcm_fftMag_mfcc_sma_de[12]_minPos_numeric,pcm_fftMag_mfcc_sma_de[12]_amean_numeric,pcm_fftMag_mfcc_sma_de[12]_linregc1_numeric,pcm_fftMag_mfcc_sma_de[12]_linregc2_numeric,pcm_fftMag_mfcc_sma_de[12]_linregerrQ_numeric,pcm_fftMag_mfcc_sma_de[12]_stddev_numeric,pcm_fftMag_mfcc_sma_de[12]_skewness_numeric,pcm_fftMag_mfcc_sma_de[12]_kurtosis_numeric,pcm_zcr_sma_de_max_numeric,pcm_zcr_sma_de_min_numeric,pcm_zcr_sma_de_range_numeric,pcm_zcr_sma_de_maxPos_numeric,pcm_zcr_sma_de_minPos_numeric,pcm_zcr_sma_de_amean_numeric,pcm_zcr_sma_de_linregc1_numeric,pcm_zcr_sma_de_linregc2_numeric,pcm_zcr_sma_de_linregerrQ_numeric,pcm_zcr_sma_de_stddev_numeric,pcm_zcr_sma_de_skewness_numeric,pcm_zcr_sma_de_kurtosis_numeric,voiceProb_sma_de_max_numeric,voiceProb_sma_de_min_numeric,voiceProb_sma_de_range_numeric,voiceProb_sma_de_maxPos_numeric,voiceProb_sma_de_minPos_numeric,voiceProb_sma_de_amean_numeric,voiceProb_sma_de_linregc1_numeric,voiceProb_sma_de_linregc2_numeric,voiceProb_sma_de_linregerrQ_numeric,voiceProb_sma_de_stddev_numeric,voiceProb_sma_de_skewness_numeric,voiceProb_sma_de_kurtosis_numeric,F0_sma_de_max_numeric,F0_sma_de_min_numeric,F0_sma_de_range_numeric,F0_sma_de_maxPos_numeric,F0_sma_de_minPos_numeric,F0_sma_de_amean_numeric,F0_sma_de_linregc1_numeric,F0_sma_de_linregc2_numeric,F0_sma_de_linregerrQ_numeric,F0_sma_de_stddev_numeric,F0_sma_de_skewness_numeric,F0_sma_de_kurtosis_numeric,sim_1"
    # name_list = column_name.split(",")

    list1 = list(set([item for sublist in list_involved_result for item in sublist]))
    list2 = list(set([item for sublist in list_pay_result for item in sublist]))

    common_set, unique_list1, unique_list2 = find_common_and_unique(list1, list2)


    # 输出重合部分的列与最后一列的文件
    dataset = datasetname
    input_file = "/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/"+dataset+"_involved/"+dataset+"_involved_hasname.csv"
    input_file2 = "/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/"+dataset+"_involved/"+dataset+"_involved_hasname_continue.csv"
    input_file3 = "/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/"+dataset+"/"+dataset+"_hasname.csv"
    output_file = "/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/"+dataset+"_involved/"+"calculate_repeat_feature_Reduce.csv"
    output_file2 = "/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/"+dataset+"_involved/"+"calculate_repeat_feature_Reduce_continue.csv"
    output_file3 = "/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/"+dataset+"/"+"calculate_repeat_feature_Reduce.csv"
    output_result = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/maoer_FS_chonghe_ResultCount.csv'
    output_acc_result = '/Users/ly/Desktop/工作/大论文/数据/ProcessingResult/maoer_FS_chonghe_ACC_ResultCount.csv'
    output_CHONGHE_file = "/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/"+dataset+"/"

    # 获取namelist
    df = pd.read_csv(input_file)
    name_list = df.columns.tolist()
    # 输出分类结果
    selected_columns_CHONGHE_QOE = generate_output_featureSet(common_set, input_file, output_CHONGHE_file+'maoer_CHONGHE_QOE_feature.csv')
    #classifier_run(selected_columns_CHONGHE_QOE, output_acc_result, datasetname ,'CHONGHE_QOE')
    selected_columns_CHONGHE_PAY = generate_output_featureSet(common_set, input_file3, output_CHONGHE_file+'maoer_CHONGHE_PAY_feature.csv')
    #classifier_run(selected_columns_CHONGHE_PAY, output_acc_result,  datasetname ,'CHONGHE_PAY')
    selected_columns_QOE = generate_output_featureSet(unique_list1, input_file, output_CHONGHE_file+'maoer_QOE_feature.csv')
    #classifier_run(selected_columns_QOE, output_acc_result,  datasetname ,'QOE')
    selected_columns_FUFEI = generate_output_featureSet(unique_list2, input_file3, output_CHONGHE_file+'maoer_FUFEI_feature.csv')
    #classifier_run(selected_columns_FUFEI, output_acc_result, datasetname , 'FUFEI')
    print('分类结果已输出')

    # output
    print("dataset:", dataset)
    print("重合的数字集合：", common_set, "长度：", len(common_set))
    output_list1 = [name_list[i] for i in common_set]
    print("对应列名：",output_list1)
    print("第一组（契合度）中非重合的部分：", unique_list1, "长度：", len(unique_list1))
    output_list2 = [name_list[i] for i in unique_list1]
    print("对应列名：",output_list2)
    print("第二组（付费）中非重合的部分：", unique_list2, "长度：", len(unique_list2))
    output_list3 = [name_list[i] for i in unique_list2]
    print("对应列名：", output_list3)

    # if not os.path.exists(output_result):
    #     # os.system(r"touch {}".format(outpath))#调用系统命令行来创建文件
    #     with open(output_result, 'a', newline='') as file:
    #         writer = csv.writer(file)
    #         writer.writerow(
    #             ['DataSet', '重合的数字集合', '长度', '对应列名', '契合度_非重合部分', '长度', '对应列名', '付费_非重合部分', '长度', '对应列名'])
    # with open(output_result, 'a', newline='') as file:
    #     writer = csv.writer(file)
    #     writer.writerow(
    #         [dataset, common_set, len(common_set), output_list1, unique_list1, len(unique_list1),
    #          output_list2, unique_list2, len(unique_list2), output_list3])
    #
    # get_commonset_feature_tocsv(input_file, output_file, common_set)
    # get_commonset_feature_tocsv(input_file2, output_file2, common_set)
    # get_commonset_feature_tocsv(input_file3, output_file3, common_set)


import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import copy
from torch.utils.data import Dataset, DataLoader, TensorDataset
import datetime
import config
from data_tool import DataTool
from model import base_model
from model.base_model import MatchingModel, model_training, test_model
import vec_tool, debug_tool

# data input
data_time_windows_list = ['0101_0131']  # '0115_0215',


# 由于模型输入得是张量，因此在之前将字典转化为了张量，现在将它转换回去
class TensorDatasettoDict(Dataset):
    def __init__(self, dataset, keys):
        self.dataset = dataset
        self.keys = keys

    def __len__(self):
        return len(self.dataset)

    def __getitem__(self, idx):
        data = self.dataset[idx]
        sample = {key: data[i] for i, key in enumerate(self.keys)}
        return sample


if __name__ == '__main__':
    data_time_windows = '0101_0131'
    data_path = "D:/academic\MaoerExperiment\code\MaoerDL_DY\maoer\DataSet/"
    # path = './Dataset/' + data_time_windows + '_user_pay_pred_feature_deal.csv'
    train_path = data_path + data_time_windows + '_all_feature_FS_deal.csv'
    test_path = data_path + data_time_windows + '_all_feature_DL_deal.csv'
    dataset_spilt_path = data_path + data_time_windows + '_user_pay_pred_feature_spilt.csv'
    output_weight_result_path = data_path + data_time_windows + '_user_pay_pred_result_weight.csv'
    data_feature_continue_discrete_namelist_path = data_path + 'DL_windows_fs_new.csv'  # 连续与离散划分表
    # 获取时间窗内连续与离散特征名的列表(获取列名)
    user_history_pay_QOE_continue_column, user_history_pay_CHONGHE_continue_column, \
        user_history_pay_FUFEI_continue_column, user_history_pay_QOE_discrete_column, \
        user_history_pay_CHONGHE_discrete_column, user_history_pay_FUFEI_discrete_column = DataTool.get_continue_discrete_feature_namelist(
        data_time_windows, data_feature_continue_discrete_namelist_path)

    user_feature_continue_column = []
    user_feature_discrete_column = []
    # total continue feature
    total_continue_feature = user_feature_continue_column + user_history_pay_QOE_continue_column + user_history_pay_CHONGHE_continue_column + user_history_pay_FUFEI_continue_column
    total_discrete_feature = user_feature_discrete_column + user_history_pay_QOE_discrete_column + user_history_pay_CHONGHE_discrete_column + user_history_pay_FUFEI_discrete_column
    # 付费label(离散特征)
    total_discrete_feature_add_D = user_feature_discrete_column + user_history_pay_QOE_discrete_column + user_history_pay_CHONGHE_discrete_column + user_history_pay_FUFEI_discrete_column
    total_discrete_feature_add_D.append('pay_DL')
    user_history_pay_CHONGHE_discrete_column_add_D = copy.deepcopy(user_history_pay_CHONGHE_discrete_column)
    user_history_pay_CHONGHE_discrete_column_add_D.append('pay_DL')
    tensor_dict_idx = ['pay_QOE_continue', 'pay_QOE_discrete', 'pay_CHONGHE_continue', 'pay_CHONGHE_discrete',
                       'pay_FUFEI_continue', 'pay_FUFEI_discrete', 'target_QOE_continue', 'target_QOE_discrete',
                       'target_CHONGHE_continue', 'target_CHONGHE_discrete', 'target_FUFEI_continue',
                       'target_FUFEI_discrete']

    # 形成对应需要的特征名称列表
    feature_column_dict = {
        'user_info_continue': user_feature_continue_column,  # []
        'user_info_discrete': user_feature_discrete_column,  # []
        'history_QOE_continue': user_history_pay_QOE_continue_column,
        'history_QOE_discrete': user_history_pay_QOE_discrete_column,
        'history_CHONGHE_continue': user_history_pay_CHONGHE_continue_column,
        'history_CHONGHE_discrete': user_history_pay_CHONGHE_discrete_column,
        'history_FUFEI_continue': user_history_pay_FUFEI_continue_column,
        'history_FUFEI_discrete': user_history_pay_FUFEI_discrete_column,
        'history_CHONGHE_discrete_add_D': user_history_pay_CHONGHE_discrete_column_add_D
    }
    # 创建一个空的DataFrame来存储结果
    test_auc_df = pd.DataFrame(
        columns=['时间', 'model', '运行位置', 'Type', 'dataset', 'train_ratio', 'feature_embedding', 'batchSize', 'lr',
                 'max_history_len', '实验数', '测试集总损失', 'AUC', 'ACC', 'F1', 'Precision', 'Recall'])
    test_weight_df = pd.DataFrame(
        columns=['时间', 'model', '运行位置', 'Type', 'dataset', 'train_ratio', 'feature_embedding', 'batchSize', 'lr',
                 'max_history_len', '实验数', 'se_user_pay_QOE_weight', 'se_user_pay_CHONGHE_weight',
                 'se_user_pay_FUFEI_weight', 'se_target_QOE_weight', 'se_target_CHONGHE_weight',
                 'se_target_FUFEI_weight', \
                 'target_history_pay_attention_QOE_weight', 'target_history_pay_attention_CHONGHE_weight',
                 'target_history_pay_attention_FUFEI_weight'])
    for i in range(5):
        """
        主要用于在反向传播（backward pass）过程中，如果有任何计算图中的操作产生了异常，比如 NaN（不是数字）或者 inf（无限大）值，它会给出详细的错误信息
        """
        torch.autograd.set_detect_anomaly(True)
        print(f"i=:{i + 1}")
        n = i
        # 数据集 train、val、test划分及总数据hash表(以user_id为key的存储对应对应行的hash表)及不同类特征数存储的字典

        # xxx_list: user_id的列表
        # data_hash: 所有数据（包括训练、验证、测试）
        # feature_category_num_dict: 各列的值的数量的字典 key:列名, value:数量
        train_list, val_list, test_list, train_data_hash, data_hash, feature_category_num_dict = DataTool.data_input(
            data_time_windows, train_path, test_path, dataset_spilt_path, config.val_ratio, config.test_ratio,
            total_continue_feature, total_discrete_feature)

        # 样本数大于5的user
        train_list, val_list, test_list = debug_tool.less_sample(train_data_hash, data_hash)

        # 获取训练、验证、测试集对应的数据形成的向量hash存储及label
        # 数据以key-value形式存储，key为user_id，value的维度为(max_history_len, feature_num), label的维度为(1, batch)
        train_data_tensor_hash, train_label, train_data_tensor_hash_history_mask = vec_tool.get_feature_to_matrix(
            train_list,
            train_data_hash,
            feature_column_dict)

        val_data_tensor_hash, val_label, val_data_tensor_hash_history_mask = vec_tool.get_feature_to_matrix(val_list,
                                                                                                            data_hash,
                                                                                                            feature_column_dict)
        test_data_tensor_hash, test_label, test_data_tensor_hash_history_mask = vec_tool.get_feature_to_matrix(
            test_list,
            data_hash,
            feature_column_dict)

        # 生成batch再添加维度对齐张量（三个维度）这里张量输出的全是三维 (batch_size, 1 or max_history_len, feature_num)
        train_batch_feature_tensor_dict = vec_tool.generate_user_feature_alignment_tensor(train_list,
                                                                                          train_data_tensor_hash)
        val_batch_feature_tensor_dict = vec_tool.generate_user_feature_alignment_tensor(val_list, val_data_tensor_hash)
        test_batch_feature_tensor_dict = vec_tool.generate_user_feature_alignment_tensor(test_list,
                                                                                         test_data_tensor_hash)

        train_label_tensor = torch.tensor(train_label)
        val_label_tensor = torch.tensor(val_label)
        test_label_tensor = torch.tensor(test_label)

        train_label_tensor = train_label_tensor.unsqueeze(-1)
        val_label_tensor = val_label_tensor.unsqueeze(-1)
        test_label_tensor = test_label_tensor.unsqueeze(-1)  # 在最后新增一个维度，因为TensorDataset要第一维大小相同 label变为(batch,1)

        train_user_id_list_tensor = torch.tensor(train_list)
        val_user_id_list_tensor = torch.tensor(val_list)
        test_user_id_list_tensor = torch.tensor(test_list)

        train_user_id_list_tensor = train_user_id_list_tensor.unsqueeze(-1)
        val_user_id_list_tensor = val_user_id_list_tensor.unsqueeze(-1)
        test_user_id_list_tensor = test_user_id_list_tensor.unsqueeze(-1)  # 在

        # mask矩阵的字典
        train_batch_feature_tensor_history_mask_dict = vec_tool.generate_user_feature_alignment_tensor(train_list,
                                                                                                       train_data_tensor_hash_history_mask,
                                                                                                       is_mask=True)
        val_batch_feature_tensor_history_mask_dict = vec_tool.generate_user_feature_alignment_tensor(val_list,
                                                                                                     val_data_tensor_hash_history_mask,
                                                                                                     is_mask=True)
        test_batch_feature_tensor_history_mask_dict = vec_tool.generate_user_feature_alignment_tensor(test_list,
                                                                                                      test_data_tensor_hash_history_mask,
                                                                                                      is_mask=True)
        print('张量生成完成')

        # # TensorDataset输入得是张量，因此由字典转为张量
        train_batch_feature_tensor_pay_QOE_discrete = train_batch_feature_tensor_dict['pay_QOE_discrete']
        train_batch_feature_tensor_pay_CHONGHE_discrete = train_batch_feature_tensor_dict['pay_CHONGHE_discrete']
        train_batch_feature_tensor_pay_FUFEI_discrete = train_batch_feature_tensor_dict['pay_FUFEI_discrete']
        train_batch_feature_tensor_pay_QOE_continue = train_batch_feature_tensor_dict['pay_QOE_continue']
        train_batch_feature_tensor_pay_CHONGHE_continue = train_batch_feature_tensor_dict['pay_CHONGHE_continue']
        train_batch_feature_tensor_pay_FUFEI_continue = train_batch_feature_tensor_dict['pay_FUFEI_continue']
        train_batch_feature_tensor_target_QOE_discrete = train_batch_feature_tensor_dict['target_QOE_discrete']
        train_batch_feature_tensor_target_CHONGHE_discrete = train_batch_feature_tensor_dict['target_CHONGHE_discrete']
        train_batch_feature_tensor_target_FUFEI_discrete = train_batch_feature_tensor_dict['target_FUFEI_discrete']
        train_batch_feature_tensor_target_QOE_continue = train_batch_feature_tensor_dict['target_QOE_continue']
        train_batch_feature_tensor_target_CHONGHE_continue = train_batch_feature_tensor_dict['target_CHONGHE_continue']
        train_batch_feature_tensor_target_FUFEI_continue = train_batch_feature_tensor_dict['target_FUFEI_continue']
        train_batch_feature_tensor_pay_QOE_discrete_mask = train_batch_feature_tensor_history_mask_dict[
            'pay_QOE_discrete']
        train_batch_feature_tensor_pay_CHONGHE_discrete_mask = train_batch_feature_tensor_history_mask_dict[
            'pay_CHONGHE_discrete']
        train_batch_feature_tensor_pay_FUFEI_discrete_mask = train_batch_feature_tensor_history_mask_dict[
            'pay_FUFEI_discrete']
        train_batch_feature_tensor_pay_QOE_continue_mask = train_batch_feature_tensor_history_mask_dict[
            'pay_QOE_continue']
        train_batch_feature_tensor_pay_CHONGHE_continue_mask = train_batch_feature_tensor_history_mask_dict[
            'pay_CHONGHE_continue']
        train_batch_feature_tensor_pay_FUFEI_continue_mask = train_batch_feature_tensor_history_mask_dict[
            'pay_FUFEI_continue']

        val_batch_feature_tensor_pay_QOE_discrete = val_batch_feature_tensor_dict['pay_QOE_discrete']
        val_batch_feature_tensor_pay_CHONGHE_discrete = val_batch_feature_tensor_dict['pay_CHONGHE_discrete']
        val_batch_feature_tensor_pay_FUFEI_discrete = val_batch_feature_tensor_dict['pay_FUFEI_discrete']
        val_batch_feature_tensor_pay_QOE_continue = val_batch_feature_tensor_dict['pay_QOE_continue']
        val_batch_feature_tensor_pay_CHONGHE_continue = val_batch_feature_tensor_dict['pay_CHONGHE_continue']
        val_batch_feature_tensor_pay_FUFEI_continue = val_batch_feature_tensor_dict['pay_FUFEI_continue']
        val_batch_feature_tensor_target_QOE_discrete = val_batch_feature_tensor_dict['target_QOE_discrete']
        val_batch_feature_tensor_target_CHONGHE_discrete = val_batch_feature_tensor_dict['target_CHONGHE_discrete']
        val_batch_feature_tensor_target_FUFEI_discrete = val_batch_feature_tensor_dict['target_FUFEI_discrete']
        val_batch_feature_tensor_target_QOE_continue = val_batch_feature_tensor_dict['target_QOE_continue']
        val_batch_feature_tensor_target_CHONGHE_continue = val_batch_feature_tensor_dict['target_CHONGHE_continue']
        val_batch_feature_tensor_target_FUFEI_continue = val_batch_feature_tensor_dict['target_FUFEI_continue']
        val_batch_feature_tensor_pay_QOE_discrete_mask = val_batch_feature_tensor_history_mask_dict['pay_QOE_discrete']
        val_batch_feature_tensor_pay_CHONGHE_discrete_mask = val_batch_feature_tensor_history_mask_dict[
            'pay_CHONGHE_discrete']
        val_batch_feature_tensor_pay_FUFEI_discrete_mask = val_batch_feature_tensor_history_mask_dict[
            'pay_FUFEI_discrete']
        val_batch_feature_tensor_pay_QOE_continue_mask = val_batch_feature_tensor_history_mask_dict['pay_QOE_continue']
        val_batch_feature_tensor_pay_CHONGHE_continue_mask = val_batch_feature_tensor_history_mask_dict[
            'pay_CHONGHE_continue']
        val_batch_feature_tensor_pay_FUFEI_continue_mask = val_batch_feature_tensor_history_mask_dict[
            'pay_FUFEI_continue']

        test_batch_feature_tensor_pay_QOE_discrete = test_batch_feature_tensor_dict['pay_QOE_discrete']
        test_batch_feature_tensor_pay_CHONGHE_discrete = test_batch_feature_tensor_dict['pay_CHONGHE_discrete']
        test_batch_feature_tensor_pay_FUFEI_discrete = test_batch_feature_tensor_dict['pay_FUFEI_discrete']
        test_batch_feature_tensor_pay_QOE_continue = test_batch_feature_tensor_dict['pay_QOE_continue']
        test_batch_feature_tensor_pay_CHONGHE_continue = test_batch_feature_tensor_dict['pay_CHONGHE_continue']
        test_batch_feature_tensor_pay_FUFEI_continue = test_batch_feature_tensor_dict['pay_FUFEI_continue']
        test_batch_feature_tensor_target_QOE_discrete = test_batch_feature_tensor_dict['target_QOE_discrete']
        test_batch_feature_tensor_target_CHONGHE_discrete = test_batch_feature_tensor_dict['target_CHONGHE_discrete']
        test_batch_feature_tensor_target_FUFEI_discrete = test_batch_feature_tensor_dict['target_FUFEI_discrete']
        test_batch_feature_tensor_target_QOE_continue = test_batch_feature_tensor_dict['target_QOE_continue']
        test_batch_feature_tensor_target_CHONGHE_continue = test_batch_feature_tensor_dict['target_CHONGHE_continue']
        test_batch_feature_tensor_target_FUFEI_continue = test_batch_feature_tensor_dict['target_FUFEI_continue']
        test_batch_feature_tensor_pay_QOE_discrete_mask = test_batch_feature_tensor_history_mask_dict[
            'pay_QOE_discrete']
        test_batch_feature_tensor_pay_CHONGHE_discrete_mask = test_batch_feature_tensor_history_mask_dict[
            'pay_CHONGHE_discrete']
        test_batch_feature_tensor_pay_FUFEI_discrete_mask = test_batch_feature_tensor_history_mask_dict[
            'pay_FUFEI_discrete']
        test_batch_feature_tensor_pay_QOE_continue_mask = test_batch_feature_tensor_history_mask_dict[
            'pay_QOE_continue']
        test_batch_feature_tensor_pay_CHONGHE_continue_mask = test_batch_feature_tensor_history_mask_dict[
            'pay_CHONGHE_continue']
        test_batch_feature_tensor_pay_FUFEI_continue_mask = test_batch_feature_tensor_history_mask_dict[
            'pay_FUFEI_continue']

        # 训练集
        train_dataset = TensorDataset(
            train_user_id_list_tensor,
            train_batch_feature_tensor_pay_QOE_discrete,
            train_batch_feature_tensor_pay_CHONGHE_discrete,
            train_batch_feature_tensor_pay_FUFEI_discrete,
            train_batch_feature_tensor_pay_QOE_continue,
            train_batch_feature_tensor_pay_CHONGHE_continue,
            train_batch_feature_tensor_pay_FUFEI_continue,
            train_batch_feature_tensor_target_QOE_discrete,
            train_batch_feature_tensor_target_CHONGHE_discrete,
            train_batch_feature_tensor_target_FUFEI_discrete,
            train_batch_feature_tensor_target_QOE_continue,
            train_batch_feature_tensor_target_CHONGHE_continue,
            train_batch_feature_tensor_target_FUFEI_continue,
            train_batch_feature_tensor_pay_QOE_discrete_mask,
            train_batch_feature_tensor_pay_CHONGHE_discrete_mask,
            train_batch_feature_tensor_pay_FUFEI_discrete_mask,
            train_batch_feature_tensor_pay_QOE_continue_mask,
            train_batch_feature_tensor_pay_CHONGHE_continue_mask,
            train_batch_feature_tensor_pay_FUFEI_continue_mask,
            train_label_tensor)

        val_dataset = TensorDataset(
            val_user_id_list_tensor,
            val_batch_feature_tensor_pay_QOE_discrete,
            val_batch_feature_tensor_pay_CHONGHE_discrete,
            val_batch_feature_tensor_pay_FUFEI_discrete,
            val_batch_feature_tensor_pay_QOE_continue,
            val_batch_feature_tensor_pay_CHONGHE_continue,
            val_batch_feature_tensor_pay_FUFEI_continue,
            val_batch_feature_tensor_target_QOE_discrete,
            val_batch_feature_tensor_target_CHONGHE_discrete,
            val_batch_feature_tensor_target_FUFEI_discrete,
            val_batch_feature_tensor_target_QOE_continue,
            val_batch_feature_tensor_target_CHONGHE_continue,
            val_batch_feature_tensor_target_FUFEI_continue,
            val_batch_feature_tensor_pay_QOE_discrete_mask,
            val_batch_feature_tensor_pay_CHONGHE_discrete_mask,
            val_batch_feature_tensor_pay_FUFEI_discrete_mask,
            val_batch_feature_tensor_pay_QOE_continue_mask,
            val_batch_feature_tensor_pay_CHONGHE_continue_mask,
            val_batch_feature_tensor_pay_FUFEI_continue_mask,
            val_label_tensor)

        # # 训练集
        # train_dataset = TensorDataset(*train_batch_feature_tensor, *train_batch_feature_tensor_history_mask, train_label_tensor)
        # val_dataset = TensorDataset(*val_batch_feature_tensor, *val_batch_feature_tensor_history_mask, val_label_tensor)

        # 创建数据加载器
        train_loader = DataLoader(train_dataset, batch_size=config.batch_size, shuffle=False, drop_last=True)  # 记得改回随机
        val_loader = DataLoader(val_dataset, batch_size=config.batch_size, shuffle=False, drop_last=True)

        # 确保您的计算机上有CUDA支持的GPU
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        # 创建大模型的实例
        model = MatchingModel(feature_category_num_dict, feature_column_dict, config.continue_embedding_dim,
                              config.discrete_embedding_dim, config.num_heads, config.feature_dim,
                              config.max_history_len)
        print('模型搭建完成')
        model.to(device)
        # 进一步处理 列表转移到GPU
        for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_QOE_discrete_embeddings)):
            model.user_history_pay_embedding_layer.user_pay_history_QOE_discrete_embeddings[i] = \
                model.user_history_pay_embedding_layer.user_pay_history_QOE_discrete_embeddings[i].to(device)
        for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_discrete_embeddings)):
            model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_discrete_embeddings[i] = \
                model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_discrete_embeddings[i].to(device)
        for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_FUFEI_discrete_embeddings)):
            model.user_history_pay_embedding_layer.user_pay_history_FUFEI_discrete_embeddings[i] = \
                model.user_history_pay_embedding_layer.user_pay_history_FUFEI_discrete_embeddings[i].to(device)
        for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_QOE_continue_embedding)):
            model.user_history_pay_embedding_layer.user_pay_history_QOE_continue_embedding[i] = \
                model.user_history_pay_embedding_layer.user_pay_history_QOE_continue_embedding[i].to(device)
        for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_continue_embedding)):
            model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_continue_embedding[i] = \
                model.user_history_pay_embedding_layer.user_pay_history_CHONGHE_continue_embedding[i].to(device)
        for i in range(len(model.user_history_pay_embedding_layer.user_pay_history_FUFEI_continue_embedding)):
            model.user_history_pay_embedding_layer.user_pay_history_FUFEI_continue_embedding[i] = \
                model.user_history_pay_embedding_layer.user_pay_history_FUFEI_continue_embedding[i].to(device)

        for i in range(len(model.target_embedding_layer.target_QOE_discrete_embeddings)):
            model.target_embedding_layer.target_QOE_discrete_embeddings[i] = \
                model.target_embedding_layer.target_QOE_discrete_embeddings[i].to(device)
        for i in range(len(model.target_embedding_layer.target_CHONGHE_discrete_embeddings)):
            model.target_embedding_layer.target_CHONGHE_discrete_embeddings[i] = \
                model.target_embedding_layer.target_CHONGHE_discrete_embeddings[i].to(device)
        for i in range(len(model.target_embedding_layer.target_FUFEI_discrete_embeddings)):
            model.target_embedding_layer.target_FUFEI_discrete_embeddings[i] = \
                model.target_embedding_layer.target_FUFEI_discrete_embeddings[i].to(device)
        for i in range(len(model.target_embedding_layer.target_QOE_continue_embedding)):
            model.target_embedding_layer.target_QOE_continue_embedding[i] = \
                model.target_embedding_layer.target_QOE_continue_embedding[i].to(device)
        for i in range(len(model.target_embedding_layer.target_CHONGHE_continue_embedding)):
            model.target_embedding_layer.target_CHONGHE_continue_embedding[i] = \
                model.target_embedding_layer.target_CHONGHE_continue_embedding[i].to(device)
        for i in range(len(model.target_embedding_layer.target_FUFEI_continue_embedding)):
            model.target_embedding_layer.target_FUFEI_continue_embedding[i] = \
                model.target_embedding_layer.target_FUFEI_continue_embedding[i].to(device)
        print('模型转移到GPU完成')
        lossfunction = nn.BCELoss()
        #     optimizer = optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), lr=lr)
        optimizer = optim.SGD(filter(lambda p: p.requires_grad, model.parameters()), lr=config.lr, momentum=0.9)

        # 训练
        model_training(model, train_loader, val_loader, lossfunction, optimizer, 10, device)
        print('模型训练完成')
        print('||--------训练结束时间：', datetime.datetime.now(), '-------------')
        # 测试
        test_dataset = TensorDataset(
            test_user_id_list_tensor, test_batch_feature_tensor_pay_QOE_discrete,
            test_batch_feature_tensor_pay_CHONGHE_discrete,
            test_batch_feature_tensor_pay_FUFEI_discrete,
            test_batch_feature_tensor_pay_QOE_continue,
            test_batch_feature_tensor_pay_CHONGHE_continue,
            test_batch_feature_tensor_pay_FUFEI_continue,
            test_batch_feature_tensor_target_QOE_discrete,
            test_batch_feature_tensor_target_CHONGHE_discrete,
            test_batch_feature_tensor_target_FUFEI_discrete,
            test_batch_feature_tensor_target_QOE_continue,
            test_batch_feature_tensor_target_CHONGHE_continue,
            test_batch_feature_tensor_target_FUFEI_continue,
            test_batch_feature_tensor_pay_QOE_discrete_mask,
            test_batch_feature_tensor_pay_CHONGHE_discrete_mask,
            test_batch_feature_tensor_pay_FUFEI_discrete_mask,
            test_batch_feature_tensor_pay_QOE_continue_mask,
            test_batch_feature_tensor_pay_CHONGHE_continue_mask,
            test_batch_feature_tensor_pay_FUFEI_continue_mask,
            test_label_tensor)
        test_loader = DataLoader(test_dataset, batch_size=config.batch_size, shuffle=False, drop_last=True)
        average_loss_test, average_auc_test, average_acc_test, average_f1_test, average_precision_test, average_recall_test, weight_result_dict = test_model(
            model, test_loader, lossfunction)
        # 测试的每个样本结果保存到csv
        # 将本次训练的结果添加到DataFrame中
        test_auc_df = test_auc_df.append(
            {'时间': datetime.datetime.now(), 'model': 'model3.1', '运行位置': 'GPU', 'Type': 'Origin',
             'dataset': data_time_windows, 'feature_embedding': config.feature_dim, 'batchSize': config.batch_size,
             'lr': config.lr,
             'max_history_len': config.max_history_len, '实验数': i + 1, '测试集总损失': average_loss_test,
             'AUC': average_auc_test, 'ACC': average_acc_test, 'F1': average_f1_test,
             'Precision': average_precision_test, 'Recall': average_recall_test}, ignore_index=True)
        weight_result = {'时间': datetime.datetime.now(), 'model': 'model3.1', '运行位置': 'GPU', 'Type': 'Origin',
                         'dataset': data_time_windows, 'feature_embedding': config.feature_dim,
                         'batchSize': config.batch_size,
                         'lr': config.lr, 'max_history_len': config.max_history_len, '实验数': i + 1, \
                         'se_user_pay_QOE_weight': weight_result_dict['se_user_pay_QOE_weight'],
                         'se_user_pay_CHONGHE_weight': weight_result_dict['se_user_pay_CHONGHE_weight'], \
                         'se_user_pay_FUFEI_weight': weight_result_dict['se_user_pay_FUFEI_weight'],
                         'se_target_QOE_weight': weight_result_dict['se_target_QOE_weight'], \
                         'se_target_CHONGHE_weight': weight_result_dict['se_target_CHONGHE_weight'],
                         'se_target_FUFEI_weight': weight_result_dict['se_target_FUFEI_weight'], \
                         'target_history_pay_attention_QOE_weight': weight_result_dict[
                             'target_history_pay_attention_QOE_weight'], \
                         'target_history_pay_attention_CHONGHE_weight': weight_result_dict[
                             'target_history_pay_attention_CHONGHE_weight'], \
                         'target_history_pay_attention_FUFEI_weight': weight_result_dict[
                             'target_history_pay_attention_FUFEI_weight']}
        test_weight_df = test_weight_df.append(weight_result, ignore_index=True)
    # 将结果保存到CSV文件中
    with open(data_path + 'maoerDL_result_maoer_pay_pred_model3_1.csv', 'a') as f:
        test_auc_df.to_csv(f, index=False)
    with open(data_path + 'maoerDL_result_maoer_pay_pred_weight_model3_1.csv', 'a') as f:
        test_weight_df.to_csv(f, index=False)
    #     test_auc_df.to_csv('./Dataset/maoerDL_result_maoer_pay_pred_model3_1.csv', index=False)
    #     test_weight_df.to_csv('./Dataset/maoerDL_result_maoer_pay_pred_weight_model3_1.csv', index=False)
    print('结果已输出')
    print('||--------当前时间窗', data_time_windows, '结束时间：', datetime.datetime.now(), '-------------')

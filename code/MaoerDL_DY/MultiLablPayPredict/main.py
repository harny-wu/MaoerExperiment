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

# data input
data_time_windows_list = ['0101_0131']  # '0115_0215',

# 2. 形成张量矩阵 目标特征为：（batch,1,feature_num; 用户历史行为特征为（batch,max_history_len(固定长度的历史记录数),feature_num）

# mask 对用户历史行为长度的固定
# 转换 history 列为长度为max_history_len的数组
def process_history(history, max_history_len):
    if len(history) >= max_history_len:
        processed_history = history[-max_history_len:]
    else:
        processed_history = [-1] * (max_history_len - len(history)) + history
    return processed_history


# 将填充-1的位置标记为True
def create_mask(history):
    mask = [True if item == -1 else False for item in history]
    return mask


# 将历史行为记录处理为固定长度并进行mask
def history_feature_mask(user_history_feature_index, data_matrix_user_history, max_history_len):
    # user_history_feature_index: 用户历史特征的索引列表
    mask_history_feature_matrix = []
    origin_history_feature_matrix = []
    for feature_index in range(len(user_history_feature_index)):
        feature_data = [data_row[feature_index] for data_row in data_matrix_user_history]  # 获取一列特征值
        processed_feature_data = process_history(feature_data,
                                                 max_history_len)  # 处理为固定长度 max_history_len 假如max_history_len=15,原长度为5，那么处理后为[-1,-1, ..., -1, x1,x2,x3,x4,x5]
        origin_history_feature_matrix.append(processed_feature_data)
        mask_feature_data = create_mask(processed_feature_data)  # 将空的mask,填充-1的位置标记为True,其他为False
        mask_history_feature_matrix.append(mask_feature_data)

    # print('mask',len(origin_history_feature_matrix),len(origin_history_feature_matrix[0]))
    return origin_history_feature_matrix, mask_history_feature_matrix


# 将输入形成的data_hash和连续、离散特征列名,按照划分的训练或测试的user_id的列表，提取用户特征形成张量矩阵存储到data_tensor_hash中，以user_id为key，多个张量矩阵为value
def get_feature_to_matrix(train_or_val_or_test_list, data_hash, feature_column_dict):
    # 存储新的张量hash
    data_tensor_hash = {}
    # 存储历史记录的掩码矩阵
    data_tensor_history_mask_hash = {}
    target_label = []  # 预测目标值的标签

    for user_id in train_or_val_or_test_list:
        user_data = data_hash[user_id]
        # 创建空的二维矩阵
        # data_matrix_user_info_continue = []
        # data_matrix_user_info_discrete = []
        data_matrix_pay_QOE_continue = []
        data_matrix_pay_QOE_discrete = []
        data_matrix_pay_CHONGHE_continue = []
        data_matrix_pay_CHONGHE_discrete = []
        data_matrix_pay_FUFEI_continue = []
        data_matrix_pay_FUFEI_discrete = []
        data_matrix_target_QOE_continue = []
        data_matrix_target_CHONGHE_continue = []
        data_matrix_target_FUFEI_continue = []
        data_matrix_target_QOE_discrete = []
        data_matrix_target_CHONGHE_discrete = []
        data_matrix_target_FUFEI_discrete = []
        # 提取特征列对应的索引
        # user_feature_continue_index = [user_data.columns.get_loc(col) for col in feature_column_dict['user_info_continue'] if col in user_data.columns]
        # user_feature_discrete_index = [user_data.columns.get_loc(col) for col in feature_column_dict['user_info_discrete'] if
        #                                col in user_data.columns]
        user_history_QOE_continue_index = [user_data.columns.get_loc(col) for col in
                                           feature_column_dict['history_QOE_continue'] if
                                           col in user_data.columns]
        user_history_QOE_discrete_index = [user_data.columns.get_loc(col) for col in
                                           feature_column_dict['history_QOE_discrete'] if
                                           col in user_data.columns]
        user_history_CHONGHE_continue_index = [user_data.columns.get_loc(col) for col in
                                               feature_column_dict['history_CHONGHE_continue'] if
                                               col in user_data.columns]
        user_history_CHONGHE_discrete_index = [user_data.columns.get_loc(col) for col in
                                               feature_column_dict['history_CHONGHE_discrete'] if
                                               col in user_data.columns]
        user_history_FUFEI_continue_index = [user_data.columns.get_loc(col) for col in
                                             feature_column_dict['history_FUFEI_continue'] if
                                             col in user_data.columns]
        user_history_FUFEI_discrete_index = [user_data.columns.get_loc(col) for col in
                                             feature_column_dict['history_FUFEI_discrete'] if
                                             col in user_data.columns]
        user_history_CHONGHE_discrete_add_D_index = [user_data.columns.get_loc(col) for col in
                                                     feature_column_dict['history_CHONGHE_discrete_add_D'] if
                                                     col in user_data.columns]

        # 填充数据矩阵
        for i in range(len(user_data)):
            if i != (len(user_data) - 1):  # 除最后一行即所有历史记录，不包括目标记录
                # [[x11, x12, x13, ..., x1n],
                #  [x21, x22, x23, ..., x2n],
                #    .    .    .    .    .
                #    .    .    .    .    .
                #    .    .    .    .    .
                #  [xm1, xm2, xm3, ..., xmn]]
                # m x n: m代表该user_id对应的数据的行数-1，n代表qoe/fufei/chonghe的特征数
                data_matrix_pay_QOE_continue.append(
                    [user_data.iloc[i, col] for col in user_history_QOE_continue_index])  # 用户历史QOE连续特征
                data_matrix_pay_QOE_discrete.append(
                    [user_data.iloc[i, col] for col in user_history_QOE_discrete_index])  # 用户历史QOE离散特征
                data_matrix_pay_CHONGHE_continue.append(
                    [user_data.iloc[i, col] for col in user_history_CHONGHE_continue_index])  # 用户历史CHONGHE连续特征
                data_matrix_pay_CHONGHE_discrete.append(
                    [user_data.iloc[i, col] for col in user_history_CHONGHE_discrete_add_D_index])  # 用户历史CHONGHE离散特征
                data_matrix_pay_FUFEI_continue.append(
                    [user_data.iloc[i, col] for col in user_history_FUFEI_continue_index])  # 用户历史FUFEI连续特征
                data_matrix_pay_FUFEI_discrete.append(
                    [user_data.iloc[i, col] for col in user_history_FUFEI_discrete_index])  # 用户历史FUFEI离散特征
            else:  # 目标记录
                # data_matrix_user_info_continue.append([user_data.iloc[i, col] for col in user_feature_continue_index])  # 用户连续特征
                # data_matrix_user_info_discrete.append([user_data.iloc[i, col] for col in user_feature_discrete_index])  # 用户离散特征
                # 维度：1xn, 其中n代表特征数
                target_label.append(user_data.iloc[i, -1])  # 预测目标的y值：1x1
                data_matrix_target_QOE_continue.append(
                    [user_data.iloc[i, col] for col in user_history_QOE_continue_index])  # 目标QOE连续特征
                data_matrix_target_QOE_discrete.append(
                    [user_data.iloc[i, col] for col in user_history_QOE_discrete_index])  # 目标QOE离散特征
                data_matrix_target_CHONGHE_continue.append(
                    [user_data.iloc[i, col] for col in user_history_CHONGHE_continue_index])  # 目标CHONGHE连续特征
                data_matrix_target_CHONGHE_discrete.append(
                    [user_data.iloc[i, col] for col in user_history_CHONGHE_discrete_index])  # 目标CHONGHE离散特征
                data_matrix_target_FUFEI_continue.append(
                    [user_data.iloc[i, col] for col in user_history_FUFEI_continue_index])  # 目标FUFEI连续特征
                data_matrix_target_FUFEI_discrete.append(
                    [user_data.iloc[i, col] for col in user_history_FUFEI_discrete_index])  # 目标FUFEI离散特征
        # print('data_matrix_pay_QOE_continue:', len(data_matrix_pay_QOE_continue),len(data_matrix_pay_QOE_continue[0]))
        # print(len(data_matrix_target_QOE_continue),len(data_matrix_target_QOE_continue[0]))
        # 将历史行为记录处理为固定长度并进行mask
        data_matrix_pay_QOE_continue, data_matrix_pay_QOE_continue_mask = history_feature_mask(
            user_history_QOE_continue_index, data_matrix_pay_QOE_continue, config.max_history_len)
        data_matrix_pay_QOE_discrete, data_matrix_pay_QOE_discrete_mask = history_feature_mask(
            user_history_QOE_discrete_index, data_matrix_pay_QOE_discrete, config.max_history_len)
        data_matrix_pay_CHONGHE_continue, data_matrix_pay_CHONGHE_continue_mask = history_feature_mask(
            user_history_CHONGHE_continue_index, data_matrix_pay_CHONGHE_continue, config.max_history_len)
        data_matrix_pay_CHONGHE_discrete, data_matrix_pay_CHONGHE_discrete_mask = history_feature_mask(
            user_history_CHONGHE_discrete_add_D_index, data_matrix_pay_CHONGHE_discrete, config.max_history_len)
        data_matrix_pay_FUFEI_continue, data_matrix_pay_FUFEI_continue_mask = history_feature_mask(
            user_history_FUFEI_continue_index, data_matrix_pay_FUFEI_continue, config.max_history_len)
        data_matrix_pay_FUFEI_discrete, data_matrix_pay_FUFEI_discrete_mask = history_feature_mask(
            user_history_FUFEI_discrete_index, data_matrix_pay_FUFEI_discrete, config.max_history_len)
        # print('data_matrix_pay_QOE_discrete',len(data_matrix_pay_QOE_discrete),len(data_matrix_pay_QOE_discrete[0]))
        # print('(ata_matrix_pay_QOE_discrete',data_matrix_pay_QOE_discrete[0])

        # 将numpy数组转换为PyTorch张量       # history   得到的data_matrix_user_history及data_tensor_pay_QOE_continue维度是(feature_num,history_len)需要转成tensor后转置
        data_tensor_pay_QOE_continue = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_QOE_continue), dtype=torch.float32), -2, -1)
        # data_tensor_pay_QOE_discrete = torch.tensor(np.array(data_matrix_pay_QOE_discrete), dtype=torch.float32)
        # print('data_tensor_pay_QOE_discrete1',data_tensor_pay_QOE_discrete[0,:])
        data_tensor_pay_QOE_discrete = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_QOE_discrete), dtype=torch.float32), -2, -1)
        # print('data_tensor_pay_QOE_discrete2',data_tensor_pay_QOE_discrete[0,:])
        # print('data_tensor_pay_QOE_discrete3',data_tensor_pay_QOE_discrete[:,0])
        data_tensor_pay_CHONGHE_continue = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_CHONGHE_continue), dtype=torch.float32), -2, -1)
        data_tensor_pay_CHONGHE_discrete = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_CHONGHE_discrete), dtype=torch.float32), -2, -1)
        data_tensor_pay_FUFEI_continue = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_FUFEI_continue), dtype=torch.float32), -2, -1)
        data_tensor_pay_FUFEI_discrete = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_FUFEI_discrete), dtype=torch.float32), -2, -1)
        #  mask矩阵   得到的data_matrix_user_history及data_tensor_pay_QOE_continue维度是(feature_num,history_len)需要转成tensor后转置
        data_tensor_pay_QOE_continue_mask = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_QOE_continue_mask), dtype=torch.float32), -2, -1)
        data_tensor_pay_QOE_discrete_mask = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_QOE_discrete_mask), dtype=torch.float32), -2, -1)
        data_tensor_pay_CHONGHE_continue_mask = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_CHONGHE_continue_mask), dtype=torch.float32), -2, -1)
        data_tensor_pay_CHONGHE_discrete_mask = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_CHONGHE_discrete_mask), dtype=torch.float32), -2, -1)
        data_tensor_pay_FUFEI_continue_mask = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_FUFEI_continue_mask), dtype=torch.float32), -2, -1)
        data_tensor_pay_FUFEI_discrete_mask = torch.transpose(
            torch.tensor(np.array(data_matrix_pay_FUFEI_discrete_mask), dtype=torch.float32), -2, -1)
        # user + target   输出维度为（1，feature_num）,一处第一个为1的维度变为（feature_num）
        # data_tensor_user_info_continue = torch.tensor(np.array(data_matrix_user_info_continue), dtype=torch.float32)
        # data_tensor_user_info_discrete = torch.tensor(np.array(data_matrix_user_info_discrete), dtype=torch.float32)
        data_tensor_target_QOE_continue = torch.squeeze(
            torch.tensor(np.array(data_matrix_target_QOE_continue), dtype=torch.float32), dim=0)
        data_tensor_target_QOE_discrete = torch.squeeze(
            torch.tensor(np.array(data_matrix_target_QOE_discrete), dtype=torch.float32), dim=0)
        data_tensor_target_CHONGHE_continue = torch.squeeze(
            torch.tensor(np.array(data_matrix_target_CHONGHE_continue), dtype=torch.float32), dim=0)
        data_tensor_target_CHONGHE_discrete = torch.squeeze(
            torch.tensor(np.array(data_matrix_target_CHONGHE_discrete), dtype=torch.float32), dim=0)
        data_tensor_target_FUFEI_continue = torch.squeeze(
            torch.tensor(np.array(data_matrix_target_FUFEI_continue), dtype=torch.float32), dim=0)
        data_tensor_target_FUFEI_discrete = torch.squeeze(
            torch.tensor(np.array(data_matrix_target_FUFEI_discrete), dtype=torch.float32), dim=0)

        # 生成hash值，按user_id为key存储成hash
        tensor_hash_value = {
            'pay_QOE_continue': data_tensor_pay_QOE_continue,
            'pay_QOE_discrete': data_tensor_pay_QOE_discrete,
            'pay_CHONGHE_continue': data_tensor_pay_CHONGHE_continue,
            'pay_CHONGHE_discrete': data_tensor_pay_CHONGHE_discrete,
            'pay_FUFEI_continue': data_tensor_pay_FUFEI_continue,
            'pay_FUFEI_discrete': data_tensor_pay_FUFEI_discrete,
            'target_QOE_continue': data_tensor_target_QOE_continue,
            'target_QOE_discrete': data_tensor_target_QOE_discrete,
            'target_CHONGHE_continue': data_tensor_target_CHONGHE_continue,
            'target_CHONGHE_discrete': data_tensor_target_CHONGHE_discrete,
            'target_FUFEI_continue': data_tensor_target_FUFEI_continue,
            'target_FUFEI_discrete': data_tensor_target_FUFEI_discrete
        }
        tensor_hash_value_history_mask = {
            'pay_QOE_continue': data_tensor_pay_QOE_continue_mask,
            'pay_QOE_discrete': data_tensor_pay_QOE_discrete_mask,
            'pay_CHONGHE_continue': data_tensor_pay_CHONGHE_continue_mask,
            'pay_CHONGHE_discrete': data_tensor_pay_CHONGHE_discrete_mask,
            'pay_FUFEI_continue': data_tensor_pay_FUFEI_continue_mask,
            'pay_FUFEI_discrete': data_tensor_pay_FUFEI_discrete_mask,
        }
        if user_id in data_tensor_hash:
            data_tensor_hash[user_id].update(tensor_hash_value)
            data_tensor_history_mask_hash[user_id].update(tensor_hash_value_history_mask)
        else:
            data_tensor_hash[user_id] = tensor_hash_value
            data_tensor_history_mask_hash[user_id] = tensor_hash_value_history_mask

    # 如果需要合并成一个张量，可以使用torch.cat方法
    # combined_tensor = torch.cat((data_matrix_1_tensor, data_matrix_2_tensor), dim=1)
    # data_tensor_hash中用户历史的输出维度(max_history_len,feature_num)，目标的输出维度是（feature_num）
    return data_tensor_hash, target_label, data_tensor_history_mask_hash


# 张量矩阵添加一个batch维度，并在用户特征与目标特征的张量中再添加一维使其与用户历史行为张量对齐， 形成两种：
# 原数据为：1.用户特征与目标特征都为：（1,feature_num）; 2.用户历史行为特征为（max_history_len(固定长度的历史记录数),feature_num）
# 新数据为：1.用户特征与目标特征都为：（batch,1,1,feature_num); 2.用户历史行为特征为（batch,max_history_len(固定长度的历史记录数),feature_num）
# 形成batch维度的特征
def generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                           feature_category):  # 例:feature_category = 'user_info_continue' 就是上面生成的tensor_hash_value字典的键
    tensor_list = []
    for user_id in train_or_val_or_test_list:  # 遍历data_tensor_hash的所有key (user_id)
        if feature_category in data_tensor_hash[user_id]:
            tensor = data_tensor_hash[user_id][feature_category]  # 获取feature_category对应的张量
            tensor_list.append(tensor)  # 添加到tensor_list中
    #  print(tensor_list)
    batch_feature_tensor = torch.stack(tensor_list, dim=0)  # 在第一个维度上合并所有张量(其实相当于生成一个新维度)
    return batch_feature_tensor


# 生成batch再添加维度对齐张量（三个维度）
def generate_user_feature_alignment_tensor(train_or_val_or_test_list, data_tensor_hash, is_mask=False):
    # 用户历史行为矩阵（max_history_len(固定长度的历史记录数),feature_num）->（batch,max_history_len(固定长度的历史记录数),feature_num）
    pay_QOE_continue_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                   'pay_QOE_continue')
    pay_QOE_discrete_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                   'pay_QOE_discrete')
    pay_CHONGHE_continue_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                       'pay_CHONGHE_continue')
    pay_CHONGHE_discrete_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                       'pay_CHONGHE_discrete')
    pay_FUFEI_continue_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                     'pay_FUFEI_continue')
    pay_FUFEI_discrete_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                     'pay_FUFEI_discrete')
    # print('pay_QOE_discrete_batch_feature_tensor1',pay_QOE_discrete_batch_feature_tensor[0,:,0])
    # 看是否是掩码矩阵，不是则xxx，是则没有user+target
    if is_mask == False:
        # 用户矩阵 (feature_num) ->(batch,feature_num)
        # user_info_continue_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'user_info_continue')
        # user_info_discrete_batch_feature_tensor = generate_batch_feature(data_tensor_hash, 'user_info_discrete')
        # 目标矩阵 (feature_num) ->(batch,feature_num)
        target_QOE_continue_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                          'target_QOE_continue')
        target_QOE_discrete_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                          'target_QOE_discrete')
        target_CHONGHE_continue_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list,
                                                                              data_tensor_hash,
                                                                              'target_CHONGHE_continue')
        target_CHONGHE_discrete_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list,
                                                                              data_tensor_hash,
                                                                              'target_CHONGHE_discrete')
        target_FUFEI_continue_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                            'target_FUFEI_continue')
        target_FUFEI_discrete_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
                                                                            'target_FUFEI_discrete')

        # 假设原始张量矩阵为 tensor，形状为 (batch_size, feature_num)将其加一个维度变为 (batch_size, 1, feature_num)
        # user_info_continue_batch_feature_tensor = torch.unsqueeze(user_info_continue_batch_feature_tensor, dim=1)
        # user_info_discrete_batch_feature_tensor = torch.unsqueeze(user_info_discrete_batch_feature_tensor, dim=1)
        target_QOE_continue_batch_feature_tensor = torch.unsqueeze(target_QOE_continue_batch_feature_tensor, dim=1)
        target_QOE_discrete_batch_feature_tensor = torch.unsqueeze(target_QOE_discrete_batch_feature_tensor, dim=1)
        target_CHONGHE_continue_batch_feature_tensor = torch.unsqueeze(target_CHONGHE_continue_batch_feature_tensor,
                                                                       dim=1)
        target_CHONGHE_discrete_batch_feature_tensor = torch.unsqueeze(target_CHONGHE_discrete_batch_feature_tensor,
                                                                       dim=1)
        target_FUFEI_continue_batch_feature_tensor = torch.unsqueeze(target_FUFEI_continue_batch_feature_tensor, dim=1)
        target_FUFEI_discrete_batch_feature_tensor = torch.unsqueeze(target_FUFEI_discrete_batch_feature_tensor, dim=1)

        batch_feature_tensor_dict = {
            'pay_QOE_discrete': pay_QOE_discrete_batch_feature_tensor,
            'pay_CHONGHE_discrete': pay_CHONGHE_discrete_batch_feature_tensor,
            'pay_FUFEI_discrete': pay_FUFEI_discrete_batch_feature_tensor,
            'pay_QOE_continue': pay_QOE_continue_batch_feature_tensor,
            'pay_CHONGHE_continue': pay_CHONGHE_continue_batch_feature_tensor,
            'pay_FUFEI_continue': pay_FUFEI_continue_batch_feature_tensor,
            'target_QOE_discrete': target_QOE_discrete_batch_feature_tensor,
            'target_CHONGHE_discrete': target_CHONGHE_discrete_batch_feature_tensor,
            'target_FUFEI_discrete': target_FUFEI_discrete_batch_feature_tensor,
            'target_QOE_continue': target_QOE_continue_batch_feature_tensor,
            'target_CHONGHE_continue': target_CHONGHE_continue_batch_feature_tensor,
            'target_FUFEI_continue': target_FUFEI_continue_batch_feature_tensor,

        }
    else:
        batch_feature_tensor_dict = {
            'pay_QOE_discrete': pay_QOE_discrete_batch_feature_tensor,
            'pay_CHONGHE_discrete': pay_CHONGHE_discrete_batch_feature_tensor,
            'pay_FUFEI_discrete': pay_FUFEI_discrete_batch_feature_tensor,
            'pay_QOE_continue': pay_QOE_continue_batch_feature_tensor,
            'pay_CHONGHE_continue': pay_CHONGHE_continue_batch_feature_tensor,
            'pay_FUFEI_continue': pay_FUFEI_continue_batch_feature_tensor,
        }
    return batch_feature_tensor_dict  # 这里张量输出的全是三维 (batch_size, 1 or max_history_len, feature_num)


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


# 3.基础模型 embedding、attention


# 4.Embedding层


# 5.Attention层


# 6.整合模型


# (batch,600)经过网络变成200 +(batch,featuer_user*200)经过网络变成200 -> (batch,200)
# (batch,200) ->MLP ->(batch，1) ->sigmoid -> (batch,1)


if __name__ == '__main__':
    data_time_windows = '0101_0131'
    data_path = "/Users/daidaiwu/学校/大论文/MaoerExperiment/code/MaoerDL_DY/maoer/DataSet/"
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
        'user_info_continue': user_feature_continue_column,  #[]
        'user_info_discrete': user_feature_discrete_column,  #[]
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
            data_time_windows, train_path, test_path, dataset_spilt_path, config.val_ratio, config.test_ratio, total_continue_feature,total_discrete_feature)

        # 获取训练、验证、测试集对应的数据形成的向量hash存储及label
        # 数据以key-value形式存储，key为user_id，value的维度为(max_history_len, feature_num), label的维度为(1, batch)
        train_data_tensor_hash, train_label, train_data_tensor_hash_history_mask = get_feature_to_matrix(train_list,
                                                                                                         train_data_hash,
                                                                                                         feature_column_dict)
        val_data_tensor_hash, val_label, val_data_tensor_hash_history_mask = get_feature_to_matrix(val_list, data_hash,
                                                                                                   feature_column_dict)
        test_data_tensor_hash, test_label, test_data_tensor_hash_history_mask = get_feature_to_matrix(test_list,
                                                                                                      data_hash,
                                                                                                      feature_column_dict)
        # 输出查看结果
        # for key1 in train_data_tensor_hash.keys():
        #     dimensions1 = train_data_tensor_hash[key1]['pay_QOE_continue'].size()
        #     dimensions2 = train_data_tensor_hash[key1]['pay_QOE_discrete'].size()
        #     dimensions3 = train_data_tensor_hash[key1]['pay_CHONGHE_continue'].size()
        #     dimensions4 = train_data_tensor_hash[key1]['target_QOE_continue'].size()
        #     dimensions5 = train_data_tensor_hash[key1]['target_QOE_discrete'].size()
        #     dimensions6 = train_data_tensor_hash[key1]['target_CHONGHE_continue'].size()
        #     print("val_data_tensor_hash size=", dimensions1,dimensions2,dimensions3,dimensions4,dimensions5,dimensions6)

        # 生成batch再添加维度对齐张量（三个维度）这里张量输出的全是三维 (batch_size, 1 or max_history_len, feature_num)
        train_batch_feature_tensor_dict = generate_user_feature_alignment_tensor(train_list, train_data_tensor_hash)
        val_batch_feature_tensor_dict = generate_user_feature_alignment_tensor(val_list, val_data_tensor_hash)
        test_batch_feature_tensor_dict = generate_user_feature_alignment_tensor(test_list, test_data_tensor_hash)

        train_label_tensor = torch.tensor(train_label)
        val_label_tensor = torch.tensor(val_label)
        test_label_tensor = torch.tensor(test_label)

        train_label_tensor = train_label_tensor.unsqueeze(-1)
        val_label_tensor = val_label_tensor.unsqueeze(-1)
        test_label_tensor = test_label_tensor.unsqueeze(-1)  # 在最后新增一个维度，因为TensorDataset要第一维大小相同 label变为(batch,1)
        # mask矩阵的字典
        train_batch_feature_tensor_history_mask_dict = generate_user_feature_alignment_tensor(train_list,
                                                                                              train_data_tensor_hash_history_mask,
                                                                                              is_mask=True)
        val_batch_feature_tensor_history_mask_dict = generate_user_feature_alignment_tensor(val_list,
                                                                                            val_data_tensor_hash_history_mask,
                                                                                            is_mask=True)
        test_batch_feature_tensor_history_mask_dict = generate_user_feature_alignment_tensor(test_list,
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
        train_dataset = TensorDataset(train_batch_feature_tensor_pay_QOE_discrete,
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
        val_dataset = TensorDataset(val_batch_feature_tensor_pay_QOE_discrete,
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
                              config.discrete_embedding_dim, config.num_heads, config.feature_dim, config.max_history_len)
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
        model_training(model, train_loader, val_loader, lossfunction, optimizer, 500, device)
        print('模型训练完成')
        print('||--------训练结束时间：', datetime.datetime.now(), '-------------')
        # 测试
        test_dataset = TensorDataset(test_batch_feature_tensor_pay_QOE_discrete,
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
            model, test_loader)
        # 测试的每个样本结果保存到csv
        # 将本次训练的结果添加到DataFrame中
        test_auc_df = test_auc_df.append(
            {'时间': datetime.datetime.now(), 'model': 'model3.1', '运行位置': 'GPU', 'Type': 'Origin',
             'dataset': data_time_windows, 'feature_embedding': config.feature_dim, 'batchSize': config.batch_size, 'lr': config.lr,
             'max_history_len': config.max_history_len, '实验数': i + 1, '测试集总损失': average_loss_test,
             'AUC': average_auc_test, 'ACC': average_acc_test, 'F1': average_f1_test,
             'Precision': average_precision_test, 'Recall': average_recall_test}, ignore_index=True)
        weight_result = {'时间': datetime.datetime.now(), 'model': 'model3.1', '运行位置': 'GPU', 'Type': 'Origin',
                         'dataset': data_time_windows, 'feature_embedding': config.feature_dim, 'batchSize': config.batch_size,
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

import numpy as np
import torch
import config


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
            "basic_info": [user_id],
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
    # basic_info_batch_feature_tensor = generate_batch_feature(train_or_val_or_test_list, data_tensor_hash,
    #                                                          "basic_info")
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
            # 'basic_info': basic_info_batch_feature_tensor,
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

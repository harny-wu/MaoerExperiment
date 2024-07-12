# 猫耳深度学习对比模型 -DNN

from collections import Counter
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader, TensorDataset
import pandas as pd
import numpy as np
import os
import csv
import datetime
from sklearn.metrics import roc_auc_score, f1_score, accuracy_score, recall_score, precision_score, roc_curve, confusion_matrix
from _collections import OrderedDict  # 导入 OrderedDict 来保持字典中键值对的顺序


# 自定义数据集类
class CustomDataset(Dataset):
    def __init__(self, data, labels):
        self.data = data
        self.labels = labels
        self.num_classes = len(set(labels))  # 计算标签的类型数

    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        sample = {
            'data': self.data[idx],
            'label': self.labels[idx],
            'num_classes': self.num_classes,  # 返回标签的类型数
            'feature_dim': len(self.data[idx])  # 返回特征维度
        }
        return sample
# 自定义数据加载器
class DynamicDataLoader(DataLoader):
    def __init__(self, dataset, batch_size):
        super().__init__(dataset, batch_size, shuffle=True)

    def __iter__(self):
        for batch in super().__iter__():
            yield batch
            # yield [{key: sample[key] for key in sample} for sample in batch]

# 定义 DNN 模型
class DNN(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim):
        super(DNN, self).__init__()
        self.fc1 = nn.Linear(input_dim, hidden_dim)
        self.fc2 = nn.Linear(hidden_dim, output_dim)

    def forward(self, x):
        x = F.relu(self.fc1(x))
        x = self.fc2(x)
        return F.log_softmax(x, dim=1)

# 标签值映射到从0开始的整数上
def map_labels_to_int(labels):
    label_map = {}  # 创建空字典用于存储标签值到整数的映射关系
    mapped_labels = []  # 存储映射后的整数标签列表
    count = 0  # 用于生成从 0 开始的整数

    for label in labels:
        if label not in label_map:
            label_map[label] = count
            count += 1
        mapped_labels.append(label_map[label])

    return mapped_labels, label_map  # 映射后的整数标签列表，标签映射关系

# 自动评估阈值，计算ACC 、 Precision 等评估指标
def evaluate(y_true, y_pred, digits=4, cutoff='auto'):
    '''
    Args:
        y_true: list, labels, y_pred: list, predictions, digits: The number of decimals to use when rounding the number. Default is 4（保留小数后几位）
        cutoff: float or 'auto'
    Returns:
        evaluation: dict
    '''
    # 根据预测概率值y_pred计算最佳的切分阈值
    if cutoff == 'auto':
        fpr, tpr, thresholds = roc_curve(y_true, y_pred)
        youden = tpr-fpr
        cutoff = thresholds[np.argmax(youden)]
    y_pred_t = [1 if i > cutoff else 0 for i in y_pred]

    evaluation = OrderedDict()
    tn, fp, fn, tp = confusion_matrix(y_true, y_pred_t).ravel()
    evaluation['auc'] = round(roc_auc_score(y_true, y_pred), digits)
    evaluation['acc'] = round(accuracy_score(y_true, y_pred_t), digits)
    evaluation['recall'] = round(recall_score(y_true, y_pred_t), digits)
    evaluation['precision'] = round(precision_score(y_true, y_pred_t), digits)
    evaluation['specificity'] = round(tn / (tn + fp), digits)
    evaluation['F1'] = round(f1_score(y_true, y_pred_t), digits)
    evaluation['cutoff'] = cutoff

    return evaluation

# DNN预测 输入：训练数据、训练label，测试数据，特征维度
def DNNPred(train_data, train_label, test_data, test_label, origin_batch_size):

    mapped_train_labels, _ = map_labels_to_int(train_label)
    mapped_test_labels, _ = map_labels_to_int(test_label)
    train_dataset = CustomDataset(train_data, mapped_train_labels)
    test_dataset = CustomDataset(test_data, mapped_test_labels)
    hidden_dim = 128  # 隐藏层维度
    input_dim = train_dataset[0]['feature_dim']  # 输入特征维度
    output_dim = train_dataset[0]['num_classes']   # 输出类别数
    train_loader = DynamicDataLoader(train_dataset, origin_batch_size)  # 动态形成 batchSize
    test_loader = DynamicDataLoader(test_dataset, origin_batch_size)
    # 创建大模型的实例
    model = DNN(input_dim, hidden_dim, output_dim)
    # 确保您的计算机上有CUDA支持的GPU
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print('模型搭建完成')
    model.to(device)
    # 定义损失函数和优化器
    loss_function = nn.NLLLoss()  # 负对数似然损失函数
    # optimizer = optim.Adam(model.parameters(), lr=0.001)
    # optimizer = optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), lr=0.001)
    optimizer = optim.SGD(filter(lambda p: p.requires_grad, model.parameters()), lr=0.1, momentum=0.9)

    average_loss_test, average_auc_test, average_acc_test, average_f1_test,\
        average_precision_test, average_recall_test = model_training(model, train_loader, test_loader,
                                                                     loss_function, optimizer, device)
    print('模型训练完成')
    print('||--------训练结束时间：', datetime.datetime.now(), '-------------')
    return average_loss_test, average_auc_test, average_acc_test, average_f1_test, average_precision_test, average_recall_test

def model_training(model, train_loader, val_loader, loss_function, optimizer, device):
    best_val_loss = float('inf')  # 初始化最佳验证损失为正无穷
    patience = 1  # 容忍多少个epoch没有验证性能提升
    early_stopping_counter = 0  # 初始化计数器
    EPOCH = 500
    for epoch in range(EPOCH):
        model.train()
        total_loss = 0.0
        train_time = 0
        val_time = 0
        # 使用动态数据加载器进行训练
        for batch in train_loader:
            batch = [data.to(device) for data in batch]
            # inputs = torch.tensor([sample['data'] for sample in batch])  # 提取数据部分并转换为张量
            # targets = torch.tensor([sample['label'] for sample in batch])  # 提取标签部分并转换为张量
            for param in model.parameters():
                param.requires_grad = True
            optimizer.zero_grad()
            inputs = torch.tensor(np.array(batch['data']), dtype=torch.float)  # 提取数据部分并转换为张量
            targets = batch['label'].clone().detach()  # 提取标签部分并转换为张量
            outputs = model(inputs)
            outputs = torch.argmax(outputs, dim=1)
            outputs[outputs == 1] = 0
            outputs[outputs == 2] = 1
            # print(inputs, targets, outputs)
            loss = loss_function(outputs, targets)
            loss.backward()
            optimizer.step()
            # 损失
            total_loss += loss.item()
            train_time += 1
            print('||--训练：----------', train_time, '个batch运行时间：', datetime.datetime.now(), '-------------')
            # 平均损失
        average_loss = total_loss / len(train_loader)

        # 使用训练好的模型进行预测
        # 假设有测试数据 test_data
        # test_data 的形状为 (样本数, 特征维度)
        if (epoch + 1) % 5 == 0:
            print(
                f"Epoch {epoch + 1},loss:{average_loss}")
            model.eval()
            with torch.no_grad():
                total_loss_val = 0.0
                total_auc_val = 0.0
                total_acc_val = 0
                total_f1_val = 0
                total_precision_val = 0
                total_recall_val = 0
                val_time = 0
                for batch_val in val_loader:  # 假设你有一个名为 val_loader 的验证集数据加载器
                    batch_val = [data.to(device) for data in batch_val]
                    inputs_val = torch.tensor(np.array(batch_val['data']), dtype=torch.float)  # 提取数据部分并转换为张量
                    targets_val = batch_val['label'].clone().detach()  # 提取标签部分并转换为张量
                    outputs_val = model(inputs_val)
                    outputs_val = torch.argmax(outputs_val, dim=1)
                    outputs_val[outputs_val == 1] = 0
                    outputs_val[outputs_val == 2] = 1
                    loss_val = loss_function(outputs_val, targets_val)
                    # 损失
                    total_loss_val += loss_val.item()
                    evaluation = evaluate(targets_val, outputs_val)
                    total_acc_val += evaluation['acc']
                    total_f1_val += evaluation['F1']
                    total_recall_val += evaluation['recall']
                    total_precision_val += evaluation['precision']
                    total_auc_val += evaluation['auc']
                    val_time += 1
                    print('||--验证：----------', val_time, '个batch运行时间：', datetime.datetime.now(), '-------------')
                    # 平均损失
                    average_loss_val = total_loss_val / len(val_loader)
                    average_auc_val = total_auc_val / len(val_loader)
                    average_acc_val = total_acc_val / len(val_loader)
                    average_f1_val = total_f1_val / len(val_loader)
                    average_precision_val = total_precision_val / len(val_loader)
                    average_recall_val = total_recall_val / len(val_loader)
                    print(
                        f"Validation Loss: {average_loss_val},AUC: {average_auc_val},ACC:{average_acc_val},F1:{average_f1_val},Precision:{average_precision_val},Recall:{average_recall_val}")

                    if average_loss_val < best_val_loss:
                        best_val_loss = average_loss_val
                        early_stopping_counter = 0
                    else:
                        early_stopping_counter += 1
                    if early_stopping_counter >= patience:
                        print(f"早停策略触发，停止训练在第 {epoch} 个epoch.")
                        break
    return average_loss_val, average_auc_val,average_acc_val,average_f1_val,average_precision_val,average_recall_val


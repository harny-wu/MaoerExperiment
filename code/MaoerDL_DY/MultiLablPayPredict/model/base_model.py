import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

import datetime
from sklearn.metrics import roc_auc_score, f1_score, accuracy_score, recall_score, precision_score, roc_curve, \
    confusion_matrix
from _collections import OrderedDict  # 导入 OrderedDict 来保持字典中键值对的顺序

from torch import device

import config
from layer.common import dense_layer_noReLu
from layer.embedding import UserPayHistoryEmbedding, TargetEmbedding, HistoryDimScalingLayer, \
    TargetDimScalingLayer, History_Target_AttentionLayer


class MatchingModel(nn.Module):
    def __init__(self, feature_category_num_dict, feature_column_dict, continue_embedding_dim,
                 discrete_embedding_dim, num_heads, feature_dim, max_history_len):
        super(MatchingModel, self).__init__()
        # Embedding层
        # self.user_info_embedding_layer = UserInfoEmbedding(continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict)
        self.user_history_pay_embedding_layer = UserPayHistoryEmbedding(continue_embedding_dim, discrete_embedding_dim,
                                                                        feature_category_num_dict, feature_column_dict)
        # print('embedding user_history结果')
        self.target_embedding_layer = TargetEmbedding(continue_embedding_dim, discrete_embedding_dim,
                                                      feature_category_num_dict, feature_column_dict)

        # User History & Target Attention层
        self.history_pay_attention_layer = HistoryDimScalingLayer(num_heads, feature_dim, feature_category_num_dict,
                                                                  max_history_len,feature_column_dict)
        self.target_attention_layer = TargetDimScalingLayer(feature_dim, feature_category_num_dict,feature_column_dict)

        # Target History Attention层
        self.target_history_attention_layer = History_Target_AttentionLayer(num_heads, feature_dim)

        # 维度转换层
        final_dim = 20
        self.target_dim_change = dense_layer_noReLu(3 * feature_dim,
                                                    final_dim)  # (batch,3,200)->(batch,600)->(batch,200)
        # self.user_info_dim_change = dense_layer(user_info_feature_num, 200)  # (batch,user_info_feature,200)->(batch,user_info_feature*200)->(batch,200)
        # MLP
        self.pay_vec_MLP_layer = dense_layer_noReLu(final_dim, 1)

    def forward(self, batch_feature_tensor_pay_QOE_discrete, batch_feature_tensor_pay_CHONGHE_discrete,
                batch_feature_tensor_pay_FUFEI_discrete,
                batch_feature_tensor_pay_QOE_continue, batch_feature_tensor_pay_CHONGHE_continue,
                batch_feature_tensor_pay_FUFEI_continue,
                batch_feature_tensor_target_QOE_discrete, batch_feature_tensor_target_CHONGHE_discrete,
                batch_feature_tensor_target_FUFEI_discrete,
                batch_feature_tensor_target_QOE_continue, batch_feature_tensor_target_CHONGHE_continue,
                batch_feature_tensor_target_FUFEI_continue,
                batch_feature_tensor_pay_QOE_discrete_mask, batch_feature_tensor_pay_CHONGHE_discrete_mask,
                batch_feature_tensor_pay_FUFEI_discrete_mask,
                batch_feature_tensor_pay_QOE_continue_mask, batch_feature_tensor_pay_CHONGHE_continue_mask,
                batch_feature_tensor_pay_FUFEI_continue_mask,
                label_tensor):
        # Embedding层
        user_history_pay_QOE_vec, user_history_pay_CHONGHE_vec, user_history_pay_FUFEI_vec = self.user_history_pay_embedding_layer(
            batch_feature_tensor_pay_QOE_discrete, batch_feature_tensor_pay_CHONGHE_discrete,
            batch_feature_tensor_pay_FUFEI_discrete, batch_feature_tensor_pay_QOE_continue,
            batch_feature_tensor_pay_CHONGHE_continue, batch_feature_tensor_pay_FUFEI_continue)
        target_QOE_vec, target_CHONGHE_vec, target_FUFEI_vec = self.target_embedding_layer(
            batch_feature_tensor_target_QOE_discrete, batch_feature_tensor_target_CHONGHE_discrete,
            batch_feature_tensor_target_FUFEI_discrete, batch_feature_tensor_target_QOE_continue,
            batch_feature_tensor_target_CHONGHE_continue, batch_feature_tensor_target_FUFEI_continue)
        # print('user_history_pay_FUFEI_vec size=',user_history_pay_FUFEI_vec.size())
        # print('target_QOE_vec size=',target_QOE_vec.size())
        # User History & Target Attention层
        # 合并mask输入
        # print("Shape of mask tensor:", batch_feature_tensor_pay_QOE_discrete_mask.shape,batch_feature_tensor_pay_QOE_continue_mask.shape)
        pay_QOE_mask = torch.cat(
            (batch_feature_tensor_pay_QOE_discrete_mask, batch_feature_tensor_pay_QOE_continue_mask), dim=2)
        pay_CHONGHE_mask = torch.cat(
            (batch_feature_tensor_pay_CHONGHE_discrete_mask, batch_feature_tensor_pay_CHONGHE_continue_mask), dim=2)
        pay_FUFEI_mask = torch.cat(
            (batch_feature_tensor_pay_FUFEI_discrete_mask, batch_feature_tensor_pay_FUFEI_continue_mask), dim=2)
        HistoryDimScaling_Weight_Result, se_user_history_pay_QOE_vec, se_user_history_pay_CHONGHE_vec, se_user_history_pay_FUFEI_vec = self.history_pay_attention_layer(
            user_history_pay_QOE_vec, user_history_pay_CHONGHE_vec, user_history_pay_FUFEI_vec,
            pay_QOE_mask=pay_QOE_mask, pay_CHONGHE_mask=pay_CHONGHE_mask, pay_FUFEI_mask=pay_FUFEI_mask)
        TargetDimScaling_Weight_Result, se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec = self.target_attention_layer(
            target_QOE_vec, target_CHONGHE_vec, target_FUFEI_vec)
        # print('se_user_history_pay_QOE_vec size=', se_user_history_pay_QOE_vec.shape)
        # print('se_target_QOE_vec size=', se_target_QOE_vec.shape)
        # Target with History Attention层
        target_history_pay_attention_vec, target_history_pay_attention_QOE_weight, \
            target_history_pay_attention_CHONGHE_weight, target_history_pay_attention_FUFEI_weight = self.target_history_attention_layer(
            se_user_history_pay_QOE_vec, se_user_history_pay_CHONGHE_vec, se_user_history_pay_FUFEI_vec,
            se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec)
        # print('target_history_pay_attention_vec size=', target_history_pay_attention_vec.shape)

        # # 拼接user_info_vec与target_history_pay_attention_vec等
        # user_info_vec = user_info_vec.squeeze(1)  # 使用 squeeze 函数移除大小为 1 的维度
        # FUFEI:(batch,3,200)->(batch,3*200)经过网络->(batch,200) + uer_info:(batch,featuer_user*200)经过网络->(batch,200) 叠加后-> (batch,400)
        # 维度转换 (batch,3,200)->(batch,feature*200)经过网络->(batch,200)
        target_history_pay_attention_vec = target_history_pay_attention_vec.view(config.batch_size,
                                                                                 -1)  # 将张量 x 重塑为 (batch, 3*200)  使用 -1 作为自动计算的维度
        target_history_pay_attention_vec = self.target_dim_change(target_history_pay_attention_vec)
        # print('target_history_pay_attention_vec',target_history_pay_attention_vec)

        # MLP
        # (batch,200) ->MLP ->(batch，1) ->sigmoid -> (batch,1)
        out_vec = self.pay_vec_MLP_layer(target_history_pay_attention_vec)
        # print('out_vec size=',out_vec.shape,'out_vec:',out_vec)
        # 使用softmax函数将logits转换为概率分布
        # softmax_score = F.softmax(out_vec, dim=1)  # 在类别维度（dim=1）上应用softmax
        sigmoid_score = torch.sigmoid(out_vec)  # 在类别维度（dim=1）上应用softmax
        # sigmoid_score = out_vec  # 在类别维度（dim=1）上应用softmax
        softmax_score = torch.softmax(out_vec, dim=1)
        # print('softmax_score size=',softmax_score.shape,'score:',softmax_score)
        # print('sigmoid_score size=',sigmoid_score.shape,'score:',sigmoid_score)

        return softmax_score, sigmoid_score, HistoryDimScaling_Weight_Result, TargetDimScaling_Weight_Result, target_history_pay_attention_QOE_weight, target_history_pay_attention_CHONGHE_weight, target_history_pay_attention_FUFEI_weight


# 损失函数
class LossFunction(nn.Module):
    def __init__(self):
        super(LossFunction, self).__init__()

    def forward(self, pred, target_label):
        # pred是未经处理过的原值，target_label是0、1标签
        # 计算第一个任务的二元交叉熵损失
        loss = F.binary_cross_entropy_with_logits(pred, target_label, reduction='none')
        return loss


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
        youden = tpr - fpr
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


# 输出 Target History 的对特征的注意力得分
def OutputMutliAttentionScore(attention_weights):
    # 将注意力矩阵 reshape 成 (batch_size * head_num, feature_num, head_dim) 的形状
    batch_size, feature_num, feature_num, head_dim = attention_weights.shape
    attention_weights = attention_weights.view(-1, feature_num, head_dim)
    # 定义全连接层和激活函数
    fc_layer = nn.Linear(head_dim, 1).to(attention_weights.device)
    activation = nn.Sigmoid()
    # 将注意力矩阵输入全连接层
    output = fc_layer(attention_weights)
    # 应用激活函数
    output = activation(output)
    # 将输出 reshape 成最终形状 (batch_size, feature_num, 1, 1)
    final_output = output.view(-1, feature_num, 1, 1)
    return final_output


# 输出权重结果到文件夹 首先要压缩维度到特征上，然后根据特征名列表输出
# tensor_dict_idx = ['pay_QOE_continue','pay_QOE_discrete','pay_CHONGHE_continue','pay_CHONGHE_discrete','pay_FUFEI_continue','pay_FUFEI_discrete','target_QOE_continue','target_QOE_discrete','target_CHONGHE_continue','target_CHONGHE_discrete','target_FUFEI_continue','target_FUFEI_discrete']
def WeightResult(HistoryDimScaling_Weight_Result, TargetDimScaling_Weight_Result,
                 target_history_pay_attention_QOE_weight,
                 target_history_pay_attention_CHONGHE_weight, target_history_pay_attention_FUFEI_weight):
    # SE attention  (batch,feature_num,1,1)
    se_user_pay_QOE_weight = HistoryDimScaling_Weight_Result['se_QOE_weight']
    se_user_pay_CHONGHE_weight = HistoryDimScaling_Weight_Result['se_CHONGHE_weight']
    se_user_pay_FUFEI_weight = HistoryDimScaling_Weight_Result['se_FUFEI_weight']
    se_target_QOE_weight = TargetDimScaling_Weight_Result['se_QOE_weight']
    se_target_CHONGHE_weight = TargetDimScaling_Weight_Result['se_CHONGHE_weight']
    se_target_FUFEI_weight = TargetDimScaling_Weight_Result['se_FUFEI_weight']
    # Target History Attention  得到(batch,feature_num,1,1)
    # print('target_history_pay_attention_QOE_weight',target_history_pay_attention_QOE_weight.shape)
    target_history_pay_attention_QOE_weight = OutputMutliAttentionScore(target_history_pay_attention_QOE_weight)
    target_history_pay_attention_CHONGHE_weight = OutputMutliAttentionScore(target_history_pay_attention_CHONGHE_weight)
    target_history_pay_attention_FUFEI_weight = OutputMutliAttentionScore(target_history_pay_attention_FUFEI_weight)
    # 在batch维度上取平均，保持维度 得到(1,feature_num,1,1) 再用.squeeze()去掉为1的维度
    se_user_pay_QOE_weight = se_user_pay_QOE_weight.mean(dim=0, keepdim=True).squeeze()
    se_user_pay_CHONGHE_weight = se_user_pay_CHONGHE_weight.mean(dim=0, keepdim=True).squeeze()
    se_user_pay_FUFEI_weight = se_user_pay_FUFEI_weight.mean(dim=0, keepdim=True).squeeze()
    se_target_QOE_weight = se_target_QOE_weight.mean(dim=0, keepdim=True).squeeze()
    se_target_CHONGHE_weight = se_target_CHONGHE_weight.mean(dim=0, keepdim=True).squeeze()
    se_target_FUFEI_weight = se_target_FUFEI_weight.mean(dim=0, keepdim=True).squeeze()
    target_history_pay_attention_QOE_weight = target_history_pay_attention_QOE_weight.mean(dim=0,
                                                                                           keepdim=True).squeeze()
    target_history_pay_attention_CHONGHE_weight = target_history_pay_attention_CHONGHE_weight.mean(dim=0,
                                                                                                   keepdim=True).squeeze()
    target_history_pay_attention_FUFEI_weight = target_history_pay_attention_FUFEI_weight.mean(dim=0,
                                                                                               keepdim=True).squeeze()

    result = {'se_user_pay_QOE_weight': se_user_pay_QOE_weight.tolist(),
              'se_user_pay_CHONGHE_weight': se_user_pay_CHONGHE_weight.tolist(),
              'se_user_pay_FUFEI_weight': se_user_pay_FUFEI_weight.tolist(),
              'se_target_QOE_weight': se_target_QOE_weight.tolist(),
              'se_target_CHONGHE_weight': se_target_CHONGHE_weight.tolist(),
              'se_target_FUFEI_weight': se_target_FUFEI_weight.tolist(),
              'target_history_pay_attention_QOE_weight': target_history_pay_attention_QOE_weight.tolist(),
              'target_history_pay_attention_CHONGHE_weight': target_history_pay_attention_CHONGHE_weight.tolist(),
              'target_history_pay_attention_FUFEI_weight': target_history_pay_attention_FUFEI_weight.tolist()
              }

    return result

# 7.模型训练 Trainging
def model_training(model, train_loader, val_loader, lossfunction, optimizer, EPOCH, device):
    # 定义早停策略的参数
    best_val_loss = float('inf')  # 初始化最佳验证损失为正无穷
    patience = 1  # 容忍多少个epoch没有验证性能提升
    early_stopping_counter = 0  # 初始化计数器

    for epoch in range(EPOCH):
        model.train()  # 设置模型为训练模式
        total_classfier_loss = 0.0
        total_loss = 0.0
        train_time = 0
        val_time = 0
        for batch in train_loader:
            batch = [data.to(device) for data in batch]
            batch_feature_tensor_pay_QOE_discrete, batch_feature_tensor_pay_CHONGHE_discrete, batch_feature_tensor_pay_FUFEI_discrete, \
                batch_feature_tensor_pay_QOE_continue, batch_feature_tensor_pay_CHONGHE_continue, batch_feature_tensor_pay_FUFEI_continue, \
                batch_feature_tensor_target_QOE_discrete, batch_feature_tensor_target_CHONGHE_discrete, batch_feature_tensor_target_FUFEI_discrete, \
                batch_feature_tensor_target_QOE_continue, batch_feature_tensor_target_CHONGHE_continue, batch_feature_tensor_target_FUFEI_continue, \
                batch_feature_tensor_pay_QOE_discrete_mask, batch_feature_tensor_pay_CHONGHE_discrete_mask, batch_feature_tensor_pay_FUFEI_discrete_mask, \
                batch_feature_tensor_pay_QOE_continue_mask, batch_feature_tensor_pay_CHONGHE_continue_mask, batch_feature_tensor_pay_FUFEI_continue_mask, \
                train_label_tensor = batch
            for param in model.parameters():
                param.requires_grad = True
            optimizer.zero_grad()
            softmax_score, sigmoid_score, HistoryDimScaling_Weight_Result, TargetDimScaling_Weight_Result, \
                target_history_pay_attention_QOE_weight, target_history_pay_attention_CHONGHE_weight, \
                target_history_pay_attention_FUFEI_weight = model(batch_feature_tensor_pay_QOE_discrete,
                                                                  batch_feature_tensor_pay_CHONGHE_discrete,
                                                                  batch_feature_tensor_pay_FUFEI_discrete,
                                                                  batch_feature_tensor_pay_QOE_continue,
                                                                  batch_feature_tensor_pay_CHONGHE_continue,
                                                                  batch_feature_tensor_pay_FUFEI_continue,
                                                                  batch_feature_tensor_target_QOE_discrete,
                                                                  batch_feature_tensor_target_CHONGHE_discrete,
                                                                  batch_feature_tensor_target_FUFEI_discrete,
                                                                  batch_feature_tensor_target_QOE_continue,
                                                                  batch_feature_tensor_target_CHONGHE_continue,
                                                                  batch_feature_tensor_target_FUFEI_continue,
                                                                  batch_feature_tensor_pay_QOE_discrete_mask,
                                                                  batch_feature_tensor_pay_CHONGHE_discrete_mask,
                                                                  batch_feature_tensor_pay_FUFEI_discrete_mask,
                                                                  batch_feature_tensor_pay_QOE_continue_mask,
                                                                  batch_feature_tensor_pay_CHONGHE_continue_mask,
                                                                  batch_feature_tensor_pay_FUFEI_continue_mask,
                                                                  train_label_tensor)

            # weight_result_dict = WeightResult(HistoryDimScaling_Weight_Result, TargetDimScaling_Weight_Result, target_history_pay_attention_QOE_weight,
            #            target_history_pay_attention_CHONGHE_weight,target_history_pay_attention_FUFEI_weight)
            # weight_result_dict = {key: torch.tensor(value).cpu() for key, value in weight_result_dict.items()}
            # print('weight_result_dict_se_user_pay_QOE_weight',weight_result_dict['se_user_pay_QOE_weight'])
            # print('HistoryDimScaling_Weight_Result, TargetDimScaling_Weight_Result, target_history_pay_attention_weight',
            #      HistoryDimScaling_Weight_Result['mutli_QOE_weight'].shape, TargetDimScaling_Weight_Result['se_QOE_weight'].shape, target_history_pay_attention_weight.shape)
            # sigmoid
            # print('sigmoid_score',sigmoid_score)
            sigmoid_score = sigmoid_score[:, 0]  # (样本数，1)
            train_label_tensor = train_label_tensor[:, 0].to(device)  # (样本数，1)
            # train_label_tensor[train_label_tensor == 1] = 0
            # train_label_tensor[train_label_tensor == 2] = 1
            # train_label_tensor = torch.where(train_label_tensor == 1, torch.tensor(0).to(device), torch.tensor(1).to(device))  # 使用 torch.where 将 1 映射为 0，将 2 映射为 1
            loss = lossfunction(sigmoid_score, train_label_tensor.float())
            # softmax
            # softmax_score = softmax_score[:, 0]  # (样本数，1)
            # train_label_tensor = train_label_tensor[:, 0].to(device)  # (样本数，1)
            # train_label_tensor = torch.where(train_label_tensor == 1, torch.tensor(0).to(device), torch.tensor(1).to(device))  # 使用 torch.where 将 1 映射为 0，将 2 映射为 1
            # loss = lossfunction(softmax_score, train_label_tensor.float())
            loss.to(device)

            # loss回传检查
            # for name, parms in model.named_parameters():	
            #     if parms.grad is not None:  # 检查梯度是否为None
            #         grad_mean = torch.mean(parms.grad)  # 计算梯度的均值
            #         print('-->name:', name, '-->grad_requirs:', parms.requires_grad, '-->grad_mean: {:.4f}'.format(grad_mean))
            #     else:
            #         print('-->name:', name, '-->grad_requirs:', parms.requires_grad, '-->grad_mean: None')
            loss.backward()
            optimizer.step()
            # print("=============更新之后===========")
            # for name, parms in model.named_parameters():	
            #     if parms.grad is not None:  # 检查梯度是否为None
            #         grad_mean = torch.mean(parms.grad)  # 计算梯度的均值
            #         print('-->name:', name, '-->grad_requirs:', parms.requires_grad, '-->grad_mean: {:.4f}'.format(grad_mean))
            #     else:
            #         print('-->name:', name, '-->grad_requirs:', parms.requires_grad, '-->grad_mean: None')
            # print(optimizer)
            # input("=====迭代结束=====")

            # 损失
            total_loss += loss.item()
            train_time += 1
            print('||--训练：----------', train_time, '个batch运行时间：', datetime.datetime.now(), '-------------')
        # 平均损失
        average_loss = total_loss / len(train_loader)

        if (epoch + 1) % 5 == 0:
            print(
                f"Epoch {epoch + 1},loss:{average_loss}")

            # 验证集评估
            model.eval()  # 将模型切换为评估模式
            with torch.no_grad():  # 在评估模式下不计算梯度
                total_loss_val = 0.0
                total_auc_val = 0.0
                total_acc_val = 0
                total_f1_val = 0
                total_precision_val = 0
                total_recall_val = 0
                val_time = 0
                for batch_val in val_loader:  # 假设你有一个名为 val_loader 的验证集数据加载器
                    batch_val = [data.to(device) for data in batch_val]
                    val_batch_feature_tensor_pay_QOE_discrete, val_batch_feature_tensor_pay_CHONGHE_discrete, val_batch_feature_tensor_pay_FUFEI_discrete, \
                        val_batch_feature_tensor_pay_QOE_continue, val_batch_feature_tensor_pay_CHONGHE_continue, val_batch_feature_tensor_pay_FUFEI_continue, \
                        val_batch_feature_tensor_target_QOE_discrete, val_batch_feature_tensor_target_CHONGHE_discrete, val_batch_feature_tensor_target_FUFEI_discrete, \
                        val_batch_feature_tensor_target_QOE_continue, val_batch_feature_tensor_target_CHONGHE_continue, val_batch_feature_tensor_target_FUFEI_continue, \
                        val_batch_feature_tensor_pay_QOE_discrete_mask, val_batch_feature_tensor_pay_CHONGHE_discrete_mask, val_batch_feature_tensor_pay_FUFEI_discrete_mask, \
                        val_batch_feature_tensor_pay_QOE_continue_mask, val_batch_feature_tensor_pay_CHONGHE_continue_mask, val_batch_feature_tensor_pay_FUFEI_continue_mask, \
                        val_label_tensor = batch_val
                    softmax_score_val, sigmoid_score_val, HistoryDimScaling_Weight_Result_val, TargetDimScaling_Weight_Result_val, \
                        target_history_pay_attention_QOE_weight_val, target_history_pay_attention_CHONGHE_weight_val, \
                        target_history_pay_attention_FUFEI_weight_val = model(val_batch_feature_tensor_pay_QOE_discrete,
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

                    # sigmoid                   
                    sigmoid_score_val = sigmoid_score_val[:, 0]  # (样本数，1)
                    sigmoid_score_val = sigmoid_score_val.cpu()  # .detach()  # 转为CPU
                    val_label_tensor = val_label_tensor[:, 0]  # (样本数，1)
                    val_label_tensor = val_label_tensor.cpu()
                    # val_label_tensor[val_label_tensor == 1] = 0
                    # val_label_tensor[val_label_tensor == 2] = 1
                    # val_label_tensor = torch.where(val_label_tensor == 1, torch.tensor(0), torch.tensor(1))  # 使用 torch.where 将 1 映射为 0，将 2 映射为 1
                    loss_val = lossfunction(sigmoid_score_val, val_label_tensor.float())
                    # softmax
                    # softmax_score_val = softmax_score_val[:, 0]  # (样本数，1)
                    # softmax_score_val = softmax_score_val.cpu()# .detach()  # 转为CPU
                    # val_label_tensor = val_label_tensor[:, 0]  # (样本数，1)
                    # val_label_tensor = val_label_tensor.cpu()
                    # val_label_tensor = torch.where(val_label_tensor == 1, torch.tensor(0), torch.tensor(1))  # 使用 torch.where 将 1 映射为 0，将 2 映射为 1
                    # loss_val = lossfunction(softmax_score_val, val_label_tensor.float())

                    # 损失
                    total_loss_val += loss_val.item()
                    # 计算验证集上的精度
                    # predicted_classes_val = (sigmoid_score_val > 0.5).long()
                    # total_acc_val += (predicted_classes_val == val_label_tensor).sum().item() / len(val_label_tensor)
                    # total_f1_val += f1_score(val_label_tensor, predicted_classes_val)
                    # total_recall_val += recall_score(val_label_tensor, predicted_classes_val)
                    # precision_val = ((predicted_classes_val == 1) & (val_label_tensor == 1)).sum().item() / (predicted_classes_val == 1).sum().item()
                    # total_precision_val += precision_val
                    # total_auc_val += roc_auc_score(val_label_tensor, softmax_score_val)
                    evaluation = evaluate(val_label_tensor, sigmoid_score_val)
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

# 模型测试 Test
def test_model(model, test_loader):
    model.eval()  # 设置模型为评估模式
    with torch.no_grad():  # 在评估模式下不计算梯度
        total_loss_test = 0.0
        total_auc_test = 0.0
        total_acc_test = 0
        total_f1_test = 0
        total_precision_test = 0
        total_recall_test = 0
        test_time = 0
        results = []  # 用于保存结果的列表
        for batch_test in test_loader:  # 假设你有一个名为 val_loader 的验证集数据加载器
            batch_test = [data.to(device) for data in batch_test]
            test_batch_feature_tensor_pay_QOE_discrete, test_batch_feature_tensor_pay_CHONGHE_discrete, test_batch_feature_tensor_pay_FUFEI_discrete, \
                test_batch_feature_tensor_pay_QOE_continue, test_batch_feature_tensor_pay_CHONGHE_continue, test_batch_feature_tensor_pay_FUFEI_continue, \
                test_batch_feature_tensor_target_QOE_discrete, test_batch_feature_tensor_target_CHONGHE_discrete, test_batch_feature_tensor_target_FUFEI_discrete, \
                test_batch_feature_tensor_target_QOE_continue, test_batch_feature_tensor_target_CHONGHE_continue, test_batch_feature_tensor_target_FUFEI_continue, \
                test_batch_feature_tensor_pay_QOE_discrete_mask, test_batch_feature_tensor_pay_CHONGHE_discrete_mask, test_batch_feature_tensor_pay_FUFEI_discrete_mask, \
                test_batch_feature_tensor_pay_QOE_continue_mask, test_batch_feature_tensor_pay_CHONGHE_continue_mask, test_batch_feature_tensor_pay_FUFEI_continue_mask, \
                test_label_tensor = batch_test
            softmax_score_test, sigmoid_score_test, HistoryDimScaling_Weight_Result_test, TargetDimScaling_Weight_Result_test, \
                target_history_pay_attention_QOE_weight_test, target_history_pay_attention_CHONGHE_weight_test, \
                target_history_pay_attention_FUFEI_weight_test = model(test_batch_feature_tensor_pay_QOE_discrete,
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
            weight_result_dict = WeightResult(HistoryDimScaling_Weight_Result_test, TargetDimScaling_Weight_Result_test,
                                              target_history_pay_attention_QOE_weight_test,
                                              target_history_pay_attention_CHONGHE_weight_test,
                                              target_history_pay_attention_FUFEI_weight_test)
            weight_result_dict = {key: torch.tensor(value).cpu() for key, value in weight_result_dict.items()}
            # sigmoid
            sigmoid_score_test = sigmoid_score_test[:, 0]  # (样本数，1)
            sigmoid_score_test = sigmoid_score_test.cpu()  #.detach()  # 转为CPU
            test_label_tensor = test_label_tensor[:, 0]  # (样本数，1)
            test_label_tensor = test_label_tensor.cpu()
            # test_label_tensor[test_label_tensor == 1] = 0
            # test_label_tensor[test_label_tensor == 2] = 1
            # test_label_tensor = torch.where(test_label_tensor == 1, torch.tensor(0), torch.tensor(1))  # 使用 torch.where 将 1 映射为 0，将 2 映射为 1
            loss_test = LossFunction(sigmoid_score_test, test_label_tensor.float())
            # softmax
            # softmax_score_test = softmax_score_test[:, 0]  # (样本数，1)
            # softmax_score_test = softmax_score_test.cpu()#.detach()  # 转为CPU
            # test_label_tensor = test_label_tensor[:, 0]  # (样本数，1)
            # test_label_tensor = test_label_tensor.cpu()
            # test_label_tensor = torch.where(test_label_tensor == 1, torch.tensor(0), torch.tensor(1))  # 使用 torch.where 将 1 映射为 0，将 2 映射为 1
            # loss_test = lossfunction(softmax_score_test, test_label_tensor.float())

            # 损失
            total_loss_test += loss_test.item()
            # 计算验证集上的精度
            # predicted_classes_test = (sigmoid_score_test > 0.5).long()
            # total_acc_test += (predicted_classes_test == test_label_tensor).sum().item() / len(test_label_tensor)
            # total_f1_test += f1_score(test_label_tensor, predicted_classes_test)
            # total_recall_test += recall_score(test_label_tensor, predicted_classes_test)
            # precision_test = ((predicted_classes_test == 1) & (test_label_tensor == 1)).sum().item() / (predicted_classes_test == 1).sum().item()
            # total_precision_test += precision_test
            # total_auc_test += roc_auc_score(test_label_tensor, sigmoid_score_test)
            evaluation = evaluate(test_label_tensor, sigmoid_score_test)
            total_acc_test += evaluation['acc']
            total_f1_test += evaluation['F1']
            total_recall_test += evaluation['recall']
            total_precision_test += evaluation['precision']
            total_auc_test += evaluation['auc']

            test_time += 1
            print('||--测试：----------', test_time, '个batch运行时间：', datetime.datetime.now(), '-------------')
        # 平均损失
        average_loss_test = total_loss_test / len(test_loader)
        average_auc_test = total_auc_test / len(test_loader)
        average_acc_test = total_acc_test / len(test_loader)
        average_f1_test = total_f1_test / len(test_loader)
        average_precision_test = total_precision_test / len(test_loader)
        average_recall_test = total_recall_test / len(test_loader)
        print(
            f"Test Loss: {average_loss_test},AUC: {average_auc_test},ACC:{average_acc_test},F1:{average_f1_test},Precision:{average_precision_test},Recall:{average_recall_test}")
        return average_loss_test, average_auc_test, average_acc_test, average_f1_test, average_precision_test, average_recall_test, weight_result_dict

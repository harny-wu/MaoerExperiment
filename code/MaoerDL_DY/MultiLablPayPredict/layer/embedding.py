import torch
from torch import nn

from MultiLablPayPredict.config import max_history_len, feature_dim
from MultiLablPayPredict.layer.basic_attention import MultiHeadSelfAttention, MultiHeadHistory_TargetAttention
from MultiLablPayPredict.layer.common import discrete_embedding, continuous_embedding, category_feature_num, SELayer


# user_history_feature 对于一个user的多个历史行为，将其拼接成一维向量 要先经过一层通道注意力机制得到最后结果
# (样本数,history,20,200) ->多头 ->(样本数,20,200)->转置->(样本数,200,20) ->SE->特征权重->(样本数,200,20) ->转置-> 加权->(样本数,1，200)
# user_pay_history_feature 加上batch的
# 用户历史
class UserPayHistoryEmbedding(nn.Module):
    def __init__(self, continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict):
        super(UserPayHistoryEmbedding, self).__init__()
        # 连续特征
        # 离散特征
        self.feature_category_num_dict = feature_category_num_dict
        # 离散embedding
        self.user_pay_history_QOE_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                           feature_column_dict['history_QOE_discrete'],
                                                                           discrete_embedding_dim)
        self.user_pay_history_CHONGHE_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                               feature_column_dict[
                                                                                   'history_CHONGHE_discrete_add_D'],
                                                                               discrete_embedding_dim)
        self.user_pay_history_FUFEI_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                             feature_column_dict[
                                                                                 'history_FUFEI_discrete'],
                                                                             discrete_embedding_dim)
        # MLP  连续embedding
        # category_feature_num_list = category_feature_num(feature_category_num_dict, feature_column_dict['history_QOE_continue'])
        self.user_pay_history_QOE_continue_embedding = continuous_embedding(
            category_feature_num(feature_category_num_dict, feature_column_dict['history_QOE_continue']),
            continue_embedding_dim)
        self.user_pay_history_CHONGHE_continue_embedding = continuous_embedding(
            category_feature_num(feature_category_num_dict, feature_column_dict['history_CHONGHE_continue']),
            continue_embedding_dim)
        self.user_pay_history_FUFEI_continue_embedding = continuous_embedding(
            category_feature_num(feature_category_num_dict, feature_column_dict['history_FUFEI_continue']),
            continue_embedding_dim)

    def forward(self, batch_feature_tensor_pay_QOE_discrete, batch_feature_tensor_pay_CHONGHE_discrete,
                batch_feature_tensor_pay_FUFEI_discrete, batch_feature_tensor_pay_QOE_continue,
                batch_feature_tensor_pay_CHONGHE_continue, batch_feature_tensor_pay_FUFEI_continue):
        # user_history Embedding
        # user_history_continue_features_embedding 得到(batch, 1, continue_feature_num, continue_embedding_dim)
        # user_history_discrete_features_embedding 得到(batch, 1, discrete_feature_num, discrete_embedding_dim)
        # history中有三种：QOE/CHONGHE/FUFEI,将其分别转化为embedding然后合并
        # embedding的数据要求输入是整数类型 因此转为int，输入数据得是从0开始的索引后的数据，因此mask后得到-1以及在输入时得到了从0开始的索引后值，
        # 现在所有discrete数据输入时+1，即 batch_feature_tensor_pay_QOE_discrete[:, :, i]+1
        # for i in range(batch_feature_tensor_pay_QOE_discrete.shape[2]):
        #     print(i,batch_feature_tensor_pay_QOE_discrete.shape[2],batch_feature_tensor_pay_QOE_discrete[:, :, i]+1,self.user_pay_history_QOE_discrete_embeddings[i].num_embeddings )
        batch_feature_tensor_pay_QOE_discrete = batch_feature_tensor_pay_QOE_discrete.int()
        batch_feature_tensor_pay_CHONGHE_discrete = batch_feature_tensor_pay_CHONGHE_discrete.int()
        batch_feature_tensor_pay_FUFEI_discrete = batch_feature_tensor_pay_FUFEI_discrete.int()

        user_history_pay_QOE_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_pay_QOE_discrete[:, :, i] + 1) for i, embedding_layer in
             enumerate(self.user_pay_history_QOE_discrete_embeddings)], dim=-2)
        user_history_pay_QOE_continue_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_pay_QOE_continue[:, :, i].unsqueeze(-1).float()) for
             i, embedding_layer in
             enumerate(self.user_pay_history_QOE_continue_embedding)], dim=-2)
        user_history_pay_QOE_vec = torch.cat(
            [user_history_pay_QOE_discrete_column_discrete_features_embedding,
             user_history_pay_QOE_continue_column_discrete_features_embedding], dim=2)  # 特征级合并

        user_history_pay_CHONGHE_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_pay_CHONGHE_discrete[:, :, i] + 1) for i, embedding_layer in
             enumerate(self.user_pay_history_CHONGHE_discrete_embeddings)], dim=-2)
        user_history_pay_CHONGHE_continue_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_pay_CHONGHE_continue[:, :, i].unsqueeze(2).float()) for
             i, embedding_layer in
             enumerate(self.user_pay_history_CHONGHE_continue_embedding)], dim=-2)
        user_history_pay_CHONGHE_vec = torch.cat(
            [user_history_pay_CHONGHE_discrete_column_discrete_features_embedding,
             user_history_pay_CHONGHE_continue_column_discrete_features_embedding], dim=2)  # 特征级合并

        user_history_pay_FUFEI_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_pay_FUFEI_discrete[:, :, i] + 1) for i, embedding_layer in
             enumerate(self.user_pay_history_FUFEI_discrete_embeddings)], dim=-2)
        user_history_pay_FUFEI_continue_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_pay_FUFEI_continue[:, :, i].unsqueeze(2).float()) for
             i, embedding_layer in
             enumerate(self.user_pay_history_FUFEI_continue_embedding)], dim=-2)
        user_history_pay_FUFEI_vec = torch.cat(
            [user_history_pay_FUFEI_discrete_column_discrete_features_embedding,
             user_history_pay_FUFEI_continue_column_discrete_features_embedding], dim=2)  # 特征级合并
        # print(user_history_pay_FUFEI_discrete_column_discrete_features_embedding.shape,user_history_pay_FUFEI_continue_column_discrete_features_embedding.shape)

        return user_history_pay_QOE_vec, user_history_pay_CHONGHE_vec, user_history_pay_FUFEI_vec


# target_feature
class TargetEmbedding(nn.Module):
    def __init__(self, continue_embedding_dim, discrete_embedding_dim, feature_category_num_dict, feature_column_dict):
        super(TargetEmbedding, self).__init__()
        # 连续特征  与付费、非付费共享一套特征
        # 离散特征  与付费、非付费共享一套特征
        self.feature_category_num_dict = feature_category_num_dict
        # 离散embedding
        self.target_QOE_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                 feature_column_dict['history_QOE_discrete'],
                                                                 discrete_embedding_dim)
        self.target_CHONGHE_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                     feature_column_dict['history_CHONGHE_discrete'],
                                                                     discrete_embedding_dim)
        self.target_FUFEI_discrete_embeddings = discrete_embedding(self.feature_category_num_dict,
                                                                   feature_column_dict['history_FUFEI_discrete'],
                                                                   discrete_embedding_dim)
        # MLP  连续embedding
        self.target_QOE_continue_embedding = continuous_embedding(
            category_feature_num(feature_category_num_dict, feature_column_dict['history_QOE_continue']),
            continue_embedding_dim)
        self.target_CHONGHE_continue_embedding = continuous_embedding(
            category_feature_num(feature_category_num_dict, feature_column_dict['history_CHONGHE_continue']),
            continue_embedding_dim)
        self.target_FUFEI_continue_embedding = continuous_embedding(
            category_feature_num(feature_category_num_dict, feature_column_dict['history_FUFEI_continue']),
            continue_embedding_dim)

    def forward(self, batch_feature_tensor_target_QOE_discrete, batch_feature_tensor_target_CHONGHE_discrete,
                batch_feature_tensor_target_FUFEI_discrete, batch_feature_tensor_target_QOE_continue,
                batch_feature_tensor_target_CHONGHE_continue, batch_feature_tensor_target_FUFEI_continue):
        # target Embedding
        # target_continue_features_embedding 得到(batch, 1, continue_feature_num, continue_embedding_dim)
        # target_discrete_features_embedding 得到(batch, 1, discrete_feature_num, discrete_embedding_dim)
        # 有三种：QOE/CHONGHE/FUFEI,将其分别转化为embedding然后合并
        batch_feature_tensor_target_QOE_discrete = batch_feature_tensor_target_QOE_discrete.int()
        batch_feature_tensor_target_CHONGHE_discrete = batch_feature_tensor_target_CHONGHE_discrete.int()
        batch_feature_tensor_target_FUFEI_discrete = batch_feature_tensor_target_FUFEI_discrete.int()
        target_QOE_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_target_QOE_discrete[:, :, i] + 1) for i, embedding_layer in
             enumerate(self.target_QOE_discrete_embeddings)], dim=-2)
        target_QOE_continue_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_target_QOE_continue[:, :, i].unsqueeze(2).float()) for
             i, embedding_layer in
             enumerate(self.target_QOE_continue_embedding)], dim=-2)
        target_QOE_vec = torch.cat(
            [target_QOE_discrete_column_discrete_features_embedding,
             target_QOE_continue_column_discrete_features_embedding], dim=2)  # 特征级合并

        target_CHONGHE_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_target_CHONGHE_discrete[:, :, i] + 1) for i, embedding_layer in
             enumerate(self.target_CHONGHE_discrete_embeddings)], dim=-2)
        target_CHONGHE_continue_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_target_CHONGHE_continue[:, :, i].unsqueeze(2).float()) for
             i, embedding_layer in
             enumerate(self.target_CHONGHE_continue_embedding)], dim=-2)
        target_CHONGHE_vec = torch.cat(
            [target_CHONGHE_discrete_column_discrete_features_embedding,
             target_CHONGHE_continue_column_discrete_features_embedding], dim=2)  # 特征级合并

        target_FUFEI_discrete_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_target_FUFEI_discrete[:, :, i] + 1) for i, embedding_layer in
             enumerate(self.target_FUFEI_discrete_embeddings)], dim=-2)
        target_FUFEI_continue_column_discrete_features_embedding = torch.stack(
            [embedding_layer(batch_feature_tensor_target_FUFEI_continue[:, :, i].unsqueeze(2).float()) for
             i, embedding_layer in
             enumerate(self.target_FUFEI_continue_embedding)], dim=-2)
        target_FUFEI_vec = torch.cat(
            [target_FUFEI_discrete_column_discrete_features_embedding,
             target_FUFEI_continue_column_discrete_features_embedding], dim=2)  # 特征级合并

        return target_QOE_vec, target_CHONGHE_vec, target_FUFEI_vec


# 用户历史embedding 多头+SE  (batch, history, feature_num, feature_dim)->(batch, 1，feature_dim)
class HistoryDimScalingLayer(nn.Module):
    def __init__(self, num_heads, feature_dim, feature_category_num_dict, max_history_len, feature_column_dict):
        super(HistoryDimScalingLayer, self).__init__()
        self.feature_column_dict = feature_column_dict
        # 多头注意力
        self.multi_head_attention = MultiHeadSelfAttention(num_heads, feature_dim, max_history_len)
        # SE注意力
        self.se_attention_QOE = SELayer(
            len(category_feature_num(feature_category_num_dict,
                                     self.feature_column_dict['history_QOE_continue'])) + len(
                category_feature_num(feature_category_num_dict, feature_column_dict['history_QOE_discrete'])))
        self.se_attention_CHONGHE = SELayer(
            len(category_feature_num(feature_category_num_dict, feature_column_dict['history_CHONGHE_continue'])) + len(
                category_feature_num(feature_category_num_dict, feature_column_dict['history_CHONGHE_discrete_add_D'])))
        self.se_attention_FUFEI = SELayer(
            len(category_feature_num(feature_category_num_dict, feature_column_dict['history_FUFEI_continue'])) + len(
                category_feature_num(feature_category_num_dict, feature_column_dict['history_FUFEI_discrete'])))

    def forward(self, user_history_QOE_vec, user_history_CHONGHE_vec, user_history_FUFEI_vec, pay_QOE_mask=None,
                pay_CHONGHE_mask=None, pay_FUFEI_mask=None):
        # (batch, history, feature_num, feature_dim) ->多头 ->(batch, feature_num, feature_dim)->转置->(batch, feature_dim, feature_num) ->SE->特征权重->(batch, feature_dim, feature_num) ->转置-> 加权->(batch, 1，feature_dim)
        # 多头注意力  例(batch, history, 20, 200) ->多头 ->(batch, 20, 200)
        # print('user_history_QOE_vec',user_history_QOE_vec.shape,pay_QOE_mask.shape)
        # ********多头注意力前转化************
        # 二、三维度互换  变为(batch, feature_num, history, 200)
        user_history_QOE_vec = user_history_QOE_vec.permute(0, 2, 1, 3)
        user_history_CHONGHE_vec = user_history_CHONGHE_vec.permute(0, 2, 1, 3)
        user_history_FUFEI_vec = user_history_FUFEI_vec.permute(0, 2, 1, 3)
        # 记录特征数
        user_history_QOE_temp_dim = user_history_QOE_vec.shape[1]
        user_history_CHONGHE_temp_dim = user_history_CHONGHE_vec.shape[1]
        user_history_FUFEI_temp_dim = user_history_FUFEI_vec.shape[1]
        # （样本数*特征数,历史数，200）
        user_history_QOE_vec = user_history_QOE_vec.reshape(-1, max_history_len, feature_dim)
        user_history_CHONGHE_vec = user_history_CHONGHE_vec.reshape(-1, max_history_len, feature_dim)
        user_history_FUFEI_vec = user_history_FUFEI_vec.reshape(-1, max_history_len, feature_dim)
        # (样本数*特征数，200）
        multi_QOE_weight, multi_user_history_QOE_vec, _ = self.multi_head_attention(user_history_QOE_vec,
                                                                                    mask=pay_QOE_mask)
        multi_CHONGHE_weight, multi_user_history_CHONGHE_vec, _ = self.multi_head_attention(user_history_CHONGHE_vec,
                                                                                            mask=pay_CHONGHE_mask)
        multi_FUFEI_weight, multi_user_history_FUFEI_vec, _ = self.multi_head_attention(user_history_FUFEI_vec,
                                                                                        mask=pay_FUFEI_mask)
        # (样本数,特征数，200）
        multi_user_history_QOE_vec = multi_user_history_QOE_vec.view(-1, user_history_QOE_temp_dim, feature_dim)
        multi_user_history_CHONGHE_vec = multi_user_history_CHONGHE_vec.view(-1, user_history_CHONGHE_temp_dim,
                                                                             feature_dim)
        multi_user_history_FUFEI_vec = multi_user_history_FUFEI_vec.view(-1, user_history_FUFEI_temp_dim, feature_dim)

        multi_user_history_QOE_vec = multi_user_history_QOE_vec.unsqueeze(-1)
        multi_user_history_CHONGHE_vec = multi_user_history_CHONGHE_vec.unsqueeze(-1)
        multi_user_history_FUFEI_vec = multi_user_history_FUFEI_vec.unsqueeze(-1)

        # SE注意力  (batch,feature_num,feature_dim,1) ->SE->特征权重->(batch,feature_num,feature_dim,1)->去除最后一列-> 加权->(batch, 1，feature_dim)
        se_QOE_weight, se_user_history_QOE_vec, _ = self.se_attention_QOE(multi_user_history_QOE_vec)
        se_CHONGHE_weight, se_user_history_CHONGHE_vec, _ = self.se_attention_CHONGHE(multi_user_history_CHONGHE_vec)
        se_FUFEI_weight, se_user_history_FUFEI_vec, _ = self.se_attention_FUFEI(multi_user_history_FUFEI_vec)

        HistoryDimScaling_Weight_Result = {
            'mutli_QOE_weight': multi_QOE_weight,
            'mutli_CHONGHE_weight': multi_CHONGHE_weight,
            'mutli_FUFEI_weight': multi_FUFEI_weight,
            'se_QOE_weight': se_QOE_weight,
            'se_CHONGHE_weight': se_CHONGHE_weight,
            'se_FUFEI_weight': se_FUFEI_weight
        }
        return HistoryDimScaling_Weight_Result, se_user_history_QOE_vec, se_user_history_CHONGHE_vec, se_user_history_FUFEI_vec


# 目标产品embedding SE  (batch, 1, feature_num, feature_dim)->(batch, 1，feature_dim)
class TargetDimScalingLayer(nn.Module):
    def __init__(self, feature_dim, feature_category_num_dict, feature_column_dict):
        super(TargetDimScalingLayer, self).__init__()
        # SE注意力
        self.se_attention_QOE = SELayer(
            len(category_feature_num(feature_category_num_dict, feature_column_dict['history_QOE_continue'])) + len(
                category_feature_num(feature_category_num_dict, feature_column_dict['history_QOE_discrete'])))
        self.se_attention_CHONGHE = SELayer(
            len(category_feature_num(feature_category_num_dict, feature_column_dict['history_CHONGHE_continue'])) + len(
                category_feature_num(feature_category_num_dict, feature_column_dict['history_CHONGHE_discrete'])))
        self.se_attention_FUFEI = SELayer(
            len(category_feature_num(feature_category_num_dict, feature_column_dict['history_FUFEI_continue'])) + len(
                category_feature_num(feature_category_num_dict, feature_column_dict['history_FUFEI_discrete'])))

    def forward(self, target_QOE_vec, target_CHONGHE_vec, target_FUFEI_vec, mask=None):
        target_QOE_vec = target_QOE_vec.squeeze(dim=1)
        target_CHONGHE_vec = target_CHONGHE_vec.squeeze(dim=1)
        target_FUFEI_vec = target_FUFEI_vec.squeeze(dim=1)
        # 调整维度 (batch, 20, 200)->(batch,20,200,1)  (batch,feature_num.embedding_dim,1)
        target_QOE_vec = target_QOE_vec.unsqueeze(-1)
        target_CHONGHE_vec = target_CHONGHE_vec.unsqueeze(-1)
        target_FUFEI_vec = target_FUFEI_vec.unsqueeze(-1)

        # SE注意力  (batch, feature_dim, feature_num) ->SE->特征权重->(batch, feature_dim, feature_num)->转置-> 加权->(batch, 1，feature_dim)
        # 结果为权重，合并后向量，合并前向量
        se_QOE_weight, se_target_QOE_vec, _ = self.se_attention_QOE(target_QOE_vec)
        se_CHONGHE_weight, se_target_CHONGHE_vec, _ = self.se_attention_CHONGHE(target_CHONGHE_vec)
        se_FUFEI_weight, se_target_FUFEI_vec, _ = self.se_attention_FUFEI(target_FUFEI_vec)

        TargetDimScaling_Weight_Result = {
            'se_QOE_weight': se_QOE_weight,
            'se_CHONGHE_weight': se_CHONGHE_weight,
            'se_FUFEI_weight': se_FUFEI_weight
        }
        return TargetDimScaling_Weight_Result, se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec


# 用户历史与目标记录的attention层
class History_Target_AttentionLayer(nn.Module):
    def __init__(self, num_heads, feature_dim):
        super(History_Target_AttentionLayer, self).__init__()
        self.target_history_pay_feature_pianhao_QOE_layer = MultiHeadHistory_TargetAttention(num_heads, feature_dim)
        self.target_history_pay_feature_pianhao_CHONGHE_layer = MultiHeadHistory_TargetAttention(num_heads, feature_dim)
        self.target_history_pay_feature_pianhao_FUFEI_layer = MultiHeadHistory_TargetAttention(num_heads, feature_dim)

    def forward(self, se_user_history_pay_QOE_vec, se_user_history_pay_CHONGHE_vec, se_user_history_pay_FUFEI_vec,
                se_target_QOE_vec, se_target_CHONGHE_vec, se_target_FUFEI_vec):
        # 将QOE、CHONGHE、FUFEI分别做attention
        # 对目标特征求对历史特征的偏好   (batch, 1，feature_dim)输出
        target_history_pay_attention_QOE_weight, target_history_pay_attention_QOE_vec = self.target_history_pay_feature_pianhao_QOE_layer(
            se_target_QOE_vec, se_user_history_pay_QOE_vec, se_user_history_pay_QOE_vec)
        target_history_pay_attention_CHONGHE_weight, target_history_pay_attention_CHONGHE_vec = self.target_history_pay_feature_pianhao_CHONGHE_layer(
            se_target_CHONGHE_vec, se_user_history_pay_CHONGHE_vec, se_user_history_pay_CHONGHE_vec)
        target_history_pay_attention_FUFEI_weight, target_history_pay_attention_FUFEI_vec = self.target_history_pay_feature_pianhao_FUFEI_layer(
            se_target_FUFEI_vec, se_user_history_pay_FUFEI_vec, se_user_history_pay_FUFEI_vec)
        # CONCAT  (batch, 3，feature_dim)输出
        target_history_pay_attention_vec = torch.cat((target_history_pay_attention_QOE_vec,
                                                      target_history_pay_attention_CHONGHE_vec,
                                                      target_history_pay_attention_FUFEI_vec), dim=1)
        return target_history_pay_attention_vec, target_history_pay_attention_QOE_weight, target_history_pay_attention_CHONGHE_weight, target_history_pay_attention_FUFEI_weight

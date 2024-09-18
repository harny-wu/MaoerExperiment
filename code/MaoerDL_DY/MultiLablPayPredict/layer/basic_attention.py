import torch
from torch import nn

from config import max_history_len

# 多头自注意力
class MultiHeadSelfAttention(nn.Module):
    def __init__(self, num_heads, feature_dim, max_history_len):
        super(MultiHeadSelfAttention, self).__init__()
        self.num_heads = num_heads  #10
        self.feature_dim = feature_dim  #200
        self.head_dim = feature_dim // num_heads
        self.max_history_len = max_history_len

        self.WQ = nn.Linear(feature_dim, feature_dim)
        self.WK = nn.Linear(feature_dim, feature_dim)
        self.WV = nn.Linear(feature_dim, feature_dim)

    def forward(self, history_matrix, mask=None):
        batch_size, history_len, _ = history_matrix.size()

        Q = self.WQ(history_matrix)
        K = self.WK(history_matrix)
        V = self.WV(history_matrix)

        Q = Q.view(batch_size, history_len, self.num_heads, self.head_dim).permute(0, 2, 1,
                                                                                   3)  #(batch,num_heads,history_len,head_dim)
        K = K.view(batch_size, history_len, self.num_heads, self.head_dim).permute(0, 2, 1, 3)
        V = V.view(batch_size, history_len, self.num_heads, self.head_dim).permute(0, 2, 1, 3)

        attention_scores = torch.matmul(Q, K.permute(0, 1, 3, 2)) / (self.head_dim ** 0.5)

        if mask is not None:
            mask = mask.permute(0, 2, 1)  # 二、三维度互换  变为(batch, feature_num, history)
            temp_dim = mask.shape[1]
            #（样本数*特征数,历史数）
            mask = mask.reshape(-1, max_history_len)
            attention_scores = attention_scores.masked_fill(mask.unsqueeze(1).unsqueeze(2).bool(), float('-1e30'))  #()

        attention_weights = torch.softmax(attention_scores, dim=-1)  #shape(batch,head,history_len,history_len)
        #(batch,history_len,200)
        weighted_sum = torch.matmul(attention_weights, V).permute(0, 2, 1, 3).contiguous().view(batch_size, history_len,
                                                                                                self.feature_dim)
        # 计算加权平均
        weighted_avg_out = weighted_sum.mean(dim=1, keepdim=True)  # 在 history_len 维度上取平均，保持维度
        # 调整维度
        weighted_avg_out = weighted_avg_out.view(batch_size, 1, self.feature_dim)
        # print('weighted_sum',weighted_avg_out.shape)

        return attention_weights, weighted_avg_out, weighted_sum

# 注意力机制 关于用
class MultiHeadHistory_TargetAttention(nn.Module):
    def __init__(self, num_heads, embed_dim, dropout=0.1):
        super(MultiHeadHistory_TargetAttention, self).__init__()

        assert embed_dim % num_heads == 0, f"Embedding dimension ({embed_dim}) should be divisible by the number of heads ({num_heads})."

        self.embed_dim = embed_dim
        self.num_heads = num_heads
        self.head_dim = embed_dim // num_heads

        # 定义权重矩阵
        self.q_linear = nn.Linear(embed_dim, embed_dim)
        self.k_linear = nn.Linear(embed_dim, embed_dim)
        self.v_linear = nn.Linear(embed_dim, embed_dim)

        self.out_proj = nn.Linear(embed_dim, embed_dim)

        self.scaling = self.head_dim ** -0.5
        self.dropout = nn.Dropout(dropout)
        self.softmax = nn.Softmax(dim=-1)

    def forward(self, query, key, value, attn_mask=None):
        batch_size = query.size(0)
        # 进行线性投影并分离成多个头
        q = self.q_linear(query).view(batch_size, -1, self.num_heads, self.head_dim).transpose(1, 2)
        k = self.k_linear(key).view(batch_size, -1, self.num_heads, self.head_dim).transpose(1, 2)
        v = self.v_linear(value).view(batch_size, -1, self.num_heads, self.head_dim).transpose(1, 2)
        # 计算注意力得分
        scores = torch.matmul(q, k.transpose(-2, -1)) * self.scaling
        if attn_mask is not None:
            scores.masked_fill_(attn_mask.unsqueeze(1), float('-inf'))
        # 应用softmax函数
        attn_weights = self.softmax(scores)
        # 应用dropout
        attn_weights = self.dropout(attn_weights)
        # 进行值的加权求和
        context = torch.matmul(attn_weights, v).transpose(1, 2).contiguous().view(batch_size, -1, self.embed_dim)
        # 输出层的线性变换
        output = self.out_proj(context)
        return attn_weights, output
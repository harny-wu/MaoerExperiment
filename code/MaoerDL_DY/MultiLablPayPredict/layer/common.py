import math

from torch import nn

# 3.基础模型 embedding、attention
# 构建离散特征的embedding
def discrete_embedding(feature_category_num_dict, feature_column_name_list, embedding_dim):  # 输入特征取值大小的集合,特征数,维度
    # 创建一个列表来存储每个嵌入层
    embeddings = []
    for i in range(0, len(feature_column_name_list)):
        # print(feature_column_name_list[i], feature_category_num_dict[feature_column_name_list[i]])
        embedding_layer1 = nn.Embedding(feature_category_num_dict[feature_column_name_list[i]] + 2, embedding_dim)
        embeddings.append(embedding_layer1)
    #     print('embedding维度',feature_category_num_dict[feature_column_name_list[i]]+1)
    # print('本轮embedding层：',len(feature_column_name_list))
    return embeddings


# 全连接层 MLP
def dense_layer(in_features, out_features):
    # in_features=hidden_size,out_features=1
    return nn.Sequential(
        nn.Linear(in_features, out_features, bias=True),
        nn.ReLU())


# 全连接层 MLP
def dense_layer_noReLu(in_features, out_features):
    # in_features=hidden_size,out_features=1
    return nn.Sequential(
        nn.Linear(in_features, out_features, bias=True))


# 连续特征离散化
def continuous_embedding(num_continuous_features, out_features):
    continuous_embedding_layers = []
    for i in range(0, len(num_continuous_features)):
        num_continuous_feature = num_continuous_features[i]
        embedding_layer = dense_layer(1, out_features)
        continuous_embedding_layers.append(embedding_layer)
    return continuous_embedding_layers


# 根据全特征数量表及类别，得到类别下的对应特征数量  feature_column_name_list = feature_column_dict['user_info_continue']
def category_feature_num(feature_category_num_dict, feature_column_name_list):
    category_feature_num_list = []
    for i in range(len(feature_column_name_list)):
        category_feature_num_list.append(feature_category_num_dict[feature_column_name_list[i]])
    # print('category_feature_num',len(category_feature_num_list))
    return category_feature_num_list


# SE层中找到合适的reduction使channel // reduction得到整数
def find_reduction(channel, min_reduction=2, max_reduction=19):
    # 对于质数，直接取自己作为reduction  
    if is_prime(channel):
        return channel

        # 计算介于min_reduction和max_reduction之间的候选reduction值  
    candidates = [i for i in range(min_reduction, max_reduction + 1) if channel % i == 0]

    # 如果候选列表为空，则至少取2作为reduction  
    if not candidates:
        return min_reduction

        # 尝试找到最大的候选值，使得channel // reduction的结果尽可能大  
    reduction = max(candidates)

    return reduction


def is_prime(n):
    """判断一个数是否为质数"""
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True


# 输入(batch,feature_num,embedding_dim,1) ->(batch,feature_num,embedding_dim,1)->输出特征权重及权重乘后的(batch,embedding_dim) 
class SELayer(nn.Module):
    def __init__(self, channel, reduction=16):
        super(SELayer, self).__init__()
        self.avg_pool = nn.AdaptiveAvgPool2d(1)
        self.reduction = reduction
        self.reduction = find_reduction(channel)
        self.fc = nn.Sequential(
            nn.Linear(channel, channel // reduction, bias=False),
            nn.ReLU(inplace=True),
            nn.Linear(channel // reduction, channel, bias=False),
            nn.Sigmoid()
        )

    def forward(self, x):
        b, c, h, w = x.size()
        # print('b, c, h, w',b, c, h, w)
        y = self.avg_pool(x).view(b, c)
        # print('y',y)
        weight = self.fc(y).view(b, c, 1, 1)
        new_x = x * weight.expand_as(x)  # 利用了 PyTorch 的广播机制，使得张量 weight 被复制成与输入 x 相同的形状，然后进行逐元素相乘 
        # 加权平均 (batch, embedding_dim)
        weighted_avg_out_x = new_x.mean(dim=1, keepdim=True)  # 在 feature_num维度上取平均，保持维度
        # 调整维度
        weighted_avg_out_x = weighted_avg_out_x.view(b, 1, h, w)
        # 去除最后一维
        new_x = new_x.squeeze(dim=3)
        weighted_avg_out_x = weighted_avg_out_x.squeeze(dim=3)

        return weight, weighted_avg_out_x, new_x


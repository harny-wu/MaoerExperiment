# 分析数据相关性
# 对于数据集来说计算所有列属性与最后一列（决策属性）的相关性，数据要求：第一行为列名，最后一列为决策属性，需要先离散化并填充缺失值
import pandas as pd
from collections import Counter

# 读取数据表
# filepath = '/Users/ly/Desktop/工作/大论文/数据/猫耳特征提取/0101_0131_all_feature_involved_kmeans3/0101_0131_all_feature_involved_kmeans3.csv'
filepath = '/Users/ly/Desktop/工作/大论文/数据/量化方法实验/user_pay_4/user_pay_4.csv'
datadf = pd.read_csv(filepath)
# 缺失值替换
new_data=[]
for index, col in datadf.items():
    #从每列随机选取中一个值
    #ranValue=random.choice(col)
    #选取一列中出现次数最多的值  离散型
    newcol=list(col)
    count=Counter(newcol).most_common(2)
    if(count[0][0]==-1):
        ranValue=count[1][0]
    else:
        ranValue=count[0][0]
    #ranValue=max(set(newcol), key = newcol.count)
    #选取一列中的平均值 连续型
    #meanvalue = np.array(col)
    #ranValue=np.mean(meanvalue)
    rep = [ranValue if x==100000 or x==-1 else x for x in col]
    new_data.append(rep)
datadf=pd.DataFrame(new_data)
datadf=datadf.T

# 检查方差是否为零
zero_var_columns = datadf.columns[datadf.var() == 0]
print(zero_var_columns)
datadf = datadf.drop(zero_var_columns, axis=1)  # 剔除方差为零的列

# 提取属性列和决策属性列
attributes = datadf.columns[:-1]
decision_attribute = datadf.columns[-1]


# 计算相关性并输出结果
correlations = datadf[attributes].corrwith(datadf[decision_attribute])
result = pd.DataFrame({'属性列名': attributes, '相关性': correlations})
print(result)
high_corr_value = 0.2
high_correlation = result[(result['相关性'] >= high_corr_value ) | (result['相关性'] <= -high_corr_value )]
print('high_corr:')
print(high_correlation)
result.to_csv('data_corr_analysis_result.csv', index=False) # 行索引
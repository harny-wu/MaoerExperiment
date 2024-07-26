# MaoerExperiment
猫耳 互动体验质量量化与序列多目标预测实验 代码 + 数据 + 相关工具
    
    ├── README.md
    ├── code
     ├── MaoerDL_DY # dy 处理的深度学习代码
      ├── Dataset # 数据集
      ├── MultiLablPayPredict # 代码
     ├── MaoerDL_LY LY 处理的深度学习代码
      ├── Dataset
     ├── MaoerDataAanalysis # 数据分析脚本
      └── one- analysis- script
     ├── MaoerDataProcess # 数据处理脚本
      ├── FS
      ├── ML
      ├── SQL
     └── STCFS
         ├── FeatureSelection
    ├── data
    └── tool
        ├── discrete-by-BenjaminL # 离散化工具
        └── featureSelection-by-BenjaminL
            └── feature-selection-java - 6



MaoerDL_DY 使用

更换[maoer_timewindows_continue_discrete_feature_column.csv](code%2FMaoerDL_DY%2FDataset%2Fmaoer_timewindows_continue_discrete_feature_column.csv)为自己的特征选择结果

| 字段名称 | 描述 |
| :--: | :--: |
| DataSet | 数据集 |
| QoE | QOE独有特征 |
| CHONGHE | 重合特征 |
| FUFEI | 付费特征 |
| QOE_continue | QOE独有特征-连续特征 |
| QOE_discrete | QOE独有特征-离散特征 |

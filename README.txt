======================================================================
乳腺癌诊断 - 机器学习模型分析项目
Breast Cancer Diagnosis - Machine Learning Model Analysis
======================================================================

项目概述 (Project Overview)
----------------------------------------------------------------------
本项目使用Wisconsin乳腺癌数据集，对比了三种机器学习模型的诊断性能：
- Logistic Regression (glmnet)
- Random Forest (rf)
- Support Vector Machine (svmRadial)

项目结构 (Project Structure)
----------------------------------------------------------------------
BreastCancer_Project/
├── data/
│   └── data.csv                          # Wisconsin乳腺癌数据集 (569样本, 30特征)
│
├── scripts/
│   └── main.R                            # 完整分析代码
│
├── figures/                              # 所有可视化结果
│   ├── roc_curves.png                    # ROC曲线对比图
│   ├── glmnet_feature_importance.png     # 最佳模型特征重要性
│   └── shap_summary.png                  # 随机森林SHAP分析
│
├── models/
│   └── best_model.rds                    # 保存的最佳模型
│
└── README.txt                            # 本说明文件                                                                                                                          

关键实验结果 (Key Results)
----------------------------------------------------------------------
✓ 最佳模型: glmnet (Logistic Regression with Elastic Net)
  - 准确率 (Accuracy):     98.82%
  - 灵敏度 (Sensitivity):  98.41%
  - 特异度 (Specificity):  99.07%
  - F1分数 (F1-Score):     98.41%
  - AUC:                   0.991

✓ 其他模型性能:
  - Random Forest:    95.29% accuracy, AUC 0.991
  - SVM (RBF kernel): 95.29% accuracy, AUC 0.989

✓ 数据划分: 70% 训练集 (398样本) / 30% 测试集 (170样本)

✓ 交叉验证: 10-fold repeated cross-validation (3 repeats)

✓ 自定义阈值: 0.4 (针对不平衡数据优化)

如何运行代码 (How to Run)
----------------------------------------------------------------------
1. 确保安装了R及以下包:
   - caret
   - dplyr
   - pROC
   - fastshap

2. 在R或RStudio中运行:
   source("scripts/main.R")

3. 结果会保存在 figures/ 和 models/ 文件夹中

主要方法说明 (Methodology)
----------------------------------------------------------------------
数据预处理:
  - 移除ID和无关列
  - Z-score标准化 (均值0, 标准差1)
  - 转换诊断标签为因子 (B=良性, M=恶性)

模型训练:
  - 超参数网格搜索
  - 重复交叉验证优化
  - ROC曲线作为优化指标

特征解释:
  - glmnet: 回归系数绝对值
  - Random Forest: SHAP值分析
  - 展示非线性特征交互效应

关键发现 (Key Findings)
----------------------------------------------------------------------
最重要的诊断特征 (按重要性排序):
  1. radius_worst          (最大半径)
  2. concave.points_worst  (最大凹陷点数)
  3. texture_worst         (最大纹理)
  4. radius_se             (半径标准误)
  5. area_worst            (最大面积)

→ 所有"_worst"特征(最大值)对恶性肿瘤诊断最关键

文件用途 (File Usage)
----------------------------------------------------------------------
给队友的说明:
  - figures/ 文件夹包含所有需要的图表
  - 可以直接在报告中使用这些可视化结果
  - main.R 包含完整的可重现代码
  - 如需重新运行实验，运行时间约5-10分钟

最后更新: 2025年12月3日
======================================================================

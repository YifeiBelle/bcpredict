# 加载必需的包
library(caret)
library(dplyr)
library(pROC)

# 定义评估指标计算函数
calculate_metrics <- function(true_vals, predicted_vals) {
  if (length(true_vals) != length(predicted_vals)) {
    print("Error! Lengths of arrays do not match")
    return(0)
  }
  
  # 将因子转换为 0/1
  true_vals <- as.numeric(true_vals) - 1
  predicted_vals <- as.numeric(predicted_vals) - 1
  
  # 计算混淆矩阵的四个值
  TP <- sum(true_vals == 1 & predicted_vals == 1)
  TN <- sum(true_vals == 0 & predicted_vals == 0)
  FP <- sum(true_vals == 0 & predicted_vals == 1)
  FN <- sum(true_vals == 1 & predicted_vals == 0)
  
  cat("\tTP=", TP, " TN=", TN, " FP=", FP, " FN=", FN, "\n")
  cat("\ttotal=", TP + FP + TN + FN, "\n")
  
  # 计算指标
  accuracy <- (TP + TN) / (TP + TN + FP + FN)
  
  precision <- 0.0
  if ((TP + FP) > 0) {
    precision <- TP / (TP + FP)
  }
  
  recall <- 0.0
  if ((TP + FN) > 0) {
    recall <- TP / (TP + FN)
  }
  
  specificity <- 0.0
  if ((TN + FP) > 0) {
    specificity <- TN / (TN + FP)
  }
  
  f_score <- 0.0
  if ((precision + recall) > 0.0) {
    f_score <- 2.0 * (precision * recall) / (precision + recall)
  }
  
  cat("\taccuracy=", round(accuracy, 4), "  precision=", round(precision, 4), 
      "  recall=", round(recall, 4), "  specificity=", round(specificity, 4), 
      "  F-score=", round(f_score, 4), "\n")
  
  return(list(TP = TP, TN = TN, FP = FP, FN = FN, 
              accuracy = accuracy, precision = precision, 
              recall = recall, specificity = specificity, f_score = f_score))
}

# 读取数据
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)

# 数据预处理
if ("X" %in% names(data)) data$X <- NULL  # 安全删除
if ("id" %in% names(data)) data$id <- NULL  # 安全删除
data$diagnosis <- as.factor(data$diagnosis)  # 转换目标变量为因子

# 查看数据基本信息
cat("========== 数据信息 ==========\n")
cat("数据维度:", nrow(data), "样本 ×", ncol(data), "列\n")
cat("缺失值检查:\n")
print(colSums(is.na(data)))
cat("\n诊断结果分布:\n")
print(table(data$diagnosis))

# 划分训练集和测试集
set.seed(123)  # 设置随机种子保证结果可重复
train_index <- createDataPartition(data$diagnosis, p = 0.7, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]

cat("\n数据划分完成: 训练集", nrow(train_data), "样本, 测试集", nrow(test_data), "样本\n")

# 将预处理步骤(center, scale)放入train函数中，这样模型对象会包含预处理信息，不需要手动进行标准化，模型会自动处理
cat("预处理配置: 将在模型训练过程中自动进行标准化(center, scale)...\n\n")

# 训练多个模型进行对比
model_methods <- c("glmnet", "rf", "svmRadial")
models <- list()
results <- data.frame()

for (method in model_methods) {
  cat("正在训练模型:", method, "...\n")
  
  # 为每个模型设置网格搜索参数
  if (method == "glmnet") {
    tune_grid <- expand.grid(alpha = c(0.7, 0.8, 0.9, 1), 
                             lambda = c(0.0001, 0.0005, 0.001, 0.005, 0.01))
  } else if (method == "rf") {
    tune_grid <- expand.grid(mtry = c(5, 8, 10, 12, 15))
  } else if (method == "svmRadial") {
    tune_grid <- expand.grid(sigma = c(0.01, 0.02, 0.03, 0.05), 
                             C = c(5, 10, 15, 20))
  }
  
  # 训练模型(重复交叉验证 + 超参数调优)
  model <- train(diagnosis ~ ., 
                 data = train_data, 
                 method = method,
                 preProcess = c("center", "scale"), # 关键修改：将预处理集成到模型中
                 tuneGrid = tune_grid,
                 trControl = trainControl(
                   method = "repeatedcv", 
                   number = 10, 
                   repeats = 3,
                   classProbs = TRUE,
                   summaryFunction = twoClassSummary
                 ),
                 metric = "ROC",
                 verbose = FALSE)
  
  models[[method]] <- model
  
  # 在测试集上进行预测
  pred_prob <- predict(model, newdata = test_data, type = "prob")[, 2]
  
  # 使用0.4作为阈值进行分类
  predictions <- ifelse(pred_prob >= 0.4, "M", "B")
  predictions <- factor(predictions, levels = levels(test_data$diagnosis))
  
  # 关键修改：指定 positive = "M" 以正确计算敏感度等指标
  cm <- confusionMatrix(predictions, test_data$diagnosis, positive = "M")
  
  # 计算ROC曲线的AUC值
  roc_obj <- roc(test_data$diagnosis, pred_prob, quiet = TRUE)
  
  # 计算F1分数
  precision <- cm$byClass['Pos Pred Value']
  recall <- cm$byClass['Sensitivity']
  f1 <- 2 * (precision * recall) / (precision + recall)
  
  # 保存结果
  results <- rbind(results, data.frame(
    Model = method,
    Accuracy = round(cm$overall['Accuracy'], 4),
    Sensitivity = round(cm$byClass['Sensitivity'], 4),
    Specificity = round(cm$byClass['Specificity'], 4),
    Precision = round(precision, 4),
    F1 = round(f1, 4),
    AUC = round(as.numeric(roc_obj$auc), 4)
  ))
}

# 重置行名
rownames(results) <- NULL

# 显示对比结果
print(results[order(results$Accuracy, decreasing = TRUE), ])

# 选择最佳模型
best_idx <- which.max(results$Accuracy)
best_model_name <- results$Model[best_idx]

cat("\n最佳模型:", best_model_name, "\n")
cat("准确率(Accuracy):", results$Accuracy[best_idx], "\n")
cat("精准率(Precision):", results$Precision[best_idx], "\n")

cat("灵敏度(Sensitivity):", results$Sensitivity[best_idx], "\n")
cat("特异性(Specificity):", results$Specificity[best_idx], "\n")
cat("F1分数:", results$F1[best_idx], "\n")
cat("AUC:", results$AUC[best_idx], "\n")

# 绘制ROC曲线对比图
cat("\n========== 绘制ROC曲线 ==========\n")
if (!dir.exists("figures")) {
  dir.create("figures")
}
png("figures/roc_curves.png", width = 800, height = 600)
plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1),
     xlab = "False Positive Rate (1 - Specificity)", 
     ylab = "True Positive Rate (Sensitivity)",
     main = "ROC Curves Comparison")
abline(0, 1, lty = 2, col = "gray")

colors <- c("blue", "red", "green")
for (i in 1:length(model_methods)) {
  method <- model_methods[i]
  pred_prob <- predict(models[[method]], newdata = test_data, type = "prob")[, 2]
  roc_obj <- roc(test_data$diagnosis, pred_prob, quiet = TRUE)
  plot(roc_obj, add = TRUE, col = colors[i], lwd = 2)
}

legend("bottomright", legend = paste0(model_methods, " (AUC=", round(results$AUC, 3), ")"),
       col = colors, lwd = 2, cex = 0.8)
dev.off()
cat("ROC曲线已保存至: figures/roc_curves.png\n")

# 显示最佳模型的结果
cat("\n========== 最佳模型详细评估 ==========\n")
best_predictions <- predict(models[[best_model_name]], newdata = test_data, type = "prob")[, 2]
best_predictions <- ifelse(best_predictions >= 0.4, "M", "B")
best_predictions <- factor(best_predictions, levels = levels(test_data$diagnosis))
cat("基于混淆矩阵的指标计算:\n")
metrics <- calculate_metrics(test_data$diagnosis, best_predictions)

cat("\ncaret包的详细混淆矩阵:\n")
best_cm <- confusionMatrix(best_predictions, test_data$diagnosis, positive = "M")
print(best_cm)

# 显示所有模型的特征重要性
cat("\n========== 特征重要性分析 ==========\n")

for (method in model_methods) {
  cat("\n", method, "模型的重要特征Top10:\n")
  tryCatch({
    importance <- varImp(models[[method]])
    print(head(importance$importance, 10))
  }, error = function(e) {
    cat("  该模型暂不支持特征重要性提取\n")
  })
}

# 单独为最佳模型(glmnet)绘制特征重要性图
if (best_model_name == "glmnet") {
  cat("\n========== 最佳模型特征系数可视化 ==========\n")
  
  # 提取glmnet系数
  coef_matrix <- coef(models[[best_model_name]]$finalModel, 
                      s = models[[best_model_name]]$finalModel$lambdaOpt)
  feature_coef <- as.vector(coef_matrix)[-1]  # 去掉截距
  names(feature_coef) <- rownames(coef_matrix)[-1]
  
  # 按绝对值排序
  feature_importance <- abs(feature_coef)
  feature_importance <- sort(feature_importance, decreasing = TRUE)
  
  # 绘制特征重要性图
  png("figures/glmnet_feature_importance.png", width = 800, height = 600)
  par(mar = c(5, 10, 4, 2))
  top_features <- head(feature_importance, 15)
  barplot(rev(top_features), horiz = TRUE, las = 1,
          main = "Feature Importance (glmnet - Best Model)",
          xlab = "Absolute Coefficient Value",
          col = "coral")
  dev.off()
  cat("glmnet特征重要性图已保存至: figures/glmnet_feature_importance.png\n")
  
  cat("\nTop 10 最重要特征:\n")
  print(head(feature_importance, 10))
}

# SHAP值分析（针对随机森林模型展示非线性交互效应）
cat("\n========== SHAP值分析 (Random Forest) ==========\n")
if (requireNamespace("fastshap", quietly = TRUE)) {
  library(fastshap)
  
  cat("正在计算SHAP值（可能需要几分钟）...\n")
  
  # 定义预测函数
  predict_function <- function(model, newdata) {
    predict(model, newdata, type = "prob")[, 2]
  }
  
  # 计算SHAP值（随机森林模型）
  shap_values <- explain(models[["rf"]], 
                         X = as.data.frame(train_data[, -1]),
                         pred_wrapper = predict_function,
                         nsim = 50)
  
  # 计算每个特征的平均绝对SHAP值
  shap_importance <- colMeans(abs(shap_values))
  shap_importance <- sort(shap_importance, decreasing = TRUE)
  
  # 绘制SHAP摘要图
  png("figures/shap_summary.png", width = 800, height = 600)
  par(mar = c(5, 10, 4, 2))
  top_features <- head(shap_importance, 15)
  barplot(rev(top_features), horiz = TRUE, las = 1,
          main = "SHAP Feature Importance (Random Forest)",
          xlab = "Mean |SHAP value|",
          col = "steelblue")
  dev.off()
  cat("SHAP图已保存至: figures/shap_summary.png\n")
  cat("\n注: 虽然glmnet是最佳模型，但我们对RF进行SHAP分析以展示非线性特征交互效应\n")
} else {
  cat("fastshap包未安装，跳过SHAP分析\n")
  cat("可以安装fastshap包: install.packages('fastshap')\n")
}

# 保存最佳模型供后续使用
if (!dir.exists("models")) {
  dir.create("models")
}
saveRDS(models[[best_model_name]], "models/best_model.rds")
cat("\n模型已保存至: models/best_model.rds\n")
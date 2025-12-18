#!/usr/bin/env Rscript
# 验证模型计算结果是否与R package中的一样

library(bcpredict)
library(caret)
library(dplyr)

cat("=== 模型验证脚本 ===\n")

# 1. 加载数据
data_file <- "data/data.csv"
if (!file.exists(data_file)) {
  stop("数据文件不存在: ", data_file)
}
data <- read.csv(data_file, stringsAsFactors = FALSE)
if ("X" %in% names(data)) data$X <- NULL
if ("id" %in% names(data)) data$id <- NULL
data$diagnosis <- as.factor(data$diagnosis)

cat("数据维度:", nrow(data), "样本 ×", ncol(data), "列\n")
cat("诊断分布:\n")
print(table(data$diagnosis))

# 2. 划分训练集和测试集（与原始脚本相同）
set.seed(123)
train_index <- createDataPartition(data$diagnosis, p = 0.7, list = FALSE)
train_data <- data[train_index, ]
test_data <- data[-train_index, ]

cat("\n测试集大小:", nrow(test_data), "样本\n")

# 3. 使用 bcpredict 包进行预测
cat("\n--- 使用 bcpredict::predict_diagnosis 进行预测 ---\n")
pred_package <- predict_diagnosis(test_data)
cat("前6个预测:", head(as.character(pred_package)), "\n")
cat("预测分布:\n")
print(table(pred_package))

# 4. 使用保存的模型进行预测（如果存在）
model_file <- "models/best_model.rds"
if (file.exists(model_file)) {
  cat("\n--- 使用保存的模型 (best_model.rds) 进行预测 ---\n")
  best_model <- readRDS(model_file)
  # 注意：保存的模型是 caret 对象，需要预处理
  # 使用相同的预处理（已在模型中集成）
  pred_saved <- predict(best_model, newdata = test_data, type = "prob")[, "M"]
  pred_saved_class <- ifelse(pred_saved >= 0.4, "M", "B")
  pred_saved_class <- factor(pred_saved_class, levels = c("B", "M"))
  cat("前6个预测:", head(as.character(pred_saved_class)), "\n")
  cat("预测分布:\n")
  print(table(pred_saved_class))
  
  # 比较包预测与保存模型预测
  cat("\n--- 比较包预测与保存模型预测 ---\n")
  agreement <- all(pred_package == pred_saved_class, na.rm = TRUE)
  if (agreement) {
    cat("✅ 预测完全一致\n")
  } else {
    cat("❌ 预测不一致\n")
    mismatch <- which(pred_package != pred_saved_class)
    cat("  不一致的样本数量:", length(mismatch), "\n")
    if (length(mismatch) <= 10) {
      cat("  不一致的索引:", mismatch, "\n")
    }
  }
} else {
  cat("模型文件不存在，跳过保存模型比较。\n")
}

# 5. 计算测试集上的性能指标（与 README 比较）
cat("\n--- 测试集性能指标 ---\n")
true_labels <- test_data$diagnosis
conf_matrix <- confusionMatrix(pred_package, true_labels, positive = "M")
print(conf_matrix)

accuracy <- conf_matrix$overall["Accuracy"]
sensitivity <- conf_matrix$byClass["Sensitivity"]
specificity <- conf_matrix$byClass["Specificity"]
precision <- conf_matrix$byClass["Pos Pred Value"]
f1 <- 2 * (precision * sensitivity) / (precision + sensitivity)

cat(sprintf("准确率 (Accuracy): %.4f\n", accuracy))
cat(sprintf("灵敏度 (Sensitivity): %.4f\n", sensitivity))
cat(sprintf("特异性 (Specificity): %.4f\n", specificity))
cat(sprintf("精确率 (Precision): %.4f\n", precision))
cat(sprintf("F1 分数: %.4f\n", f1))

# 计算 AUC
pred_prob <- predict(best_model, newdata = test_data, type = "prob")[, "M"]
roc_obj <- pROC::roc(true_labels, pred_prob, quiet = TRUE)
auc_val <- pROC::auc(roc_obj)
cat(sprintf("AUC: %.4f\n", auc_val))

# 6. 与 README 中报告的指标比较
cat("\n--- 与 README 中报告的指标比较 ---\n")
readme_metrics <- list(
  accuracy = 0.9882,
  sensitivity = 0.9841,
  specificity = 0.9907,
  precision = NA,  # 未明确给出
  f1 = 0.9841,
  auc = 0.9912
)

cat("README 指标:\n")
cat(sprintf("  准确率: %.4f\n", readme_metrics$accuracy))
cat(sprintf("  灵敏度: %.4f\n", readme_metrics$sensitivity))
cat(sprintf("  特异性: %.4f\n", readme_metrics$specificity))
cat(sprintf("  F1: %.4f\n", readme_metrics$f1))
cat(sprintf("  AUC: %.4f\n", readme_metrics$auc))

cat("\n差异 (当前 - README):\n")
cat(sprintf("  准确率: %+.4f\n", accuracy - readme_metrics$accuracy))
cat(sprintf("  灵敏度: %+.4f\n", sensitivity - readme_metrics$sensitivity))
cat(sprintf("  特异性: %+.4f\n", specificity - readme_metrics$specificity))
cat(sprintf("  F1: %+.4f\n", f1 - readme_metrics$f1))
cat(sprintf("  AUC: %+.4f\n", auc_val - readme_metrics$auc))

# 7. 检查是否在容差范围内一致
tolerance <- 0.005
if (abs(accuracy - readme_metrics$accuracy) < tolerance &&
    abs(sensitivity - readme_metrics$sensitivity) < tolerance &&
    abs(specificity - readme_metrics$specificity) < tolerance &&
    abs(auc_val - readme_metrics$auc) < tolerance) {
  cat("\n✅ 所有指标在容差范围内与 README 一致。\n")
} else {
  cat("\n⚠️  某些指标超出容差范围，请检查。\n")
}

cat("\n=== 验证完成 ===\n")
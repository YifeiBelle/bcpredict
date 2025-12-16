# 准备包数据：加载模型和预处理对象
library(caret)

# 加载原始数据以计算预处理参数
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)
data$X <- NULL
data$id <- NULL
data$diagnosis <- as.factor(data$diagnosis)

# 划分训练集（与原始脚本相同）
set.seed(123)
train_index <- createDataPartition(data$diagnosis, p = 0.7, list = FALSE)
train_data <- data[train_index, ]

# 计算预处理对象（中心化 + 缩放）
preProc <- preProcess(train_data[, -1], method = c("center", "scale"))

# 加载最佳模型
best_model <- readRDS("models/best_model.rds")

# 保存为内部数据
usethis::use_data(best_model, preProc, internal = TRUE, overwrite = TRUE)
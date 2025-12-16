# 创建 sysdata.rda
library(caret)

cat("Loading data...\n")
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)
data$X <- NULL
data$id <- NULL
data$diagnosis <- as.factor(data$diagnosis)

cat("Splitting...\n")
set.seed(123)
train_index <- createDataPartition(data$diagnosis, p = 0.7, list = FALSE)
train_data <- data[train_index, ]

cat("Creating preProc...\n")
preProc <- preProcess(train_data[, -1], method = c("center", "scale"))

cat("Loading model...\n")
best_model <- readRDS("models/best_model.rds")

cat("Saving to bcpredict/R/sysdata.rda...\n")
save(best_model, preProc, file = "bcpredict/R/sysdata.rda", compress = "xz")

cat("Done.\n")
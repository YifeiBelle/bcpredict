# Create toy dataset for bcpredict package
library(caret)

# Load original data
data <- read.csv("../data/data.csv", stringsAsFactors = FALSE)
data$X <- NULL
data$id <- NULL
data$diagnosis <- as.factor(data$diagnosis)

# Take a small random sample (5 rows) for toy data
set.seed(42)
toy_data <- data[sample(nrow(data), 5), ]

# Remove the diagnosis column (since we want only features for prediction)
toy_data_features <- toy_data[, -1]

# Save as package data in data/ directory
save(toy_data_features, file = "data/toy_data_features.rda", compress = "xz")

cat("Toy data created and saved.\n")
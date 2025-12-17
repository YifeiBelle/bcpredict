# Create toy data by sampling from the original Wisconsin Breast Cancer dataset
original_data <- read.csv("../data/data.csv", stringsAsFactors = FALSE)
# Remove unnecessary columns
original_data$X <- NULL
original_data$id <- NULL
# Keep only features (remove diagnosis column)
features <- original_data[, -1]
# Take a random sample of 30 rows
set.seed(123)
toy_data_features <- features[sample(nrow(features), 30), ]
# Save to package data directory
save(toy_data_features, file = "data/toy_data_features.rda", compress = "xz")
cat("Toy data created with", nrow(toy_data_features), "rows.\n")
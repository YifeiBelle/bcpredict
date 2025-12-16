# Create toy data
data <- read.csv("data/data.csv", stringsAsFactors = FALSE)
data$X <- NULL
data$id <- NULL
# Keep only features (remove diagnosis column)
features <- data[, -1]
# Take first 5 rows
toy_data_features <- features[1:5, ]
save(toy_data_features, file = "data/toy_data_features.rda", compress = "xz")
cat("Toy data saved.\n")
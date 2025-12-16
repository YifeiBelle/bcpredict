library(devtools)
load_all("bcpredict", quiet = FALSE)
data(toy_data_features, package = "bcpredict")
cat("Data loaded, dimensions:", dim(toy_data_features), "\n")
cat("First row:\n")
print(head(toy_data_features, 1))

result <- try(predict_diagnosis(toy_data_features), silent = TRUE)
if (inherits(result, "try-error")) {
  cat("Error:", as.character(result), "\n")
} else {
  cat("Predictions:", result, "\n")
  cat("Table:\n")
  print(table(result))
}
cat("Testing predict_diagnosis with getS3method...\n")
library(devtools)
load_all("bcpredict", quiet = FALSE)

# Load toy data
data(toy_data_features, package = "bcpredict")
cat("Loaded toy data, rows:", nrow(toy_data_features), "\n")

# Predict
tryCatch({
  predictions <- predict_diagnosis(toy_data_features)
  cat("Success! Predictions length:", length(predictions), "\n")
  print(table(predictions))
}, error = function(e) {
  cat("Error:", e$message, "\n")
  traceback()
})
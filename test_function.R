# Load the package
library(bcpredict)

# Check if internal objects exist
if (exists("best_model", envir = asNamespace("bcpredict"))) {
  cat("best_model found\n")
} else {
  cat("best_model NOT found\n")
}

if (exists("preProc", envir = asNamespace("bcpredict"))) {
  cat("preProc found\n")
} else {
  cat("preProc NOT found\n")
}

# Load toy data
data(toy_data)
cat("Toy data dimensions:", dim(toy_data), "\n")

# Test prediction
pred <- predict_diagnosis(toy_data)
cat("Predictions length:", length(pred), "\n")
cat("First few predictions:", head(pred), "\n")
cat("Levels:", levels(pred), "\n")
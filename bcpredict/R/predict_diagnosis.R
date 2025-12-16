#' Predict Breast Cancer Diagnosis
#'
#' This function predicts whether a breast cancer tumor is benign (B) or malignant (M)
#' based on 30 numeric features. The prediction uses a trained glmnet model with
#' a threshold of 0.4 for classification.
#'
#' @param newdata A data.frame containing the 30 feature columns. The column names
#'   must match the training data features (see details). Extra columns are ignored.
#' @return A factor vector of predictions with levels "B" (benign) and "M" (malignant).
#' @details
#' The required feature columns are:
#' radius_mean, texture_mean, perimeter_mean, area_mean, smoothness_mean,
#' compactness_mean, concavity_mean, concave.points_mean, symmetry_mean,
#' fractal_dimension_mean, radius_se, texture_se, perimeter_se, area_se,
#' smoothness_se, compactness_se, concavity_se, concave.points_se, symmetry_se,
#' fractal_dimension_se, radius_worst, texture_worst, perimeter_worst, area_worst,
#' smoothness_worst, compactness_worst, concavity_worst, concave.points_worst,
#' symmetry_worst, fractal_dimension_worst.
#'
#' The function internally applies the same centering and scaling as used during training.
#' @examples
#' \dontrun{
#' # Load example data (toy dataset)
#' data(toy_data)
#' predictions <- predict_diagnosis(toy_data)
#' }
#' @export
predict_diagnosis <- function(newdata) {
  # Internal model and preprocessing objects are loaded via sysdata.rda
  # They are available in the package namespace.
  # If they are missing, the package installation is broken.
  
  # Ensure newdata is a data.frame
  if (!is.data.frame(newdata)) {
    newdata <- as.data.frame(newdata)
  }

  # Select only the relevant feature columns (ignore extra columns)
  required_features <- c(
    "radius_mean", "texture_mean", "perimeter_mean", "area_mean",
    "smoothness_mean", "compactness_mean", "concavity_mean",
    "concave.points_mean", "symmetry_mean", "fractal_dimension_mean",
    "radius_se", "texture_se", "perimeter_se", "area_se",
    "smoothness_se", "compactness_se", "concavity_se",
    "concave.points_se", "symmetry_se", "fractal_dimension_se",
    "radius_worst", "texture_worst", "perimeter_worst", "area_worst",
    "smoothness_worst", "compactness_worst", "concavity_worst",
    "concave.points_worst", "symmetry_worst", "fractal_dimension_worst"
  )

  # Check for missing columns
  missing <- setdiff(required_features, colnames(newdata))
  if (length(missing) > 0) {
    stop("The following required columns are missing: ",
         paste(missing, collapse = ", "))
  }

  # Subset to required columns (in correct order)
  newdata <- newdata[, required_features, drop = FALSE]

  # Apply preprocessing (centering and scaling)
  # Use caret's predict method for preProcess objects
  newdata_scaled <- caret::predict.preProcess(preProc, newdata)

  # Predict probabilities using the caret model
  # The model returns probabilities for class "M" (second column)
  prob_m <- predict(best_model, newdata = newdata_scaled, type = "prob")[, "M"]

  # Apply threshold 0.4 (as in the original script)
  predictions <- ifelse(prob_m >= 0.4, "M", "B")

  # Convert to factor with same levels as training
  factor(predictions, levels = c("B", "M"))
}

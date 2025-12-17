#' Predict Breast Cancer Diagnosis
#'
#' @description
#' Predicts whether a breast cancer tumor is benign (B) or malignant (M)
#' based on 30 numeric features from the Wisconsin Breast Cancer Diagnostic dataset.
#' The prediction uses a trained glmnet (elastic net) model with a threshold of 0.4
#' for classification. The model was selected as the best performer among glmnet,
#' random forest, and SVM with radial kernel in the original analysis.
#'
#' @param newdata A data.frame containing the 30 feature columns. The column names
#'   must match the training data features (see details). Extra columns are ignored.
#'   All features must be numeric.
#'
#' @return A factor vector of predictions with levels "B" (benign) and "M" (malignant).
#'
#' @details
#' The function expects the following 30 features in the exact same order as they
#' appear in the training data:
#' \itemize{
#'   \item radius_mean, texture_mean, perimeter_mean, area_mean, smoothness_mean,
#'   \item compactness_mean, concavity_mean, concave.points_mean, symmetry_mean,
#'   \item fractal_dimension_mean,
#'   \item radius_se, texture_se, perimeter_se, area_se, smoothness_se,
#'   \item compactness_se, concavity_se, concave.points_se, symmetry_se,
#'   \item fractal_dimension_se,
#'   \item radius_worst, texture_worst, perimeter_worst, area_worst,
#'   \item smoothness_worst, compactness_worst, concavity_worst,
#'   \item concave.points_worst, symmetry_worst, fractal_dimension_worst.
#' }
#'
#' The function internally applies the same centering and scaling (mean‑zero,
#' unit‑variance) that was used during model training. Missing columns will cause
#' an error.
#'
#' The underlying model is a glmnet classifier trained with 10‑fold repeated
#' cross‑validation (3 repeats) and optimized for ROC AUC. The classification
#' threshold is set to 0.4, which was found to balance sensitivity and specificity
#' on the original test set.
#'
#' @note
#' The model and preprocessing objects are stored internally in the package
#' (via \code{sysdata.rda}). If the package installation is corrupted, the function
#' will fail with an error about missing objects.
#'
#' @examples
#' # Load the included toy dataset (a subset of the original data)
#' data(toy_data_features)
#' # Predict diagnosis
#' predictions <- predict_diagnosis(toy_data_features)
#' # View first few predictions
#' head(predictions)
#' # Count of benign vs malignant
#' table(predictions)
#'
#' @seealso
#' \code{caret::train} for model training, \code{glmnet::glmnet} for
#' the underlying algorithm.
#'
#' @references
#' Wisconsin Breast Cancer Diagnostic Data Set. Original donors: Dr. William H. Wolberg,
#' W. Nick Street, Olvi L. Mangasarian. UCI Machine Learning Repository.
#'
#' The analysis that produced this model is documented in the project repository:
#' \url{https://github.com/YifeiBelle/bcpredict}.
#'
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
  # Get the S3 method for predict.preProcess from caret namespace
  predict_preprocess <- getS3method("predict", "preProcess", envir = asNamespace("caret"))
  newdata_scaled <- predict_preprocess(preProc, newdata)

  # Predict probabilities using the caret model
  # The model returns probabilities for class "M" (second column)
  prob_m <- predict(best_model, newdata = newdata_scaled, type = "prob")[, "M"]

  # Apply threshold 0.4 (as in the original script)
  predictions <- ifelse(prob_m >= 0.4, "M", "B")

  # Convert to factor with same levels as training
  factor(predictions, levels = c("B", "M"))
}

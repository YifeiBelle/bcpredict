#' Visualize Toy Data Features
#'
#' @description
#' Generates exploratory plots for the toy dataset (or any data frame with the same 30 features).
#' Four plot types are supported: histogram (distribution of each feature),
#' correlation heatmap, PCA scatter plot, and feature importance (coefficients of the trained glmnet model).
#'
#' @param data A data.frame containing the 30 feature columns. If NULL (default),
#'   the built-in \code{toy_data_features} dataset is used.
#' @param type Character string specifying the type of plot:
#'   \itemize{
#'     \item "histogram": Histograms of each feature (30 subplots).
#'     \item "correlation": Heatmap of pairwise Pearson correlations.
#'     \item "pca": Scatter plot of the first two principal components.
#'     \item "importance": Bar plot of the absolute coefficients of the trained glmnet model (the best model from the original analysis).
#'   }
#' @param ... Additional graphical parameters passed to the underlying plot functions.
#'
#' @return Invisibly returns the plotted object (a list for PCA, a matrix for correlation,
#'   a numeric vector for importance, or NULL for histogram). The primary purpose is side‑effect plotting.
#'
#' @details
#' For "histogram", the function sets up a 6×5 layout and draws a histogram for each
#' of the 30 features. The x‑axis is labeled with the feature name.
#'
#' For "correlation", the correlation matrix is computed with \code{cor()} and plotted
#' using \code{image()} with a color gradient from blue (‑1) to red (+1). The diagonal
#' is omitted (set to NA) to improve readability.
#'
#' For "pca", principal component analysis is performed via \code{prcomp()} (centered
#' but not scaled, because the features are already on similar scales). The first two
#' PCs are plotted as a scatter plot. Points are colored by their row index.
#'
#' For "importance", the function extracts the coefficients of the trained glmnet model
#' (stored internally in the package) and plots their absolute values as a horizontal bar plot.
#' This visualization matches the feature importance plot shown in the original analysis.
#'
#' @note
#' The function is intended for quick exploratory visualization of the toy dataset.
#' For publication‑quality graphics, consider using dedicated plotting packages
#' (e.g., \code{ggplot2}).
#'
#' @examples
#' # Load the toy dataset
#' data(toy_data_features)
#' # Histogram of all features (may be slow due to many subplots)
#' \dontrun{
#' visualize_toy_data(type = "histogram")
#' }
#' # Correlation heatmap
#' visualize_toy_data(type = "correlation")
#' # PCA scatter plot
#' visualize_toy_data(type = "pca")
#' # Feature importance (coefficients of the trained glmnet model)
#' visualize_toy_data(type = "importance")
#'
#' @export
visualize_toy_data <- function(data = NULL, type = c("histogram", "correlation", "pca", "importance"), ...) {
  type <- match.arg(type)

  # If no data provided, use the built‑in toy dataset
  if (is.null(data)) {
    if (!requireNamespace("bcpredict", quietly = TRUE)) {
      stop("Package 'bcpredict' must be installed to use the built‑in toy dataset.")
    }
    # Load toy_data_features from the package's data directory
    data_name <- "toy_data_features"
    if (!exists(data_name, envir = globalenv())) {
      data(list = data_name, package = "bcpredict", envir = environment())
    }
    data <- get(data_name, envir = environment())
  }

  # Ensure data is a data.frame with at least one row
  if (!is.data.frame(data) || nrow(data) == 0) {
    stop("'data' must be a non‑empty data.frame.")
  }

  # Select only the 30 standard features (if extra columns present)
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
  missing <- setdiff(required_features, colnames(data))
  if (length(missing) > 0) {
    warning("The following required columns are missing: ",
            paste(missing, collapse = ", "),
            ". Using available columns only.")
    required_features <- intersect(required_features, colnames(data))
  }

  data <- data[, required_features, drop = FALSE]

  # Dispatch to the appropriate plotting routine
  switch(type,
    histogram = .visualize_histogram(data, ...),
    correlation = .visualize_correlation(data, ...),
    pca = .visualize_pca(data, ...),
    importance = .visualize_importance(data, ...)
  )
}

# Internal helper: histogram of each feature
.visualize_histogram <- function(data, ...) {
  nfeat <- ncol(data)
  # Set up a 6×5 layout (30 plots)
  oldpar <- par(mfrow = c(6, 5), mar = c(3, 3, 1, 1), mgp = c(1.5, 0.5, 0))
  on.exit(par(oldpar))

  for (i in seq_len(nfeat)) {
    hist(data[[i]],
         main = "",
         xlab = colnames(data)[i],
         col = "lightblue",
         border = "white",
         ...)
  }
  invisible(NULL)
}

# Internal helper: correlation heatmap
.visualize_correlation <- function(data, ...) {
  cor_mat <- cor(data, use = "pairwise.complete.obs")
  # Set diagonal to NA to improve color contrast
  diag(cor_mat) <- NA

  # Color palette from blue (negative) to white (zero) to red (positive)
  col_pal <- colorRampPalette(c("blue", "white", "red"))(100)

  # Plot
  image(seq_len(ncol(cor_mat)), seq_len(nrow(cor_mat)), cor_mat,
        col = col_pal,
        xlab = "Feature index", ylab = "Feature index",
        main = "Pairwise Pearson correlation",
        axes = FALSE, ...)
  axis(1, at = seq_len(ncol(cor_mat)), labels = colnames(data), las = 2, cex.axis = 0.7)
  axis(2, at = seq_len(nrow(cor_mat)), labels = colnames(data), las = 1, cex.axis = 0.7)
  box()

  # Add a color legend
  legend("topright",
         legend = c("-1", "0", "+1"),
         fill = c("blue", "white", "red"),
         bty = "n")

  invisible(cor_mat)
}

# Internal helper: PCA scatter plot
.visualize_pca <- function(data, ...) {
  # Center the data (no scaling, as features are already on similar scales)
  pca <- prcomp(data, center = TRUE, scale. = FALSE)

  # Proportion of variance explained
  var_exp <- round(100 * pca$sdev^2 / sum(pca$sdev^2), 1)

  # Plot first two PCs
  plot(pca$x[, 1], pca$x[, 2],
       xlab = paste0("PC1 (", var_exp[1], "%)"),
       ylab = paste0("PC2 (", var_exp[2], "%)"),
       main = "PCA of toy data",
       pch = 19, col = rgb(0.2, 0.4, 0.8, 0.7),
       ...)
  grid()

  invisible(pca)
}

# Internal helper: feature importance (coefficients of the trained glmnet model)
.visualize_importance <- function(data, ...) {
  # The internal model objects are stored in the package namespace
  # They are loaded via sysdata.rda and are available as 'best_model' and 'preProc'
  # We need to ensure they are accessible.
  if (!exists("best_model", envir = parent.env(environment()))) {
    # Try to load from the package's internal data
    # This is a fallback; normally they are already present when the package is loaded.
    ns <- asNamespace("bcpredict")
    if (exists("best_model", envir = ns)) {
      best_model <- get("best_model", envir = ns)
    } else {
      stop("Internal model object 'best_model' not found. The package may be corrupted.")
    }
  } else {
    best_model <- get("best_model", envir = parent.env(environment()))
  }

  # Extract coefficients from the glmnet model (caret wrapper)
  # The finalModel is a glmnet object
  coef_matrix <- coef(best_model$finalModel, s = best_model$finalModel$lambdaOpt)
  feature_coef <- as.vector(coef_matrix)[-1]  # remove intercept
  names(feature_coef) <- rownames(coef_matrix)[-1]

  # Absolute values for importance
  importance <- abs(feature_coef)
  importance <- sort(importance, decreasing = TRUE)

  # Keep only the top 15 features for readability
  top_n <- min(15, length(importance))
  top_importance <- head(importance, top_n)

  # Horizontal bar plot
  oldpar <- par(mar = c(5, 10, 4, 2))
  on.exit(par(oldpar))
  barplot(rev(top_importance),
          horiz = TRUE,
          las = 1,
          main = "Feature Importance (glmnet - Best Model)",
          xlab = "Absolute Coefficient Value",
          col = "coral",
          ...)
  box()

  invisible(importance)
}
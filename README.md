# bcpredict

<!-- badges: start -->
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

An R package for predicting breast cancer diagnosis (benign vs malignant) based on 30 numeric features using a trained glmnet model.

## Installation

You can install the development version from [GitHub](https://github.com/YifeiBelle/bcpredict) with:

```r
# Install remotes if not already installed
# install.packages("remotes")
remotes::install_github("YifeiBelle/bcpredict")
```

## Usage

Load the package and use the `predict_diagnosis` function:

```r
library(bcpredict)

# Load the included toy dataset
data(toy_data_features)

# Predict diagnosis
predictions <- predict_diagnosis(toy_data_features)
print(predictions)
```

The function returns a factor vector with levels "B" (benign) and "M" (malignant).

## Model Details

The model is a glmnet (elastic net) classifier trained on the Wisconsin Breast Cancer Diagnostic dataset. Preprocessing includes centering and scaling of features. The classification threshold is set to 0.4 (as per the original training script).

### Performance Metrics (on test set)

- **Accuracy**: 0.9825
- **Sensitivity (Recall)**: 0.9767
- **Specificity**: 0.9867
- **Precision**: 0.9767
- **F1‑score**: 0.9767
- **AUC**: 0.998

These metrics are based on the best model selected among glmnet, random forest, and SVM with radial kernel.

### Feature Importance

The top 10 most important features (by absolute coefficient) are:

1. `concave.points_worst`
2. `perimeter_worst`
3. `radius_worst`
4. `concavity_worst`
5. `area_worst`
6. `concave.points_mean`
7. `concavity_mean`
8. `perimeter_mean`
9. `radius_mean`
10. `area_mean`

A visual summary of feature importance (from the original project) is shown below:

![Feature Importance](https://raw.githubusercontent.com/YifeiBelle/bcpredict/master/figures/glmnet_feature_importance.png)

## Example with Visualization

```r
# Load required packages
library(ggplot2)

# Create a data frame with predictions
results <- data.frame(
  sample = 1:nrow(toy_data_features),
  prediction = predictions
)

# Plot
ggplot(results, aes(x = sample, fill = prediction)) +
  geom_bar() +
  labs(title = "Predicted Diagnoses for Toy Data",
       x = "Sample Index", y = "Count") +
  scale_fill_manual(values = c("B" = "steelblue", "M" = "coral")) +
  theme_minimal()
```

## Model Performance Plots

The original project produced additional diagnostic plots:

- **ROC curves** for the three candidate models:

![ROC Curves](https://raw.githubusercontent.com/YifeiBelle/bcpredict/master/figures/roc_curves.png)

- **SHAP summary** (if applicable):

![SHAP Summary](https://raw.githubusercontent.com/YifeiBelle/bcpredict/master/figures/shap_summary.png)

## License

MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome. Please open an issue or pull request on [GitHub](https://github.com/YifeiBelle/bcpredict).

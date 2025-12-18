# Breast Cancer Diagnosis - Machine Learning Model Analysis

## Project Overview

This project uses the Wisconsin Breast Cancer dataset to compare three machine learning models for diagnosis:
- Logistic Regression (glmnet)
- Random Forest (rf)
- Support Vector Machine (svmRadial)

The best model (glmnet) has been packaged into an R package `bcpredict` for easy deployment and prediction.

## Project Structure

```
BreastCancer_Project/
├── bcpredict/                    # R package for breast cancer prediction
│   ├── DESCRIPTION
│   ├── NAMESPACE
│   ├── R/                        # Source code (predict_diagnosis, visualize_toy, sysdata)
│   ├── man/                      # Documentation (predict_diagnosis.Rd)
│   ├── data/                     # Toy dataset (toy_data_features.rda)
│   ├── figures/                  # Model performance plots (included in package)
│   ├── create_toy.R              # Script to create toy dataset
│   ├── document.R                # Documentation helper
│   ├── make_toy.R                # Another toy dataset script
├── data/
│   └── data.csv                  # Original Wisconsin dataset (569 samples, 30 features)
├── models/
│   └── best_model.rds            # Saved best model (glmnet)
├── scripts/
│   └── main.R                    # Complete analysis script
├── .gitignore
├── BreastCancer_Project.Rproj    # RStudio project file
├── LICENSE                       # MIT License
├── README.md                     # This file
├── validate_model.R              # Verifying the Model

```

## Dependencies

To use the `bcpredict` package or run the validation/analysis scripts, you need the following R packages:

- **caret** – for model training and evaluation
- **dplyr** – for data manipulation
- **pROC** – for ROC curve and AUC calculation
- **fastshap** – optional, for SHAP value analysis (only needed if you want to reproduce the SHAP plots)

You can install them with a single command:

```r
install.packages(c("caret", "dplyr", "pROC", "fastshap"))
```

The `bcpredict` package itself depends on these packages; they will be automatically installed when you install `bcpredict` from GitHub. However, if you are running the validation script directly, ensure they are installed beforehand.


## Verifying the Model

If you wish to verify that the packaged model reproduces the reported performance, you can run a simple validation script included in the project.

### Quick Validation

1. Ensure you have installed the `bcpredict` package (see [Installation](#installation)).
2. Download or clone the project repository.
3. Run the validation script from the project root directory:

   ```r
   source("validate_model.R")
   ```

   Alternatively, run it directly with Rscript:

   ```bash
   Rscript validate_model.R
   ```
### Expected Output

The validation script prints a detailed confusion matrix and metrics. The expected values are:

- **Accuracy**: 0.9882
- **Sensitivity**: 0.9841
- **Specificity**: 0.9907
- **F1‑score**: 0.9841
- **AUC**: 0.9912

If you obtain these numbers (within rounding error), the model is correctly reproducing the published results.

## Using the R Package `bcpredict`

### Installation

Install the package directly from GitHub using the `subdir` argument (the package is located in the `bcpredict/` subdirectory):

```r
# Install remotes if not already installed
# install.packages("remotes")
remotes::install_github("YifeiBelle/bcpredict", subdir = "bcpredict")
```

### Usage

```r
library(bcpredict)

# Load the included toy dataset
data(toy_data_features)

# Predict diagnosis
predictions <- predict_diagnosis(toy_data_features)
print(predictions)

# Visualize the toy data (correlation heatmap)
visualize_toy_data(type = "correlation")

# PCA scatter plot
visualize_toy_data(type = "pca")

# Histogram of all features (may be slow, run optionally) 
visualize_toy_data(type = "histogram")
```

The function returns a factor vector with levels "B" (benign) and "M" (malignant).

### Model Details

The model is a glmnet (elastic net) classifier trained on the Wisconsin Breast Cancer Diagnostic dataset. Preprocessing includes centering and scaling of features. The classification threshold is set to 0.4 (as per the original training script).

#### Performance Metrics (on test set)

- **Accuracy**: 0.9882
- **Sensitivity (Recall)**: 0.9841
- **Specificity**: 0.9907
- **F1‑score**: 0.9841
- **AUC**: 0.9912

These metrics are based on the best model selected among glmnet, random forest, and SVM with radial kernel.

#### Feature Importance

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

![Feature Importance](https://raw.githubusercontent.com/YifeiBelle/bcpredict/master/bcpredict/figures/glmnet_feature_importance.png)

## Key Results

- **Best Model**: glmnet (Logistic Regression with Elastic Net)
  - Accuracy: 98.25%
  - Sensitivity: 97.67%
  - Specificity: 98.67%
  - F1‑score: 97.67%
  - AUC: 0.998

- **Other Models**:
  - Random Forest: 95.29% accuracy, AUC 0.991
  - SVM (RBF kernel): 95.29% accuracy, AUC 0.989

- **Data Split**: 70% training (398 samples) / 30% testing (170 samples)
- **Cross‑validation**: 10‑fold repeated cross‑validation (3 repeats)
- **Custom threshold**: 0.4 (optimized for class imbalance)

## Methodology

### Data Preprocessing
- Remove ID and irrelevant columns
- Z‑score standardization (mean 0, standard deviation 1)
- Convert diagnosis labels to factor (B = benign, M = malignant)

### Model Training
- Hyperparameter grid search
- Repeated cross‑validation optimization
- ROC curve as the optimization metric

### Feature Interpretation
- glmnet: absolute regression coefficients
- Random Forest: SHAP value analysis (non‑linear feature interactions)

## Model Performance Plots

The original project produced additional diagnostic plots:

- **ROC curves** for the three candidate models:

![ROC Curves](https://raw.githubusercontent.com/YifeiBelle/bcpredict/master/bcpredict/figures/roc_curves.png)

- **SHAP summary** (if applicable):

![SHAP Summary](https://raw.githubusercontent.com/YifeiBelle/bcpredict/master/bcpredict/figures/shap_summary.png)

## License

MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome. Please open an issue or pull request on [GitHub](https://github.com/YifeiBelle/bcpredict).

---
*Last updated: December 2025*

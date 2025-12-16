# Breast Cancer Diagnosis - Machine Learning Model Analysis

## Project Overview

This project uses the Wisconsin Breast Cancer dataset to compare three machine learning models for diagnosis:
- Logistic Regression (glmnet)
- Random Forest (rf)
- Support Vector Machine (svmRadial)

The best model (glmnet) has been packaged into an R package `bcpredict` for easy deployment and prediction.

## Updated Project Structure

```
BreastCancer_Project/
├── bcpredict/                    # R package for breast cancer prediction
│   ├── DESCRIPTION
│   ├── NAMESPACE
│   ├── R/                        # Source code (predict_diagnosis)
│   ├── man/                      # Documentation
│   ├── data/                     # Toy dataset (toy_data_features)
│   ├── inst/
│   ├── vignettes/
│   ├── tests/
│   └── figures/                  # Model performance plots
├── data/
│   └── data.csv                  # Original Wisconsin dataset (569 samples, 30 features)
├── models/
│   └── best_model.rds            # Saved best model (glmnet)
├── scripts/
│   └── main.R                    # Complete analysis script
├── README.md                     # This file
├── LICENSE                       # MIT License
└── BreastCancer_Project.Rproj    # RStudio project file
```

## How to Run the Analysis

1. Ensure R and the required packages are installed:
   - caret
   - dplyr
   - pROC
   - fastshap (optional for SHAP analysis)

2. Run the analysis script:
   ```r
   source("scripts/main.R")
   ```

3. Results will be saved in the `figures/` and `models/` directories (created automatically).

## Using the R Package `bcpredict`

### Installation

Install the package directly from GitHub:

```r
# Install remotes if not already installed
# install.packages("remotes")
remotes::install_github("YifeiBelle/bcpredict")
```

### Usage

```r
library(bcpredict)

# Load the included toy dataset
data(toy_data_features)

# Predict diagnosis
predictions <- predict_diagnosis(toy_data_features)
print(predictions)
```

The function returns a factor vector with levels "B" (benign) and "M" (malignant).

### Model Details

The model is a glmnet (elastic net) classifier trained on the Wisconsin Breast Cancer Diagnostic dataset. Preprocessing includes centering and scaling of features. The classification threshold is set to 0.4 (as per the original training script).

#### Performance Metrics (on test set)

- **Accuracy**: 0.9825
- **Sensitivity (Recall)**: 0.9767
- **Specificity**: 0.9867
- **Precision**: 0.9767
- **F1‑score**: 0.9767
- **AUC**: 0.998

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
  - Accuracy: 98.82%
  - Sensitivity: 98.41%
  - Specificity: 99.07%
  - F1‑score: 98.41%
  - AUC: 0.991

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

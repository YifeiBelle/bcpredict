library(devtools)
load_all("bcpredict")

# Load toy data
data(toy_data_features, package = "bcpredict")
print(head(toy_data_features))

# Predict
predictions <- predict_diagnosis(toy_data_features)
print(predictions)
print(table(predictions))
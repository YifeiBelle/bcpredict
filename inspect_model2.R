# Load the model without caret if possible
m <- readRDS('models/best_model.rds')
cat('Model class:', class(m), '\n')
cat('Model type:', m$modelType, '\n')
cat('Model method:', m$method, '\n')
cat('Preprocessing:', ifelse(is.null(m$preProcess), 'None', paste(m$preProcess$method, collapse=', ')), '\n')
cat('Training data columns:', names(m$trainingData), '\n')
cat('Training data dimensions:', dim(m$trainingData), '\n')
cat('Final model class:', class(m$finalModel), '\n')
cat('Final model summary:\n')
print(m$finalModel)
cat('\n--- Coefficients ---\n')
if ('finalModel' %in% names(m) && 'glmnet' %in% class(m$finalModel)) {
  # For glmnet, extract coefficients at optimal lambda
  coefs <- coef(m$finalModel, s = m$finalModel$lambdaOpt)
  print(coefs)
}
cat('\n--- Model call ---\n')
print(m$call)
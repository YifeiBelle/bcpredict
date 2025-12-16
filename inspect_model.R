library(caret)
m <- readRDS('models/best_model.rds')
cat('Model class:', class(m), '\n')
cat('Model method:', m$method, '\n')
cat('Features:', names(m$trainingData), '\n')
cat('Preprocessing:', ifelse(is.null(m$preProcess), 'None', paste(m$preProcess$method, collapse=', ')), '\n')
cat('Coefficients:\n')
if ('finalModel' %in% names(m)) {
  coefs <- coef(m$finalModel, s = m$finalModel$lambdaOpt)
  print(coefs)
}
cat('\n--- Model summary ---\n')
print(m)
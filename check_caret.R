library(caret)
cat('predict.preProcess exists:', exists('predict.preProcess', where = asNamespace('caret'), mode = 'function'), '\n')
cat('Methods for predict:', paste(methods('predict'), collapse=', '), '\n')
cat('preProcess class methods:', paste(methods(class='preProcess'), collapse=', '), '\n')
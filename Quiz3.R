checkMethods <- c("mean", "lm", "colSums", "show", "dgamma", "predict")
isGenericS3 = function(FUN) body(match.fun(FUN))[[1]] == 'UseMethod'
sapply(checkMethods, function(FUN) isGeneric(FUN) || isGenericS3(FUN))

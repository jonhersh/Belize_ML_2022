# ----------------------------------------------------------
# Setup
# ----------------------------------------------------------
set.seed(1818)
options(scipen = 9)

library('tidyverse')
library('rsample')
library('glmnet')
library('glmnetUtils')
library('forcats')

# load data
LFS_2019 <- readRDS("data/LFS_April_2019_noPID.RDS")


# create testing and training split
LFS_split <- initial_split(LFS_2019, prop = .75)
LFS_train <- training(LFS_split)
LFS_test <- testing(LFS_split)

# ----------------------------------------------------------
# Estimating Ridge Models in R 
# ----------------------------------------------------------

# estimate a Ridge model using glmnet
# note if you get an error make sure you 
#  have loaded glmnetUtils
ridge_mod <- cv.glmnet(any_bank_account ~ urban + tenureTypeOwn + outerWallsPoor 
                       + toiletPoor + elecGrid + bedrooms + aircon + fridges 
                       + micros + washers + stereos + DVDplayers + TVs + 
                         cellphones + computers + vehicles + cable + 
                         internet + numHHmem + numDep + numChildren,
                       data = LFS_train,
                       weights = Weight,
                       family = "binomial",
                       # note alpha = 0 sets ridge!  
                       alpha = 0)

plot(ridge_mod)

# print the two model suggested values of lambda:

print(ridge_mod$lambda.min)
#
print(ridge_mod$lambda.1se)

# print coefficient using lambda.min
coef(ridge_mod, s = ridge_mod$lambda.min) %>% 
  round(3)

# print coefficient using lambda.1se
coef(ridge_mod, s = ridge_mod$lambda.1se) %>% 
  round(3)

# put into coefficient vector
ridge_coefs <- tibble(
  `varnames` = rownames(coef(ridge_mod, s = ridge_mod$lambda.1se)),
  `ridge_min` = coef(ridge_mod, s = ridge_mod$lambda.min) %>% 
    round(3) %>% as.matrix() %>% as.data.frame(),
  `ridge_1se` = coef(ridge_mod, s = ridge_mod$lambda.1se) %>% 
    round(3) %>% as.matrix() %>% as.data.frame()
) 

print(ridge_coefs, n = 31)

# use the plot function to see the MSE
# path as we vary lambda (the amount of penalization)
plot(ridge_mod)

### examine coefficient shrinkage path
# note may need to install devtools first
# install.packages('devtools')
devtools::install_github("jaredlander/coefplot")
library('coefplot')
coefpath(ridge_mod)

# ----------------------------------------------------------
#  Lasso Lab  
# ----------------------------------------------------------

# 1. Estimate a lasso model predicting 

# ----------------------------------------------------------
# Estimating Lasso Models in R 
# ----------------------------------------------------------

# note cv.glmnet automatically performs 
# k-fold cross-validation 
lasso_mod <- cv.glmnet(any_bank_account ~ urban + tenureTypeOwn + outerWallsPoor 
                       + toiletPoor + elecGrid + bedrooms + aircon + fridges 
                       + micros + washers + stereos + DVDplayers + TVs + 
                         cellphones + computers + vehicles + cable + 
                         internet + numHHmem + numDep + numChildren,
                       data = LFS_train,
                       weights = Weight,
                       family = "binomial",
                       # note alpha = 1 sets lasso!  
                       alpha = 1)

# plot how the MSE varies as we vary lambda
plot(lasso_mod)


# Note that lasso estimates a series of models, one for 
# every value of lambda -- the amount of shrinkage

# print the two model suggested values of lambda:
print(lasso_mod$lambda.min)
# 
print(lasso_mod$lambda.1se)


# to examine the coefficients we must say what value of 
# lambda we want to use. 

# coefficients using lambda.1se
coef(lasso_mod, 
     s = lasso_mod$lambda.1se) %>% 
  round(3)

# coefficients using lambda that minimizes cross-validated error
coef(lasso_mod, 
     s = lasso_mod$lambda.min) %>% 
  round(3)

# put into coefficient vector
lasso_coefs <- tibble(
  `varnames` = rownames(coef(lasso_mod, s = lasso_mod$lambda.1se)),
  `lasso_min` = coef(lasso_mod, s = lasso_mod$lambda.min) %>% 
    round(3) %>% as.matrix() %>% as.data.frame(),
  `lasso_1se` = coef(lasso_mod, s = lasso_mod$lambda.1se) %>% 
    round(3) %>% as.matrix() %>% as.data.frame()
) 
print(lasso_coefs, n = 23)

# install.packages('devtools')
devtools::install_github("jaredlander/coefplot")
library('coefplot')
coefpath(lasso_mod)


# ----------------------------------------------------------
# ElasticNet Model
# ----------------------------------------------------------
enet_mod <- cva.glmnet(any_bank_account ~ urban + tenureTypeOwn + outerWallsPoor 
                       + toiletPoor + elecGrid + bedrooms + aircon + fridges 
                       + micros + washers + stereos + DVDplayers + TVs + 
                         cellphones + computers + vehicles + cable + 
                         internet + numHHmem + numDep + numChildren,
                       data = LFS_train, alpha = seq(0,1, by = 0.05), 
                       weights = Weight, family = "binomial")

plot(enet_mod)

# now enet_mod holds a list with all of the sub models, 
# each with alpha = whatever sequence the model was estimated with

minlossplot(enet_mod, 
            cv.type = "min")


str(enet_mod$modlist)

# Use this function to find the best alpha
get_alpha <- function(fit) {
  alpha <- fit$alpha
  error <- sapply(fit$modlist, 
                  function(mod) {min(mod$cvm)})
  alpha[which.min(error)]
}

# Get all parameters.
get_model_params <- function(fit) {
  alpha <- fit$alpha
  lambdaMin <- sapply(fit$modlist, `[[`, "lambda.min")
  lambdaSE <- sapply(fit$modlist, `[[`, "lambda.1se")
  error <- sapply(fit$modlist, function(mod) {min(mod$cvm)})
  best <- which.min(error)
  data.frame(alpha = alpha[best], lambdaMin = lambdaMin[best],
             lambdaSE = lambdaSE[best], eror = error[best])
}

# extract the best alpha value and model parameters
best_alpha <- get_alpha(enet_mod)
print(best_alpha)
get_model_params(enet_mod)

# extract the best model object
best_mod <- enet_mod$modlist[[which(enet_mod$alpha == best_alpha)]]


# ----------------------------------------------------------
#  Lasso Lab  
# ----------------------------------------------------------
# 1. Estimate a cross-validated lasso regression model to predict whether 
#    someone doesn't have a bank account because it's too expensive 

# 2. Call the coefpath function against this fitted model. Which variables 
#    are most robust to high levels of penalization?

# 3. Estimate a cross-validated ridge regression model to predict whether 
#    someone doesn't have a bank account because it's too expensive 

# 4. Estimate an elasticnet model to predict whether 
#    someone doesn't have a bank account because it's too expensive 

# 5. Call the minlossplot function over this model




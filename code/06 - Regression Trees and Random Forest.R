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
LFS_2019 <- readRDS("data/LFS_April_2019_noPID.RDS") %>% 
  mutate(across(c(any_bank_account, no_bank_no_money, no_bank_too_far, tenureTypeOwn, outerWallsPoor, toiletPoor, elecGrid, bedrooms, aircon, fridges, micros, washers, stereos, DVDplayers, TVs, cellphones, computers, vehicles, cable, internet),
                ~ as.factor(.x)))


# create testing and training split
LFS_split <- initial_split(LFS_2019, prop = .75)
LFS_train <- training(LFS_split)
LFS_test <- testing(LFS_split)

#------------------------------------------------------------
# Regression Trees
#------------------------------------------------------------
library(partykit)
library(tidyverse)
library(rpart)       

set.seed(1818)

# Use the function ctree in rparty to estimate a 
# single regression tree classification model 
bank_tree <- ctree(any_bank_account ~ urban  + toiletPoor + numDep  
                   + elecGrid + internet + vehicles + numHHmem + DISTRICT_STR,
                   control = partykit::ctree_control(alpha=0.001, 
                                                     minbucket = 3000), 
                    data = LFS_train, weights = Weight)


# print the fitted model object 
print(bank_tree)

# Viewing the fitted model is easier 
plot(bank_tree)




#------------------------------------------------------------
# Cross-Validating to Select Optimal Tree Depth
#------------------------------------------------------------
# cross validate to get optimal tree depth
# must use rpart package here

# rpart function to select optimal depth of tree
# read the help() file for rpart.control to learn about 
#  the different function options
# max depth  ensures the final tree only has this 
#  many splits
# min split means minimum observations in a node before 
#  a split can be attempted
# cp is the complexity parameter, overall Rsq must 
#  increase by cp at each step
library('rpart')
bank_rpart <- rpart(any_bank_account ~ urban  + toiletPoor + numDep  
                    + elecGrid + internet + vehicles + numHHmem + DISTRICT_STR,
                    data = LFS_train, weights = Weight,
                    method = "class",control = list(cp = 0, 
                                   minsplit = 10,
                                   maxdepth = 10))
bank_rpart$cptable

# plot the relationship between tree complexity (depth and cp)
# and CV error
plotcp(bank_rpart)



#---------------------------------------------------------------
# Random Forest
#---------------------------------------------------------------
library('randomForest')

rf_fit <- randomForest(any_bank_account ~ urban + tenureTypeOwn + outerWallsPoor 
                       + toiletPoor + elecGrid + bedrooms + aircon + fridges 
                       + micros + washers + stereos + TVs + cellphones + 
                         computers + vehicles + cable + educ_head_of_hh + 
                         internet + numHHmem + numDep + numChildren, 
                       type = classification, 
                       data = LFS_train,
                       mtry = 3, 
                       weights = LFS_train$Weight,
                       na.action = na.roughfix,
                       ntree = 100, 
                       importance = TRUE)


print(rf_fit)

plot(rf_fit)

#---------------------------------------------------------------
# Variable Importance
#---------------------------------------------------------------
varImpPlot(rf_fit, type = 1)
importance(rf_fit)

#---------------------------------------------------------------
# Explain Forest
#---------------------------------------------------------------
# really cool package!
# https://cran.r-project.org/web/packages/randomForestExplainer/vignettes/randomForestExplainer.html
library('randomForestExplainer')

plot_min_depth_distribution(rf_fit, mean_sample = "top_trees")

plot_multi_way_importance(rf_fit, size_measure = "no_of_nodes")


plot_predict_interaction(rf_fit, LFS_train, "numHHmem", 
                         "educ_head_of_hh", 
                         grid = 50)

# explain_forest(rf_fit, 
#               interactions = TRUE, 
#               data =  CR_train %>% select(-household_ID))


#---------------------------------------------------------------
# Cross-validate to select optimal mtry 
#---------------------------------------------------------------
library('caret')

rf_caret <-
  train(any_bank_account ~ urban + tenureTypeOwn + outerWallsPoor 
        + toiletPoor + elecGrid + bedrooms + aircon + fridges 
        + micros + washers + stereos + TVs + cellphones + 
          computers + vehicles + cable + educ_head_of_hh + 
          internet + numHHmem + numDep + numChildren, 
        data = LFS_train,
        weights = LFS_train$Weight,
        method = "rf",
        metric = "Accuracy",
        tuneLength = 5,
        trControl = trainControl(method = "cv", 
                                 number = 5, 
                                 verbose = TRUE))

plot(rf_caret)


#---------------------------------------------------------------
# Exercises
#---------------------------------------------------------------
# 1. Estimate a tree model to predict whether someone doesn't 
#    have a bank account because they don't have enough money. Use whatever
#    independent variables you think are important! 

# 2. Estimate a random forest model using mtry = 4 and 200 different trees
#    to predict whether someone doesn't have a bank account because they 
#    don't have enough money

# 3. Use varImpPlot to show which variables have the highest impact on the 
#    model performance

# 4. Use the function plot_min_depth_distribution on the model to examine inside
#    the random forest model. 

# 5. Use the train function in caret to use cross-validation to estimate the 
#    optimal mtry. 

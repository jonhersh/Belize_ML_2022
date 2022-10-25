# ----------------------------------------------------------
# Setup
# ----------------------------------------------------------
set.seed(1818)
options(scipen = 9)

library('dplyr')
library('rsample')
library('forcats')

# load data
LFS_2019 <- readRDS("data/LFS_April_2019_noPID.RDS") %>% 
  mutate(across(c(any_bank_account, no_bank_no_money, no_bank_too_far, tenureTypeOwn, outerWallsPoor, toiletPoor, elecGrid, bedrooms, aircon, fridges, micros, washers, stereos, DVDplayers, TVs, cellphones, computers, vehicles, cable, internet),
                ~ as.factor(.x)))

# create testing and training split
LFS_split <- initial_split(LFS_2019, prop = .75)
LFS_train <- training(LFS_split)
LFS_test <- testing(LFS_split)



#--------------------------------------------------------
# Estimating Logistic Regression in R
#--------------------------------------------------------
# make sure to use glm() function! 
# set family = binomial to set logistic function
logit_fit1 <- glm(any_bank_account ~ urban  + toiletPoor + numDep  
                  + elecGrid + internet + vehicles + numHHmem + DISTRICT_STR,
                  family = binomial,
                  data = LFS_train)

# summary over the model to see the model estimates
summary(logit_fit1)


# ------------------------------------------------
# Generate model predictions
# ------------------------------------------------
preds_train <- tibble(
  `true` = as.factor(LFS_train$any_bank_account),
  `scores` = predict(logit_fit1, 
                          newdata = LFS_train,
                          type = "response")
) %>% 
  mutate(class_pred = as.factor(if_else(scores > 0.6,1,0)))



# ------------------------------------------------
# estimate confusion matrix
# ------------------------------------------------
library(caret)
confusionMatrix(preds_train$class_pred,
                preds_train$true, 
                positive = "1")


# ------------------------------------------------
#  Plot ROC curve
# ------------------------------------------------
library('ggplot2')
library('plotROC')

p <- ggplot(preds_train, 
            aes(m = scores, 
                d = as.numeric(true))) + 
  geom_roc(labelsize = 3.5, 
           cutoffs.at = 
             c(0.99,0.9,0.7,0.5,0.3,0.1,0)) +
  theme_minimal(base_size = 16)
print(p)
calc_auc(p)


# ------------------------------------------------
#  Exercises
# ------------------------------------------------
# 1. Generate predicted scores using the lasso model
#    for the test data frame (using lambda.min)


# 2. Generate class predictions using a variety of cutoffs


# 3. Compute confusion a confusion matrix for those various
#    cutoff thresholds

# 4. Produce an ROC plot using the lasso model predictions
#    for the test set. 


# 5. Our model is overfit if the accuracy in the test is 
#    considerably worse than the accuracy in the training. 
#    Compare the AUC metric in the test versus train for the 
#    ridge model. Is our model overfit or underfit? 

# 6. Extra credit! Do the above using the ElasticNet model
#    Generate predictions using the optimal value of lambda

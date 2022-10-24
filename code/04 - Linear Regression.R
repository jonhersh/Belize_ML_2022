
#--------------------------------------------------------
# Basic Linear Regression
#--------------------------------------------------------
# remove all existing objects in memory
rm(list = ls())

# load these libraries
library('dplyr')
library('ggplot2')


#--------------------------------------------------------
# Formulas in R 
#--------------------------------------------------------
# formulas in R start with the dependent variable on the 
# left hand side (LHS), then by a "~" tilde, following by 
# all the dependent variables you wish to estimate on the
# right hand side (RHS)

# e.g. y ~ x1 + x2

data(mpg)
hwy ~ year + displ + cyl  

mod1 <- lm(hwy ~ year + cyl + displ, 
           data = mpg)

summary(mod1)


#--------------------------------------------------------
# Linear Models using lm()
#--------------------------------------------------------

# estimate a linear model with displacement, and 
# cycl on the RHS, and hwy as the 
# development variable (LHS)
# Use the 'mpg' dataframe to estimate the model
# and store the regression equation as 'mod1'
mod2 <- lm(hwy ~ displ + cyl, 
           data = mpg)

# print out a summary of the linear model
summary(mod2)

# or just view the whole "list" object of 
# the model results
str(mod2)



#--------------------------------------------------------
# estimating "prettier" regression output
#--------------------------------------------------------
# install.packages('sjPlot')
library('sjPlot')
# install.packages('sjPlot')
library('tidymodels')
# output a prettier table of results 
# looks very nice in RMarkdown! 
tab_model(mod1)

# output a plot of regression coefficients
plot_model(mod1)

# output a table of coefficients and their p-values, t-stats
tidy(mod1)



#--------------------------------------------------------
# Linear Model to Predict Bank Access
#--------------------------------------------------------
LFS_2019 <- readRDS("data/LFS_April_2019_noPID.RDS")

bank_mod <- lm(any_bank_account ~ educ_head_of_hh + log_numHHmem + log_numChildren, 
              data = LFS_2019, 
              weight = Weight)

summary(bank_mod)


#--------------------------------------------------------
# Exercises
#--------------------------------------------------------

# 1. Estimate a linear model predicting any_bank_account as a function of 
#    urban, tenureTypeOwn, floorMatPoor, toiletPoor, elecGrid, bedrooms, aircon
#    cellphones, computers, and numHHmem. Store this as bank_mod2

# 2. Estimate a linear model predicting borrowed_any as a function of the 
#    same variables listed. Store this as borrowed_mod

# 3. Run the summary command over both models









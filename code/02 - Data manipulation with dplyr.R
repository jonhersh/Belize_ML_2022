# ------------------------------------------------
# Loading data 
# ------------------------------------------------
library('dplyr')

LFS_2019 <- readRDS("data/LFS_April_2019_noPID.RDS")

# ------------------------------------------------
# Data frame basics
# ------------------------------------------------

# see metadata associated with data frame 
attributes(LFS_2019)

# column or variable names
names(LFS_2019) 

# Inspect/view the raw datafile
View(LFS_2019)

# number of rows
nrow(LFS_2019)

# see number of columns
ncol(LFS_2019)

# see both dimensions
dim(LFS_2019)

# "$" operator to select a column
LFS_2019$DISTRICT_STR


# ------------------------------------------------
# GLIMPSE to summarize data
# ------------------------------------------------
# let's summarize the data using the glimpse function
glimpse(LFS_2019)


# ------------------------------------------------
# Pipe Operator!  
# ------------------------------------------------
# The pipe operator "%>%" is super useful!
# It allows us to execute a series of functions on an object in stages
# The general recipe is Data_Frame %>% function1() %>% function2() etc
# Functions are applied right to left

LFS_2019 %>% glimpse()

# cmd/ctrl + shift as a shortcut create the pipe operator 





# ------------------------------------------------
# Slice function: to select ROWS 
# ------------------------------------------------
# SLICE: slice to view only the first 10 rows
LFS_2019 %>% slice(1:10)

# SLICE to view only rows 300 to 310 
LFS_2019 %>% slice(300:310)


# ------------------------------------------------
# Arrange function: to ORDER dataset
# ------------------------------------------------

# arrange the dataframe in descending order by Weight
LFS_2019 %>%  
  arrange(desc(Weight)) 

# arrange via multipe columns, by budget and title year, then output rows 1 to 10
LFS_2019 %>% 
  arrange(desc(numChildren), desc(numHHmem)) %>% 
  slice(1:10)




# ------------------------------------------------
# SELECT columns of the dataset using the 'select' function
# ------------------------------------------------
# selecting columns using the select() function
# here we create a subset of the original dataset that only contains 
# director_name and movie title
LFS_2019_keys <- LFS_2019 %>%  select(DISTRICT_STR, DISTRICT_C)
glimpse(LFS_2019_keys)

# using select to programmatically select several variables that 
# 'start with' a certain string
LFS_2019_bank <- LFS_2019 %>% select(starts_with("no_bank"))
glimpse(LFS_2019_bank)

# use - in front of a variable name to de-select that variable
LFS_2019 <-  
  LFS_2019 %>% 
  select(-log_numHHmem, -log_numChildren)

# ------------------------------------------------
# RENAME variables using the RENAME function
# ------------------------------------------------

# use the rename function to rename variables
LFS_2019 <- 
  LFS_2019 %>%  
  rename(eduHead = educ_head_of_hh)

glimpse(LFS_2019)

# ------------------------------------------------
# FILTER and ONLY allow certain rows using the FILTER function
# ------------------------------------------------
# filter removes any rows that DO NOT meet the logical operator

# ONLY select large budget LFS_2019 and store this as a new data frame
LFS_2019_big <- LFS_2019 %>% filter(numHHmem > 10)
nrow(LFS_2019_big)

# ONLY select Corozal households
LFS_2019_Corozal <- LFS_2019 %>% filter(DISTRICT_STR  == "Corozal")
nrow(LFS_2019_Corozal)
dim(LFS_2019_Corozal)


# select both Corozal households and rural ones
LFS_2019_Corozal_rural <- LFS_2019 %>% filter(DISTRICT_STR == "English" | URBAN_RURAL == "Rural")
dim(LFS_2019_Corozal_rural)


# ------------------------------------------------
# MUTATE to Transform variables in your dataset
# ------------------------------------------------

# adding new variables using mutate()
# let's create new variables log budget and log gross that are
# budget and gross transformed by logarithm
LFS_2019 <- 
  LFS_2019 %>% 
  mutate(log_numHHmem = log(1 + numHHmem),
         log_numChildren = log(1 + numChildren))

LFS_2019 %>% glimpse()


# ------------------------------------------------
# Working with survey weights and summary tables
# ------------------------------------------------
# http://gdfe.co/srvyr/
# install.packages('srvyr')
library(srvyr, warn.conflicts = FALSE)

LFS_2019 %>% 
  as_survey(weights = c(Weight)) %>% 
  group_by(DISTRICT_STR) %>% 
  summarize(numChildren = survey_mean(numChildren, na.rm = TRUE))

# ------------------------------------------------
# Lab exercises
# ------------------------------------------------

# 1. Use the filter command to see the number of rural households in the survey

# 2. Use the mutate command to create a dependency ratio variable, e.g. 
#    number of dependents divided by number of household members 

# 3. Use the as_survey and summarize command to calculate fraction of households
#    with bank accounts overall in the country 

# 4. Add the group_by() command to the above statement to calculate fraction of a 
#    district with any bank account

# 5. Use the summarize command to compute any other statistic by district


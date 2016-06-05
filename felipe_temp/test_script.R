#------------ Load Libraries -----#

library(magrittr)
library(dplyr)
library(tidyr)
library(foreign)
library(nnet)

#------- Read & Clean Data ----#

#Read Neil's file
trainPrep.df <- read.csv('../data/train_prep.csv')

##train.df <- read.csv(gzfile('../data/train.csv.gz'))

#Does the pet have a name?
trainPrep.df %<>% mutate(Pet_named = ifelse(Name=="",0,1))

#select certain columns
trainSelected.df <- trainPrep.df %>% select(AnimalType,AgeuponOutcome_days,sex,desexed,Breed_is_mix,Pet_named,OutcomeType)

#------ Mutinomial Logistic Regression -----#

#divide set into training, and cross validation 
library(nnet)

test <- multinom(OutcomeType ~ ., data = trainSelected.df)




#---- Simple Random Forest ---#



#--- Simple xgboost ---#
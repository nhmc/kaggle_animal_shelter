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

multi.model <- multinom(OutcomeType ~ ., data = trainSelected.df)

library(MLmetrics)

Outcome_true <- factor(trainSelected.df$OutcomeType)#,stringsAsFactors = T)
Outcome_long <- data.frame(ID=trainPrep.df$AnimalID,OutcomeTrue=Outcome_true,value=rep(1,length(Outcome_true)))
Outcome_wide <- spread(Outcome_long,OutcomeTrue,value,fill=0)
Outcome_wide <- data.matrix(Outcome_wide[,-1])

preds.matrix<- predict(multi.model,trainSelected.df[,-7],type='probs')
ix <- rowSums(is.na(preds.matrix)) == 0
preds.matrix <- preds.matrix[ix,]
Outcome_wide <- Outcome_wide[ix,]

score_multinomialreg <- MultiLogLoss(y_true = Outcome_wide, y_pred=preds.matrix) 

#---- Simple Random Forest ---#
library(randomForest)

rf.model <- randomForest(OutcomeType ~ desexed+AgeuponOutcome_days+Pet_named, data = trainSelected.df[ix,],ntree=100,do.trace=10)

print(rf.model)
importance(rf.model)

preds.rf <- predict(rf.model,trainSelected.df[ix,-7],type = 'prob')

MultiLogLoss(y_true = Outcome_wide, y_pred=preds.rf) 

score_multinomialreg <- MultiLogLoss(y_true = Outcome_wide, y_pred=preds.matrix) 

#---prepare for xgboost -----#

#--- Simple xgboost ---#
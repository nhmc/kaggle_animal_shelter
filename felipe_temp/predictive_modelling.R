# --- predictive modelling ----

library(caret)
library(nnet)
library(MLmetrics)
library(tidyr)
library(dplyr)

load("trainReady.rda")

mysample <- createDataPartition(train.df$OutcomeType, p=0.6, list=FALSE)
training <- train.df[mysample, ]
testing <- train.df[-mysample, ]

mod_fit <- train(OutcomeType ~ . ,  data=training[,-1], method="glm", family="binomial")



multi.model <- multinom(OutcomeType ~ .,data=training[,-1])


Outcome_true <- factor(testing$OutcomeType)#,stringsAsFactors = T)
Outcome_long <- data.frame(ID=testing$AnimalID,OutcomeTrue=Outcome_true,value=rep(1,length(Outcome_true)))
Outcome_wide <- spread(Outcome_long,OutcomeTrue,value,fill=0)
Outcome_wide <- data.matrix(Outcome_wide[,-1])

preds.matrix<- predict(multi.model,testing[,-c(1,13)],type='probs')
ix <- rowSums(is.na(preds.matrix)) == 0
preds.matrix <- preds.matrix[ix,]
Outcome_wide <- Outcome_wide[ix,]

score_multinomialreg <- MultiLogLoss(y_true = Outcome_wide, y_pred=preds.matrix) 
score_multinomialreg

# ----- Random forests ---
library(randomForest)

trainingrf <- data.frame(unclass(training))
testingrf <- data.frame(unclass(testing))

rf.model <- randomForest(OutcomeType ~ ., data = trainingrf[,-c(1,2,12,10,4)],ntree=500,do.trace=10)

print(rf.model)
importance(rf.model)

preds.rf <- predict(rf.model,testingrf[,-c(1,13)],type = 'prob')

MultiLogLoss(y_true = Outcome_wide, y_pred=preds.rf) 

score_multinomialreg <- MultiLogLoss(y_true = Outcome_wide, y_pred=preds.matrix) 


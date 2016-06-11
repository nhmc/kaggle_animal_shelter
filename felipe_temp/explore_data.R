#' ---
#' title: "Exploring Data - Animal Shelter Kaggle Comp"
#' author: "F Marin"
#' date: "June 11, 2016"
#' ---

# --- Load Libraries -----

library(magrittr,quietly = TRUE, warn.conflicts = FALSE)
library(dplyr,quietly = TRUE, warn.conflicts = FALSE)
library(tidyr,quietly = TRUE, warn.conflicts = FALSE)
library(foreign,quietly = TRUE, warn.conflicts = FALSE)
library(nnet,quietly = TRUE, warn.conflicts = FALSE)
library(ggplot2,quietly = TRUE, warn.conflicts = FALSE)


# ---- Read & clean data ----

#Read and Clean data: Neil's file

trainPrep.df <- read.csv('../data/train_prep.csv',stringsAsFactors = FALSE)

#fill for missing/unknown values

#to replace with 'unknown'
trainPrep.df %<>% mutate(Name=ifelse(Name=="","Unknown",Name))
trainPrep.df %<>% mutate(Name=ifelse(AgeuponOutcome=="","Unknown",AgeuponOutcome))
trainPrep.df %<>% mutate(Name=ifelse(SexuponOutcome=="","Unknown",SexuponOutcome))
trainPrep.df %<>% mutate(Name=ifelse(sex=="","Unknown",sex))
trainPrep.df %<>% mutate(Name=ifelse(desexed=="","Unknown",desexed))

#replace NAs
trainPrep.df %<>% replace_na(list(AgeuponOutcome_days=-100))


# ---- Some additional plots ----

#outcome vs year
plot.outyear <- ggplot(data=trainPrep.df,aes(x=factor(dt_year)))
plot.outyear <- plot.outyear + geom_bar(aes(fill=factor(OutcomeType)))
plot.outyear

#outcome vs month
plot.outmonth <- ggplot(data=trainPrep.df,aes(x=factor(dt_month)))
plot.outmonth <- plot.outmonth + geom_bar(aes(fill=factor(OutcomeType)),position='fill')
plot.outmonth <- plot.outmonth + labs(title='Outcome vs Month',x='Month of the year',y='Normalised count')
plot.outmonth

#outcome vs day of the week
plot.outday <- ggplot(data=trainPrep.df,aes(x=factor(dt_dayofweek)))
plot.outday <- plot.outday + geom_bar(aes(fill=factor(OutcomeType)),position='fill')
plot.outday <- plot.outday + labs(title='Outcome vs Day',x='Day of the week',y='Normalised count')
plot.outday










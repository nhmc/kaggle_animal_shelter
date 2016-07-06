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

#add pet's race into the mix
# remove special characters (replace with ' ')
PetBreed <- data.frame(PetBreed=tolower(gsub("[^[:alnum:] ]", " ",trainPrep.df$Breed)))
#eliminate mix
trainPrep.df$PetBreed <- as.character(sub("(.*?) mix.*", "\\1",PetBreed$PetBreed))

#create mapping: cats
cat.type <- data.frame(table(as.character(trainPrep.df[trainPrep.df$AnimalType=='Cat',]$PetBreed)))
names(cat.type) <- c('Type','Freq')
cat.type %<>% arrange(desc(Freq)) %>%
                mutate(cumsumFreq=cumsum(Freq)/sum(Freq)) 
#take the first 9 classes - 10th is 'other'
cat.main.types <- cat.type[1:9,] %>% arrange(Freq) %>% select(Type)
cat.type$Category <- rep("",nrow(cat.type))
cat.type$Category[1:9] <- as.character(cat.type$Type[1:9])

for (i in 10:length(cat.type$Type)){
  cat.type$Category[i] = 'other cat'
  for(j in 1:9){
    if(grepl(cat.main.types$Type[j],cat.type$Type[i])==TRUE){
      cat.type$Category[i] = as.character(cat.main.types$Type[j])
      break
    }
  }
}

  
#create mapping: dogs
dog.type <- data.frame(table(as.character(trainPrep.df[trainPrep.df$AnimalType=='Dog',]$PetBreed)))
names(dog.type) <- c('Type','Freq')
dog.type %<>% arrange(desc(Freq)) %>%
    mutate(cumsumFreq=cumsum(Freq)/sum(Freq)) 
#take the first 14 classes - 15th is 'other'
dog.main.types <- data.frame(Type=c('pit bull','chihuahua','german shepperd','australian cattle','retriever',
                      'dachshund','poodle','terrier','schnauzer','boxer','shepperd','shih tzu',
                      'beagle','husky')) 
  
for (i in 1:length(dog.type$Type)){
  dog.type$Category[i] = 'other dog'
    for(j in 1:14){
      if(grepl(dog.main.types$Type[j],dog.type$Type[i])==TRUE){
        dog.type$Category[i] = as.character(dog.main.types$Type[j])
        break
      }
    }
}

#create new table
pet.MainBreed <- rbind(dog.type,cat.type) %>% select(PetBreed=Type,PetBreedCat=Category)
#join
trainPrep.df %<>% inner_join(pet.MainBreed)

#explore data
#outcome vs Main breed category
plot.breedmain <- ggplot(data=trainPrep.df,aes(x=factor(PetBreedCat)))
plot.breedmain <- plot.breedmain + geom_bar(aes(fill=factor(OutcomeType)),position='fill')
plot.breedmain <- plot.breedmain + labs(title='Outcome vs Breed',x='Breed Category',y='Normalised count')
plot.breedmain

train.df <- trainPrep.df %>% select(AnimalID,Name,AnimalType,dt_year,dt_month,dt_dayofweek,AgeuponOutcome_days,
                                    sex,desexed,Breed_is_mix,PetBreedCat,dogsize,OutcomeType)

save(train.df, file="trainReady.rda")

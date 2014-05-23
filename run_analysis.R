###################################
##   Project Scripts            ### 
##  Getting and Cleaning Data   ###
##     May 22, 2014             ###
###################################


require(data.table)
# Set your WD to appropriate directory
if(!file.exists("C:/coursera_project")){dir.create("C:/coursera_project")}
setwd("C:/coursera_project")
# Getting Data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
download.file(url, destfile = "dataset.zip", mode = "wb")
unzip("dataset.zip")
file.remove("dataset.zip")
file.rename("UCI HAR Dataset", "data")

#creating variable and id data
activity <- read.table("./data/activity_labels.txt")
  names(activity) <- c("activity.code", "activity")
features <- read.table("./data/features.txt")
  #mean sub vars
  mean.pos <- grep("mean()", as.character(features$V2), fixed = TRUE)
  mean.pos <- data.table(V1 = mean.pos, 
                         mean.pos = rep(TRUE, length.out = length(mean.pos)) )
  #Standard Deviation sub vars
  std.pos <- grep("std()", as.character(features$V2), fixed = TRUE)
  std.pos <- data.table(V1 = std.pos, 
                        std.pos = rep(TRUE, length.out = length(std.pos)) )
features <- merge(features, mean.pos, by = "V1", all = TRUE)
features <- merge(features, std.pos, by = "V1", all = TRUE)
features$mean.pos <- !is.na(features$mean.pos)
features$std.pos <- !is.na(features$std.pos)
mean.std.pos <- as.character(features$V2[features$mean.pos == TRUE 
                                         | features$std.pos == TRUE])

#merging for TEST dataset
subject.test <- read.table("./data/test/subject_test.txt")
activity.test <- read.table("./data/test/Y_test.txt")
features.test <- read.table("./data/test/X_test.txt")
  names(features.test) <- as.character(features$V2)
test <- data.table( subject.test, activity.test,  features.test)

#merging for TRAIN dataset
subject.train <- read.table("./data/train/subject_train.txt")
activity.train <- read.table("./data/train/Y_train.txt")
features.train <- read.table("./data/train/X_train.txt")
  names(features.train) <- as.character(features$V2)
train <- data.table(subject.train,  activity.train, features.train)

#Appending the TEST and TRAIN datasets
data <- rbindlist(list(test, train))
setnames(data, 1:2,
         c("subject", "activity.code"))

#Subsetting just the mean() and std() variables
subset.index <- c("subject", "activity.code", mean.std.pos)
data.sub <- subset(data, select = subset.index)

#collapsing the aggregated, tidy dataset
tidy.data <- aggregate( x = data.sub, by = 
                          list(data.sub$subject, data.sub$activity.code), FUN = mean)
tidy.data <- subset(tidy.data, select = subset.index)

#Adding activity description
data <- merge(activity, data, by = "activity.code", all = TRUE )
data.sub <- merge(activity, data.sub, by = "activity.code", all = TRUE )
tidy.data <- merge(activity, tidy.data, by = "activity.code", all = TRUE )
write.table(tidy.data, "tidy_data.txt")

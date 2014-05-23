#Codebook for Coursera Project
## Getting and Cleaning Data: May 22, 2014


This codebook is designed to walk through the data processing and transformations used in the script file run_analysis.R to clarify steps taken in the processing:

First ensure the package(data.table) is installed:

```r
install.packages("data.table")
```


## Download and Directory designation
To ensure reproducible processing, this script checks and creates a new directory on the home c:/ directory called ~/coursera_project/.  This is to create an unambiguous location across machines.  Next the data is downloaded, unzipped and renamed for easy scripting.  If you are using a mac, please use:

```r
download.file(url, destfile = "dataset.zip", mode = "wb", method = "curl")
```
to download files, this uses the "curl" method to get the file.  

## Creating Variable and ID data
This section of code is used to load the data on activity descriptions and feature variable titles.

```r
activity <- read.table("./data/activity_labels.txt")
names(activity) <- c("activity.code", "activity")
features <- read.table("./data/features.txt")
```

Also, this section creates the index of variables that subsets to just mean and standard deviation variables out of the 561 total variables in features. These variables have "mean()" or "std()" exactly in the title.  The ultimate goal is to produce a character vector containing the column titles of the variables of interest.

```r
mean.pos <- grep("mean()", as.character(features$V2), fixed = TRUE)
mean.pos <- data.table(V1 = mean.pos, mean.pos = rep(TRUE, length.out = length(mean.pos)))
# Standard Deviation sub vars
std.pos <- grep("std()", as.character(features$V2), fixed = TRUE)
std.pos <- data.table(V1 = std.pos, std.pos = rep(TRUE, length.out = length(std.pos)))
features <- merge(features, mean.pos, by = "V1", all = TRUE)
features <- merge(features, std.pos, by = "V1", all = TRUE)
features$mean.pos <- !is.na(features$mean.pos)
features$std.pos <- !is.na(features$std.pos)
mean.std.pos <- as.character(features$V2[features$mean.pos == TRUE | features$std.pos == 
    TRUE])
```



## Merging for Test and Train data
Now the actual test and train data can be loaded and cleaned. Here we load the subjects, activities, and feature variables while giving them titles and discriptions

```r
# merging for TEST dataset
subject.test <- read.table("./data/test/subject_test.txt")
activity.test <- read.table("./data/test/Y_test.txt")
features.test <- read.table("./data/test/X_test.txt")
names(features.test) <- as.character(features$V2)
test <- data.table(subject.test, activity.test, features.test)

# merging for TRAIN dataset
subject.train <- read.table("./data/train/subject_train.txt")
activity.train <- read.table("./data/train/Y_train.txt")
features.train <- read.table("./data/train/X_train.txt")
names(features.train) <- as.character(features$V2)
train <- data.table(subject.train, activity.train, features.train)
```

## Append main dataset, subset main dataset, and create Tidy Data
Finally we append these two datasets, to create one large set with all the variables. Now we can use the previously created vector of column names to subset the data to contain only our "mean()" and "std()" appropriate variables as data.sub.  We use this data.sub to create teh final tidy data using the aggregate() function. Lastly we add back in the titles for activity description, and outsheet a dataset as .txt to load to coursera servers.

```r
# Appending the TEST and TRAIN datasets
data <- rbindlist(list(test, train))
setnames(data, 1:2, c("subject", "activity.code"))

# Subsetting just the mean() and std() variables
subset.index <- c("subject", "activity.code", mean.std.pos)
data.sub <- subset(data, select = subset.index)

# collapsing the aggregated, tidy dataset
tidy.data <- aggregate(x = data.sub, by = list(data.sub$subject, data.sub$activity.code), 
    FUN = mean)
tidy.data <- subset(tidy.data, select = subset.index)

# Adding activity description
data <- merge(activity, data, by = "activity.code", all = TRUE)
data.sub <- merge(activity, data.sub, by = "activity.code", all = TRUE)
tidy.data <- merge(activity, tidy.data, by = "activity.code", all = TRUE)
write.table(tidy.data, "tidy_data.txt")
```





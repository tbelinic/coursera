###
### Getting and Cleaning Data Project - run_analysis.R
### Author: Tena Belinic
###


library(dplyr)

#Loading activity_labels and features
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)
activity_labels <- rename(activity_labels, class_label=V1, activity_names=V2)

features <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
features <- rename(features, index=V1, feature_names=V2)
features <- features[grep("(mean|std)", features$feature_names), ]
features <- mutate(features, feature_names=gsub("\\(\\)","", features$feature_names))

#Loading train data
train <- read.table("./UCI HAR Dataset/train/X_train.txt", stringsAsFactors = FALSE)
train <- train[ ,features$index]
colnames(train) <-  features$feature_names

activity_train <- read.table("./UCI HAR Dataset/train/y_train.txt", stringsAsFactors = FALSE)
activity_train <- rename(activity_train, activity=V1)

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", stringsAsFactors = FALSE)
subject_train <- rename(subject_train, subject=V1)
train <- cbind(subject_train, activity_train, train)

#Loading test data
test <- read.table("./UCI HAR Dataset/test/X_test.txt", stringsAsFactors = FALSE)
test <- test[ ,features$index]
colnames(test) <-  features$feature_names

activity_test <- read.table("./UCI HAR Dataset/test/y_test.txt", stringsAsFactors = FALSE)
activity_test <- rename(activity_test, activity=V1)

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", stringsAsFactors = FALSE)
subject_test <- rename(subject_test, subject=V1)
test <- cbind(subject_test, activity_test, test)


# Merging the training and the test sets into one data set.
all_data <- rbind(train, test)

# Changing activity  to  descriptive activity names 
all_data$activity <- factor(all_data$activity, levels = activity_labels$class_label, labels= activity_labels$activity_names)

# Creating tidy data set with the average of each variable for each activity and each subject.
library(reshape2)
tidy_data <- melt(all_data, id=c("subject","activity"))
tidy_data <- dcast(data = tidy_data, subject + activity ~ variable, fun.aggregate = mean)

write.table(x=tidy_data, file="tidy_data.txt", quote = FALSE)
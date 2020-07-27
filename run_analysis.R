#You should create one R script called run_analysis.R that does the following.

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average
#    of each variable for each activity and each subject.

run_analysis <- function(){
  library(dplyr)
  #Downloads and unpacks dataset, if not already done.
  zip <- "projdata.zip"
  if (!file.exists(zip)){
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, zip)
  }  
  if (!file.exists("UCI HAR Dataset")) { 
    unzip(zip) 
  }

  #reads files in dataset folder into tables
  features <- read.table("UCI HAR Dataset/features.txt", col.names = c("num","functions"))
  activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
  subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
  x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
  y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
  subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
  x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
  y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")
  
  # 1. Merges the training and the test sets to create one data set.
  x_data <- rbind(x_train, x_test)
  y_data <- rbind(y_train, y_test)
  subjects <- rbind(subject_train, subject_test)
  merged_data <- cbind(subjects, x_data, y_data)
  
  # 2. Extracts only the measurements on the mean and standard deviation for each measurement.
  tidy_data <- merged_data %>% select(subject, code, contains("mean"), contains("std"))
  
  # 3. Uses descriptive activity names to name the activities in the data set
  tidy_data$code <- activity_labels[tidy_data$code,2]
  names(tidy_data)[2] <- "activity"
  
  # 4. Appropriately labels the data set with descriptive variable names.
  names(tidy_data)<-gsub("Acc", "Accelerometer", names(tidy_data))
  names(tidy_data)<-gsub("Gyro", "Gyroscope", names(tidy_data))
  names(tidy_data)<-gsub("BodyBody", "Body", names(tidy_data))
  names(tidy_data)<-gsub("Mag", "Magnitude", names(tidy_data))
  names(tidy_data)<-gsub("^t", "Time", names(tidy_data))
  names(tidy_data)<-gsub("^f", "Frequency", names(tidy_data))
  names(tidy_data)<-gsub("tBody", "TimeBody", names(tidy_data))
  names(tidy_data)<-gsub("-mean()", "Mean", names(tidy_data), ignore.case = TRUE)
  names(tidy_data)<-gsub("-std()", "STD", names(tidy_data), ignore.case = TRUE)
  names(tidy_data)<-gsub("-freq()", "Frequency", names(tidy_data), ignore.case = TRUE)
  names(tidy_data)<-gsub("angle", "Angle", names(tidy_data))
  names(tidy_data)<-gsub("gravity", "Gravity", names(tidy_data))
  
  # 5. From the data set in step 4, creates a second, independent tidy data set with the average
  #    of each variable for each activity and each subject.
  
  final <- suppressWarnings(tidy_data %>% group_by(subject, activity) %>% summarise_all(funs(mean)))
  write.table(final, "TidyData.txt", row.name=FALSE)
}

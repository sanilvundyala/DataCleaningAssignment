# Code Book
## Transformations to Get Tidy Dataset
### 1. Download dataset
   Checks if dataset is downloaded and extracted, and does so if not. 
   Data extracted into folder named "UCI HAR Dataset"
``` 
  if (!file.exists(zip)){
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, zip)
  }  
  if (!file.exists("UCI HAR Dataset")) { 
    unzip(zip) 
  }
```
### 2. Read files
  Reads files in "UCI HAR Dataset" folder into tables with appropriate column names.
  Data read is separated by subject, x, and y, across the test and train samples. This data needs to be merged.
```
  features <- read.table("UCI HAR Dataset/features.txt", col.names = c("num","functions"))
  activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
  subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
  x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
  y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
  subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
  x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
  y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")
```
### 3. Merge files
  Merges previously read data by subject, x and y. Then merges all 3 categories into one table `merged_data`
```
  x_data <- rbind(x_train, x_test)
  y_data <- rbind(y_train, y_test)
  subjects <- rbind(subject_train, subject_test)
  merged_data <- cbind(subjects, x_data, y_data)
```
### 4. Extract Mean and St. Dev
  Extracts the measurements on the mean an dstandard deviation for each measurement from `merged_data` into `tidy_data` table
```
 tidy_data <- merged_data %>% select(subject, code, contains("mean"), contains("std"))
```
### 5. Descriptive Activity Names
  Uses descriptive activity names from `activity_labels`, replacing the previosly used numeric codes
```
  tidy_data$code <- activity_labels[tidy_data$code,2]
  names(tidy_data)[2] <- "activity"
```
### 6. Descriptive Variable Names
  Labels the data set with descriptive variable names, replacing ones from downloaded files.
```
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
```
### 7. Averages for Activity and Subject
  Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```
final <- suppressWarnings(tidy_data %>% group_by(subject, activity) %>% summarise_all(funs(mean)))
```
### 8. Print Tidy Data
  Writes final grouped and summarized tidy data into a file called "TidyData.txt"
```
write.table(final, "TidyData.txt", row.name=FALSE)
```

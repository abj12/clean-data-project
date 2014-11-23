# data collected from the accelerometers from the Samsung Galaxy S smartphone 
# download data to a temporary file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
temp <- tempfile()
download.file(fileUrl,temp)

# extract info about subjects (merge train and test data)
subject_test <- read.table(unz(temp, "UCI HAR Dataset/test/subject_test.txt"))
subject_train <- read.table(unz(temp, "UCI HAR Dataset/train/subject_train.txt"))
subject <- rbind(subject_test,subject_train)
rm(subject_test,subject_train)

# extract info about performed activities (merge train and test data)
testActivity <- read.table(unz(temp, "UCI HAR Dataset/test/y_test.txt"))
trainActivity <- read.table(unz(temp, "UCI HAR Dataset/train/y_train.txt"))
activity <- rbind(testActivity,trainActivity)
rm(testActivity,trainActivity)

# extract info about performed measurements 
features <- read.table(unz(temp, "UCI HAR Dataset/features.txt"))

# extract train and test data  
testData <- read.table(unz(temp, "UCI HAR Dataset/test/X_test.txt"))
trainData <- read.table(unz(temp, "UCI HAR Dataset/train/X_train.txt"))

unlink(temp)


# (1) Merge the training and the test sets to create one data set
data <- rbind(testData,trainData)
rm(trainData,testData) # remove unnecessary variables to keep workspace tidy

# (4) Appropriately label the data set with descriptive variable names
names(data) <- as.character(features[,2])
rm(features)

# (2) Extracts only variables for the mean and standard deviation of each signal 
subset <- sort(c(grep("mean()",names(data),fixed = TRUE),grep("std()",names(data),fixed = TRUE)))
mydata <- data[,subset]
rm(data)

# (3) Uses descriptive activity names to name the activities in the data set
#install.packages("plyr")
library(plyr)
activity <- factor(activity[,1])
activity <- mapvalues(activity, from = c("1","2","3","4","5","6"), to = c("walk","walk_up","walk_down","sit","stand","lay"))

info <- cbind(subject,activity)
names(info) <- c("subject","activity")

mydata <- cbind(info,mydata)
rm(subject,activity,info)

if(!file.exists("./data")){dir.create("./data")}
write.table(mydata, "./data/mydata.txt", sep="\t") 

# (5) From the data set in step (4), create a second, independent tidy data set
# with the average of each variable for each activity and each subject
#install.packages("reshape2")
library(reshape2)
dataMelt <- melt(mydata, id.vars = c("subject", "activity"))  
tidyData <- dcast(dataMelt, subject + activity ~ variable, fun = mean)

write.table(tidyData, "./data/tidydata.txt", row.name=FALSE) 


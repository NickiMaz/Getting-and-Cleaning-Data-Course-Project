library(dplyr)
library(data.table)

core <- getwd()
setwd("UCI HAR Dataset")
def <- getwd()

#prepareing activity labels
activity_labels <-  read.csv(file = "activity_labels.txt", header = FALSE, sep = " ",
                            col.names = c("Numeration","Activity Name"), row.names = 1)
activity_labels <- as.character(activity_labels$Activity.Name)

#prepareing features data and filter that we need
features <- read.csv(file = "features.txt", header = FALSE, sep = " ",
         col.names = c("Numeration","Feature Name"), row.names = 1)

features_name <- as.character(features[grep(pattern = "(mean\\(\\)|std\\(\\))", x = features$Feature.Name), ])
names(features_name) <- "Feature Name"

features_num <- grep(pattern = "(mean\\(\\)|std\\(\\))", x = features$Feature.Name)
rm(features)

#form test dataset
setwd("test")
sub_test <- read.csv(file = "subject_test.txt", header = FALSE)
sub_test <- factor(as.character(sub_test$V1))
activity_test <- read.csv(file = "y_test.txt", header = FALSE)
activity_test <- as.numeric(activity_test$V1)
test_data <- fread(file = "X_test.txt", select = features_num, sep = " ", dec = ".",
                    header = FALSE, col.names = features_name)
test_data <- mutate(.data = test_data, Subject = sub_test,
                     Activity = factor(x = activity_test, labels = activity_labels))

setwd(def)

#form train dataset
setwd("train")
sub_train <- read.csv(file = "subject_train.txt", header = FALSE)
sub_train <- factor(as.character(sub_train$V1))
activity_train <- read.csv(file = "y_train.txt", header = FALSE)
activity_train <- as.numeric(activity_train$V1)
train_data <- fread(file = "X_train.txt", select = features_num, sep = " ", dec = ".",
                    header = FALSE, col.names = features_name)
train_data <- mutate(.data = train_data, Subject = sub_train,
                     Activity = factor(x = activity_train, labels = activity_labels))

#make first full dataset
first_dataset <- merge(train_data, test_data, all = TRUE)

#make second dataset
subjects <- as.character(sort(as.numeric(levels(first_dataset$Subject))))
string_subj <- paste(rep("Subject", length(subjects)), subjects)
final_names_dataset_2 <- paste(rep(string_subj, each = length(activity_labels)),
                               rep(activity_labels, length(string_subj)), sep = ". ")

second_dataset <- data.frame(matrix(nrow = length(final_names_dataset_2), ncol = length(features_name) + 1))

names(second_dataset) <- c("Subject and Activity", features_name)
second_dataset$`Subject and Activity` <- final_names_dataset_2

for (i in subjects) {
  s <- first_dataset[first_dataset$Subject == i,]
  for (j in activity_labels) {
    a <- s[s$Activity == j,]
    a <- a[,1:(ncol(a) - 2)]
    vec <- lapply(a, mean)
    second_dataset[second_dataset$`Subject and Activity` == paste0("Subject ", i, ". ", j),
                   2:ncol(second_dataset)] <- vec
  }
}

#saving the second dataset
rm(s, a, vec)
setwd(core)
write.table(x = second_dataset, file = "tidy_dataset.txt", row.names = FALSE)

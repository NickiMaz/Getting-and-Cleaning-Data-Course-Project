# Getting-and-Cleaning-Data-Course-Project
In this script ctreated two new datasets

This script made in different way, that descriebed in task.
First thing, i prepared information, which common to test and train data: prepared activity labels vector, like vector of factor variable, and find features, which we need to save in the task. By this way, i economy memory in script.
```{r}

#prepareing activity labels
activity_labels <-  read.csv(file = "activity_labels.txt", header = FALSE, sep = " ",
                            col.names = c("Numeration","Activity Name"), row.names = 1)
activity_labels <- as.character(activity_labels$Activity.Name)

#prepareing features data and filter that we need
features <- read.csv(file = "features.txt", header = FALSE, sep = " ",
         col.names = c("Numeration","Feature Name"), row.names = 1)

features_name <- as.character(features[grep(pattern = "(mean\\(\\)|std\\(\\))", x = features$Feature.Name), ])
names(features_name) <- "Feature Name"

```

After that, i formed test and train data separatlty, and add in this dataset subject and activity label,and after that form first full dataset, which complete first three punkts of the task.

To form second dataset, i prepare new names vector, which indicate subject and activity.
After that in loop i fill second dataset.
```{r}

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

```

Finally this table save in txt format.